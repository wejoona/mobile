import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/domain/entities/device.dart';
import 'package:usdc_wallet/features/settings/index.dart' as settings;

void main() {
  group('Device contract', () {
    test('parses backend camelCase device payloads', () {
      final trustedAt = DateTime.utc(2026, 5, 26, 12);
      final lastLoginAt = DateTime.utc(2026, 5, 27, 8);

      final device = Device.fromJson({
        'id': 'device-1',
        'userId': 'user-1',
        'deviceIdentifier': 'vendor-123',
        'displayName': 'Ben iPhone',
        'brand': 'Apple',
        'model': 'iPhone17,2',
        'os': 'iOS',
        'platform': 'ios',
        'osVersion': '18.4',
        'appVersion': '1.2.3',
        'isTrusted': true,
        'trustedAt': trustedAt.toIso8601String(),
        'isActive': true,
        'isCurrent': true,
        'lastLoginAt': lastLoginAt.toIso8601String(),
        'lastIpAddress': '102.176.45.123',
        'loginCount': 7,
        'createdAt': DateTime.utc(2026, 5, 1).toIso8601String(),
      });

      expect(device.id, 'device-1');
      expect(device.deviceIdentifier, 'vendor-123');
      expect(device.deviceName, 'Ben iPhone');
      expect(device.brand, 'Apple');
      expect(device.deviceModel, 'iPhone17,2');
      expect(device.os, 'iOS');
      expect(device.osDisplay, 'iOS 18.4');
      expect(device.appVersion, '1.2.3');
      expect(device.isTrusted, isTrue);
      expect(device.trustedAt, trustedAt);
      expect(device.isActive, isTrue);
      expect(device.isCurrent, isTrue);
      expect(device.lastActiveAt, lastLoginAt);
      expect(device.lastIpAddress, '102.176.45.123');
      expect(device.loginCount, 7);
      expect(device.displayLabel, contains('iPhone'));
    });

    test('parses mock snake_case device payloads', () {
      final device = Device.fromJson({
        'id': 'device-2',
        'user_id': 'user-2',
        'device_identifier': 'android-456',
        'device_name': 'Galaxy',
        'brand': 'Samsung',
        'model': 'Galaxy S24',
        'os': 'Android',
        'platform': 'android',
        'os_version': '15',
        'app_version': '1.2.4',
        'is_trusted': false,
        'is_current': false,
        'is_active': true,
        'last_active_at': DateTime.utc(2026, 5, 27, 9).toIso8601String(),
        'last_ip_address': '41.85.162.74',
        'login_count': 3,
        'created_at': DateTime.utc(2026, 5, 2).toIso8601String(),
      });

      expect(device.userId, 'user-2');
      expect(device.deviceIdentifier, 'android-456');
      expect(device.deviceName, 'Galaxy');
      expect(device.displayLabel, 'Samsung Galaxy S24');
      expect(device.osDisplay, 'Android 15');
      expect(device.isTrusted, isFalse);
      expect(device.isActive, isTrue);
      expect(device.lastIpAddress, '41.85.162.74');
      expect(device.loginCount, 3);
    });

    test('parses blocked device state from admin/security payloads', () {
      final blockedAt = DateTime.utc(2026, 6, 11, 9);

      final device = Device.fromJson({
        'id': 'device-3',
        'userId': 'user-3',
        'deviceIdentifier': 'ios-blocked',
        'displayName': 'Old iPhone',
        'platform': 'ios',
        'status': 'blacklisted',
        'isActive': false,
        'blacklistReason': 'Lost phone',
        'blacklistedAt': blockedAt.toIso8601String(),
      });

      expect(device.isBlocked, isTrue);
      expect(device.isActive, isFalse);
      expect(device.cannotAccess, isTrue);
      expect(device.isRecentlyActive, isFalse);
      expect(device.blockedReason, 'Lost phone');
      expect(device.blockedAt, blockedAt);
    });

    test('settings barrel exports the canonical blocked-device model', () {
      final device = settings.Device.fromJson({
        'id': 'device-4',
        'userId': 'user-4',
        'deviceIdentifier': 'blocked-vendor-id',
        'displayName': 'Team iPhone',
        'platform': 'ios',
        'isBlocked': true,
        'blockedReason': 'Admin blacklist',
      });

      expect(device.isBlocked, isTrue);
      expect(device.cannotAccess, isTrue);
      expect(device.blockedReason, 'Admin blacklist');
    });
  });
}
