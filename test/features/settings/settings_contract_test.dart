import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/settings/repositories/devices_repository.dart';
import 'package:usdc_wallet/features/settings/repositories/sessions_repository.dart';

import '../../helpers/test_utils.dart';

void main() {
  test('SessionsRepository parses bare backend array', () async {
    final dio = MockDio();
    dio.queueResponse([
      {
        'id': 'session-1',
        'deviceId': 'device-1',
        'ipAddress': '197.155.45.10',
        'userAgent': 'Mozilla/5.0 (iPhone)',
        'location': 'Abidjan, Côte d\'Ivoire',
        'isActive': true,
        'lastActivityAt': DateTime.utc(2026, 6, 2).toIso8601String(),
        'expiresAt': DateTime.utc(2026, 7, 2).toIso8601String(),
      },
    ]);
    final repository = SessionsRepository(dio);

    final sessions = await repository.getSessions();

    expect(dio.requestHistory.single.path, '/sessions');
    expect(sessions, hasLength(1));
    expect(sessions.single.deviceDescription, 'iPhone');
  });

  test('DevicesRepository parses bare backend array', () async {
    final dio = MockDio();
    dio.queueResponse([
      {
        'id': 'device-1',
        'deviceIdentifier': 'ios-vendor-id',
        'displayName': 'Ben iPhone',
        'brand': 'Apple',
        'model': 'iPhone 15 Pro',
        'os': 'iOS',
        'osVersion': '17.2',
        'platform': 'ios',
        'isTrusted': true,
        'isActive': true,
        'lastLoginAt': DateTime.utc(2026, 6, 2).toIso8601String(),
        'createdAt': DateTime.utc(2026, 5, 2).toIso8601String(),
      },
    ]);
    final repository = DevicesRepository(dio);

    final devices = await repository.getDevices();

    expect(dio.requestHistory.single.path, '/devices');
    expect(devices, hasLength(1));
    expect(devices.single.displayName, 'Apple iPhone 15 Pro');
  });
}
