/// Devices Mock Implementation
///
/// Mock handlers for device management endpoints.
library;

import 'package:dio/dio.dart';
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
      device['is_trusted'] = true;
      device['trustedAt'] = DateTime.now().toIso8601String();
      device['trusted_at'] = device['trustedAt'];
    }
  }

  static void untrustDevice(String id) {
    final device = findDevice(id);
    if (device != null) {
      device['isTrusted'] = false;
      device['is_trusted'] = false;
      device['trustedAt'] = null;
      device['trusted_at'] = null;
    }
  }

  static void renameDevice(String id, String name) {
    final device = findDevice(id);
    if (device != null) {
      device['displayName'] = name;
      device['display_name'] = name;
      device['deviceName'] = name;
      device['device_name'] = name;
    }
  }

  static List<Map<String, dynamic>> _initialDevices() {
    return [
      {
        'id': 'device-1',
        'userId': 'mock-user',
        'deviceIdentifier': 'iphone-15-pro-123',
        'displayName': 'Ben iPhone',
        'brand': 'Apple',
        'model': 'iPhone 15 Pro',
        'os': 'iOS',
        'osVersion': '17.2',
        'appVersion': '0.9.0',
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
        'userId': 'mock-user',
        'deviceIdentifier': 'macbook-pro-456',
        'displayName': 'MacBook Pro',
        'brand': 'Apple',
        'model': 'MacBook Pro',
        'os': 'macOS',
        'osVersion': '14.2',
        'appVersion': '0.9.0',
        'platform': 'web',
        'isTrusted': true,
        'isCurrent': false,
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
        'userId': 'mock-user',
        'deviceIdentifier': 'samsung-s23-789',
        'displayName': 'Galaxy S23',
        'brand': 'Samsung',
        'model': 'Galaxy S23',
        'os': 'Android',
        'osVersion': '14',
        'appVersion': '0.9.0',
        'platform': 'android',
        'isTrusted': false,
        'isCurrent': false,
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
    for (final path in const [
      '/devices',
      '/devices/register',
      '/api/v1/devices',
      '/api/v1/devices/register',
    ]) {
      interceptor.register(
        method: 'POST',
        path: path,
        handler: _handleRegisterDevice,
      );
    }

    for (final path in const ['/devices', '/api/v1/devices']) {
      interceptor.register(
        method: 'GET',
        path: path,
        handler: _handleGetDevices,
      );
    }

    // GET /devices/:id - Get a single device
    interceptor.register(
      method: 'GET',
      path: r'/devices/[\w-]+',
      handler: _handleGetDevice,
    );

    for (final path in const [
      r'/devices/[\w-]+/trust',
      r'/api/v1/devices/[\w-]+/trust',
    ]) {
      interceptor.register(
        method: 'POST',
        path: path,
        handler: _handleTrustDevice,
      );
    }

    for (final path in const [
      r'/devices/[\w-]+/untrust',
      r'/api/v1/devices/[\w-]+/untrust',
    ]) {
      interceptor.register(
        method: 'POST',
        path: path,
        handler: _handleUntrustDevice,
      );
    }

    for (final path in const [
      r'/devices/[\w-]+/rename',
      r'/api/v1/devices/[\w-]+/rename',
    ]) {
      interceptor.register(
        method: 'POST',
        path: path,
        handler: _handleRenameDevice,
      );
    }

    // POST /devices/revoke-others - Revoke all other devices
    interceptor.register(
      method: 'POST',
      path: '/devices/revoke-others',
      handler: _handleRevokeOthers,
    );

    for (final path in const ['/devices', '/api/v1/devices']) {
      interceptor.register(
        method: 'DELETE',
        path: path,
        handler: _handleRemoveAllDevices,
      );
    }

    for (final path in const [r'/devices/[\w-]+', r'/api/v1/devices/[\w-]+']) {
      interceptor.register(
        method: 'DELETE',
        path: path,
        handler: _handleRemoveDevice,
      );
    }
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
      device['is_current'] = false;
    }
    final now = DateTime.now().toIso8601String();
    final newDevice = {
      'id': 'device-${DateTime.now().millisecondsSinceEpoch}',
      'userId': 'mock-user',
      'deviceIdentifier': deviceIdentifier,
      'device_identifier': deviceIdentifier,
      'displayName': data['displayName'] ?? data['deviceName'] ?? data['model'],
      'display_name':
          data['displayName'] ?? data['deviceName'] ?? data['model'],
      'deviceName': data['deviceName'] ?? data['displayName'] ?? data['model'],
      'device_name': data['deviceName'] ?? data['displayName'] ?? data['model'],
      'brand': data['brand'],
      'model': data['model'],
      'os': data['os'] ?? (data['platform'] == 'ios' ? 'iOS' : 'Android'),
      'osVersion': data['osVersion'],
      'os_version': data['osVersion'],
      'appVersion': data['appVersion'],
      'app_version': data['appVersion'],
      'platform': data['platform'],
      'isTrusted': false,
      'is_trusted': false,
      'trustedAt': null,
      'trusted_at': null,
      'isActive': true,
      'is_active': true,
      'isCurrent': true,
      'is_current': true,
      'lastLoginAt': now,
      'last_login_at': now,
      'lastActiveAt': now,
      'last_active_at': now,
      'lastIpAddress': '127.0.0.1',
      'last_ip_address': '127.0.0.1',
      'loginCount': 1,
      'login_count': 1,
      'createdAt': now,
      'created_at': now,
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

  /// Handle untrust device
  static Future<MockResponse> _handleUntrustDevice(
    RequestOptions options,
  ) async {
    final deviceId = _extractId(options.path);
    final device = DevicesMockState.findDevice(deviceId);

    if (device == null) {
      return MockResponse.notFound('Device not found');
    }

    DevicesMockState.untrustDevice(deviceId);
    final updatedDevice = DevicesMockState.findDevice(deviceId);

    return MockResponse.success(updatedDevice);
  }


  /// Handle rename device
  static Future<MockResponse> _handleRenameDevice(
    RequestOptions options,
  ) async {
    final deviceId = _extractId(options.path);
    final device = DevicesMockState.findDevice(deviceId);
    final data = options.data as Map<String, dynamic>? ?? {};
    final name = data['name'] as String?;

    if (device == null) {
      return MockResponse.notFound('Device not found');
    }
    if (name == null || name.trim().isEmpty) {
      return MockResponse.badRequest('Device name is required');
    }

    DevicesMockState.renameDevice(deviceId, name.trim());
    final updatedDevice = DevicesMockState.findDevice(deviceId);

    return MockResponse.success(updatedDevice);
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

  /// Handle remove all devices
  static Future<MockResponse> _handleRemoveAllDevices(
    RequestOptions options,
  ) async {
    DevicesMockState.devices.clear();

    return MockResponse.success({
      'success': true,
      'message': 'All devices removed successfully',
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
    final devicesIndex = segments.indexOf('devices');
    if (devicesIndex == -1 || devicesIndex + 1 >= segments.length) {
      return segments.length > 1 ? segments[1] : '';
    }
    return segments[devicesIndex + 1];
  }
}
