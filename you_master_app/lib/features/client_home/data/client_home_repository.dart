import 'package:you_master_app/features/client_home/domain/home_category.dart';
import 'package:you_master_app/features/client_home/domain/professional_preview.dart';

abstract interface class ClientHomeRepository {
  List<ProfessionalPreview> getNearbyProfessionals();

  Future<List<ProfessionalPreview>> getPopularNearby({
    required String city,
    required HomeCategory category,
    required int limit,
  });
}

class MockClientHomeRepository implements ClientHomeRepository {
  const MockClientHomeRepository();

  @override
  List<ProfessionalPreview> getNearbyProfessionals() {
    return const [
      ProfessionalPreview(
        id: 'glamour-haven',
        name: 'Glamour Haven',
        description: 'Стрижки, окрашивание, брови, макияж',
        rating: 4.8,
        reviewCount: 1254,
        distanceKm: 0.5,
        durationLabel: '10–60 мин',
        priceFrom: 1200,
        imageAsset: 'assets/images/home/glamour_haven.webp',
        categories: {
          HomeCategory.brows,
          HomeCategory.makeup,
          HomeCategory.more,
        },
        availableToday: true,
        badge: 'Топ мастер',
      ),
      ProfessionalPreview(
        id: 'ekaterina-smirnova',
        name: 'Екатерина Смирнова',
        description: 'Маникюр, педикюр, дизайн ногтей',
        rating: 4.9,
        reviewCount: 892,
        distanceKm: 0.7,
        durationLabel: '40–90 мин',
        priceFrom: 900,
        imageAsset: 'assets/images/home/ekaterina.webp',
        categories: {HomeCategory.manicure},
        availableToday: true,
      ),
      ProfessionalPreview(
        id: 'anna-ivanova',
        name: 'Анна Иванова',
        description: 'Брови, ламинирование ресниц, макияж',
        rating: 4.7,
        reviewCount: 645,
        distanceKm: 0.9,
        durationLabel: '30–75 мин',
        priceFrom: 800,
        imageAsset: 'assets/images/home/anna.webp',
        categories: {
          HomeCategory.brows,
          HomeCategory.lashes,
          HomeCategory.makeup,
        },
        availableToday: false,
      ),
    ];
  }

  @override
  Future<List<ProfessionalPreview>> getPopularNearby({
    required String city,
    required HomeCategory category,
    required int limit,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 550));

    final professionals = getNearbyProfessionals().where((professional) {
      return category == HomeCategory.all ||
          category == HomeCategory.more ||
          professional.categories.contains(category);
    });

    return professionals.take(limit).toList(growable: false);
  }
}
