import 'package:flutter/material.dart';
import 'package:you_master_app/design_system/theme/app_colors.dart';

class ProfessionalQuickActions extends StatelessWidget {
  const ProfessionalQuickActions({required this.onActionPressed, super.key});

  final ValueChanged<ProfessionalQuickAction> onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Быстрые действия',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (final action in ProfessionalQuickAction.values) ...[
              Expanded(
                child: _ActionTile(
                  action: action,
                  onTap: () => onActionPressed(action),
                ),
              ),
              if (action != ProfessionalQuickAction.values.last)
                const SizedBox(width: 8),
            ],
          ],
        ),
      ],
    );
  }
}

enum ProfessionalQuickAction {
  services('Услуги', Icons.grid_view_rounded),
  appointments('Записи', Icons.calendar_today_outlined),
  reviews('Отзывы', Icons.favorite_border_rounded),
  clients('Клиенты', Icons.people_outline_rounded);

  const ProfessionalQuickAction(this.label, this.icon);
  final String label;
  final IconData icon;
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.action, required this.onTap});

  final ProfessionalQuickAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          child: Column(
            children: [
              Icon(action.icon, color: AppColors.primary, size: 22),
              const SizedBox(height: 8),
              FittedBox(
                child: Text(action.label, style: const TextStyle(fontSize: 11)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
