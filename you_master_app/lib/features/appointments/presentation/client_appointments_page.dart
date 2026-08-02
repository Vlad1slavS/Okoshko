import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:you_master_app/app/router/app_routes.dart';
import 'package:you_master_app/design_system/theme/app_colors.dart';
import 'package:you_master_app/features/appointments/domain/appointment.dart';
import 'package:you_master_app/features/appointments/presentation/state/appointments_controller.dart';
import 'package:you_master_app/features/appointments/presentation/state/appointments_state.dart';
import 'package:you_master_app/features/appointments/presentation/widgets/appointment_card.dart';

class ClientAppointmentsPage extends ConsumerWidget {
  const ClientAppointmentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointments = ref.watch(appointmentsControllerProvider);
    final selectedTab = ref.watch(appointmentsSelectedTabProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Мои записи')),
      body: Column(
        children: [
          _AppointmentsTabs(selectedTab: selectedTab),
          const Divider(height: 1),
          Expanded(
            child: appointments.when(
              loading: () => const _AppointmentsLoading(),
              error: (error, stackTrace) => _AppointmentsError(
                onRetry: ref
                    .read(appointmentsControllerProvider.notifier)
                    .refresh,
              ),
              data: (state) => _AppointmentsContent(state: state),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentsTabs extends ConsumerWidget {
  const _AppointmentsTabs({required this.selectedTab});

  final AppointmentsTab selectedTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        children: [
          for (final tab in AppointmentsTab.values)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: ChoiceChip(
                  key: Key('appointments-tab-${tab.name}'),
                  label: SizedBox(
                    width: double.infinity,
                    child: Text(
                      tab.label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  selected: selectedTab == tab,
                  showCheckmark: false,
                  onSelected: (_) => ref
                      .read(appointmentsControllerProvider.notifier)
                      .selectTab(tab),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AppointmentsContent extends ConsumerWidget {
  const _AppointmentsContent({required this.state});

  final AppointmentsState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.items.isEmpty) {
      return RefreshIndicator(
        onRefresh: ref.read(appointmentsControllerProvider.notifier).refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.52,
              child: _AppointmentsEmpty(tab: state.selectedTab),
            ),
          ],
        ),
      );
    }

    final showNearest = state.selectedTab == AppointmentsTab.upcoming;
    return RefreshIndicator(
      onRefresh: ref.read(appointmentsControllerProvider.notifier).refresh,
      child: ListView.separated(
        key: PageStorageKey('appointments-${state.selectedTab.name}'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
        itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          if (index == state.items.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final appointment = state.items[index];
          final isNearest = showNearest && index == 0;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isNearest) ...[
                Text(
                  'Ближайшая запись',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
              ] else if (showNearest && index == 1) ...[
                Text(
                  'Следующие записи',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
              ],
              AppointmentCard(
                appointment: appointment,
                isNearest: isNearest,
                onProfessionalTap: () => context.push(
                  AppRoutes.professionalDetails(appointment.professionalId),
                ),
                onUiAction: (action) => _showComingSoon(context, action),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showComingSoon(BuildContext context, String action) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('$action появится на следующем этапе')),
      );
  }
}

class _AppointmentsLoading extends StatelessWidget {
  const _AppointmentsLoading();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
      itemCount: 3,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) => Container(
        key: const Key('appointment-skeleton'),
        height: 220,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F5F6),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
      ),
    );
  }
}

class _AppointmentsError extends StatelessWidget {
  const _AppointmentsError({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 56,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Не удалось загрузить записи',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Проверьте подключение и попробуйте ещё раз.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: onRetry, child: const Text('Повторить')),
          ],
        ),
      ),
    );
  }
}

class _AppointmentsEmpty extends StatelessWidget {
  const _AppointmentsEmpty({required this.tab});

  final AppointmentsTab tab;

  @override
  Widget build(BuildContext context) {
    final description = switch (tab) {
      AppointmentsTab.upcoming => 'Найдите мастера и выберите удобное время.',
      AppointmentsTab.completed => 'Здесь появится история ваших посещений.',
      AppointmentsTab.cancelled => 'У вас нет отменённых записей.',
    };
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_month_outlined,
                size: 42,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Здесь пока пусто',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
