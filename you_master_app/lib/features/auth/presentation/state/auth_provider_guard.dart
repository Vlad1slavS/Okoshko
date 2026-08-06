import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:you_master_app/core/config/app_environment.dart';
import 'package:you_master_app/features/auth/data/auth_repository.dart';
import 'package:you_master_app/features/auth/presentation/state/auth_controller.dart';

class AuthenticationRequiredException implements Exception {
  const AuthenticationRequiredException();
}

class ProfessionalProfileRequiredException implements Exception {
  const ProfessionalProfileRequiredException();
}

AuthUser requireAuthenticatedUser(Ref ref, {bool professional = false}) {
  if (!AppEnvironment.useRemoteApi) {
    return const AuthUser(
      id: 'local-user',
      phone: '+70000000000',
      hasClientProfile: true,
      hasProfessionalProfile: true,
    );
  }

  final auth = ref.watch(authControllerProvider);
  if (auth.status != AuthStatus.authenticated || auth.session == null) {
    throw const AuthenticationRequiredException();
  }
  final user = auth.session!.user;
  if (professional && !user.hasProfessionalProfile) {
    throw const ProfessionalProfileRequiredException();
  }
  return user;
}
