import 'package:better_todo/data/local/app_database.dart';
import 'package:better_todo/data/models/todo_models.dart';
import 'package:sqflite/sqflite.dart';

final class TodoRepository {
  TodoRepository({AppDatabase? database})
    : _appDatabase = database ?? AppDatabase.instance;

  final AppDatabase _appDatabase;

  Future<Database> get _db => _appDatabase.database;

  int get _now => DateTime.now().millisecondsSinceEpoch;

  Future<List<TodoListModel>> getLists() async {
    final database = await _db;
    final rows = await database.query(
      'todo_lists',
      orderBy: 'is_pinned DESC, sort_position ASC, id ASC',
    );
    return rows.map(TodoListModel.fromMap).toList();
  }

  Future<int> createList({
    required String name,
    required bool isScheduled,
    bool isLocked = false,
  }) async {
    final database = await _db;
    final position = Sqflite.firstIntValue(
      await database.rawQuery(
        'SELECT COALESCE(MAX(sort_position), 0) + 1000 FROM todo_lists',
      ),
    );
    return database.insert('todo_lists', {
      'name': name.trim(),
      'is_scheduled': isScheduled ? 1 : 0,
      'is_locked': isLocked ? 1 : 0,
      'is_pinned': 0,
      'sort_position': position ?? 1000,
      'created_at': _now,
      'updated_at': _now,
    });
  }

  Future<void> updateList(
    TodoListModel list, {
    String? name,
    bool? isLocked,
  }) async {
    final database = await _db;
    await database.update(
      'todo_lists',
      {
        if (name != null) 'name': name.trim(),
        if (isLocked != null) 'is_locked': isLocked ? 1 : 0,
        'updated_at': _now,
      },
      where: 'id = ?',
      whereArgs: [list.id],
    );
  }

  Future<void> deleteList(int id) async {
    final database = await _db;
    await database.delete('todo_lists', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> pinList(int? id) async {
    final database = await _db;
    await database.transaction((transaction) async {
      await transaction.update('todo_lists', {'is_pinned': 0});
      if (id != null) {
        await transaction.update(
          'todo_lists',
          {'is_pinned': 1, 'updated_at': _now},
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    });
  }

  Future<void> reorderLists(List<int> ids) async {
    final database = await _db;
    await database.transaction((transaction) async {
      for (var index = 0; index < ids.length; index++) {
        await transaction.update(
          'todo_lists',
          {'sort_position': (index + 1) * 1000, 'updated_at': _now},
          where: 'id = ?',
          whereArgs: [ids[index]],
        );
      }
    });
  }

  Future<String?> getPassword() async {
    final database = await _db;
    final rows = await database.query(
      'app_settings',
      columns: ['password'],
      where: 'id = 1',
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first['password'] as String?;
  }

  Future<void> setPassword(String? password) async {
    final database = await _db;
    await database.insert('app_settings', {
      'id': 1,
      'password': password?.isEmpty ?? true ? null : password,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<ListSectionModel>> getSections(int listId) async {
    final database = await _db;
    final rows = await database.query(
      'list_sections',
      where: 'list_id = ?',
      whereArgs: [listId],
      orderBy: 'sort_position ASC, id ASC',
    );
    return rows.map(ListSectionModel.fromMap).toList();
  }

  Future<int> createSection(int listId, String name) async {
    final database = await _db;
    final position = Sqflite.firstIntValue(
      await database.rawQuery(
        'SELECT COALESCE(MAX(sort_position), 0) + 1000 '
        'FROM list_sections WHERE list_id = ?',
        [listId],
      ),
    );
    return database.insert('list_sections', {
      'list_id': listId,
      'name': name.trim(),
      'sort_position': position ?? 1000,
      'created_at': _now,
      'updated_at': _now,
    });
  }

  Future<void> renameSection(int id, String name) async {
    final database = await _db;
    await database.update(
      'list_sections',
      {'name': name.trim(), 'updated_at': _now},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteSection(int id) async {
    final database = await _db;
    await database.delete('list_sections', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> reorderSections(List<int> ids) async {
    final database = await _db;
    await database.transaction((transaction) async {
      for (var index = 0; index < ids.length; index++) {
        await transaction.update(
          'list_sections',
          {'sort_position': (index + 1) * 1000, 'updated_at': _now},
          where: 'id = ?',
          whereArgs: [ids[index]],
        );
      }
    });
  }

  Future<List<ScheduledTodoModel>> getScheduledTodos(
    int listId,
    DateTime start,
    DateTime end,
  ) async {
    final database = await _db;
    final rows = await database.query(
      'scheduled_todos',
      where: 'list_id = ? AND scheduled_day BETWEEN ? AND ?',
      whereArgs: [listId, databaseDay(start), databaseDay(end)],
      orderBy: 'scheduled_day ASC, is_completed ASC, sort_position ASC, id ASC',
    );
    return rows.map(ScheduledTodoModel.fromMap).toList();
  }

  Future<int> createScheduledTodo({
    required int listId,
    required String content,
    required DateTime day,
    int? minute,
  }) async {
    final database = await _db;
    final dayValue = databaseDay(day);
    final position = Sqflite.firstIntValue(
      await database.rawQuery(
        'SELECT COALESCE(MAX(sort_position), 0) + 1000 '
        'FROM scheduled_todos WHERE list_id = ? AND scheduled_day = ?',
        [listId, dayValue],
      ),
    );
    return database.insert('scheduled_todos', {
      'list_id': listId,
      'content': content.trim(),
      'scheduled_day': dayValue,
      'scheduled_minute': minute,
      'sort_position': position ?? 1000,
      'created_at': _now,
      'updated_at': _now,
    });
  }

  Future<void> updateScheduledTodo(
    ScheduledTodoModel todo, {
    String? content,
    DateTime? day,
    int? minute,
    bool updateMinute = false,
    bool? isCompleted,
  }) async {
    final database = await _db;
    await database.update(
      'scheduled_todos',
      {
        if (content != null) 'content': content.trim(),
        if (day != null) 'scheduled_day': databaseDay(day),
        if (updateMinute) 'scheduled_minute': minute,
        if (isCompleted != null) 'is_completed': isCompleted ? 1 : 0,
        if (isCompleted != null) 'completed_at': isCompleted ? _now : null,
        'updated_at': _now,
      },
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  Future<void> deleteScheduledTodo(int id) async {
    final database = await _db;
    await database.delete('scheduled_todos', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> moveScheduledTodo(ScheduledTodoModel todo, DateTime day) async {
    final database = await _db;
    final dayValue = databaseDay(day);
    await database.transaction((transaction) async {
      final position = Sqflite.firstIntValue(
        await transaction.rawQuery(
          'SELECT COALESCE(MAX(sort_position), 0) + 1000 '
          'FROM scheduled_todos WHERE list_id = ? AND scheduled_day = ?',
          [todo.listId, dayValue],
        ),
      );
      await transaction.update(
        'scheduled_todos',
        {
          'scheduled_day': dayValue,
          'sort_position': position ?? 1000,
          'updated_at': _now,
        },
        where: 'id = ?',
        whereArgs: [todo.id],
      );
    });
  }

  Future<void> reorderScheduledTodos(List<int> ids) async {
    await _reorderTodos('scheduled_todos', ids);
  }

  Future<List<RegularTodoModel>> getRegularTodos(int listId) async {
    final database = await _db;
    final rows = await database.query(
      'regular_todos',
      where: 'list_id = ?',
      whereArgs: [listId],
      orderBy:
          'section_id IS NOT NULL, section_id ASC, is_completed ASC, '
          'sort_position ASC, id ASC',
    );
    return rows.map(RegularTodoModel.fromMap).toList();
  }

  Future<int> createRegularTodo({
    required int listId,
    required String content,
    int? sectionId,
  }) async {
    final database = await _db;
    final position = Sqflite.firstIntValue(
      await database.rawQuery(
        'SELECT COALESCE(MAX(sort_position), 0) + 1000 '
        'FROM regular_todos WHERE list_id = ? '
        'AND ((? IS NULL AND section_id IS NULL) '
        'OR section_id = ?)',
        [listId, sectionId, sectionId],
      ),
    );
    return database.insert('regular_todos', {
      'list_id': listId,
      'section_id': sectionId,
      'content': content.trim(),
      'sort_position': position ?? 1000,
      'created_at': _now,
      'updated_at': _now,
    });
  }

  Future<void> updateRegularTodo(
    RegularTodoModel todo, {
    String? content,
    int? sectionId,
    bool updateSection = false,
    bool? isCompleted,
  }) async {
    final database = await _db;
    await database.update(
      'regular_todos',
      {
        if (content != null) 'content': content.trim(),
        if (updateSection) 'section_id': sectionId,
        if (isCompleted != null) 'is_completed': isCompleted ? 1 : 0,
        if (isCompleted != null) 'completed_at': isCompleted ? _now : null,
        'updated_at': _now,
      },
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  Future<void> deleteRegularTodo(int id) async {
    final database = await _db;
    await database.delete('regular_todos', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> reorderRegularTodos(List<int> ids) async {
    await _reorderTodos('regular_todos', ids);
  }

  Future<void> _reorderTodos(String table, List<int> ids) async {
    final database = await _db;
    await database.transaction((transaction) async {
      for (var index = 0; index < ids.length; index++) {
        await transaction.update(
          table,
          {'sort_position': (index + 1) * 1000, 'updated_at': _now},
          where: 'id = ?',
          whereArgs: [ids[index]],
        );
      }
    });
  }
}
