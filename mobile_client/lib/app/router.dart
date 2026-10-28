import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_client/app/app_shell.dart';
import 'package:mobile_client/core/context/app_context.dart';
import 'package:mobile_client/core/di/injection.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
// final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/notes',
  refreshListenable: getIt<AppContext>(),
  redirect: (context, state) {
    // final authContext = getIt<AppContext>();
    // final isLoggingIn = state.matchedLocation == '/login';

    return null;
  },
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
              builder: (_, _) => const Center(child: Text("Notes")),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/thoughts',
              builder: (_, _) => const Center(child: Text("Thoughts")),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/tasks',
              builder: (_, _) => const Center(child: Text("Tasks")),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/checklists',
              builder: (_, _) => const Center(child: Text("Checklists")),
            ),
          ],
        ),
      ],
    ),
    // GoRoute(
    //   path: '/posts/:slug',
    //   builder: (context, state) {
    //     final slug = state.pathParameters['slug']!;
    //     return PostScreen(slug: slug,);
    //   },
    // ),
  ],
);
