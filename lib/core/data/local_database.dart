import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  LocalDatabase();

  Database? _database;

  Future<Database> get instance async {
    final existing = _database;
    if (existing != null) return existing;

    final supportDir = await getApplicationSupportDirectory();
    final dbPath = p.join(supportDir.path, 'vcos_offline.db');

    return _database = await openDatabase(
      dbPath,
      version: 3,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE sales (
            id TEXT PRIMARY KEY,
            remote_id TEXT,
            description TEXT NOT NULL,
            customer_name TEXT NOT NULL,
            amount REAL NOT NULL,
            notes TEXT NOT NULL DEFAULT '',
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            deleted_at TEXT,
            sync_status TEXT NOT NULL
          )
        ''');

        await database.execute('''
          CREATE TABLE expenses (
            id TEXT PRIMARY KEY,
            remote_id TEXT,
            description TEXT NOT NULL,
            category TEXT NOT NULL,
            amount REAL NOT NULL,
            notes TEXT NOT NULL DEFAULT '',
            photo_paths TEXT NOT NULL DEFAULT '[]',
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            deleted_at TEXT,
            sync_status TEXT NOT NULL
          )
        ''');

        await database.execute('''
          CREATE TABLE app_settings (
            id INTEGER PRIMARY KEY CHECK (id = 1),
            studio_name TEXT NOT NULL,
            owner_name TEXT NOT NULL,
            phone TEXT NOT NULL,
            auto_sync_enabled INTEGER NOT NULL,
            high_contrast_enabled INTEGER NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');

        await database.execute('''
          CREATE TABLE sync_queue (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            entity_type TEXT NOT NULL,
            entity_id TEXT NOT NULL,
            operation TEXT NOT NULL,
            created_at TEXT NOT NULL,
            attempted_at TEXT,
            error_message TEXT
          )
        ''');

        await _createSuggestionsTable(database);

        await database.execute(
          'CREATE INDEX idx_sales_sync ON sales(sync_status, updated_at)',
        );
        await database.execute(
          'CREATE INDEX idx_expenses_sync ON expenses(sync_status, updated_at)',
        );
      },
      onUpgrade: (database, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createSuggestionsTable(database);
        }
        if (oldVersion < 3) {
          await _ensureExpensePhotoPathsColumn(database);
        }
      },
      onOpen: _ensureExpensePhotoPathsColumn,
    );
  }

  Future<void> _ensureExpensePhotoPathsColumn(Database database) async {
    final columns = await database.rawQuery('PRAGMA table_info(expenses)');
    final hasPhotoPaths = columns.any((column) {
      return column['name'] == 'photo_paths';
    });
    if (hasPhotoPaths) return;

    await database.execute(
      "ALTER TABLE expenses ADD COLUMN photo_paths TEXT NOT NULL DEFAULT '[]'",
    );
  }

  Future<void> _createSuggestionsTable(Database database) async {
    await database.execute('''
      CREATE TABLE IF NOT EXISTS field_suggestions (
        field TEXT NOT NULL,
        value TEXT NOT NULL,
        usage_count INTEGER NOT NULL DEFAULT 1,
        updated_at TEXT NOT NULL,
        PRIMARY KEY (field, value)
      )
    ''');

    await database.execute(
      'CREATE INDEX IF NOT EXISTS idx_suggestions_field '
      'ON field_suggestions(field, usage_count, updated_at)',
    );
  }
}
