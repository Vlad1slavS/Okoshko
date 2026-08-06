import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:you_master_app/design_system/theme/app_colors.dart';

enum AppShellMode { client, professional }

class AppShell extends StatelessWidget {
  const AppShell({
    required this.mode,
    required this.navigationShell,
    super.key,
  });

  final AppShellMode mode;
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final destinations = mode == AppShellMode.client
        ? _clientDestinations
        : _professionalDestinations;
    final shell = Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        height: 72,
        indicatorColor: Colors.transparent,
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) async {
          if (mode == AppShellMode.professional && index == 2) {
            await _showProfessionalQuickActions(context, navigationShell);
            return;
          }
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: [
          for (var index = 0; index < destinations.length; index++)
            NavigationDestination(
              icon: mode == AppShellMode.professional && index == 2
                  ? const _ProfessionalCreateButton()
                  : Icon(destinations[index].icon),
              selectedIcon: mode == AppShellMode.professional && index == 2
                  ? const _ProfessionalCreateButton()
                  : Icon(destinations[index].selectedIcon),
              label: destinations[index].label,
            ),
        ],
      ),
    );

    final isDesktop = MediaQuery.sizeOf(context).width > 600;
    if (!isDesktop) {
      return shell;
    }

    return ColoredBox(
      color: const Color(0xFFFFFFFF),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              border: Border.symmetric(
                vertical: BorderSide(color: Color(0xFFE2DEE0)),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(19, 80, 80, 80),
                  blurRadius: 28,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: shell,
          ),
        ),
      ),
    );
  }

  Future<void> _showProfessionalQuickActions(
    BuildContext context,
    StatefulNavigationShell navigationShell,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Быстрое действие',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              _QuickActionTile(
                icon: Icons.person_add_alt_rounded,
                title: 'Добавить запись',
                onTap: () {
                  Navigator.pop(sheetContext);
                  navigationShell.goBranch(1);
                },
              ),
              _QuickActionTile(
                icon: Icons.access_time_rounded,
                title: 'Открыть время для записи',
                onTap: () {
                  Navigator.pop(sheetContext);
                  navigationShell.goBranch(1);
                },
              ),
              _QuickActionTile(
                icon: Icons.design_services_outlined,
                title: 'Добавить услугу',
                onTap: () => _showUnavailable(sheetContext),
              ),
              _QuickActionTile(
                icon: Icons.local_offer_outlined,
                title: 'Создать акцию',
                onTap: () => _showUnavailable(sheetContext),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUnavailable(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('Раздел появится в следующей версии')),
    );
  }
}

class _ProfessionalCreateButton extends StatelessWidget {
  const _ProfessionalCreateButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 45,
      height: 45,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x33FF426F),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

class _ShellDestination {
  const _ShellDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const _clientDestinations = [
  _ShellDestination(
    label: 'Главная',
    icon: Icons.home_rounded,
    selectedIcon: Icons.home_rounded,
  ),
  _ShellDestination(
    label: 'Поиск',
    icon: Icons.search_outlined,
    selectedIcon: Icons.search_rounded,
  ),
  _ShellDestination(
    label: 'Записи',
    icon: Icons.calendar_today_outlined,
    selectedIcon: Icons.calendar_month_rounded,
  ),
  _ShellDestination(
    label: 'Избранное',
    icon: Icons.favorite_outline_rounded,
    selectedIcon: Icons.favorite_rounded,
  ),
  _ShellDestination(
    label: 'Профиль',
    icon: Icons.person_outline_rounded,
    selectedIcon: Icons.person_rounded,
  ),
];

const _professionalDestinations = [
  _ShellDestination(
    label: 'Главная',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home_rounded,
  ),
  _ShellDestination(
    label: 'Календарь',
    icon: Icons.calendar_month_outlined,
    selectedIcon: Icons.calendar_month_rounded,
  ),
  _ShellDestination(
    label: '',
    icon: Icons.add_circle_outline_rounded,
    selectedIcon: Icons.add_circle_rounded,
  ),
  _ShellDestination(
    label: 'Клиенты',
    icon: Icons.people_outline_rounded,
    selectedIcon: Icons.people_rounded,
  ),
  _ShellDestination(
    label: 'Кабинет',
    icon: Icons.person_outline_rounded,
    selectedIcon: Icons.person_rounded,
  ),
];
