import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/features/settings/models/device.dart';

/// Repository for managing user devices
class DevicesRepository {
  final Dio _dio;

  DevicesRepository(this._dio);

  /// POST /api/v1/devices - Register current device
  Future<Device> registerDevice({
    required String deviceId,
    required String platform,
    String? model,
    String? brand,
    String? osVersion,
    String? appVersion,
    String? fcmToken,
    String? locale,
  }) async {
    final response = await _dio.post(
      '/devices/register',
      data: {
        'deviceIdentifier': deviceId,
        'platform': platform,
        if (model != null) 'model': model,
        if (brand != null) 'brand': brand,
        if (osVersion != null) 'osVersion': osVersion,
        if (appVersion != null) 'appVersion': appVersion,
        if (fcmToken != null) 'fcmToken': fcmToken,
      },
    );
    return Device.fromJson(response.data as Map<String, dynamic>);
  }

  /// Get all active devices for the current user
  Future<List<Device>> getDevices() async {
    final response = await _dio.get('/devices');
    final raw = response.data;
    final List devicesJson;
    if (raw is Map<String, dynamic>) {
      devicesJson = raw['devices'] as List? ?? raw['data'] as List? ?? [];
    } else if (raw is List) {
      devicesJson = raw;
    } else {
      devicesJson = [];
    }
    return devicesJson
        .map((json) => Device.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Trust a device
  Future<Device> trustDevice(String deviceId) async {
    final response = await _dio.post('/devices/$deviceId/trust');
    final raw = response.data;
    if (raw is Map<String, dynamic> && raw.containsKey('id')) {
      return Device.fromJson(raw);
    }
    final devices = await getDevices();
    return devices.firstWhere((device) => device.id == deviceId);
  }

  /// Revoke/remove a device
  Future<void> revokeDevice(String deviceId) async {
    await _dio.delete('/devices/$deviceId');
  }
}

/// Provider for DevicesRepository
final devicesRepositoryProvider = Provider<DevicesRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return DevicesRepository(dio);
});
