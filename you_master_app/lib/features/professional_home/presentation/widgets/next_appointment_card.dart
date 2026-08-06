import 'package:flutter/material.dart';
import 'package:you_master_app/design_system/theme/app_colors.dart';
import 'package:you_master_app/design_system/widgets/professional_avatar.dart';
import 'package:you_master_app/features/professional_home/domain/professional_dashboard.dart';

class NextAppointmentCard extends StatelessWidget {
  const NextAppointmentCard({required this.appointment, this.onTap, super.key});

  final ProfessionalAppointmentSummary appointment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ближайшая запись',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Material(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(15),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(15),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  ProfessionalAvatar(
                    size: 48,
                    imageAsset: appointment.clientAvatarAsset,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.clientName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          appointment.serviceName,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _time(appointment.startsAt),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _time(DateTime value) =>
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
}
