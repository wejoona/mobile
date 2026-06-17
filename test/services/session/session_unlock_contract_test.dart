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
    final navigationExtensionSource = File(
      'lib/router/navigation_extensions.dart',
    ).readAsStringSync();

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
    expect(pinSuccessBody, contains('context.enterAuthenticatedApp('));
    expect(
      pinScreenSource,
      contains('ref.listenManual<AuthState>'),
      reason:
          'PIN unlock listeners must be registered once per screen lifecycle',
    );
    expect(
      pinScreenSource,
      contains('ref.listenManual<SessionState>'),
      reason:
          'session unlock listener must be registered once per screen lifecycle',
    );
    expect(
      _methodBody(pinScreenSource, 'build'),
      isNot(contains('ref.listen')),
      reason:
          'registering listeners in build can reschedule stale PIN redirects on every rebuild',
    );
    expect(
      biometricUnlockBody,
      contains('appFsmProvider.notifier).unlockSession()'),
      reason:
          'biometric unlock must clear the FSM lock state before routing home',
    );
    expect(biometricPromptSource, contains('biometricServiceProvider'));
    expect(
      biometricPromptSource,
      contains('isBiometricEnabled(userId: userId)'),
    );
    expect(
      biometricPromptSource,
      isNot(contains('LocalAuthentication _localAuth')),
      reason:
          'FSM biometric prompt must use Korido user-bound biometric service, not raw device auth',
    );
    expect(biometricUnlockBody, contains('addPostFrameCallback'));
    expect(biometricUnlockBody, contains('context.enterAuthenticatedApp()'));
    expect(
      sessionLockedUnlockBody,
      contains('appFsmProvider.notifier).unlockSession()'),
      reason:
          'session lock unlock must clear the FSM lock state before routing home',
    );
    expect(
      sessionLockedUnlockBody,
      contains('context.enterAuthenticatedApp()'),
    );
    expect(navigationExtensionSource, contains('enterAuthenticatedApp'));
    expect(
      navigationExtensionSource,
      contains('final navigator = Navigator.maybeOf(this)'),
    );
    expect(navigationExtensionSource, contains('while (navigator.canPop()'));
    expect(navigationExtensionSource, contains('router.go(route);'));
    expect(
      navigationExtensionSource.indexOf('while (navigator.canPop()'),
      lessThan(navigationExtensionSource.indexOf('router.go(route);')),
      reason:
          'auth stack cleanup must happen before routing home so PIN/login cannot remain underneath Home',
    );
  });

  test(
    'PIN lock screen keeps user-bound biometric and manual PIN fallback available',
    () {
      final pinScreenSource = File(
        'lib/features/pin/views/pin_screen.dart',
      ).readAsStringSync();
      final loginProviderSource = File(
        'lib/features/auth/providers/login_provider.dart',
      ).readAsStringSync();
      final sessionLockedSource = File(
        'lib/features/fsm_states/views/session_locked_view.dart',
      ).readAsStringSync();
      final loginPinSource = File(
        'lib/features/auth/views/login_pin_view.dart',
      ).readAsStringSync();

      expect(
        pinScreenSource,
        contains('bio.isBiometricEnabled(userId: userId)'),
      );
      expect(
        sessionLockedSource,
        contains('biometricService.isBiometricEnabled(userId: userId)'),
      );
      expect(
        loginPinSource,
        contains('PinScreen(pinContext: PinContext.login)'),
        reason:
            'the legacy LoginPinView import must delegate to the canonical PIN screen',
      );
      expect(loginPinSource, isNot(contains('verifyPinLocally')));
      expect(pinScreenSource, contains('bio.getAvailableType()'));
      expect(
        pinScreenSource,
        contains('showBiometric: _shouldShowBiometricUnlock'),
      );
      expect(
        loginProviderSource,
        isNot(contains('Future<bool> verifyBiometric()')),
        reason:
            'LoginProvider must not carry a second biometric unlock authority',
      );
      expect(
        pinScreenSource,
        contains('biometric_usePinInstead'),
        reason:
            'unlock transition must let the user return to PIN if navigation stalls',
      );
    },
  );

  test('biometric login is bound to the persisted Korido user', () {
    final loginSource = File(
      'lib/features/auth/views/login_view.dart',
    ).readAsStringSync();
    final authProviderSource = File(
      'lib/features/auth/providers/auth_provider.dart',
    ).readAsStringSync();

    expect(loginSource, contains('biometricService.getBoundUserId()'));
    expect(loginSource, contains('boundUserId == storedUserId'));
    expect(loginSource, contains('expectedUserId: expectedUserId'));
    expect(authProviderSource, contains('responseUserId != expectedUserId'));
    expect(authProviderSource, contains('await clearLocalSession()'));
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
    final shellRoutesSource = File(
      'lib/router/routes/primary_shell_routes.dart',
    ).readAsStringSync();
    final redirectorSource = File(
      'lib/router/app_redirector.dart',
    ).readAsStringSync();
    final legacyLoginPinSource = File(
      'lib/features/auth/views/login_pin_view.dart',
    ).readAsStringSync();

    expect(shellSource, contains('PopScope'));
    expect(shellSource, contains('canPop: false'));
    expect(
      shellSource.indexOf('return PopScope('),
      lessThan(shellSource.indexOf('authState.isAuthenticated')),
      reason:
          'the authenticated shell placeholder must also block back-swipe while auth state settles',
    );
    expect(
      File('lib/router/navigation_extensions.dart').readAsStringSync(),
      contains('enterAuthenticatedApp'),
      reason:
          'auth success routes must clear stale OTP/PIN pages before showing home',
    );
    expect(
      shellRoutesSource,
      contains('pageBuilder: (context, state, child) => NoTransitionPage'),
      reason:
          'authenticated tab shell must own the route page so iOS back-swipe cannot reveal login',
    );
    expect(redirectorSource, contains('_isAuthenticatedDeadEndRoute'));
    expect(redirectorSource, contains('_invalidPinLoginRedirect'));
    expect(redirectorSource, contains('location != \'/login/pin\''));
    expect(redirectorSource, contains('pendingPinSessionToken'));
    expect(redirectorSource, isNot(contains('isPublicPath(location)')));
    expect(redirectorSource, contains("location == '/signup'"));
    expect(redirectorSource, contains("location == '/signup/verify-phone'"));
    expect(redirectorSource, contains("return '/home'"));
    expect(
      legacyLoginPinSource,
      contains('PinScreen(pinContext: PinContext.login)'),
    );
    expect(
      legacyLoginPinSource,
      isNot(contains("context.go('/home')")),
      reason:
          'legacy PIN login must not leave login/PIN routes under the home page',
    );
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

  test('active sessions unlock returns to sessions screen safely', () {
    final routesSource = File(
      'lib/router/routes/auth_state_routes.dart',
    ).readAsStringSync();
    final sessionsScreenSource = File(
      'lib/features/settings/views/sessions_screen.dart',
    ).readAsStringSync();

    expect(routesSource, contains('_sessionLockReturnTo(state)'));
    expect(routesSource, contains("state.uri.queryParameters['returnTo']"));
    expect(routesSource, contains('uri.hasScheme'));
    expect(routesSource, contains('uri.hasAuthority'));
    expect(routesSource, contains("returnTo.startsWith('/login')"));
    expect(routesSource, contains("returnTo.startsWith('/onboarding')"));
    expect(routesSource, contains("return '/home'"));
    expect(
      sessionsScreenSource,
      contains("Uri.encodeComponent('/settings/sessions')"),
      reason:
          'Active Sessions should return to its task context after explicit unlock',
    );
  });

  test('local auth cleanup clears pending OTP and PIN login flow state', () {
    final source = File(
      'lib/features/auth/providers/auth_provider.dart',
    ).readAsStringSync();

    final cleanupBody = _methodBody(source, 'clearLocalSession');

    expect(source, contains('login_provider.dart'));
    expect(
      cleanupBody,
      contains('ref.invalidate(loginProvider)'),
      reason:
          'logout/security cleanup must not leave a stale pending PIN session that can keep PIN screens reachable',
    );
    expect(
      cleanupBody.indexOf('endSession()'),
      lessThan(cleanupBody.indexOf('ref.invalidate(loginProvider)')),
      reason:
          'the runtime session should be ended before the login flow state is discarded',
    );
  });

  test('PIN reset can route failed liveness to manual recovery review', () {
    final resetSource = File(
      'lib/features/pin/views/reset_pin_view.dart',
    ).readAsStringSync();
    final livenessSource = File(
      'lib/features/liveness/widgets/liveness_check_widget.dart',
    ).readAsStringSync();

    final reviewBody = _methodBody(resetSource, '_routePinResetToManualReview');

    expect(livenessSource, contains('onManualReviewRequired'));
    expect(livenessSource, contains('_LivenessState.manualReview'));
    expect(livenessSource, contains('Manual review needed'));
    expect(resetSource, contains('onManualReviewRequired'));
    expect(reviewBody, contains("'/support/tickets'"));
    expect(reviewBody, contains("'category': 'account_recovery'"));
    expect(reviewBody, contains("'priority': 'high'"));
    expect(resetSource, contains('_buildManualReviewStep'));
    expect(
      resetSource,
      contains('Expected first response: within 30 minutes'),
      reason:
          'manual recovery must tell the user what happens next instead of dead-ending at provider failure',
    );
  });

  test(
    'KYC liveness declares capture capability and has manual review fallback',
    () {
      final serviceSource = File(
        'lib/services/liveness/liveness_service.dart',
      ).readAsStringSync();
      final widgetSource = File(
        'lib/features/liveness/widgets/liveness_check_widget.dart',
      ).readAsStringSync();
      final kycLivenessSource = File(
        'lib/features/kyc/views/kyc_liveness_view.dart',
      ).readAsStringSync();

      final manualReviewBody = _methodBody(
        kycLivenessSource,
        '_routeKycToManualReview',
      );

      expect(serviceSource, contains("'capabilities': capabilities.toJson()"));
      expect(serviceSource, contains("'captureMode': captureMode.value"));
      expect(serviceSource, contains("'mediaType': captureMode.value"));
      expect(widgetSource, contains('LivenessClientCapabilities'));
      expect(widgetSource, contains('LivenessCaptureMode.photo'));
      expect(kycLivenessSource, contains('onManualReviewRequired'));
      expect(manualReviewBody, contains("'/support/tickets'"));
      expect(manualReviewBody, contains("'category': 'kyc'"));
      expect(manualReviewBody, contains("'priority': 'high'"));
      expect(
        manualReviewBody,
        contains('identity document, profile photo, reference selfie'),
        reason:
            'manual KYC review must preserve the same evidence graph as automated face matching',
      );
    },
  );
}

String _methodBody(String source, String methodName) {
  final signatureIndex = source.indexOf(
    RegExp(
      r'(?:void|bool|String|Widget|Future<[^>]+>)\s+' +
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
