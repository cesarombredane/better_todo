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

final class PersonModel {
  const PersonModel({
    required this.id,
    required this.name,
    required this.isOwner,
  });

  factory PersonModel.fromMap(Map<String, Object?> map) => PersonModel(
    id: map['id']! as int,
    name: map['name']! as String,
    isOwner: map['is_owner'] == 1,
  );

  final int id;
  final String name;
  final bool isOwner;
}

final class ScheduledTodoModel {
  const ScheduledTodoModel({
    required this.id,
    required this.listId,
    required this.content,
    required this.description,
    required this.assigneeId,
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
        description: map['description'] as String?,
        assigneeId: map['assignee_id'] as int?,
        scheduledDay: DateTime.parse(map['scheduled_day']! as String),
        scheduledMinute: map['scheduled_minute'] as int?,
        isCompleted: map['is_completed'] == 1,
        sortPosition: map['sort_position']! as int,
      );

  final int id;
  final int listId;
  final String content;
  final String? description;
  final int? assigneeId;
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
    required this.description,
    required this.assigneeId,
    required this.isCompleted,
    required this.sortPosition,
  });

  factory RegularTodoModel.fromMap(Map<String, Object?> map) =>
      RegularTodoModel(
        id: map['id']! as int,
        listId: map['list_id']! as int,
        sectionId: map['section_id'] as int?,
        content: map['content']! as String,
        description: map['description'] as String?,
        assigneeId: map['assignee_id'] as int?,
        isCompleted: map['is_completed'] == 1,
        sortPosition: map['sort_position']! as int,
      );

  final int id;
  final int listId;
  final int? sectionId;
  final String content;
  final String? description;
  final int? assigneeId;
  final bool isCompleted;
  final int sortPosition;
}

final class TodoSubtaskModel {
  const TodoSubtaskModel({
    required this.id,
    required this.scheduledTodoId,
    required this.regularTodoId,
    required this.content,
    required this.isCompleted,
  });

  factory TodoSubtaskModel.fromMap(Map<String, Object?> map) =>
      TodoSubtaskModel(
        id: map['id']! as int,
        scheduledTodoId: map['scheduled_todo_id'] as int?,
        regularTodoId: map['regular_todo_id'] as int?,
        content: map['content']! as String,
        isCompleted: map['is_completed'] == 1,
      );

  final int id;
  final int? scheduledTodoId;
  final int? regularTodoId;
  final String content;
  final bool isCompleted;
}

final class TodoSubtaskDraft {
  const TodoSubtaskDraft({required this.content, required this.isCompleted});

  factory TodoSubtaskDraft.fromModel(TodoSubtaskModel model) =>
      TodoSubtaskDraft(content: model.content, isCompleted: model.isCompleted);

  final String content;
  final bool isCompleted;
}

String databaseDay(DateTime date) {
  final day = DateTime(date.year, date.month, date.day);
  return '${day.year.toString().padLeft(4, '0')}-'
      '${day.month.toString().padLeft(2, '0')}-'
      '${day.day.toString().padLeft(2, '0')}';
}
