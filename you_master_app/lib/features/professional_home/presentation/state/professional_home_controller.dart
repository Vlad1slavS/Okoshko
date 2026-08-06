import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:you_master_app/core/network/api_retry_policy.dart';
import 'package:you_master_app/features/auth/presentation/state/auth_provider_guard.dart';
import 'package:you_master_app/features/professional_home/data/professional_home_repository.dart';
import 'package:you_master_app/features/professional_home/domain/professional_dashboard.dart';

final professionalHomeRepositoryProvider = Provider<ProfessionalHomeRepository>(
  (ref) => const MockProfessionalHomeRepository(),
);

final professionalHomeControllerProvider =
    AsyncNotifierProvider<ProfessionalHomeController, ProfessionalDashboard>(
      ProfessionalHomeController.new,
      retry: ApiRetryPolicy.transientErrors,
    );

class ProfessionalHomeController extends AsyncNotifier<ProfessionalDashboard> {
  @override
  Future<ProfessionalDashboard> build() {
    requireAuthenticatedUser(ref, professional: true);
    return ref.read(professionalHomeRepositoryProvider).getDashboard();
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(
      ref.read(professionalHomeRepositoryProvider).getDashboard,
    );
  }
}
