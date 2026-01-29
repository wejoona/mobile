import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/services/analytics/analytics_service.dart';

void main() {
  group('AnalyticsService', () {
    late AnalyticsService analyticsService;

    setUp(() {
      analyticsService = AnalyticsService();
    });

    test('should initialize without crashing', () {
      expect(analyticsService, isNotNull);
    });

    test('should handle logLoginSuccess gracefully without Firebase', () async {
      // Should not throw even if Firebase is not configured
      await expectLater(
        analyticsService.logLoginSuccess(
          method: 'phone_otp',
          userId: 'test_user',
        ),
        completes,
      );
    });

    test('should handle logLoginFailed gracefully without Firebase', () async {
      await expectLater(
        analyticsService.logLoginFailed(
          method: 'phone_otp',
          reason: 'Invalid OTP',
        ),
        completes,
      );
    });

    test('should handle logTransferInitiated gracefully without Firebase', () async {
      await expectLater(
        analyticsService.logTransferInitiated(
          transferType: 'p2p_phone',
          amount: 1000.0,
          currency: 'XOF',
        ),
        completes,
      );
    });

    test('should handle logTransferCompleted gracefully without Firebase', () async {
      await expectLater(
        analyticsService.logTransferCompleted(
          transferType: 'p2p_phone',
          amount: 1000.0,
          currency: 'XOF',
          transactionId: 'txn_123',
        ),
        completes,
      );
    });

    test('should handle logTransferFailed gracefully without Firebase', () async {
      await expectLater(
        analyticsService.logTransferFailed(
          transferType: 'p2p_phone',
          amount: 1000.0,
          currency: 'XOF',
          reason: 'Insufficient balance',
        ),
        completes,
      );
    });

    test('should handle logKycStarted gracefully without Firebase', () async {
      await expectLater(
        analyticsService.logKycStarted(tier: 'tier_1'),
        completes,
      );
    });

    test('should handle logKycCompleted gracefully without Firebase', () async {
      await expectLater(
        analyticsService.logKycCompleted(
          tier: 'tier_1',
          status: 'approved',
        ),
        completes,
      );
    });

    test('should handle logDepositInitiated gracefully without Firebase', () async {
      await expectLater(
        analyticsService.logDepositInitiated(
          method: 'orange_money',
          amount: 5000.0,
          currency: 'XOF',
        ),
        completes,
      );
    });

    test('should handle logDepositCompleted gracefully without Firebase', () async {
      await expectLater(
        analyticsService.logDepositCompleted(
          method: 'orange_money',
          amount: 5000.0,
          currency: 'XOF',
          transactionId: 'dep_123',
        ),
        completes,
      );
    });

    test('should handle logBillPaymentCompleted gracefully without Firebase', () async {
      await expectLater(
        analyticsService.logBillPaymentCompleted(
          billerName: 'CIE',
          category: 'electricity',
          amount: 2000.0,
          currency: 'XOF',
          transactionId: 'bill_123',
        ),
        completes,
      );
    });

    test('should handle logScreenView gracefully without Firebase', () async {
      await expectLater(
        analyticsService.logScreenView(
          screenName: 'home_screen',
          screenClass: 'HomeView',
        ),
        completes,
      );
    });

    test('should handle setUserId gracefully without Firebase', () async {
      await expectLater(
        analyticsService.setUserId('user_123'),
        completes,
      );
    });

    test('should handle setUserProperty gracefully without Firebase', () async {
      await expectLater(
        analyticsService.setUserProperty(
          name: 'kyc_tier',
          value: 'tier_1',
        ),
        completes,
      );
    });

    test('should handle reset gracefully without Firebase', () async {
      await expectLater(
        analyticsService.reset(),
        completes,
      );
    });
  });
}
