import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:you_master_app/app/router/app_routes.dart';
import 'package:you_master_app/design_system/theme/app_colors.dart';
import 'package:you_master_app/features/professional_home/domain/professional_dashboard.dart';
import 'package:you_master_app/features/professional_home/presentation/state/professional_home_controller.dart';
import 'package:you_master_app/features/professional_home/presentation/widgets/dashboard_recommendation.dart';
import 'package:you_master_app/features/professional_home/presentation/widgets/dashboard_statistics.dart';
import 'package:you_master_app/features/professional_home/presentation/widgets/next_appointment_card.dart';
import 'package:you_master_app/features/professional_home/presentation/widgets/professional_home_header.dart';
import 'package:you_master_app/features/professional_home/presentation/widgets/professional_quick_actions.dart';
import 'package:you_master_app/features/professional_home/presentation/widgets/today_appointments.dart';
import 'package:you_master_app/features/professional_home/presentation/widgets/today_summary.dart';

class ProfessionalHomePage extends ConsumerWidget {
  const ProfessionalHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(professionalHomeControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: dashboard.when(
          data: (data) => _DashboardContent(
            dashboard: data,
            onRefresh: () =>
                ref.read(professionalHomeControllerProvider.notifier).refresh(),
          ),
          loading: () => const _DashboardLoading(),
          error: (error, stackTrace) => _DashboardError(
            onRetry: () => ref.invalidate(professionalHomeControllerProvider),
          ),
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.dashboard, required this.onRefresh});

  final ProfessionalDashboard dashboard;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        key: const PageStorageKey('professional-home-scroll'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
        children: [
          ProfessionalHomeHeader(
            name: dashboard.professionalName,
            onNotificationsPressed: () => _unavailable(context),
          ),
          const SizedBox(height: 18),
          TodaySummary(
            appointmentsCount: dashboard.todayAppointmentsCount,
            revenueLabel: _money(dashboard.todayRevenueMinor),
            revenueChangePercent: dashboard.revenueChangePercent,
            onCalendarPressed: () => context.go(AppRoutes.professionalCalendar),
          ),
          if (dashboard.nextAppointment case final appointment?) ...[
            const SizedBox(height: 24),
            NextAppointmentCard(
              appointment: appointment,
              onTap: () => _unavailable(context),
            ),
          ],
          const SizedBox(height: 24),
          ProfessionalQuickActions(
            onActionPressed: (action) {
              if (action == ProfessionalQuickAction.appointments) {
                context.go(AppRoutes.professionalCalendar);
                return;
              }
              _unavailable(context);
            },
          ),
          const SizedBox(height: 24),
          DashboardRecommendation(onPressed: () => _unavailable(context)),
          const SizedBox(height: 24),
          DashboardStatistics(
            appointments: dashboard.weekAppointmentsCount,
            revenueLabel: _money(dashboard.weekRevenueMinor),
            newClients: dashboard.newClientsCount,
            appointmentsChange: dashboard.appointmentsChangePercent,
            revenueChange: dashboard.revenueChangePercent,
            newClientsChange: dashboard.newClientsChange,
          ),
          const SizedBox(height: 20),
          TodayAppointments(
            appointments: dashboard.todayAppointments,
            onShowAll: () => context.go(AppRoutes.professionalCalendar),
          ),
        ],
      ),
    );
  }

  static String _money(int minor) {
    final value = (minor ~/ 100).toString();
    final buffer = StringBuffer();
    for (var index = 0; index < value.length; index++) {
      if (index > 0 && (value.length - index) % 3 == 0) buffer.write(' ');
      buffer.write(value[index]);
    }
    return '${buffer.toString()} ₽';
  }

  void _unavailable(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Раздел появится в следующей версии')),
    );
  }
}

class _DashboardLoading extends StatelessWidget {
  const _DashboardLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        _Skeleton(width: 230, height: 24),
        SizedBox(height: 8),
        _Skeleton(width: 190, height: 14),
        SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: _Skeleton(height: 132)),
            SizedBox(width: 12),
            Expanded(child: _Skeleton(height: 132)),
          ],
        ),
        SizedBox(height: 24),
        _Skeleton(height: 92),
        SizedBox(height: 24),
        _Skeleton(height: 120),
        SizedBox(height: 24),
        _Skeleton(height: 180),
      ],
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton({this.width, required this.height});
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFF4F2F3),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.onRetry});
  final VoidCallback onRetry;

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
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Не удалось загрузить кабинет',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Проверьте соединение и попробуйте ещё раз.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: onRetry, child: const Text('Повторить')),
          ],
        ),
      ),
    );
  }
}
