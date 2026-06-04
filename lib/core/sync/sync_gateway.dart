import '../api/api_client.dart';
import '../models/expense.dart';
import '../models/sale.dart';

class SyncResult {
  const SyncResult({
    required this.success,
    this.message = '',
    this.syncedSales = const {},
  });

  final bool success;
  final String message;
  final Map<String, String> syncedSales;
}

abstract class SyncGateway {
  Future<SyncResult> pushChanges({
    required List<Sale> sales,
    required List<Expense> expenses,
  });
}

class PendingApiSyncGateway implements SyncGateway {
  const PendingApiSyncGateway();

  @override
  Future<SyncResult> pushChanges({
    required List<Sale> sales,
    required List<Expense> expenses,
  }) async {
    return const SyncResult(
      success: false,
      message: 'API ainda nao configurada. Dados mantidos localmente.',
    );
  }
}

class ApiSyncGateway implements SyncGateway {
  ApiSyncGateway({ApiClient? client}) : _apiClient = client ?? ApiClient();

  final ApiClient _apiClient;

  @override
  Future<SyncResult> pushChanges({
    required List<Sale> sales,
    required List<Expense> expenses,
  }) async {
    if (sales.isEmpty) {
      return const SyncResult(
        success: true,
        message: 'Nenhuma venda pendente para sincronizar.',
      );
    }

    final syncedSales = <String, String>{};

    try {
      for (final sale in sales) {
        if (sale.isDeleted) {
          await _apiClient.deleteSale(sale);
          syncedSales[sale.id] = sale.remoteId ?? sale.id;
          continue;
        }

        final remoteId = await _apiClient.upsertSale(sale);
        syncedSales[sale.id] = remoteId;
      }

      final ignoredExpensesMessage = expenses.isEmpty
          ? ''
          : ' Gastos continuam pendentes por enquanto.';
      return SyncResult(
        success: true,
        syncedSales: syncedSales,
        message: 'Vendas sincronizadas com a API.$ignoredExpensesMessage',
      );
    } on Object {
      return SyncResult(
        success: false,
        syncedSales: syncedSales,
        message: 'API indisponivel. Dados mantidos localmente.',
      );
    }
  }
}
