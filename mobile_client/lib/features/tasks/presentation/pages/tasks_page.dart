import 'package:flutter/material.dart';
import 'package:mobile_client/core/di/injection.dart';
import 'package:mobile_client/core/rust/api/tasks.dart';
import 'package:mobile_client/core/rust/dto/task.dart';
import 'package:mobile_client/features/tasks/presentation/controllers/tasks_controller.dart';
import 'package:mobile_client/features/tasks/presentation/widgets/task_card.dart';
import 'package:mobile_client/features/tasks/presentation/widgets/upcoming_strip.dart';
import 'package:mobile_client/l10n/app_localizations.dart';
import 'package:mobile_client/shared/views/searchable_list_page.dart';
import 'package:mobile_client/shared/widgets/section_selection_actions.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SearchableListPage<TasksController, TaskDto>(
      create: (filters) =>
          TasksController(api: getIt<TasksApi>(), filters: filters),
      routeOf: (id) => id < 0 ? '/tasks/new' : '/tasks/$id',
      onCreate: (context, c, open) => open(-1),
      createTooltip: l10n.tasks_new,
      visibleCount: (c) => c.items.length,
      emptyText: (c) => switch (c.view) {
        TaskView.overview => l10n.tasks_empty,
        TaskView.simple => l10n.tasks_empty_simple,
        TaskView.periodic => l10n.tasks_empty_periodic,
      },
      emptyIcon: Icons.task_alt,
      searchHint: l10n.tasks_search_hint,
      selectionActions: (context, c) => buildSelectionActions<TaskDto>(
        context,
        controller: c,
        deleteTitle: l10n.tasks_delete_title,
        deleteBody: l10n.tasks_delete_body,
      ),
      toolbar: (context, c) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        child: Row(
          children: [
            ChoiceChip(
              avatar: const Icon(Icons.task_alt, size: 18),
              label: Text(l10n.tasks_view_simple),
              selected: c.view == TaskView.simple,
              onSelected: (_) => c.setView(TaskView.simple),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              avatar: const Icon(Icons.repeat, size: 18),
              label: Text(l10n.tasks_view_periodic),
              selected: c.view == TaskView.periodic,
              onSelected: (_) => c.setView(TaskView.periodic),
            ),
          ],
        ),
      ),
      slivers: (context, c, open) {
        final showUpcoming =
            c.view == TaskView.overview &&
            !c.filters.isSearching &&
            c.upcoming.isNotEmpty;

        return [
          if (showUpcoming) ...[
            SliverToBoxAdapter(
              child: UpcomingStrip(
                entries: c.upcoming,
                onOpen: open,
                onToggle: c.toggleDone,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(l10n.tasks_all, style: theme.textTheme.titleSmall),
              ),
            ),
          ],
          SliverPadding(
            padding: const EdgeInsets.only(top: 4, bottom: 88),
            sliver: SliverList.builder(
              itemCount: c.items.length,
              itemBuilder: (_, i) {
                final t = c.items[i];
                return TaskCard(
                  key: ValueKey(t.id),
                  task: t,
                  selecting: c.selecting,
                  selected: c.selectedIds.contains(t.id),
                  onLongPress: () => c.toggleSelection(t.id),
                  onTap: () => c.selecting ? c.toggleSelection(t.id) : open(t.id),
                  onToggleDone: () => c.toggleDone(t.id),
                  expanded: c.isExpanded(t.id),
                  onToggleExpanded: () => c.toggleExpanded(t.id),
                  onToggleSubTask: (i) => c.toggleSubTask(t.id, i),
                );
              },
            ),
          ),
        ];
      },
    );
  }
}
