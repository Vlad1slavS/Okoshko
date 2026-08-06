import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:you_master_app/app/router/app_routes.dart';
import 'package:you_master_app/design_system/theme/app_colors.dart';
import 'package:you_master_app/features/professional_calendar/presentation/state/professional_calendar_controller.dart';
import 'package:you_master_app/features/professional_calendar/presentation/widgets/calendar_appointment_card.dart';
import 'package:you_master_app/features/professional_calendar/presentation/widgets/professional_month_calendar.dart';

class ProfessionalCalendarPage extends ConsumerWidget {
  const ProfessionalCalendarPage({super.key});

  static const _weekdays = [
    'Понедельник',
    'Вторник',
    'Среда',
    'Четверг',
    'Пятница',
    'Суббота',
    'Воскресенье',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(professionalCalendarControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Расписание'),
        actions: [
          IconButton(
            tooltip: 'Настройки расписания',
            onPressed: () => context.push(AppRoutes.professionalSchedule),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _CalendarError(
          onRetry: () => ref.invalidate(professionalCalendarControllerProvider),
        ),
        data: (calendarState) => RefreshIndicator(
          onRefresh: ref
              .read(professionalCalendarControllerProvider.notifier)
              .refresh,
          child: ListView(
            key: const PageStorageKey('professional-calendar-scroll'),
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              ProfessionalMonthCalendar(
                month: calendarState.month,
                selectedDate: calendarState.selectedDate,
                appointments: calendarState.calendar.appointments,
                availabilityStarts: calendarState.calendar.availabilityStarts,
                onDateSelected: ref
                    .read(professionalCalendarControllerProvider.notifier)
                    .selectDate,
                onPreviousMonth: () => ref
                    .read(professionalCalendarControllerProvider.notifier)
                    .changeMonth(-1),
                onNextMonth: () => ref
                    .read(professionalCalendarControllerProvider.notifier)
                    .changeMonth(1),
              ),
              const SizedBox(height: 22),
              Text(
                '${_weekdays[calendarState.selectedDate.weekday - 1]}, ${calendarState.selectedDate.day}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              if (calendarState.selectedAppointments.isEmpty &&
                  calendarState.selectedAvailabilityStarts.isEmpty)
                const _EmptyDay()
              else
                for (final appointment
                    in calendarState.selectedAppointments) ...[
                  CalendarAppointmentCard(appointment: appointment),
                  const SizedBox(height: 10),
                ],
              if (calendarState.selectedAvailabilityStarts.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Открытые окна',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final start
                        in calendarState.selectedAvailabilityStarts)
                      Chip(
                        avatar: const Icon(
                          Icons.schedule_rounded,
                          size: 17,
                          color: AppColors.success,
                        ),
                        label: Text(
                          start.restrictedServiceName == null
                              ? start.time
                              : '${start.time} · ${start.restrictedServiceName}',
                        ),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => _unavailable(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Добавить перерыв'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(50),
                  side: BorderSide.none,
                  backgroundColor: AppColors.primaryContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _unavailable(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Настройку расписания добавим следующим этапом'),
      ),
    );
  }
}

class _EmptyDay extends StatelessWidget {
  const _EmptyDay();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.event_available_rounded,
            color: AppColors.textSecondary,
            size: 34,
          ),
          SizedBox(height: 8),
          Text(
            'На этот день записей нет',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _CalendarError extends StatelessWidget {
  const _CalendarError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 14),
            const Text(
              'Не удалось загрузить календарь',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Повторить')),
          ],
        ),
      ),
    );
  }
}
