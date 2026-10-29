import 'package:flutter/material.dart';
import 'package:mobile_client/core/rust/dto/tag.dart';
import 'package:mobile_client/l10n/app_localizations.dart';

/// Multi-select tags with inline creation. Returns the chosen tag ids, or
/// `null` if dismissed.
///
/// [tags] is read on every [listenable] change, so newly created tags appear
/// immediately. With [allowEmpty] the user may confirm an empty selection
/// (needed when editing the exact tag set of one note).
Future<Set<int>?> showTagPickerSheet(
  BuildContext context, {
  required Listenable listenable,
  required List<TagDto> Function() tags,
  required Future<TagDto?> Function(String name) onCreate,
  Set<int> initial = const {},
  String? title,
  bool allowEmpty = false,
}) {
  return showModalBottomSheet<Set<int>>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _TagPickerSheet(
      listenable: listenable,
      tags: tags,
      onCreate: onCreate,
      initial: initial,
      title: title,
      allowEmpty: allowEmpty,
    ),
  );
}

class _TagPickerSheet extends StatefulWidget {
  const _TagPickerSheet({
    required this.listenable,
    required this.tags,
    required this.onCreate,
    required this.initial,
    required this.title,
    required this.allowEmpty,
  });

  final Listenable listenable;
  final List<TagDto> Function() tags;
  final Future<TagDto?> Function(String name) onCreate;
  final Set<int> initial;
  final String? title;
  final bool allowEmpty;

  @override
  State<_TagPickerSheet> createState() => _TagPickerSheetState();
}

class _TagPickerSheetState extends State<_TagPickerSheet> {
  late final Set<int> _picked = {...widget.initial};
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
    final tag = await widget.onCreate(name);
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
            listenable: widget.listenable,
            builder: (context, _) {
              final tags = widget.tags();
              final canConfirm = widget.allowEmpty || _picked.isNotEmpty;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title ?? l10n.notes_add_tag,
                    style: theme.textTheme.titleMedium,
                  ),
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
                      onPressed: canConfirm
                          ? () => Navigator.pop(context, {..._picked})
                          : null,
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
