import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

class DeviceIntelligence {
  final String deviceId;
  final int associatedAccounts;
  final bool isKnownFraudDevice;
  final double trustScore;
  final String? lastKnownLocation;
  final DateTime? firstSeenAt;
  final DateTime? lastSeenAt;

  const DeviceIntelligence({
    required this.deviceId,
    required this.associatedAccounts,
    required this.isKnownFraudDevice,
    required this.trustScore,
    this.lastKnownLocation,
    this.firstSeenAt,
    this.lastSeenAt,
  });

  factory DeviceIntelligence.fromJson(Map<String, dynamic> json) => DeviceIntelligence(
    deviceId: json['deviceId'] as String,
    associatedAccounts: json['associatedAccounts'] as int? ?? 0,
    isKnownFraudDevice: json['isKnownFraudDevice'] as bool? ?? false,
    trustScore: (json['trustScore'] as num?)?.toDouble() ?? 0.5,
    lastKnownLocation: json['lastKnownLocation'] as String?,
    firstSeenAt: json['firstSeenAt'] != null ? DateTime.parse(json['firstSeenAt'] as String) : null,
    lastSeenAt: json['lastSeenAt'] != null ? DateTime.parse(json['lastSeenAt'] as String) : null,
  );
}

/// Service de renseignement sur les appareils.
///
/// Interroge la base de données de renseignement pour
/// obtenir l'historique de confiance d'un appareil.
class DeviceIntelligenceService {
  static const _tag = 'DeviceIntelligence';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  DeviceIntelligenceService({required Dio dio}) : _dio = dio;

  Future<DeviceIntelligence?> getIntelligence({required String deviceId}) async {
    try {
      final response = await _dio.get('/fraud/device-intelligence/$deviceId');
      return DeviceIntelligence.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      _log.error('Device intelligence lookup failed', e);
      return null;
    }
  }

  Future<void> reportDevice({
    required String deviceId,
    required String reason,
  }) async {
    try {
      await _dio.post('/fraud/device-intelligence/report', data: {
        'deviceId': deviceId,
        'reason': reason,
      });
    } catch (e) {
      _log.error('Device report failed', e);
    }
  }
}

final deviceIntelligenceProvider = Provider<DeviceIntelligenceService>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
