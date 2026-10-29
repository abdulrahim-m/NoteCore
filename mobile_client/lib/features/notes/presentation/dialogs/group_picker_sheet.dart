import 'package:flutter/material.dart';
import 'package:mobile_client/core/rust/dto/note.dart';
import 'package:mobile_client/l10n/app_localizations.dart';

/// Picks a destination group. Returns `null` when dismissed, and
/// `(id: null)` when "Unassigned" was chosen.
///
/// With [markCurrent] the group [currentId] (or "Unassigned" when null) is
/// shown as the current one.
Future<({int? id})?> showGroupPickerSheet(
  BuildContext context,
  List<NoteGroupDto> groups, {
  bool markCurrent = false,
  int? currentId,
}) {
  return showModalBottomSheet<({int? id})>(
    context: context,
    showDragHandle: true,
    builder: (ctx) {
      final l10n = AppLocalizations.of(ctx)!;
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(ctx).height * 0.6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(
                  l10n.notes_select_group,
                  style: Theme.of(ctx).textTheme.titleMedium,
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.folder_off_outlined),
                      title: Text(l10n.notes_unassigned),
                      selected: markCurrent && currentId == null,
                      trailing: markCurrent && currentId == null
                          ? const Icon(Icons.check)
                          : null,
                      onTap: () => Navigator.pop(ctx, (id: null)),
                    ),
                    for (final g in groups)
                      ListTile(
                        leading: const Icon(Icons.folder_outlined),
                        title: Text(g.name),
                        selected: markCurrent && currentId == g.id,
                        trailing: markCurrent && currentId == g.id
                            ? const Icon(Icons.check)
                            : null,
                        onTap: () => Navigator.pop(ctx, (id: g.id)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
