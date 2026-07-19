import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

final class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const _fileName = 'better_todo.db';
  static const _version = 1;

  Database? _database;

  Future<Database> get database async {
    return _database ??= await _open();
  }

  Future<Database> _open() async {
    final directory = await getDatabasesPath();

    return openDatabase(
      path.join(directory, _fileName),
      version: _version,
      onConfigure: _configure,
      onCreate: _createSchema,
    );
  }

  Future<void> _configure(Database database) async {
    await database.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _createSchema(Database database, int version) async {
    final batch = database.batch();

    batch.execute('''
      CREATE TABLE app_settings (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        password TEXT
      )
    ''');

    batch.execute('''
      CREATE TABLE todo_lists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        is_scheduled INTEGER NOT NULL DEFAULT 0
          CHECK (is_scheduled IN (0, 1)),
        is_locked INTEGER NOT NULL DEFAULT 0
          CHECK (is_locked IN (0, 1)),
        is_pinned INTEGER NOT NULL DEFAULT 0
          CHECK (is_pinned IN (0, 1)),
        sort_position INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    batch.execute('''
      CREATE TABLE list_sections (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        list_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        sort_position INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (list_id)
          REFERENCES todo_lists (id)
          ON DELETE CASCADE
      )
    ''');

    batch.execute('''
      CREATE TABLE scheduled_todos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        list_id INTEGER NOT NULL,
        content TEXT NOT NULL,
        scheduled_day TEXT NOT NULL,
        scheduled_minute INTEGER
          CHECK (
            scheduled_minute IS NULL
            OR scheduled_minute BETWEEN 0 AND 1439
          ),
        is_completed INTEGER NOT NULL DEFAULT 0
          CHECK (is_completed IN (0, 1)),
        sort_position INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        completed_at INTEGER,
        FOREIGN KEY (list_id)
          REFERENCES todo_lists (id)
          ON DELETE CASCADE
      )
    ''');

    batch.execute('''
      CREATE TABLE regular_todos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        list_id INTEGER NOT NULL,
        section_id INTEGER,
        content TEXT NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0
          CHECK (is_completed IN (0, 1)),
        sort_position INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        completed_at INTEGER,
        FOREIGN KEY (list_id)
          REFERENCES todo_lists (id)
          ON DELETE CASCADE,
        FOREIGN KEY (section_id)
          REFERENCES list_sections (id)
          ON DELETE SET NULL
      )
    ''');

    await batch.commit(noResult: true);
  }

  Future<void> close() async {
    final database = _database;
    if (database == null) return;

    await database.close();
    _database = null;
  }
}
