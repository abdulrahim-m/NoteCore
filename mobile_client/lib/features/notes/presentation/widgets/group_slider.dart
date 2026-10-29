import 'package:flutter/material.dart';
import 'package:mobile_client/core/rust/dto/note.dart';
import 'package:mobile_client/l10n/app_localizations.dart';

/// Horizontally scrolling group tabs. Deliberately borderless so they blend
/// into the page. "All" is always first. a pinned button at the end opens management.
class GroupSlider extends StatelessWidget {
  const GroupSlider({
    super.key,
    required this.groups,
    required this.selectedId,
    required this.onSelected,
    required this.onManage,
  });

  final List<NoteGroupDto> groups;
  final int? selectedId;
  final ValueChanged<int?> onSelected;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsetsDirectional.only(start: 12, end: 4),
              children: [
                _GroupTab(
                  label: l10n.notes_all,
                  selected: selectedId == null,
                  onTap: () => onSelected(null),
                ),
                for (final g in groups)
                  _GroupTab(
                    label: g.name,
                    count: g.listedNotes,
                    selected: selectedId == g.id,
                    onTap: () => onSelected(g.id),
                  ),
              ],
            ),
          ),
          IconButton(
            tooltip: l10n.notes_manage_groups,
            onPressed: onManage,
            icon: const Icon(Icons.edit_note),
          ),
        ],
      ),
    );
  }
}

class _GroupTab extends StatelessWidget {
  const _GroupTab({
    required this.label,
    required this.selected,
    required this.onTap,
    this.count,
  });

  final String label;
  final int? count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = selected ? cs.primary : cs.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected
                  ? cs.primary.withValues(alpha: 0.14)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                    color: color,
                  ),
                ),
                if (count != null) ...[
                  const SizedBox(width: 6),
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 11,
                      color: color.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
