import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:you_master_app/app/router/app_routes.dart';
import 'package:you_master_app/design_system/theme/app_colors.dart';
import 'package:you_master_app/features/client_location/presentation/state/client_location_controller.dart';
import 'package:you_master_app/features/client_profile/presentation/state/client_profile_controller.dart';
import 'package:you_master_app/features/client_profile/presentation/widgets/become_professional_card.dart';
import 'package:you_master_app/features/client_profile/presentation/widgets/edit_profile_sheet.dart';
import 'package:you_master_app/features/client_profile/presentation/widgets/profile_header.dart';
import 'package:you_master_app/features/client_profile/presentation/widgets/profile_menu_section.dart';
import 'package:you_master_app/features/client_profile/presentation/widgets/profile_stats.dart';

class ClientProfilePage extends ConsumerWidget {
  const ClientProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(clientProfileControllerProvider);
    final city = ref.watch(clientLocationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: [
          IconButton(
            tooltip: 'Настройки',
            onPressed: () => _showUnavailable(context),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: ListView(
        key: const PageStorageKey('client-profile-scroll'),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          ProfileHeader(
            profile: profile,
            onEdit: () => _editProfile(context, ref),
          ),
          const SizedBox(height: 18),
          ProfileStats(
            appointments: profile.upcomingAppointments,
            favorites: profile.favoriteCount,
          ),
          const SizedBox(height: 26),
          ProfileMenuSection(
            title: 'Мой аккаунт',
            children: [
              ProfileMenuTile(
                icon: Icons.calendar_month_outlined,
                title: 'Мои записи',
                onTap: () => context.go(AppRoutes.clientAppointments),
              ),
              ProfileMenuTile(
                icon: Icons.favorite_outline_rounded,
                title: 'Избранное',
                onTap: () => context.go(AppRoutes.clientFavorites),
              ),
              ProfileMenuTile(
                icon: Icons.star_outline_rounded,
                title: 'Мои отзывы',
                onTap: () => _showUnavailable(context),
              ),
              ProfileMenuTile(
                icon: Icons.local_offer_outlined,
                title: 'Промокоды и бонусы',
                onTap: () => _showUnavailable(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ProfileMenuSection(
            title: 'Настройки',
            children: [
              ProfileMenuTile(
                icon: Icons.notifications_none_rounded,
                title: 'Уведомления',
                trailing: Switch(
                  value: profile.notificationsEnabled,
                  onChanged: ref
                      .read(clientProfileControllerProvider.notifier)
                      .setNotificationsEnabled,
                ),
              ),
              ProfileMenuTile(
                icon: Icons.location_on_outlined,
                title: 'Город',
                subtitle: city,
                onTap: () => context.go(AppRoutes.clientHome),
              ),
              ProfileMenuTile(
                icon: Icons.lock_outline_rounded,
                title: 'Безопасность',
                subtitle: 'Телефон подтверждён',
                onTap: () => _showUnavailable(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ProfileMenuSection(
            title: 'Помощь',
            children: [
              ProfileMenuTile(
                icon: Icons.support_agent_rounded,
                title: 'Помощь и поддержка',
                onTap: () => _showUnavailable(context),
              ),
              ProfileMenuTile(
                icon: Icons.info_outline_rounded,
                title: 'О приложении',
                subtitle: 'Версия 1.0.0',
                onTap: () => _showUnavailable(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          BecomeProfessionalCard(
            onPressed: () => context.go(AppRoutes.professionalHome),
          ),
          const SizedBox(height: 24),
          ProfileMenuSection(
            title: 'Аккаунт',
            children: [
              ProfileMenuTile(
                icon: Icons.logout_rounded,
                title: 'Выйти',
                foregroundColor: AppColors.error,
                onTap: () => _confirmLogout(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _editProfile(BuildContext context, WidgetRef ref) async {
    final profile = ref.read(clientProfileControllerProvider);
    final result = await showModalBottomSheet<({String name, String email})>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => EditProfileSheet(profile: profile),
    );

    if (result != null && result.name.trim().isNotEmpty) {
      ref
          .read(clientProfileControllerProvider.notifier)
          .updateProfile(name: result.name, email: result.email);
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выйти из аккаунта?'),
        content: const Text(
          'Чтобы снова управлять записями, потребуется войти по номеру телефона.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Выйти'),
          ),
          const SizedBox(height: 8),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 249, 249, 249),
              foregroundColor: Colors.black,
            ),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      context.go(AppRoutes.entry);
    }
  }

  void _showUnavailable(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Раздел появится в следующей версии')),
    );
  }
}
