import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:you_master_app/app/router/app_routes.dart';
import 'package:you_master_app/app/shell/app_shell.dart';
import 'package:you_master_app/features/app_entry/presentation/app_entry_page.dart';
import 'package:you_master_app/features/appointments/presentation/client_appointments_page.dart';
import 'package:you_master_app/features/client_home/presentation/client_home_page.dart';
import 'package:you_master_app/features/client_profile/presentation/client_profile_page.dart';
import 'package:you_master_app/features/client_search/presentation/client_search_page.dart';
import 'package:you_master_app/features/favorites/presentation/client_favorites_page.dart';
import 'package:you_master_app/features/placeholders/presentation/feature_placeholder_page.dart';
import 'package:you_master_app/features/professional_details/presentation/professional_details_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.entry,
    routes: [
      GoRoute(
        path: AppRoutes.entry,
        builder: (context, state) => const AppEntryPage(),
      ),
      GoRoute(
        path: AppRoutes.professionalDetailsPattern,
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          transitionDuration: const Duration(milliseconds: 360),
          reverseTransitionDuration: const Duration(milliseconds: 280),
          child: ProfessionalDetailsPage(
            professionalId: state.pathParameters['id']!,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final position = Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutCubic));

            return SlideTransition(
              position: animation.drive(position),
              child: child,
            );
          },
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(
          mode: AppShellMode.client,
          navigationShell: navigationShell,
        ),
        branches: _clientBranches,
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(
          mode: AppShellMode.professional,
          navigationShell: navigationShell,
        ),
        branches: _professionalBranches,
      ),
    ],
    errorBuilder: (context, state) => FeaturePlaceholderPage(
      title: 'Страница не найдена',
      description: state.error?.toString(),
      icon: Icons.search_off_rounded,
    ),
  );

  ref.onDispose(router.dispose);
  return router;
});

final _clientBranches = <StatefulShellBranch>[
  StatefulShellBranch(
    routes: [
      GoRoute(
        path: AppRoutes.clientHome,
        builder: (context, state) => const ClientHomePage(),
      ),
    ],
  ),
  StatefulShellBranch(
    routes: [
      GoRoute(
        path: AppRoutes.clientSearch,
        builder: (context, state) => const ClientSearchPage(),
      ),
    ],
  ),
  StatefulShellBranch(
    routes: [
      GoRoute(
        path: AppRoutes.clientAppointments,
        builder: (context, state) => const ClientAppointmentsPage(),
      ),
    ],
  ),
  StatefulShellBranch(
    routes: [
      GoRoute(
        path: AppRoutes.clientFavorites,
        builder: (context, state) => const ClientFavoritesPage(),
      ),
    ],
  ),
  StatefulShellBranch(
    routes: [
      GoRoute(
        path: AppRoutes.clientProfile,
        builder: (context, state) => const ClientProfilePage(),
      ),
    ],
  ),
];

final _professionalBranches = <StatefulShellBranch>[
  _placeholderBranch(
    path: AppRoutes.professionalHome,
    title: 'Главная мастера',
    icon: Icons.dashboard_rounded,
  ),
  _placeholderBranch(
    path: AppRoutes.professionalCalendar,
    title: 'Календарь',
    icon: Icons.calendar_month_rounded,
  ),
  _placeholderBranch(
    path: AppRoutes.professionalCreate,
    title: 'Быстрое действие',
    icon: Icons.add_circle_rounded,
  ),
  _placeholderBranch(
    path: AppRoutes.professionalMessages,
    title: 'Сообщения',
    icon: Icons.chat_bubble_rounded,
  ),
  _placeholderBranch(
    path: AppRoutes.professionalCabinet,
    title: 'Кабинет',
    icon: Icons.person_rounded,
  ),
];

StatefulShellBranch _placeholderBranch({
  required String path,
  required String title,
  required IconData icon,
}) {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: path,
        builder: (context, state) =>
            FeaturePlaceholderPage(title: title, icon: icon),
      ),
    ],
  );
}
