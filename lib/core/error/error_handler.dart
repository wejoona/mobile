import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:usdc_wallet/core/exceptions/app_exception.dart';
import 'package:usdc_wallet/core/l10n/app_strings.dart';

/// Centralized error handler. Converts exceptions to user-facing messages.
class ErrorHandler {
  /// Convert any exception to a user-friendly message.
  static String getMessage(Object error) {
    if (error is AppException) return error.message;

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          return AppStrings.networkError;
        case DioExceptionType.badResponse:
          return _handleStatusCode(error.response?.statusCode);
        case DioExceptionType.cancel:
          return 'Requête annulée';
        default:
          return AppStrings.genericError;
      }
    }

    if (error is FormatException) return 'Données invalides';

    if (kDebugMode) debugPrint('[ErrorHandler] Unhandled: $error');
    return AppStrings.genericError;
  }

  static String _handleStatusCode(int? code) {
    switch (code) {
      case 400: return 'Requête invalide';
      case 401: return AppStrings.sessionExpired;
      case 403: return 'Accès refusé';
      case 404: return 'Ressource introuvable';
      case 409: return 'Conflit de données';
      case 422: return 'Données de formulaire invalides';
      case 429: return 'Trop de requêtes. Patientez.';
      case 500: return AppStrings.serverError;
      case 502: return 'Service temporairement indisponible';
      case 503: return 'Service en maintenance';
      default: return AppStrings.serverError;
    }
  }

  /// Extract field-level validation errors from API response.
  static Map<String, String> getFieldErrors(DioException error) {
    try {
      final data = error.response?.data;
      if (data is Map && data.containsKey('errors')) {
        final errors = data['errors'] as Map<String, dynamic>;
        return errors.map((k, v) => MapEntry(k, v.toString()));
      }
    } catch (_) {}
    return {};
  }
}
