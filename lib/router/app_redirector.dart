import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/config/environment_config.dart';
import 'package:usdc_wallet/features/auth/models/login_state.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart' as auth;
import 'package:usdc_wallet/features/auth/providers/login_provider.dart';
import 'package:usdc_wallet/features/signup/providers/signup_flow_provider.dart';
import 'package:usdc_wallet/services/app_version/mobile_version_policy_service.dart';
import 'package:usdc_wallet/services/feature_flags/feature_flags_extensions.dart';
import 'package:usdc_wallet/services/feature_flags/feature_flags_provider.dart';
import 'package:usdc_wallet/services/session/session_service.dart';
import 'package:usdc_wallet/state/fsm/index.dart';
import 'package:usdc_wallet/state/kyc_state_machine.dart' as kyc_machine;
import 'package:usdc_wallet/state/user_state_machine.dart';
import 'package:usdc_wallet/state/wallet_state_machine.dart';
import 'package:usdc_wallet/utils/logger.dart';

const _routerLogger = AppLogger('Router');

/// Triggers GoRouter refreshes when auth, onboarding, KYC, or FSM state changes.
class RouterRefreshNotifier extends ChangeNotifier {
  RouterRefreshNotifier(Ref ref) {
    ref
      // Listen to auth state changes.
      ..listen(auth.authProvider, (_, _) => notifyListeners())
      // Listen to session lock/unlock changes.
      ..listen(sessionServiceProvider, (_, _) => notifyListeners())
      // Listen to wallet state changes for onboarding redirect.
      ..listen(walletStateMachineProvider, (_, _) => notifyListeners())
      // Listen to user state changes for profile completion redirect.
      ..listen(userStateMachineProvider, (previous, next) {
        if (previous?.firstName != next.firstName) {
          notifyListeners();
        }
      })
      // Listen to FSM state changes for navigation.
      ..listen(appFsmProvider, (previous, next) {
        if (previous?.currentScreen != next.currentScreen) {
          notifyListeners();
        }
      })
      ..listen(kyc_machine.kycStateMachineProvider, (_, _) => notifyListeners())
      ..listen(mobileVersionPolicyProvider, (previous, next) {
        if (previous?.forceUpgrade != next.forceUpgrade) {
          notifyListeners();
        }
      });
  }
}

final routerRefreshProvider = Provider<RouterRefreshNotifier>(
  RouterRefreshNotifier.new,
);

String? appRedirect(BuildContext context, GoRouterState state) {
  final container = ProviderScope.containerOf(context);
  final authState = container.read(auth.authProvider);
  final userState = container.read(userStateMachineProvider);
  final flags = container.read(featureFlagsProvider);
  final sessionState = container.read(sessionServiceProvider);
  final loginState = container.read(loginProvider);
  final signupState = container.read(signupFlowProvider);
  final appFsmState = container.read(appFsmProvider);
  final kycState = container.read(kyc_machine.kycStateMachineProvider);
  final versionPolicyState = container.read(mobileVersionPolicyProvider);

  final isAuthenticated = authState.isAuthenticated;
  final location = state.matchedLocation;
  final fsmTargetRoute = appFsmState.currentRoute;

  _routerLogger.debug(
    'Redirect check: location=$location, fsmTarget=$fsmTargetRoute',
  );

  final loadingRedirect = _loadingWalletRedirect(location, fsmTargetRoute);
  if (loadingRedirect != null) {
    return loadingRedirect;
  }

  final isWithinSameFlow = _isWithinSameFlow(location, fsmTargetRoute);
  final isOnboardingRoute = _isOnboardingRoute(location);
  final isSignupRoute =
      _isSignupRoute(location) || _isLegacySignupRoute(location);
  final isFsmRoute = _isFsmRoute(location);
  final isPublicRoute = _isPublicRoute(location);

  if (location == '/') {
    return null;
  }

  if (versionPolicyState.forceUpgrade && location != '/force-update') {
    return '/force-update';
  }

  if (!versionPolicyState.forceUpgrade && location == '/force-update') {
    return isAuthenticated ? '/home' : '/login';
  }

  final isLockedState =
      !EnvironmentConfig.debugSkipPin &&
      (authState.isLocked || sessionState.isLocked);
  final lockRedirect = _lockRedirect(
    location: location,
    routeIntent: state.uri.toString(),
    isLockedState: isLockedState,
  );
  if (lockRedirect != null) {
    return lockRedirect;
  }

  final unlockedLockScreenRedirect = _unlockedLockScreenRedirect(
    location: location,
    isAuthenticated: isAuthenticated,
    isLockedState: isLockedState,
  );
  if (unlockedLockScreenRedirect != null) {
    return unlockedLockScreenRedirect;
  }

  final otpContextRedirect = _otpContextRedirect(
    location: location,
    isAuthenticated: isAuthenticated,
    authState: authState,
    loginState: loginState,
    signupState: signupState,
  );
  if (otpContextRedirect != null) {
    return otpContextRedirect;
  }

  if (isAuthenticated &&
      !isLockedState &&
      _isAuthenticatedDeadEndRoute(location)) {
    return '/home';
  }

  final invalidPinLoginRedirect = _invalidPinLoginRedirect(
    location: location,
    isAuthenticated: isAuthenticated,
    isLockedState: isLockedState,
    pendingPinSessionToken: loginState.sessionToken,
  );
  if (invalidPinLoginRedirect != null) {
    return invalidPinLoginRedirect;
  }

  final fsmRedirect = _fsmRedirect(
    location: location,
    fsmTargetRoute: fsmTargetRoute,
    isLockedState: isLockedState,
    isFsmRoute: isFsmRoute,
    isOnboardingRoute: isOnboardingRoute || isSignupRoute,
    isPublicRoute: isPublicRoute,
    isWithinSameFlow: isWithinSameFlow,
  );
  if (fsmRedirect != null) {
    return fsmRedirect;
  }

  if (!isAuthenticated && !isLockedState && !isPublicRoute) {
    return '/login';
  }

  final profileRedirect = _profileRedirect(
    location: location,
    isAuthenticated: isAuthenticated,
    isOnboardingRoute: isOnboardingRoute || isSignupRoute,
    authFirstName: authState.user?.firstName,
    stateFirstName: userState.firstName,
    profileKnown: authState.user != null || userState.userId != null,
  );
  if (profileRedirect != null) {
    return profileRedirect;
  }

  if (isAuthenticated && _isAuthRoute(location)) {
    return '/home';
  }

  if (isAuthenticated &&
      _requiresVerifiedKycPath(location) &&
      kycState.status.name != 'verified') {
    return '/kyc';
  }

  return _featureFlagRedirect(location, flags);
}

String? _loadingWalletRedirect(String location, String fsmTargetRoute) {
  if ((location == '/loading' || location == '/create-wallet') &&
      fsmTargetRoute == '/home') {
    return '/home';
  }
  return null;
}

bool _isWithinSameFlow(String location, String fsmTargetRoute) {
  final locationBase = _routeBase(location);
  final fsmBase = _routeBase(fsmTargetRoute);
  final isWithinSameFlow = locationBase == fsmBase;

  _routerLogger.debug(
    'Flow check: locationBase=$locationBase, fsmBase=$fsmBase, isWithinSameFlow=$isWithinSameFlow',
  );

  return isWithinSameFlow;
}

String? _lockRedirect({
  required String location,
  required String routeIntent,
  required bool isLockedState,
}) {
  if (isLockedState && !_isAllowedWhenLockedRoute(location)) {
    final returnTo = Uri.encodeComponent(routeIntent);
    return '/session-locked?returnTo=$returnTo';
  }
  return null;
}

String? _unlockedLockScreenRedirect({
  required String location,
  required bool isAuthenticated,
  required bool isLockedState,
}) {
  if (location != '/session-locked' || isLockedState) {
    return null;
  }
  return isAuthenticated ? '/home' : '/login';
}

String? _otpContextRedirect({
  required String location,
  required bool isAuthenticated,
  required auth.AuthState authState,
  required LoginState loginState,
  required SignupFlowState signupState,
}) {
  if (location == '/login/otp' && !_hasLoginOtpContext(loginState)) {
    return '/login';
  }

  if (location == '/signup/verify-phone' &&
      !_hasSignupOtpContext(signupState, authState)) {
    return isAuthenticated ? '/home' : '/signup';
  }

  if (location == '/otp' && !_hasLegacyOtpContext(authState)) {
    return '/login';
  }

  return null;
}

bool _hasLoginOtpContext(LoginState state) =>
    state.currentStep == LoginStep.otp && state.phoneValue != null;

bool _hasSignupOtpContext(SignupFlowState state, auth.AuthState authState) {
  final hasPhone =
      (state.phoneNumber?.trim().isNotEmpty ?? false) ||
      (authState.phone?.trim().isNotEmpty ?? false);
  return hasPhone && authState.status == auth.AuthStatus.otpSent;
}

bool _hasLegacyOtpContext(auth.AuthState state) {
  final hasPhone = state.phone?.trim().isNotEmpty ?? false;
  return hasPhone &&
      (state.status == auth.AuthStatus.otpSent ||
          state.status == auth.AuthStatus.loading ||
          state.status == auth.AuthStatus.error);
}

String? _fsmRedirect({
  required String location,
  required String fsmTargetRoute,
  required bool isLockedState,
  required bool isFsmRoute,
  required bool isOnboardingRoute,
  required bool isPublicRoute,
  required bool isWithinSameFlow,
}) {
  if (!isLockedState &&
      !isFsmRoute &&
      !isOnboardingRoute &&
      !isPublicRoute &&
      fsmTargetRoute != location &&
      fsmTargetRoute != '/home' &&
      !isWithinSameFlow) {
    _routerLogger.debug('Redirecting to FSM target: $fsmTargetRoute');
    return fsmTargetRoute;
  }
  return null;
}

String? _profileRedirect({
  required String location,
  required bool isAuthenticated,
  required bool isOnboardingRoute,
  required String? authFirstName,
  required String? stateFirstName,
  required bool profileKnown,
}) {
  final hasProfileName =
      (authFirstName != null && authFirstName.trim().isNotEmpty) ||
      (stateFirstName?.trim().isNotEmpty ?? false);
  final isProfileCaptureRoute =
      location == '/profile-complete' || location == '/signup/profile';

  if (isAuthenticated &&
      profileKnown &&
      !hasProfileName &&
      location.startsWith('/signup/') &&
      !isProfileCaptureRoute &&
      location != '/signup' &&
      location != '/signup/legal-consent' &&
      location != '/signup/verify-phone') {
    return '/signup/profile';
  }

  if (isAuthenticated &&
      profileKnown &&
      !hasProfileName &&
      !isOnboardingRoute &&
      !isProfileCaptureRoute) {
    return '/profile-complete';
  }

  return null;
}

String? _featureFlagRedirect(String location, Map<String, bool> flags) {
  if (flags.isEmpty) {
    return null;
  }

  if (location == '/withdraw' &&
      !flags.canWithdraw &&
      !flags.canUseMobileMoneyWithdrawals) {
    return '/home';
  }
  if (location.startsWith('/send-external') && !flags.canUseExternalTransfers) {
    return '/home';
  }

  if (location == '/airtime' && !flags.canBuyAirtime) {
    return '/home';
  }
  if ((location == '/bills' || location.startsWith('/bill-payments')) &&
      !flags.canPayBills &&
      !flags.canUseBillPayments) {
    return '/home';
  }

  if (location == '/savings' &&
      !flags.canSetSavingsGoals &&
      !flags.canUseSavingsPots) {
    return '/home';
  }
  if (location.startsWith('/savings-pots') && !flags.canUseSavingsPots) {
    return '/home';
  }
  if ((location == '/card' || location.startsWith('/cards/')) &&
      !flags.canUseVirtualCards) {
    return '/home';
  }
  if (location == '/split' && !flags.canSplitBills) {
    return '/home';
  }
  if (location == '/budget' && !flags.canUseBudget) {
    return '/home';
  }
  if ((location == '/scheduled' ||
          location.startsWith('/recurring-transfers')) &&
      !flags.canScheduleTransfers) {
    return '/home';
  }

  if (location == '/analytics' && !flags.canViewAnalytics) {
    return '/home';
  }
  if (location == '/converter' && !flags.canUseCurrencyConverter) {
    return '/home';
  }
  if (location == '/request' &&
      !flags.canRequestMoney &&
      !flags.canUsePaymentLinks) {
    return '/home';
  }
  if (location == '/recipients' && !flags.canUseSavedRecipients) {
    return '/home';
  }
  if (location.startsWith('/payment-links') && !flags.canUsePaymentLinks) {
    return '/home';
  }
  if (location == '/referrals' &&
      !flags.canReferFriends &&
      !flags.canUseReferralProgram) {
    return '/home';
  }
  if (_isMerchantQrPath(location) && !flags.canUseMerchantQr) {
    return '/home';
  }

  return null;
}

bool _isPublicRoute(String location) =>
    isPublicAppRoute(location) ||
    location == '/force-update' ||
    location.startsWith('/session-locked');

bool _isSecurityRecoveryRoute(String location) =>
    isSecurityRecoveryAppRoute(location);

bool _isAllowedWhenLockedRoute(String location) =>
    appRouteContractFor(location).isAllowedWhenLocked;

String? _invalidPinLoginRedirect({
  required String location,
  required bool isAuthenticated,
  required bool isLockedState,
  required String? pendingPinSessionToken,
}) {
  if (location != '/login/pin' || isLockedState) {
    return null;
  }

  if (isAuthenticated) {
    return '/home';
  }

  final hasPendingPinSession =
      pendingPinSessionToken != null && pendingPinSessionToken.isNotEmpty;
  return hasPendingPinSession ? null : '/login';
}

bool _isOnboardingRoute(String location) =>
    location == '/onboarding' ||
    location == '/profile-complete' ||
    isSetupAppRoute(location);

bool _isSignupRoute(String location) => isSignupAppRoute(location);

bool _isLegacySignupRoute(String location) => isLegacySignupAppRoute(location);

bool _isFsmRoute(String location) => isFsmOwnedAppRoute(location);

bool _isAuthRoute(String location) =>
    location.startsWith('/login') || location == '/otp';

bool _isAuthenticatedDeadEndRoute(String location) =>
    isAuthDeadEndAppRoute(location);

bool _isMerchantQrPath(String location) =>
    location == '/scan-to-pay' ||
    location == '/merchant-dashboard' ||
    location == '/merchant-qr' ||
    location == '/create-payment-request' ||
    location == '/merchant-transactions';

bool _requiresVerifiedKycPath(String location) =>
    requiresVerifiedKycAppRoute(location);

String _routeBase(String location) =>
    '/${location.split('/').where((segment) => segment.isNotEmpty).take(1).join('/')}';
