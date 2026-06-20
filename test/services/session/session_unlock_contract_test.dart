import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/pin/models/pin_reset_route_context.dart';

void main() {
  test('PIN reset return targets stay inside safe app routes', () {
    expect(
      PinResetRouteContext.safeReturnTo('/pay/abc?source=qr'),
      '/pay/abc?source=qr',
    );
    expect(
      PinResetRouteContext.safeReturnTo('/settings/sessions'),
      '/settings/sessions',
    );
    expect(
      PinResetRouteContext.safeReturnTo('https://evil.example/pay'),
      isNull,
    );
    expect(PinResetRouteContext.safeReturnTo('//evil.example/pay'), isNull);
    expect(PinResetRouteContext.safeReturnTo('/login'), isNull);
    expect(PinResetRouteContext.safeReturnTo('/pin/reset'), isNull);
    expect(
      PinResetRouteContext.safeReturnTo('/session-locked?returnTo=/pay/abc'),
      isNull,
    );
  });

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
    expect(pinSuccessBody, contains('context.fsmEnterAuthenticatedApp('));
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
    expect(biometricUnlockBody, contains('context.fsmEnterAuthenticatedApp()'));
    expect(
      sessionLockedUnlockBody,
      contains('appFsmProvider.notifier).unlockSession()'),
      reason:
          'session lock unlock must clear the FSM lock state before routing home',
    );
    expect(
      sessionLockedUnlockBody,
      contains('context.fsmEnterAuthenticatedApp()'),
    );
    expect(navigationExtensionSource, contains('enterAuthenticatedApp'));
    expect(
      navigationExtensionSource,
      contains('fsmEnterAuthenticatedApp(route: route);'),
      reason:
          'authenticated entry should delegate to the FSM navigation facade',
    );
    expect(
      navigationExtensionSource,
      isNot(contains('navigator.pop()')),
      reason:
          'manual Navigator pops can corrupt the shell child even when the URI is /home',
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

  test('biometric settings do not own enrollment storage', () {
    final settingsProviderSource = File(
      'lib/features/biometric/providers/biometric_settings_provider.dart',
    ).readAsStringSync();

    expect(settingsProviderSource, contains('biometricServiceProvider'));
    expect(
      settingsProviderSource,
      contains('isBiometricEnabled()'),
      reason:
          'settings may project enrollment state but BiometricService owns the user-bound decision',
    );
    expect(
      settingsProviderSource,
      isNot(contains('setBiometricEnabled')),
      reason:
          'settings must not expose a second writer for biometric enrollment',
    );
    expect(
      settingsProviderSource,
      isNot(contains('StorageKeys.biometricEnabled')),
      reason: 'settings must not write or read the raw biometric flag directly',
    );
  });

  test('reset PIN unlock does not depend on stale locked route', () {
    final source = File(
      'lib/features/pin/views/reset_pin_view.dart',
    ).readAsStringSync();
    final authProviderSource = File(
      'lib/features/auth/providers/auth_provider.dart',
    ).readAsStringSync();

    final unlockBody = _methodBody(source, '_unlockAfterReset');
    final accountRecoveryUnlockBody = _methodBody(
      authProviderSource,
      'unlockAfterAccountRecovery',
    );

    expect(unlockBody, contains('_completePendingLoginAfterPinReset()'));
    expect(unlockBody, contains('unlockAfterAccountRecovery()'));
    expect(
      unlockBody.indexOf('_completePendingLoginAfterPinReset()'),
      lessThan(unlockBody.indexOf('unlockAfterAccountRecovery()')),
      reason:
          'OTP-before-PIN recovery must complete the pending login session before falling back to stored-session recovery',
    );
    final pendingLoginBody = _methodBody(
      source,
      '_completePendingLoginAfterPinReset',
    );
    expect(pendingLoginBody, contains('ref.read(loginProvider)'));
    expect(pendingLoginBody, contains('sessionToken'));
    expect(pendingLoginBody, contains('completePinLogin('));
    expect(pendingLoginBody, contains('refreshToken: loginState.refreshToken'));
    expect(pendingLoginBody, contains('user: loginState.user'));
    expect(pendingLoginBody, contains('kycStatus: loginState.kycStatus'));
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
    expect(
      accountRecoveryUnlockBody,
      contains('_sessionMutationVersion++'),
      reason:
          'account recovery must cancel stale startup restores that can relock the app',
    );
    expect(
      accountRecoveryUnlockBody,
      contains('startSession('),
      reason:
          'trusted PIN reset should start an active local session instead of only clearing a lock flag',
    );

    final finalizeResetBody = _methodBody(source, '_finalizeConfirmedPinReset');
    expect(
      finalizeResetBody,
      contains('pinStateProvider.notifier'),
      reason:
          'trusted PIN reset should update in-memory PIN state, not only storage',
    );
  });

  test('reset PIN is opened with canonical phone recovery context', () {
    final resetSource = File(
      'lib/features/pin/views/reset_pin_view.dart',
    ).readAsStringSync();
    final pinScreenSource = File(
      'lib/features/pin/views/pin_screen.dart',
    ).readAsStringSync();
    final routesSource = File(
      'lib/router/routes/card_account_routes.dart',
    ).readAsStringSync();
    final resetContextSource = File(
      'lib/features/pin/models/pin_reset_route_context.dart',
    ).readAsStringSync();
    final fsmSource = File(
      'lib/state/fsm/fsm_provider.dart',
    ).readAsStringSync();
    final livenessSource = File(
      'lib/features/liveness/widgets/liveness_check_widget.dart',
    ).readAsStringSync();

    expect(routesSource, contains('final extra = state.extra;'));
    expect(routesSource, contains('extra is PinResetRouteContext'));
    expect(routesSource, contains('_pinResetRouteContext('));
    expect(
      routesSource,
      contains('ResetPinView(initialContext: resetContext)'),
      reason: 'PIN reset route must forward recovery context to the screen',
    );
    expect(routesSource, contains("state.uri.queryParameters['returnTo']"));
    expect(routesSource, contains('_pinResetRouteContext'));
    expect(resetContextSource, contains('final String? returnTo'));
    expect(resetContextSource, contains('safeReturnTo'));
    expect(pinScreenSource, contains('returnTo: widget.successRoute'));
    expect(resetSource, contains('String get _resetSuccessRoute'));
    expect(resetSource, contains('String get _loginRouteAfterRecoveryExit'));
    expect(
      resetSource,
      contains('context.fsmEnterAuthenticatedApp(route: _resetSuccessRoute)'),
      reason:
          'successful PIN recovery must return to the user intent that opened reset',
    );
    expect(
      resetSource,
      contains('context.fsmGo(_loginRouteAfterRecoveryExit)'),
      reason:
          'manual-review exit should preserve the original return target through login',
    );
    expect(
      resetSource,
      contains("ValueKey('pin_reset_phone_field')"),
      reason:
          'PIN reset should show the registered phone before sending an OTP',
    );
    expect(
      resetSource,
      contains('readOnly: _recoveryPhone != null'),
      reason:
          'PIN reset should lock a known phone but allow recovery entry when context is missing',
    );
    expect(resetSource, contains('_manualRecoveryPhoneFromInput()'));
    expect(resetSource, contains('widget.initialContext?.phoneValue'));
    expect(resetSource, contains('ref.read(loginProvider).phoneValue'));
    expect(
      resetSource,
      contains('_selectedRecoveryCountry.fullPrefix'),
      reason:
          'Manual PIN recovery must parse phone input with the selected country, not a hidden default dial code',
    );
    expect(
      resetSource,
      isNot(contains("?? '+225'")),
      reason:
          "PIN reset must not silently default no-context recovery to Cote d'Ivoire",
    );
    expect(
      resetSource,
      contains('StorageKeys.rememberedPhone'),
      reason:
          'Forgot-PIN must prefill from the same remembered phone store as login when provider hydration has not finished',
    );
    expect(resetSource, contains('PhoneNumberValue.tryFromStorageValue'));
    expect(resetSource, contains('login(phone: phone.apiPhone'));
    expect(
      resetSource,
      contains('widget.initialContext?.recoveryAccessToken'),
      reason:
          'OTP-before-PIN recovery must keep the pending auth session token',
    );
    expect(pinScreenSource, contains('context.fsmOpenPinReset('));
    expect(pinScreenSource, contains('phone: loginState.phoneValue'));
    expect(
      pinScreenSource,
      contains('recoveryAccessToken: loginState.sessionToken'),
    );
    expect(
      fsmSource,
      contains('openPinReset<T>(BuildContext context, {Object? extra})'),
    );
    expect(
      _methodBody(fsmSource, 'openPinReset'),
      contains("goToRoute(\n      context,\n      '/pin/reset',"),
      reason:
          'PIN reset is a recovery transition and must not keep failed auth/PIN routes underneath it',
    );
    expect(
      _methodBody(livenessSource, '_fail'),
      contains('LivenessManualReviewRequest('),
      reason:
          'Account recovery/KYC owners need typed manual-review metadata; the liveness widget should hand off instead of showing a dismissible nested review',
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
    final routeContractSource = File(
      'lib/state/fsm/app_route_contract.dart',
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
      File('lib/router/navigation_extensions.dart').readAsStringSync(),
      isNot(contains('navigator.pop()')),
      reason:
          'authenticated entry must use GoRouter.go stack replacement, not manual Navigator pops that can corrupt the shell child',
    );
    expect(
      shellRoutesSource,
      contains('pageBuilder: (context, state, child) => NoTransitionPage'),
      reason:
          'authenticated tab shell must own the route page so iOS back-swipe cannot reveal login',
    );
    expect(redirectorSource, contains('_isAuthenticatedDeadEndRoute'));
    expect(redirectorSource, contains('_invalidPinLoginRedirect'));
    expect(redirectorSource, contains("location != '/login/pin'"));
    expect(redirectorSource, contains('pendingPinSessionToken'));
    expect(
      redirectorSource,
      contains("location != '/login/pin'"),
      reason:
          'returning login PIN entry is pre-auth but must stay protected by the pending OTP session guard',
    );
    expect(
      redirectorSource,
      contains("hasPendingPinSession ? null : '/login'"),
      reason:
          'login PIN may stay open only while the OTP-created pending PIN session exists',
    );
    expect(
      File('lib/features/pin/views/pin_screen.dart').readAsStringSync(),
      contains('_queuedUnlockedRedirect = true;'),
      reason:
          'PIN success should own one authenticated-app navigation instead of racing the auth-state listener',
    );
    expect(redirectorSource, isNot(contains('isPublicPath(location)')));
    expect(routeContractSource, contains("pattern: '/signup'"));
    expect(routeContractSource, contains("pattern: '/signup/verify-phone'"));
    expect(redirectorSource, contains('isSignupAppRoute(location)'));
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
    expect(routesSource, contains('_authReturnTo(state)'));
    expect(routesSource, contains('successRoute: _authReturnTo(state)'));
    expect(routesSource, contains("state.uri.queryParameters['returnTo']"));
    expect(routesSource, contains('uri.hasScheme'));
    expect(routesSource, contains('uri.hasAuthority'));
    expect(routesSource, contains("returnTo.startsWith('/login')"));
    expect(routesSource, contains("returnTo.startsWith('/onboarding')"));
    expect(routesSource, contains("_safeReturnTo(state) ?? '/home'"));
    expect(
      sessionsScreenSource,
      contains("Uri.encodeComponent('/settings/sessions')"),
      reason:
          'Active Sessions should return to its task context after explicit unlock',
    );
  });

  test('pay link login preserves return intent through OTP and PIN', () {
    final payLinkSource = File(
      'lib/features/payment_links/views/pay_link_view.dart',
    ).readAsStringSync();
    final loginSource = File(
      'lib/features/auth/views/login_view.dart',
    ).readAsStringSync();
    final otpSource = File(
      'lib/features/auth/views/login_otp_view.dart',
    ).readAsStringSync();
    final routesSource = File(
      'lib/router/routes/auth_state_routes.dart',
    ).readAsStringSync();
    final deepLinkSource = File(
      'lib/core/deep_linking/deep_link_handler.dart',
    ).readAsStringSync();

    expect(payLinkSource, contains("Uri.encodeComponent('/pay/"));
    expect(payLinkSource, contains("'/login?returnTo="));
    expect(loginSource, contains("queryParameters['returnTo']"));
    expect(loginSource, contains('/login/otp?returnTo='));
    expect(otpSource, contains("queryParameters['returnTo']"));
    expect(otpSource, contains('/login/pin?returnTo='));
    expect(routesSource, contains('successRoute: _authReturnTo(state)'));
    expect(deepLinkSource, contains(r"context.fsmPush('/pay/$linkCode')"));
    expect(
      _methodBody(deepLinkSource, '_routeToDestination'),
      isNot(
        contains(
          "_saveForLater(context, path, params);\n        context.fsmGo('/login');",
        ),
      ),
      reason:
          'public payment links must land on /pay/:code; PayLinkView owns login returnTo',
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
    final userApiSource = File(
      'lib/services/api/providers/user_api.dart',
    ).readAsStringSync();
    final transactionsSource = File(
      'lib/features/transactions/views/transactions_view.dart',
    ).readAsStringSync();
    final riskSource = File(
      'lib/services/security/risk_based_security_service.dart',
    ).readAsStringSync();
    final livenessSource = File(
      'lib/features/liveness/widgets/liveness_check_widget.dart',
    ).readAsStringSync();
    final infoPlist = File('ios/Runner/Info.plist').readAsStringSync();
    final androidManifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    final reviewBody = _methodBody(resetSource, '_routePinResetToManualReview');
    final riskStepBody = _methodBody(resetSource, '_buildRiskStep');
    final livenessStartBody = _methodBody(livenessSource, '_start');

    expect(userApiSource, contains('String? otp'));
    expect(
      userApiSource,
      contains("if (otp != null && otp.isNotEmpty) 'otp': otp"),
      reason:
          'the shared PIN reset API helper must match the recovery-token contract where OTP is optional',
    );
    expect(
      transactionsSource,
      contains("context.fsmGo('/create-wallet')"),
      reason:
          'authenticated wallet setup must not send users back to the public introduction/onboarding route',
    );
    expect(
      transactionsSource,
      isNot(contains("context.fsmGo('/onboarding')")),
      reason:
          'onboarding is product education; wallet creation is an authenticated setup route',
    );
    expect(livenessSource, contains('onManualReviewRequired'));
    expect(livenessSource, contains('onManualReviewAcknowledged'));
    expect(livenessSource, contains('widget.onCancel != null'));
    expect(livenessSource, contains('ph.Permission.camera.request()'));
    expect(livenessSource, contains('_LivenessState.cameraPermissionRequired'));
    expect(livenessSource, contains('Continue with manual review'));
    expect(livenessSource, contains("'camera_permission_unavailable'"));
    expect(livenessSource, contains("'liveness_challenge_unavailable'"));
    expect(livenessSource, contains('_LivenessState.manualReview'));
    expect(livenessSource, contains('Manual review needed'));
    expect(livenessSource, contains('_releaseCamera()'));
    expect(livenessSource, contains('useRecoveryToken'));
    expect(livenessSource, contains("'liveness_result_unavailable'"));
    expect(livenessSource, contains('supportReviewRequired'));
    expect(livenessSource, contains('_manualReviewSlaLabel'));
    expect(livenessSource, contains('String? tempPhotoPath'));
    expect(livenessSource, contains('await _deleteTempPhoto(tempPhotoPath)'));
    expect(livenessSource, contains('_unsupportedCaptureMessage'));
    expect(livenessSource, contains('_unsupportedCaptureReason'));
    expect(
      _methodBody(livenessSource, '_requiresUnsupportedCapture'),
      contains('challenge.requiresMotionEvidence'),
      reason:
          'photo-only liveness must not try to satisfy nod/motion challenges with a still image',
    );
    expect(
      _methodBody(livenessSource, '_requiresUnsupportedCapture'),
      contains('challenge.manualReviewRecommended'),
      reason:
          'backend/provider manual-review recommendations must fail closed into review instead of capture',
    );
    expect(
      _methodBody(livenessSource, '_unsupportedCaptureReason'),
      contains("'motion_liveness_requires_video_evidence'"),
      reason:
          'manual review should preserve the reason that a photo-only client cannot provide motion proof',
    );
    expect(
      livenessSource,
      contains('final review = _manualReviewFromError(e)'),
    );
    expect(
      livenessStartBody.indexOf('await _createSession()'),
      lessThan(livenessStartBody.indexOf('await _initializeCamera()')),
      reason:
          'do not request camera permission when the provider cannot create a usable liveness session',
    );
    expect(
      livenessSource,
      contains('nextChallengeIndex >= _challenges.length'),
      reason:
          'a terminal backend response without a final result must not leave the UI spinning on a missing next challenge',
    );
    expect(
      livenessSource,
      contains('_state != _LivenessState.manualReview'),
      reason:
          'manual-review fallback must not keep a close button that can erase the review state',
    );
    expect(
      livenessSource,
      contains(
        "AppButton(label: 'Continue', onPressed: _acknowledgeManualReview)",
      ),
      reason:
          'manual-review continue must acknowledge the outcome, not use the cancel/back action',
    );
    expect(resetSource, contains('onManualReviewRequired'));
    expect(
      resetSource,
      contains('onManualReviewRequired: _routeLivenessManualReview'),
    );
    expect(
      resetSource,
      contains('onManualReviewAcknowledged: _openManualReviewStepFromLiveness'),
    );
    expect(resetSource, contains('void _routeLivenessManualReview'));
    expect(
      _methodBody(resetSource, '_routeLivenessManualReview'),
      contains('newPinHash: _pendingNewPinHash'),
      reason:
          'liveness provider/manual-review fallback must keep the user-chosen replacement PIN attached to account recovery',
    );
    expect(
      _methodBody(resetSource, '_routeLivenessManualReview'),
      contains('livenessRequest: request'),
      reason:
          'PIN recovery should preserve liveness fallback details such as SLA copy while staging manual review',
    );
    expect(
      riskStepBody,
      isNot(contains('onCancel:')),
      reason:
          'high-risk PIN recovery liveness must not expose a close action that returns to OTP and hides manual-review state',
    );
    expect(resetSource, contains('useRecoveryToken: true'));
    final requestOtpBody = _methodBody(resetSource, '_requestOtp');
    expect(requestOtpBody, contains('authServiceProvider'));
    expect(requestOtpBody, contains('_hasRecoveryAuthorizationCandidate'));
    expect(
      requestOtpBody.indexOf('_ensureRecoveryAuthorization(phone)'),
      greaterThan(requestOtpBody.indexOf('_hasRecoveryAuthorizationCandidate')),
      reason:
          'Requesting a recovery OTP is a public recovery action; recovery authorization can only be required when an existing token is already available.',
    );
    expect(resetSource, contains('_createRecoveryAuthorizationFromOtp'));
    expect(resetSource, contains('_accountRecoveryRiskMetadata'));
    final recoveryRiskBody = _methodBody(
      resetSource,
      '_accountRecoveryRiskMetadata',
    );
    expect(recoveryRiskBody, contains('deviceFingerprintServiceProvider'));
    expect(recoveryRiskBody, contains('clientRiskScoreServiceProvider'));
    expect(recoveryRiskBody, contains('RiskAction.accountRecovery'));
    expect(recoveryRiskBody, contains("'deviceId': fingerprint.deviceId"));
    expect(
      recoveryRiskBody,
      contains("'serverObservedClientRiskScore'"),
      reason:
          'account recovery risk must send client/device signals so low-risk trusted devices can stay OTP-only and high-risk devices can require liveness',
    );
    expect(resetSource, contains('verifyRecoveryOtp'));
    expect(resetSource, contains('StorageKeys.recoveryAccessToken'));
    expect(resetSource, contains('StorageKeys.recoveryAccessTokenPhone'));
    expect(resetSource, contains('StorageKeys.recoveryAccessTokenScope'));
    expect(resetSource, contains('StorageKeys.recoveryAccessTokenCreatedAt'));
    expect(resetSource, contains('_readScopedRecoveryToken(phone)'));
    expect(resetSource, contains('_routeRecoveryTokenFor(phone)'));
    expect(
      resetSource,
      contains('storedPhone?.e164 != phone.e164'),
      reason:
          'recovery tokens must be scoped to the exact phone they authorize',
    );
    expect(
      _methodBody(
        resetSource,
        '_ensureRecoveryAuthorization',
      ).indexOf('_routeRecoveryTokenFor(phone)'),
      lessThan(
        _methodBody(
          resetSource,
          '_ensureRecoveryAuthorization',
        ).indexOf('_readScopedRecoveryToken(phone)'),
      ),
      reason:
          'a fresh route recovery token must win over any stored recovery token',
    );
    expect(resetSource, contains('ApiRequestExtra.useRecoveryToken'));
    expect(resetSource, contains('LivenessDecision.autoApprove'));
    expect(resetSource, contains("'liveness_manual_review_confidence'"));
    expect(resetSource, contains("'liveness_challenge_unavailable'"));
    expect(resetSource, contains("'liveness_step_up_validation_failed'"));
    final verifyOtpBody = _methodBody(resetSource, '_verifyOtp');
    final submitResetBody = _methodBody(resetSource, '_submitReset');
    final handleLivenessBody = _methodBody(
      resetSource,
      '_handleLivenessComplete',
    );
    final loadActiveReviewBody = _methodBody(
      resetSource,
      '_loadActiveAccountRecoveryReview',
    );
    final applyReviewTicketBody = _methodBody(
      resetSource,
      '_applyManualReviewTicket',
    );
    final applyBackendManualReviewBody = _methodBody(
      resetSource,
      '_applyBackendManualReview',
    );
    expect(
      verifyOtpBody,
      isNot(contains('evaluateOperation')),
      reason:
          'OTP should only authorize recovery; risk/manual review must wait until the desired new PIN is confirmed',
    );
    expect(
      verifyOtpBody,
      isNot(contains('_routePinResetToManualReview')),
      reason:
          'manual review cannot be created before mobile has the replacement PIN hash',
    );
    expect(
      submitResetBody,
      contains('final newPinHash = _hashPinForBackend(_newPin)'),
      reason: 'confirmed PIN must be converted to the pending reset payload',
    );
    expect(
      submitResetBody.indexOf('_prepareRecoveryDecisionForConfirmedPin'),
      lessThan(submitResetBody.indexOf('_finalizeConfirmedPinReset')),
      reason:
          'risk/liveness/manual-review routing should happen after PIN confirmation and before mutation',
    );
    expect(resetSource, contains('if (decision.stepUpRequired)'));
    expect(
      resetSource.indexOf('if (_requiresFaceAndLiveness(decision))'),
      lessThan(resetSource.indexOf('if (decision.stepUpRequired)')),
      reason:
          'PIN recovery must branch high-risk liveness before generic step-up handling',
    );
    expect(
      _methodBody(resetSource, '_prepareRecoveryDecisionForConfirmedPin'),
      contains('useRecoveryToken: true'),
      reason:
          'all PIN recovery step-up validation paths must use the scoped recovery token, not the normal bearer session',
    );
    expect(
      resetSource.indexOf('await _createRecoveryAuthorizationFromOtp()'),
      lessThan(resetSource.indexOf('evaluateOperation')),
      reason:
          'PIN recovery must exchange OTP for a scoped recovery token before risk/liveness endpoints are called',
    );
    expect(reviewBody, contains('ApiEndpoints.userPinResetManualReview'));
    expect(resetSource, contains('enum _PinRecoveryStep'));
    expect(resetSource, isNot(contains('int _step')));
    expect(resetSource, contains('_transitionTo(_PinRecoveryStep.newPin)'));
    expect(resetSource, contains('_transitionTo(_PinRecoveryStep.liveness)'));
    expect(reviewBody, contains("'newPinHash': pendingPinHash"));
    expect(reviewBody, contains("'reason': reason"));
    expect(
      reviewBody,
      contains(
        'Choose and confirm your new PIN before manual review can start.',
      ),
      reason: 'manual review must fail closed if no replacement PIN exists',
    );
    expect(
      reviewBody,
      contains(
        '_markManualReviewCreating(\n        reason,\n        reviewSla: decision?.reviewSla',
      ),
    );
    expect(
      reviewBody.indexOf('_markManualReviewCreating(reason'),
      lessThan(reviewBody.indexOf('await _ensureRecoveryAuthorization(phone)')),
      reason:
          'manual-review creation state must appear immediately and must not wait for the support ticket network call',
    );
    expect(
      resetSource,
      contains("decision.nextAction ?? 'risk_manual_review'"),
      reason:
          'PIN recovery must honor the backend flow-contract nextAction instead of hardcoding every manual-review reason',
    );
    expect(reviewBody, contains('_markManualReviewCreationFailed(reason)'));
    expect(
      reviewBody.indexOf('_transitionTo(_PinRecoveryStep.manualReview)'),
      lessThan(reviewBody.indexOf('await _ensureRecoveryAuthorization(phone)')),
      reason:
          'liveness provider failures should not strand the user inside the liveness widget while a ticket is created',
    );
    expect(
      loadActiveReviewBody,
      contains('ApiEndpoints.userPinResetReviewCurrent'),
      reason:
          'PIN recovery resume must use the canonical PIN reset review status endpoint, not generic support tickets',
    );
    expect(
      loadActiveReviewBody,
      isNot(contains('/support/tickets/active')),
      reason:
          'manual-review resume must not couple a PIN replacement flow to generic support-ticket list semantics',
    );
    expect(
      applyReviewTicketBody,
      contains(
        "data['hasPendingPinReset'] == true && !_manualReviewPinApplied",
      ),
      reason:
          'manual-review UI can only say the PIN is queued after the API confirms pending PIN material exists',
    );
    expect(
      applyReviewTicketBody,
      contains("data['pinResetApplied'] == true"),
      reason:
          'manual-review resume must distinguish approved/applied PIN reset state from a failed staging request',
    );
    expect(
      applyBackendManualReviewBody,
      contains("'hasPendingPinReset': payload['hasPendingPinReset'] ?? true"),
      reason:
          'backend PIN recovery manual-review fallback happens after the replacement PIN was submitted, so the queued state must not render as not sent',
    );
    expect(
      resetSource,
      contains('This request is not queued yet. Please retry'),
      reason:
          'manual-review staging failures must be honest and retryable, not a false queued state',
    );
    expect(
      handleLivenessBody,
      contains('_transitionTo(_PinRecoveryStep.confirmPin)'),
      reason:
          'successful liveness should return to the PIN confirmation loading state while backend reset applies',
    );
    expect(resetSource, contains('_retryManualReview'));
    expect(resetSource, contains('_returnToSignInFromManualReview'));
    expect(
      resetSource,
      contains('await ref.read(authProvider.notifier).clearLocalSession()'),
      reason:
          'manual-review exit must clear the locked local session before navigating to login',
    );
    expect(resetSource, contains("'step_up_challenge_unavailable'"));
    expect(resetSource, contains('_buildManualReviewStep'));
    expect(riskSource, contains("'account_recovery': StepUpType.manualReview"));
    expect(riskSource, contains('stepUpType == StepUpType.manualReview'));
    expect(
      riskSource,
      contains(
        'low-risk recovery uses an\n  /// OTP user ceremony with a scoped recovery challenge token',
      ),
      reason:
          'account recovery must stay risk-based, while still preserving the backend recovery challenge token',
    );
    expect(
      resetSource,
      contains('Expected first response: within 30 minutes'),
      reason:
          'manual recovery must tell the user what happens next instead of dead-ending at provider failure',
    );
    expect(
      infoPlist,
      contains('identity or liveness checks'),
      reason:
          'iOS camera permission copy must match the recovery/KYC liveness use case',
    );
    expect(
      androidManifest,
      contains('android.permission.CAMERA'),
      reason: 'Android liveness and QR flows require explicit camera access',
    );
  });

  test('KYC liveness declares capture capability and has manual review fallback', () {
    final serviceSource = File(
      'lib/services/liveness/liveness_service.dart',
    ).readAsStringSync();
    final widgetSource = File(
      'lib/features/liveness/widgets/liveness_check_widget.dart',
    ).readAsStringSync();
    final kycLivenessSource = File(
      'lib/features/kyc/views/kyc_liveness_view.dart',
    ).readAsStringSync();
    final kycServiceSource = File(
      'lib/services/kyc/kyc_service.dart',
    ).readAsStringSync();
    final kycRoutesSource = File(
      'lib/router/routes/kyc_settings_routes.dart',
    ).readAsStringSync();
    final riskStepUpSource = File(
      'lib/features/wallet/widgets/risk_step_up_dialog.dart',
    ).readAsStringSync();
    final riskSecurityServiceSource = File(
      'lib/services/security/risk_based_security_service.dart',
    ).readAsStringSync();

    final manualReviewBody = _methodBody(
      kycLivenessSource,
      '_routeKycToManualReview',
    );
    final riskStepUpLivenessBody = _methodBody(
      riskStepUpSource,
      '_onLivenessComplete',
    );

    expect(serviceSource, contains("'capabilities': capabilities.toJson()"));
    expect(serviceSource, contains("'captureMode': captureMode.value"));
    expect(serviceSource, contains("'mediaType': captureMode.value"));
    expect(widgetSource, contains('LivenessClientCapabilities'));
    expect(widgetSource, contains('LivenessCaptureMode.photo'));
    expect(widgetSource, contains('ph.Permission.camera.request()'));
    expect(widgetSource, contains('_LivenessState.cameraPermissionRequired'));
    expect(widgetSource, contains('verification == null'));
    expect(widgetSource, contains('await _releaseCamera()'));
    expect(kycLivenessSource, contains('onManualReviewRequired'));
    expect(
      kycLivenessSource,
      contains('onManualReviewAcknowledged: _acknowledgeManualReview'),
    );
    expect(riskStepUpSource, contains('onManualReviewRequired'));
    expect(
      riskStepUpSource,
      contains('onManualReviewAcknowledged: _acknowledgeLivenessManualReview'),
    );
    expect(riskStepUpSource, contains('LivenessDecision.autoApprove'));
    expect(
      riskStepUpLivenessBody,
      contains('result.stepUpProofId'),
      reason:
          'money-flow step-up must prefer backend livenessProofId and only fall back through LivenessResult.stepUpProofId',
    );
    expect(
      riskSecurityServiceSource,
      contains("'livenessProofId': livenessSessionId"),
      reason:
          'step-up validation should send the canonical proof field while preserving the legacy alias',
    );
    expect(
      riskStepUpLivenessBody,
      contains('challengeToken == null || challengeToken.isEmpty'),
      reason:
          'money-flow liveness must fail closed instead of crashing when a backend challenge token is missing',
    );
    expect(kycServiceSource, contains("'/kyc/manual-review'"));
    expect(kycRoutesSource, contains('redirect: _kycEvidenceRedirect'));
    expect(kycRoutesSource, contains('flow.canSubmit'));
    expect(kycRoutesSource, contains('!flow.hasRequiredPersonalInfo'));
    expect(kycRoutesSource, contains('flow.selectedDocumentType == null'));
    expect(kycRoutesSource, contains('flow.capturedDocuments.isEmpty'));
    expect(kycRoutesSource, contains('flow.selfiePath == null'));
    expect(manualReviewBody, contains('routeToManualReview'));
    expect(manualReviewBody, contains('request.backendReviewAlreadyCreated'));
    expect(manualReviewBody, contains('_refreshKycManualReviewState()'));
    expect(manualReviewBody, contains('_scheduleManualReviewNavigation()'));
    expect(manualReviewBody, contains('_markManualReviewCreationFailed'));
    expect(kycLivenessSource, contains('_retryManualReviewCreation'));
    expect(
      manualReviewBody,
      isNot(contains('_isComplete = false')),
      reason:
          'manual-review creation failure must stay in the review retry state, not collapse into liveness retry',
    );
    expect(
      manualReviewBody,
      contains("'identity_document'"),
      reason:
          'manual KYC review must preserve the same evidence graph as automated face matching',
    );
  });

  test('change PIN uses risk before liveness', () {
    final source = File(
      'lib/features/settings/views/change_pin_view.dart',
    ).readAsStringSync();
    final riskBody = _methodBody(source, '_evaluateChangePinRisk');
    final livenessBody = _methodBody(source, '_handleLivenessComplete');
    final saveBody = _methodBody(source, '_saveNewPin');

    expect(source, contains('ChangePinPhase.riskCheck'));
    expect(
      source,
      contains('ChangePinPhase _phase = ChangePinPhase.riskCheck'),
      reason: 'Change PIN must not open directly into liveness.',
    );
    expect(riskBody, contains("operation: 'pin_change'"));
    expect(riskBody, contains('StepUpType.biometric'));
    expect(riskBody, contains('StepUpType.liveness'));
    expect(riskBody, contains('StepUpType.biometricAndLiveness'));
    expect(
      riskBody,
      isNot(contains('ChangePinPhase.pinEntry')),
      reason:
          'risk evaluation alone must not open PIN entry for a backend-token-gated mutation',
    );
    expect(
      source,
      contains('_phase = ChangePinPhase.pinEntry'),
      reason:
          'PIN entry should still be reachable after validated step-up proof',
    );
    expect(source, contains('String? _validatedStepUpChallengeToken'));
    expect(
      source,
      contains('_validatedStepUpChallengeToken = null'),
      reason: 'each new Change PIN risk evaluation must start with no token',
    );
    expect(
      livenessBody,
      contains('validateStepUp'),
      reason:
          'liveness must validate the backend step-up token before the PIN form opens',
    );
    expect(
      livenessBody,
      contains('_validatedStepUpChallengeToken = challengeToken'),
      reason:
          'the PIN form may open only after backend step-up validation succeeds',
    );
    expect(
      saveBody,
      contains('final challengeToken = _validatedStepUpChallengeToken'),
      reason:
          'the final PIN mutation must use only a validated backend step-up token',
    );
    expect(
      saveBody,
      contains('stepUpChallengeToken: challengeToken'),
      reason: 'the validated token must be sent to the PIN mutation endpoint',
    );
    expect(
      saveBody,
      isNot(contains('final challengeToken = _riskDecision?.challengeToken')),
      reason:
          'the raw risk decision token is only pending; it is not enough to change the PIN',
    );
    expect(
      source,
      isNot(contains('reconnaissance faciale')),
      reason:
          'Change PIN copy must not claim every PIN change requires facial verification.',
    );
  });
}

String _methodBody(String source, String methodName) {
  final signatureIndex = source.indexOf(
    RegExp(
      r'(?:void|bool|String|Widget|Future(?:<[^\n]+>)?)\s+' +
          RegExp.escape(methodName) +
          r'(?:<[^>\n]+>)?\s*\(',
    ),
  );
  expect(signatureIndex, isNonNegative, reason: '$methodName should exist');

  var parameterDepth = 0;
  var bodyStart = -1;
  for (var i = signatureIndex; i < source.length; i++) {
    final char = source[i];
    if (char == '(') {
      parameterDepth++;
    } else if (char == ')') {
      parameterDepth--;
    } else if (char == '{' && parameterDepth == 0) {
      bodyStart = i;
      break;
    }
  }
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
