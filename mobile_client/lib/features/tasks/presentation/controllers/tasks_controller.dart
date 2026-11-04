import 'dart:async';

import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:mobile_client/core/rust/api/tasks.dart';
import 'package:mobile_client/core/rust/dto/query.dart';
import 'package:mobile_client/core/rust/dto/tag.dart';
import 'package:mobile_client/core/rust/dto/task.dart';
import 'package:mobile_client/features/tasks/domain/task_schedule.dart';
import 'package:mobile_client/shared/controllers/filterable_controller.dart';
import 'package:mobile_client/shared/controllers/searchable_list_controller.dart';
import 'package:mobile_client/shared/widgets/search_filters.dart';

enum TaskStatus {
  unfinished,
  finished;

  bool get forApi => this == finished;
}

enum TaskKind { all, oneTime, periodic }

class TasksController extends SearchableListController<TaskDto>
    implements FilterableListController {
  TasksController({required this._api, required SearchFilters filters})
    : super(filters) {
    filters.addListener(notifyListeners);
  }

  static const _lingerFor = Duration(milliseconds: 700);

  final TasksApi _api;

  TaskStatus _status = TaskStatus.unfinished;
  TaskKind _kind = TaskKind.all;
  PriorityDto? _priority;
  DateTime? _dueAfter;
  DateTime? _dueBefore;

  List<TaskDto> _pool = const [];
  List<UpcomingEntry> _upcoming = const [];
  int _poolToken = 0;

  final Set<int> _expanded = {};
  final Set<int> _moved = {};
  final Set<int> _lingering = {};
  final Map<int, Timer> _timers = {};

  TaskStatus get status => _status;
  TaskKind get kind => _kind;
  PriorityDto? get priority => _priority;
  DateTime? get dueAfter => _dueAfter;
  DateTime? get dueBefore => _dueBefore;
  List<UpcomingEntry> get upcoming => _upcoming;

  bool get hasTaskFilters =>
      _priority != null || _dueAfter != null || _dueBefore != null;

  @override
  bool get isFiltering => filters.isSearching || hasTaskFilters;

  @override
  FilterableListController get filterController => this;
  bool get showsUpcoming =>
      _kind == TaskKind.all &&
      _status == TaskStatus.unfinished &&
      !isFiltering &&
      _upcoming.isNotEmpty;
  List<TaskDto> get shown => items
      .where((t) => !_moved.contains(t.id) || _lingering.contains(t.id))
      .toList();

  // ------------------------------------------------------------- the view
  void setStatus(TaskStatus s) {
    if (s == _status) return;
    _status = s;
    clearSelection();
    reload();
  }

  void setKind(TaskKind k) {
    if (k == _kind) return;
    _kind = k;
    clearSelection();
    reload();
  }

  @override
  void onQueryChanged() {
    _kind = TaskKind.all;
    reload();
  }

  @override
  Future<void> refreshRemote() => _api.refresh();

  @override
  Future<void> reload({bool keepPages = false}) {
    for (final t in _timers.values) {
      t.cancel();
    }
    _timers.clear();
    _moved.clear();
    _lingering.clear();
    if (_kind == TaskKind.all &&
        _status == TaskStatus.unfinished &&
        !isFiltering) {
      _loadUpcoming();
    }
    return super.reload(keepPages: keepPages);
  }

  Future<void> _loadUpcoming() async {
    final token = ++_poolToken;
    try {
      final all = await _api.searchTasksWithParams(
        params: const TaskSearchParamsDto(),
        status: TaskStatus.unfinished.forApi,
      );
      if (token != _poolToken) return;
      _pool = all;
      _upcoming = upcomingOf(_pool, DateTime.now());
      notifyListeners();
    } catch (e) {
      if (token == _poolToken) report(e);
    }
  }

  // --------------------------------------------------------------- fetching
  TaskSearchParamsDto _params() {
    final p = filters.toParams();
    return TaskSearchParamsDto(
      text: p.text,
      tags: p.tags,
      createdAfter: p.createdAfter,
      createdBefore: p.createdBefore,
      priority: _priority,
      dueDateAfter: _dueAfter,
      dueDateBefore: _dueBefore,
    );
  }
  bool get _typedList => _kind == TaskKind.periodic && !isFiltering;

  @override
  Future<List<TaskDto>> fetchPage(ListRequestDto req) {
    if (_typedList) return _api.getTypedList(req: req, periodic: true);
    return _api.searchTasksWithParams(
      params: _params(),
      req: req,
      status: _status.forApi,
    );
  }

  @override
  List<TaskDto> filterPage(List<TaskDto> raw) {
    if (_typedList) {
      return raw.where((t) => t.done == (_status == TaskStatus.finished)).toList();
    }
    if (_kind == TaskKind.all) return raw;
    final periodic = _kind == TaskKind.periodic;
    return raw
        .where((t) => (t.taskType == TaskTypeDto.periodic) == periodic)
        .toList();
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
    _noteMoved(id);
    try {
      final done = await _api.toggleDone(id: id);
      if (done != nowDone) {
        _replace(id, (t) => _copy(t, done: done));
        _noteMoved(id);
      }
    } catch (e) {
      _replace(id, (t) => _copy(t, done: !nowDone));
      _noteMoved(id);
      report(e);
    }
  }
  void _noteMoved(int id) {
    if (!_moved.add(id)) _moved.remove(id);
    _lingering.add(id);
    _timers[id]?.cancel();
    _timers[id] = Timer(_lingerFor, () {
      _timers.remove(id);
      _lingering.remove(id);
      notifyListeners();
    });
    notifyListeners();
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
      _replace(
        taskId,
        (t) => _copy(t, options: _withSub(t, index, !nowChecked)),
      );
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

  // -------------------------------------------- filters (drawer / badge)
  void setPriority(PriorityDto? p) {
    _priority = p;
    _filtersChanged();
  }

  void setDueAfter(DateTime? d) {
    _dueAfter = d;
    _filtersChanged();
  }

  void setDueBefore(DateTime? d) {
    _dueBefore = d;
    _filtersChanged();
  }

  void _filtersChanged() {
    notifyListeners();
    onQueryChanged();
  }

  @override
  List<TagDto> get tags => filters.tags;
  @override
  Set<int> get filterTagIds => filters.filterTagIds;
  @override
  DateTime? get createdAfter => filters.createdAfter;
  @override
  DateTime? get createdBefore => filters.createdBefore;

  @override
  int get activeFilterCount =>
      filters.activeFilterCount +
      (_priority != null ? 1 : 0) +
      (_dueAfter != null ? 1 : 0) +
      (_dueBefore != null ? 1 : 0);

  @override
  void toggleFilterTag(int id) => filters.toggleFilterTag(id);
  @override
  void setCreatedAfter(DateTime? value) => filters.setCreatedAfter(value);
  @override
  void setCreatedBefore(DateTime? value) => filters.setCreatedBefore(value);
  @override
  void clearFilters() {
    _priority = null;
    _dueAfter = null;
    _dueBefore = null;
    filters.clearFilters();
  }

  @override
  Future<TagDto?> createTag(String name) => filters.createTag(name);
  @override
  Future<void> deleteTag(int id) => filters.deleteTag(id);

  // ------------------------------------------------------------------ hooks
  @override
  int idOf(TaskDto item) => item.id;
  @override
  List<TagDto> tagsOf(TaskDto item) => item.tags;

  @override
  Future<List<TaskDto>> listRemote(ListRequestDto req) =>
      _api.searchTasksWithParams(
        params: const TaskSearchParamsDto(),
        req: req,
        status: _status.forApi,
      );

  @override
  Future<List<TaskDto>> searchRemote(
    SearchParamsDto params,
    ListRequestDto req,
  ) => _api.searchTasksWithParams(
    params: _params(),
    req: req,
    status: _status.forApi,
  );

  @override
  Future<void> deleteRemote(int id) => _api.deleteTask(id: id);

  @override
  Future<void> setTagsRemote(int id, Int64List tagIds) =>
      _api.updateTags(id: id, tagIds: tagIds);

  @override
  void dispose() {
    filters.removeListener(notifyListeners);
    for (final t in _timers.values) {
      t.cancel();
    }
    super.dispose();
  }
}
