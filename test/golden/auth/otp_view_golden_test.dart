import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/auth/views/otp_view.dart';

import '../helpers/golden_test_helper.dart';

/// Golden tests for OTP View
///
/// Status: ACTIVE (MVP Critical)
/// File: lib/features/auth/views/otp_view.dart
/// Route: /otp
///
/// Test Matrix:
/// - Light/Dark mode
/// - Initial empty state
/// - Partially entered OTP
/// - Full OTP entered
/// - Resend available state
/// - Resend countdown state
/// - Error state (invalid OTP)
/// - Loading state
///
/// To update goldens:
/// flutter test --update-goldens test/golden/auth/otp_view_golden_test.dart
void main() {
  setUpAll(() async {
    await GoldenTestUtils.init();
  });

  group('OTPView Golden Tests', () {
    group('Light Mode', () {
      testWidgets('initial empty state', (tester) async {
        await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
        
        await tester.pumpWidget(
          GoldenTestWrapper(
            isDarkMode: false,
            child: OtpView(),
          ),
        );
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/auth/otp_view/initial_light.png'),
        );
      });

      testWidgets('with countdown timer showing', (tester) async {
        await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
        
        await tester.pumpWidget(
          GoldenTestWrapper(
            isDarkMode: false,
            child: OtpView(),
          ),
        );
        // Let countdown start but capture immediately to show timer
        await tester.pump(const Duration(seconds: 1));

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/auth/otp_view/countdown_light.png'),
        );
      });
    });

    group('Dark Mode', () {
      testWidgets('initial empty state', (tester) async {
        await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
        
        await tester.pumpWidget(
          GoldenTestWrapper(
            isDarkMode: true,
            child: OtpView(),
          ),
        );
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/auth/otp_view/initial_dark.png'),
        );
      });
    });
  });
}
