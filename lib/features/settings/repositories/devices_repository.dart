import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/domain/entities/device.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

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
    String? os,
    String? deviceName,
    String? osVersion,
    String? appVersion,
    String? fcmToken,
    String? locale,
    Map<String, dynamic>? metadata,
  }) async {
    final deviceMetadata = {if (locale != null) 'locale': locale, ...?metadata};

    final response = await _dio.post(
      '/devices/register',
      data: {
        'deviceIdentifier': deviceId,
        'platform': platform,
        if (deviceName != null) 'deviceName': deviceName,
        if (model != null) 'model': model,
        if (brand != null) 'brand': brand,
        if (os != null) 'os': os,
        if (osVersion != null) 'osVersion': osVersion,
        if (appVersion != null) 'appVersion': appVersion,
        if (fcmToken != null) 'fcmToken': fcmToken,
        if (deviceMetadata.isNotEmpty) 'metadata': deviceMetadata,
      },
    );
    return Device.fromJson(response.data as Map<String, dynamic>);
  }

  /// Get all active devices for the current user
  Future<List<Device>> getDevices() async {
    final response = await _dio.get('/devices');
    final raw = response.data;
    final List<dynamic> devicesJson;
    if (raw is Map<String, dynamic>) {
      devicesJson =
          (raw['devices'] ?? raw['data'] ?? raw['items']) as List? ?? [];
    } else if (raw is List) {
      devicesJson = raw;
    } else {
      devicesJson = [];
    }
    return devicesJson.map((json) => Device.fromJson(json)).toList();
  }

  /// Trust a device
  Future<void> trustDevice(String deviceId) async {
    await _dio.post('/devices/$deviceId/trust');
  }

  /// Remove trust from a device
  Future<void> untrustDevice(String deviceId) async {
    await _dio.post('/devices/$deviceId/untrust');
  }

  /// Rename a device
  Future<void> renameDevice(String deviceId, String name) async {
    await _dio.post('/devices/$deviceId/rename', data: {'name': name});
  }

  /// Revoke/remove a device
  Future<void> revokeDevice(String deviceId) async {
    await _dio.delete('/devices/$deviceId');
  }

  /// Revoke all devices for the current account. Backend route is DELETE /devices.
  Future<void> revokeAllDevices() async {
    await _dio.delete('/devices');
  }
}

/// Provider for DevicesRepository
final devicesRepositoryProvider = Provider<DevicesRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return DevicesRepository(dio);
});
