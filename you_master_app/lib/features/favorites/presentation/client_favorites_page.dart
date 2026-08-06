import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:you_master_app/app/router/app_routes.dart';
import 'package:you_master_app/design_system/theme/app_colors.dart';
import 'package:you_master_app/features/client_home/presentation/widgets/professional_card.dart';
import 'package:you_master_app/features/favorites/presentation/state/favorites_controller.dart';

class ClientFavoritesPage extends ConsumerWidget {
  const ClientFavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoriteProfessionalsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Избранное')),
      body: favorites.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _FavoritesError(
          onRetry: () =>
              ref.invalidate(favoriteProfessionalsControllerProvider),
        ),
        data: (state) => state.items.isEmpty
            ? const _EmptyFavorites()
            : RefreshIndicator(
                onRefresh: ref
                    .read(favoriteProfessionalsControllerProvider.notifier)
                    .refresh,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  itemCount: state.items.length + (state.hasNext ? 1 : 0),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    if (index == state.items.length) {
                      return Center(
                        child: TextButton(
                          onPressed: state.loadingMore
                              ? null
                              : ref
                                    .read(
                                      favoriteProfessionalsControllerProvider
                                          .notifier,
                                    )
                                    .loadMore,
                          child: state.loadingMore
                              ? const SizedBox.square(
                                  dimension: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Показать ещё'),
                        ),
                      );
                    }
                    final professional = state.items[index];
                    return ProfessionalCard(
                      professional: professional,
                      onTap: () => context.push(
                        AppRoutes.professionalDetails(professional.id),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}

class _FavoritesError extends StatelessWidget {
  const _FavoritesError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48),
          const SizedBox(height: 12),
          const Text('Не удалось загрузить избранное'),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Повторить')),
        ],
      ),
    ),
  );
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 24, 32, 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                size: 44,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Пока ничего не добавлено',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(
              'Сохраняйте понравившихся мастеров и студии, '
              'чтобы быстро вернуться к ним позже.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              key: const Key('favorites-open-search'),
              onPressed: () => context.go(AppRoutes.clientSearch),
              icon: const Icon(Icons.search_rounded),
              label: const Text('Найти мастера'),
            ),
          ],
        ),
      ),
    );
  }
}
