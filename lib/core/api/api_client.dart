import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../data/sync_status.dart';
import '../models/app_settings.dart';
import '../models/expense.dart';
import '../models/sale.dart';
import 'api_config.dart';

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({
    ApiConfig config = const ApiConfig(),
    http.Client? httpClient,
  })  : _baseUrl = config.baseUrl.endsWith('/')
            ? config.baseUrl.substring(0, config.baseUrl.length - 1)
            : config.baseUrl,
        _httpClient = httpClient ?? http.Client();

  final String _baseUrl;
  final http.Client _httpClient;

  Future<List<Sale>> listSales() async {
    final response = await _httpClient
        .get(
          Uri.parse('$_baseUrl/sales?include_deleted=true'),
          headers: _jsonHeaders,
        )
        .timeout(_requestTimeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const ApiException('Falha ao baixar vendas da API.');
    }

    final body = jsonDecode(response.body) as List<dynamic>;
    return body
        .whereType<Map<String, dynamic>>()
        .map((item) => Sale.fromMap(_remoteRecordMap(item)))
        .toList();
  }

  Future<List<Expense>> listExpenses() async {
    final response = await _httpClient
        .get(
          Uri.parse('$_baseUrl/expenses?include_deleted=true'),
          headers: _jsonHeaders,
        )
        .timeout(_requestTimeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const ApiException('Falha ao baixar gastos da API.');
    }

    final body = jsonDecode(response.body) as List<dynamic>;
    return body.whereType<Map<String, dynamic>>().map((item) {
      final map = _remoteRecordMap(item);
      map['photo_paths'] = jsonEncode(
        _remotePhotoPaths(item['photo_paths']),
      );
      return Expense.fromMap(map);
    }).toList();
  }

  Future<AppSettings> readSettings() async {
    final response = await _httpClient
        .get(
          Uri.parse('$_baseUrl/settings'),
          headers: _jsonHeaders,
        )
        .timeout(_requestTimeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const ApiException('Falha ao baixar configuracoes da API.');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return AppSettings.fromMap(body);
  }

  Future<String> upsertSale(Sale sale) async {
    final uri = sale.remoteId == null
        ? Uri.parse('$_baseUrl/sales')
        : Uri.parse('$_baseUrl/sales/${sale.remoteId}');
    final response = sale.remoteId == null
        ? await _httpClient
            .post(
              uri,
              headers: _jsonHeaders,
              body: jsonEncode(_salePayload(sale)),
            )
            .timeout(_requestTimeout)
        : await _httpClient
            .put(
              uri,
              headers: _jsonHeaders,
              body: jsonEncode(_salePayload(sale)),
            )
            .timeout(_requestTimeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Falha ao sincronizar venda ${sale.id}.');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['id'] as String? ?? sale.remoteId ?? sale.id;
  }

  Future<void> deleteSale(Sale sale) async {
    final remoteId = sale.remoteId ?? sale.id;
    final response = await _httpClient
        .delete(
          Uri.parse('$_baseUrl/sales/$remoteId'),
          headers: _jsonHeaders,
        )
        .timeout(_requestTimeout);

    if (response.statusCode == 404) return;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Falha ao remover venda ${sale.id} da API.');
    }
  }

  Future<String> upsertExpense(Expense expense) async {
    final uri = expense.remoteId == null
        ? Uri.parse('$_baseUrl/expenses')
        : Uri.parse('$_baseUrl/expenses/${expense.remoteId}');
    final payload = await _expensePayload(expense);
    final response = expense.remoteId == null
        ? await _httpClient
            .post(
              uri,
              headers: _jsonHeaders,
              body: jsonEncode(payload),
            )
            .timeout(_requestTimeout)
        : await _httpClient
            .put(
              uri,
              headers: _jsonHeaders,
              body: jsonEncode(payload),
            )
            .timeout(_requestTimeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Falha ao sincronizar gasto ${expense.id}.');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['id'] as String? ?? expense.remoteId ?? expense.id;
  }

  Future<void> deleteExpense(Expense expense) async {
    final remoteId = expense.remoteId ?? expense.id;
    final response = await _httpClient
        .delete(
          Uri.parse('$_baseUrl/expenses/$remoteId'),
          headers: _jsonHeaders,
        )
        .timeout(_requestTimeout);

    if (response.statusCode == 404) return;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Falha ao remover gasto ${expense.id} da API.');
    }
  }

  Future<void> updateSettings(AppSettings settings) async {
    final response = await _httpClient
        .put(
          Uri.parse('$_baseUrl/settings'),
          headers: _jsonHeaders,
          body: jsonEncode(_settingsPayload(settings)),
        )
        .timeout(_requestTimeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const ApiException('Falha ao sincronizar configuracoes.');
    }
  }

  Future<String> uploadExpensePhoto(String photoPath) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/uploads/expense-photos'),
    );
    request.files.add(await http.MultipartFile.fromPath('file', photoPath));

    final streamedResponse =
        await _httpClient.send(request).timeout(_requestTimeout);
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const ApiException('Falha ao enviar foto do gasto.');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final remoteUrl = body['url'] as String?;
    final remotePath = body['path'] as String?;
    if (remotePath != null && remotePath.isNotEmpty) {
      return _resolveRemotePath(remotePath);
    }
    if (remoteUrl != null && remoteUrl.isNotEmpty) return remoteUrl;
    throw const ApiException('API nao retornou a URL da foto.');
  }

  static const _jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  static const _requestTimeout = Duration(seconds: 5);

  Map<String, Object?> _salePayload(Sale sale) {
    return {
      'id': sale.id,
      'remote_id': sale.remoteId,
      'description': sale.description,
      'customer_name': sale.customerName,
      'amount': sale.amount,
      'notes': sale.notes,
      'created_at': sale.createdAt.toIso8601String(),
      'updated_at': sale.updatedAt.toIso8601String(),
      'deleted_at': sale.deletedAt?.toIso8601String(),
      'sync_status': SyncStatus.synced.name,
    };
  }

  Future<Map<String, Object?>> _expensePayload(Expense expense) async {
    return {
      'id': expense.id,
      'remote_id': expense.remoteId,
      'description': expense.description,
      'category': expense.category,
      'amount': expense.amount,
      'notes': expense.notes,
      'photo_paths': await _uploadedPhotoPaths(expense.photoPaths),
      'created_at': expense.createdAt.toIso8601String(),
      'updated_at': expense.updatedAt.toIso8601String(),
      'deleted_at': expense.deletedAt?.toIso8601String(),
      'sync_status': SyncStatus.synced.name,
    };
  }

  Map<String, Object?> _settingsPayload(AppSettings settings) {
    return {
      'studio_name': settings.studioName,
      'owner_name': settings.ownerName,
      'phone': settings.phone,
      'auto_sync_enabled': settings.autoSyncEnabled,
      'high_contrast_enabled': settings.highContrastEnabled,
    };
  }

  Future<List<String>> _uploadedPhotoPaths(List<String> photoPaths) async {
    final uploadedPaths = <String>[];
    for (final photoPath in photoPaths) {
      if (_isRemotePath(photoPath)) {
        uploadedPaths.add(photoPath);
        continue;
      }

      final file = File(photoPath);
      if (!file.existsSync()) {
        uploadedPaths.add(photoPath);
        continue;
      }
      uploadedPaths.add(await uploadExpensePhoto(photoPath));
    }
    return uploadedPaths;
  }

  Map<String, Object?> _remoteRecordMap(Map<String, dynamic> item) {
    return {
      ...item,
      'remote_id': item['remote_id'] as String? ?? item['id'],
      'sync_status': SyncStatus.synced.name,
    };
  }

  List<String> _remotePhotoPaths(Object? value) {
    if (value is! List) return const [];
    return value.whereType<String>().map(_resolveRemotePath).toList();
  }

  bool _isRemotePath(String value) {
    return value.startsWith('http://') || value.startsWith('https://');
  }

  String _resolveRemotePath(String value) {
    if (_isRemotePath(value)) return value;
    if (!value.startsWith('/')) return value;

    final uri = Uri.parse(_baseUrl);
    final port = uri.hasPort ? ':${uri.port}' : '';
    return '${uri.scheme}://${uri.host}$port$value';
  }
}
