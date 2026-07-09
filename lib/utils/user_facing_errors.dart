import 'package:dio/dio.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

/// Maps thrown values to messages safe to display in the UI.
class UserFacingErrors {
  UserFacingErrors._();

  static const String fallbackMessage =
      'Une erreur est survenue. Veuillez réessayer.';

  /// Returns a user-safe error message for [error].
  static String message(Object error) {
    if (error is ApiException) {
      return _apiMessage(error);
    }

    if (error is DioException) {
      return _fromDio(error);
    }

    if (error is Exception) {
      return _fromException(error);
    }

    if (error is String) {
      final text = error.trim();
      if (text.isNotEmpty && !_looksTechnical(text)) {
        return text;
      }
    }

    return fallbackMessage;
  }

  static String _apiMessage(ApiException error) {
    final text = error.message.trim();
    if (text.isNotEmpty && !_looksTechnical(text)) {
      return text;
    }

    return _statusMessage(error.statusCode);
  }

  static String _fromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'La connexion a expiré. Veuillez réessayer.';
      case DioExceptionType.connectionError:
        return 'Pas de connexion internet. Vérifiez votre réseau.';
      case DioExceptionType.cancel:
        return 'La requête a été annulée.';
      default:
        break;
    }

    final wrapped = error.error;
    if (wrapped is ApiException) {
      return message(wrapped);
    }

    if (error.response?.statusCode != null) {
      return _statusMessage(error.response!.statusCode);
    }

    return fallbackMessage;
  }

  static String _fromException(Exception error) {
    if (error is ApiException) {
      return message(error);
    }

    final raw = error.toString();
    final stripped = raw
        .replaceFirst(RegExp(r'^[A-Za-z]+Exception:\s*'), '')
        .trim();

    if (stripped.isNotEmpty && !_looksTechnical(stripped)) {
      return stripped;
    }

    return fallbackMessage;
  }

  static String _statusMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Requête invalide. Vérifiez les informations saisies.';
      case 401:
        return 'Votre session a expiré. Veuillez vous reconnecter.';
      case 403:
        return 'Accès refusé.';
      case 404:
        return 'Ressource introuvable.';
      case 408:
        return 'La connexion a expiré. Veuillez réessayer.';
      case 409:
        return 'Conflit détecté. Veuillez réessayer.';
      case 413:
        return 'Fichier trop volumineux. Choisissez un fichier plus petit.';
      case 422:
        return 'Certaines informations sont invalides.';
      case 429:
        return 'Trop de tentatives. Patientez un moment.';
      case 500:
        return 'Erreur serveur. Veuillez réessayer.';
      case 502:
      case 503:
        return 'Service temporairement indisponible.';
      case 504:
        return 'Le serveur met trop de temps à répondre.';
      default:
        if (statusCode != null && statusCode >= 500) {
          return 'Erreur serveur. Veuillez réessayer.';
        }
        return fallbackMessage;
    }
  }

  static bool _looksTechnical(String text) {
    final lower = text.toLowerCase();
    return lower.contains('exception') ||
        lower.contains('stacktrace') ||
        lower.contains('stack trace') ||
        lower.startsWith('dart:') ||
        RegExp(r'#\d+\s').hasMatch(text) ||
        text.contains('\n');
  }
}