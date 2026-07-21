import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

final class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const _fileName = 'better_todo.db';
  static const _version = 4;
  static const _createTodoSubtasks = '''
    CREATE TABLE todo_subtasks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      scheduled_todo_id INTEGER,
      regular_todo_id INTEGER,
      content TEXT NOT NULL,
      is_completed INTEGER NOT NULL DEFAULT 0
        CHECK (is_completed IN (0, 1)),
      sort_position INTEGER NOT NULL DEFAULT 0,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      CHECK (
        (scheduled_todo_id IS NOT NULL AND regular_todo_id IS NULL)
        OR
        (scheduled_todo_id IS NULL AND regular_todo_id IS NOT NULL)
      ),
      FOREIGN KEY (scheduled_todo_id)
        REFERENCES scheduled_todos (id)
        ON DELETE CASCADE,
      FOREIGN KEY (regular_todo_id)
        REFERENCES regular_todos (id)
        ON DELETE CASCADE
    )
  ''';

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
      onUpgrade: _upgradeSchema,
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
        description TEXT,
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
        description TEXT,
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

    batch.execute(_createTodoSubtasks);

    await batch.commit(noResult: true);
  }

  Future<void> _upgradeSchema(
    Database database,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await database.rawUpdate('''
        UPDATE todo_lists
        SET is_pinned = 1
        WHERE id = (
          SELECT id FROM todo_lists WHERE is_scheduled = 1 LIMIT 1
        )
        AND NOT EXISTS (
          SELECT 1 FROM todo_lists WHERE is_pinned = 1
        )
      ''');
    }
    if (oldVersion < 3) {
      await database.execute(_createTodoSubtasks);
    }
    if (oldVersion < 4) {
      await database.execute(
        'ALTER TABLE scheduled_todos ADD COLUMN description TEXT',
      );
      await database.execute(
        'ALTER TABLE regular_todos ADD COLUMN description TEXT',
      );
    }
  }

  Future<void> close() async {
    final database = _database;
    if (database == null) return;

    await database.close();
    _database = null;
  }
}
