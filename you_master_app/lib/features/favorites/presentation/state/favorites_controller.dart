import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:you_master_app/core/config/app_environment.dart';
import 'package:you_master_app/core/network/api_retry_policy.dart';
import 'package:you_master_app/core/network/network_providers.dart';
import 'package:you_master_app/features/auth/presentation/state/auth_controller.dart';
import 'package:you_master_app/features/auth/presentation/state/auth_provider_guard.dart';
import 'package:you_master_app/features/client_home/domain/professional_preview.dart';
import 'package:you_master_app/features/client_home/presentation/state/client_home_controller.dart';
import 'package:you_master_app/features/favorites/data/favorites_repository.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return BackendFavoritesRepository(ref.watch(apiClientProvider));
});

class FavoritesState {
  const FavoritesState({this.ids = const {}, this.loading = false});

  final Set<String> ids;
  final bool loading;
}

final favoritesControllerProvider =
    NotifierProvider<FavoritesController, FavoritesState>(
      FavoritesController.new,
    );

class FavoritesController extends Notifier<FavoritesState> {
  Set<String> _confirmed = const {};
  final Map<String, Future<bool>> _syncing = {};

  @override
  FavoritesState build() {
    final userId = ref.watch(
      authControllerProvider.select((auth) => auth.session?.user.id),
    );
    _confirmed = const {};
    _syncing.clear();
    if (userId != null && AppEnvironment.useRemoteApi) {
      Future.microtask(() => _load(userId));
      return const FavoritesState(loading: true);
    }
    return const FavoritesState();
  }

  Future<void> _load(String userId) async {
    try {
      final ids = await ref.read(favoritesRepositoryProvider).getIds();
      if (ref.read(authControllerProvider).session?.user.id != userId) return;
      _confirmed = Set.unmodifiable(ids);
      state = FavoritesState(ids: _confirmed);
    } catch (_) {
      if (ref.read(authControllerProvider).session?.user.id == userId) {
        state = const FavoritesState();
      }
    }
  }

  Future<bool> toggle(String professionalId) {
    final updated = {...state.ids};
    if (!updated.add(professionalId)) updated.remove(professionalId);
    state = FavoritesState(ids: Set.unmodifiable(updated));

    if (!AppEnvironment.useRemoteApi) {
      _confirmed = state.ids;
      ref.invalidate(favoriteProfessionalsControllerProvider);
      return Future.value(true);
    }

    return _syncing[professionalId] ??= _synchronize(
      professionalId,
    ).whenComplete(() => _syncing.remove(professionalId));
  }

  Future<bool> _synchronize(String professionalId) async {
    var succeeded = true;
    while (_confirmed.contains(professionalId) !=
        state.ids.contains(professionalId)) {
      final desired = state.ids.contains(professionalId);
      try {
        await ref
            .read(favoritesRepositoryProvider)
            .setFavorite(professionalId, favorite: desired);
        final confirmed = {..._confirmed};
        desired
            ? confirmed.add(professionalId)
            : confirmed.remove(professionalId);
        _confirmed = Set.unmodifiable(confirmed);
        ref.invalidate(favoriteProfessionalsControllerProvider);
      } catch (_) {
        succeeded = false;
        if (state.ids.contains(professionalId) == desired) {
          final rollback = {...state.ids};
          _confirmed.contains(professionalId)
              ? rollback.add(professionalId)
              : rollback.remove(professionalId);
          state = FavoritesState(ids: Set.unmodifiable(rollback));
          break;
        }
      }
    }
    return succeeded;
  }
}

class FavoriteProfessionalsState {
  const FavoriteProfessionalsState({
    required this.items,
    required this.page,
    required this.hasNext,
    this.loadingMore = false,
  });

  final List<ProfessionalPreview> items;
  final int page;
  final bool hasNext;
  final bool loadingMore;

  FavoriteProfessionalsState copyWith({
    List<ProfessionalPreview>? items,
    int? page,
    bool? hasNext,
    bool? loadingMore,
  }) => FavoriteProfessionalsState(
    items: items ?? this.items,
    page: page ?? this.page,
    hasNext: hasNext ?? this.hasNext,
    loadingMore: loadingMore ?? this.loadingMore,
  );
}

final favoriteProfessionalsControllerProvider =
    AsyncNotifierProvider<
      FavoriteProfessionalsController,
      FavoriteProfessionalsState
    >(
      FavoriteProfessionalsController.new,
      retry: ApiRetryPolicy.transientErrors,
    );

class FavoriteProfessionalsController
    extends AsyncNotifier<FavoriteProfessionalsState> {
  static const _pageSize = 20;

  @override
  Future<FavoriteProfessionalsState> build() {
    requireAuthenticatedUser(ref);
    return _loadPage(0);
  }

  Future<FavoriteProfessionalsState> _loadPage(int page) async {
    if (!AppEnvironment.useRemoteApi) {
      final ids = ref.read(favoritesControllerProvider).ids;
      final items = ref
          .read(clientHomeRepositoryProvider)
          .getNearbyProfessionals()
          .where((professional) => ids.contains(professional.id))
          .toList(growable: false);
      return FavoriteProfessionalsState(items: items, page: 0, hasNext: false);
    }
    final result = await ref
        .read(favoritesRepositoryProvider)
        .getPage(page: page, size: _pageSize);
    return FavoriteProfessionalsState(
      items: result.items,
      page: result.page,
      hasNext: result.hasNext,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _loadPage(0));
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.loadingMore || !current.hasNext) return;
    state = AsyncData(current.copyWith(loadingMore: true));
    try {
      final next = await _loadPage(current.page + 1);
      state = AsyncData(
        FavoriteProfessionalsState(
          items: [...current.items, ...next.items],
          page: next.page,
          hasNext: next.hasNext,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}
