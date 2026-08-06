import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:you_master_app/features/auth/data/auth_repository.dart';
import 'package:you_master_app/core/network/network_providers.dart';

class AuthState {
  const AuthState({
    this.phone,
    this.devCode,
    this.resendAfter = Duration.zero,
    this.session,
    this.loading = false,
    this.error,
  });
  final String? phone;
  final String? devCode;
  final Duration resendAfter;
  final AuthSession? session;
  final bool loading;
  final String? error;
  AuthState copyWith({
    String? phone,
    String? devCode,
    Duration? resendAfter,
    AuthSession? session,
    bool? loading,
    String? error,
    bool clearError = false,
  }) => AuthState(
    phone: phone ?? this.phone,
    devCode: devCode ?? this.devCode,
    resendAfter: resendAfter ?? this.resendAfter,
    session: session ?? this.session,
    loading: loading ?? this.loading,
    error: clearError ? null : error ?? this.error,
  );
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<bool> requestOtp(String phone) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final result = await ref.read(authRepositoryProvider).requestOtp(phone);
      state = AuthState(
        phone: phone,
        devCode: result.devCode,
        resendAfter: result.resendAfter,
      );
      return true;
    } catch (error) {
      state = state.copyWith(loading: false, error: _message(error));
      return false;
    }
  }

  Future<bool> verifyOtp(String code) async {
    final phone = state.phone;
    if (phone == null) return false;
    state = state.copyWith(loading: true, clearError: true);
    try {
      final session = await ref
          .read(authRepositoryProvider)
          .verifyOtp(phone, code);
      ref.read(apiClientProvider).setAccessToken(session.accessToken);
      ref.read(apiClientProvider).setUnauthorizedHandler(refreshAccessToken);
      state = state.copyWith(
        loading: false,
        session: session,
        clearError: true,
      );
      return true;
    } catch (error) {
      state = state.copyWith(loading: false, error: _message(error));
      return false;
    }
  }

  Future<bool> restoreSession() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final session = await ref.read(authRepositoryProvider).refresh();
      ref.read(apiClientProvider).setAccessToken(session.accessToken);
      ref.read(apiClientProvider).setUnauthorizedHandler(refreshAccessToken);
      state = state.copyWith(
        loading: false,
        session: session,
        clearError: true,
      );
      return true;
    } catch (_) {
      ref.read(apiClientProvider).setAccessToken(null);
      ref.read(apiClientProvider).setUnauthorizedHandler(null);
      state = const AuthState();
      return false;
    }
  }

  Future<bool> refreshAccessToken() async {
    try {
      final session = await ref.read(authRepositoryProvider).refresh();
      ref.read(apiClientProvider).setAccessToken(session.accessToken);
      state = state.copyWith(session: session, clearError: true);
      return true;
    } catch (_) {
      ref.read(apiClientProvider).setAccessToken(null);
      ref.read(apiClientProvider).setUnauthorizedHandler(null);
      state = const AuthState();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await ref.read(authRepositoryProvider).logout();
    } finally {
      ref.read(apiClientProvider).setAccessToken(null);
      ref.read(apiClientProvider).setUnauthorizedHandler(null);
      state = const AuthState();
    }
  }

  Future<bool> completeProfile({
    required String firstName,
    String? lastName,
  }) async {
    final session = state.session;
    if (session == null) return false;
    state = state.copyWith(loading: true, clearError: true);
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .completeProfile(firstName: firstName, lastName: lastName);
      state = state.copyWith(
        loading: false,
        session: AuthSession(accessToken: session.accessToken, user: user),
        clearError: true,
      );
      return true;
    } catch (error) {
      state = state.copyWith(loading: false, error: _message(error));
      return false;
    }
  }

  String _message(Object error) =>
      error.toString().replaceFirst('ApiException: ', '');
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
