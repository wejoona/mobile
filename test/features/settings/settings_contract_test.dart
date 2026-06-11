import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/settings/repositories/devices_repository.dart';
import 'package:usdc_wallet/features/settings/repositories/sessions_repository.dart';

import '../../helpers/test_utils.dart';

void main() {
  test('SessionsRepository parses bare device array', () async {
    final dio = MockDio();
    dio.queueResponse([
      {
        'id': 'device-1',
        'deviceId': 'device-1',
        'lastIpAddress': '197.155.45.10',
        'platform': 'ios',
        'model': 'iPhone',
        'isActive': true,
        'lastLoginAt': DateTime.utc(2026, 6, 2).toIso8601String(),
      },
    ]);
    final repository = SessionsRepository(dio);

    final sessions = await repository.getSessions();

    expect(dio.requestHistory.single.path, '/devices');
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
    expect(devices.single.displayLabel, 'Apple iPhone 15 Pro');
  });
}
