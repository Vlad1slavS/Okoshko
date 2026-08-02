import 'package:flutter/material.dart';
import 'package:you_master_app/design_system/theme/app_colors.dart';

class BecomeProfessionalCard extends StatelessWidget {
  const BecomeProfessionalCard({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryContainer, AppColors.surfaceMuted],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: AppColors.primary),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Вы оказываете услуги?',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Создайте профиль мастера и принимайте записи онлайн.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          FilledButton(
            key: const Key('open-professional-cabinet'),
            onPressed: onPressed,
            child: const Text('Перейти в кабинет мастера'),
          ),
        ],
      ),
    );
  }
}
