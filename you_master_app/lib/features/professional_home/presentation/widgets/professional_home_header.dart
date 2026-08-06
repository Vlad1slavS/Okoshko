import 'package:flutter/material.dart';
import 'package:you_master_app/design_system/theme/app_colors.dart';

class ProfessionalHomeHeader extends StatelessWidget {
  const ProfessionalHomeHeader({
    required this.name,
    required this.onNotificationsPressed,
    super.key,
  });

  final String name;
  final VoidCallback onNotificationsPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Привет, $name!',
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Хорошего дня и много записей!',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Уведомления',
          onPressed: onNotificationsPressed,
          icon: const Icon(Icons.notifications_none_rounded),
        ),
      ],
    );
  }
}
