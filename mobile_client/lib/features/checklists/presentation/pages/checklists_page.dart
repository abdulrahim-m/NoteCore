import 'package:flutter/material.dart';
import 'package:mobile_client/core/di/injection.dart';
import 'package:mobile_client/core/rust/api/short_tasks.dart';
import 'package:mobile_client/core/rust/dto/short_task.dart';
import 'package:mobile_client/features/checklists/presentation/controllers/short_tasks_controller.dart';
import 'package:mobile_client/features/checklists/presentation/widgets/checklist_card.dart';
import 'package:mobile_client/l10n/app_localizations.dart';
import 'package:mobile_client/shared/section_list_page.dart';

/// "Checklists" tab: expandable sections of tickable short tasks. Finished
/// items/sections are hidden unless "Show completed" is on.
class ChecklistsPage extends StatelessWidget {
  const ChecklistsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SectionListPage<ShortTasksController, ShortTaskSectionDto>(
      create: (filters) =>
          ShortTasksController(api: getIt<ShortTasksApi>(), filters: filters),
      routeOf: (id) => '/checklists/$id',
      visibleCount: (c) => c.visibleSections.length,
      emptyText: (c) =>
          c.items.isNotEmpty ? l10n.checklists_all_done : l10n.checklists_empty,
      emptyIcon: Icons.checklist,
      searchHint: l10n.checklists_search_hint,
      newTitle: l10n.checklists_new_section,
      nameHint: l10n.checklists_section_name,
      renameTitle: l10n.checklists_rename_section,
      deleteTitle: l10n.checklists_delete_title,
      deleteBody: l10n.checklists_delete_body,
      toolbar: (context, c) => Align(
        alignment: AlignmentDirectional.centerStart,
        child: Padding(
          padding: const EdgeInsetsDirectional.only(start: 12),
          child: FilterChip(
            visualDensity: VisualDensity.compact,
            label: Text(l10n.checklists_show_completed),
            selected: c.showCompleted,
            onSelected: (_) => c.toggleShowCompleted(),
          ),
        ),
      ),
      slivers: (context, c, open) {
        final sections = c.visibleSections;
        return [
          SliverPadding(
            padding: const EdgeInsets.only(top: 4, bottom: 88),
            sliver: SliverList.builder(
              itemCount: sections.length,
              itemBuilder: (_, i) {
                final s = sections[i];
                return ChecklistCard(
                  key: ValueKey(s.id),
                  section: s,
                  items: c.visibleItems(s),
                  expanded: c.isExpanded(s.id),
                  selecting: c.selecting,
                  selected: c.selectedIds.contains(s.id),
                  onHeaderTap: () =>
                      c.selecting ? c.toggleSelection(s.id) : c.toggleExpanded(s.id),
                  onLongPress: () => c.toggleSelection(s.id),
                  onOpen: () => open(s.id),
                  onToggleItem: (itemId) => c.toggleItem(s.id, itemId),
                );
              },
            ),
          ),
        ];
      },
    );
  }
}
