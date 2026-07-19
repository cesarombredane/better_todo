import 'package:better_todo/data/models/todo_models.dart';
import 'package:flutter/material.dart';

typedef NewListValue = ({String name, bool isScheduled, bool isLocked});
typedef ScheduledTodoValue = ({String content, DateTime day, int? minute});
typedef RegularTodoValue = ({String content, int? sectionId});

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
  var isScheduled = false;
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
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Scheduled list'),
                subtitle: const Text('Tasks use dates and calendar views'),
                value: isScheduled,
                onChanged: (value) => setState(() => isScheduled = value),
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
                isScheduled: isScheduled,
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
}) {
  var content = todo?.content ?? '';
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
                autofocus: true,
                maxLines: 3,
                minLines: 1,
                decoration: const InputDecoration(labelText: 'Task'),
                onChanged: (value) => content = value,
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
                day: day,
                minute: time == null ? null : time!.hour * 60 + time!.minute,
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
}) {
  var content = todo?.content ?? '';
  var sectionId = todo?.sectionId ?? initialSectionId;
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
                autofocus: true,
                maxLines: 3,
                minLines: 1,
                decoration: const InputDecoration(labelText: 'Todo'),
                onChanged: (value) => content = value,
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
                sectionId: sectionId,
              ));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
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
