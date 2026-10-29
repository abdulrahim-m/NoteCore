import 'package:flutter/material.dart';
import 'package:mobile_client/features/notes/presentation/controllers/notes_controller.dart';
import 'package:mobile_client/l10n/app_localizations.dart';

/// Multi-select tags (with inline creation). Returns the chosen tag ids, or
/// `null` if dismissed.
Future<Set<int>?> showTagPickerSheet(
  BuildContext context,
  NotesController controller,
) {
  return showModalBottomSheet<Set<int>>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _TagPickerSheet(controller: controller),
  );
}

class _TagPickerSheet extends StatefulWidget {
  const _TagPickerSheet({required this.controller});
  final NotesController controller;

  @override
  State<_TagPickerSheet> createState() => _TagPickerSheetState();
}

class _TagPickerSheetState extends State<_TagPickerSheet> {
  final Set<int> _picked = {};
  final _field = TextEditingController();

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _field.text.trim();
    if (name.isEmpty) return;
    _field.clear();
    final tag = await widget.controller.createTag(name);
    if (tag != null && mounted) setState(() => _picked.add(tag.id));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: ListenableBuilder(
            listenable: widget.controller,
            builder: (context, _) {
              final tags = widget.controller.tags;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.notes_add_tag, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  if (tags.isEmpty)
                    Text(
                      l10n.notes_tags_empty,
                      style: theme.textTheme.bodySmall,
                    )
                  else
                    Flexible(
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            for (final t in tags)
                              FilterChip(
                                label: Text(t.name),
                                selected: _picked.contains(t.id),
                                onSelected: (v) => setState(() {
                                  v ? _picked.add(t.id) : _picked.remove(t.id);
                                }),
                              ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _field,
                    onSubmitted: (_) => _create(),
                    decoration: InputDecoration(
                      hintText: l10n.notes_new_tag,
                      isDense: true,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _create,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _picked.isEmpty
                          ? null
                          : () => Navigator.pop(context, {..._picked}),
                      child: Text(l10n.notes_done),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
