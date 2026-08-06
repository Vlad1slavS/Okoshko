import 'package:you_master_app/core/network/api_client.dart';
import 'package:you_master_app/features/professional_details/data/professional_details_repository.dart';
import 'package:you_master_app/features/professional_details/domain/professional_details.dart';

class BackendProfessionalDetailsRepository
    implements ProfessionalDetailsRepository {
  const BackendProfessionalDetailsRepository(
    this._apiClient,
    this._presentationContentRepository,
  );

  final ApiClient _apiClient;
  final ProfessionalDetailsRepository _presentationContentRepository;

  @override
  Future<ProfessionalDetails> getById(String id) async {
    final encodedSlug = Uri.encodeComponent(id);
    final presentationContent = _presentationContentRepository.getById(id);
    final payload = await _apiClient.getObject(
      '/api/v1/professionals/by-slug/$encodedSlug/details',
    );
    final content = await presentationContent;
    final profile = payload['professional']! as Map<String, Object?>;
    final servicePayload = payload['services']! as List<Object?>;
    final services = <ProfessionalService>[
      for (var index = 0; index < servicePayload.length; index++)
        _mapService(
          servicePayload[index]! as Map<String, Object?>,
          index,
          content,
        ),
    ];
    final categories = {
      for (final service in services) service.category,
    }.toList(growable: false);
    final location = profile['location'] as Map<String, Object?>?;

    return ProfessionalDetails(
      id: id,
      name: profile['displayName']! as String,
      specializations: categories,
      coverAsset: content.coverAsset,
      avatarAsset: content.avatarAsset,
      avatarUrl: profile['avatarUrl'] as String?,
      rating: (profile['rating']! as num).toDouble(),
      reviewCount: profile['reviewsCount']! as int,
      experienceYears: _experienceYears(
        profile['experienceStartedOn'] as String?,
        fallback: content.experienceYears,
      ),
      completedAppointments: profile['completedAppointmentsCount']! as int,
      repeatClientPercent: content.repeatClientPercent,
      address: location?['address'] as String? ?? content.address,
      addressHint: location?['city'] as String? ?? content.addressHint,
      workingHours: content.workingHours,
      about: profile['description'] as String? ?? content.about,
      serviceCategories: ['Все', ...categories],
      services: services,
      portfolioAssets: content.portfolioAssets,
      reviews: content.reviews,
      credentials: content.credentials,
      isVerified: content.isVerified,
    );
  }

  ProfessionalService _mapService(
    Map<String, Object?> payload,
    int index,
    ProfessionalDetails content,
  ) {
    final fallbackImages = content.services
        .map((service) => service.imageAsset)
        .toList(growable: false);
    final imageAsset = fallbackImages.isEmpty
        ? content.coverAsset
        : fallbackImages[index % fallbackImages.length];

    return ProfessionalService(
      id: payload['id']! as String,
      category: payload['categoryName']! as String,
      name: payload['name']! as String,
      description: payload['description'] as String? ?? '',
      durationMinutes: payload['durationMinutes']! as int,
      price: (payload['priceMinor']! as int) ~/ 100,
      imageAsset: imageAsset,
      isPopular: index == 0,
    );
  }

  int _experienceYears(String? startedOn, {required int fallback}) {
    final start = DateTime.tryParse(startedOn ?? '');
    if (start == null) return fallback;
    final today = DateTime.now();
    var years = today.year - start.year;
    if (today.month < start.month ||
        (today.month == start.month && today.day < start.day)) {
      years--;
    }
    return years < 0 ? 0 : years;
  }
}
