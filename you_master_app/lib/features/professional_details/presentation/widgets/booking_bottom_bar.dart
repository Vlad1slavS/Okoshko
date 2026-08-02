import 'package:flutter/material.dart';
import 'package:you_master_app/design_system/theme/app_colors.dart';
import 'package:you_master_app/features/professional_details/domain/professional_details.dart';

class BookingBottomBar extends StatelessWidget {
  const BookingBottomBar({
    required this.service,
    required this.onPressed,
    super.key,
  });

  final ProfessionalService? service;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: service == null
                  ? const Text(
                      'Выберите услугу',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service!.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${service!.priceFrom ? 'от ' : ''}${service!.price} ₽'
                          '  •  ${service!.durationMinutes} мин',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              key: const Key('choose-booking-time'),
              onPressed: service == null ? null : onPressed,
              style: FilledButton.styleFrom(
                minimumSize: const Size(128, 46),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text('Выбрать время'),
            ),
          ],
        ),
      ),
    );
  }
}
