import 'package:flutter/material.dart';
import 'package:mobile_client/core/rust/dto/tag.dart';
import 'package:mobile_client/l10n/app_localizations.dart';
import 'package:mobile_client/shared/auto_save_text_field.dart';

/// Top of an open section: editable name, tag chips and an optional hint
/// shown while the section has no items.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.name,
    required this.nameHint,
    required this.tags,
    required this.onRename,
    required this.onEditTags,
    required this.onRemoveTag,
    this.emptyMessage,
  });

  final String name;
  final String nameHint;
  final List<TagDto> tags;
  final ValueChanged<String> onRename;
  final VoidCallback onEditTags;
  final ValueChanged<int> onRemoveTag;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final titleStyle = (theme.textTheme.headlineMedium ?? const TextStyle())
        .copyWith(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoSaveTextField(
            initialText: name,
            style: titleStyle,
            onSave: onRename,
            decoration: InputDecoration(
              hintText: nameHint,
              hintStyle: titleStyle,
              isDense: true,
              contentPadding: EdgeInsets.all(0),
              filled: false
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final tag in tags)
                InputChip(
                  visualDensity: VisualDensity.compact,
                  label: Text(tag.name),
                  onPressed: onEditTags,
                  onDeleted: () => onRemoveTag(tag.id),
                ),
              ActionChip(
                visualDensity: VisualDensity.compact,
                avatar: const Icon(Icons.add, size: 18),
                label: Text(l10n.notes_add_tag),
                onPressed: onEditTags,
              ),
            ],
          ),
          if (emptyMessage != null) ...[
            const SizedBox(height: 32),
            Center(
              child: Text(emptyMessage!, style: theme.textTheme.bodySmall),
            ),
          ],
        ],
      ),
    );
  }
}
