final class TodoListModel {
  const TodoListModel({
    required this.id,
    required this.name,
    required this.isScheduled,
    required this.isLocked,
    required this.isPinned,
    required this.sortPosition,
  });

  factory TodoListModel.fromMap(Map<String, Object?> map) => TodoListModel(
    id: map['id']! as int,
    name: map['name']! as String,
    isScheduled: map['is_scheduled'] == 1,
    isLocked: map['is_locked'] == 1,
    isPinned: map['is_pinned'] == 1,
    sortPosition: map['sort_position']! as int,
  );

  final int id;
  final String name;
  final bool isScheduled;
  final bool isLocked;
  final bool isPinned;
  final int sortPosition;
}

final class ListSectionModel {
  const ListSectionModel({
    required this.id,
    required this.listId,
    required this.name,
    required this.sortPosition,
  });

  factory ListSectionModel.fromMap(Map<String, Object?> map) =>
      ListSectionModel(
        id: map['id']! as int,
        listId: map['list_id']! as int,
        name: map['name']! as String,
        sortPosition: map['sort_position']! as int,
      );

  final int id;
  final int listId;
  final String name;
  final int sortPosition;
}

final class ScheduledTodoModel {
  const ScheduledTodoModel({
    required this.id,
    required this.listId,
    required this.content,
    required this.scheduledDay,
    required this.scheduledMinute,
    required this.isCompleted,
    required this.sortPosition,
  });

  factory ScheduledTodoModel.fromMap(Map<String, Object?> map) =>
      ScheduledTodoModel(
        id: map['id']! as int,
        listId: map['list_id']! as int,
        content: map['content']! as String,
        scheduledDay: DateTime.parse(map['scheduled_day']! as String),
        scheduledMinute: map['scheduled_minute'] as int?,
        isCompleted: map['is_completed'] == 1,
        sortPosition: map['sort_position']! as int,
      );

  final int id;
  final int listId;
  final String content;
  final DateTime scheduledDay;
  final int? scheduledMinute;
  final bool isCompleted;
  final int sortPosition;
}

final class RegularTodoModel {
  const RegularTodoModel({
    required this.id,
    required this.listId,
    required this.sectionId,
    required this.content,
    required this.isCompleted,
    required this.sortPosition,
  });

  factory RegularTodoModel.fromMap(Map<String, Object?> map) =>
      RegularTodoModel(
        id: map['id']! as int,
        listId: map['list_id']! as int,
        sectionId: map['section_id'] as int?,
        content: map['content']! as String,
        isCompleted: map['is_completed'] == 1,
        sortPosition: map['sort_position']! as int,
      );

  final int id;
  final int listId;
  final int? sectionId;
  final String content;
  final bool isCompleted;
  final int sortPosition;
}

String databaseDay(DateTime date) {
  final day = DateTime(date.year, date.month, date.day);
  return '${day.year.toString().padLeft(4, '0')}-'
      '${day.month.toString().padLeft(2, '0')}-'
      '${day.day.toString().padLeft(2, '0')}';
}
