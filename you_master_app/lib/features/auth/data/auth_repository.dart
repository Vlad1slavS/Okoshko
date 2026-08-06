import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:you_master_app/core/network/api_client.dart';
import 'package:you_master_app/core/network/network_providers.dart';

class OtpRequestResult {
  const OtpRequestResult({required this.resendAfter, this.devCode});
  final Duration resendAfter;
  final String? devCode;
}

class AuthSession {
  const AuthSession({required this.accessToken, required this.user});
  final String accessToken;
  final AuthUser user;
}

class AuthUser {
  const AuthUser({
    required this.id,
    required this.phone,
    required this.hasClientProfile,
    required this.hasProfessionalProfile,
    this.displayName,
    this.email,
  });
  final String id;
  final String phone;
  final String? displayName;
  final String? email;
  final bool hasClientProfile;
  final bool hasProfessionalProfile;
}

class AuthRepository {
  const AuthRepository(this._api);
  final ApiClient _api;

  Future<OtpRequestResult> requestOtp(String phone) async {
    final json = await _api.postObject('/api/v1/auth/otp/request', {
      'phone': phone,
    });
    return OtpRequestResult(
      resendAfter: Duration(seconds: json['resendAfterSeconds'] as int),
      devCode: json['devCode'] as String?,
    );
  }

  Future<AuthSession> verifyOtp(String phone, String code) async {
    final json = await _api.postObject('/api/v1/auth/otp/verify', {
      'phone': phone,
      'code': code,
    });
    return _session(json);
  }

  Future<AuthSession> refresh() async =>
      _session(await _api.postObject('/api/v1/auth/refresh', const {}));
  Future<void> logout() async {
    await _api.postObject('/api/v1/auth/logout', const {});
  }

  Future<AuthUser> completeProfile({
    required String firstName,
    String? lastName,
  }) async {
    final json = await _api.putObject('/api/v1/auth/me/profile', {
      'firstName': firstName,
      'lastName': lastName,
    });
    return _user(json);
  }

  AuthSession _session(Map<String, Object?> json) {
    final user = json['user']! as Map<String, dynamic>;
    return AuthSession(
      accessToken: json['accessToken'] as String,
      user: _user(user),
    );
  }

  AuthUser _user(Map<String, Object?> user) => AuthUser(
    id: user['id'] as String,
    phone: user['phone'] as String,
    email: user['email'] as String?,
    displayName: user['displayName'] as String?,
    hasClientProfile: user['hasClientProfile'] as bool,
    hasProfessionalProfile: user['hasProfessionalProfile'] as bool,
  );
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(apiClientProvider)),
);
