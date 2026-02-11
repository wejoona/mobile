import 'package:dio/dio.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

/// Centralized Error Message Mapping
///
/// Maps API error codes, network errors, and exceptions to user-friendly
/// localized messages. Returns error message keys to be used with AppLocalizations.
///
/// Usage:
/// ```dart
/// try {
///   await sdk.wallet.getBalance();
/// } on ApiException catch (e) {
///   final errorKey = ErrorMessages.fromApiException(e);
///   AppToast.error(context, l10n.translate(errorKey));
/// }
/// ```
class ErrorMessages {
  /// Map API Exception to localized error message key
  static String fromApiException(ApiException exception) {
    // Check for specific error codes from backend
    if (exception.data != null && exception.data is Map) {
      final errorCode = exception.data['code'] as String?;
      final errorType = exception.data['type'] as String?;

      if (errorCode != null) {
        return _mapErrorCode(errorCode);
      }

      if (errorType != null) {
        return _mapErrorType(errorType);
      }
    }

    // Fall back to HTTP status code mapping
    if (exception.statusCode != null) {
      return _mapStatusCode(exception.statusCode!);
    }

    return 'error_generic';
  }

  /// Map Dio Exception to localized error message key
  static String fromDioException(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'error_timeout';

      case DioExceptionType.connectionError:
        return 'error_noInternet';

      case DioExceptionType.badResponse:
        if (exception.response?.statusCode != null) {
          return _mapStatusCode(exception.response!.statusCode!);
        }
        return 'error_serverError';

      case DioExceptionType.cancel:
        return 'error_requestCancelled';

      default:
        return 'error_generic';
    }
  }

  /// Map general Exception to localized error message key
  static String fromException(Exception exception) {
    if (exception is ApiException) {
      return fromApiException(exception);
    }

    if (exception is DioException) {
      return fromDioException(exception);
    }

    // Check exception message for common patterns
    final message = exception.toString().toLowerCase();

    if (message.contains('socket') || message.contains('network')) {
      return 'error_noInternet';
    }

    if (message.contains('timeout')) {
      return 'error_timeout';
    }

    if (message.contains('certificate') || message.contains('ssl')) {
      return 'error_sslError';
    }

    return 'error_generic';
  }

  /// Map backend error codes to localized keys
  static String _mapErrorCode(String code) {
    switch (code) {
      // Authentication errors
      case 'INVALID_OTP':
        return 'auth_error_invalidOtp';
      case 'OTP_EXPIRED':
        return 'error_otpExpired';
      case 'TOO_MANY_OTP_ATTEMPTS':
        return 'error_tooManyOtpAttempts';
      case 'INVALID_CREDENTIALS':
        return 'error_invalidCredentials';
      case 'ACCOUNT_LOCKED':
        return 'error_accountLocked';
      case 'ACCOUNT_SUSPENDED':
        return 'error_accountSuspended';
      case 'SESSION_EXPIRED':
        return 'error_sessionExpired';

      // KYC errors
      case 'KYC_REQUIRED':
        return 'error_kycRequired';
      case 'KYC_PENDING':
        return 'error_kycPending';
      case 'KYC_REJECTED':
        return 'error_kycRejected';
      case 'KYC_EXPIRED':
        return 'error_kycExpired';

      // Transaction errors
      case 'INSUFFICIENT_BALANCE':
      case 'INSUFFICIENT_FUNDS':
        return 'error_insufficientBalance';
      case 'AMOUNT_TOO_LOW':
        return 'error_amountTooLow';
      case 'AMOUNT_TOO_HIGH':
        return 'error_amountTooHigh';
      case 'DAILY_LIMIT_EXCEEDED':
        return 'error_dailyLimitExceeded';
      case 'MONTHLY_LIMIT_EXCEEDED':
        return 'error_monthlyLimitExceeded';
      case 'TRANSACTION_LIMIT_EXCEEDED':
        return 'error_transactionLimitExceeded';
      case 'DUPLICATE_TRANSACTION':
        return 'error_duplicateTransaction';

      // PIN errors
      case 'INVALID_PIN':
      case 'INCORRECT_PIN':
        return 'error_pinIncorrect';
      case 'PIN_LOCKED':
        return 'error_pinLocked';
      case 'PIN_TOO_WEAK':
        return 'error_pinTooWeak';

      // Beneficiary errors
      case 'BENEFICIARY_NOT_FOUND':
        return 'error_beneficiaryNotFound';
      case 'BENEFICIARY_LIMIT_REACHED':
        return 'error_beneficiaryLimitReached';

      // Provider errors
      case 'PROVIDER_UNAVAILABLE':
      case 'PROVIDER_DOWN':
        return 'error_providerUnavailable';
      case 'PROVIDER_TIMEOUT':
        return 'error_providerTimeout';
      case 'PROVIDER_MAINTENANCE':
        return 'error_providerMaintenance';

      // Rate limiting
      case 'RATE_LIMITED':
      case 'TOO_MANY_REQUESTS':
        return 'error_rateLimited';

      // Validation errors
      case 'INVALID_PHONE_NUMBER':
        return 'error_phoneInvalid';
      case 'INVALID_AMOUNT':
        return 'error_amountInvalid';
      case 'INVALID_ADDRESS':
        return 'error_invalidAddress';
      case 'INVALID_COUNTRY':
        return 'error_invalidCountry';

      // Device/Security errors
      case 'DEVICE_NOT_TRUSTED':
        return 'error_deviceNotTrusted';
      case 'DEVICE_LIMIT_REACHED':
        return 'error_deviceLimitReached';
      case 'BIOMETRIC_REQUIRED':
        return 'error_biometricRequired';

      default:
        return 'error_generic';
    }
  }

  /// Map error types to localized keys
  static String _mapErrorType(String type) {
    switch (type) {
      case 'NETWORK_ERROR':
        return 'error_network';
      case 'VALIDATION_ERROR':
        return 'error_validationFailed';
      case 'AUTHENTICATION_ERROR':
        return 'error_authenticationFailed';
      case 'AUTHORIZATION_ERROR':
        return 'error_accessDenied';
      case 'NOT_FOUND':
        return 'error_notFound';
      case 'CONFLICT':
        return 'error_conflict';
      case 'SERVER_ERROR':
        return 'error_serverError';
      default:
        return 'error_generic';
    }
  }

  /// Map HTTP status codes to localized keys
  static String _mapStatusCode(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'error_badRequest';
      case 401:
        return 'error_unauthorized';
      case 403:
        return 'error_accessDenied';
      case 404:
        return 'error_notFound';
      case 408:
        return 'error_timeout';
      case 409:
        return 'error_conflict';
      case 422:
        return 'error_validationFailed';
      case 429:
        return 'error_rateLimited';
      case 500:
        return 'error_serverError';
      case 502:
      case 503:
        return 'error_serviceUnavailable';
      case 504:
        return 'error_gatewayTimeout';
      default:
        if (statusCode >= 500) {
          return 'error_serverError';
        } else if (statusCode >= 400) {
          return 'error_badRequest';
        }
        return 'error_generic';
    }
  }

  /// Get actionable suggestion based on error
  static String? getActionSuggestion(String errorKey) {
    switch (errorKey) {
      case 'error_noInternet':
      case 'error_network':
        return 'error_suggestion_checkConnection';
      case 'error_timeout':
        return 'error_suggestion_tryAgain';
      case 'error_sessionExpired':
        return 'error_suggestion_loginAgain';
      case 'error_kycRequired':
        return 'error_suggestion_completeKyc';
      case 'error_insufficientBalance':
        return 'error_suggestion_addFunds';
      case 'error_dailyLimitExceeded':
      case 'error_monthlyLimitExceeded':
        return 'error_suggestion_waitOrUpgrade';
      case 'error_providerUnavailable':
      case 'error_providerMaintenance':
        return 'error_suggestion_tryLater';
      case 'error_pinLocked':
        return 'error_suggestion_resetPin';
      case 'error_rateLimited':
        return 'error_suggestion_slowDown';
      default:
        return null;
    }
  }

  /// Check if error should trigger logout
  static bool shouldLogout(String errorKey) {
    return errorKey == 'error_sessionExpired' ||
        errorKey == 'error_accountLocked' ||
        errorKey == 'error_accountSuspended' ||
        errorKey == 'error_unauthorized';
  }

  /// Check if error should show retry button
  static bool canRetry(String errorKey) {
    return errorKey == 'error_network' ||
        errorKey == 'error_noInternet' ||
        errorKey == 'error_timeout' ||
        errorKey == 'error_serverError' ||
        errorKey == 'error_serviceUnavailable' ||
        errorKey == 'error_gatewayTimeout' ||
        errorKey == 'error_providerTimeout';
  }

  /// Get error severity level
  static ErrorSeverity getSeverity(String errorKey) {
    // Critical - requires immediate action
    if (errorKey == 'error_accountLocked' ||
        errorKey == 'error_accountSuspended' ||
        errorKey == 'error_kycRejected') {
      return ErrorSeverity.critical;
    }

    // Warning - user action needed
    if (errorKey == 'error_kycRequired' ||
        errorKey == 'error_kycPending' ||
        errorKey == 'error_sessionExpired' ||
        errorKey == 'error_dailyLimitExceeded' ||
        errorKey == 'error_pinLocked') {
      return ErrorSeverity.warning;
    }

    // Info - temporary issue
    if (errorKey == 'error_noInternet' ||
        errorKey == 'error_timeout' ||
        errorKey == 'error_providerUnavailable') {
      return ErrorSeverity.info;
    }

    // Default to error
    return ErrorSeverity.error;
  }
}

/// Error severity levels
enum ErrorSeverity {
  info, // Temporary issues, can retry
  warning, // User action needed
  error, // Standard errors
  critical, // Account-level issues
}
