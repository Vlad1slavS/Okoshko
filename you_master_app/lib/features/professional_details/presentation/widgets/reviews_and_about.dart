import 'package:flutter/material.dart';
import 'package:you_master_app/design_system/theme/app_colors.dart';
import 'package:you_master_app/features/professional_details/domain/professional_details.dart';

class ReviewsAndAbout extends StatelessWidget {
  const ReviewsAndAbout({required this.details, super.key});

  final ProfessionalDetails details;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Отзывы',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              TextButton(onPressed: () {}, child: const Text('Смотреть все')),
            ],
          ),
          const SizedBox(height: 8),
          _RatingSummary(details: details),
          const SizedBox(height: 12),
          for (final review in details.reviews) ...[
            _ReviewCard(review: review),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 18),
          Text('О мастере', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          Text(details.about, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          for (final credential in details.credentials)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                _credentialIcon(credential.icon),
                color: AppColors.primary,
              ),
              title: Text(
                credential.title,
                style: const TextStyle(fontSize: 14),
              ),
              subtitle: Text(credential.value),
            ),
        ],
      ),
    );
  }

  IconData _credentialIcon(String value) => switch (value) {
    'education' => Icons.school_outlined,
    'payment' => Icons.payment_outlined,
    'cancellation' => Icons.schedule_outlined,
    _ => Icons.workspace_premium_outlined,
  };
}

class _RatingSummary extends StatelessWidget {
  const _RatingSummary({required this.details});

  final ProfessionalDetails details;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(
            details.rating.toStringAsFixed(1),
            style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(
                    5,
                    (index) => const Icon(
                      Icons.star_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${details.reviewCount} отзывов',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final ProfessionalReview review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 18,
                child: Icon(Icons.person_outline_rounded, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.author,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      review.date,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  review.rating,
                  (index) => const Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(review.text),
          if (review.isVerifiedAppointment) ...[
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(
                  Icons.verified_outlined,
                  size: 15,
                  color: AppColors.success,
                ),
                SizedBox(width: 5),
                Text(
                  'Подтверждённая запись',
                  style: TextStyle(fontSize: 11, color: AppColors.success),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
