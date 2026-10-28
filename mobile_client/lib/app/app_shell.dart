import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_client/l10n/app_localizations.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onItemTapped(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false, // Connected normally to the bottom screen edge
      appBar: AppBar(
        title: Text(
          "NoteCore",
          style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(color: Theme.of(context).colorScheme.primary),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Options?
            },
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),

      body: navigationShell,

      bottomNavigationBar: _buildIntegratedBottomBar(context),
    );
  }

  Widget _buildIntegratedBottomBar(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final items = [
      (
        Icons.article_outlined,
        Icons.article,
        l10n.shell_navBar_note_view,
      ),
      (
        Icons.lightbulb_outline,
        Icons.lightbulb,
        l10n.shell_navBar_thought_view,
      ),
      (
        Icons.task_alt_outlined,
        Icons.task_alt,
        l10n.shell_navBar_task_view,
      ),
      (
        Icons.checklist_outlined,
        Icons.checklist,
        l10n.shell_navBar_checklist_view,
      ),
    ];

    return Container(
      color: colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Partial top separator line that does not fully connect on the sides
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Divider(
                height: 1,
                thickness: 0.8,
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(items.length, (index) {
                  final isSelected = currentIndex == index;
                  final item = items[index];

                  return InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _onItemTapped(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.primaryContainer
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected ? item.$2 : item.$1,
                            size: 20,
                            color: isSelected
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onSurfaceVariant,
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 6),
                            Text(
                              item.$3,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}