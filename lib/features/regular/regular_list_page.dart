import 'package:better_todo/app/app_controller.dart';
import 'package:better_todo/data/models/todo_models.dart';
import 'package:better_todo/theme/app_colors.dart';
import 'package:better_todo/widgets/app_dialogs.dart';
import 'package:flutter/material.dart';

final class RegularListPage extends StatelessWidget {
  const RegularListPage({required this.controller, super.key});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final unsectioned = controller.regularTodos
        .where((todo) => todo.sectionId == null)
        .toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      children: [
        _TodoGroup(
          title: controller.sections.isEmpty ? 'TODOS' : 'NO SECTION',
          sectionId: null,
          todos: unsectioned,
          controller: controller,
          showWhenEmpty: controller.sections.isEmpty,
        ),
        if (controller.sections.isNotEmpty)
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: controller.sections.length,
            onReorderItem: (oldIndex, newIndex) async {
              final sections = [...controller.sections];
              final section = sections.removeAt(oldIndex);
              sections.insert(newIndex, section);
              await controller.reorderSections(
                sections.map((item) => item.id).toList(),
              );
            },
            itemBuilder: (context, index) {
              final section = controller.sections[index];
              final todos = controller.regularTodos
                  .where((todo) => todo.sectionId == section.id)
                  .toList();
              return _SectionCard(
                key: ValueKey(section.id),
                section: section,
                todos: todos,
                index: index,
                controller: controller,
              );
            },
          ),
      ],
    );
  }
}

final class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.section,
    required this.todos,
    required this.index,
    required this.controller,
    super.key,
  });

  final ListSectionModel section;
  final List<RegularTodoModel> todos;
  final int index;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.surface,
      child: Column(
        children: [
          ListTile(
            title: Text(
              section.name.toUpperCase(),
              style: const TextStyle(
                color: AppColors.yellowSoft,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            leading: ReorderableDragStartListener(
              index: index,
              child: const Icon(Icons.drag_indicator),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Add todo',
                  onPressed: () => _addTodo(context),
                  icon: const Icon(Icons.add),
                ),
                PopupMenuButton<String>(
                  onSelected: (action) => _sectionAction(context, action),
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'rename', child: Text('Rename')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
          ),
          _TodoList(
            sectionId: section.id,
            todos: todos,
            controller: controller,
          ),
          if (todos.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Empty section',
                  style: TextStyle(color: AppColors.textDisabled),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _addTodo(BuildContext context) async {
    final value = await showRegularTodoDialog(
      context,
      sections: controller.sections,
      initialSectionId: section.id,
    );
    if (value != null) {
      await controller.createRegularTodo(
        content: value.content,
        sectionId: value.sectionId,
      );
    }
  }

  Future<void> _sectionAction(BuildContext context, String action) async {
    if (action == 'rename') {
      final name = await showTextDialog(
        context,
        title: 'Rename section',
        initialValue: section.name,
      );
      if (name != null) await controller.renameSection(section, name);
    }
    if (action == 'delete') {
      final confirmed = await showConfirmDialog(
        context,
        title: 'Delete ${section.name}?',
        message: 'Its todos will be moved to No section.',
      );
      if (confirmed) await controller.deleteSection(section);
    }
  }
}

final class _TodoGroup extends StatelessWidget {
  const _TodoGroup({
    required this.title,
    required this.sectionId,
    required this.todos,
    required this.controller,
    required this.showWhenEmpty,
  });

  final String title;
  final int? sectionId;
  final List<RegularTodoModel> todos;
  final AppController controller;
  final bool showWhenEmpty;

  @override
  Widget build(BuildContext context) {
    if (todos.isEmpty && !showWhenEmpty) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.surface,
      child: Column(
        children: [
          ListTile(
            title: Text(
              title,
              style: const TextStyle(
                color: AppColors.yellowSoft,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            trailing: IconButton(
              tooltip: 'Add todo',
              onPressed: () => _addTodo(context),
              icon: const Icon(Icons.add),
            ),
          ),
          _TodoList(sectionId: sectionId, todos: todos, controller: controller),
          if (todos.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Text(
                'No todos yet',
                style: TextStyle(color: AppColors.textDisabled),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _addTodo(BuildContext context) async {
    final value = await showRegularTodoDialog(
      context,
      sections: controller.sections,
      initialSectionId: sectionId,
    );
    if (value != null) {
      await controller.createRegularTodo(
        content: value.content,
        sectionId: value.sectionId,
      );
    }
  }
}

final class _TodoList extends StatelessWidget {
  const _TodoList({
    required this.sectionId,
    required this.todos,
    required this.controller,
  });

  final int? sectionId;
  final List<RegularTodoModel> todos;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: todos.length,
      onReorderItem: (oldIndex, newIndex) =>
          controller.reorderRegularTodos(sectionId, oldIndex, newIndex),
      itemBuilder: (context, index) => _RegularTodoTile(
        key: ValueKey(todos[index].id),
        todo: todos[index],
        index: index,
        controller: controller,
      ),
    );
  }
}

final class _RegularTodoTile extends StatelessWidget {
  const _RegularTodoTile({
    required this.todo,
    required this.index,
    required this.controller,
    super.key,
  });

  final RegularTodoModel todo;
  final int index;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 4, right: 8),
      leading: Checkbox(
        value: todo.isCompleted,
        onChanged: (_) => controller.toggleRegularTodo(todo),
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
      onTap: () => _edit(context),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ReorderableDragStartListener(
            index: index,
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.drag_handle),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (action) {
              if (action == 'edit') _edit(context);
              if (action == 'delete') _delete(context);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit / move')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _edit(BuildContext context) async {
    final value = await showRegularTodoDialog(
      context,
      sections: controller.sections,
      todo: todo,
    );
    if (value != null) {
      await controller.editRegularTodo(
        todo,
        content: value.content,
        sectionId: value.sectionId,
      );
    }
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete todo?',
      message: todo.content,
    );
    if (confirmed) await controller.deleteRegularTodo(todo);
  }
}
