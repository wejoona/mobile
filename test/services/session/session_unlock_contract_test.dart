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
    final sessionLockedSource = File(
      'lib/features/fsm_states/views/session_locked_view.dart',
    ).readAsStringSync();

    final pinUnlockBody = _methodBody(pinScreenSource, '_applySessionUnlock');
    final pinSuccessBody = _methodBody(pinScreenSource, '_onSuccess');
    final biometricUnlockBody = _methodBody(
      biometricPromptSource,
      '_completeUnlock',
    );
    final sessionLockedUnlockBody = _methodBody(sessionLockedSource, '_unlock');

    for (final body in [
      pinUnlockBody,
      biometricUnlockBody,
      sessionLockedUnlockBody,
    ]) {
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
    expect(
      sessionLockedUnlockBody,
      contains('appFsmProvider.notifier).unlockSession()'),
      reason:
          'session lock unlock must clear the FSM lock state before routing home',
    );
    expect(sessionLockedUnlockBody, contains("router.go('/home')"));
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

  test('reset PIN unlock does not depend on stale locked route', () {
    final source = File(
      'lib/features/pin/views/reset_pin_view.dart',
    ).readAsStringSync();

    final unlockBody = _methodBody(source, '_unlockAfterReset');

    expect(unlockBody, contains('unlockAfterAccountRecovery()'));
    expect(
      unlockBody,
      contains('authState.isAuthenticated'),
      reason: 'trusted PIN reset should transition home once auth is active',
    );
    expect(
      unlockBody,
      contains('!sessionState.isLocked'),
      reason: 'trusted PIN reset should clear the session lock state',
    );
    expect(
      unlockBody,
      contains('!authState.isLocked'),
      reason: 'trusted PIN reset must also clear the auth lock state',
    );
    expect(
      unlockBody,
      isNot(contains('currentRoute')),
      reason: 'trusted PIN reset should not fail because a lock route is stale',
    );

    final submitBody = _methodBody(source, '_submitReset');
    expect(
      submitBody,
      contains('pinStateProvider.notifier'),
      reason:
          'trusted PIN reset should update in-memory PIN state, not only storage',
    );
  });

  test('session lock screen restores PIN and biometric if unlock stalls', () {
    final source = File(
      'lib/features/fsm_states/views/session_locked_view.dart',
    ).readAsStringSync();

    final unlockBody = _methodBody(source, '_unlock');
    final restoreBody = _methodBody(source, '_restoreUnlockControls');

    expect(unlockBody, contains('Duration(seconds: 5)'));
    expect(unlockBody, contains('_restoreUnlockControls()'));
    expect(source, contains('WidgetsBinding.instance.addObserver(this)'));
    expect(source, contains('didChangeAppLifecycleState'));
    expect(source, contains('biometric_usePinInstead'));
    expect(restoreBody, contains('_isUnlocking = false'));
    expect(restoreBody, contains("_pin = ''"));
    expect(restoreBody, contains('_checkBiometric()'));
  });

  test('stale scheduled lock navigation is ignored after unlock', () {
    final source = File(
      'lib/services/session/session_manager.dart',
    ).readAsStringSync();
    final sessionServiceSource = File(
      'lib/services/session/session_service.dart',
    ).readAsStringSync();

    final showLockBody = _methodBody(source, '_showLockScreen');
    final recordActivityBody = _methodBody(
      sessionServiceSource,
      'recordActivity',
    );
    final unlockSessionBody = _methodBody(
      sessionServiceSource,
      'unlockSession',
    );

    expect(showLockBody, contains('ref.read(sessionServiceProvider)'));
    expect(showLockBody, isNot(contains('!auth.isLocked')));
    expect(
      showLockBody,
      contains('!session.isLocked'),
      reason: 'session lock state is authoritative for lock navigation',
    );
    expect(showLockBody, contains("'/session-locked'"));

    final redirectorSource = File(
      'lib/router/app_redirector.dart',
    ).readAsStringSync();
    expect(redirectorSource, contains('sessionServiceProvider'));
    expect(
      redirectorSource,
      contains('authState.isLocked || sessionState.isLocked'),
    );
    expect(
      recordActivityBody,
      contains('state.status == SessionStatus.locked'),
      reason: 'PIN screen taps must not restart inactivity timers while locked',
    );
    expect(unlockSessionBody, contains('_cancelWarningTimer()'));
    expect(unlockSessionBody, contains('_backgroundLockTimer?.cancel()'));
    expect(unlockSessionBody, contains('_backgroundEnteredAt = null'));
    expect(unlockSessionBody, contains('remainingSeconds: null'));
  });

  test('authenticated main shell cannot pop back to login', () {
    final shellSource = File(
      'lib/router/widgets/navigation_shell.dart',
    ).readAsStringSync();
    final redirectorSource = File(
      'lib/router/app_redirector.dart',
    ).readAsStringSync();

    expect(shellSource, contains('PopScope'));
    expect(shellSource, contains('canPop: false'));
    expect(redirectorSource, contains('_isAuthenticatedDeadEndRoute'));
    expect(redirectorSource, contains("location == '/onboarding/phone'"));
    expect(redirectorSource, contains("return '/home'"));
  });

  test('session refresh accepts the backend response envelope', () {
    final source = File(
      'lib/services/session/session_service.dart',
    ).readAsStringSync();

    expect(source, contains('_responsePayload(response.data)'));
    expect(source, contains("payload['accessToken']"));
    expect(source, contains("payload['refreshToken']"));
    expect(source, contains("payload['expiresIn']"));
    expect(
      source,
      contains('if (nestedData is Map<String, dynamic>)'),
      reason: 'SessionService must accept { data: { accessToken, ... } }',
    );
  });

  test('active sessions only request unlock when auth can be locked', () {
    final source = File(
      'lib/features/settings/providers/sessions_provider.dart',
    ).readAsStringSync();

    final friendlyErrorBody = _methodBody(source, '_friendlyError');
    final expiredSessionBody = _methodBody(source, '_handleExpiredSession');

    expect(friendlyErrorBody, contains('ref.read(authProvider).isLocked'));
    expect(friendlyErrorBody, contains('Please unlock Korido again'));
    expect(friendlyErrorBody, contains('Please sign in again'));
    expect(expiredSessionBody, contains('setLocked()'));
    expect(
      expiredSessionBody,
      contains('return ref.read(authProvider).isLocked'),
      reason:
          'a rejected/cleared refresh token must not route users to a dead PIN unlock screen',
    );
  });
}

String _methodBody(String source, String methodName) {
  final signatureIndex = source.indexOf(
    RegExp(
      r'(?:void|bool|String|Future<[^>]+>)\s+' +
          RegExp.escape(methodName) +
          r'\s*\(',
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
