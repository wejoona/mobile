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
        contains('kycStateMachineProvider.notifier'),
        reason:
            'KYC status refresh must update the durable FSM source used by redirects.',
      );
      expect(
        loadStatusBody,
        contains('updateFromAuthResponse(data.status.toApiString())'),
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
      expect(
        submittedView,
        contains('durableStatus == KycStatus.manualReview'),
      );
      expect(submittedView, contains('kyc_status_manualReview_title'));
      expect(submittedView, contains('kyc_info_manualReview_description'));
    });

    test('KYC status screen waits for API-backed status before restart', () {
      final statusView = File(
        'lib/features/kyc/views/kyc_status_view.dart',
      ).readAsStringSync();

      expect(statusView, contains('kycStateMachineProvider'));
      expect(statusView, contains('hasAuthoritativeStatus'));
      expect(statusView, contains('await _refreshStatus();'));
      expect(
        statusView,
        isNot(contains('state.verificationStatus ?? KycStatus.none')),
        reason:
            'A null flow status means the backend status is still unknown; '
            'falling back to none lets approved users restart KYC.',
      );
    });

    test('submitted/manual review screen reconciles after admin approval', () {
      final submittedView = File(
        'lib/features/kyc/views/submitted_view.dart',
      ).readAsStringSync();

      expect(submittedView, contains('ConsumerStatefulWidget'));
      expect(submittedView, contains('loadVerificationStatus()'));
      expect(submittedView, contains('kyc_status_approved_title'));
      expect(submittedView, contains('isVerified'));
    });

    test('home refresh reconciles KYC and notification state', () {
      final homeView = File(
        'lib/features/wallet/views/wallet_home_screen.dart',
      ).readAsStringSync();

      expect(homeView, contains('_refreshKycForHome()'));
      expect(homeView, contains('_refreshNotificationsForHome()'));
      expect(homeView, contains('updateProfile(kycStatus: kyc.status)'));
      expect(homeView, contains('refreshUnreadNotificationCountProvider'));
    });

    test('submitted review routes cannot redirect back into evidence steps', () {
      final routeSource = File(
        'lib/router/routes/kyc_settings_routes.dart',
      ).readAsStringSync();

      expect(routeSource, contains('durableStatus.isSubmitted'));
      expect(
        routeSource.indexOf('durableStatus.isSubmitted'),
        lessThan(routeSource.indexOf('_kycEvidenceRedirect(context, state)')),
        reason:
            'A backend submitted/manual-review state is terminal for the user; '
            'the submitted route must not ask for personal info, documents, or selfie again.',
      );
      expect(routeSource, contains("return '/kyc/submitted';"));
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
  });
}
