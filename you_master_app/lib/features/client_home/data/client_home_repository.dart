import 'package:you_master_app/core/network/api_client.dart';
import 'package:you_master_app/features/client_home/domain/home_category.dart';
import 'package:you_master_app/features/client_home/domain/professional_preview.dart';
import 'package:you_master_app/features/client_search/presentation/state/client_search_state.dart';

class ProfessionalPreviewPage {
  const ProfessionalPreviewPage({
    required this.items,
    required this.page,
    required this.totalItems,
    required this.hasNext,
  });

  final List<ProfessionalPreview> items;
  final int page;
  final int totalItems;
  final bool hasNext;
}

abstract interface class ClientHomeRepository {
  List<ProfessionalPreview> getNearbyProfessionals();

  Future<List<ProfessionalPreview>> getPopularNearby({
    required String city,
    required HomeCategory category,
    required int limit,
  });

  Future<ProfessionalPreviewPage> search({
    required String city,
    required String query,
    required HomeCategory category,
    required SearchSort sort,
    required double minimumRating,
    required int page,
    required int size,
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

  @override
  Future<ProfessionalPreviewPage> search({
    required String city,
    required String query,
    required HomeCategory category,
    required SearchSort sort,
    required double minimumRating,
    required int page,
    required int size,
  }) async {
    final normalizedQuery = query.trim().toLowerCase();
    var items = getNearbyProfessionals().where((professional) {
      return (category == HomeCategory.all ||
              category == HomeCategory.more ||
              professional.categories.contains(category)) &&
          (normalizedQuery.isEmpty ||
              professional.name.toLowerCase().contains(normalizedQuery) ||
              professional.description.toLowerCase().contains(
                normalizedQuery,
              )) &&
          professional.rating >= minimumRating;
    }).toList();
    switch (sort) {
      case SearchSort.recommended:
      case SearchSort.rating:
        items.sort((a, b) => b.rating.compareTo(a.rating));
      case SearchSort.distance:
        items.sort(
          (a, b) => (a.distanceKm ?? double.infinity).compareTo(
            b.distanceKm ?? double.infinity,
          ),
        );
      case SearchSort.price:
        items.sort((a, b) => a.priceFrom.compareTo(b.priceFrom));
    }
    final start = page * size;
    final pageItems = start >= items.length
        ? const <ProfessionalPreview>[]
        : items.skip(start).take(size).toList(growable: false);
    return ProfessionalPreviewPage(
      items: pageItems,
      page: page,
      totalItems: items.length,
      hasNext: start + pageItems.length < items.length,
    );
  }
}

class BackendClientHomeRepository implements ClientHomeRepository {
  const BackendClientHomeRepository(this._apiClient, this._fallback);

  final ApiClient _apiClient;
  final MockClientHomeRepository _fallback;

  @override
  List<ProfessionalPreview> getNearbyProfessionals() =>
      _fallback.getNearbyProfessionals();

  @override
  Future<List<ProfessionalPreview>> getPopularNearby({
    required String city,
    required HomeCategory category,
    required int limit,
  }) async {
    final query = _queryParameters(
      city: city,
      category: category,
      extra: {'limit': '$limit'},
    );
    final payload = await _apiClient.getList(
      '/api/v1/professionals/popular?$query',
    );
    return payload.map(_mapPreview).toList(growable: false);
  }

  @override
  Future<ProfessionalPreviewPage> search({
    required String city,
    required String query,
    required HomeCategory category,
    required SearchSort sort,
    required double minimumRating,
    required int page,
    required int size,
  }) async {
    final parameters = _queryParameters(
      city: city,
      category: category,
      extra: {
        'query': query,
        'minimumRating': '$minimumRating',
        'sort': _sortValue(sort),
        'page': '$page',
        'size': '$size',
      },
    );
    final payload = await _apiClient.getObject(
      '/api/v1/professionals?$parameters',
    );
    final items = payload['items'] as List<dynamic>? ?? const [];
    return ProfessionalPreviewPage(
      items: items.map(_mapPreview).toList(growable: false),
      page: payload['page'] as int,
      totalItems: payload['totalItems'] as int,
      hasNext: payload['hasNext'] as bool,
    );
  }

  String _queryParameters({
    required String city,
    required HomeCategory category,
    required Map<String, String> extra,
  }) {
    final values = <String, String>{'city': city, ...extra};
    if (category != HomeCategory.all && category != HomeCategory.more) {
      values['category'] = category.name;
    }
    return Uri(queryParameters: values).query;
  }

  String _sortValue(SearchSort sort) => switch (sort) {
    SearchSort.rating => 'RATING',
    SearchSort.price => 'PRICE',
    SearchSort.recommended || SearchSort.distance => 'RECOMMENDED',
  };

  ProfessionalPreview _mapPreview(Object? value) {
    final json = value as Map<String, dynamic>;
    final slug = json['slug'] as String;
    final durationFrom = json['durationFromMinutes'] as int;
    final durationTo = json['durationToMinutes'] as int;
    final categories = (json['categorySlugs'] as List<dynamic>)
        .map(
          (value) => HomeCategory.values
              .where((item) => item.name == value)
              .firstOrNull,
        )
        .whereType<HomeCategory>()
        .toSet();
    return ProfessionalPreview(
      id: slug,
      name: json['displayName'] as String,
      description: json['description'] as String? ?? '',
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewsCount'] as int,
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      durationLabel: durationFrom == durationTo
          ? '$durationFrom мин'
          : '$durationFrom–$durationTo мин',
      priceFrom: (json['priceFromMinor'] as int) ~/ 100,
      imageUrl: json['avatarUrl'] as String?,
      categories: categories,
      availableToday: false,
      badge: null,
    );
  }
}
