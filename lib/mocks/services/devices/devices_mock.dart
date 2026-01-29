/// Devices Mock Implementation
///
/// Mock handlers for device management endpoints.
library;

import 'package:dio/dio.dart';
import '../../base/api_contract.dart';
import '../../base/mock_interceptor.dart';

/// Devices mock state
class DevicesMockState {
  static final List<Map<String, dynamic>> devices = [
    {
      'id': 'device-1',
      'device_identifier': 'iphone-15-pro-123',
      'brand': 'Apple',
      'model': 'iPhone 15 Pro',
      'os': 'iOS',
      'os_version': '17.2',
      'app_version': '1.0.0',
      'platform': 'ios',
      'is_trusted': true,
      'trusted_at': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
      'is_active': true,
      'last_login_at': DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String(),
      'last_ip_address': '102.176.45.123',
      'login_count': 45,
    },
    {
      'id': 'device-2',
      'device_identifier': 'macbook-pro-456',
      'brand': 'Apple',
      'model': 'MacBook Pro',
      'os': 'macOS',
      'os_version': '14.2',
      'app_version': '1.0.0',
      'platform': 'web',
      'is_trusted': true,
      'trusted_at': DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
      'is_active': true,
      'last_login_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      'last_ip_address': '102.176.45.123',
      'login_count': 23,
    },
    {
      'id': 'device-3',
      'device_identifier': 'samsung-s23-789',
      'brand': 'Samsung',
      'model': 'Galaxy S23',
      'os': 'Android',
      'os_version': '14',
      'app_version': '1.0.0',
      'platform': 'android',
      'is_trusted': false,
      'trusted_at': null,
      'is_active': true,
      'last_login_at': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      'last_ip_address': '41.85.162.74',
      'login_count': 8,
    },
  ];

  static void reset() {
    // Reset to initial state if needed
  }

  static Map<String, dynamic>? findDevice(String id) {
    try {
      return devices.firstWhere((device) => device['id'] == id);
    } catch (e) {
      return null;
    }
  }

  static void removeDevice(String id) {
    devices.removeWhere((device) => device['id'] == id);
  }

  static void trustDevice(String id) {
    final device = findDevice(id);
    if (device != null) {
      device['is_trusted'] = true;
      device['trusted_at'] = DateTime.now().toIso8601String();
    }
  }
}

/// Devices mock registration
class DevicesMock {
  static void register(MockInterceptor interceptor) {
    // GET /api/v1/devices - Get all devices
    interceptor.register(
      method: 'GET',
      path: '/api/v1/devices',
      handler: _handleGetDevices,
    );

    // POST /api/v1/devices/:id/trust - Trust a device
    interceptor.register(
      method: 'POST',
      path: r'/api/v1/devices/[\w-]+/trust',
      handler: _handleTrustDevice,
    );

    // DELETE /api/v1/devices/:id - Revoke/remove a device
    interceptor.register(
      method: 'DELETE',
      path: r'/api/v1/devices/[\w-]+',
      handler: _handleRemoveDevice,
    );
  }

  /// Handle get all devices
  static Future<MockResponse> _handleGetDevices(RequestOptions options) async {
    return MockResponse.success({
      'devices': DevicesMockState.devices,
    });
  }

  /// Handle trust device
  static Future<MockResponse> _handleTrustDevice(RequestOptions options) async {
    final deviceId = options.path.split('/')[4];
    final device = DevicesMockState.findDevice(deviceId);

    if (device == null) {
      return MockResponse.notFound('Device not found');
    }

    DevicesMockState.trustDevice(deviceId);
    final updatedDevice = DevicesMockState.findDevice(deviceId);

    return MockResponse.success(updatedDevice);
  }

  /// Handle remove device
  static Future<MockResponse> _handleRemoveDevice(RequestOptions options) async {
    final deviceId = options.path.split('/')[4];
    final device = DevicesMockState.findDevice(deviceId);

    if (device == null) {
      return MockResponse.notFound('Device not found');
    }

    DevicesMockState.removeDevice(deviceId);

    return MockResponse.success({
      'success': true,
      'message': 'Device removed successfully',
    });
  }
}
