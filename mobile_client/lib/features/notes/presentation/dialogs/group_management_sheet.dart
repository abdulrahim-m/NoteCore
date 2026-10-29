import 'package:flutter/material.dart';
import 'package:mobile_client/features/notes/presentation/controllers/notes_controller.dart';
import 'package:mobile_client/features/notes/presentation/dialogs/dialogs.dart';
import 'package:mobile_client/l10n/app_localizations.dart';

/// Create / rename / delete groups. Deleting a group that still has notes is
/// refused by the Rust core, its message is shown via the controller's
/// `onError` snackbar.
Future<void> showGroupManagementSheet(
  BuildContext context,
  NotesController controller,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _GroupManagementSheet(controller: controller),
  );
}

class _GroupManagementSheet extends StatelessWidget {
  const _GroupManagementSheet({required this.controller});
  final NotesController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        ),
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final groups = controller.groups;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 12, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.notes_manage_groups,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.add),
                        label: Text(l10n.notes_new_group),
                        onPressed: () async {
                          final name = await showTextInputDialog(
                            context,
                            title: l10n.notes_new_group,
                            hint: l10n.notes_group_name,
                            confirmLabel: l10n.notes_create,
                          );
                          if (name != null) controller.createGroup(name);
                        },
                      ),
                    ],
                  ),
                ),
                if (groups.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        l10n.notes_groups_empty,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: groups.length,
                      itemBuilder: (context, i) {
                        final g = groups[i];
                        return ListTile(
                          leading: const Icon(Icons.folder_outlined),
                          title: Text(g.name),
                          subtitle: Text(l10n.notes_count(g.listedNotes)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: l10n.notes_rename_group,
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () async {
                                  final name = await showTextInputDialog(
                                    context,
                                    title: l10n.notes_rename_group,
                                    hint: l10n.notes_group_name,
                                    confirmLabel: l10n.notes_save,
                                    initial: g.name,
                                  );
                                  if (name != null && name != g.name) {
                                    controller.renameGroup(g.id, name);
                                  }
                                },
                              ),
                              IconButton(
                                tooltip: l10n.notes_delete,
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () async {
                                  final ok = await showConfirmDialog(
                                    context,
                                    title: l10n.notes_delete_group_title,
                                    message: l10n.notes_delete_group_body(
                                      g.name,
                                    ),
                                    confirmLabel: l10n.notes_delete,
                                    destructive: true,
                                  );
                                  if (ok) controller.deleteGroup(g.id);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 8),
              ],
            );
          },
        ),
      ),
    );
  }
}
