import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/features/auth/views/login_otp_view.dart';
import 'package:usdc_wallet/features/auth/views/login_view.dart';
import 'package:usdc_wallet/features/auth/views/otp_view.dart';
import 'package:usdc_wallet/features/fsm_states/views/index.dart';
import 'package:usdc_wallet/features/onboarding/views/kyc_prompt_view.dart';
import 'package:usdc_wallet/features/onboarding/views/onboarding_pin_view.dart';
import 'package:usdc_wallet/features/onboarding/views/onboarding_success_view.dart';
import 'package:usdc_wallet/features/onboarding/views/onboarding_view.dart';
import 'package:usdc_wallet/features/onboarding/views/otp_verification_view.dart';
import 'package:usdc_wallet/features/onboarding/views/phone_input_view.dart';
import 'package:usdc_wallet/features/onboarding/views/profile_complete_view.dart';
import 'package:usdc_wallet/features/onboarding/views/profile_setup_view.dart';
import 'package:usdc_wallet/features/pin/views/pin_screen.dart';
import 'package:usdc_wallet/features/splash/views/splash_view.dart';
import 'package:usdc_wallet/features/wallet/views/create_wallet_view.dart';
import 'package:usdc_wallet/router/page_transitions.dart';

List<RouteBase> authStateRoutes() => [
  // Splash Screen (no transition)
  GoRoute(
    path: '/',
    pageBuilder: (context, state) =>
        AppPageTransitions.none(state: state, child: const SplashView()),
  ),

  // Profile completion (post-login name capture)
  GoRoute(
    path: '/profile-complete',
    pageBuilder: (context, state) => AppPageTransitions.fade(
      state: state,
      child: const ProfileCompleteView(),
    ),
  ),

  // Onboarding Route (fade)
  GoRoute(
    path: '/onboarding',
    pageBuilder: (context, state) =>
        AppPageTransitions.fade(state: state, child: const OnboardingView()),
  ),
  GoRoute(
    path: '/onboarding/phone',
    pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
      state: state,
      child: const PhoneInputView(),
    ),
  ),
  GoRoute(
    path: '/onboarding/otp',
    pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
      state: state,
      child: const OtpVerificationView(),
    ),
  ),
  GoRoute(
    path: '/onboarding/profile',
    pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
      state: state,
      child: const ProfileSetupView(),
    ),
  ),
  GoRoute(
    path: '/onboarding/pin',
    pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
      state: state,
      child: const OnboardingPinView(),
    ),
  ),
  GoRoute(
    path: '/onboarding/kyc-prompt',
    pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
      state: state,
      child: const KycPromptView(),
    ),
  ),
  GoRoute(
    path: '/onboarding/success',
    pageBuilder: (context, state) => AppPageTransitions.scaleAndFade(
      state: state,
      child: const OnboardingSuccessView(),
    ),
  ),

  // Auth Routes (fade for smooth transitions)
  GoRoute(
    path: '/login',
    pageBuilder: (context, state) =>
        AppPageTransitions.fade(state: state, child: const LoginView()),
  ),
  GoRoute(
    path: '/login/otp',
    pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
      state: state,
      child: const LoginOtpView(),
    ),
  ),
  GoRoute(
    path: '/login/pin',
    pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
      state: state,
      child: const PinScreen(pinContext: PinContext.login),
    ),
  ),
  GoRoute(
    path: '/otp',
    pageBuilder: (context, state) =>
        AppPageTransitions.fade(state: state, child: const OtpView()),
  ),

  // FSM State-specific Routes
  GoRoute(
    path: '/otp-expired',
    pageBuilder: (context, state) =>
        AppPageTransitions.fade(state: state, child: const OtpExpiredView()),
  ),
  GoRoute(
    path: '/auth-locked',
    pageBuilder: (context, state) =>
        AppPageTransitions.fade(state: state, child: const AuthLockedView()),
  ),
  GoRoute(
    path: '/auth-suspended',
    pageBuilder: (context, state) =>
        AppPageTransitions.fade(state: state, child: const AuthSuspendedView()),
  ),
  GoRoute(
    path: '/session-locked',
    pageBuilder: (context, state) => AppPageTransitions.fade(
      state: state,
      child: PinScreen(
        pinContext: PinContext.sessionLock,
        successRoute: _sessionLockReturnTo(state),
      ),
    ),
  ),
  GoRoute(
    path: '/biometric-prompt',
    pageBuilder: (context, state) => AppPageTransitions.fade(
      state: state,
      child: const BiometricPromptView(),
    ),
  ),
  GoRoute(
    path: '/device-verification',
    pageBuilder: (context, state) => AppPageTransitions.fade(
      state: state,
      child: const DeviceVerificationView(),
    ),
  ),
  GoRoute(
    path: '/session-conflict',
    pageBuilder: (context, state) => AppPageTransitions.fade(
      state: state,
      child: const SessionConflictView(),
    ),
  ),
  GoRoute(
    path: '/wallet-frozen',
    pageBuilder: (context, state) =>
        AppPageTransitions.fade(state: state, child: const WalletFrozenView()),
  ),
  GoRoute(
    path: '/wallet-under-review',
    pageBuilder: (context, state) => AppPageTransitions.fade(
      state: state,
      child: const WalletUnderReviewView(),
    ),
  ),
  GoRoute(
    path: '/kyc-expired',
    pageBuilder: (context, state) =>
        AppPageTransitions.fade(state: state, child: const KycExpiredView()),
  ),
  GoRoute(
    path: '/loading',
    pageBuilder: (context, state) =>
        AppPageTransitions.fade(state: state, child: const LoadingView()),
  ),
  GoRoute(
    path: '/force-update',
    pageBuilder: (context, state) =>
        AppPageTransitions.fade(state: state, child: const ForceUpdateView()),
  ),
  GoRoute(
    path: '/maintenance',
    pageBuilder: (context, state) =>
        AppPageTransitions.fade(state: state, child: const MaintenanceView()),
  ),
  GoRoute(
    path: '/server-error',
    pageBuilder: (context, state) =>
        AppPageTransitions.fade(state: state, child: const ServerErrorView()),
  ),
  GoRoute(
    path: '/create-wallet',
    pageBuilder: (context, state) =>
        AppPageTransitions.fade(state: state, child: const CreateWalletView()),
  ),
];

String _sessionLockReturnTo(GoRouterState state) {
  final returnTo = state.uri.queryParameters['returnTo']?.trim();
  if (returnTo == null || returnTo.isEmpty) {
    return '/home';
  }

  final uri = Uri.tryParse(returnTo);
  if (uri == null ||
      uri.hasScheme ||
      uri.hasAuthority ||
      !returnTo.startsWith('/') ||
      returnTo.startsWith('//') ||
      returnTo.startsWith('/login') ||
      returnTo.startsWith('/onboarding') ||
      returnTo == '/session-locked') {
    return '/home';
  }

  return returnTo;
}
