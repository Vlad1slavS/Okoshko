import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:you_master_app/app/router/app_routes.dart';
import 'package:you_master_app/design_system/theme/app_colors.dart';
import 'package:you_master_app/features/favorites/presentation/widgets/favorite_toggle.dart';
import 'package:you_master_app/features/professional_details/domain/professional_details.dart';
import 'package:you_master_app/features/professional_details/presentation/state/professional_details_providers.dart';
import 'package:you_master_app/features/professional_details/presentation/widgets/booking_bottom_bar.dart';
import 'package:you_master_app/features/professional_details/presentation/widgets/portfolio_section.dart';
import 'package:you_master_app/features/professional_details/presentation/widgets/professional_overview.dart';
import 'package:you_master_app/features/professional_details/presentation/widgets/reviews_and_about.dart';
import 'package:you_master_app/features/professional_details/presentation/widgets/services_section.dart';

class ProfessionalDetailsPage extends ConsumerStatefulWidget {
  const ProfessionalDetailsPage({required this.professionalId, super.key});

  final String professionalId;

  @override
  ConsumerState<ProfessionalDetailsPage> createState() =>
      _ProfessionalDetailsPageState();
}

class _ProfessionalDetailsPageState
    extends ConsumerState<ProfessionalDetailsPage> {
  String _selectedCategory = 'Все';
  String? _selectedServiceId = 'manicure-coated';

  @override
  Widget build(BuildContext context) {
    final detailsAsync = ref.watch(
      professionalDetailsProvider(widget.professionalId),
    );
    final page = detailsAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, size: 48),
                const SizedBox(height: 12),
                const Text('Не удалось загрузить профиль'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.invalidate(
                    professionalDetailsProvider(widget.professionalId),
                  ),
                  child: const Text('Повторить'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: _buildDetails,
    );

    return _CenteredDetailsFrame(child: page);
  }

  Widget _buildDetails(ProfessionalDetails details) {
    final selectedService = details.services
        .where((service) => service.id == _selectedServiceId)
        .firstOrNull;

    return Scaffold(
      body: CustomScrollView(
        key: PageStorageKey('professional-${details.id}-scroll'),
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 250,
            backgroundColor: AppColors.surface,
            surfaceTintColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.all(7),
              child: _CircleAction(
                icon: Icons.arrow_back_rounded,
                tooltip: 'Назад',
                onPressed: _goBack,
              ),
            ),
            actions: [
              _CircleAction(
                icon: Icons.ios_share_rounded,
                tooltip: 'Поделиться',
                onPressed: () => _showMessage('Ссылка на профиль скопирована'),
              ),
              const SizedBox(width: 8),
              FavoriteToggle(
                professionalId: details.id,
                builder: (context, isFavorite, onTap) => _CircleAction(
                  icon: isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFavorite ? AppColors.primary : AppColors.textPrimary,
                  tooltip: 'Избранное',
                  onPressed: onTap,
                ),
              ),
              const SizedBox(width: 12),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 68, bottom: 16),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(details.coverAsset, fit: BoxFit.cover),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black26, Colors.transparent],
                      ),
                    ),
                  ),
                  const Positioned(
                    right: 14,
                    bottom: 14,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        child: Text(
                          '1/7',
                          style: TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: ProfessionalOverview(details: details)),
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
          SliverToBoxAdapter(
            child: ServicesSection(
              details: details,
              selectedCategory: _selectedCategory,
              selectedServiceId: _selectedServiceId,
              onCategorySelected: (value) =>
                  setState(() => _selectedCategory = value),
              onServiceSelected: (service) =>
                  setState(() => _selectedServiceId = service.id),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primaryContainer),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.card_giftcard_rounded, color: AppColors.primary),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Приведи подругу и получите скидку 10% на услугу',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: PortfolioSection(assets: details.portfolioAssets),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
          SliverToBoxAdapter(child: ReviewsAndAbout(details: details)),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
      bottomNavigationBar: BookingBottomBar(
        service: selectedService,
        onPressed: () =>
            _showMessage('Выбор даты и времени добавим следующим экраном'),
      ),
    );
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.clientHome);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color = AppColors.textPrimary,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, color: color),
      ),
    );
  }
}

class _CenteredDetailsFrame extends StatelessWidget {
  const _CenteredDetailsFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.sizeOf(context).width <= 600) return child;

    return ColoredBox(
      color: const Color(0xFFF4F2F3),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              boxShadow: [BoxShadow(color: Color(0x18000000), blurRadius: 28)],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
