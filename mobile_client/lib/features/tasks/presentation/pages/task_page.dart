import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_client/core/di/injection.dart';
import 'package:mobile_client/core/rust/api/tasks.dart';
import 'package:mobile_client/core/rust/dto/task.dart';
import 'package:mobile_client/shared/widgets/tag_picker_sheet.dart';
import 'package:mobile_client/features/tasks/presentation/controllers/task_editor_controller.dart';
import 'package:mobile_client/features/tasks/presentation/widgets/schedule_editor.dart';
import 'package:mobile_client/features/tasks/presentation/widgets/task_labels.dart';
import 'package:mobile_client/l10n/app_localizations.dart';
import 'package:mobile_client/shared/dialogs/dialogs.dart';
import 'package:mobile_client/shared/widgets/directional_text_field.dart';
import 'package:mobile_client/shared/widgets/search_filters.dart';
import 'package:mobile_client/shared/widgets/tag_chips_row.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key, this.taskId});

  final int? taskId;

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  late final TaskEditorController _c;
  late final SearchFilters _filters;

  @override
  void initState() {
    super.initState();
    _filters = getIt<SearchFilters>();
    _c = TaskEditorController(taskId: widget.taskId, api: getIt<TasksApi>());
    _c.onError = _showMessage;
    _filters.loadTags();
    _c.load();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // -------------------------------------------------------------- actions
  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (_c.titleCtl.text.trim().isEmpty) {
      _showMessage(l10n.tasks_title_required);
      return;
    }
    if (await _c.save() && mounted) context.pop();
  }

  Future<void> _confirmLeave() async {
    final l10n = AppLocalizations.of(context)!;
    final discard = await showConfirmDialog(
      context,
      title: l10n.tasks_discard_title,
      message: l10n.tasks_discard_body,
      confirmLabel: l10n.tasks_discard,
      destructive: true,
    );
    if (discard && mounted) context.pop();
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showConfirmDialog(
      context,
      title: l10n.tasks_delete_title(1),
      message: l10n.tasks_delete_body(1),
      confirmLabel: l10n.notes_delete,
      destructive: true,
    );
    if (!ok || !mounted) return;
    if (await _c.delete() && mounted) context.pop();
  }

  Future<void> _pickDue() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _c.dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _c.setDueDate(DateTime(picked.year, picked.month, picked.day));
    }
  }

  Future<void> _editTags() async {
    final l10n = AppLocalizations.of(context)!;
    final ids = await showTagPickerSheet(
      context,
      listenable: _filters,
      tags: () => _filters.tags,
      onCreate: _filters.createTag,
      initial: _c.tagIds,
      title: l10n.notes_tags,
      allowEmpty: true,
    );
    if (ids != null) _c.setTagIds(ids);
  }

  // ---------------------------------------------------------------- build
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListenableBuilder(
      listenable: Listenable.merge([_c, _filters]),
      builder: (context, _) {
        final ready = !_c.loading && !_c.failed;
        return PopScope(
          canPop: !_c.dirty,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _confirmLeave();
          },
          child: Scaffold(
          appBar: AppBar(
            title: Text(_c.isNew ? l10n.tasks_new : l10n.tasks_edit),
            actions: [
              if (ready && !_c.isNew)
                IconButton(
                  tooltip: l10n.notes_delete,
                  onPressed: _delete,
                  icon: const Icon(Icons.delete_outline),
                ),
              if (ready)
                IconButton(
                  tooltip: l10n.notes_save,
                  onPressed: _save,
                  icon: const Icon(Icons.check),
                ),
            ],
          ),
          body: _c.loading
              ? const Center(child: CircularProgressIndicator())
              : _c.failed
              ? Center(child: Text(l10n.tasks_load_failed))
              : _buildForm(l10n),
          ),
        );
      },
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 8),
    child: Text(text, style: Theme.of(context).textTheme.titleSmall),
  );

  Widget _buildForm(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final oneTime = _c.type == TaskTypeDto.oneTime;
    final tags = _filters.tags.where((t) => _c.tagIds.contains(t.id)).toList();

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        DirectionalTextField(
          controller: _c.titleCtl,
          style: theme.textTheme.titleLarge,
          decoration: InputDecoration(hintText: l10n.tasks_title_hint),
        ),
        const SizedBox(height: 12),
        DirectionalTextField(
          controller: _c.descriptionCtl,
          minLines: 2,
          maxLines: 6,
          decoration: InputDecoration(hintText: l10n.tasks_description_hint),
        ),

        _label(l10n.tasks_type),
        SegmentedButton<TaskTypeDto>(
          segments: [
            ButtonSegment(
              value: TaskTypeDto.oneTime,
              icon: const Icon(Icons.task_alt),
              label: Text(l10n.tasks_type_one_time),
            ),
            ButtonSegment(
              value: TaskTypeDto.periodic,
              icon: const Icon(Icons.repeat),
              label: Text(l10n.tasks_type_periodic),
            ),
          ],
          selected: {_c.type},
          onSelectionChanged: (s) => _c.setType(s.first),
        ),

        _label(l10n.tasks_priority),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            ChoiceChip(
              label: Text(l10n.tasks_priority_none),
              selected: _c.priority == null,
              onSelected: (_) => _c.setPriority(null),
            ),
            for (final p in PriorityDto.values)
              ChoiceChip(
                label: Text(priorityLabel(l10n, p)),
                selected: _c.priority == p,
                onSelected: (_) => _c.setPriority(p),
              ),
          ],
        ),

        if (oneTime) ...[
          _label(l10n.tasks_due_date),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _pickDue,
                icon: const Icon(Icons.event, size: 18),
                label: Text(
                  _c.dueDate == null
                      ? l10n.tasks_no_due_date
                      : MaterialLocalizations.of(
                          context,
                        ).formatMediumDate(_c.dueDate!),
                ),
              ),
              if (_c.dueDate != null)
                IconButton(
                  tooltip: l10n.notes_clear_filters,
                  onPressed: () => _c.setDueDate(null),
                  icon: const Icon(Icons.close),
                ),
            ],
          ),
        ] else ...[
          _label(l10n.tasks_schedule),
          ScheduleEditor(value: _c.schedule, onChanged: _c.setSchedule),
        ],

        _label(l10n.tasks_checklist),
        for (var i = 0; i < _c.checklist.length; i++)
          Padding(
            key: ObjectKey(_c.checklist[i]),
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Checkbox(
                  value: _c.checklist[i].checked,
                  onChanged: (v) => _c.setSubTaskChecked(i, v ?? false),
                ),
                Expanded(
                  child: DirectionalTextField(
                    controller: _c.checklist[i].ctl,
                    decoration: InputDecoration(
                      hintText: l10n.checklists_new_item_hint,
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _c.removeSubTask(i),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: _c.addSubTask,
            icon: const Icon(Icons.add),
            label: Text(l10n.tasks_checklist_add),
          ),
        ),

        _label(l10n.notes_tags),
        TagChipsRow(
          tags: tags,
          onEdit: _editTags,
          onRemove: (id) => _c.setTagIds({..._c.tagIds}..remove(id)),
        ),
      ],
    );
  }
}
