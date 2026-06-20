import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/features/auth/views/legal_document_view.dart';
import 'package:usdc_wallet/features/auth/views/login_otp_view.dart';
import 'package:usdc_wallet/features/auth/views/login_view.dart';
import 'package:usdc_wallet/features/auth/views/otp_view.dart';
import 'package:usdc_wallet/features/fsm_states/views/index.dart';
import 'package:usdc_wallet/features/onboarding/views/onboarding_view.dart';
import 'package:usdc_wallet/features/onboarding/views/profile_complete_view.dart';
import 'package:usdc_wallet/features/pin/views/pin_screen.dart';
import 'package:usdc_wallet/features/signup/views/signup_kyc_prompt_view.dart';
import 'package:usdc_wallet/features/signup/views/signup_legal_consent_view.dart';
import 'package:usdc_wallet/features/signup/views/signup_otp_verification_view.dart';
import 'package:usdc_wallet/features/signup/views/signup_phone_view.dart';
import 'package:usdc_wallet/features/signup/views/signup_pin_setup_view.dart';
import 'package:usdc_wallet/features/signup/views/signup_profile_setup_view.dart';
import 'package:usdc_wallet/features/signup/views/signup_success_view.dart';
import 'package:usdc_wallet/features/splash/views/splash_view.dart';
import 'package:usdc_wallet/features/wallet/views/create_wallet_view.dart';
import 'package:usdc_wallet/router/page_transitions.dart';
import 'package:usdc_wallet/services/legal/legal_documents_service.dart';

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

  // Product introduction route. This is not account creation.
  GoRoute(
    path: '/onboarding',
    pageBuilder: (context, state) =>
        AppPageTransitions.fade(state: state, child: const OnboardingView()),
  ),

  // Signup/account creation routes. Keep these explicit so login,
  // introduction, and registration cannot drift into each other.
  GoRoute(
    path: '/signup',
    pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
      state: state,
      child: const SignupPhoneView(),
    ),
  ),
  GoRoute(
    path: '/signup/legal-consent',
    pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
      state: state,
      child: const SignupLegalConsentView(),
    ),
  ),
  GoRoute(
    path: '/legal/terms',
    pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
      state: state,
      child: const LegalDocumentView(
        documentType: LegalDocumentType.termsOfService,
      ),
    ),
  ),
  GoRoute(
    path: '/legal/privacy',
    pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
      state: state,
      child: const LegalDocumentView(
        documentType: LegalDocumentType.privacyPolicy,
      ),
    ),
  ),
  GoRoute(
    path: '/signup/verify-phone',
    pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
      state: state,
      child: const SignupOtpVerificationView(),
    ),
  ),
  GoRoute(
    path: '/signup/profile',
    pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
      state: state,
      child: const SignupProfileSetupView(),
    ),
  ),
  GoRoute(
    path: '/signup/set-pin',
    pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
      state: state,
      child: const SignupPinSetupView(),
    ),
  ),
  GoRoute(
    path: '/signup/kyc-prompt',
    pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
      state: state,
      child: const SignupKycPromptView(),
    ),
  ),
  GoRoute(
    path: '/signup/success',
    pageBuilder: (context, state) => AppPageTransitions.scaleAndFade(
      state: state,
      child: const SignupSuccessView(),
    ),
  ),

  // Legacy signup paths. Redirect instead of rendering so old deep links stay
  // valid while new code speaks the explicit signup language.
  GoRoute(path: '/onboarding/phone', redirect: (_, _) => '/signup'),
  GoRoute(
    path: '/onboarding/legal-consent',
    redirect: (_, _) => '/signup/legal-consent',
  ),
  GoRoute(path: '/onboarding/otp', redirect: (_, _) => '/signup/verify-phone'),
  GoRoute(path: '/onboarding/profile', redirect: (_, _) => '/signup/profile'),
  GoRoute(path: '/onboarding/pin', redirect: (_, _) => '/signup/set-pin'),
  GoRoute(
    path: '/onboarding/kyc-prompt',
    redirect: (_, _) => '/signup/kyc-prompt',
  ),
  GoRoute(path: '/onboarding/success', redirect: (_, _) => '/signup/success'),

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
      child: PinScreen(
        pinContext: PinContext.login,
        successRoute: _authReturnTo(state),
      ),
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
  return _safeReturnTo(state) ?? '/home';
}

String? _authReturnTo(GoRouterState state) {
  return _safeReturnTo(state);
}

String? _safeReturnTo(GoRouterState state) {
  final returnTo = state.uri.queryParameters['returnTo']?.trim();
  if (returnTo == null || returnTo.isEmpty) {
    return null;
  }

  final uri = Uri.tryParse(returnTo);
  if (uri == null ||
      uri.hasScheme ||
      uri.hasAuthority ||
      !returnTo.startsWith('/') ||
      returnTo.startsWith('//') ||
      returnTo.startsWith('/login') ||
      returnTo.startsWith('/signup') ||
      returnTo.startsWith('/onboarding') ||
      returnTo == '/session-locked') {
    return null;
  }

  return returnTo;
}
