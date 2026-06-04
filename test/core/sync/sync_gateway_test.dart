import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:vcos_app/core/api/api_client.dart';
import 'package:vcos_app/core/api/api_config.dart';
import 'package:vcos_app/core/data/sync_status.dart';
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
}
