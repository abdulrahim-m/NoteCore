import 'package:flutter/material.dart';
import 'package:mobile_client/core/di/injection.dart';
import 'package:mobile_client/core/rust/api/short_tasks.dart';
import 'package:mobile_client/core/rust/dto/short_task.dart';
import 'package:mobile_client/features/checklists/presentation/controllers/short_task_section_controller.dart';
import 'package:mobile_client/l10n/app_localizations.dart';
import 'package:mobile_client/shared/editable_item_tile.dart';
import 'package:mobile_client/shared/section_editor_view.dart';

/// One checklist: name + tags, tasks (tick, edit in place, swipe to delete)
/// and a composer. All behaviour is in [SectionEditorView].
class ChecklistSectionPage extends StatelessWidget {
  const ChecklistSectionPage({super.key, required this.sectionId});

  final int sectionId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final base = (theme.textTheme.bodyLarge ?? const TextStyle()).copyWith(
      fontSize: 16,
      height: 1.4,
    );

    return SectionEditorView<ShortTaskSectionController, ShortTaskItemDto>(
      create: () => ShortTaskSectionController(
        sectionId: sectionId,
        api: getIt<ShortTasksApi>(),
      ),
      nameHint: l10n.checklists_section_name,
      emptyMessage: l10n.checklists_section_empty,
      composerHint: l10n.checklists_new_item_hint,
      addTooltip: l10n.checklists_add,
      loadFailed: l10n.checklists_load_failed,
      deleteTitle: l10n.checklists_delete_title(1),
      deleteBody: l10n.checklists_delete_body(1),
      itemBuilder: (context, c, item) => EditableItemTile(
        itemId: item.id,
        text: item.text,
        textStyle: base.copyWith(
          color: item.done ? cs.outline : cs.onSurface,
          decoration: item.done ? TextDecoration.lineThrough : null,
        ),
        leading: Padding(
          padding: const EdgeInsetsDirectional.only(end: 8),
          child: SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: item.done,
              onChanged: (_) => c.toggle(item.id),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
        onSave: (text) => c.updateText(item.id, text),
        onDelete: () => c.deleteItem(item.id),
      ),
    );
  }
}
