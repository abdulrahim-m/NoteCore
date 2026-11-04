import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:mobile_client/core/rust/api/tasks.dart';
import 'package:mobile_client/core/rust/dto/query.dart';
import 'package:mobile_client/core/rust/dto/tag.dart';
import 'package:mobile_client/core/rust/dto/task.dart';
import 'package:mobile_client/features/tasks/domain/task_schedule.dart';
import 'package:mobile_client/shared/controllers/searchable_list_controller.dart';
import 'package:mobile_client/shared/widgets/search_filters.dart';

enum TaskView {
  overview,
  simple,
  periodic,
}

class TasksController extends SearchableListController<TaskDto> {
  TasksController({required TasksApi api, required SearchFilters filters})
    : _api = api,
      super(filters);

  final TasksApi _api;

  TaskView _view = TaskView.overview;
  List<TaskDto> _pool = const [];
  List<UpcomingEntry> _upcoming = const [];
  int _poolToken = 0;
  final Set<int> _expanded = {};

  TaskView get view => _view;
  List<UpcomingEntry> get upcoming => _upcoming;

  void setView(TaskView v) {
    final next = _view == v ? TaskView.overview : v;
    if (next == _view) return;
    _view = next;
    clearSelection();
    reload();
  }

  @override
  void onQueryChanged() {
    _view = TaskView.overview;
    reload();
  }

  @override
  Future<void> reload({bool keepPages = false}) {
    if (_view == TaskView.overview && !filters.isSearching) _loadUpcoming();
    return super.reload(keepPages: keepPages);
  }

  Future<void> _loadUpcoming() async {
    final token = ++_poolToken;
    try {
      final all = await _api.getList();
      if (token != _poolToken) return;
      _pool = all;
      _upcoming = upcomingOf(_pool, DateTime.now());
      notifyListeners();
    } catch (e) {
      if (token == _poolToken) report(e);
    }
  }

  // ---------------------------------------------------------------- ticking
  TaskDto? _find(int id) =>
      items.where((t) => t.id == id).firstOrNull ??
      _pool.where((t) => t.id == id).firstOrNull;

  Future<void> toggleDone(int id) async {
    final t = _find(id);
    if (t == null) return;
    final nowDone = !t.done;
    _replace(id, (t) => _copy(t, done: nowDone));
    try {
      final done = await _api.toggleDone(id: id);
      if (done != nowDone) _replace(id, (t) => _copy(t, done: done));
    } catch (e) {
      _replace(id, (t) => _copy(t, done: !nowDone)); // revert
      report(e);
    }
  }

  bool isExpanded(int id) => _expanded.contains(id);

  void toggleExpanded(int id) {
    if (!_expanded.add(id)) _expanded.remove(id);
    notifyListeners();
  }

  Future<void> toggleSubTask(int taskId, int index) async {
    final list = _find(taskId)?.options.checkList;
    if (list == null || index < 0 || index >= list.length) return;
    final nowChecked = !list[index].checked;
    _replace(taskId, (t) => _copy(t, options: _withSub(t, index, nowChecked)));
    try {
      await _api.updateOptions(id: taskId, options: _find(taskId)!.options);
    } catch (e) {
      _replace(taskId, (t) => _copy(t, options: _withSub(t, index, !nowChecked)));
      report(e);
    }
  }

  TaskOptionsDto _withSub(TaskDto t, int index, bool checked) {
    final o = t.options;
    final list = [...?o.checkList];
    if (index >= list.length) return o;
    list[index] = SubTaskDto(text: list[index].text, checked: checked);
    return TaskOptionsDto(
      priority: o.priority,
      dueDate: o.dueDate,
      schedule: o.schedule,
      checkList: list,
    );
  }

  void _replace(int id, TaskDto Function(TaskDto t) edit) {
    _pool = [for (final t in _pool) t.id == id ? edit(t) : t];
    _upcoming = upcomingOf(_pool, DateTime.now());
    updateWhere((t) => t.id == id, edit);
  }

  TaskDto _copy(TaskDto t, {bool? done, TaskOptionsDto? options}) => TaskDto(
    id: t.id,
    title: t.title,
    description: t.description,
    taskType: t.taskType,
    done: done ?? t.done,
    createdAt: t.createdAt,
    updatedAt: t.updatedAt,
    options: options ?? t.options,
    tags: t.tags,
  );

  // ------------------------------------------------------------------ hooks
  @override
  int idOf(TaskDto item) => item.id;
  @override
  List<TagDto> tagsOf(TaskDto item) => item.tags;

  @override
  Future<List<TaskDto>> listRemote(ListRequestDto req) =>
      _api.getList(req: req);

  @override
  Future<List<TaskDto>> searchRemote(
    SearchParamsDto params,
    ListRequestDto req,
  ) => _api.searchTasksWithParams(
    params: TaskSearchParamsDto(
      text: params.text,
      tags: params.tags,
      createdAfter: params.createdAfter,
      createdBefore: params.createdBefore,
    ),
    req: req,
  );

  @override
  Future<List<TaskDto>> fetchPage(ListRequestDto req) {
    if (filters.isSearching) return searchRemote(filters.toParams(), req);
    return switch (_view) {
      TaskView.overview => listRemote(req),
      TaskView.simple => _api.getTypedList(req: req, periodic: false),
      TaskView.periodic => _api.getTypedList(req: req, periodic: true),
    };
  }

  @override
  List<TaskDto> filterPage(List<TaskDto> raw) {
    if (_view == TaskView.overview || !filters.isSearching) return raw;
    final periodic = _view == TaskView.periodic;
    return raw
        .where((t) => (t.taskType == TaskTypeDto.periodic) == periodic)
        .toList();
  }

  @override
  Future<void> deleteRemote(int id) => _api.deleteTask(id: id);

  @override
  Future<void> setTagsRemote(int id, Int64List tagIds) =>
      _api.updateTags(id: id, tagIds: tagIds);
}
