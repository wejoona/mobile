import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Résultat de la détection de changement SIM
class SimChangeResult {
  final bool simChanged;
  final String? previousCarrier;
  final String? currentCarrier;
  final DateTime? lastChangeDate;
  final int changeCountLast30Days;

  const SimChangeResult({
    required this.simChanged,
    this.previousCarrier,
    this.currentCarrier,
    this.lastChangeDate,
    this.changeCountLast30Days = 0,
  });
}

/// Service de détection de changement de carte SIM.
///
/// Détecte les changements de SIM qui pourraient indiquer
/// un SIM swap (attaque par échange de SIM).
class SimChangeDetectionService {
  static const _tag = 'SimChangeDetection';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;
  String? _lastKnownSimId;

  SimChangeDetectionService({required Dio dio}) : _dio = dio;

  /// Vérifier si la SIM a changé
  Future<SimChangeResult> checkSimChange({
    required String currentSimId,
    required String phoneNumber,
  }) async {
    final changed = _lastKnownSimId != null && _lastKnownSimId != currentSimId;
    _lastKnownSimId = currentSimId;

    if (changed) {
      _log.warning('SIM change detected for $phoneNumber');
      // Notifier le serveur
      try {
        await _dio.post('/risk/sim-change', data: {
          'phoneNumber': phoneNumber,
          'newSimId': currentSimId,
        });
      } catch (e) {
        _log.error('Failed to report SIM change', e);
      }
    }

    return SimChangeResult(
      simChanged: changed,
      lastChangeDate: changed ? DateTime.now() : null,
    );
  }

  /// Vérifier le statut SIM swap via l'opérateur
  Future<SimChangeResult> verifyWithCarrier({
    required String phoneNumber,
  }) async {
    try {
      final response = await _dio.post('/risk/sim-swap/verify', data: {
        'phoneNumber': phoneNumber,
      });
      final data = response.data as Map<String, dynamic>;
      return SimChangeResult(
        simChanged: data['recentSwap'] as bool? ?? false,
        previousCarrier: data['previousCarrier'] as String?,
        currentCarrier: data['currentCarrier'] as String?,
        lastChangeDate: data['lastChangeDate'] != null
            ? DateTime.parse(data['lastChangeDate'] as String) : null,
        changeCountLast30Days: data['changeCount30d'] as int? ?? 0,
      );
    } catch (e) {
      _log.error('Carrier SIM swap verification failed', e);
      return const SimChangeResult(simChanged: false);
    }
  }
}

final simChangeDetectionProvider = Provider<SimChangeDetectionService>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
