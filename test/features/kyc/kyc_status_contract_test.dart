import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/kyc/models/kyc_status.dart';
import 'package:usdc_wallet/utils/kyc_utils.dart';

void main() {
  group('KycStatus contract', () {
    test('preserves manual_review for FSM and compliance routing', () {
      final status = KycStatus.fromString('manual_review');

      expect(status, KycStatus.manualReview);
      expect(status.toApiString(), 'manual_review');
      expect(status.isManualReview, isTrue);
      expect(status.isInReview, isTrue);
      expect(status.needsKyc, isFalse);
    });

    test('normalizes backend approval vocabulary for display and limits', () {
      for (final backendStatus in ['approved', 'auto_approved', 'verified']) {
        expect(KycStatus.fromString(backendStatus), KycStatus.verified);
        expect(kycStatusConfig(backendStatus).label, 'Verified');
        expect(
          kycLimitDescription(backendStatus),
          'Daily: 5,000 USDC · Monthly: 50,000 USDC',
        );
      }
    });

    test('keeps review states out of needs-kyc display bucket', () {
      for (final backendStatus in [
        'submitted',
        'pending_verification',
        'in_review',
        'manual_review',
      ]) {
        expect(kycStatusConfig(backendStatus).label, 'Under Review');
        expect(
          kycLimitDescription(backendStatus),
          'Daily: 500 USDC · Monthly: 5,000 USDC',
        );
      }
    });

    test('status loader preserves backend rejection reason for user display', () {
      final source = File(
        'lib/features/kyc/providers/kyc_provider.dart',
      ).readAsStringSync();
      final loadStatusBody = RegExp(
        r'Future<void> loadVerificationStatus\(\) async \{([\s\S]*?)\n  \}',
      ).firstMatch(source)!.group(1)!;

      expect(loadStatusBody, contains('rejectionReason: data.rejectionReason'));
      expect(
        loadStatusBody,
        contains("'status': data.status.toApiString()"),
        reason:
            'KYC status refresh must preserve API vocabulary like manual_review instead of enum names like manualReview.',
      );
      expect(
        loadStatusBody,
        contains('kycStateMachineProvider.notifier'),
        reason:
            'KYC status refresh must update the durable FSM source used by redirects.',
      );
      expect(
        loadStatusBody,
        contains('updateFromAuthResponse(data.status.toApiString())'),
      );
      expect(
        loadStatusBody,
        contains('clearVerificationStatus: true'),
        reason:
            'A KYC refresh must clear stale local wizard status so manual-review '
            'screens wait for the fresh /kyc/status response after admin review.',
      );
      expect(
        loadStatusBody.indexOf('updateFromAuthResponse'),
        lessThan(
          loadStatusBody.indexOf(
            'state = state.copyWith(\n        isLoading: false',
          ),
        ),
        reason:
            'Durable KYC FSM should be synchronized before local flow state drives UI decisions.',
      );
    });

    test('KYC service unwraps API envelope before reading status', () {
      final serviceSource = File(
        'lib/services/kyc/kyc_service.dart',
      ).readAsStringSync();
      final getStatusBody = RegExp(
        r'Future<KycStatusResponse> getKycStatus\(\{bool forceRefresh = false\}\) async \{([\s\S]*?)\n  \}',
      ).firstMatch(serviceSource)!.group(1)!;

      expect(getStatusBody, contains('apiResponsePayload(response.data)'));
      expect(
        getStatusBody,
        isNot(contains('response.data as Map<String, dynamic>')),
        reason:
            'Wrapped API responses must not fall back to pending when the real status is approved.',
      );
      expect(
        serviceSource,
        contains('final data = apiResponsePayload(response.data);'),
        reason:
            'Document, liveness, and verification responses can also be API envelopes.',
      );
    });

    test('manual review has its own user-facing copy contract', () {
      final statusView = File(
        'lib/features/kyc/views/kyc_status_view.dart',
      ).readAsStringSync();
      final submittedView = File(
        'lib/features/kyc/views/submitted_view.dart',
      ).readAsStringSync();

      expect(statusView, contains('kyc_status_manualReview_title'));
      expect(statusView, contains('kyc_status_manualReview_description'));
      expect(statusView, contains('kyc_info_manualReview_title'));
      expect(statusView, contains('KycStatus.manualReview'));

      expect(submittedView, contains('kycStateMachineProvider'));
      expect(submittedView, contains('status == KycStatus.manualReview'));
      expect(submittedView, contains('_effectiveStatus'));
      expect(submittedView, contains('kyc_status_manualReview_title'));
      expect(submittedView, contains('kyc_info_manualReview_description'));
    });

    test('KYC status screen waits for API-backed status before restart', () {
      final statusView = File(
        'lib/features/kyc/views/kyc_status_view.dart',
      ).readAsStringSync();

      expect(statusView, contains('kycStateMachineProvider'));
      expect(statusView, contains('_effectiveStatus'));
      expect(statusView, contains('_isAuthoritativeDurableStatus'));
      expect(statusView, contains('hasAuthoritativeStatus'));
      expect(statusView, contains('await _refreshStatus();'));
      expect(statusView, contains('if (flowStatus != null)'));
      expect(
        statusView.indexOf('if (_isAuthoritativeDurableStatus(durableState))'),
        lessThan(statusView.indexOf('if (flowStatus != null)')),
        reason:
            'A fresh API-backed durable KYC status must override stale wizard state after admin review.',
      );
      expect(
        statusView,
        isNot(contains('state.verificationStatus ?? KycStatus.none')),
        reason:
            'A null flow status means the backend status is still unknown; '
            'falling back to none lets approved users restart KYC.',
      );
      expect(
        statusView,
        isNot(
          contains(
            'final status = state.verificationStatus ?? durableState.status',
          ),
        ),
        reason:
            'Status screens must use the centralized effective-status helper, '
            'not ad-hoc stale wizard fallbacks.',
      );
    });

    test('submitted/manual review screen reconciles after admin approval', () {
      final submittedView = File(
        'lib/features/kyc/views/submitted_view.dart',
      ).readAsStringSync();

      expect(submittedView, contains('ConsumerStatefulWidget'));
      expect(submittedView, contains('loadVerificationStatus()'));
      expect(submittedView, contains('kycStateMachineProvider.notifier'));
      expect(submittedView, contains('final durableState'));
      expect(submittedView, contains('flow.verificationStatus != null'));
      expect(submittedView, contains('if (durableState.hasLoaded)'));
      expect(submittedView, contains('return durableState.status;'));
      expect(
        submittedView.indexOf('if (durableState.hasLoaded)'),
        lessThan(submittedView.indexOf('if (flow.verificationStatus != null)')),
        reason:
            'Submitted/manual-review screens must let fresh API-backed KYC state beat stale local flow state.',
      );
      expect(submittedView, contains('kyc_status_approved_title'));
      expect(submittedView, contains('isVerified'));
      expect(submittedView, contains('_safeReturnTo'));
      expect(submittedView, contains('Continue deposit'));
      expect(submittedView, contains('_buildReconciliationState'));
    });

    test('home refresh reconciles KYC, limits, and notification state', () {
      final homeView = File(
        'lib/features/wallet/views/wallet_home_screen.dart',
      ).readAsStringSync();

      expect(homeView, contains('_refreshKycForHome()'));
      expect(homeView, contains('_refreshNotificationsForHome()'));
      expect(homeView, contains('_refreshLimitsForHome()'));
      expect(homeView, contains('updateProfile(kycStatus: kyc.status)'));
      expect(homeView, contains('refreshUnreadNotificationCountProvider'));
      expect(homeView, contains('fetchLimits()'));
      expect(
        homeView,
        contains('final kycState = ref.watch(kycStateMachineProvider)'),
        reason:
            'Home KYC calls to action must reflect durable/API KYC state, not only copied auth profile state.',
      );
      expect(
        homeView,
        contains('Unable to verify account permissions right now'),
        reason:
            'Unknown limits should block money-flow entry until permissions can be verified.',
      );
    });

    test('realtime polling refreshes both KYC state holders', () {
      final realtimeSource = File(
        'lib/services/realtime/realtime_service.dart',
      ).readAsStringSync();
      final pullAllBody = RegExp(
        r'void pullAll\(\) \{([\s\S]*?)\n  \}',
      ).firstMatch(realtimeSource)!.group(1)!;
      final refreshKycBody = RegExp(
        r'void _refreshKycState\(\) \{([\s\S]*?)\n  \}',
      ).firstMatch(realtimeSource)!.group(1)!;

      expect(pullAllBody, contains('_refreshKycState()'));
      expect(
        refreshKycBody,
        contains('kycProvider.notifier).loadVerificationStatus()'),
      );
      expect(
        refreshKycBody,
        contains('kycStateMachineProvider.notifier).fetch()'),
      );
    });

    test('settings uses effective API-backed KYC status', () {
      final settingsSource = File(
        'lib/features/settings/views/settings_screen.dart',
      ).readAsStringSync();
      final userStateSource = File(
        'lib/state/user_state_machine.dart',
      ).readAsStringSync();
      final kycStateSource = File(
        'lib/state/kyc_state_machine.dart',
      ).readAsStringSync();

      expect(settingsSource, contains('effectiveKycStatusProvider'));
      expect(
        settingsSource,
        isNot(contains('ref.watch(kycStatusProvider)')),
        reason:
            'Settings must not display stale profile KYC status after admin approval.',
      );
      expect(userStateSource, contains('effectiveKycStatusProvider'));
      expect(userStateSource, contains('kycState.hasLoaded'));
      expect(userStateSource, contains('return kycState.status;'));
      expect(userStateSource, contains('userStateMachineProvider).kycStatus'));
      expect(kycStateSource, contains('this.status = KycStatus.none'));
      expect(kycStateSource, contains('final bool hasLoaded'));
      expect(kycStateSource, contains('hasLoaded: true'));
    });

    test('submitted review routes cannot redirect back into evidence steps', () {
      final routeSource = File(
        'lib/router/routes/kyc_settings_routes.dart',
      ).readAsStringSync();

      expect(routeSource, contains('_isKycReviewOrApprovalStatus'));
      expect(routeSource, contains('_kycPrerequisiteRedirectForPath'));
      expect(routeSource, contains('flow.hasCompletedLiveness'));
      expect(routeSource, contains("return '/kyc/liveness-instructions';"));
      expect(
        routeSource,
        isNot(contains('_kycEvidenceRedirect(context, state)')),
      );
      expect(
        routeSource,
        contains('String? _kycSubmittedRedirect'),
        reason: 'The submitted route should keep its own redirect owner.',
      );
      expect(
        routeSource,
        contains('The submitted view owns backend reconciliation'),
        reason:
            'The submitted route should render its reconciliation screen instead of redirecting into the wizard.',
      );
      expect(
        routeSource,
        contains("if (currentPath == '/kyc/submitted')"),
        reason:
            'A verified KYC update must let /kyc/submitted preserve intent/returnTo so users can continue the deposit they started.',
      );
      expect(routeSource, contains('return null;'));
      expect(
        routeSource,
        contains('_kycFlowStatusRedirect(state.uri, flow.status)'),
      );
      expect(routeSource, contains('_kycSubmittedRouteFrom(state.uri)'));
      expect(routeSource, contains("'returnTo': returnTo"));
    });

    test('secondary KYC evidence routes use wizard prerequisites', () {
      final routeSource = File(
        'lib/router/routes/kyc_settings_routes.dart',
      ).readAsStringSync();

      for (final path in [
        '/kyc/address',
        '/kyc/video',
        '/kyc/additional-docs',
      ]) {
        final routeBlock = RegExp(
          "path: '$path',[\\s\\S]*?pageBuilder:",
        ).firstMatch(routeSource)?.group(0);

        expect(routeBlock, isNotNull, reason: path);
        expect(
          routeBlock,
          contains('redirect: _kycWizardRedirect'),
          reason: '$path must not bypass the KYC wizard state guard.',
        );
      }

      expect(routeSource, contains("case '/kyc/address':"));
      expect(routeSource, contains("case '/kyc/video':"));
      expect(routeSource, contains("case '/kyc/additional-docs':"));
      expect(routeSource, contains('if (flow.capturedDocuments.isEmpty)'));
      expect(routeSource, contains("return '/kyc/document-capture';"));
      expect(routeSource, contains('if (flow.selfiePath == null)'));
      expect(routeSource, contains("return '/kyc/selfie';"));
    });

    test('KYC liveness is mandatory before review and final submit', () {
      final providerSource = File(
        'lib/features/kyc/providers/kyc_provider.dart',
      ).readAsStringSync();
      final livenessSource = File(
        'lib/features/kyc/views/kyc_liveness_view.dart',
      ).readAsStringSync();
      final livenessInstructionsSource = File(
        'lib/features/kyc/views/kyc_liveness_instructions_view.dart',
      ).readAsStringSync();
      final routeSource = File(
        'lib/router/routes/kyc_settings_routes.dart',
      ).readAsStringSync();

      expect(providerSource, contains('livenessProofId'));
      expect(providerSource, contains('clearLivenessProof'));
      expect(providerSource, contains('hasIdentityEvidenceForLiveness'));
      expect(providerSource, contains('hasCompletedLiveness'));
      expect(providerSource, contains('canEnterReview'));
      expect(providerSource, contains('canSubmitForManualReview'));
      expect(providerSource, contains('canEnterReview && kycConsentAccepted'));
      expect(
        livenessSource,
        contains('setLivenessProof(result.stepUpProofId)'),
      );
      expect(
        livenessSource,
        contains('submitKyc(requireLivenessProof: false)'),
      );
      expect(livenessInstructionsSource, contains('setKycConsentAccepted'));
      expect(
        livenessInstructionsSource,
        contains('Identity verification consent'),
      );
      expect(routeSource, contains('!flow.hasCompletedLiveness'));
      expect(routeSource, contains("return '/kyc/liveness-instructions';"));
    });

    test('deposit intent survives KYC wizard submission', () {
      final providerSource = File(
        'lib/features/kyc/providers/kyc_provider.dart',
      ).readAsStringSync();
      final statusView = File(
        'lib/features/kyc/views/kyc_status_view.dart',
      ).readAsStringSync();
      final reviewView = File(
        'lib/features/kyc/views/review_view.dart',
      ).readAsStringSync();

      expect(providerSource, contains('returnIntent'));
      expect(providerSource, contains('returnTo'));
      expect(statusView, contains('startFlowForIntent'));
      expect(reviewView, contains('_submittedRoute'));
      expect(reviewView, contains("'/kyc/submitted?intent="));
    });

    test('transaction empty-state deposit CTA enters guarded deposit route', () {
      final transactionsView = File(
        'lib/features/transactions/views/transactions_view.dart',
      ).readAsStringSync();

      expect(transactionsView, contains("context.fsmGo('/deposit/amount')"));
      expect(
        transactionsView,
        isNot(contains("context.fsmGo('/deposit')")),
        reason:
            'The empty-state CTA should hit the canonical money route so the FSM can redirect unverified users to deposit KYC.',
      );
    });

    test('review submission does not fire a second incomplete KYC submit', () {
      final reviewSource = File(
        'lib/features/kyc/views/review_view.dart',
      ).readAsStringSync();

      expect(reviewSource, contains('submitKyc()'));
      expect(
        reviewSource,
        isNot(contains('submitDocumentForVerification')),
        reason:
            'The real KYC submit already uploads evidence and personal data. '
            'A second best-effort submit with only personalInfo creates false errors.',
      );
    });

    test('KYC review requires explicit backend consent before submit', () {
      final providerSource = File(
        'lib/features/kyc/providers/kyc_provider.dart',
      ).readAsStringSync();
      final reviewSource = File(
        'lib/features/kyc/views/review_view.dart',
      ).readAsStringSync();
      final serviceSource = File(
        'lib/services/kyc/kyc_service.dart',
      ).readAsStringSync();

      expect(providerSource, contains('kycConsentAccepted'));
      expect(providerSource, contains('grantRequiredKycConsents()'));
      expect(providerSource, contains('canEnterReview && kycConsentAccepted'));
      expect(reviewSource, contains('Identity verification consent'));
      expect(reviewSource, contains('setKycConsentAccepted'));
      expect(serviceSource, contains("'/consent/grant'"));
      for (final consentType in [
        'kyc_data_processing',
        'kyc_data_sharing',
        'privacy_policy',
        'terms_of_service',
        'aml_screening',
      ]) {
        expect(serviceSource, contains("'$consentType'"));
      }
    });
  });
}
