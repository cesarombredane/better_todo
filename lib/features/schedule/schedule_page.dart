import 'package:better_todo/app/app_controller.dart';
import 'package:better_todo/data/models/todo_models.dart';
import 'package:better_todo/theme/app_colors.dart';
import 'package:better_todo/widgets/app_dialogs.dart';
import 'package:flutter/material.dart';

final class SchedulePage extends StatelessWidget {
  const SchedulePage({required this.controller, super.key});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return controller.scheduleView == ScheduleView.list
        ? _TwoWeekView(controller: controller)
        : _CalendarView(controller: controller);
  }
}

final class _TwoWeekView extends StatelessWidget {
  const _TwoWeekView({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final today = _dateOnly(DateTime.now());
    final days = List.generate(14, (index) => today.add(Duration(days: index)));
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      itemCount: days.length,
      itemBuilder: (context, index) => _DaySection(
        day: days[index],
        todos: controller.scheduledForDay(days[index]),
        controller: controller,
        isToday: index == 0,
      ),
    );
  }
}

final class _DaySection extends StatelessWidget {
  const _DaySection({
    required this.day,
    required this.todos,
    required this.controller,
    required this.isToday,
  });

  final DateTime day;
  final List<ScheduledTodoModel> todos;
  final AppController controller;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    return DragTarget<ScheduledTodoModel>(
      onWillAcceptWithDetails: (details) =>
          databaseDay(details.data.scheduledDay) != databaseDay(day),
      onAcceptWithDetails: (details) =>
          controller.moveScheduledTodo(details.data, day),
      builder: (context, candidates, _) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Material(
          color: candidates.isEmpty
              ? AppColors.surface
              : AppColors.yellowMuted.withValues(alpha: 0.22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isToday ? AppColors.yellowMuted : AppColors.surfaceRaised,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        isToday ? 'TODAY · ${_dayLabel(day)}' : _dayLabel(day),
                        style: TextStyle(
                          color: isToday
                              ? AppColors.yellow
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Add task on this day',
                      onPressed: () => _createForDay(context),
                      icon: const Icon(Icons.add, size: 20),
                    ),
                  ],
                ),
              ),
              if (todos.isEmpty)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: Text(
                    'No tasks',
                    style: TextStyle(color: AppColors.textDisabled),
                  ),
                )
              else
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  buildDefaultDragHandles: false,
                  itemCount: todos.length,
                  onReorderItem: (oldIndex, newIndex) =>
                      controller.reorderScheduledTodos(day, oldIndex, newIndex),
                  itemBuilder: (context, index) => _ScheduledTodoTile(
                    key: ValueKey(todos[index].id),
                    todo: todos[index],
                    index: index,
                    controller: controller,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createForDay(BuildContext context) async {
    final value = await showScheduledTodoDialog(context, initialDay: day);
    if (value != null) {
      await controller.createScheduledTodo(
        content: value.content,
        day: value.day,
        minute: value.minute,
      );
    }
  }
}

final class _ScheduledTodoTile extends StatelessWidget {
  const _ScheduledTodoTile({
    required this.todo,
    required this.index,
    required this.controller,
    super.key,
  });

  final ScheduledTodoModel todo;
  final int index;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final tile = ListTile(
      contentPadding: const EdgeInsets.only(left: 4, right: 8),
      leading: Checkbox(
        value: todo.isCompleted,
        onChanged: (_) => controller.toggleScheduledTodo(todo),
      ),
      title: Text(
        todo.content,
        style: TextStyle(
          decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
          color: todo.isCompleted
              ? AppColors.textDisabled
              : AppColors.textPrimary,
        ),
      ),
      subtitle: todo.scheduledMinute == null
          ? null
          : Text(_timeLabel(todo.scheduledMinute!)),
      onTap: () => _edit(context),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LongPressDraggable<ScheduledTodoModel>(
            data: todo,
            feedback: Material(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 240,
                child: ListTile(title: Text(todo.content)),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.calendar_today_outlined, size: 19),
            ),
          ),
          ReorderableDragStartListener(
            index: index,
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.drag_handle, size: 20),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') _edit(context);
              if (value == 'delete') _delete(context);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
    return tile;
  }

  Future<void> _edit(BuildContext context) async {
    final value = await showScheduledTodoDialog(context, todo: todo);
    if (value != null) {
      await controller.editScheduledTodo(
        todo,
        content: value.content,
        day: value.day,
        minute: value.minute,
      );
    }
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete task?',
      message: todo.content,
    );
    if (confirmed) await controller.deleteScheduledTodo(todo);
  }
}

final class _CalendarView extends StatelessWidget {
  const _CalendarView({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final month = controller.visibleMonth;
    final first = DateTime(month.year, month.month);
    final gridStart = first.subtract(Duration(days: first.weekday - 1));
    final days = List.generate(
      42,
      (index) => gridStart.add(Duration(days: index)),
    );
    final selectedTodos = controller.scheduledForDay(
      controller.selectedCalendarDay,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => controller.changeVisibleMonth(-1),
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Text(
                _monthLabel(month),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            IconButton(
              onPressed: () => controller.changeVisibleMonth(1),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        Row(
          children: [
            for (final label in const ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
          ],
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
          ),
          itemCount: days.length,
          itemBuilder: (context, index) {
            final day = days[index];
            final count = controller.scheduledForDay(day).length;
            final selected =
                databaseDay(day) == databaseDay(controller.selectedCalendarDay);
            final currentMonth = day.month == month.month;
            return InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => controller.selectCalendarDay(day),
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: selected ? AppColors.yellow : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${day.day}',
                      style: TextStyle(
                        color: selected
                            ? AppColors.background
                            : currentMonth
                            ? AppColors.textPrimary
                            : AppColors.textDisabled,
                      ),
                    ),
                    if (count > 0)
                      Container(
                        width: 5,
                        height: 5,
                        margin: const EdgeInsets.only(top: 3),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.background
                              : AppColors.yellow,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        Text(
          _dayLabel(controller.selectedCalendarDay),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (selectedTodos.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'No tasks on this day',
              style: TextStyle(color: AppColors.textDisabled),
            ),
          )
        else
          ...selectedTodos.asMap().entries.map(
            (entry) => _ScheduledTodoTile(
              key: ValueKey(entry.value.id),
              todo: entry.value,
              index: entry.key,
              controller: controller,
            ),
          ),
      ],
    );
  }
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

String _dayLabel(DateTime date) {
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
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
  return '${weekdays[date.weekday - 1]} ${months[date.month - 1]} ${date.day}';
}

String _monthLabel(DateTime date) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${months[date.month - 1]} ${date.year}';
}

String _timeLabel(int minute) {
  final hour = minute ~/ 60;
  final minutes = minute % 60;
  return '${hour.toString().padLeft(2, '0')}:'
      '${minutes.toString().padLeft(2, '0')}';
}
