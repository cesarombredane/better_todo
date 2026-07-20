import 'package:better_todo/data/models/todo_models.dart';
import 'package:better_todo/data/repositories/todo_repository.dart';
import 'package:flutter/foundation.dart';

enum ScheduleView { list, calendar }

final class AppController extends ChangeNotifier {
  AppController({TodoRepository? repository})
    : _repository = repository ?? TodoRepository();

  final TodoRepository _repository;

  List<TodoListModel> lists = [];
  List<ListSectionModel> sections = [];
  List<ScheduledTodoModel> scheduledTodos = [];
  List<RegularTodoModel> regularTodos = [];
  final Set<int> unlockedListIds = {};

  int? selectedListId;
  String? password;
  String? error;
  bool isLoading = true;
  ScheduleView scheduleView = ScheduleView.list;
  DateTime selectedCalendarDay = _dateOnly(DateTime.now());
  DateTime visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);

  TodoListModel? get selectedList {
    for (final list in lists) {
      if (list.id == selectedListId) return list;
    }
    return null;
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  Future<void> initialize() async {
    await _run(() async {
      password = await _repository.getPassword();
      lists = await _repository.getLists();
      if (!lists.any((list) => list.isScheduled)) {
        await _repository.createList(
          name: 'Schedule',
          isScheduled: true,
          isPinned: true,
        );
        lists = await _repository.getLists();
      }
      selectedListId =
          lists.where((list) => list.isPinned).firstOrNull?.id ??
          lists.first.id;
      await _loadSelectedContent();
    }, loading: true);
  }

  Future<void> selectList(TodoListModel list) async {
    selectedListId = list.id;
    scheduleView = ScheduleView.list;
    await refreshSelected();
  }

  Future<void> refreshSelected() async {
    await _run(_loadSelectedContent, loading: true);
  }

  Future<void> _loadSelectedContent() async {
    final list = selectedList;
    if (list == null) {
      sections = [];
      regularTodos = [];
      scheduledTodos = [];
      return;
    }
    if (list.isScheduled) {
      final now = DateTime.now();
      scheduledTodos = await _repository.getScheduledTodos(
        list.id,
        DateTime(now.year - 1),
        DateTime(now.year + 3, 12, 31),
      );
      sections = [];
      regularTodos = [];
    } else {
      sections = await _repository.getSections(list.id);
      regularTodos = await _repository.getRegularTodos(list.id);
      scheduledTodos = [];
    }
  }

  Future<void> createList({
    required String name,
    required bool isLocked,
  }) async {
    await _run(() async {
      final id = await _repository.createList(
        name: name,
        isScheduled: false,
        isLocked: isLocked,
      );
      await _reloadLists();
      selectedListId = id;
      await _loadSelectedContent();
    });
  }

  Future<void> renameList(TodoListModel list, String name) async {
    await _run(() async {
      await _repository.updateList(list, name: name);
      await _reloadLists();
    });
  }

  Future<void> setListLocked(TodoListModel list, bool locked) async {
    await _run(() async {
      await _repository.updateList(list, isLocked: locked);
      if (locked) unlockedListIds.remove(list.id);
      await _reloadLists();
    });
  }

  Future<void> deleteList(TodoListModel list) async {
    if (list.isScheduled) return;
    await _run(() async {
      await _repository.deleteList(list.id);
      unlockedListIds.remove(list.id);
      await _reloadLists();
      if (selectedListId == list.id) {
        selectedListId = lists.firstOrNull?.id;
      }
      await _loadSelectedContent();
    });
  }

  Future<void> togglePinned(TodoListModel list) async {
    await _run(() async {
      await _repository.pinList(list.isPinned ? null : list.id);
      await _reloadLists();
    });
  }

  Future<void> reorderLists(int oldIndex, int newIndex) async {
    final reordered = [...lists];
    final list = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, list);
    lists = reordered;
    notifyListeners();
    await _run(() async {
      await _repository.reorderLists(reordered.map((item) => item.id).toList());
      await _reloadLists();
    });
  }

  Future<void> _reloadLists() async {
    lists = await _repository.getLists();
  }

  bool canOpen(TodoListModel list) =>
      !list.isLocked || unlockedListIds.contains(list.id);

  bool unlock(TodoListModel list, String attempt) {
    if (password == null || password!.isEmpty || attempt == password) {
      unlockedListIds.add(list.id);
      notifyListeners();
      return true;
    }
    return false;
  }

  void lockAll() {
    unlockedListIds.clear();
    notifyListeners();
  }

  Future<void> changePassword(String? value) async {
    await _run(() async {
      final normalized = value?.trim();
      password = normalized == null || normalized.isEmpty ? null : normalized;
      await _repository.setPassword(password);
      if (password == null) unlockedListIds.clear();
    });
  }

  void setScheduleView(ScheduleView view) {
    scheduleView = view;
    notifyListeners();
  }

  void selectCalendarDay(DateTime day) {
    selectedCalendarDay = _dateOnly(day);
    notifyListeners();
  }

  void changeVisibleMonth(int delta) {
    visibleMonth = DateTime(visibleMonth.year, visibleMonth.month + delta);
    notifyListeners();
  }

  List<ScheduledTodoModel> scheduledForDay(DateTime day) => scheduledTodos
      .where((todo) => databaseDay(todo.scheduledDay) == databaseDay(day))
      .toList();

  Future<void> createScheduledTodo({
    required String content,
    required DateTime day,
    int? minute,
  }) async {
    final list = selectedList;
    if (list == null) return;
    await _run(() async {
      await _repository.createScheduledTodo(
        listId: list.id,
        content: content,
        day: day,
        minute: minute,
      );
      await _loadSelectedContent();
    });
  }

  Future<void> editScheduledTodo(
    ScheduledTodoModel todo, {
    required String content,
    required DateTime day,
    int? minute,
  }) async {
    await _run(() async {
      await _repository.updateScheduledTodo(
        todo,
        content: content,
        day: day,
        minute: minute,
        updateMinute: true,
      );
      await _loadSelectedContent();
    });
  }

  Future<void> toggleScheduledTodo(ScheduledTodoModel todo) async {
    await _run(() async {
      await _repository.updateScheduledTodo(
        todo,
        isCompleted: !todo.isCompleted,
      );
      await _loadSelectedContent();
    });
  }

  Future<void> deleteScheduledTodo(ScheduledTodoModel todo) async {
    await _run(() async {
      await _repository.deleteScheduledTodo(todo.id);
      await _loadSelectedContent();
    });
  }

  Future<void> moveScheduledTodo(ScheduledTodoModel todo, DateTime day) async {
    await _run(() async {
      await _repository.moveScheduledTodo(todo, day);
      await _loadSelectedContent();
    });
  }

  Future<void> reorderScheduledTodos(
    DateTime day,
    int oldIndex,
    int newIndex,
  ) async {
    final items = scheduledForDay(day);
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    await _run(() async {
      await _repository.reorderScheduledTodos(
        items.map((todo) => todo.id).toList(),
      );
      await _loadSelectedContent();
    });
  }

  Future<void> createSection(String name) async {
    final list = selectedList;
    if (list == null) return;
    await _run(() async {
      await _repository.createSection(list.id, name);
      await _loadSelectedContent();
    });
  }

  Future<void> renameSection(ListSectionModel section, String name) async {
    await _run(() async {
      await _repository.renameSection(section.id, name);
      await _loadSelectedContent();
    });
  }

  Future<void> deleteSection(ListSectionModel section) async {
    await _run(() async {
      await _repository.deleteSection(section.id);
      await _loadSelectedContent();
    });
  }

  Future<void> reorderSections(List<int> ids) async {
    await _run(() async {
      await _repository.reorderSections(ids);
      await _loadSelectedContent();
    });
  }

  Future<void> createRegularTodo({
    required String content,
    int? sectionId,
  }) async {
    final list = selectedList;
    if (list == null) return;
    await _run(() async {
      await _repository.createRegularTodo(
        listId: list.id,
        content: content,
        sectionId: sectionId,
      );
      await _loadSelectedContent();
    });
  }

  Future<void> editRegularTodo(
    RegularTodoModel todo, {
    required String content,
    int? sectionId,
  }) async {
    await _run(() async {
      await _repository.updateRegularTodo(
        todo,
        content: content,
        sectionId: sectionId,
        updateSection: true,
      );
      await _loadSelectedContent();
    });
  }

  Future<void> toggleRegularTodo(RegularTodoModel todo) async {
    await _run(() async {
      await _repository.updateRegularTodo(todo, isCompleted: !todo.isCompleted);
      await _loadSelectedContent();
    });
  }

  Future<void> deleteRegularTodo(RegularTodoModel todo) async {
    await _run(() async {
      await _repository.deleteRegularTodo(todo.id);
      await _loadSelectedContent();
    });
  }

  Future<void> reorderRegularTodos(
    int? sectionId,
    int oldIndex,
    int newIndex,
  ) async {
    final items = regularTodos
        .where((todo) => todo.sectionId == sectionId)
        .toList();
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    await _run(() async {
      await _repository.reorderRegularTodos(
        items.map((todo) => todo.id).toList(),
      );
      await _loadSelectedContent();
    });
  }

  Future<void> _run(
    Future<void> Function() action, {
    bool loading = false,
  }) async {
    error = null;
    if (loading) isLoading = true;
    notifyListeners();
    try {
      await action();
    } catch (exception) {
      error = exception.toString();
    } finally {
      if (loading) isLoading = false;
      notifyListeners();
    }
  }
}
