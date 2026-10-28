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
      extendBody: true,
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
            icon: Icon(Icons.more_vert),
          ),
        ],
      ),

      body: navigationShell,

      bottomNavigationBar: _buildCompactBottomBar(context),
    );
  }

  Widget _buildCompactBottomBar(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;
    final colorScheme = Theme.of(context).colorScheme;

    final items = [
      (
        Icons.article_outlined,
        Icons.article,
        AppLocalizations.of(context)!.shell_navBar_note_view,
      ),
      (
        Icons.person_outline,
        Icons.person,
        AppLocalizations.of(context)!.shell_navBar_task_view,
      ),
    ];

    return SafeArea(
      child: Container(
        height: 48,
        margin: const EdgeInsets.fromLTRB(26, 0, 26, 15),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onPrimary,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(items.length, (index) {
              final isSelected = currentIndex == index;
              final item = items[index];

              return InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _onItemTapped(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 56,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primaryContainer
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? item.$2 : item.$1,
                        size: 20,
                        color: isSelected
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurfaceVariant,
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        Text(
                          item.$3,
                          style: TextStyle(
                            fontSize: 12,
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
      ),
    );
  }
}
