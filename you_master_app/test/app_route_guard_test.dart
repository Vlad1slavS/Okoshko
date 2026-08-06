import 'package:flutter_test/flutter_test.dart';
import 'package:you_master_app/app/router/app_route_guard.dart';
import 'package:you_master_app/app/router/app_routes.dart';
import 'package:you_master_app/features/auth/data/auth_repository.dart';
import 'package:you_master_app/features/auth/presentation/state/auth_controller.dart';

void main() {
  const client = AuthUser(
    id: 'client-id',
    phone: '+79990000000',
    hasClientProfile: true,
    hasProfessionalProfile: false,
  );
  const professional = AuthUser(
    id: 'professional-id',
    phone: '+79990000001',
    hasClientProfile: true,
    hasProfessionalProfile: true,
  );

  AuthState authenticated(AuthUser user) => AuthState(
    status: AuthStatus.authenticated,
    session: AuthSession(accessToken: 'token', user: user),
  );

  test('holds initial route on startup until auth is resolved', () {
    const auth = AuthState(status: AuthStatus.initializing);

    expect(
      AppRouteGuard.redirect(auth, Uri.parse('/client/favorites')),
      '/startup?returnTo=%2Fclient%2Ffavorites',
    );
    expect(
      AppRouteGuard.redirect(
        auth,
        Uri.parse('/startup?returnTo=%2Fclient%2Ffavorites'),
      ),
      isNull,
    );
  });

  test('resolves startup route according to auth and target access', () {
    expect(
      AppRouteGuard.redirect(
        authenticated(client),
        Uri.parse('/startup?returnTo=%2Fclient%2Ffavorites'),
      ),
      AppRoutes.clientFavorites,
    );
    expect(
      AppRouteGuard.redirect(
        const AuthState(status: AuthStatus.unauthenticated),
        Uri.parse('/startup?returnTo=%2Fclient%2Ffavorites'),
      ),
      '/auth/phone?returnTo=%2Fclient%2Ffavorites',
    );
  });

  test('allows public pages without authentication', () {
    const auth = AuthState(status: AuthStatus.unauthenticated);

    expect(AppRouteGuard.redirect(auth, Uri.parse('/client/home')), isNull);
    expect(AppRouteGuard.redirect(auth, Uri.parse('/client/search')), isNull);
    expect(
      AppRouteGuard.redirect(auth, Uri.parse('/professionals/anna-ivanova')),
      isNull,
    );
  });

  test('protects client route and preserves safe returnTo', () {
    const auth = AuthState(status: AuthStatus.unauthenticated);

    expect(
      AppRouteGuard.redirect(auth, Uri.parse('/client/favorites')),
      '/auth/phone?returnTo=%2Fclient%2Ffavorites',
    );
  });

  test('returns authenticated client to requested route after auth', () {
    expect(
      AppRouteGuard.redirect(
        authenticated(client),
        Uri.parse('/auth/otp?returnTo=%2Fclient%2Ffavorites'),
      ),
      AppRoutes.clientFavorites,
    );
  });

  test('requires completed client profile before returnTo', () {
    const incomplete = AuthUser(
      id: 'new-user',
      phone: '+79990000002',
      hasClientProfile: false,
      hasProfessionalProfile: false,
    );

    expect(
      AppRouteGuard.redirect(
        authenticated(incomplete),
        Uri.parse('/auth/otp?returnTo=%2Fclient%2Ffavorites'),
      ),
      '/auth/profile?returnTo=%2Fclient%2Ffavorites',
    );
  });

  test('requires professional profile for professional routes', () {
    expect(
      AppRouteGuard.redirect(
        authenticated(client),
        Uri.parse('/professional/calendar'),
      ),
      AppRoutes.clientProfile,
    );
    expect(
      AppRouteGuard.redirect(
        authenticated(professional),
        Uri.parse('/professional/calendar'),
      ),
      isNull,
    );
  });

  test('rejects external returnTo', () {
    expect(AppRoutes.safeReturnTo('https://evil.example'), isNull);
    expect(AppRoutes.safeReturnTo('//evil.example/path'), isNull);
    expect(AppRoutes.safeReturnTo('/auth/otp'), isNull);
  });
}
