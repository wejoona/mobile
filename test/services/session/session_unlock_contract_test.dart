import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('PIN and biometric unlock clear session lock and route home', () {
    final pinScreenSource = File(
      'lib/features/pin/views/pin_screen.dart',
    ).readAsStringSync();
    final biometricPromptSource = File(
      'lib/features/fsm_states/views/biometric_prompt_view.dart',
    ).readAsStringSync();

    final pinUnlockBody = _methodBody(pinScreenSource, '_applySessionUnlock');
    final pinSuccessBody = _methodBody(pinScreenSource, '_onSuccess');
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
    }

    expect(
      pinSuccessBody,
      contains('PinContext.sessionLock'),
      reason: 'PIN unlock contract must cover the active session lock route',
    );
    expect(
      pinSuccessBody,
      contains('_transitionThen'),
      reason:
          'PIN unlock should not race session state changes against routing',
    );
    expect(
      pinSuccessBody,
      contains("router.go(widget.successRoute ?? '/home')"),
    );
    expect(
      biometricUnlockBody,
      contains('appFsmProvider.notifier).unlockSession()'),
      reason:
          'biometric unlock must clear the FSM lock state before routing home',
    );
    expect(biometricUnlockBody, contains('addPostFrameCallback'));
    expect(biometricUnlockBody, contains("router.go('/home')"));
  });

  test('PIN lock screen keeps biometric and manual PIN fallback available', () {
    final pinScreenSource = File(
      'lib/features/pin/views/pin_screen.dart',
    ).readAsStringSync();

    expect(pinScreenSource, contains('bio.isBiometricEnabled()'));
    expect(pinScreenSource, contains('bio.getAvailableType()'));
    expect(
      pinScreenSource,
      contains('showBiometric: _shouldShowBiometricUnlock'),
    );
    expect(
      pinScreenSource,
      contains('biometric_usePinInstead'),
      reason:
          'unlock transition must let the user return to PIN if navigation stalls',
    );
  });
}

String _methodBody(String source, String methodName) {
  final signatureIndex = source.indexOf(
    RegExp(
      r'(?:void|bool|Future<[^>]+>)\s+' + RegExp.escape(methodName) + r'\s*\(',
    ),
  );
  expect(signatureIndex, isNonNegative, reason: '$methodName should exist');

  final bodyStart = source.indexOf('{', signatureIndex);
  expect(bodyStart, isNonNegative, reason: '$methodName should have a body');

  var depth = 0;
  for (var i = bodyStart; i < source.length; i++) {
    final char = source[i];
    if (char == '{') {
      depth++;
    }
    if (char == '}') {
      depth--;
    }
    if (depth == 0) {
      return source.substring(bodyStart, i + 1);
    }
  }

  fail('Could not parse $methodName body');
}
