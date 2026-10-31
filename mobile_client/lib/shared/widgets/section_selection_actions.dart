import 'package:flutter/material.dart';
import 'package:mobile_client/features/notes/presentation/dialogs/tag_picker_sheet.dart';
import 'package:mobile_client/l10n/app_localizations.dart';
import 'package:mobile_client/shared/dialogs.dart';
import 'package:mobile_client/shared/section_list_controller.dart';

/// The actions of the selection bar for any section list: rename (only when
/// exactly one is selected), add tag, delete.
List<Widget> buildSectionSelectionActions<T>(
  BuildContext context, {
  required SectionListController<T> controller,
  required String renameTitle,
  required String nameHint,
  required String Function(int count) deleteTitle,
  required String Function(int count) deleteBody,
}) {
  final l10n = AppLocalizations.of(context)!;
  final cs = Theme.of(context).colorScheme;
  final c = controller;

  Future<void> rename() async {
    final current = c.items.firstWhere((s) => c.idOf(s) == c.selectedIds.first);
    final currentTitle = c.titleOf(current);
    final name = await showTextInputDialog(
      context,
      title: renameTitle,
      hint: nameHint,
      confirmLabel: l10n.notes_save,
      initial: currentTitle,
    );
    if (name != null && name != currentTitle) await c.renameSelected(name);
  }

  Future<void> addTags() async {
    final ids = await showTagPickerSheet(
      context,
      listenable: c.filters,
      tags: () => c.filters.tags,
      onCreate: c.filters.createTag,
    );
    if (ids != null) await c.addTagsToSelected(ids);
  }

  Future<void> delete() async {
    final count = c.selectedIds.length;
    final ok = await showConfirmDialog(
      context,
      title: deleteTitle(count),
      message: deleteBody(count),
      confirmLabel: l10n.notes_delete,
      destructive: true,
    );
    if (ok) await c.deleteSelected();
  }

  return [
    if (c.selectedIds.length == 1)
      IconButton(
        tooltip: renameTitle,
        onPressed: rename,
        icon: const Icon(Icons.edit_outlined),
      ),
    IconButton(
      tooltip: l10n.notes_add_tag,
      onPressed: addTags,
      icon: const Icon(Icons.label_outline),
    ),
    IconButton(
      tooltip: l10n.notes_delete,
      onPressed: delete,
      icon: Icon(Icons.delete_outline, color: cs.error),
    ),
  ];
}
