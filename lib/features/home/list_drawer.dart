import 'package:better_todo/app/app_controller.dart';
import 'package:better_todo/data/models/todo_models.dart';
import 'package:better_todo/theme/app_colors.dart';
import 'package:better_todo/widgets/app_dialogs.dart';
import 'package:flutter/material.dart';

final class ListDrawer extends StatelessWidget {
  const ListDrawer({required this.controller, super.key});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            const ListTile(
              title: Text(
                'TODO',
                style: TextStyle(
                  color: AppColors.yellow,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const Divider(),
            Expanded(
              child: controller.lists.isEmpty
                  ? const Center(child: Text('No lists yet'))
                  : ReorderableListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: controller.lists.length,
                      onReorderItem: controller.reorderLists,
                      itemBuilder: (context, index) {
                        final list = controller.lists[index];
                        return _ListEntry(
                          key: ValueKey(list.id),
                          list: list,
                          selected: list.id == controller.selectedListId,
                          controller: controller,
                        );
                      },
                    ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('New list'),
              onTap: () => _createList(context),
            ),
            ListTile(
              leading: const Icon(Icons.password_outlined),
              title: Text(
                controller.password == null
                    ? 'Set password'
                    : 'Change password',
              ),
              onTap: () => _managePassword(context),
            ),
            if (controller.password != null)
              ListTile(
                leading: const Icon(Icons.lock_reset_outlined),
                title: const Text('Lock all lists'),
                onTap: () {
                  controller.lockAll();
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _createList(BuildContext context) async {
    final value = await showNewListDialog(context);
    if (value == null || !context.mounted) return;
    if (value.isLocked && controller.password == null) {
      final password = await showPasswordDialog(
        context,
        title: 'Set a password first',
      );
      if (password == null || !context.mounted) return;
      await controller.changePassword(password);
    }
    await controller.createList(
      name: value.name,
      isScheduled: value.isScheduled,
      isLocked: value.isLocked,
    );
    if (context.mounted) Navigator.pop(context);
  }

  Future<void> _managePassword(BuildContext context) async {
    if (controller.password == null) {
      final value = await showPasswordDialog(context, title: 'Set password');
      if (value != null) await controller.changePassword(value);
      return;
    }
    final current = await showPasswordDialog(
      context,
      title: 'Current password',
    );
    if (current == null || !context.mounted) return;
    if (current != controller.password) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Incorrect password')));
      return;
    }
    final value = await showPasswordDialog(
      context,
      title: 'New password',
      label: 'Leave empty to remove',
      allowEmpty: true,
    );
    if (value != null) await controller.changePassword(value);
  }
}

final class _ListEntry extends StatelessWidget {
  const _ListEntry({
    required this.list,
    required this.selected,
    required this.controller,
    super.key,
  });

  final TodoListModel list;
  final bool selected;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: selected,
      selectedTileColor: AppColors.surfaceRaised,
      leading: Icon(
        list.isLocked && !controller.canOpen(list)
            ? Icons.lock_outline
            : list.isScheduled
            ? Icons.calendar_month_outlined
            : Icons.checklist_outlined,
        color: list.isPinned ? AppColors.yellow : null,
      ),
      title: Text(list.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: list.isPinned ? const Text('Pinned') : null,
      onTap: () => _open(context),
      trailing: PopupMenuButton<String>(
        onSelected: (action) => _handleAction(context, action),
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'rename', child: Text('Rename')),
          PopupMenuItem(
            value: 'pin',
            child: Text(list.isPinned ? 'Unpin' : 'Pin'),
          ),
          PopupMenuItem(
            value: 'lock',
            child: Text(list.isLocked ? 'Remove lock' : 'Lock'),
          ),
          const PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    if (!controller.canOpen(list)) {
      final value = await showPasswordDialog(
        context,
        title: 'Unlock ${list.name}',
      );
      if (value == null || !context.mounted) return;
      if (!controller.unlock(list, value)) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Incorrect password')));
        return;
      }
    }
    await controller.selectList(list);
    if (context.mounted) Navigator.pop(context);
  }

  Future<void> _handleAction(BuildContext context, String action) async {
    switch (action) {
      case 'rename':
        final value = await showTextDialog(
          context,
          title: 'Rename list',
          initialValue: list.name,
        );
        if (value != null) await controller.renameList(list, value);
      case 'pin':
        await controller.togglePinned(list);
      case 'lock':
        if (!list.isLocked && controller.password == null) {
          final password = await showPasswordDialog(
            context,
            title: 'Set a password first',
          );
          if (password == null) return;
          await controller.changePassword(password);
        }
        await controller.setListLocked(list, !list.isLocked);
      case 'delete':
        final confirmed = await showConfirmDialog(
          context,
          title: 'Delete ${list.name}?',
          message: 'All sections and todos in this list will be deleted.',
        );
        if (confirmed) await controller.deleteList(list);
    }
  }
}
