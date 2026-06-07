import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('PIN and biometric unlock clear session lock and route home', () {
    final sessionLockedSource = File(
      'lib/features/fsm_states/views/session_locked_view.dart',
    ).readAsStringSync();
    final biometricPromptSource = File(
      'lib/features/fsm_states/views/biometric_prompt_view.dart',
    ).readAsStringSync();

    final pinUnlockBody = _methodBody(sessionLockedSource, '_unlock');
    final biometricUnlockBody = _methodBody(
      biometricPromptSource,
      '_completeUnlock',
    );

    for (final body in [pinUnlockBody, biometricUnlockBody]) {
      expect(body, contains('authProvider.notifier).unlock()'));
      expect(
        body,
        contains('sessionServiceProvider.notifier).unlockSession()'),
      );
      expect(body, contains("context.go('/home')"));
    }
  });

  test('PIN lock screen keeps biometric action available when enabled', () {
    final sessionLockedSource = File(
      'lib/features/fsm_states/views/session_locked_view.dart',
    ).readAsStringSync();

    expect(sessionLockedSource, contains('biometricService.isAvailable()'));
    expect(
      sessionLockedSource,
      contains('biometricService.isBiometricEnabled()'),
    );
    expect(
      sessionLockedSource,
      matches(
        RegExp(r'showBiometric:\s*_biometricSupported && _biometricEnabled'),
      ),
    );
  });
}

String _methodBody(String source, String methodName) {
  final signatureIndex = source.indexOf('void $methodName()');
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
