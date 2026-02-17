import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/connectivity/connectivity_provider.dart';

/// Intercepteur qui détecte les échecs réseau sur les requêtes POST
/// de transfert et notifie l'utilisateur de passer en mode hors ligne.
///
/// Note : L'enfilement réel se fait via OfflineModeManager.queueTransfer()
/// dans le flow UI. Cet intercepteur marque les erreurs réseau pour
/// permettre au code appelant de basculer vers la file d'attente.
class OfflineQueueInterceptor extends Interceptor {
  final Ref _ref;

  /// Endpoints éligibles à la file d'attente hors ligne
  static const _queueableEndpoints = [
    '/transfers/internal',
    '/transfers/external',
  ];

  OfflineQueueInterceptor(this._ref);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final isNetworkError = err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout;

    final isQueueable = _queueableEndpoints.any(
      (ep) => err.requestOptions.path.contains(ep),
    );

    if (isNetworkError && isQueueable) {
      if (kDebugMode) {
        debugPrint('[OfflineQueue] Échec réseau sur ${err.requestOptions.path} — éligible à la file d\'attente');
      }

      // Marquer comme hors ligne si pas déjà fait
      final connectivity = _ref.read(connectivityProvider);
      if (connectivity.isOnline) {
        // Force refresh connectivity state
        _ref.read(connectivityProvider.notifier).refreshPendingCount();
      }

      // Enrichir l'erreur pour que le code appelant sache qu'il peut enqueue
      handler.next(DioException(
        requestOptions: err.requestOptions,
        type: err.type,
        error: err.error,
        response: err.response,
        message: 'OFFLINE_QUEUEABLE: ${err.message}',
      ));
      return;
    }

    handler.next(err);
  }
}

/// Provider pour l'intercepteur de file d'attente hors ligne
final offlineQueueInterceptorProvider = Provider<OfflineQueueInterceptor>((ref) {
  return OfflineQueueInterceptor(ref);
});
