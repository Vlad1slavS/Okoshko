import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:you_master_app/features/professional_home/data/professional_home_repository.dart';
import 'package:you_master_app/features/professional_home/domain/professional_dashboard.dart';

final professionalHomeRepositoryProvider = Provider<ProfessionalHomeRepository>(
  (ref) => const MockProfessionalHomeRepository(),
);

final professionalHomeControllerProvider =
    AsyncNotifierProvider<ProfessionalHomeController, ProfessionalDashboard>(
      ProfessionalHomeController.new,
    );

class ProfessionalHomeController extends AsyncNotifier<ProfessionalDashboard> {
  @override
  Future<ProfessionalDashboard> build() {
    return ref.read(professionalHomeRepositoryProvider).getDashboard();
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(
      ref.read(professionalHomeRepositoryProvider).getDashboard,
    );
  }
}
