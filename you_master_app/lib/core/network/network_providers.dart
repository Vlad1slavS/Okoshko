import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:you_master_app/core/config/app_environment.dart';
import 'package:you_master_app/core/network/api_client.dart';
import 'package:you_master_app/core/network/http_client_factory.dart';

final httpClientProvider = Provider<http.Client>((ref) {
  final client = createPlatformHttpClient();
  ref.onDispose(client.close);
  return client;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    ref.watch(httpClientProvider),
    baseUrl: AppEnvironment.apiBaseUrl,
    traceRequestStacks: AppEnvironment.traceApiRequestStacks,
  );
});
