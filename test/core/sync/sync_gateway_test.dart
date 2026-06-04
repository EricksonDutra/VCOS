import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:vcos_app/core/api/api_client.dart';
import 'package:vcos_app/core/api/api_config.dart';
import 'package:vcos_app/core/data/sync_status.dart';
import 'package:vcos_app/core/models/app_settings.dart';
import 'package:vcos_app/core/models/expense.dart';
import 'package:vcos_app/core/models/sale.dart';
import 'package:vcos_app/core/sync/sync_gateway.dart';

void main() {
  test('syncs pending sales through the API client', () async {
    final requests = <http.Request>[];
    final httpClient = MockClient((request) async {
      requests.add(request);
      return http.Response(
        '{"id":"remote-sale-1"}',
        201,
        headers: {'content-type': 'application/json'},
      );
    });
    final gateway = ApiSyncGateway(
      client: ApiClient(
        config: const ApiConfig(baseUrl: 'http://localhost:8000/api/v1'),
        httpClient: httpClient,
      ),
    );
    final sale = Sale(
      id: 'sale-1',
      description: 'Avental',
      customerName: 'Maria',
      amount: 85,
      createdAt: DateTime(2026, 6, 4),
      updatedAt: DateTime(2026, 6, 4),
      syncStatus: SyncStatus.pending,
    );

    final result = await gateway.pushChanges(
      sales: [sale],
      expenses: const [],
    );

    expect(result.success, isTrue);
    expect(result.syncedSales, {'sale-1': 'remote-sale-1'});
    expect(requests.single.method, 'POST');
    expect(requests.single.url.path, '/api/v1/sales');
  });

  test('syncs pending expenses and settings through the API client', () async {
    final requests = <http.Request>[];
    final httpClient = MockClient((request) async {
      requests.add(request);
      if (request.url.path == '/api/v1/settings') {
        return http.Response(
          '{"studio_name":"VCOS","owner_name":"Ana","phone":"123",'
          '"auto_sync_enabled":true,"high_contrast_enabled":false,'
          '"updated_at":"2026-06-04T00:00:00Z"}',
          200,
          headers: {'content-type': 'application/json'},
        );
      }
      return http.Response(
        '{"id":"remote-expense-1"}',
        201,
        headers: {'content-type': 'application/json'},
      );
    });
    final gateway = ApiSyncGateway(
      client: ApiClient(
        config: const ApiConfig(baseUrl: 'http://localhost:8000/api/v1'),
        httpClient: httpClient,
      ),
    );
    final expense = Expense(
      id: 'expense-1',
      description: 'Linha',
      category: 'Materiais',
      amount: 18,
      notes: 'Algodao',
      photoPaths: const ['storage/photo.jpg'],
      createdAt: DateTime(2026, 6, 4),
      updatedAt: DateTime(2026, 6, 4),
      syncStatus: SyncStatus.pending,
    );
    final settings = AppSettings(
      studioName: 'VCOS',
      ownerName: 'Ana',
      phone: '123',
      autoSyncEnabled: true,
      highContrastEnabled: false,
      updatedAt: DateTime(2026, 6, 4),
    );

    final result = await gateway.pushChanges(
      sales: const [],
      expenses: [expense],
      settings: settings,
    );

    expect(result.success, isTrue);
    expect(result.syncedExpenses, {'expense-1': 'remote-expense-1'});
    expect(result.settingsSynced, isTrue);
    expect(requests.map((request) => request.method), ['POST', 'PUT']);
    expect(requests.map((request) => request.url.path), [
      '/api/v1/expenses',
      '/api/v1/settings',
    ]);
    expect(requests.first.body, contains('"photo_paths":["storage/photo.jpg"]'));
  });
}
