import 'package:you_master_app/core/network/api_client.dart';
import 'package:you_master_app/features/client_home/domain/home_category.dart';
import 'package:you_master_app/features/client_home/domain/professional_preview.dart';

class FavoritePage {
  const FavoritePage({
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

abstract interface class FavoritesRepository {
  Future<Set<String>> getIds();
  Future<FavoritePage> getPage({required int page, required int size});
  Future<void> setFavorite(String professionalId, {required bool favorite});
}

class BackendFavoritesRepository implements FavoritesRepository {
  const BackendFavoritesRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Set<String>> getIds() async {
    final payload = await _apiClient.getObject('/api/v1/me/favorites/ids');
    return (payload['professionalIds'] as List<dynamic>? ?? const [])
        .cast<String>()
        .toSet();
  }

  @override
  Future<FavoritePage> getPage({required int page, required int size}) async {
    final payload = await _apiClient.getObject(
      '/api/v1/me/favorites?page=$page&size=$size',
    );
    return FavoritePage(
      items: (payload['items'] as List<dynamic>? ?? const [])
          .map(_mapPreview)
          .toList(growable: false),
      page: payload['page'] as int,
      totalItems: payload['totalItems'] as int,
      hasNext: payload['hasNext'] as bool,
    );
  }

  @override
  Future<void> setFavorite(
    String professionalId, {
    required bool favorite,
  }) async {
    final id = Uri.encodeComponent(professionalId);
    if (favorite) {
      await _apiClient.putObject('/api/v1/me/favorites/$id', const {});
    } else {
      await _apiClient.deleteObject('/api/v1/me/favorites/$id');
    }
  }

  ProfessionalPreview _mapPreview(Object? value) {
    final json = value! as Map<String, dynamic>;
    final durationFrom = json['durationFromMinutes'] as int;
    final durationTo = json['durationToMinutes'] as int;
    final categories = (json['categorySlugs'] as List<dynamic>)
        .map(
          (value) => HomeCategory.values
              .where((category) => category.name == value)
              .firstOrNull,
        )
        .whereType<HomeCategory>()
        .toSet();
    return ProfessionalPreview(
      id: json['slug'] as String,
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
    );
  }
}
