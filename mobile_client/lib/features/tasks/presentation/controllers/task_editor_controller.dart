import 'package:flutter/material.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:mobile_client/core/rust/api/tasks.dart';
import 'package:mobile_client/core/rust/dto/task.dart';
import 'package:mobile_client/features/tasks/domain/task_schedule.dart';
import 'package:mobile_client/shared/utils/api_guard.dart';

class SubTaskDraft {
  SubTaskDraft(String text, {this.checked = false})
    : ctl = TextEditingController(text: text);

  final TextEditingController ctl;
  bool checked;
}

class TaskEditorController extends ChangeNotifier with ApiGuard {
  TaskEditorController({required this.taskId, required TasksApi api})
    : _api = api,
      _loading = taskId != null {
    titleCtl.addListener(notifyListeners);
    descriptionCtl.addListener(notifyListeners);
    if (taskId == null) _baseline = _signature();
  }

  final int? taskId;
  final TasksApi _api;

  final titleCtl = TextEditingController();
  final descriptionCtl = TextEditingController();
  final List<SubTaskDraft> checklist = [];

  bool _loading;
  bool _failed = false;
  bool _disposed = false;
  TaskTypeDto _type = TaskTypeDto.oneTime;
  PriorityDto? _priority;
  DateTime? _dueDate;
  ScheduleDto _schedule = const ScheduleDto.daily(hour: 9);
  Set<int> _tagIds = {};

  String? _baseline;

  bool get isNew => taskId == null;
  bool get loading => _loading;
  bool get failed => _failed;
  TaskTypeDto get type => _type;
  PriorityDto? get priority => _priority;
  DateTime? get dueDate => _dueDate;
  ScheduleDto get schedule => _schedule;
  Set<int> get tagIds => _tagIds;

  bool get dirty => _baseline != null && _signature() != _baseline;

  String _signature() => [
    titleCtl.text.trim(),
    descriptionCtl.text.trim(),
    _type,
    _priority,
    _dueDate,
    _schedule,
    checklist.map((d) => '${d.ctl.text.trim()}:${d.checked}').join('\u0001'),
    (_tagIds.toList()..sort()).join(','),
  ].join('\u0000');

  Future<void> load() async {
    final id = taskId;
    if (id == null) return;
    try {
      final t = await _api.getTask(id: id);
      titleCtl.text = t.title;
      descriptionCtl.text = t.description;
      _type = t.taskType;
      _priority = t.options.priority;
      _dueDate = parseDue(t.options.dueDate);
      _schedule = t.options.schedule ?? _schedule;
      for (final s in t.options.checkList ?? const <SubTaskDto>[]) {
        _addDraft(SubTaskDraft(s.text, checked: s.checked));
      }
      _tagIds = t.tags.map((e) => e.id).toSet();
      _baseline = _signature();
    } catch (e) {
      _failed = true;
      report(e);
    }
    _loading = false;
    notifyListeners();
  }

  // ---------------------------------------------------------------- edits
  void setType(TaskTypeDto v) {
    _type = v;
    notifyListeners();
  }

  void setPriority(PriorityDto? v) {
    _priority = v;
    notifyListeners();
  }

  void setDueDate(DateTime? v) {
    _dueDate = v;
    notifyListeners();
  }

  void setSchedule(ScheduleDto v) {
    _schedule = v;
    notifyListeners();
  }

  void setTagIds(Set<int> ids) {
    _tagIds = ids;
    notifyListeners();
  }

  void _addDraft(SubTaskDraft d) {
    d.ctl.addListener(notifyListeners);
    checklist.add(d);
  }

  void addSubTask() {
    _addDraft(SubTaskDraft(''));
    notifyListeners();
  }

  void removeSubTask(int index) {
    checklist.removeAt(index).ctl.dispose();
    notifyListeners();
  }

  void setSubTaskChecked(int index, bool checked) {
    checklist[index].checked = checked;
    notifyListeners();
  }

  // ----------------------------------------------------------------- save
  TaskOptionsDto _options() {
    final subs = [
      for (final d in checklist)
        if (d.ctl.text.trim().isNotEmpty)
          SubTaskDto(text: d.ctl.text.trim(), checked: d.checked),
    ];
    final oneTime = _type == TaskTypeDto.oneTime;
    return TaskOptionsDto(
      priority: _priority,
      dueDate: oneTime && _dueDate != null ? formatDue(_dueDate!) : null,
      schedule: oneTime ? null : _schedule,
      checkList: subs.isEmpty ? null : subs,
    );
  }

  Future<bool> save() async {
    final title = titleCtl.text.trim();
    final description = descriptionCtl.text.trim();
    final options = _options();
    final tags = Int64List.fromList(_tagIds.toList());
    final id = taskId;

    final ok = await guard(() async {
      if (id == null) {
        await _api.createTask(
          title: title,
          description: description,
          taskType: _type,
          options: options,
          tagIds: tags,
        );
      } else {
        await _api.updateTaskDetails(
          id: id,
          title: title,
          description: description,
          taskType: _type,
        );
        await _api.updateOptions(id: id, options: options);
        await _api.updateTags(id: id, tagIds: tags);
      }
    });
    if (ok) _baseline = _signature();
    return ok;
  }

  Future<bool> delete() {
    final id = taskId;
    if (id == null) return Future.value(false);
    return guard(() => _api.deleteTask(id: id));
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    titleCtl.dispose();
    descriptionCtl.dispose();
    for (final d in checklist) {
      d.ctl.dispose();
    }
    super.dispose();
  }
}
