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
    final response = await _dio.post('/devices/register', data: {
      'deviceId': deviceId,
      'platform': platform,
      if (model != null) 'model': model,
      if (brand != null) 'brand': brand,
      if (osVersion != null) 'osVersion': osVersion,
      if (appVersion != null) 'appVersion': appVersion,
      if (fcmToken != null) 'fcmToken': fcmToken,
      if (locale != null) 'locale': locale,
    });
    return Device.fromJson(response.data);
  }

  /// Get all active devices for the current user
  Future<List<Device>> getDevices() async {
    final response = await _dio.get('/devices');
    final List<dynamic> devicesJson = response.data['devices'] ?? [];
    return devicesJson.map((json) => Device.fromJson(json)).toList();
  }

  /// Trust a device
  Future<Device> trustDevice(String deviceId) async {
    final response = await _dio.post('/devices/$deviceId/trust');
    return Device.fromJson(response.data);
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
