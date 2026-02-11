/// Base application exception.
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException(this.message, {this.code, this.details});

  @override
  String toString() => 'AppException($code): $message';
}

/// Network-related exceptions.
class NetworkException extends AppException {
  const NetworkException([String message = 'Network error'])
      : super(message, code: 'NETWORK_ERROR');
}

class TimeoutException extends AppException {
  const TimeoutException([String message = 'Request timed out'])
      : super(message, code: 'TIMEOUT');
}

class ServerException extends AppException {
  final int? statusCode;

  const ServerException(
    super.message, {
    this.statusCode,
    super.details,
  }) : super(code: 'SERVER_ERROR');
}

/// Auth exceptions.
class UnauthorizedException extends AppException {
  const UnauthorizedException([String message = 'Unauthorized'])
      : super(message, code: 'UNAUTHORIZED');
}

class SessionExpiredException extends AppException {
  const SessionExpiredException()
      : super('Session expired. Please log in again.',
            code: 'SESSION_EXPIRED');
}

/// Business logic exceptions.
class InsufficientBalanceException extends AppException {
  final double available;
  final double required_;

  const InsufficientBalanceException({
    required this.available,
    required this.required_,
  }) : super(
          'Insufficient balance. Available: $available, Required: $required_',
          code: 'INSUFFICIENT_BALANCE',
        );
}

class TransactionLimitException extends AppException {
  final String limitType;
  final double limit;

  const TransactionLimitException({
    required this.limitType,
    required this.limit,
  }) : super(
          '$limitType limit exceeded. Maximum: $limit',
          code: 'LIMIT_EXCEEDED',
        );
}

class PinLockedException extends AppException {
  final Duration lockoutDuration;

  const PinLockedException(this.lockoutDuration)
      : super(
          'Too many PIN attempts. Try again later.',
          code: 'PIN_LOCKED',
        );
}

class KycRequiredException extends AppException {
  final String requiredLevel;

  const KycRequiredException(this.requiredLevel)
      : super(
          'KYC verification ($requiredLevel) required for this action.',
          code: 'KYC_REQUIRED',
        );
}

/// Validation exception.
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException(
    super.message, {
    this.fieldErrors,
  }) : super(code: 'VALIDATION_ERROR');
}
