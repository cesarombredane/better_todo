import 'package:better_todo/app/app_controller.dart';
import 'package:better_todo/features/home/list_drawer.dart';
import 'package:better_todo/features/regular/regular_list_page.dart';
import 'package:better_todo/features/schedule/schedule_page.dart';
import 'package:better_todo/theme/app_colors.dart';
import 'package:better_todo/widgets/app_dialogs.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final AppController controller = AppController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller.initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      controller.lockAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final list = controller.selectedList;
        return Scaffold(
          drawer: ListDrawer(controller: controller),
          appBar: AppBar(
            title: Text(list?.name ?? 'TODO'),
            actions: [
              if (list?.isScheduled ?? false)
                IconButton(
                  tooltip: controller.scheduleView == ScheduleView.list
                      ? 'Calendar view'
                      : 'Two-week list',
                  onPressed: () => controller.setScheduleView(
                    controller.scheduleView == ScheduleView.list
                        ? ScheduleView.calendar
                        : ScheduleView.list,
                  ),
                  icon: Icon(
                    controller.scheduleView == ScheduleView.list
                        ? Icons.calendar_month_outlined
                        : Icons.view_agenda_outlined,
                  ),
                ),
              if (list != null && !list.isScheduled)
                IconButton(
                  tooltip: 'Add section',
                  onPressed: () => _addSection(context),
                  icon: const Icon(Icons.create_new_folder_outlined),
                ),
            ],
          ),
          body: _body(list),
          floatingActionButton: list == null || !controller.canOpen(list)
              ? null
              : FloatingActionButton(
                  onPressed: () => list.isScheduled
                      ? _addScheduledTodo(context)
                      : _addRegularTodo(context),
                  child: const Icon(Icons.add),
                ),
        );
      },
    );
  }

  Widget _body(dynamic list) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.error != null) {
      return _MessageView(
        icon: Icons.error_outline,
        message: controller.error!,
        actionLabel: 'Retry',
        onAction: controller.refreshSelected,
      );
    }
    if (list == null) {
      return const _MessageView(
        icon: Icons.add_task,
        message: 'Create a list from the menu to begin.',
      );
    }
    if (!controller.canOpen(list)) {
      return _MessageView(
        icon: Icons.lock_outline,
        message:
            '${list.name} is locked. Unlock protected lists from the menu.',
      );
    }
    return list.isScheduled
        ? SchedulePage(controller: controller)
        : RegularListPage(controller: controller);
  }

  Future<void> _addScheduledTodo(BuildContext context) async {
    final value = await showScheduledTodoDialog(
      context,
      persons: controller.persons,
      initialDay: controller.scheduleView == ScheduleView.calendar
          ? controller.selectedCalendarDay
          : DateTime.now(),
      initialAssigneeId: controller.defaultAssigneeId,
    );
    if (value != null) {
      await controller.createScheduledTodo(
        content: value.content,
        description: value.description,
        assigneeId: value.assigneeId,
        day: value.day,
        minute: value.minute,
      );
    }
  }

  Future<void> _addRegularTodo(BuildContext context) async {
    final value = await showRegularTodoDialog(
      context,
      sections: controller.sections,
      persons: controller.persons,
      initialAssigneeId: controller.defaultAssigneeId,
    );
    if (value != null) {
      await controller.createRegularTodo(
        content: value.content,
        description: value.description,
        assigneeId: value.assigneeId,
        sectionId: value.sectionId,
      );
    }
  }

  Future<void> _addSection(BuildContext context) async {
    final name = await showTextDialog(context, title: 'New section');
    if (name != null) await controller.createSection(name);
  }
}

final class _MessageView extends StatelessWidget {
  const _MessageView({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.textDisabled),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            if (actionLabel != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
