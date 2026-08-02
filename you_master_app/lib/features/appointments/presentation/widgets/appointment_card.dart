import 'package:flutter/material.dart';
import 'package:you_master_app/design_system/theme/app_colors.dart';
import 'package:you_master_app/features/appointments/domain/appointment.dart';

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({
    required this.appointment,
    required this.onProfessionalTap,
    required this.onUiAction,
    this.isNearest = false,
    super.key,
  });

  final Appointment appointment;
  final VoidCallback onProfessionalTap;
  final ValueChanged<String> onUiAction;
  final bool isNearest;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('appointment-${appointment.id}'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isNearest ? AppColors.surfaceMuted : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isNearest
              ? AppColors.primary.withValues(alpha: 0.26)
              : AppColors.border,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${appointment.dateLabel} · ${appointment.timeLabel}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _StatusBadge(status: appointment.status),
            ],
          ),
          const SizedBox(height: 14),
          InkWell(
            key: Key('appointment-professional-${appointment.id}'),
            onTap: onProfessionalTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      appointment.professionalImageAsset,
                      width: 58,
                      height: 58,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.professionalName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          appointment.serviceName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          _DetailsRow(
            icon: Icons.location_on_outlined,
            text: appointment.address,
          ),
          const SizedBox(height: 8),
          _DetailsRow(
            icon: Icons.schedule_rounded,
            text: '${appointment.durationLabel}  ·  ${appointment.price} ₽',
          ),
          const SizedBox(height: 16),
          _Actions(
            appointment: appointment,
            isNearest: isNearest,
            onUiAction: onUiAction,
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final AppointmentStatus status;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (status) {
      AppointmentStatus.confirmed => (
        const Color(0xFFEAF8EF),
        AppColors.success,
      ),
      AppointmentStatus.awaitingConfirmation => (
        const Color(0xFFFFF4D9),
        const Color(0xFF956000),
      ),
      AppointmentStatus.completed => (
        const Color(0xFFF1F1F3),
        AppColors.textSecondary,
      ),
      AppointmentStatus.cancelledByClient ||
      AppointmentStatus.cancelledByProfessional => (
        const Color(0xFFFFECEA),
        AppColors.error,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: foreground,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DetailsRow extends StatelessWidget {
  const _DetailsRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.appointment,
    required this.isNearest,
    required this.onUiAction,
  });

  final Appointment appointment;
  final bool isNearest;
  final ValueChanged<String> onUiAction;

  @override
  Widget build(BuildContext context) {
    if (appointment.status == AppointmentStatus.completed) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => onUiAction('Повторная запись'),
              child: const Text('Повторить'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FilledButton(
              onPressed: appointment.reviewed
                  ? null
                  : () => onUiAction('Отзыв'),
              child: Text(
                appointment.reviewed ? 'Отзыв оставлен' : 'Оставить отзыв',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      );
    }

    if (appointment.status == AppointmentStatus.cancelledByClient ||
        appointment.status == AppointmentStatus.cancelledByProfessional) {
      return FilledButton(
        onPressed: () => onUiAction('Повторная запись'),
        child: const Text('Записаться снова'),
      );
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: null,
            child: const Text('Перенести'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton(
            onPressed: null,
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Отменить'),
          ),
        ),
      ],
    );
  }
}
