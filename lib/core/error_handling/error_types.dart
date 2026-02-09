import 'package:dio/dio.dart';

/// Error severity levels for reporting
enum ErrorSeverity {
  /// Informational - not an error but worth tracking
  info,

  /// Warning - something unexpected but handled
  warning,

  /// Error - a real error that was handled
  error,

  /// Fatal - critical error that prevents app operation
  fatal,
}

/// Base class for app-specific errors
abstract class AppError implements Exception {
  const AppError(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => code != null ? '[$code] $message' : message;
}

/// Network-related errors
class NetworkError extends AppError {
  const NetworkError(
    super.message, {
    super.code,
    this.statusCode,
    this.endpoint,
  });

  final int? statusCode;
  final String? endpoint;

  factory NetworkError.fromDioException(DioException e) {
    final statusCode = e.response?.statusCode;
    final endpoint = e.requestOptions.path;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return NetworkError(
          'Connection timeout. Please check your internet connection.',
          code: 'TIMEOUT',
          statusCode: statusCode,
          endpoint: endpoint,
        );

      case DioExceptionType.sendTimeout:
        return NetworkError(
          'Request timeout. Please try again.',
          code: 'SEND_TIMEOUT',
          statusCode: statusCode,
          endpoint: endpoint,
        );

      case DioExceptionType.receiveTimeout:
        return NetworkError(
          'Server response timeout. Please try again.',
          code: 'RECEIVE_TIMEOUT',
          statusCode: statusCode,
          endpoint: endpoint,
        );

      case DioExceptionType.badResponse:
        final message = _getErrorMessageFromResponse(e.response);
        return NetworkError(
          message,
          code: 'HTTP_$statusCode',
          statusCode: statusCode,
          endpoint: endpoint,
        );

      case DioExceptionType.cancel:
        return NetworkError(
          'Request was cancelled.',
          code: 'CANCELLED',
          statusCode: statusCode,
          endpoint: endpoint,
        );

      case DioExceptionType.connectionError:
        return NetworkError(
          'No internet connection. Please check your network.',
          code: 'NO_CONNECTION',
          statusCode: statusCode,
          endpoint: endpoint,
        );

      default:
        return NetworkError(
          'Network error occurred. Please try again.',
          code: 'UNKNOWN',
          statusCode: statusCode,
          endpoint: endpoint,
        );
    }
  }

  static String _getErrorMessageFromResponse(Response? response) {
    if (response == null) return 'Server error occurred.';

    final statusCode = response.statusCode;
    final data = response.data;

    // Try to extract error message from response
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['error'] ?? data['detail'];
      if (message != null) return message.toString();
    }

    // Fallback to status code messages
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Session expired. Please login again.';
      case 403:
        return 'Access denied. You do not have permission.';
      case 404:
        return 'Resource not found.';
      case 409:
        return 'Conflict. This action cannot be completed.';
      case 422:
        return 'Validation failed. Please check your input.';
      case 429:
        return 'Too many requests. Please wait a moment.';
      case 500:
        return 'Server error. Please try again later.';
      case 502:
        return 'Service temporarily unavailable.';
      case 503:
        return 'Service under maintenance.';
      default:
        return 'Server error occurred. Please try again.';
    }
  }
}

/// Authentication errors
class AuthError extends AppError {
  const AuthError(super.message, {super.code});

  static const sessionExpired = AuthError(
    'Your session has expired. Please login again.',
    code: 'SESSION_EXPIRED',
  );

  static const invalidCredentials = AuthError(
    'Invalid credentials. Please try again.',
    code: 'INVALID_CREDENTIALS',
  );

  static const accountLocked = AuthError(
    'Account locked. Please contact support.',
    code: 'ACCOUNT_LOCKED',
  );
}

/// Validation errors
class ValidationError extends AppError {
  const ValidationError(
    super.message, {
    super.code,
    this.field,
  });

  final String? field;
}

/// Business logic errors
class BusinessError extends AppError {
  const BusinessError(super.message, {super.code});

  static const insufficientBalance = BusinessError(
    'Insufficient balance for this transaction.',
    code: 'INSUFFICIENT_BALANCE',
  );

  static const dailyLimitExceeded = BusinessError(
    'Daily transaction limit exceeded.',
    code: 'DAILY_LIMIT_EXCEEDED',
  );

  static const invalidRecipient = BusinessError(
    'Invalid recipient. Please check the details.',
    code: 'INVALID_RECIPIENT',
  );
}

/// Storage errors
class StorageError extends AppError {
  const StorageError(super.message, {super.code});

  static const readFailed = StorageError(
    'Failed to read data from storage.',
    code: 'READ_FAILED',
  );

  static const writeFailed = StorageError(
    'Failed to save data to storage.',
    code: 'WRITE_FAILED',
  );
}

/// Biometric errors
class BiometricError extends AppError {
  const BiometricError(super.message, {super.code});

  static const notAvailable = BiometricError(
    'Biometric authentication is not available on this device.',
    code: 'NOT_AVAILABLE',
  );

  static const notEnrolled = BiometricError(
    'No biometric data enrolled. Please set up in device settings.',
    code: 'NOT_ENROLLED',
  );

  static const authenticationFailed = BiometricError(
    'Biometric authentication failed. Please try again.',
    code: 'AUTH_FAILED',
  );
}

/// Camera/Media errors
class MediaError extends AppError {
  const MediaError(super.message, {super.code});

  static const cameraNotAvailable = MediaError(
    'Camera is not available.',
    code: 'CAMERA_NOT_AVAILABLE',
  );

  static const permissionDenied = MediaError(
    'Camera permission denied. Please enable in settings.',
    code: 'PERMISSION_DENIED',
  );

  static const imageQualityPoor = MediaError(
    'Image quality is not acceptable. Please try again.',
    code: 'POOR_QUALITY',
  );
}

/// QR Code errors
class QRCodeError extends AppError {
  const QRCodeError(super.message, {super.code});

  static const invalidFormat = QRCodeError(
    'Invalid QR code format.',
    code: 'INVALID_FORMAT',
  );

  static const scanFailed = QRCodeError(
    'Failed to scan QR code. Please try again.',
    code: 'SCAN_FAILED',
  );
}

/// Extension to check error types
extension ErrorTypeCheck on Object {
  bool get isNetworkError => this is NetworkError || this is DioException;
  bool get isAuthError => this is AuthError;
  bool get isValidationError => this is ValidationError;
  bool get isBusinessError => this is BusinessError;

  /// Get user-friendly error message
  String get userFriendlyMessage {
    if (this is AppError) {
      return (this as AppError).message;
    }
    if (this is DioException) {
      return NetworkError.fromDioException(this as DioException).message;
    }
    return 'An unexpected error occurred. Please try again.';
  }
}
