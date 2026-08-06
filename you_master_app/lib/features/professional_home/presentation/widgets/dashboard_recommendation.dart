import 'package:flutter/material.dart';
import 'package:you_master_app/design_system/theme/app_colors.dart';

class DashboardRecommendation extends StatelessWidget {
  const DashboardRecommendation({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryContainer, AppColors.surfaceMuted],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt_rounded, color: AppColors.primary, size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Освободилось окно?',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Создайте предложение за минуту',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton(onPressed: onPressed, child: const Text('Создать')),
        ],
      ),
    );
  }
}
