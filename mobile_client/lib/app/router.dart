import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_client/app/app_shell.dart';
import 'package:mobile_client/core/context/app_context.dart';
import 'package:mobile_client/core/di/injection.dart';
import 'package:mobile_client/features/notes/presentation/pages/note_page.dart';
import 'package:mobile_client/features/notes/presentation/pages/notes_page.dart';
import 'package:mobile_client/features/thoughts/presentation/pages/thought_section_page.dart';
import 'package:mobile_client/features/thoughts/presentation/pages/thoughts_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/notes',
  refreshListenable: getIt<AppContext>(),
  redirect: (context, state) => null,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/notes',
              builder: (_, _) => const NotesPage(),
              routes: [
                GoRoute(
                  path: ':id',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (_, state) => NotePage(
                    noteId:
                        int.tryParse(state.pathParameters['id'] ?? '') ?? -1,
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/thoughts',
              builder: (_, _) => const ThoughtsPage(),
              routes: [
                GoRoute(
                  path: ':id',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (_, state) => ThoughtSectionPage(
                    sectionId:
                        int.tryParse(state.pathParameters['id'] ?? '') ?? -1,
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/tasks',
              builder: (_, _) => const Center(child: Text('Tasks')),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/checklists',
              builder: (_, _) => const Center(child: Text('Checklists')),
            ),
          ],
        ),
      ],
    ),
  ],
);
