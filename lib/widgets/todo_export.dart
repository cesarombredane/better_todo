import 'package:better_todo/data/models/todo_models.dart';
import 'package:flutter/services.dart';

String formatTodoText({
  required String title,
  required String? description,
  required Iterable<TodoSubtaskDraft> subtasks,
}) {
  final lines = <String>[
    '### $title',
    if (description case final description? when description.trim().isNotEmpty)
      description.trim(),
    for (final subtask in subtasks) '  - ${subtask.content}',
  ];
  return lines.join('\n');
}

String formatRegularGroupText({
  required String title,
  required Iterable<RegularTodoModel> todos,
  required Map<int, List<TodoSubtaskModel>> subtasks,
}) {
  return _formatGroup(
    title,
    todos.map(
      (todo) => formatTodoText(
        title: todo.content,
        description: todo.description,
        subtasks: (subtasks[todo.id] ?? const []).map(
          TodoSubtaskDraft.fromModel,
        ),
      ),
    ),
  );
}

String formatScheduledGroupText({
  required String title,
  required Iterable<ScheduledTodoModel> todos,
  required Map<int, List<TodoSubtaskModel>> subtasks,
}) {
  return _formatGroup(
    title,
    todos.map(
      (todo) => formatTodoText(
        title: formatScheduledTodoTitle(todo.content, todo.scheduledMinute),
        description: todo.description,
        subtasks: (subtasks[todo.id] ?? const []).map(
          TodoSubtaskDraft.fromModel,
        ),
      ),
    ),
  );
}

String formatScheduledTodoTitle(String title, int? minute) {
  if (minute == null) return title;
  final hour = (minute ~/ 60).toString().padLeft(2, '0');
  final minutes = (minute % 60).toString().padLeft(2, '0');
  return '$title ($hour:$minutes)';
}

String formatExportDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day-$month-${date.year}';
}

String _formatGroup(String title, Iterable<String> todos) {
  final items = todos.toList();
  return [
    '## $title',
    if (items.isNotEmpty) '',
    ...items.indexed.expand((entry) {
      return [if (entry.$1 > 0) '', entry.$2];
    }),
  ].join('\n');
}

Future<void> copyTodoText(String text) async {
  await Clipboard.setData(ClipboardData(text: text));
}
