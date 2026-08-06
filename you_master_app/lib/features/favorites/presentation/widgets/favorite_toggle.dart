import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:you_master_app/design_system/widgets/app_toast.dart';
import 'package:you_master_app/features/favorites/presentation/state/favorites_controller.dart';

typedef FavoriteToggleBuilder =
    Widget Function(BuildContext context, bool isFavorite, VoidCallback onTap);

class FavoriteToggle extends ConsumerWidget {
  const FavoriteToggle({
    required this.professionalId,
    required this.builder,
    super.key,
  });

  final String professionalId;
  final FavoriteToggleBuilder builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(
      favoritesControllerProvider.select(
        (state) => state.ids.contains(professionalId),
      ),
    );

    return builder(context, isFavorite, () async {
      final success = await ref
          .read(favoritesControllerProvider.notifier)
          .toggle(professionalId);
      if (!success && context.mounted) {
        AppToast.error(
          context,
          title: 'Не удалось изменить избранное',
          message: 'Проверьте подключение и попробуйте ещё раз.',
        );
      }
    });
  }
}
