import 'package:flutter/foundation.dart';

@immutable
class ProfessionalDetails {
  const ProfessionalDetails({
    required this.id,
    required this.name,
    required this.specializations,
    required this.coverAsset,
    required this.avatarAsset,
    this.avatarUrl,
    required this.rating,
    required this.reviewCount,
    required this.experienceYears,
    required this.completedAppointments,
    required this.repeatClientPercent,
    required this.address,
    required this.addressHint,
    required this.workingHours,
    required this.about,
    required this.serviceCategories,
    required this.services,
    required this.portfolioAssets,
    required this.reviews,
    required this.credentials,
    required this.isVerified,
  });

  final String id;
  final String name;
  final List<String> specializations;
  final String coverAsset;
  final String avatarAsset;
  final String? avatarUrl;
  final double rating;
  final int reviewCount;
  final int experienceYears;
  final int completedAppointments;
  final int repeatClientPercent;
  final String address;
  final String addressHint;
  final Map<String, String> workingHours;
  final String about;
  final List<String> serviceCategories;
  final List<ProfessionalService> services;
  final List<String> portfolioAssets;
  final List<ProfessionalReview> reviews;
  final List<ProfessionalCredential> credentials;
  final bool isVerified;
}

@immutable
class ProfessionalService {
  const ProfessionalService({
    required this.id,
    required this.category,
    required this.name,
    required this.description,
    required this.durationMinutes,
    required this.price,
    required this.imageAsset,
    this.isPopular = false,
    this.priceFrom = false,
  });

  final String id;
  final String category;
  final String name;
  final String description;
  final int durationMinutes;
  final int price;
  final String imageAsset;
  final bool isPopular;
  final bool priceFrom;
}

@immutable
class ProfessionalReview {
  const ProfessionalReview({
    required this.author,
    required this.date,
    required this.rating,
    required this.text,
    required this.isVerifiedAppointment,
  });

  final String author;
  final String date;
  final int rating;
  final String text;
  final bool isVerifiedAppointment;
}

@immutable
class ProfessionalCredential {
  const ProfessionalCredential({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final String icon;
}
