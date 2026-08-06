import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:you_master_app/features/client_home/data/client_home_repository.dart';
import 'package:you_master_app/features/client_home/domain/home_category.dart';
import 'package:you_master_app/features/client_home/domain/professional_preview.dart';
import 'package:you_master_app/features/client_home/presentation/state/client_home_controller.dart';
import 'package:you_master_app/features/client_search/presentation/state/client_search_controller.dart';
import 'package:you_master_app/features/client_search/presentation/state/client_search_state.dart';

void main() {
  test('rapid typing triggers one search after debounce', () async {
    final repository = _CountingRepository();
    final container = ProviderContainer(
      overrides: [clientHomeRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final subscription = container.listen(searchResultsProvider, (_, _) {});
    addTearDown(subscription.close);
    await container.read(searchResultsProvider.future);
    expect(repository.searchCount, 1);

    final controller = container.read(clientSearchControllerProvider.notifier);
    controller.setQuery('а');
    controller.setQuery('ан');
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(repository.searchCount, 1);

    await Future<void>.delayed(const Duration(milliseconds: 350));
    await container.read(searchResultsProvider.future);
    expect(repository.searchCount, 2);
    expect(repository.lastQuery, 'ан');
  });
}

class _CountingRepository implements ClientHomeRepository {
  var searchCount = 0;
  String? lastQuery;

  @override
  List<ProfessionalPreview> getNearbyProfessionals() => const [];

  @override
  Future<List<ProfessionalPreview>> getPopularNearby({
    required String city,
    required HomeCategory category,
    required int limit,
  }) async => const [];

  @override
  Future<ProfessionalPreviewPage> search({
    required String city,
    required String query,
    required HomeCategory category,
    required SearchSort sort,
    required double minimumRating,
    required int page,
    required int size,
  }) async {
    searchCount++;
    lastQuery = query;
    return ProfessionalPreviewPage(
      items: const [],
      page: page,
      totalItems: 0,
      hasNext: false,
    );
  }
}
