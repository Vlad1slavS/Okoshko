import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:you_master_app/core/network/api_exception.dart';
import 'package:you_master_app/core/network/api_retry_policy.dart';
import 'package:you_master_app/features/auth/presentation/state/auth_provider_guard.dart';

void main() {
  test('does not retry client and auth failures', () {
    for (final status in [400, 401, 403, 404, 409, 422]) {
      expect(
        ApiRetryPolicy.transientErrors(
          0,
          ApiException(statusCode: status, message: 'failure'),
        ),
        isNull,
      );
    }
    expect(
      ApiRetryPolicy.transientErrors(
        0,
        const AuthenticationRequiredException(),
      ),
      isNull,
    );
  });

  test('retries temporary failures at most twice', () {
    final error = TimeoutException('timeout');
    expect(
      ApiRetryPolicy.transientErrors(0, error),
      const Duration(milliseconds: 500),
    );
    expect(
      ApiRetryPolicy.transientErrors(1, error),
      const Duration(milliseconds: 1000),
    );
    expect(ApiRetryPolicy.transientErrors(2, error), isNull);
  });
}
