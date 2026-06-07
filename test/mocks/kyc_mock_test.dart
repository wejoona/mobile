import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/mocks/services/kyc/kyc_mock.dart';

void main() {
  group('KycMockState', () {
    test('initializes from MOCK_KYC_STATUS dart define', () {
      expect(KycMockState.kycStatus, KycMockState.initialStatus);
    });

    test('reset returns to configured initial status', () {
      KycMockState.setStatus('rejected');

      KycMockState.reset();

      expect(KycMockState.kycStatus, KycMockState.initialStatus);
    });
  });
}
