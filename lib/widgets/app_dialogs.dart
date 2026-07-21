import 'package:better_todo/data/models/todo_models.dart';
import 'package:flutter/material.dart';

typedef NewListValue = ({String name, bool isLocked});
typedef ScheduledTodoValue = ({
  String content,
  String? description,
  DateTime day,
  int? minute,
  List<TodoSubtaskDraft> subtasks,
});
typedef RegularTodoValue = ({
  String content,
  String? description,
  int? sectionId,
  List<TodoSubtaskDraft> subtasks,
});

const _todoTitleMaxLength = 20;

Future<String?> showTextDialog(
  BuildContext context, {
  required String title,
  String initialValue = '',
  String label = 'Name',
}) {
  var text = initialValue;
  return showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: TextFormField(
        initialValue: initialValue,
        autofocus: true,
        decoration: InputDecoration(labelText: label),
        onChanged: (value) => text = value,
        onFieldSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            Navigator.pop(dialogContext, value.trim());
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (text.trim().isNotEmpty) {
              Navigator.pop(dialogContext, text.trim());
            }
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Delete',
}) async {
  return await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(confirmLabel),
            ),
          ],
        ),
      ) ??
      false;
}

Future<NewListValue?> showNewListDialog(BuildContext context) {
  var name = '';
  var isLocked = false;
  return showDialog<NewListValue>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('New list'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                autofocus: true,
                decoration: const InputDecoration(labelText: 'List name'),
                onChanged: (value) => name = value,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Password locked'),
                value: isLocked,
                onChanged: (value) => setState(() => isLocked = value),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (name.trim().isEmpty) return;
              Navigator.pop(dialogContext, (
                name: name.trim(),
                isLocked: isLocked,
              ));
            },
            child: const Text('Create'),
          ),
        ],
      ),
    ),
  );
}

Future<String?> showPasswordDialog(
  BuildContext context, {
  required String title,
  String label = 'Password',
  bool allowEmpty = false,
}) {
  var password = '';
  return showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: TextFormField(
        autofocus: true,
        obscureText: true,
        decoration: InputDecoration(labelText: label),
        onChanged: (value) => password = value,
        onFieldSubmitted: (value) {
          if (allowEmpty || value.isNotEmpty) {
            Navigator.pop(dialogContext, value);
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (allowEmpty || password.isNotEmpty) {
              Navigator.pop(dialogContext, password);
            }
          },
          child: const Text('Confirm'),
        ),
      ],
    ),
  );
}

Future<ScheduledTodoValue?> showScheduledTodoDialog(
  BuildContext context, {
  ScheduledTodoModel? todo,
  DateTime? initialDay,
  List<TodoSubtaskDraft> initialSubtasks = const [],
}) {
  var content = todo?.content ?? '';
  var description = todo?.description ?? '';
  final subtasks = [...initialSubtasks];
  final subtaskEndKey = GlobalKey();
  var day = todo?.scheduledDay ?? initialDay ?? DateTime.now();
  TimeOfDay? time = todo?.scheduledMinute == null
      ? null
      : TimeOfDay(
          hour: todo!.scheduledMinute! ~/ 60,
          minute: todo.scheduledMinute! % 60,
        );

  return showDialog<ScheduledTodoValue>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(todo == null ? 'New scheduled task' : 'Edit task'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: content,
                autofocus: todo == null,
                maxLength: _todoTitleMaxLength,
                maxLines: 1,
                decoration: const InputDecoration(labelText: 'Title'),
                onChanged: (value) => content = value,
              ),
              TextFormField(
                initialValue: description,
                maxLines: 4,
                minLines: 1,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                ),
                onChanged: (value) => description = value,
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined),
                title: Text(_displayDate(day)),
                onTap: () async {
                  final selected = await showDatePicker(
                    context: context,
                    initialDate: day,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (selected != null) setState(() => day = selected);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.schedule_outlined),
                title: Text(time?.format(context) ?? 'No specific time'),
                trailing: time == null
                    ? null
                    : IconButton(
                        onPressed: () => setState(() => time = null),
                        icon: const Icon(Icons.close),
                      ),
                onTap: () async {
                  final selected = await showTimePicker(
                    context: context,
                    initialTime: time ?? TimeOfDay.now(),
                  );
                  if (selected != null) setState(() => time = selected);
                },
              ),
              if (todo != null)
                _SubtaskEditor(
                  subtasks: subtasks,
                  setState: setState,
                  endKey: subtaskEndKey,
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (content.trim().isEmpty) return;
              Navigator.pop(dialogContext, (
                content: content.trim(),
                description: description.trim().isEmpty
                    ? null
                    : description.trim(),
                day: day,
                minute: time == null ? null : time!.hour * 60 + time!.minute,
                subtasks: [...subtasks],
              ));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
}

Future<RegularTodoValue?> showRegularTodoDialog(
  BuildContext context, {
  required List<ListSectionModel> sections,
  RegularTodoModel? todo,
  int? initialSectionId,
  Future<void> Function()? onDelete,
  List<TodoSubtaskDraft> initialSubtasks = const [],
}) {
  var content = todo?.content ?? '';
  var description = todo?.description ?? '';
  var sectionId = todo?.sectionId ?? initialSectionId;
  final subtasks = [...initialSubtasks];
  final subtaskEndKey = GlobalKey();
  return showDialog<RegularTodoValue>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(todo == null ? 'New todo' : 'Edit todo'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: content,
                autofocus: todo == null,
                maxLength: _todoTitleMaxLength,
                maxLines: 1,
                decoration: const InputDecoration(labelText: 'Title'),
                onChanged: (value) => content = value,
              ),
              TextFormField(
                initialValue: description,
                maxLines: 4,
                minLines: 1,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                ),
                onChanged: (value) => description = value,
              ),
              if (sections.isNotEmpty) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<int?>(
                  initialValue: sectionId,
                  decoration: const InputDecoration(labelText: 'Section'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('No section'),
                    ),
                    ...sections.map(
                      (section) => DropdownMenuItem(
                        value: section.id,
                        child: Text(section.name),
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() => sectionId = value),
                ),
              ],
              if (todo != null)
                _SubtaskEditor(
                  subtasks: subtasks,
                  setState: setState,
                  endKey: subtaskEndKey,
                ),
            ],
          ),
        ),
        actions: [
          if (todo != null && onDelete != null)
            TextButton(
              onPressed: () async {
                final confirmed = await showConfirmDialog(
                  dialogContext,
                  title: 'Delete information?',
                  message: 'This will permanently delete "${todo.content}".',
                );
                if (!confirmed || !dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                await onDelete();
              },
              child: const Text('Delete'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (content.trim().isEmpty) return;
              Navigator.pop(dialogContext, (
                content: content.trim(),
                description: description.trim().isEmpty
                    ? null
                    : description.trim(),
                sectionId: sectionId,
                subtasks: [...subtasks],
              ));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
}

final class _SubtaskEditor extends StatelessWidget {
  const _SubtaskEditor({
    required this.subtasks,
    required this.setState,
    required this.endKey,
  });

  final List<TodoSubtaskDraft> subtasks;
  final StateSetter setState;
  final GlobalKey endKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Subtasks',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            TextButton.icon(
              onPressed: () => _add(context),
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            ),
          ],
        ),
        for (final entry in subtasks.indexed)
          Row(
            key: ValueKey(entry.$1),
            children: [
              Checkbox(
                value: entry.$2.isCompleted,
                onChanged: (value) => setState(() {
                  subtasks[entry.$1] = TodoSubtaskDraft(
                    content: entry.$2.content,
                    isCompleted: value ?? false,
                  );
                }),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => _edit(context, entry.$1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      entry.$2.content,
                      style: TextStyle(
                        decoration: entry.$2.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Remove subtask',
                onPressed: () => setState(() => subtasks.removeAt(entry.$1)),
                icon: const Icon(Icons.close, size: 18),
              ),
            ],
          ),
        SizedBox(key: endKey, height: 1),
      ],
    );
  }

  Future<void> _add(BuildContext context) async {
    final content = await showTextDialog(
      context,
      title: 'New subtask',
      label: 'Subtask',
    );
    if (content == null) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(
      () =>
          subtasks.add(TodoSubtaskDraft(content: content, isCompleted: false)),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = endKey.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          alignment: 1,
        );
      }
    });
  }

  Future<void> _edit(BuildContext context, int index) async {
    final subtask = subtasks[index];
    final content = await showTextDialog(
      context,
      title: 'Edit subtask',
      label: 'Subtask',
      initialValue: subtask.content,
    );
    if (content == null) return;
    setState(() {
      subtasks[index] = TodoSubtaskDraft(
        content: content,
        isCompleted: subtask.isCompleted,
      );
    });
  }
}

String _displayDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}
