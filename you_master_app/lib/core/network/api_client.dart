import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:you_master_app/core/network/api_exception.dart';

class ApiClient {
  ApiClient(
    this._httpClient, {
    required this.baseUrl,
    this.traceRequestStacks = false,
  });

  final String baseUrl;
  final bool traceRequestStacks;
  final http.Client _httpClient;
  String? _accessToken;
  Future<bool> Function()? _unauthorizedHandler;
  Future<bool>? _refreshInFlight;

  void setAccessToken(String? token) => _accessToken = token;
  void setUnauthorizedHandler(Future<bool> Function()? handler) =>
      _unauthorizedHandler = handler;

  Map<String, String> _headers({bool json = false}) => {
    'Accept': 'application/json',
    if (json) 'Content-Type': 'application/json',
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };

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

  Future<Map<String, Object?>> putObject(
    String path,
    Map<String, Object?> body,
  ) async {
    final uri = _resolve(path);
    final requestId = _createRequestId();
    final stopwatch = Stopwatch()..start();

    if (kDebugMode) {
      debugPrint('API -> [$requestId] PUT $uri');
    }

    final response = await _sendWithRefresh(
      () => _httpClient
          .put(
            uri,
            headers: {..._headers(json: true), 'X-Request-Id': requestId},
            body: jsonEncode(body),
          )
          .timeout(_timeout),
      allowRefresh: !path.startsWith('/api/v1/auth/'),
    );

    if (kDebugMode) {
      debugPrint(
        'API <- [${response.headers['x-request-id'] ?? requestId}] '
        'PUT $uri -> ${response.statusCode} '
        '(${stopwatch.elapsedMilliseconds} ms)',
      );
    }

    final payload = response.body.isEmpty
        ? null
        : jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (payload case final Map<String, dynamic> object) return object;
      throw const FormatException('Expected a JSON object');
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

  Future<Map<String, Object?>> postObject(
    String path,
    Map<String, Object?> body,
  ) async {
    final uri = _resolve(path);
    final requestId = _createRequestId();
    final stopwatch = Stopwatch()..start();
    if (kDebugMode) debugPrint('API -> [$requestId] POST $uri');
    final response = await _sendWithRefresh(
      () => _httpClient
          .post(
            uri,
            headers: {..._headers(json: true), 'X-Request-Id': requestId},
            body: jsonEncode(body),
          )
          .timeout(_timeout),
      allowRefresh: !path.startsWith('/api/v1/auth/'),
    );
    if (kDebugMode) {
      debugPrint(
        'API <- [${response.headers['x-request-id'] ?? requestId}] '
        'POST $uri -> ${response.statusCode} (${stopwatch.elapsedMilliseconds} ms)',
      );
    }
    final payload = response.body.isEmpty
        ? null
        : jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (payload case final Map<String, dynamic> object) return object;
      throw const FormatException('Expected a JSON object');
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
      response = await _sendWithRefresh(
        () => _httpClient
            .get(uri, headers: {..._headers(), 'X-Request-Id': requestId})
            .timeout(_timeout),
        allowRefresh: !path.startsWith('/api/v1/auth/'),
      );
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

  Future<http.Response> _sendWithRefresh(
    Future<http.Response> Function() send, {
    required bool allowRefresh,
  }) async {
    var response = await send();
    if (response.statusCode != 401 ||
        !allowRefresh ||
        _unauthorizedHandler == null) {
      return response;
    }
    final inFlight = _refreshInFlight ??= _unauthorizedHandler!();
    final refreshed = await inFlight;
    if (identical(inFlight, _refreshInFlight)) _refreshInFlight = null;
    if (refreshed) response = await send();
    return response;
  }

  String _createRequestId() {
    final sequence = _requestSequence++;
    return 'flutter-${DateTime.now().microsecondsSinceEpoch}-$sequence';
  }
}
