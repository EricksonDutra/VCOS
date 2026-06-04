import '../api/api_client.dart';
import '../models/app_settings.dart';
import '../models/expense.dart';
import '../models/sale.dart';

class SyncResult {
  const SyncResult({
    required this.success,
    this.message = '',
    this.syncedSales = const {},
    this.syncedExpenses = const {},
    this.settingsSynced = false,
  });

  final bool success;
  final String message;
  final Map<String, String> syncedSales;
  final Map<String, String> syncedExpenses;
  final bool settingsSynced;
}

abstract class SyncGateway {
  Future<SyncResult> pushChanges({
    required List<Sale> sales,
    required List<Expense> expenses,
    AppSettings? settings,
  });
}

class PendingApiSyncGateway implements SyncGateway {
  const PendingApiSyncGateway();

  @override
  Future<SyncResult> pushChanges({
    required List<Sale> sales,
    required List<Expense> expenses,
    AppSettings? settings,
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
    AppSettings? settings,
  }) async {
    if (sales.isEmpty && expenses.isEmpty && settings == null) {
      return const SyncResult(
        success: true,
        message: 'Nenhum dado pendente para sincronizar.',
      );
    }

    final syncedSales = <String, String>{};
    final syncedExpenses = <String, String>{};
    var settingsSynced = false;

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

      for (final expense in expenses) {
        if (expense.isDeleted) {
          await _apiClient.deleteExpense(expense);
          syncedExpenses[expense.id] = expense.remoteId ?? expense.id;
          continue;
        }

        final remoteId = await _apiClient.upsertExpense(expense);
        syncedExpenses[expense.id] = remoteId;
      }

      if (settings != null) {
        await _apiClient.updateSettings(settings);
        settingsSynced = true;
      }

      return SyncResult(
        success: true,
        syncedSales: syncedSales,
        syncedExpenses: syncedExpenses,
        settingsSynced: settingsSynced,
        message: 'Dados sincronizados com a API.',
      );
    } on Object {
      return SyncResult(
        success: false,
        syncedSales: syncedSales,
        syncedExpenses: syncedExpenses,
        settingsSynced: settingsSynced,
        message: 'API indisponivel. Dados mantidos localmente.',
      );
    }
  }
}
