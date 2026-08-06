import 'package:you_master_app/app/router/app_routes.dart';
import 'package:you_master_app/features/auth/presentation/state/auth_controller.dart';

abstract final class AppRouteGuard {
  static String? redirect(AuthState auth, Uri uri) {
    if (auth.status == AuthStatus.initializing) return null;

    final location = uri.path;
    final returnTo = AppRoutes.safeReturnTo(uri.queryParameters['returnTo']);
    final isAuthRoute = location.startsWith('/auth/');
    final isPrivateClientRoute =
        location == AppRoutes.clientAppointments ||
        location == AppRoutes.clientFavorites ||
        location == AppRoutes.clientProfile;
    final isProfessionalRoute = location.startsWith('/professional/');

    if (auth.status == AuthStatus.unauthenticated) {
      if (isPrivateClientRoute || isProfessionalRoute) {
        return AppRoutes.withReturnTo(AppRoutes.authPhone, uri.toString());
      }
      if (location == AppRoutes.authOtp && auth.phone == null) {
        return AppRoutes.withReturnTo(AppRoutes.authPhone, returnTo);
      }
      if (location == AppRoutes.authProfile) {
        return AppRoutes.withReturnTo(AppRoutes.authPhone, returnTo);
      }
      if (location == AppRoutes.entry) return AppRoutes.clientHome;
      return null;
    }

    final user = auth.session?.user;
    if (user == null) return AppRoutes.authPhone;

    if (!user.hasClientProfile) {
      if (location == AppRoutes.authProfile) return null;
      return AppRoutes.withReturnTo(
        AppRoutes.authProfile,
        returnTo ?? (isAuthRoute ? null : uri.toString()),
      );
    }

    if (isProfessionalRoute && !user.hasProfessionalProfile) {
      return AppRoutes.clientProfile;
    }

    if (isAuthRoute || location == AppRoutes.entry) {
      return returnTo ?? AppRoutes.clientHome;
    }

    return null;
  }
}
