import 'package:flutter/material.dart';
import 'package:you_master_app/design_system/theme/app_colors.dart';

class TodaySummary extends StatelessWidget {
  const TodaySummary({
    required this.appointmentsCount,
    required this.revenueLabel,
    required this.revenueChangePercent,
    required this.onCalendarPressed,
    super.key,
  });

  final int appointmentsCount;
  final String revenueLabel;
  final int revenueChangePercent;
  final VoidCallback onCalendarPressed;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _SummaryCard(
              color: AppColors.primaryContainer,
              eyebrow: 'Сегодня',
              value: '$appointmentsCount записей',
              footer: TextButton(
                onPressed: onCalendarPressed,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: AppColors.primary,
                  backgroundColor: Colors.white.withValues(alpha: 0.72),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text('Календарь'),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SummaryCard(
              color: AppColors.surface,
              eyebrow: 'Доход за сегодня',
              value: revenueLabel,
              footer: Text(
                '+$revenueChangePercent% к прошлой неделе',
                style: const TextStyle(
                  color: AppColors.success,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.color,
    required this.eyebrow,
    required this.value,
    required this.footer,
  });

  final Color color;
  final String eyebrow;
  final String value;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(eyebrow, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          const SizedBox(height: 10),
          footer,
        ],
      ),
    );
  }
}
