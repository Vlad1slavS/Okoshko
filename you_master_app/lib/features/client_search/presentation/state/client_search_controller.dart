import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:you_master_app/core/network/api_retry_policy.dart';
import 'package:you_master_app/features/client_location/presentation/state/client_location_controller.dart';
import 'package:you_master_app/features/client_home/domain/home_category.dart';
import 'package:you_master_app/features/client_home/data/client_home_repository.dart';
import 'package:you_master_app/features/client_home/presentation/state/client_home_controller.dart';
import 'package:you_master_app/features/client_search/presentation/state/client_search_state.dart';

final clientSearchControllerProvider =
    NotifierProvider<ClientSearchController, ClientSearchState>(
      ClientSearchController.new,
    );

final searchResultsProvider =
    AsyncNotifierProvider<SearchResultsController, ProfessionalPreviewPage>(
      SearchResultsController.new,
      retry: ApiRetryPolicy.transientErrors,
    );

class SearchResultsController extends AsyncNotifier<ProfessionalPreviewPage> {
  static const _pageSize = 20;
  bool _loadingNextPage = false;

  @override
  Future<ProfessionalPreviewPage> build() {
    final filters = ref.watch(
      clientSearchControllerProvider.select(
        (state) => (
          query: state.query,
          category: state.category,
          sort: state.sort,
          minimumRating: state.minimumRating,
        ),
      ),
    );
    final city = ref.watch(clientLocationProvider);
    return ref
        .watch(clientHomeRepositoryProvider)
        .search(
          city: city,
          query: filters.query,
          category: filters.category,
          sort: filters.sort,
          minimumRating: filters.minimumRating,
          page: 0,
          size: _pageSize,
        );
  }

  Future<void> loadNextPage() async {
    final current = state.value;
    if (_loadingNextPage || current == null || !current.hasNext) return;
    _loadingNextPage = true;
    try {
      final filters = ref.read(clientSearchControllerProvider);
      final next = await ref
          .read(clientHomeRepositoryProvider)
          .search(
            city: ref.read(clientLocationProvider),
            query: filters.query,
            category: filters.category,
            sort: filters.sort,
            minimumRating: filters.minimumRating,
            page: current.page + 1,
            size: _pageSize,
          );
      state = AsyncData(
        ProfessionalPreviewPage(
          items: [...current.items, ...next.items],
          page: next.page,
          totalItems: next.totalItems,
          hasNext: next.hasNext,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncError<ProfessionalPreviewPage>(error, stackTrace);
    } finally {
      _loadingNextPage = false;
    }
  }
}

class ClientSearchController extends Notifier<ClientSearchState> {
  Timer? _searchDebounce;

  @override
  ClientSearchState build() {
    ref.onDispose(() => _searchDebounce?.cancel());
    return const ClientSearchState();
  }

  void initializeFromHome({
    required String query,
    required HomeCategory category,
  }) {
    _searchDebounce?.cancel();
    state = state.copyWith(query: query, queryDraft: query, category: category);
  }

  void setQuery(String value) {
    _searchDebounce?.cancel();
    state = state.copyWith(queryDraft: value);
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      state = state.copyWith(query: value);
    });
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
    _searchDebounce?.cancel();
    state = const ClientSearchState();
  }
}
