import 'package:flutter/material.dart';
import 'package:you_master_app/design_system/theme/app_colors.dart';
import 'package:you_master_app/features/professional_calendar/domain/professional_calendar.dart';

class CalendarAppointmentCard extends StatelessWidget {
  const CalendarAppointmentCard({required this.appointment, super.key});

  final CalendarAppointment appointment;

  @override
  Widget build(BuildContext context) {
    final (:label, :color, :background) = _statusStyle(appointment.status);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 3,
            height: 66,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${appointment.startTime} – ${appointment.endTime}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  appointment.serviceName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  appointment.clientName,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ({String label, Color color, Color background}) _statusStyle(
    CalendarAppointmentStatus status,
  ) => switch (status) {
    CalendarAppointmentStatus.confirmed => (
      label: 'Подтверждена',
      color: AppColors.success,
      background: const Color(0xFFEAF8EF),
    ),
    CalendarAppointmentStatus.pendingConfirmation => (
      label: 'Ожидает',
      color: const Color(0xFF7A55C5),
      background: const Color(0xFFF1EBFF),
    ),
    CalendarAppointmentStatus.completed => (
      label: 'Выполнена',
      color: AppColors.textSecondary,
      background: AppColors.surfaceMuted,
    ),
    CalendarAppointmentStatus.cancelledByClient ||
    CalendarAppointmentStatus.cancelledByProfessional => (
      label: 'Отменена',
      color: AppColors.error,
      background: const Color(0xFFFFECEA),
    ),
    CalendarAppointmentStatus.noShow => (
      label: 'Не пришёл',
      color: AppColors.error,
      background: const Color(0xFFFFECEA),
    ),
  };
}
