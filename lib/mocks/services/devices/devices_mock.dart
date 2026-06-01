/// Devices Mock Implementation
///
/// Mock handlers for device management endpoints.
library;

import 'package:dio/dio.dart';
import 'package:usdc_wallet/mocks/base/api_contract.dart';
import 'package:usdc_wallet/mocks/base/mock_interceptor.dart';

/// Devices mock state
class DevicesMockState {
  static final List<Map<String, dynamic>> devices = [
    {
      'id': 'device-1',
      'userId': 'mock-user-1',
      'deviceIdentifier': 'iphone-15-pro-123',
      'displayName': 'iPhone 15 Pro',
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
      'createdAt': DateTime.now()
          .subtract(const Duration(days: 30))
          .toIso8601String(),
      'lastActiveAt': DateTime.now()
          .subtract(const Duration(minutes: 5))
          .toIso8601String(),
      'lastLoginAt': DateTime.now()
          .subtract(const Duration(minutes: 5))
          .toIso8601String(),
      'lastIpAddress': '102.176.45.123',
      'loginCount': 45,
    },
    {
      'id': 'device-2',
      'userId': 'mock-user-1',
      'deviceIdentifier': 'macbook-pro-456',
      'displayName': 'MacBook Pro',
      'brand': 'Apple',
      'model': 'MacBook Pro',
      'os': 'macOS',
      'osVersion': '14.2',
      'appVersion': '1.0.0',
      'platform': 'web',
      'isTrusted': true,
      'isCurrent': false,
      'trustedAt': DateTime.now()
          .subtract(const Duration(days: 15))
          .toIso8601String(),
      'isActive': true,
      'createdAt': DateTime.now()
          .subtract(const Duration(days: 15))
          .toIso8601String(),
      'lastActiveAt': DateTime.now()
          .subtract(const Duration(hours: 2))
          .toIso8601String(),
      'lastLoginAt': DateTime.now()
          .subtract(const Duration(hours: 2))
          .toIso8601String(),
      'lastIpAddress': '102.176.45.123',
      'loginCount': 23,
    },
    {
      'id': 'device-3',
      'userId': 'mock-user-1',
      'deviceIdentifier': 'samsung-s23-789',
      'displayName': 'Galaxy S23',
      'brand': 'Samsung',
      'model': 'Galaxy S23',
      'os': 'Android',
      'osVersion': '14',
      'appVersion': '1.0.0',
      'platform': 'android',
      'isTrusted': false,
      'isCurrent': false,
      'trustedAt': null,
      'isActive': true,
      'createdAt': DateTime.now()
          .subtract(const Duration(days: 45))
          .toIso8601String(),
      'lastActiveAt': DateTime.now()
          .subtract(const Duration(days: 3))
          .toIso8601String(),
      'lastLoginAt': DateTime.now()
          .subtract(const Duration(days: 3))
          .toIso8601String(),
      'lastIpAddress': '41.85.162.74',
      'loginCount': 8,
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
      device['isTrusted'] = true;
      device['trustedAt'] = DateTime.now().toIso8601String();
    }
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

    // POST /devices - Legacy register route
    interceptor.register(
      method: 'POST',
      path: '/devices',
      handler: _handleRegisterDevice,
    );

    // GET /devices - Get all devices
    interceptor.register(
      method: 'GET',
      path: '/devices',
      handler: _handleGetDevices,
    );

    // GET /devices/:id - Get a single device
    interceptor.register(
      method: 'GET',
      path: '/devices/:id',
      handler: _handleGetDevice,
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

    // POST /devices/revoke-others - Revoke all other devices
    interceptor.register(
      method: 'POST',
      path: '/devices/revoke-others',
      handler: _handleRevokeOthers,
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
    final deviceIdentifier =
        data['deviceIdentifier'] ?? data['deviceId'] ?? 'unknown';
    for (final device in DevicesMockState.devices) {
      device['isCurrent'] = false;
    }
    final newDevice = {
      'id': 'device-${DateTime.now().millisecondsSinceEpoch}',
      'userId': 'mock-user-1',
      'deviceIdentifier': deviceIdentifier,
      'displayName': data['model'] ?? data['deviceName'] ?? 'Current device',
      'brand': data['brand'],
      'model': data['model'],
      'os': data['os'] ?? (data['platform'] == 'ios' ? 'iOS' : 'Android'),
      'osVersion': data['osVersion'],
      'appVersion': data['appVersion'],
      'platform': data['platform'],
      'isTrusted': false,
      'isCurrent': true,
      'trustedAt': null,
      'isActive': true,
      'createdAt': DateTime.now().toIso8601String(),
      'lastActiveAt': DateTime.now().toIso8601String(),
      'lastLoginAt': DateTime.now().toIso8601String(),
      'lastIpAddress': '127.0.0.1',
      'loginCount': 1,
    };
    DevicesMockState.devices.add(newDevice);
    return MockResponse.success(newDevice);
  }

  /// Handle get all devices
  static Future<MockResponse> _handleGetDevices(RequestOptions options) async {
    return MockResponse.success({
      'devices': DevicesMockState.devices,
      'data': DevicesMockState.devices,
    });
  }

  /// Handle get single device
  static Future<MockResponse> _handleGetDevice(RequestOptions options) async {
    final deviceId = _extractId(options.path);
    final device = DevicesMockState.findDevice(deviceId);
    if (device == null) {
      return MockResponse.notFound('Device not found');
    }
    return MockResponse.success(device);
  }

  /// Handle trust device
  static Future<MockResponse> _handleTrustDevice(RequestOptions options) async {
    final deviceId = _extractId(options.path);
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
    final deviceId = _extractId(options.path);
    final device = DevicesMockState.findDevice(deviceId);

    if (device == null) {
      return MockResponse.notFound('Device not found');
    }

    final data = options.data as Map<String, dynamic>? ?? {};
    device['displayName'] = data['name'] ?? device['displayName'];
    return MockResponse.success(device);
  }

  /// Handle revoke all other devices
  static Future<MockResponse> _handleRevokeOthers(
    RequestOptions options,
  ) async {
    DevicesMockState.devices.removeWhere(
      (device) => device['isCurrent'] != true,
    );
    return MockResponse.success({
      'success': true,
      'message': 'Other devices revoked successfully',
    });
  }

  /// Handle remove device
  static Future<MockResponse> _handleRemoveDevice(
    RequestOptions options,
  ) async {
    final deviceId = _extractId(options.path);
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

  static String _extractId(String path) {
    final segments = path
        .split('/')
        .where((segment) => segment.isNotEmpty)
        .toList();
    return segments.length > 1 ? segments[1] : '';
  }
}
