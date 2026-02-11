import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Statut de liaison de l'appareil
enum DeviceBindingStatus { bound, pending, revoked, unknown }

/// Informations de liaison appareil
class DeviceBinding {
  final String deviceId;
  final String userId;
  final DeviceBindingStatus status;
  final DateTime boundAt;
  final String? deviceName;
  final String? platform;
  final bool isPrimary;

  const DeviceBinding({
    required this.deviceId,
    required this.userId,
    required this.status,
    required this.boundAt,
    this.deviceName,
    this.platform,
    this.isPrimary = false,
  });

  factory DeviceBinding.fromJson(Map<String, dynamic> json) => DeviceBinding(
    deviceId: json['deviceId'] as String,
    userId: json['userId'] as String,
    status: DeviceBindingStatus.values.byName(json['status'] as String),
    boundAt: DateTime.parse(json['boundAt'] as String),
    deviceName: json['deviceName'] as String?,
    platform: json['platform'] as String?,
    isPrimary: json['isPrimary'] as bool? ?? false,
  );
}

/// Service de liaison appareil-compte.
///
/// Associe un appareil à un compte utilisateur pour
/// empêcher l'accès depuis des appareils non autorisés.
class DeviceBindingService {
  static const _tag = 'DeviceBinding';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  DeviceBindingService({required Dio dio}) : _dio = dio;

  /// Lier l'appareil actuel au compte
  Future<DeviceBinding?> bindDevice({
    required String deviceId,
    required String deviceName,
    required String platform,
  }) async {
    try {
      final response = await _dio.post('/risk/device/bind', data: {
        'deviceId': deviceId,
        'deviceName': deviceName,
        'platform': platform,
      });
      return DeviceBinding.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      _log.error('Device binding failed', e);
      return null;
    }
  }

  /// Vérifier si l'appareil est lié
  Future<DeviceBindingStatus> checkBinding({required String deviceId}) async {
    try {
      final response = await _dio.get('/risk/device/binding/$deviceId');
      return DeviceBindingStatus.values.byName(
        (response.data as Map<String, dynamic>)['status'] as String);
    } catch (e) {
      _log.error('Binding check failed', e);
      return DeviceBindingStatus.unknown;
    }
  }

  /// Révoquer la liaison d'un appareil
  Future<bool> revokeBinding({required String deviceId}) async {
    try {
      await _dio.delete('/risk/device/binding/$deviceId');
      return true;
    } catch (e) {
      _log.error('Binding revocation failed', e);
      return false;
    }
  }

  /// Lister tous les appareils liés
  Future<List<DeviceBinding>> listBoundDevices() async {
    try {
      final response = await _dio.get('/risk/device/bindings');
      return (response.data as List)
          .map((e) => DeviceBinding.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _log.error('Failed to list bound devices', e);
      return [];
    }
  }
}

final deviceBindingProvider = Provider<DeviceBindingService>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
