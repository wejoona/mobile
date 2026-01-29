import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usdc_wallet/services/app_review/app_review_service.dart';
import 'package:usdc_wallet/services/analytics/analytics_service.dart';

void main() {
  group('AppReviewService', () {
    late AppReviewService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      service = AppReviewService(
        analytics: AnalyticsService(),
      );
    });

    test('should initialize with default state', () async {
      await service.initialize();

      expect(service.currentState, isNotNull);
      expect(service.currentState?.successfulTransactions, 0);
      expect(service.currentState?.hasReviewed, false);
      expect(service.currentState?.firstUsageDate, isNotNull);
    });

    test('should track successful transactions', () async {
      await service.initialize();

      await service.trackSuccessfulTransaction();

      expect(service.currentState?.successfulTransactions, 1);
    });

    test('should increment transaction count on multiple successes', () async {
      await service.initialize();

      await service.trackSuccessfulTransaction();
      await service.trackSuccessfulTransaction();
      await service.trackSuccessfulTransaction();

      expect(service.currentState?.successfulTransactions, 3);
    });

    test('should mark as reviewed', () async {
      await service.initialize();

      await service.markAsReviewed();

      expect(service.currentState?.hasReviewed, true);
    });

    test('should reset state', () async {
      await service.initialize();
      await service.trackSuccessfulTransaction();
      await service.trackSuccessfulTransaction();

      await service.reset();

      expect(service.currentState?.successfulTransactions, 0);
      expect(service.currentState?.hasReviewed, false);
    });
  });

  group('AppReviewState', () {
    test('should serialize to and from JSON', () {
      final state = AppReviewState(
        successfulTransactions: 5,
        firstUsageDate: DateTime(2024, 1, 1),
        lastReviewPromptDate: DateTime(2024, 1, 15),
        hasReviewed: false,
      );

      final json = state.toJson();
      final restored = AppReviewState.fromJson(json);

      expect(restored.successfulTransactions, state.successfulTransactions);
      expect(restored.hasReviewed, state.hasReviewed);
      expect(restored.firstUsageDate?.year, state.firstUsageDate?.year);
      expect(restored.firstUsageDate?.month, state.firstUsageDate?.month);
      expect(restored.firstUsageDate?.day, state.firstUsageDate?.day);
    });

    test('should handle copyWith', () {
      const state = AppReviewState(
        successfulTransactions: 3,
        hasReviewed: false,
      );

      final updated = state.copyWith(
        successfulTransactions: 5,
        hasReviewed: true,
      );

      expect(updated.successfulTransactions, 5);
      expect(updated.hasReviewed, true);
    });
  });
}
