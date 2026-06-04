import 'package:sqflite/sqflite.dart';

import '../models/app_settings.dart';
import '../models/expense.dart';
import '../models/sale.dart';
import 'local_database.dart';
import 'vcos_repository.dart';

class SqfliteVcosRepository implements VcosRepository {
  SqfliteVcosRepository(this._localDatabase);

  final LocalDatabase _localDatabase;

  Future<Database> get _database => _localDatabase.instance;

  @override
  Future<List<Sale>> loadSales() async {
    final database = await _database;
    final rows = await database.query(
      'sales',
      orderBy: 'created_at DESC',
    );
    return rows.map(Sale.fromMap).toList();
  }

  @override
  Future<List<Expense>> loadExpenses() async {
    final database = await _database;
    final rows = await database.query(
      'expenses',
      orderBy: 'created_at DESC',
    );
    return rows.map(Expense.fromMap).toList();
  }

  @override
  Future<AppSettings> loadSettings() async {
    final database = await _database;
    final rows = await database.query(
      'app_settings',
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );
    if (rows.isNotEmpty) return AppSettings.fromMap(rows.first);

    final defaults = AppSettings.defaults();
    await saveSettings(defaults);
    return defaults;
  }

  @override
  Future<int> loadPendingSyncCount() async {
    final database = await _database;
    final rows = await database.rawQuery(
      'SELECT COUNT(*) AS total FROM sync_queue',
    );
    return rows.first['total'] as int? ?? 0;
  }

  @override
  Future<List<String>> loadSuggestions(String field) async {
    final database = await _database;
    final rows = await database.query(
      'field_suggestions',
      columns: ['value'],
      where: 'field = ?',
      whereArgs: [field],
      orderBy: 'usage_count DESC, updated_at DESC',
      limit: 24,
    );
    return rows.map((row) => row['value'] as String).toList();
  }

  @override
  Future<void> saveSale(Sale sale) async {
    final database = await _database;
    await database.insert(
      'sales',
      sale.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> saveExpense(Expense expense) async {
    final database = await _database;
    await database.insert(
      'expenses',
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    final database = await _database;
    await database.insert(
      'app_settings',
      settings.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> saveSuggestion({
    required String field,
    required String value,
  }) async {
    final cleanValue = value.trim();
    if (cleanValue.length < 2) return;

    final database = await _database;
    final existing = await database.query(
      'field_suggestions',
      columns: ['value', 'usage_count'],
      where: 'field = ? AND lower(value) = lower(?)',
      whereArgs: [field, cleanValue],
      limit: 1,
    );
    final now = DateTime.now().toIso8601String();

    if (existing.isEmpty) {
      await database.insert('field_suggestions', {
        'field': field,
        'value': cleanValue,
        'usage_count': 1,
        'updated_at': now,
      });
      return;
    }

    final currentValue = existing.first['value'] as String;
    final usageCount = existing.first['usage_count'] as int? ?? 1;
    await database.update(
      'field_suggestions',
      {
        'usage_count': usageCount + 1,
        'updated_at': now,
      },
      where: 'field = ? AND value = ?',
      whereArgs: [field, currentValue],
    );
  }

  @override
  Future<void> enqueueSync({
    required String entityType,
    required String entityId,
    required String operation,
  }) async {
    final database = await _database;
    await database.insert('sync_queue', {
      'entity_type': entityType,
      'entity_id': entityId,
      'operation': operation,
      'created_at': DateTime.now().toIso8601String(),
      'attempted_at': null,
      'error_message': null,
    });
  }
}
