import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:you_master_app/design_system/theme/app_colors.dart';
import 'package:you_master_app/design_system/widgets/professional_avatar.dart';
import 'package:you_master_app/features/client_home/domain/professional_preview.dart';
import 'package:you_master_app/features/favorites/presentation/state/favorites_controller.dart';

class ProfessionalCard extends ConsumerWidget {
  const ProfessionalCard({required this.professional, this.onTap, super.key});

  final ProfessionalPreview professional;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(
      favoritesControllerProvider.select(
        (favoriteIds) => favoriteIds.contains(professional.id),
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfessionalAvatar(
                size: 110,
                imageUrl: professional.imageUrl,
                imageAsset: professional.imageAsset,
                borderRadius: BorderRadius.circular(14),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            professional.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Tooltip(
                          message: isFavorite
                              ? 'Убрать из избранного'
                              : 'Добавить в избранное',
                          child: InkWell(
                            key: Key('favorite-${professional.id}'),
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => ref
                                .read(favoritesControllerProvider.notifier)
                                .toggle(professional.id),
                            child: Padding(
                              padding: const EdgeInsets.all(2),
                              child: Icon(
                                isFavorite
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                size: 22,
                                color: isFavorite
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (professional.badge case final badge?) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF5D6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (badge == 'Топ мастер') ...[
                              const Icon(
                                Icons.star_rounded,
                                size: 14,
                                color: Color(0xFFFFB800),
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              badge,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF8A5A00),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      professional.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            '${professional.rating.toStringAsFixed(1)} '
                            '(${professional.reviewCount} отзывов)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      professional.distanceKm == null
                          ? professional.durationLabel
                          : '${professional.distanceKm!.toStringAsFixed(1)} км от вас'
                                '  •  ${professional.durationLabel}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isNarrow = constraints.maxWidth < 190;
                        final price = Text(
                          'от ${professional.priceFrom} ₽',
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        );
                        final button = FilledButton(
                          onPressed: onTap,
                          style: FilledButton.styleFrom(
                            minimumSize: Size(
                              isNarrow ? double.infinity : 118,
                              42,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                          ),
                          child: const Text('Записаться'),
                        );

                        if (isNarrow) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: price,
                              ),
                              const SizedBox(height: 8),
                              button,
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(child: price),
                            const SizedBox(width: 10),
                            button,
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
