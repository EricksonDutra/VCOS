import '../models/app_settings.dart';
import '../models/expense.dart';
import '../models/sale.dart';
import 'sync_status.dart';
import 'vcos_repository.dart';

class MemoryVcosRepository implements VcosRepository {
  final List<Sale> _sales = [];
  final List<Expense> _expenses = [];
  var _settings = AppSettings.defaults();
  var _pendingSyncCount = 0;
  final Set<String> _pendingSyncKeys = {};
  final Map<String, List<String>> _suggestions = {};

  @override
  Future<List<Sale>> loadSales() async => List.unmodifiable(_sales);

  @override
  Future<List<Expense>> loadExpenses() async => List.unmodifiable(_expenses);

  @override
  Future<AppSettings> loadSettings() async => _settings;

  @override
  Future<int> loadPendingSyncCount() async => _pendingSyncCount;

  @override
  Future<bool> hasPendingSync({
    required String entityType,
    String? entityId,
  }) async {
    if (entityId == null) {
      return _pendingSyncKeys.any((key) => key.startsWith('$entityType:'));
    }
    return _pendingSyncKeys.contains('$entityType:$entityId');
  }

  @override
  Future<List<String>> loadSuggestions(String field) async {
    return List.unmodifiable(_suggestions[field] ?? const []);
  }

  @override
  Future<void> saveSale(Sale sale) async {
    _sales.removeWhere((item) => item.id == sale.id);
    _sales.insert(0, sale);
  }

  @override
  Future<void> saveExpense(Expense expense) async {
    _expenses.removeWhere((item) => item.id == expense.id);
    _expenses.insert(0, expense);
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    _settings = settings;
  }

  @override
  Future<void> saveSuggestion({
    required String field,
    required String value,
  }) async {
    final cleanValue = value.trim();
    if (cleanValue.length < 2) return;

    final values = _suggestions.putIfAbsent(field, () => []);
    values.removeWhere(
      (item) => item.toLowerCase() == cleanValue.toLowerCase(),
    );
    values.insert(0, cleanValue);
  }

  @override
  Future<void> replaceRemoteSnapshot({
    required List<Sale> sales,
    required List<Expense> expenses,
    required AppSettings settings,
  }) async {
    _sales
      ..clear()
      ..addAll(sales);
    _expenses
      ..clear()
      ..addAll(expenses);
    _settings = settings;
    _pendingSyncKeys.clear();
    _pendingSyncCount = 0;
  }

  @override
  Future<void> enqueueSync({
    required String entityType,
    required String entityId,
    required String operation,
  }) async {
    final key = '$entityType:$entityId';
    if (_pendingSyncKeys.add(key)) {
      _pendingSyncCount += 1;
    }
  }

  @override
  Future<void> completeSync({
    required String entityType,
    required String entityId,
    String? remoteId,
  }) async {
    if (_pendingSyncKeys.remove('$entityType:$entityId') &&
        _pendingSyncCount > 0) {
      _pendingSyncCount -= 1;
    }

    if (entityType == 'sale') {
      final index = _sales.indexWhere((sale) => sale.id == entityId);
      if (index == -1) return;
      _sales[index] = _sales[index].copyWith(
        remoteId: remoteId,
        syncStatus: SyncStatus.synced,
      );
    }

    if (entityType == 'expense') {
      final index = _expenses.indexWhere((expense) => expense.id == entityId);
      if (index == -1) return;
      _expenses[index] = _expenses[index].copyWith(
        remoteId: remoteId,
        syncStatus: SyncStatus.synced,
      );
    }
  }
}
