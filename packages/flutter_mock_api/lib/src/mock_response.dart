/// Wrapper for mock HTTP responses.
///
/// Provides factory constructors for common HTTP response patterns.
///
/// ```dart
/// // Success with data
/// MockResponse.success({'id': '123', 'name': 'John'});
///
/// // Created (201)
/// MockResponse.created({'id': '456'});
///
/// // Error responses
/// MockResponse.badRequest('Invalid email format');
/// MockResponse.unauthorized('Token expired');
/// MockResponse.notFound('User not found');
/// MockResponse.serverError('Database connection failed');
/// ```
class MockResponse<T> {
  /// HTTP status code (200, 201, 400, 401, 404, 500, etc.)
  final int statusCode;

  /// Response body data
  final T? data;

  /// Error message for non-success responses
  final String? errorMessage;

  /// Optional response headers
  final Map<String, String>? headers;

  /// Additional delay for this specific response
  final Duration delay;

  const MockResponse({
    this.statusCode = 200,
    this.data,
    this.errorMessage,
    this.headers,
    this.delay = Duration.zero,
  });

  /// Whether the response indicates success (2xx status code)
  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  /// Whether the response indicates a client error (4xx)
  bool get isClientError => statusCode >= 400 && statusCode < 500;

  /// Whether the response indicates a server error (5xx)
  bool get isServerError => statusCode >= 500;

  // ============================================
  // SUCCESS RESPONSES
  // ============================================

  /// 200 OK with data
  factory MockResponse.success(T data, {Duration? delay}) {
    return MockResponse(
      statusCode: 200,
      data: data,
      delay: delay ?? Duration.zero,
    );
  }

  /// 201 Created
  factory MockResponse.created(T data) {
    return MockResponse(statusCode: 201, data: data);
  }

  /// 204 No Content
  factory MockResponse.noContent() {
    return const MockResponse(statusCode: 204);
  }

  /// 202 Accepted (async processing)
  factory MockResponse.accepted([T? data]) {
    return MockResponse(statusCode: 202, data: data);
  }

  // ============================================
  // CLIENT ERROR RESPONSES
  // ============================================

  /// 400 Bad Request
  factory MockResponse.badRequest(String message) {
    return MockResponse(statusCode: 400, errorMessage: message);
  }

  /// 401 Unauthorized
  factory MockResponse.unauthorized([String? message]) {
    return MockResponse(
      statusCode: 401,
      errorMessage: message ?? 'Unauthorized',
    );
  }

  /// 403 Forbidden
  factory MockResponse.forbidden([String? message]) {
    return MockResponse(
      statusCode: 403,
      errorMessage: message ?? 'Forbidden',
    );
  }

  /// 404 Not Found
  factory MockResponse.notFound([String? message]) {
    return MockResponse(
      statusCode: 404,
      errorMessage: message ?? 'Not found',
    );
  }

  /// 409 Conflict
  factory MockResponse.conflict([String? message]) {
    return MockResponse(
      statusCode: 409,
      errorMessage: message ?? 'Conflict',
    );
  }

  /// 422 Unprocessable Entity (validation error)
  factory MockResponse.validationError(String message, [Map<String, dynamic>? errors]) {
    return MockResponse(
      statusCode: 422,
      errorMessage: message,
      data: errors != null ? {'errors': errors} as T : null,
    );
  }

  /// 429 Too Many Requests (rate limited)
  factory MockResponse.rateLimited([String? message, int? retryAfterSeconds]) {
    return MockResponse(
      statusCode: 429,
      errorMessage: message ?? 'Too many requests',
      headers: retryAfterSeconds != null
          ? {'Retry-After': retryAfterSeconds.toString()}
          : null,
    );
  }

  // ============================================
  // SERVER ERROR RESPONSES
  // ============================================

  /// 500 Internal Server Error
  factory MockResponse.serverError([String? message]) {
    return MockResponse(
      statusCode: 500,
      errorMessage: message ?? 'Internal server error',
    );
  }

  /// 502 Bad Gateway
  factory MockResponse.badGateway([String? message]) {
    return MockResponse(
      statusCode: 502,
      errorMessage: message ?? 'Bad gateway',
    );
  }

  /// 503 Service Unavailable
  factory MockResponse.serviceUnavailable([String? message]) {
    return MockResponse(
      statusCode: 503,
      errorMessage: message ?? 'Service unavailable',
    );
  }

  /// 504 Gateway Timeout
  factory MockResponse.gatewayTimeout([String? message]) {
    return MockResponse(
      statusCode: 504,
      errorMessage: message ?? 'Gateway timeout',
    );
  }

  @override
  String toString() {
    return 'MockResponse(statusCode: $statusCode, data: $data, error: $errorMessage)';
  }
}
