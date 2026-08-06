import 'package:flutter/material.dart';
import 'package:you_master_app/design_system/theme/app_colors.dart';
import 'package:you_master_app/design_system/widgets/professional_avatar.dart';
import 'package:you_master_app/features/professional_home/domain/professional_dashboard.dart';

class TodayAppointments extends StatelessWidget {
  const TodayAppointments({
    required this.appointments,
    required this.onShowAll,
    super.key,
  });

  final List<ProfessionalAppointmentSummary> appointments;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Записи сегодня',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            TextButton(onPressed: onShowAll, child: const Text('Все')),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              for (var index = 0; index < appointments.length; index++) ...[
                _AppointmentRow(appointment: appointments[index]),
                if (index != appointments.length - 1)
                  const Divider(height: 1, indent: 14, endIndent: 14),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _AppointmentRow extends StatelessWidget {
  const _AppointmentRow({required this.appointment});

  final ProfessionalAppointmentSummary appointment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ProfessionalAvatar(
            size: 38,
            imageAsset: appointment.clientAvatarAsset,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.clientName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  appointment.serviceName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _time(appointment.startsAt),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              _StatusBadge(status: appointment.status),
            ],
          ),
        ],
      ),
    );
  }

  String _time(DateTime value) =>
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final ProfessionalAppointmentStatus status;

  @override
  Widget build(BuildContext context) {
    final (:label, :color, :background) = switch (status) {
      ProfessionalAppointmentStatus.confirmed => (
        label: 'Подтверждена',
        color: AppColors.success,
        background: const Color(0xFFEAF8EF),
      ),
      ProfessionalAppointmentStatus.pending => (
        label: 'Ожидает',
        color: const Color(0xFF7A55C5),
        background: const Color(0xFFF1EBFF),
      ),
      ProfessionalAppointmentStatus.completed => (
        label: 'Выполнена',
        color: AppColors.textSecondary,
        background: AppColors.surfaceMuted,
      ),
      ProfessionalAppointmentStatus.cancelled => (
        label: 'Отменена',
        color: AppColors.error,
        background: const Color(0xFFFFECEA),
      ),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
