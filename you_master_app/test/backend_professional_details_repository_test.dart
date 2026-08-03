import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:you_master_app/core/network/api_client.dart';
import 'package:you_master_app/features/professional_details/data/backend_professional_details_repository.dart';
import 'package:you_master_app/features/professional_details/data/professional_details_repository.dart';

void main() {
  test('maps aggregated backend details with a single HTTP request', () async {
    var requestCount = 0;
    final httpClient = MockClient((request) async {
      requestCount++;
      expect(
        request.url.path,
        '/api/v1/professionals/by-slug/ekaterina-smirnova/details',
      );
      final payload = {
        'professional': {
          'id': '20000000-0000-0000-0000-000000000001',
          'slug': 'ekaterina-smirnova',
          'displayName': 'Екатерина с backend',
          'description': 'Описание с backend',
          'avatarUrl': null,
          'experienceStartedOn': '2020-05-01',
          'rating': 4.9,
          'reviewsCount': 128,
          'completedAppointmentsCount': 312,
          'business': {
            'id': '30000000-0000-0000-0000-000000000001',
            'slug': 'nail-studio-by-ekaterina',
            'name': 'Nail Studio by Ekaterina',
            'type': 'SOLO',
          },
          'location': {
            'id': '40000000-0000-0000-0000-000000000001',
            'name': 'Основная студия',
            'city': 'Москва',
            'address': 'Чистопрудный бульвар, 12с1',
            'timezone': 'Europe/Moscow',
            'latitude': 55.763170,
            'longitude': 37.638620,
          },
        },
        'services': [
          {
            'id': '60000000-0000-0000-0000-000000000001',
            'categoryId': '50000000-0000-0000-0000-000000000001',
            'categoryName': 'Маникюр',
            'name': 'Маникюр с покрытием',
            'description': 'Маникюр и покрытие',
            'durationMinutes': 90,
            'bufferBeforeMinutes': 0,
            'bufferAfterMinutes': 15,
            'priceMinor': 220000,
            'currency': 'RUB',
          },
        ],
      };

      return http.Response(
        jsonEncode(payload),
        200,
        headers: const {'content-type': 'application/json; charset=utf-8'},
      );
    });
    final repository = BackendProfessionalDetailsRepository(
      ApiClient(httpClient, baseUrl: 'http://localhost:8080'),
      const MockProfessionalDetailsRepository(),
    );

    final details = await repository.getById('ekaterina-smirnova');

    expect(details.name, 'Екатерина с backend');
    expect(details.about, 'Описание с backend');
    expect(details.address, 'Чистопрудный бульвар, 12с1');
    expect(details.services, hasLength(1));
    expect(details.services.single.price, 2200);
    expect(details.services.single.durationMinutes, 90);
    expect(details.portfolioAssets, isNotEmpty);
    expect(details.reviews, isNotEmpty);
    expect(requestCount, 1);
  });
}
