import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:you_master_app/app/router/app_route_guard.dart';
import 'package:you_master_app/app/router/app_routes.dart';
import 'package:you_master_app/app/shell/app_shell.dart';
import 'package:you_master_app/core/config/app_environment.dart';
import 'package:you_master_app/design_system/theme/app_colors.dart';
import 'package:you_master_app/features/app_entry/presentation/app_entry_page.dart';
import 'package:you_master_app/features/appointments/presentation/client_appointments_page.dart';
import 'package:you_master_app/features/auth/presentation/complete_profile_page.dart';
import 'package:you_master_app/features/auth/presentation/otp_auth_page.dart';
import 'package:you_master_app/features/auth/presentation/phone_auth_page.dart';
import 'package:you_master_app/features/auth/presentation/state/auth_controller.dart';
import 'package:you_master_app/features/client_home/presentation/client_home_page.dart';
import 'package:you_master_app/features/client_profile/presentation/client_profile_page.dart';
import 'package:you_master_app/features/client_search/presentation/client_search_page.dart';
import 'package:you_master_app/features/favorites/presentation/client_favorites_page.dart';
import 'package:you_master_app/features/placeholders/presentation/feature_placeholder_page.dart';
import 'package:you_master_app/features/professional_calendar/presentation/professional_calendar_page.dart';
import 'package:you_master_app/features/professional_details/presentation/professional_details_page.dart';
import 'package:you_master_app/features/professional_home/presentation/professional_home_page.dart';
import 'package:you_master_app/features/professional_schedule/presentation/professional_schedule_page.dart';

final appInitialLocationProvider = Provider<String>((ref) {
  final route = WidgetsBinding.instance.platformDispatcher.defaultRouteName;
  final uri = Uri.tryParse(route);
  if (uri == null ||
      !uri.hasAbsolutePath ||
      uri.hasScheme ||
      uri.hasAuthority) {
    return AppRoutes.entry;
  }
  return uri.toString();
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier();
  ref.listen(
    authControllerProvider.select((state) => state.status),
    (previous, next) => refreshNotifier.refresh(),
  );

  final router = GoRouter(
    initialLocation: ref.read(appInitialLocationProvider),
    overridePlatformDefaultLocation: true,
    refreshListenable: refreshNotifier,
    redirect: (context, state) => _redirect(ref, state),
    routes: [
      GoRoute(
        path: AppRoutes.entry,
        builder: (context, state) => const AppEntryPage(),
      ),
      GoRoute(
        path: AppRoutes.startup,
        builder: (context, state) => const _AppStartupPage(),
      ),
      GoRoute(
        path: AppRoutes.authPhone,
        builder: (context, state) => const PhoneAuthPage(),
      ),
      GoRoute(
        path: AppRoutes.authOtp,
        builder: (context, state) => const OtpAuthPage(),
      ),
      GoRoute(
        path: AppRoutes.authProfile,
        builder: (context, state) => const CompleteProfilePage(),
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

  ref.onDispose(() {
    router.dispose();
    refreshNotifier.dispose();
  });
  return router;
});

String? _redirect(Ref ref, GoRouterState routerState) {
  if (!AppEnvironment.useRemoteApi) return null;
  return AppRouteGuard.redirect(
    ref.read(authControllerProvider),
    routerState.uri,
  );
}

class _RouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}

class _AppStartupPage extends StatelessWidget {
  const _AppStartupPage();

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
  );
}

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
  StatefulShellBranch(
    routes: [
      GoRoute(
        path: AppRoutes.professionalHome,
        builder: (context, state) => const ProfessionalHomePage(),
      ),
    ],
  ),
  StatefulShellBranch(
    routes: [
      GoRoute(
        path: AppRoutes.professionalCalendar,
        builder: (context, state) => const ProfessionalCalendarPage(),
        routes: [
          GoRoute(
            path: 'schedule',
            builder: (context, state) => const ProfessionalSchedulePage(),
          ),
        ],
      ),
    ],
  ),
  _placeholderBranch(
    path: AppRoutes.professionalCreate,
    title: 'Быстрое действие',
    icon: Icons.add_circle_rounded,
  ),
  _placeholderBranch(
    path: AppRoutes.professionalClients,
    title: 'Клиенты',
    icon: Icons.people_rounded,
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
