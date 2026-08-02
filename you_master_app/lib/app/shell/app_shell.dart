import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: [
          for (final destination in destinations)
            NavigationDestination(
              icon: Icon(destination.icon),
              selectedIcon: Icon(destination.selectedIcon),
              label: destination.label,
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
    label: 'Создать',
    icon: Icons.add_circle_outline_rounded,
    selectedIcon: Icons.add_circle_rounded,
  ),
  _ShellDestination(
    label: 'Сообщения',
    icon: Icons.chat_bubble_outline_rounded,
    selectedIcon: Icons.chat_bubble_rounded,
  ),
  _ShellDestination(
    label: 'Кабинет',
    icon: Icons.person_outline_rounded,
    selectedIcon: Icons.person_rounded,
  ),
];
