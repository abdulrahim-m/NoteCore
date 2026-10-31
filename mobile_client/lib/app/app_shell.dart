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
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      extendBody: false,
      
      // Integrated Top Bar with matching partial bottom separator
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(58),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              backgroundColor: colorScheme.surface,
              elevation: 0,
              scrolledUnderElevation: 0,
              title: Text(
                l10n.app_title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Divider(
                height: 1,
                thickness: 0.8,
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),

      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragEnd: (d) {
          final v = d.primaryVelocity ?? 0;
          if (v.abs() < 300) return;
          final rtl = Directionality.of(context) == TextDirection.rtl;
          final target = navigationShell.currentIndex + ((rtl ? v > 0 : v < 0) ? 1 : -1);
          if (target >= 0 && target < 4) navigationShell.goBranch(target);
        },
        child: navigationShell,
      ),

      // Integrated Bottom Bar matching the top style
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