import 'package:you_master_app/core/network/api_exception.dart';
import 'package:you_master_app/features/auth/presentation/state/auth_provider_guard.dart';

abstract final class ApiRetryPolicy {
  static Duration? transientErrors(int retryCount, Object error) {
    if (error is AuthenticationRequiredException ||
        error is ProfessionalProfileRequiredException) {
      return null;
    }
    if (error is ApiException &&
        error.statusCode >= 400 &&
        error.statusCode < 500) {
      return null;
    }

    if (retryCount >= 2) return null;

    return Duration(milliseconds: retryCount == 0 ? 500 : 1000);
  }
}
