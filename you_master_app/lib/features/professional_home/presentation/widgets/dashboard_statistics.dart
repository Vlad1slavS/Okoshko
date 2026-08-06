import 'package:flutter/material.dart';
import 'package:you_master_app/design_system/theme/app_colors.dart';

class DashboardStatistics extends StatelessWidget {
  const DashboardStatistics({
    required this.appointments,
    required this.revenueLabel,
    required this.newClients,
    required this.appointmentsChange,
    required this.revenueChange,
    required this.newClientsChange,
    super.key,
  });

  final int appointments;
  final String revenueLabel;
  final int newClients;
  final int appointmentsChange;
  final int revenueChange;
  final int newClientsChange;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Expanded(
              child: Text(
                'Статистика',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              'На этой неделе',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              _StatisticRow(
                icon: Icons.calendar_today_outlined,
                label: 'Записей',
                value: '$appointments',
                change: '+$appointmentsChange%',
              ),
              const Divider(height: 1, indent: 14, endIndent: 14),
              _StatisticRow(
                icon: Icons.payments_outlined,
                label: 'Доход',
                value: revenueLabel,
                change: '+$revenueChange%',
              ),
              const Divider(height: 1, indent: 14, endIndent: 14),
              _StatisticRow(
                icon: Icons.person_add_alt_rounded,
                label: 'Новые клиенты',
                value: '$newClients',
                change: '+$newClientsChange',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatisticRow extends StatelessWidget {
  const _StatisticRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.change,
  });

  final IconData icon;
  final String label;
  final String value;
  final String change;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 42,
            child: Text(
              change,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: AppColors.success,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
