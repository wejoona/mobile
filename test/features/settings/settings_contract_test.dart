import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/settings/repositories/devices_repository.dart';
import 'package:usdc_wallet/features/settings/repositories/sessions_repository.dart';

import '../../helpers/test_utils.dart';

void main() {
  test('SessionsRepository parses bare session array', () async {
    final dio = MockDio();
    dio.queueResponse([
      {
        'id': 'session-1',
        'deviceId': 'device-1',
        'ipAddress': '197.155.45.10',
        'userAgent': 'Korido/1.0 (iOS; iPhone; 26.2)',
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

  test('SessionsRepository parses wrapped backend session payloads', () async {
    final dio = MockDio();
    dio.queueResponse({
      'data': {
        'sessions': [
          {
            'id': 'session-2',
            'deviceId': 'device-2',
            'ipAddress': '102.176.45.123',
            'userAgent': 'Korido/1.0 (Android; Pixel)',
            'isActive': true,
            'lastActivityAt': DateTime.utc(2026, 6, 3).toIso8601String(),
            'expiresAt': DateTime.utc(2026, 7, 3).toIso8601String(),
          },
        ],
        'total': 1,
      },
    });
    final repository = SessionsRepository(dio);

    final sessions = await repository.getSessions();

    expect(sessions, hasLength(1));
    expect(sessions.single.id, 'session-2');
    expect(sessions.single.deviceDescription, 'Android Device');
  });

  test('active sessions 401 does not clear the local app session', () {
    final source = File(
      'lib/features/settings/providers/sessions_provider.dart',
    ).readAsStringSync();

    final loadSessions = _methodBody(source, 'loadSessions');
    final revokeSession = _methodBody(source, 'revokeSession');
    final logoutAllDevices = _methodBody(source, 'logoutAllDevices');

    expect(loadSessions, contains('_ensureAuthenticatedForSessionRead'));
    expect(loadSessions, isNot(contains('_clearLocalSessionAfterLogoutAll')));
    expect(loadSessions, contains('error: _friendlyError(e)'));
    expect(loadSessions, contains('error: _friendlyError(retryError)'));
    expect(loadSessions, contains('requiresUnlock: true'));
    expect(revokeSession, isNot(contains('_clearLocalSessionAfterLogoutAll')));
    expect(revokeSession, contains('requiresUnlock: true'));
    expect(logoutAllDevices, contains('_clearLocalSessionAfterLogoutAll'));
  });

  test('devices 401 preserves unlock state instead of showing empty list', () {
    final source = File(
      'lib/features/settings/providers/devices_provider.dart',
    ).readAsStringSync();

    expect(source, contains('setLocked()'));
    expect(source, isNot(contains('return const <Device>[];')));
    expect(source, contains('requiresUnlock'));
    expect(source, contains('authState.isLocked'));
    expect(source, contains('error.statusCode == 401'));
  });

  test('security settings account actions and persisted controls live in canonical screen', () {
    final source = File(
      'lib/features/settings/views/security_view.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('onTap: () {}')));
    expect(source, contains("context.push('/settings/pin')"));
    expect(source, contains("context.push('/settings/devices')"));
    expect(source, contains('securitySettingsProvider'));
    expect(source, contains('setPinOnAppOpen'));
    expect(source, contains('setScreenshotProtection'));
    expect(source, contains('setTransactionAlerts'));
    expect(source, contains('setAutoLock'));
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

String _methodBody(String source, String methodName) {
  final signatureIndex = source.indexOf('Future<void> $methodName()') >= 0
      ? source.indexOf('Future<void> $methodName()')
      : source.indexOf('Future<bool> $methodName');
  expect(signatureIndex, isNonNegative, reason: '$methodName should exist');

  final bodyStart = source.indexOf('{', signatureIndex);
  expect(bodyStart, isNonNegative, reason: '$methodName should have a body');

  var depth = 0;
  for (var i = bodyStart; i < source.length; i++) {
    final char = source[i];
    if (char == '{') depth++;
    if (char == '}') depth--;
    if (depth == 0) return source.substring(bodyStart, i + 1);
  }

  fail('Could not parse $methodName body');
}
