import 'package:flutter/material.dart';
import 'package:mobile_client/shared/controllers/filterable_controller.dart';
import 'package:mobile_client/shared/dialogs/dialogs.dart';
import 'package:mobile_client/l10n/app_localizations.dart';

/// Left sliding panel: date filters + every tag. Works with any FilterableListController.
class TagsDrawer extends StatefulWidget {
  const TagsDrawer({super.key, required this.controller});
  final FilterableListController controller;

  @override
  State<TagsDrawer> createState() => _TagsDrawerState();
}

class _TagsDrawerState extends State<TagsDrawer> {
  final _tagField = TextEditingController();

  FilterableListController get c => widget.controller;

  @override
  void dispose() {
    _tagField.dispose();
    super.dispose();
  }

  Future<void> _addTag() async {
    final name = _tagField.text.trim();
    if (name.isEmpty) return;
    _tagField.clear();
    await c.createTag(name);
  }

  Future<void> _pickDate({required bool after}) async {
    final current = after ? c.createdAfter : c.createdBefore;
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    if (after) {
      c.setCreatedAfter(DateTime(picked.year, picked.month, picked.day));
    } else {
      c.setCreatedBefore(
        DateTime(picked.year, picked.month, picked.day, 23, 59, 59),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final loc = MaterialLocalizations.of(context);

    return Drawer(
      child: SafeArea(
        child: ListenableBuilder(
          listenable: c,
          builder: (context, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.general_filters,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontSize: 20,
                          ),
                        ),
                      ),
                      if (c.activeFilterCount > 0)
                        TextButton(
                          onPressed: c.clearFilters,
                          child: Text(l10n.notes_clear_filters),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _DateTile(
                        label: l10n.notes_created_after,
                        value: c.createdAfter == null
                            ? null
                            : loc.formatShortDate(c.createdAfter!),
                        onTap: () => _pickDate(after: true),
                        onClear: () => c.setCreatedAfter(null),
                      ),
                      const SizedBox(height: 8),
                      _DateTile(
                        label: l10n.notes_created_before,
                        value: c.createdBefore == null
                            ? null
                            : loc.formatShortDate(c.createdBefore!),
                        onTap: () => _pickDate(after: false),
                        onClear: () => c.setCreatedBefore(null),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    l10n.notes_tags,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Expanded(
                  child: c.tags.isEmpty
                      ? Center(
                          child: Text(
                            l10n.notes_tags_empty,
                            style: theme.textTheme.bodySmall,
                          ),
                        )
                      : ListView.builder(
                          itemCount: c.tags.length,
                          itemBuilder: (context, i) {
                            final tag = c.tags[i];
                            return CheckboxListTile(
                              dense: true,
                              value: c.filterTagIds.contains(tag.id),
                              onChanged: (_) => c.toggleFilterTag(tag.id),
                              controlAffinity: ListTileControlAffinity.leading,
                              title: Text(tag.name),
                              secondary: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () async {
                                  final ok = await showConfirmDialog(
                                    context,
                                    title: l10n.notes_delete_tag_title,
                                    message: l10n.notes_delete_tag_body(
                                      tag.name,
                                    ),
                                    confirmLabel: l10n.notes_delete,
                                    destructive: true,
                                  );
                                  if (ok) c.deleteTag(tag.id);
                                },
                              ),
                            );
                          },
                        ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _tagField,
                    onSubmitted: (_) => _addTag(),
                    decoration: InputDecoration(
                      hintText: l10n.notes_new_tag,
                      isDense: true,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _addTag,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.label,
    required this.value,
    required this.onTap,
    required this.onClear,
  });

  final String label;
  final String? value;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        alignment: AlignmentDirectional.centerStart,
        minimumSize: const Size.fromHeight(44),
      ),
      child: Row(
        children: [
          const Icon(Icons.event, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value == null ? label : '$label: $value',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (value != null)
            InkWell(
              onTap: onClear,
              child: Icon(Icons.close, size: 18, color: cs.outline),
            ),
        ],
      ),
    );
  }
}