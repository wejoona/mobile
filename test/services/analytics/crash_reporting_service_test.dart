import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/services/analytics/crash_reporting_service.dart';

void main() {
  group('CrashReportingService', () {
    late CrashReportingService crashReportingService;

    setUp(() {
      crashReportingService = CrashReportingService();
    });

    test('should initialize without crashing', () {
      expect(crashReportingService, isNotNull);
    });

    test('should handle initialize gracefully without Firebase', () async {
      await expectLater(
        crashReportingService.initialize(),
        completes,
      );
    });

    test('should handle recordError gracefully without Firebase', () async {
      final exception = Exception('Test error');
      final stackTrace = StackTrace.current;

      await expectLater(
        crashReportingService.recordError(
          exception,
          stackTrace,
          reason: 'Test error recording',
          fatal: false,
        ),
        completes,
      );
    });

    test('should handle recordApiError gracefully without Firebase', () async {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test/endpoint'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test/endpoint'),
          statusCode: 400,
        ),
      );

      await expectLater(
        crashReportingService.recordApiError(
          dioException,
          endpoint: '/test/endpoint',
          userId: 'test_user',
        ),
        completes,
      );
    });

    test('should handle recordAuthError gracefully without Firebase', () async {
      final exception = Exception('Auth failed');

      await expectLater(
        crashReportingService.recordAuthError(
          exception,
          reason: 'Invalid credentials',
          userId: 'test_user',
        ),
        completes,
      );
    });

    test('should handle recordPaymentError gracefully without Firebase', () async {
      final exception = Exception('Payment failed');

      await expectLater(
        crashReportingService.recordPaymentError(
          exception,
          paymentType: 'deposit',
          amount: '1000.0',
          currency: 'XOF',
          transactionId: 'txn_123',
          userId: 'test_user',
        ),
        completes,
      );
    });

    test('should handle recordKycError gracefully without Firebase', () async {
      final exception = Exception('KYC verification failed');

      await expectLater(
        crashReportingService.recordKycError(
          exception,
          tier: 'tier_1',
          step: 'document_upload',
          userId: 'test_user',
        ),
        completes,
      );
    });

    test('should handle log gracefully without Firebase', () async {
      await expectLater(
        crashReportingService.log('Test log message'),
        completes,
      );
    });

    test('should handle setUserId gracefully without Firebase', () async {
      await expectLater(
        crashReportingService.setUserId('user_123'),
        completes,
      );
    });

    test('should handle setCustomKey gracefully without Firebase', () async {
      await expectLater(
        crashReportingService.setCustomKey('test_key', 'test_value'),
        completes,
      );
    });

    test('should handle setCustomKey with different types', () async {
      // String
      await expectLater(
        crashReportingService.setCustomKey('string_key', 'value'),
        completes,
      );

      // Int
      await expectLater(
        crashReportingService.setCustomKey('int_key', 123),
        completes,
      );

      // Double
      await expectLater(
        crashReportingService.setCustomKey('double_key', 123.45),
        completes,
      );

      // Bool
      await expectLater(
        crashReportingService.setCustomKey('bool_key', true),
        completes,
      );
    });

    test('should handle clearUserData gracefully without Firebase', () async {
      await expectLater(
        crashReportingService.clearUserData(),
        completes,
      );
    });

    test('should report isEnabled status', () {
      expect(crashReportingService.isEnabled, isA<bool>());
    });
  });
}
