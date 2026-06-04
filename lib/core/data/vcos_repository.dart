import '../models/app_settings.dart';
import '../models/expense.dart';
import '../models/sale.dart';

abstract class VcosRepository {
  Future<List<Sale>> loadSales();
  Future<List<Expense>> loadExpenses();
  Future<AppSettings> loadSettings();
  Future<int> loadPendingSyncCount();
  Future<List<String>> loadSuggestions(String field);

  Future<void> saveSale(Sale sale);
  Future<void> saveExpense(Expense expense);
  Future<void> saveSettings(AppSettings settings);
  Future<void> saveSuggestion({
    required String field,
    required String value,
  });
  Future<void> enqueueSync({
    required String entityType,
    required String entityId,
    required String operation,
  });
  Future<void> completeSync({
    required String entityType,
    required String entityId,
    String? remoteId,
  });
}
