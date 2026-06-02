/// Devices Mock Implementation
///
/// Mock handlers for device management endpoints.
library;

import 'package:dio/dio.dart';
import 'package:usdc_wallet/mocks/base/api_contract.dart';
import 'package:usdc_wallet/mocks/base/mock_interceptor.dart';

/// Devices mock state
class DevicesMockState {
  static final List<Map<String, dynamic>> devices = _initialDevices();

  static void reset() {
    devices
      ..clear()
      ..addAll(_initialDevices());
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
      device['isTrusted'] = true;
      device['trustedAt'] = DateTime.now().toIso8601String();
    }
  }

  static void renameDevice(String id, String name) {
    final device = findDevice(id);
    if (device != null) {
      device['displayName'] = name;
    }
  }

  static List<Map<String, dynamic>> _initialDevices() {
    return [
      {
        'id': 'device-1',
        'deviceIdentifier': 'iphone-15-pro-123',
        'displayName': 'Ben iPhone',
        'brand': 'Apple',
        'model': 'iPhone 15 Pro',
        'os': 'iOS',
        'osVersion': '17.2',
        'appVersion': '1.0.0',
        'platform': 'ios',
        'isTrusted': true,
        'isCurrent': true,
        'trustedAt': DateTime.now()
            .subtract(const Duration(days: 30))
            .toIso8601String(),
        'isActive': true,
        'lastLoginAt': DateTime.now()
            .subtract(const Duration(minutes: 5))
            .toIso8601String(),
        'lastIpAddress': '102.176.45.123',
        'loginCount': 45,
        'createdAt': DateTime.now()
            .subtract(const Duration(days: 30))
            .toIso8601String(),
      },
      {
        'id': 'device-2',
        'deviceIdentifier': 'macbook-pro-456',
        'displayName': 'MacBook Pro',
        'brand': 'Apple',
        'model': 'MacBook Pro',
        'os': 'macOS',
        'osVersion': '14.2',
        'appVersion': '1.0.0',
        'platform': 'web',
        'isTrusted': true,
        'trustedAt': DateTime.now()
            .subtract(const Duration(days: 15))
            .toIso8601String(),
        'isActive': true,
        'lastLoginAt': DateTime.now()
            .subtract(const Duration(hours: 2))
            .toIso8601String(),
        'lastIpAddress': '102.176.45.123',
        'loginCount': 23,
        'createdAt': DateTime.now()
            .subtract(const Duration(days: 15))
            .toIso8601String(),
      },
      {
        'id': 'device-3',
        'deviceIdentifier': 'samsung-s23-789',
        'displayName': 'Galaxy S23',
        'brand': 'Samsung',
        'model': 'Galaxy S23',
        'os': 'Android',
        'osVersion': '14',
        'appVersion': '1.0.0',
        'platform': 'android',
        'isTrusted': false,
        'trustedAt': null,
        'isActive': true,
        'lastLoginAt': DateTime.now()
            .subtract(const Duration(days: 3))
            .toIso8601String(),
        'lastIpAddress': '41.85.162.74',
        'loginCount': 8,
        'createdAt': DateTime.now()
            .subtract(const Duration(days: 3))
            .toIso8601String(),
      },
    ];
  }
}

/// Devices mock registration
class DevicesMock {
  static void register(MockInterceptor interceptor) {
    // POST /devices/register - Register a device
    interceptor.register(
      method: 'POST',
      path: '/devices/register',
      handler: _handleRegisterDevice,
    );

    // GET /devices - Get all devices
    interceptor.register(
      method: 'GET',
      path: '/devices',
      handler: _handleGetDevices,
    );

    // POST /devices/:id/trust - Trust a device
    interceptor.register(
      method: 'POST',
      path: '/devices/:id/trust',
      handler: _handleTrustDevice,
    );

    // POST /devices/:id/rename - Rename a device
    interceptor.register(
      method: 'POST',
      path: '/devices/:id/rename',
      handler: _handleRenameDevice,
    );

    // DELETE /devices/:id - Revoke/remove a device
    interceptor.register(
      method: 'DELETE',
      path: '/devices/:id',
      handler: _handleRemoveDevice,
    );
  }

  /// Handle register device
  static Future<MockResponse> _handleRegisterDevice(
    RequestOptions options,
  ) async {
    final data = options.data as Map<String, dynamic>? ?? {};
    final newDevice = {
      'id': 'device-${DateTime.now().millisecondsSinceEpoch}',
      'deviceIdentifier': data['deviceIdentifier'] ?? 'unknown',
      'displayName': data['model'] ?? data['platform'] ?? 'Unknown Device',
      'brand': data['brand'],
      'model': data['model'],
      'os': data['platform'] == 'ios' ? 'iOS' : 'Android',
      'osVersion': data['osVersion'],
      'appVersion': data['appVersion'],
      'platform': data['platform'],
      'isTrusted': false,
      'trustedAt': null,
      'isActive': true,
      'lastLoginAt': DateTime.now().toIso8601String(),
      'lastIpAddress': '127.0.0.1',
      'loginCount': 1,
      'createdAt': DateTime.now().toIso8601String(),
    };
    DevicesMockState.devices.add(newDevice);
    return MockResponse.success(newDevice);
  }

  /// Handle get all devices
  static Future<MockResponse> _handleGetDevices(RequestOptions options) async {
    return MockResponse.success(DevicesMockState.devices);
  }

  /// Handle trust device
  static Future<MockResponse> _handleTrustDevice(RequestOptions options) async {
    final deviceId = options.extractPathParams('/devices/:id/trust')['id'];
    if (deviceId == null) {
      return MockResponse.notFound('Device not found');
    }
    final device = DevicesMockState.findDevice(deviceId);

    if (device == null) {
      return MockResponse.notFound('Device not found');
    }

    DevicesMockState.trustDevice(deviceId);
    final updatedDevice = DevicesMockState.findDevice(deviceId);

    return MockResponse.success(updatedDevice);
  }

  /// Handle rename device
  static Future<MockResponse> _handleRenameDevice(
    RequestOptions options,
  ) async {
    final deviceId = options.extractPathParams('/devices/:id/rename')['id'];
    final device = deviceId == null
        ? null
        : DevicesMockState.findDevice(deviceId);
    final name = (options.data as Map<String, dynamic>?)?['name'] as String?;

    if (deviceId == null || device == null) {
      return MockResponse.notFound('Device not found');
    }
    if (name == null || name.isEmpty) {
      return MockResponse.badRequest('name is required');
    }

    DevicesMockState.renameDevice(deviceId, name);
    return MockResponse.success({
      'success': true,
      'message': 'Device renamed successfully',
    });
  }

  /// Handle remove device
  static Future<MockResponse> _handleRemoveDevice(
    RequestOptions options,
  ) async {
    final deviceId = options.extractPathParams('/devices/:id')['id'];
    final device = deviceId == null
        ? null
        : DevicesMockState.findDevice(deviceId);

    if (deviceId == null || device == null) {
      return MockResponse.notFound('Device not found');
    }

    DevicesMockState.removeDevice(deviceId);

    return MockResponse.success({
      'success': true,
      'message': 'Device removed successfully',
    });
  }
}
