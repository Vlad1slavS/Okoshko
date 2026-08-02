import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:you_master_app/features/client_search/presentation/state/client_search_controller.dart';

class SearchFiltersSheet extends ConsumerStatefulWidget {
  const SearchFiltersSheet({super.key});

  @override
  ConsumerState<SearchFiltersSheet> createState() => _SearchFiltersSheetState();
}

class _SearchFiltersSheetState extends ConsumerState<SearchFiltersSheet> {
  late bool _availableToday;
  late double _minimumRating;

  @override
  void initState() {
    super.initState();
    final current = ref.read(clientSearchControllerProvider);
    _availableToday = current.availableToday;
    _minimumRating = current.minimumRating;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Фильтры',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _availableToday = false;
                      _minimumRating = 0;
                    });
                  },
                  child: const Text('Сбросить'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Рейтинг',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                for (final rating in const [0.0, 4.0, 4.5, 4.8])
                  ChoiceChip(
                    label: Text(rating == 0 ? 'Любой' : '$rating+'),
                    selected: _minimumRating == rating,
                    onSelected: (_) => setState(() => _minimumRating = rating),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Есть запись сегодня'),
              value: _availableToday,
              onChanged: (value) => setState(() => _availableToday = value),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                final controller = ref.read(
                  clientSearchControllerProvider.notifier,
                );
                controller
                  ..setMinimumRating(_minimumRating)
                  ..setAvailableToday(_availableToday);
                Navigator.of(context).pop();
              },
              child: const Text('Показать результаты'),
            ),
          ],
        ),
      ),
    );
  }
}
