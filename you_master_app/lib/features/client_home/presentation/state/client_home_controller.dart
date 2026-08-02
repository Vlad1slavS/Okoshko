import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:you_master_app/features/client_home/data/client_home_repository.dart';
import 'package:you_master_app/features/client_home/domain/home_category.dart';
import 'package:you_master_app/features/client_home/domain/professional_preview.dart';
import 'package:you_master_app/features/client_home/presentation/state/client_home_state.dart';

final clientHomeRepositoryProvider = Provider<ClientHomeRepository>(
  (ref) => const MockClientHomeRepository(),
);

final clientHomeControllerProvider =
    NotifierProvider<ClientHomeController, ClientHomeState>(
      ClientHomeController.new,
    );

typedef PopularProfessionalsQuery = ({String city, HomeCategory category});

final popularProfessionalsProvider =
    FutureProvider.family<List<ProfessionalPreview>, PopularProfessionalsQuery>(
      (ref, query) {
        return ref
            .watch(clientHomeRepositoryProvider)
            .getPopularNearby(
              city: query.city,
              category: query.category,
              limit: 5,
            );
      },
    );

class ClientHomeController extends Notifier<ClientHomeState> {
  @override
  ClientHomeState build() => const ClientHomeState();

  void setSearchDraft(String value) {
    state = state.copyWith(searchDraft: value);
  }

  void selectCategory(HomeCategory value) {
    state = state.copyWith(category: value);
  }
}
