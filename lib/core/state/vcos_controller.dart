import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/sync_status.dart';
import '../data/vcos_repository.dart';
import '../models/app_settings.dart';
import '../models/dashboard_summary.dart';
import '../models/expense.dart';
import '../models/sale.dart';
import '../sync/sync_gateway.dart';

class VcosController extends ChangeNotifier {
  VcosController({
    required VcosRepository repository,
    SyncGateway syncGateway = const PendingApiSyncGateway(),
  })  : _repository = repository,
        _syncGateway = syncGateway;

  final VcosRepository _repository;
  final SyncGateway _syncGateway;

  List<Sale> _sales = [];
  List<Expense> _expenses = [];
  final Map<String, List<String>> _suggestions = {};
  AppSettings _settings = AppSettings.defaults();
  var _pendingSyncCount = 0;
  var _isLoading = true;
  var _isSyncing = false;
  String? _message;

  List<Sale> get sales => List.unmodifiable(_sales);
  List<Expense> get expenses => List.unmodifiable(_expenses);
  AppSettings get settings => _settings;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  String? get message => _message;
  List<String> suggestionsFor(String field) {
    return List.unmodifiable(_suggestions[field] ?? const []);
  }

  DashboardSummary get summary {
    return DashboardSummary.fromRecords(
      sales: _sales,
      expenses: _expenses,
      pendingSyncCount: _pendingSyncCount,
    );
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    _sales = await _repository.loadSales();
    _expenses = await _repository.loadExpenses();
    _settings = await _repository.loadSettings();
    _pendingSyncCount = await _repository.loadPendingSyncCount();
    await _loadSuggestions();
    _isLoading = false;
    notifyListeners();

    unawaited(runAutoSync());
  }

  Future<void> addSale({
    required String description,
    required String customerName,
    required double amount,
    required DateTime date,
    String notes = '',
  }) async {
    final now = DateTime.now();
    final sale = Sale(
      id: _newLocalId('sale'),
      description: description.trim(),
      customerName: customerName.trim(),
      amount: amount,
      notes: notes.trim(),
      createdAt: date,
      updatedAt: now,
      syncStatus: SyncStatus.pending,
    );

    await _repository.saveSale(sale);
    await rememberSuggestion('sale_description', sale.description);
    await rememberSuggestion('sale_customer', sale.customerName);
    await _repository.enqueueSync(
      entityType: 'sale',
      entityId: sale.id,
      operation: 'upsert',
    );
    await _refreshRecords();
    _message = 'Venda salva offline. Sincronizacao fica pendente.';
    notifyListeners();
    unawaited(runAutoSync());
  }

  Future<void> updateSale({
    required Sale sale,
    required String description,
    required String customerName,
    required double amount,
    required DateTime date,
    String notes = '',
  }) async {
    final updatedSale = sale.copyWith(
      description: description.trim(),
      customerName: customerName.trim(),
      amount: amount,
      notes: notes.trim(),
      createdAt: date,
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pending,
    );

    await _repository.saveSale(updatedSale);
    await rememberSuggestion('sale_description', updatedSale.description);
    await rememberSuggestion('sale_customer', updatedSale.customerName);
    await _repository.enqueueSync(
      entityType: 'sale',
      entityId: updatedSale.id,
      operation: 'upsert',
    );
    await _refreshRecords();
    _message = 'Venda atualizada offline.';
    notifyListeners();
    unawaited(runAutoSync());
  }

  Future<void> deleteSale(Sale sale) async {
    final deletedSale = sale.copyWith(
      updatedAt: DateTime.now(),
      deletedAt: DateTime.now(),
      syncStatus: SyncStatus.pending,
    );

    await _repository.saveSale(deletedSale);
    await _repository.enqueueSync(
      entityType: 'sale',
      entityId: deletedSale.id,
      operation: 'delete',
    );
    await _refreshRecords();
    _message = 'Venda excluida offline.';
    notifyListeners();
    unawaited(runAutoSync());
  }

  Future<void> addExpense({
    required String description,
    required String category,
    required double amount,
    required DateTime date,
    String notes = '',
    List<String> photoPaths = const [],
  }) async {
    final now = DateTime.now();
    final expense = Expense(
      id: _newLocalId('expense'),
      description: description.trim(),
      category: category.trim().isEmpty ? 'Materiais' : category.trim(),
      amount: amount,
      notes: notes.trim(),
      photoPaths: photoPaths,
      createdAt: date,
      updatedAt: now,
      syncStatus: SyncStatus.pending,
    );

    await _repository.saveExpense(expense);
    await rememberSuggestion('expense_description', expense.description);
    await rememberSuggestion('expense_category', expense.category);
    await _repository.enqueueSync(
      entityType: 'expense',
      entityId: expense.id,
      operation: 'upsert',
    );
    await _refreshRecords();
    _message = 'Gasto salvo offline. Sincronizacao fica pendente.';
    notifyListeners();
    unawaited(runAutoSync());
  }

  Future<void> updateExpense({
    required Expense expense,
    required String description,
    required String category,
    required double amount,
    required DateTime date,
    String notes = '',
    List<String> photoPaths = const [],
  }) async {
    final updatedExpense = expense.copyWith(
      description: description.trim(),
      category: category.trim().isEmpty ? 'Materiais' : category.trim(),
      amount: amount,
      notes: notes.trim(),
      photoPaths: photoPaths,
      createdAt: date,
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pending,
    );

    await _repository.saveExpense(updatedExpense);
    await rememberSuggestion('expense_description', updatedExpense.description);
    await rememberSuggestion('expense_category', updatedExpense.category);
    await _repository.enqueueSync(
      entityType: 'expense',
      entityId: updatedExpense.id,
      operation: 'upsert',
    );
    await _refreshRecords();
    _message = 'Gasto atualizado offline.';
    notifyListeners();
    unawaited(runAutoSync());
  }

  Future<void> deleteExpense(Expense expense) async {
    final deletedExpense = expense.copyWith(
      updatedAt: DateTime.now(),
      deletedAt: DateTime.now(),
      syncStatus: SyncStatus.pending,
    );

    await _repository.saveExpense(deletedExpense);
    await _repository.enqueueSync(
      entityType: 'expense',
      entityId: deletedExpense.id,
      operation: 'delete',
    );
    await _refreshRecords();
    _message = 'Gasto excluido offline.';
    notifyListeners();
    unawaited(runAutoSync());
  }

  Future<void> updateSettings(AppSettings settings) async {
    _settings = settings.copyWith(updatedAt: DateTime.now());
    await _repository.saveSettings(_settings);
    await _repository.enqueueSync(
      entityType: 'settings',
      entityId: '1',
      operation: 'upsert',
    );
    _pendingSyncCount = await _repository.loadPendingSyncCount();
    _message = 'Configuracoes salvas no aparelho.';
    notifyListeners();
    unawaited(runAutoSync());
  }

  Future<void> runAutoSync() async {
    if (!_settings.autoSyncEnabled || _isSyncing || _pendingSyncCount == 0) {
      return;
    }

    _isSyncing = true;
    notifyListeners();

    final hasPendingSettings = await _repository.hasPendingSync(
      entityType: 'settings',
      entityId: '1',
    );
    final result = await _syncGateway.pushChanges(
      sales:
          _sales.where((sale) => sale.syncStatus != SyncStatus.synced).toList(),
      expenses: _expenses
          .where((expense) => expense.syncStatus != SyncStatus.synced)
          .toList(),
      settings: hasPendingSettings ? _settings : null,
    );

    for (final entry in result.syncedSales.entries) {
      await _repository.completeSync(
        entityType: 'sale',
        entityId: entry.key,
        remoteId: entry.value,
      );
    }
    for (final entry in result.syncedExpenses.entries) {
      await _repository.completeSync(
        entityType: 'expense',
        entityId: entry.key,
        remoteId: entry.value,
      );
    }
    if (result.settingsSynced) {
      await _repository.completeSync(
        entityType: 'settings',
        entityId: '1',
      );
    }
    await _refreshRecords();
    _message = result.message;
    _isSyncing = false;
    notifyListeners();
  }

  void clearMessage() {
    _message = null;
  }

  Future<void> rememberSuggestion(String field, String value) async {
    final cleanValue = value.trim();
    if (cleanValue.length < 2) return;

    await _repository.saveSuggestion(field: field, value: cleanValue);
    final values = await _repository.loadSuggestions(field);
    _suggestions[field] = values;
    notifyListeners();
  }

  Future<void> _refreshRecords() async {
    _sales = await _repository.loadSales();
    _expenses = await _repository.loadExpenses();
    _pendingSyncCount = await _repository.loadPendingSyncCount();
  }

  String _newLocalId(String prefix) {
    return '$prefix-${DateTime.now().microsecondsSinceEpoch}';
  }

  Future<void> _loadSuggestions() async {
    for (final field in const [
      'sale_description',
      'sale_customer',
      'expense_description',
      'expense_category',
    ]) {
      _suggestions[field] = await _repository.loadSuggestions(field);
    }
  }
}
