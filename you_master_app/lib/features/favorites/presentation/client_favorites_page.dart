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
    final professionals = ref.watch(favoriteProfessionalsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Избранное')),
      body: professionals.isEmpty
          ? const _EmptyFavorites()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              itemCount: professionals.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final professional = professionals[index];
                return ProfessionalCard(
                  professional: professional,
                  onTap: () => context.push(
                    AppRoutes.professionalDetails(professional.id),
                  ),
                );
              },
            ),
    );
  }
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
