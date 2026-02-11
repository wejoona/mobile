/// Standardized API error response.
class ApiErrorResponse {
  final String code;
  final String message;
  final Map<String, dynamic>? details;
  final String? requestId;

  const ApiErrorResponse({
    required this.code,
    required this.message,
    this.details,
    this.requestId,
  });

  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) {
    return ApiErrorResponse(
      code: json['code'] as String? ?? 'UNKNOWN_ERROR',
      message: json['message'] as String? ?? 'An unexpected error occurred',
      details: json['details'] as Map<String, dynamic>?,
      requestId: json['requestId'] as String?,
    );
  }

  @override
  String toString() => 'ApiError($code): $message';
}
