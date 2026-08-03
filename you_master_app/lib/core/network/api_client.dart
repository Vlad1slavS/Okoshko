import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:you_master_app/core/network/api_exception.dart';

class ApiClient {
  const ApiClient(
    this._httpClient, {
    required this.baseUrl,
    this.traceRequestStacks = false,
  });

  final String baseUrl;
  final bool traceRequestStacks;
  final http.Client _httpClient;

  static const _timeout = Duration(seconds: 12);
  static var _requestSequence = 0;

  Future<Map<String, Object?>> getObject(String path) async {
    final payload = await _get(path);
    if (payload case final Map<String, dynamic> object) {
      return object;
    }
    throw const FormatException('Expected a JSON object');
  }

  Future<List<Object?>> getList(String path) async {
    final payload = await _get(path);
    if (payload case final List<dynamic> list) {
      return list;
    }
    throw const FormatException('Expected a JSON array');
  }

  Future<Object?> _get(String path) async {
    final uri = _resolve(path);
    final requestId = _createRequestId();
    final stopwatch = Stopwatch()..start();

    if (kDebugMode) {
      debugPrint('API -> [$requestId] GET $uri');
      if (traceRequestStacks) {
        debugPrintStack(
          label: 'API request origin [$requestId] GET $uri',
          maxFrames: 30,
        );
      }
    }

    late final http.Response response;
    try {
      response = await _httpClient
          .get(
            uri,
            headers: {
              'Accept': 'application/json',
              'X-Request-Id': requestId,
            },
          )
          .timeout(_timeout);
    } catch (error) {
      if (kDebugMode) {
        debugPrint(
          'API xx [$requestId] GET $uri failed after '
          '${stopwatch.elapsedMilliseconds} ms: $error',
        );
      }
      rethrow;
    }

    if (kDebugMode) {
      final backendRequestId = response.headers['x-request-id'] ?? requestId;
      debugPrint(
        'API <- [$backendRequestId] GET $uri -> ${response.statusCode} '
        '(${stopwatch.elapsedMilliseconds} ms)',
      );
    }

    final payload = response.body.isEmpty
        ? null
        : jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return payload;
    }

    final problem = payload is Map<String, dynamic> ? payload : null;
    throw ApiException(
      statusCode: response.statusCode,
      code: problem?['code'] as String?,
      message:
          problem?['detail'] as String? ??
          'Backend request failed with status ${response.statusCode}',
    );
  }

  Uri _resolve(String path) {
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$normalizedBase$normalizedPath');
  }

  String _createRequestId() {
    final sequence = _requestSequence++;
    return 'flutter-${DateTime.now().microsecondsSinceEpoch}-$sequence';
  }
}
