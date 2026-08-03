abstract final class AppEnvironment {
  static const useRemoteApi = bool.fromEnvironment(
    'USE_REMOTE_API',
    defaultValue: false,
  );

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  static const traceApiRequestStacks = bool.fromEnvironment(
    'TRACE_API_REQUEST_STACKS',
    defaultValue: false,
  );
}
