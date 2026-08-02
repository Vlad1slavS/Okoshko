import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:you_master_app/features/client_home/domain/professional_preview.dart';
import 'package:you_master_app/features/client_home/presentation/state/client_home_controller.dart';

final favoritesControllerProvider =
    NotifierProvider<FavoritesController, Set<String>>(FavoritesController.new);

final favoriteProfessionalsProvider = Provider<List<ProfessionalPreview>>((
  ref,
) {
  final favoriteIds = ref.watch(favoritesControllerProvider);
  final professionals = ref
      .watch(clientHomeRepositoryProvider)
      .getNearbyProfessionals();
  final professionalsById = {
    for (final professional in professionals) professional.id: professional,
  };

  return favoriteIds
      .map((id) => professionalsById[id])
      .whereType<ProfessionalPreview>()
      .toList(growable: false);
});

class FavoritesController extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  void toggle(String professionalId) {
    final updated = {...state};
    if (!updated.add(professionalId)) {
      updated.remove(professionalId);
    }
    state = updated;
  }
}
