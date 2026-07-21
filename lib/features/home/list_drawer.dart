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
    final pinnedLists = controller.lists
        .where((list) => list.isPinned)
        .toList();
    final otherLists = controller.lists
        .where((list) => !list.isPinned)
        .toList();

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
                  : Column(
                      children: [
                        for (final list in pinnedLists)
                          _ListEntry(
                            key: ValueKey(list.id),
                            list: list,
                            selected: list.id == controller.selectedListId,
                            controller: controller,
                          ),
                        if (pinnedLists.isNotEmpty && otherLists.isNotEmpty)
                          const Divider(height: 1, indent: 16, endIndent: 16),
                        Expanded(
                          child: ReorderableListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: otherLists.length,
                            onReorderItem: (oldIndex, newIndex) {
                              controller.reorderLists(
                                oldIndex + pinnedLists.length,
                                newIndex + pinnedLists.length,
                              );
                            },
                            itemBuilder: (context, index) {
                              final list = otherLists[index];
                              return _ListEntry(
                                key: ValueKey(list.id),
                                list: list,
                                selected: list.id == controller.selectedListId,
                                controller: controller,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('New list'),
              onTap: () => _createList(context),
            ),
            ListTile(
              leading: const Icon(Icons.group_outlined),
              title: const Text('Manage people'),
              onTap: () => _managePeople(context),
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
            if (controller.password != null &&
                controller.lists.any((list) => list.isLocked))
              ListTile(
                leading: Icon(
                  controller.isUnlocked
                      ? Icons.lock_outline
                      : Icons.lock_open_outlined,
                ),
                title: Text(controller.isUnlocked ? 'Relock all' : 'Unlock'),
                onTap: () => _toggleLockSession(context),
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
    await controller.createList(name: value.name, isLocked: value.isLocked);
    if (context.mounted) Navigator.pop(context);
  }

  Future<void> _managePeople(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) => _ManagePeopleDialog(controller: controller),
    );
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

  Future<void> _toggleLockSession(BuildContext context) async {
    if (controller.isUnlocked) {
      controller.lockAll();
      return;
    }

    final value = await showPasswordDialog(
      context,
      title: 'Unlock protected lists',
    );
    if (value == null || !context.mounted) return;
    if (!controller.unlockAll(value)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Incorrect password')));
      return;
    }
  }
}

final class _ManagePeopleDialog extends StatefulWidget {
  const _ManagePeopleDialog({required this.controller});

  final AppController controller;

  @override
  State<_ManagePeopleDialog> createState() => _ManagePeopleDialogState();
}

final class _ManagePeopleDialogState extends State<_ManagePeopleDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Manage people'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.controller.persons.length,
          itemBuilder: (context, index) {
            final person = widget.controller.persons[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                person.isOwner ? Icons.person : Icons.person_outline,
              ),
              title: Text(person.name),
              subtitle: person.isOwner ? const Text('App user') : null,
              trailing: person.isOwner
                  ? null
                  : IconButton(
                      tooltip: 'Delete ${person.name}',
                      onPressed: () => _delete(person),
                      icon: const Icon(Icons.delete_outline),
                    ),
            );
          },
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: _add,
          icon: const Icon(Icons.add),
          label: const Text('Add person'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Future<void> _add() async {
    final name = await showTextDialog(
      context,
      title: 'Add person',
      label: 'Name',
    );
    if (name == null || !mounted) return;
    await widget.controller.createPerson(name);
    if (mounted) setState(() {});
  }

  Future<void> _delete(PersonModel person) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete ${person.name}?',
      message: 'Their tasks will be reassigned to Me.',
    );
    if (!confirmed || !mounted) return;
    await widget.controller.deletePerson(person);
    if (mounted) setState(() {});
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
      leading: list.isLocked
          ? Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.lock_outline,
                  color: list.isPinned ? AppColors.yellow : null,
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: controller.isUnlocked
                          ? AppColors.unlocked
                          : AppColors.locked,
                    ),
                  ),
                ),
              ],
            )
          : Icon(
              list.isScheduled
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
          PopupMenuItem(
            value: 'rename',
            enabled: !list.isLocked || controller.isUnlocked,
            child: const Text('Rename'),
          ),
          PopupMenuItem(
            value: 'pin',
            child: Text(list.isPinned ? 'Unpin' : 'Pin'),
          ),
          PopupMenuItem(
            value: 'lock',
            enabled: !list.isLocked || controller.isUnlocked,
            child: Text(list.isLocked ? 'Remove lock' : 'Lock'),
          ),
          if (!list.isScheduled)
            PopupMenuItem(
              value: 'delete',
              enabled: !list.isLocked || controller.isUnlocked,
              child: const Text('Delete'),
            ),
        ],
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    await controller.selectList(list);
    if (context.mounted) Navigator.pop(context);
  }

  Future<void> _handleAction(BuildContext context, String action) async {
    switch (action) {
      case 'rename':
        if (list.isLocked && !controller.isUnlocked) return;
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
        if (list.isScheduled || (list.isLocked && !controller.isUnlocked)) {
          return;
        }
        final confirmed = await showConfirmDialog(
          context,
          title: 'Delete ${list.name}?',
          message: 'All sections and todos in this list will be deleted.',
        );
        if (confirmed) await controller.deleteList(list);
    }
  }
}
