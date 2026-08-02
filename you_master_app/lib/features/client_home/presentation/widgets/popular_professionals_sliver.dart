import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:you_master_app/app/router/app_routes.dart';
import 'package:you_master_app/design_system/theme/app_colors.dart';
import 'package:you_master_app/features/client_home/domain/professional_preview.dart';
import 'package:you_master_app/features/client_home/presentation/widgets/professional_card.dart';

class PopularProfessionalsSliver extends StatelessWidget {
  const PopularProfessionalsSliver({
    required this.professionals,
    required this.onRetry,
    required this.contentMaxWidth,
    super.key,
  });

  final AsyncValue<List<ProfessionalPreview>> professionals;
  final VoidCallback onRetry;
  final double contentMaxWidth;

  @override
  Widget build(BuildContext context) {
    return professionals.when(
      skipLoadingOnRefresh: true,
      data: (items) => items.isEmpty
          ? const SliverToBoxAdapter(child: _PopularEmptyState())
          : _ProfessionalsList(
              professionals: items,
              contentMaxWidth: contentMaxWidth,
            ),
      error: (error, stackTrace) =>
          SliverToBoxAdapter(child: _PopularErrorState(onRetry: onRetry)),
      loading: () => const _PopularSkeletonList(),
    );
  }
}

class _ProfessionalsList extends StatelessWidget {
  const _ProfessionalsList({
    required this.professionals,
    required this.contentMaxWidth,
  });

  final List<ProfessionalPreview> professionals;
  final double contentMaxWidth;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.crossAxisExtent;
        final contentWidth = width.clamp(0.0, contentMaxWidth);
        final horizontalMargin = (width - contentWidth) / 2;

        return SliverPadding(
          padding: EdgeInsets.fromLTRB(
            20 + horizontalMargin,
            12,
            20 + horizontalMargin,
            20,
          ),
          sliver: SliverList.separated(
            itemCount: professionals.length,
            itemBuilder: (context, index) => ProfessionalCard(
              professional: professionals[index],
              onTap: () => context.push(
                AppRoutes.professionalDetails(professionals[index].id),
              ),
            ),
            separatorBuilder: (context, index) => const SizedBox(height: 12),
          ),
        );
      },
    );
  }
}

class _PopularSkeletonList extends StatelessWidget {
  const _PopularSkeletonList();

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      sliver: SliverList.separated(
        itemCount: 3,
        itemBuilder: (context, index) => const _PopularSkeletonCard(),
        separatorBuilder: (context, index) => const SizedBox(height: 12),
      ),
    );
  }
}

class _PopularSkeletonCard extends StatefulWidget {
  const _PopularSkeletonCard();

  @override
  State<_PopularSkeletonCard> createState() => _PopularSkeletonCardState();
}

class _PopularSkeletonCardState extends State<_PopularSkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacity = Tween<double>(
      begin: 0.45,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        key: const Key('popular-professional-skeleton'),
        height: 132,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            const _SkeletonBox(width: 110, height: 110, radius: 14),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _SkeletonBox(width: 145, height: 13),
                  SizedBox(height: 10),
                  _SkeletonBox(height: 10),
                  SizedBox(height: 8),
                  _SkeletonBox(width: 105, height: 10),
                  SizedBox(height: 16),
                  _SkeletonBox(width: 72, height: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    this.width = double.infinity,
    required this.height,
    this.radius = 5,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _PopularErrorState extends StatelessWidget {
  const _PopularErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 38, 24, 46),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 44,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            'Не удалось загрузить мастеров',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Проверьте соединение и попробуйте ещё раз.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          OutlinedButton(onPressed: onRetry, child: const Text('Повторить')),
        ],
      ),
    );
  }
}

class _PopularEmptyState extends StatelessWidget {
  const _PopularEmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 38, 24, 46),
      child: Column(
        children: [
          const Icon(
            Icons.person_search_outlined,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            'Пока не нашли мастеров этой категории рядом',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Посмотрите всех специалистов в поиске.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: () => context.go(AppRoutes.clientSearch),
            child: const Text('Открыть поиск'),
          ),
        ],
      ),
    );
  }
}
