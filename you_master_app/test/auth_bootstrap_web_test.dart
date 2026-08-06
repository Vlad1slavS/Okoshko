import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:you_master_app/app/you_master_app.dart';
import 'package:you_master_app/core/config/app_environment.dart';
import 'package:you_master_app/core/network/network_providers.dart';

void main() {
  testWidgets(
    'restores session before loading a directly opened private web route',
    (tester) async {
      tester.binding.platformDispatcher.defaultRouteNameTestValue =
          '/client/favorites';
      addTearDown(
        tester.binding.platformDispatcher.clearDefaultRouteNameTestValue,
      );

      final requests = <http.Request>[];
      final releaseRefresh = Completer<void>();
      final client = MockClient((request) async {
        requests.add(request);
        switch (request.url.path) {
          case '/api/v1/auth/refresh':
            await releaseRefresh.future;
            return http.Response(
              jsonEncode({
                'accessToken': 'restored-access-token',
                'user': {
                  'id': 'client-id',
                  'phone': '+79990000000',
                  'displayName': 'Анна Иванова',
                  'email': null,
                  'hasClientProfile': true,
                  'hasProfessionalProfile': false,
                },
              }),
              200,
              headers: {'content-type': 'application/json'},
            );
          case '/api/v1/me/favorites/ids':
            return http.Response(
              jsonEncode({'professionalIds': <String>[]}),
              200,
              headers: {'content-type': 'application/json'},
            );
          case '/api/v1/me/favorites':
            return http.Response(
              jsonEncode({
                'items': <Object>[],
                'page': 0,
                'size': 20,
                'totalItems': 0,
                'hasNext': false,
              }),
              200,
              headers: {'content-type': 'application/json'},
            );
          default:
            return http.Response('Not found', 404);
        }
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [httpClientProvider.overrideWithValue(client)],
          child: const YouMasterApp(),
        ),
      );

      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(requests, hasLength(1));
      expect(requests.single.url.path, '/api/v1/auth/refresh');

      releaseRefresh.complete();

      await tester.pumpAndSettle();

      expect(find.text('Избранное'), findsWidgets);
      expect(requests.first.url.path, '/api/v1/auth/refresh');
      final favoriteRequests = requests.where(
        (request) => request.url.path.startsWith('/api/v1/me/favorites'),
      );
      expect(favoriteRequests, isNotEmpty);
      expect(
        favoriteRequests.any(
          (request) => request.url.path == '/api/v1/me/favorites',
        ),
        isTrue,
      );
      for (final request in favoriteRequests) {
        expect(
          request.headers['Authorization'],
          'Bearer restored-access-token',
        );
      }
    },
    skip: !AppEnvironment.useRemoteApi,
  );
}
