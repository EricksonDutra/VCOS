import 'dart:convert';

import 'package:http/http.dart' as http;

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
  })  : _baseUrl = config.baseUrl.replaceFirst(RegExp(r'/$'), ''),
        _httpClient = httpClient ?? http.Client();

  final String _baseUrl;
  final http.Client _httpClient;

  Future<String> upsertSale(Sale sale) async {
    final uri = sale.remoteId == null
        ? Uri.parse('$_baseUrl/sales')
        : Uri.parse('$_baseUrl/sales/${sale.remoteId}');
    final response = sale.remoteId == null
        ? await _httpClient.post(
            uri,
            headers: _jsonHeaders,
            body: jsonEncode(_salePayload(sale)),
          ).timeout(_requestTimeout)
        : await _httpClient.put(
            uri,
            headers: _jsonHeaders,
            body: jsonEncode(_salePayload(sale)),
          ).timeout(_requestTimeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Falha ao sincronizar venda ${sale.id}.');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['id'] as String? ?? sale.remoteId ?? sale.id;
  }

  Future<void> deleteSale(Sale sale) async {
    final remoteId = sale.remoteId ?? sale.id;
    final response = await _httpClient.delete(
      Uri.parse('$_baseUrl/sales/$remoteId'),
      headers: _jsonHeaders,
    ).timeout(_requestTimeout);

    if (response.statusCode == 404) return;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Falha ao remover venda ${sale.id} da API.');
    }
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
      'sync_status': sale.syncStatus.name,
    };
  }
}
