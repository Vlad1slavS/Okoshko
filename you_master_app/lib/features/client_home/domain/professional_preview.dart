import 'package:you_master_app/features/client_home/domain/home_category.dart';

class ProfessionalPreview {
  const ProfessionalPreview({
    required this.id,
    required this.name,
    required this.description,
    required this.rating,
    required this.reviewCount,
    required this.distanceKm,
    required this.durationLabel,
    required this.priceFrom,
    this.imageUrl,
    this.imageAsset,
    required this.categories,
    required this.availableToday,
    this.badge,
  });

  final String id;
  final String name;
  final String description;
  final double rating;
  final int reviewCount;
  final double? distanceKm;
  final String durationLabel;
  final int priceFrom;
  final String? imageUrl;
  final String? imageAsset;
  final Set<HomeCategory> categories;
  final bool availableToday;
  final String? badge;
}
