import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:you_master_app/features/client_home/domain/home_category.dart';
import 'package:you_master_app/features/client_home/domain/professional_preview.dart';
import 'package:you_master_app/features/client_home/presentation/state/client_home_controller.dart';
import 'package:you_master_app/features/client_search/presentation/state/client_search_state.dart';

final clientSearchControllerProvider =
    NotifierProvider<ClientSearchController, ClientSearchState>(
      ClientSearchController.new,
    );

final searchResultsProvider = Provider<List<ProfessionalPreview>>((ref) {
  final filters = ref.watch(clientSearchControllerProvider);
  final normalizedQuery = filters.query.trim().toLowerCase();
  final professionals = ref
      .watch(clientHomeRepositoryProvider)
      .getNearbyProfessionals()
      .where(
        (professional) =>
            (filters.category == HomeCategory.all ||
                filters.category == HomeCategory.more ||
                professional.categories.contains(filters.category)) &&
            (normalizedQuery.isEmpty ||
                professional.name.toLowerCase().contains(normalizedQuery) ||
                professional.description.toLowerCase().contains(
                  normalizedQuery,
                )) &&
            professional.rating >= filters.minimumRating &&
            (!filters.availableToday || professional.availableToday),
      );
  final result = professionals.toList(growable: false);

  switch (filters.sort) {
    case SearchSort.recommended:
      return result;
    case SearchSort.rating:
      return [...result]..sort((a, b) => b.rating.compareTo(a.rating));
    case SearchSort.distance:
      return [...result]..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    case SearchSort.price:
      return [...result]..sort((a, b) => a.priceFrom.compareTo(b.priceFrom));
  }
});

class ClientSearchController extends Notifier<ClientSearchState> {
  @override
  ClientSearchState build() => const ClientSearchState();

  void initializeFromHome({
    required String query,
    required HomeCategory category,
  }) {
    state = state.copyWith(query: query, category: category);
  }

  void setQuery(String value) {
    state = state.copyWith(query: value);
  }

  void selectCategory(HomeCategory value) {
    state = state.copyWith(category: value);
  }

  void selectSort(SearchSort value) {
    state = state.copyWith(sort: value);
  }

  void setAvailableToday(bool value) {
    state = state.copyWith(availableToday: value);
  }

  void setMinimumRating(double value) {
    state = state.copyWith(minimumRating: value);
  }

  void reset() {
    state = const ClientSearchState();
  }
}
