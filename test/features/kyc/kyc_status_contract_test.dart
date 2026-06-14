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
  });
}
