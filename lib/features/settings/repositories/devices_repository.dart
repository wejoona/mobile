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

    final response = await _sendDeviceRequest(
      () => _dio.post(
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
      ),
    );
    return Device.fromJson(_deviceMapFromPayload(response.data));
  }

  /// Get all active devices for the current user
  Future<List<Device>> getDevices() async {
    final response = await _sendDeviceRequest(() => _dio.get('/devices'));
    final raw = _unwrapDevicePayload(response.data);
    final List<dynamic> devicesJson;
    if (raw is Map<String, dynamic>) {
      devicesJson =
          (raw['devices'] ?? raw['data'] ?? raw['items']) as List? ?? [];
    } else if (raw is List) {
      devicesJson = raw;
    } else {
      devicesJson = [];
    }
    return devicesJson.map(_deviceMapFromPayload).map(Device.fromJson).toList();
  }

  /// Trust a device
  Future<void> trustDevice(String deviceId) async {
    await _sendDeviceRequest(() => _dio.post('/devices/$deviceId/trust'));
  }

  /// Remove trust from a device
  Future<void> untrustDevice(String deviceId) async {
    await _sendDeviceRequest(() => _dio.post('/devices/$deviceId/untrust'));
  }

  /// Update the push token bound to a registered device.
  Future<void> updateFcmToken({
    required String deviceIdentifier,
    required String fcmToken,
  }) async {
    await _sendDeviceRequest(
      () => _dio.post(
        '/devices/fcm-token',
        data: {'deviceIdentifier': deviceIdentifier, 'fcmToken': fcmToken},
      ),
    );
  }

  /// Rename a device
  Future<void> renameDevice(String deviceId, String name) async {
    await _sendDeviceRequest(
      () => _dio.post('/devices/$deviceId/rename', data: {'name': name}),
    );
  }

  /// Revoke/remove a device
  Future<void> revokeDevice(String deviceId) async {
    await _sendDeviceRequest(() => _dio.delete('/devices/$deviceId'));
  }

  /// Revoke all devices for the current account. Backend route is DELETE /devices.
  Future<void> revokeAllDevices() async {
    await _sendDeviceRequest(() => _dio.delete('/devices'));
  }

  Future<Response<T>> _sendDeviceRequest<T>(
    Future<Response<T>> Function() request,
  ) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

/// Provider for DevicesRepository
final devicesRepositoryProvider = Provider<DevicesRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return DevicesRepository(dio);
});

Object? _unwrapDevicePayload(Object? raw) {
  if (raw is Map<String, dynamic>) {
    final data = raw['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
  } else if (raw is Map) {
    final map = Map<String, dynamic>.from(raw);
    final data = map['data'];
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
  }
  return raw;
}

Map<String, dynamic> _deviceMapFromPayload(Object? raw) {
  final unwrapped = _unwrapDevicePayload(raw);
  if (unwrapped is Map<String, dynamic>) {
    return unwrapped;
  }
  if (unwrapped is Map) {
    return Map<String, dynamic>.from(unwrapped);
  }
  return const {};
}
