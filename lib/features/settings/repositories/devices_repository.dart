import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api/api_client.dart';
import '../models/device.dart';

/// Repository for managing user devices
class DevicesRepository {
  final Dio _dio;

  DevicesRepository(this._dio);

  /// Get all active devices for the current user
  Future<List<Device>> getDevices() async {
    final response = await _dio.get('/api/v1/devices');
    final List<dynamic> devicesJson = response.data['devices'] ?? [];
    return devicesJson.map((json) => Device.fromJson(json)).toList();
  }

  /// Trust a device
  Future<Device> trustDevice(String deviceId) async {
    final response = await _dio.post('/api/v1/devices/$deviceId/trust');
    return Device.fromJson(response.data);
  }

  /// Revoke/remove a device
  Future<void> revokeDevice(String deviceId) async {
    await _dio.delete('/api/v1/devices/$deviceId');
  }
}

/// Provider for DevicesRepository
final devicesRepositoryProvider = Provider<DevicesRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return DevicesRepository(dio);
});
