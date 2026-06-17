import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/features/biometric/views/biometric_enrollment_view.dart';
import 'package:usdc_wallet/features/biometric/views/biometric_settings_view.dart';
import 'package:usdc_wallet/features/business/views/business_profile_view.dart';
import 'package:usdc_wallet/features/business/views/business_setup_view.dart';
import 'package:usdc_wallet/features/kyc/models/kyc_tier.dart' as kyc_models;
import 'package:usdc_wallet/features/kyc/views/document_capture_view.dart';
import 'package:usdc_wallet/features/kyc/views/document_type_view.dart';
import 'package:usdc_wallet/features/kyc/views/kyc_additional_docs_view.dart';
import 'package:usdc_wallet/features/kyc/views/kyc_address_view.dart';
import 'package:usdc_wallet/features/kyc/views/kyc_liveness_instructions_view.dart';
import 'package:usdc_wallet/features/kyc/views/kyc_liveness_view.dart';
import 'package:usdc_wallet/features/kyc/views/kyc_personal_info_view.dart';
import 'package:usdc_wallet/features/kyc/views/kyc_status_view.dart';
import 'package:usdc_wallet/features/kyc/views/kyc_upgrade_view.dart';
import 'package:usdc_wallet/features/kyc/views/kyc_video_view.dart';
import 'package:usdc_wallet/features/kyc/views/review_view.dart';
import 'package:usdc_wallet/features/kyc/views/selfie_view.dart';
import 'package:usdc_wallet/features/kyc/views/submitted_view.dart';
import 'package:usdc_wallet/features/notifications/views/notification_permission_screen.dart';
import 'package:usdc_wallet/features/notifications/views/notification_preferences_screen.dart';
import 'package:usdc_wallet/features/profile/views/email_verification_screen.dart';
import 'package:usdc_wallet/features/referrals/views/referrals_view.dart';
import 'package:usdc_wallet/features/settings/views/cookie_policy_view.dart';
import 'package:usdc_wallet/features/settings/views/currency_view.dart';
import 'package:usdc_wallet/features/settings/views/delete_account_view.dart';
import 'package:usdc_wallet/features/settings/views/devices_screen.dart';
import 'package:usdc_wallet/features/settings/views/help_view.dart';
import 'package:usdc_wallet/features/settings/views/language_view.dart';
import 'package:usdc_wallet/features/settings/views/limits_view.dart';
import 'package:usdc_wallet/features/settings/views/notification_settings_view.dart';
import 'package:usdc_wallet/features/settings/views/profile_edit_screen.dart';
import 'package:usdc_wallet/features/settings/views/security_view.dart';
import 'package:usdc_wallet/features/settings/views/sessions_screen.dart';
import 'package:usdc_wallet/features/settings/views/theme_settings_view.dart';
import 'package:usdc_wallet/router/page_transitions.dart';

List<RouteBase> kycSettingsRoutes() => [
  // KYC Flow Routes
  GoRoute(
    path: '/kyc',
    pageBuilder: (context, state) =>
        AppPageTransitions.fade(state: state, child: const KycStatusView()),
  ),
  GoRoute(path: '/kyc/start', redirect: (_, _) => '/kyc/document-type'),
  GoRoute(
    path: '/kyc/document-type',
    pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
      state: state,
      child: const DocumentTypeView(),
    ),
  ),
  GoRoute(
    path: '/kyc/personal-info',
    pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
      state: state,
      child: const KycPersonalInfoView(),
    ),
  ),
  GoRoute(
    path: '/kyc/document-capture',
    pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
      state: state,
      child: const DocumentCaptureView(),
    ),
  ),
  GoRoute(
    path: '/kyc/selfie',
    pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
      state: state,
      child: const SelfieView(),
    ),
  ),
  GoRoute(
    path: '/kyc/liveness-instructions',
    pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
      state: state,
      child: const KycLivenessInstructionsView(),
    ),
  ),
  GoRoute(
    path: '/kyc/liveness',
    pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
      state: state,
      child: const KycLivenessView(),
    ),
  ),
  GoRoute(
    path: '/kyc/review',
    pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
      state: state,
      child: const ReviewView(),
    ),
  ),
  GoRoute(
    path: '/kyc/submitted',
    pageBuilder: (context, state) =>
        AppPageTransitions.fade(state: state, child: const SubmittedView()),
  ),
  GoRoute(
    path: '/kyc/upgrade',
    pageBuilder: (context, state) {
      final currentTier = state.extra as Map<String, dynamic>?;
      return AppPageTransitions.verticalSlide(
        state: state,
        child: KycUpgradeView(
          currentTier:
              currentTier?['currentTier'] as kyc_models.KycTier? ??
              kyc_models.KycTier.tier0,
          targetTier:
              currentTier?['targetTier'] as kyc_models.KycTier? ??
              kyc_models.KycTier.tier1,
          reason: currentTier?['reason'] as String?,
        ),
      );
    },
  ),
  GoRoute(
    path: '/kyc/address',
    pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
      state: state,
      child: const KycAddressView(),
    ),
  ),
  GoRoute(
    path: '/kyc/video',
    pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
      state: state,
      child: const KycVideoView(),
    ),
  ),
  GoRoute(
    path: '/kyc/additional-docs',
    pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
      state: state,
      child: const KycAdditionalDocsView(),
    ),
  ),
  GoRoute(
    path: '/settings/notifications',
    pageBuilder: (context, state) => AppPageTransitions.fade(
      state: state,
      child: const NotificationSettingsView(),
    ),
  ),
  GoRoute(
    path: '/notifications/permission',
    pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
      state: state,
      child: const NotificationPermissionScreen(),
    ),
  ),
  GoRoute(
    path: '/notifications/preferences',
    pageBuilder: (context, state) => AppPageTransitions.fade(
      state: state,
      child: const NotificationPreferencesScreen(),
    ),
  ),
  GoRoute(
    path: '/settings/security',
    pageBuilder: (context, state) =>
        AppPageTransitions.fade(state: state, child: const SecurityView()),
  ),
  GoRoute(
    path: '/settings/biometric',
    pageBuilder: (context, state) => AppPageTransitions.fade(
      state: state,
      child: const BiometricSettingsView(),
    ),
  ),
  GoRoute(
    path: '/settings/biometric/enrollment',
    pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
      state: state,
      child: const BiometricEnrollmentView(),
    ),
  ),
  GoRoute(
    path: '/settings/limits',
    pageBuilder: (context, state) =>
        AppPageTransitions.fade(state: state, child: const LimitsView()),
  ),
  GoRoute(
    path: '/settings/help',
    pageBuilder: (context, state) =>
        AppPageTransitions.fade(state: state, child: const HelpView()),
  ),
  GoRoute(
    path: '/settings/language',
    pageBuilder: (context, state) =>
        AppPageTransitions.fade(state: state, child: const LanguageView()),
  ),
  GoRoute(
    path: '/settings/theme',
    pageBuilder: (context, state) =>
        AppPageTransitions.fade(state: state, child: const ThemeSettingsView()),
  ),
  GoRoute(
    path: '/settings/currency',
    pageBuilder: (context, state) =>
        AppPageTransitions.fade(state: state, child: const CurrencyView()),
  ),
  GoRoute(
    path: '/settings/devices',
    pageBuilder: (context, state) =>
        AppPageTransitions.fade(state: state, child: const DevicesScreen()),
  ),
  GoRoute(
    path: '/settings/sessions',
    pageBuilder: (context, state) =>
        AppPageTransitions.fade(state: state, child: const SessionsScreen()),
  ),
  GoRoute(
    path: '/settings/delete-account',
    pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
      state: state,
      child: const DeleteAccountView(),
    ),
  ),
  GoRoute(
    path: '/profile/verify-email',
    pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
      state: state,
      child: EmailVerificationScreen(
        successRoute: state.uri.queryParameters['successRoute'],
      ),
    ),
  ),
  GoRoute(
    path: '/settings/profile/edit',
    pageBuilder: (context, state) =>
        AppPageTransitions.fade(state: state, child: const ProfileEditScreen()),
  ),
  GoRoute(
    path: '/settings/business-setup',
    pageBuilder: (context, state) =>
        AppPageTransitions.fade(state: state, child: const BusinessSetupView()),
  ),
  GoRoute(
    path: '/settings/business-profile',
    pageBuilder: (context, state) => AppPageTransitions.fade(
      state: state,
      child: const BusinessProfileView(),
    ),
  ),
  GoRoute(
    path: '/settings/legal/cookies',
    pageBuilder: (context, state) =>
        AppPageTransitions.fade(state: state, child: const CookiePolicyView()),
  ),
  GoRoute(
    path: '/settings/cookies',
    redirect: (_, _) => '/settings/legal/cookies',
  ),
  GoRoute(path: '/settings/terms', redirect: (_, _) => '/settings/help'),
  GoRoute(path: '/settings/privacy', redirect: (_, _) => '/settings/help'),

  // Referrals Page - moved out of bottom nav (fade)
  GoRoute(
    path: '/referrals',
    pageBuilder: (context, state) =>
        AppPageTransitions.fade(state: state, child: const ReferralsView()),
  ),
];
