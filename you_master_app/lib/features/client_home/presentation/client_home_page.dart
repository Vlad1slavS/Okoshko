import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:you_master_app/app/router/app_routes.dart';
import 'package:you_master_app/design_system/theme/app_colors.dart';
import 'package:you_master_app/features/client_location/presentation/state/client_location_controller.dart';
import 'package:you_master_app/features/client_home/presentation/state/client_home_controller.dart';
import 'package:you_master_app/features/client_home/presentation/widgets/home_category_selector.dart';
import 'package:you_master_app/features/client_home/presentation/widgets/home_promo_banner.dart';
import 'package:you_master_app/features/client_home/presentation/widgets/popular_professionals_sliver.dart';
import 'package:you_master_app/features/client_search/presentation/state/client_search_controller.dart';

class ClientHomePage extends ConsumerWidget {
  const ClientHomePage({super.key});

  static const _contentMaxWidth = 1180.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(clientHomeControllerProvider);
    final city = ref.watch(clientLocationProvider);
    final popularQuery = (city: city, category: state.category);
    final professionals = ref.watch(popularProfessionalsProvider(popularQuery));
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(
          context,
        ).textTheme.apply(fontFamily: 'SanFrancisco'),
      ),
      child: (Scaffold(
        body: SafeArea(
          bottom: false,
          child: CustomScrollView(
            key: const Key('client-home-scroll'),
            slivers: [
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: _contentMaxWidth,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _HomeHeader(city: city),
                          const SizedBox(height: 22),
                          const _SearchField(),
                          const SizedBox(height: 22),
                          HomeCategorySelector(
                            selectedCategory: state.category,
                            onSelected: ref
                                .read(clientHomeControllerProvider.notifier)
                                .selectCategory,
                          ),
                          const SizedBox(height: 6),
                          const HomePromoBanner(),
                          const SizedBox(height: 28),
                          const _SectionHeader(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              PopularProfessionalsSliver(
                professionals: professionals,
                contentMaxWidth: _contentMaxWidth,
                onRetry: () =>
                    ref.invalidate(popularProfessionalsProvider(popularQuery)),
              ),
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: _contentMaxWidth,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.fromLTRB(20, 8, 20, 28),
                      child: _TrustPanel(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}

class _HomeHeader extends ConsumerWidget {
  const _HomeHeader({required this.city});

  final String city;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Image.asset('assets/images/home/logo.png', width: 100),
          ),
        ),
        TextButton(
          key: const Key('city-selector'),
          onPressed: () => _showCityPicker(context, ref),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on_outlined),
              const SizedBox(width: 2),
              Text(city),
            ],
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          tooltip: 'Уведомления',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Новых уведомлений пока нет')),
            );
          },
          icon: const Badge(
            smallSize: 7,
            child: Icon(Icons.notifications_none_rounded),
          ),
        ),
      ],
    );
  }

  Future<void> _showCityPicker(BuildContext context, WidgetRef ref) async {
    final city = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => const _CityPicker(),
    );
    if (city != null) {
      ref.read(clientLocationProvider.notifier).selectCity(city);
    }
  }
}

class _CityPicker extends StatelessWidget {
  const _CityPicker();

  @override
  Widget build(BuildContext context) {
    const cities = ['Чита'];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Выберите город',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            for (final city in cities)
              ListTile(
                leading: const Icon(Icons.location_city_outlined),
                title: Text(city),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.of(context).pop(city),
              ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends ConsumerStatefulWidget {
  const _SearchField();

  @override
  ConsumerState<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends ConsumerState<_SearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(clientHomeControllerProvider).searchDraft,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      clientHomeControllerProvider.select((state) => state.searchDraft),
      (previous, next) {
        if (_controller.text != next) {
          _controller.value = TextEditingValue(
            text: next,
            selection: TextSelection.collapsed(offset: next.length),
          );
        }
      },
    );

    return TextField(
      key: const Key('home-search-field'),
      controller: _controller,
      style: const TextStyle(fontSize: 14),
      onChanged: ref.read(clientHomeControllerProvider.notifier).setSearchDraft,
      onSubmitted: (_) => _openSearch(),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Поиск услуг, мастеров, студий…',
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        suffixIcon: IconButton(
          key: const Key('home-filter-button'),
          tooltip: 'Фильтры',
          onPressed: () => _showFilters(context),
          icon: const Icon(Icons.tune_rounded, size: 22),
        ),
      ),
    );
  }

  Future<void> _showFilters(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => const _FiltersSheet(),
    );
  }

  void _openSearch() {
    final homeState = ref.read(clientHomeControllerProvider);
    ref
        .read(clientSearchControllerProvider.notifier)
        .initializeFromHome(
          query: homeState.searchDraft,
          category: homeState.category,
        );
    context.go(AppRoutes.clientSearch);
  }
}

class _FiltersSheet extends StatefulWidget {
  const _FiltersSheet();

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  double _distance = 5;
  bool _availableToday = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Фильтры', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            Text('Расстояние: до ${_distance.round()} км'),
            Slider(
              value: _distance,
              min: 1,
              max: 20,
              divisions: 19,
              onChanged: (value) => setState(() => _distance = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Есть запись сегодня'),
              value: _availableToday,
              onChanged: (value) => setState(() => _availableToday = value),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Показать результаты'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends ConsumerWidget {
  const _SectionHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Популярные мастера рядом',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontSize: 16),
          ),
        ),
        TextButton(
          key: const Key('show-all-professionals'),
          onPressed: () {
            final homeState = ref.read(clientHomeControllerProvider);
            ref
                .read(clientSearchControllerProvider.notifier)
                .initializeFromHome(
                  query: homeState.searchDraft,
                  category: homeState.category,
                );
            context.go(AppRoutes.clientSearch);
          },
          child: const Text('Смотреть все'),
        ),
      ],
    );
  }
}

class _TrustPanel extends StatelessWidget {
  const _TrustPanel();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _TrustItem(
                  icon: Icons.verified_user_outlined,
                  title: 'Проверенные мастера',
                  description: 'Все специалисты проходят проверку',
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: _TrustItem(
                  icon: Icons.calendar_month_outlined,
                  title: 'Удобная запись',
                  description: 'Онлайн-запись 24/7 в несколько кликов',
                ),
              ),
            ],
          ),
          SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _TrustItem(
                  icon: Icons.star_border_rounded,
                  title: 'Честные отзывы',
                  description: 'Реальные отзывы от наших клиентов',
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: _TrustItem(
                  icon: Icons.sell_outlined,
                  title: 'Прозрачные цены',
                  description: 'Без скрытых платежей и наценок',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrustItem extends StatelessWidget {
  const _TrustItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFFFFF2F5),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            height: 1.35,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
