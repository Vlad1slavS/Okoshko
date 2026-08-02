import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:you_master_app/app/router/app_routes.dart';
import 'package:you_master_app/design_system/theme/app_colors.dart';
import 'package:you_master_app/features/client_home/presentation/widgets/home_category_selector.dart';
import 'package:you_master_app/features/client_home/presentation/widgets/professional_card.dart';
import 'package:you_master_app/features/client_search/presentation/state/client_search_controller.dart';
import 'package:you_master_app/features/client_search/presentation/state/client_search_state.dart';
import 'package:you_master_app/features/client_search/presentation/widgets/search_filters_sheet.dart';

class ClientSearchPage extends ConsumerStatefulWidget {
  const ClientSearchPage({super.key});

  @override
  ConsumerState<ClientSearchPage> createState() => _ClientSearchPageState();
}

class _ClientSearchPageState extends ConsumerState<ClientSearchPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(clientSearchControllerProvider).query,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(searchResultsProvider);
    final searchState = ref.watch(clientSearchControllerProvider);
    final hasActiveFilters =
        searchState.availableToday || searchState.minimumRating > 0;

    ref.listen(clientSearchControllerProvider.select((state) => state.query), (
      previous,
      next,
    ) {
      if (_searchController.text != next) {
        _searchController.value = TextEditingValue(
          text: next,
          selection: TextSelection.collapsed(offset: next.length),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          key: const PageStorageKey('client-search-scroll'),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 25),
                    TextField(
                      key: const Key('client-search-field'),
                      controller: _searchController,
                      autofocus: false,
                      textInputAction: TextInputAction.search,
                      onChanged: ref
                          .read(clientSearchControllerProvider.notifier)
                          .setQuery,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Услуга, мастер или студия',
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        suffixIcon: _searchController.text.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Очистить',
                                onPressed: () {
                                  _searchController.clear();
                                  ref
                                      .read(
                                        clientSearchControllerProvider.notifier,
                                      )
                                      .setQuery('');
                                  setState(() {});
                                },
                                icon: const Icon(Icons.close_rounded, size: 20),
                              ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    HomeCategorySelector(
                      selectedCategory: searchState.category,
                      onSelected: ref
                          .read(clientSearchControllerProvider.notifier)
                          .selectCategory,
                    ),
                    const SizedBox(height: 14),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FilterChip(
                            avatar: const Icon(Icons.tune_rounded, size: 18),
                            label: const Text('Фильтры'),
                            selected: hasActiveFilters,
                            onSelected: (_) => _showFilters(context),
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('Сегодня'),
                            selected: searchState.availableToday,
                            onSelected: ref
                                .read(clientSearchControllerProvider.notifier)
                                .setAvailableToday,
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('Рейтинг 4.5+'),
                            selected: searchState.minimumRating == 4.5,
                            onSelected: (selected) => ref
                                .read(clientSearchControllerProvider.notifier)
                                .setMinimumRating(selected ? 4.5 : 0),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            results.isEmpty
                                ? 'Ничего не найдено'
                                : 'Найдено: ${results.length}',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<SearchSort>(
                            value: searchState.sort,
                            isDense: true,
                            borderRadius: BorderRadius.circular(12),
                            items: [
                              for (final sort in SearchSort.values)
                                DropdownMenuItem(
                                  value: sort,
                                  child: Text(
                                    sort.label,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                ref
                                    .read(
                                      clientSearchControllerProvider.notifier,
                                    )
                                    .selectSort(value);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            if (results.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _SearchEmptyState(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                sliver: SliverList.separated(
                  itemCount: results.length,
                  itemBuilder: (context, index) => ProfessionalCard(
                    professional: results[index],
                    onTap: () => context.push(
                      AppRoutes.professionalDetails(results[index].id),
                    ),
                  ),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showFilters(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => const SearchFiltersSheet(),
    );
  }
}

class _SearchEmptyState extends StatelessWidget {
  const _SearchEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 56,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 14),
            Text(
              'Попробуйте изменить запрос',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Выберите другую категорию или сбросьте фильтры.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
