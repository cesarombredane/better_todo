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
    bool isPinned = false,
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
      'is_pinned': isPinned ? 1 : 0,
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

  Future<List<PersonModel>> getPersons() async {
    final database = await _db;
    final rows = await database.query(
      'persons',
      orderBy: 'is_owner DESC, name COLLATE NOCASE ASC, id ASC',
    );
    return rows.map(PersonModel.fromMap).toList();
  }

  Future<int> createPerson(String name) async {
    final database = await _db;
    return database.insert('persons', {
      'name': name.trim(),
      'is_owner': 0,
      'created_at': _now,
      'updated_at': _now,
    });
  }

  Future<List<DailyPrideModel>> getDailyPride() async {
    final database = await _db;
    final rows = await database.query('daily_pride', orderBy: 'day ASC');
    return rows.map(DailyPrideModel.fromMap).toList();
  }

  Future<void> setDailyPride(DateTime day, PrideAnswer answer) async {
    final database = await _db;
    final dayValue = databaseDay(day);
    await database.insert('daily_pride', {
      'day': dayValue,
      'answer': answer.name,
      'created_at': _now,
      'updated_at': _now,
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
    String? description,
    int? assigneeId,
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
      'description': _normalizedDescription(description),
      'assignee_id': assigneeId,
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
    String? description,
    bool updateDescription = false,
    int? assigneeId,
    bool updateAssignee = false,
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
        if (updateDescription)
          'description': _normalizedDescription(description),
        if (updateAssignee) 'assignee_id': assigneeId,
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
    String? description,
    int? assigneeId,
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
      'description': _normalizedDescription(description),
      'assignee_id': assigneeId,
      'sort_position': position ?? 1000,
      'created_at': _now,
      'updated_at': _now,
    });
  }

  Future<void> updateRegularTodo(
    RegularTodoModel todo, {
    String? content,
    String? description,
    bool updateDescription = false,
    int? assigneeId,
    bool updateAssignee = false,
    int? sectionId,
    bool updateSection = false,
    bool? isCompleted,
  }) async {
    final database = await _db;
    await database.update(
      'regular_todos',
      {
        if (content != null) 'content': content.trim(),
        if (updateDescription)
          'description': _normalizedDescription(description),
        if (updateAssignee) 'assignee_id': assigneeId,
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

  Future<List<TodoSubtaskModel>> getScheduledSubtasks(int todoId) =>
      _getSubtasks('scheduled_todo_id', todoId);

  Future<List<TodoSubtaskModel>> getRegularSubtasks(int todoId) =>
      _getSubtasks('regular_todo_id', todoId);

  Future<List<TodoSubtaskModel>> getScheduledSubtasksForList(int listId) =>
      _getSubtasksForList(
        parentTable: 'scheduled_todos',
        parentColumn: 'scheduled_todo_id',
        listId: listId,
      );

  Future<List<TodoSubtaskModel>> getRegularSubtasksForList(int listId) =>
      _getSubtasksForList(
        parentTable: 'regular_todos',
        parentColumn: 'regular_todo_id',
        listId: listId,
      );

  Future<List<TodoSubtaskModel>> _getSubtasksForList({
    required String parentTable,
    required String parentColumn,
    required int listId,
  }) async {
    final database = await _db;
    final rows = await database.rawQuery(
      'SELECT todo_subtasks.* FROM todo_subtasks '
      'INNER JOIN $parentTable '
      'ON $parentTable.id = todo_subtasks.$parentColumn '
      'WHERE $parentTable.list_id = ? '
      'ORDER BY todo_subtasks.sort_position ASC, todo_subtasks.id ASC',
      [listId],
    );
    return rows.map(TodoSubtaskModel.fromMap).toList();
  }

  Future<List<TodoSubtaskModel>> _getSubtasks(
    String parentColumn,
    int todoId,
  ) async {
    final database = await _db;
    final rows = await database.query(
      'todo_subtasks',
      where: '$parentColumn = ?',
      whereArgs: [todoId],
      orderBy: 'sort_position ASC, id ASC',
    );
    return rows.map(TodoSubtaskModel.fromMap).toList();
  }

  Future<void> replaceScheduledSubtasks(
    int todoId,
    List<TodoSubtaskDraft> subtasks,
  ) => _replaceSubtasks('scheduled_todo_id', todoId, subtasks);

  Future<void> replaceRegularSubtasks(
    int todoId,
    List<TodoSubtaskDraft> subtasks,
  ) => _replaceSubtasks('regular_todo_id', todoId, subtasks);

  Future<void> setSubtaskCompleted(int id, bool isCompleted) async {
    final database = await _db;
    await database.update(
      'todo_subtasks',
      {'is_completed': isCompleted ? 1 : 0, 'updated_at': _now},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> _replaceSubtasks(
    String parentColumn,
    int todoId,
    List<TodoSubtaskDraft> subtasks,
  ) async {
    final database = await _db;
    await database.transaction((transaction) async {
      await transaction.delete(
        'todo_subtasks',
        where: '$parentColumn = ?',
        whereArgs: [todoId],
      );
      for (var index = 0; index < subtasks.length; index++) {
        final subtask = subtasks[index];
        await transaction.insert('todo_subtasks', {
          parentColumn: todoId,
          'content': subtask.content.trim(),
          'is_completed': subtask.isCompleted ? 1 : 0,
          'sort_position': (index + 1) * 1000,
          'created_at': _now,
          'updated_at': _now,
        });
      }
    });
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

  String? _normalizedDescription(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}
