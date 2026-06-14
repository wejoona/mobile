import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/kyc/models/kyc_status.dart';

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
  });
}
