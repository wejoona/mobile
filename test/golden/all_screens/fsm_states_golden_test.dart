// Golden tests for FSM State screens (Auth states, error states, etc.)
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/fsm_states/views/auth_locked_view.dart';
import 'package:usdc_wallet/features/fsm_states/views/auth_suspended_view.dart';
import 'package:usdc_wallet/features/fsm_states/views/biometric_prompt_view.dart';
import 'package:usdc_wallet/features/fsm_states/views/device_verification_view.dart';
import 'package:usdc_wallet/features/fsm_states/views/kyc_expired_view.dart';
import 'package:usdc_wallet/features/fsm_states/views/loading_view.dart';
import 'package:usdc_wallet/features/fsm_states/views/otp_expired_view.dart';
import 'package:usdc_wallet/features/fsm_states/views/session_conflict_view.dart';
import 'package:usdc_wallet/features/fsm_states/views/session_locked_view.dart';
import 'package:usdc_wallet/features/fsm_states/views/wallet_frozen_view.dart';
import 'package:usdc_wallet/features/fsm_states/views/wallet_under_review_view.dart';

import '../helpers/golden_test_helper.dart';

void main() {
  if (skipVisualSuiteIfDisabled()) return;

  setUpAll(() async {
    await GoldenTestUtils.init();
  });

  goldenGroup('AuthLockedView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(isDarkMode: false, child: AuthLockedView()),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/fsm_states/auth_locked/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(isDarkMode: true, child: AuthLockedView()),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/fsm_states/auth_locked/default_dark.png'),
      );
    });
  });

  goldenGroup('AuthSuspendedView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(isDarkMode: false, child: AuthSuspendedView()),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          'goldens/fsm_states/auth_suspended/default_light.png',
        ),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(isDarkMode: true, child: AuthSuspendedView()),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/fsm_states/auth_suspended/default_dark.png'),
      );
    });
  });

  goldenGroup('BiometricPromptView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(isDarkMode: false, child: BiometricPromptView()),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          'goldens/fsm_states/biometric_prompt/default_light.png',
        ),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(isDarkMode: true, child: BiometricPromptView()),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          'goldens/fsm_states/biometric_prompt/default_dark.png',
        ),
      );
    });
  });

  goldenGroup('DeviceVerificationView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(isDarkMode: false, child: DeviceVerificationView()),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          'goldens/fsm_states/device_verification/default_light.png',
        ),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(isDarkMode: true, child: DeviceVerificationView()),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          'goldens/fsm_states/device_verification/default_dark.png',
        ),
      );
    });
  });

  goldenGroup('KycExpiredView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(isDarkMode: false, child: KycExpiredView()),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/fsm_states/kyc_expired/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(isDarkMode: true, child: KycExpiredView()),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/fsm_states/kyc_expired/default_dark.png'),
      );
    });
  });

  goldenGroup('LoadingView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(isDarkMode: false, child: LoadingView()),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/fsm_states/loading/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(isDarkMode: true, child: LoadingView()),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/fsm_states/loading/default_dark.png'),
      );
    });
  });

  goldenGroup('OtpExpiredView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(isDarkMode: false, child: OtpExpiredView()),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/fsm_states/otp_expired/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(isDarkMode: true, child: OtpExpiredView()),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/fsm_states/otp_expired/default_dark.png'),
      );
    });
  });

  goldenGroup('SessionConflictView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(isDarkMode: false, child: SessionConflictView()),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          'goldens/fsm_states/session_conflict/default_light.png',
        ),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(isDarkMode: true, child: SessionConflictView()),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          'goldens/fsm_states/session_conflict/default_dark.png',
        ),
      );
    });
  });

  goldenGroup('SessionLockedView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(isDarkMode: false, child: SessionLockedView()),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          'goldens/fsm_states/session_locked/default_light.png',
        ),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(isDarkMode: true, child: SessionLockedView()),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/fsm_states/session_locked/default_dark.png'),
      );
    });
  });

  goldenGroup('WalletFrozenView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(isDarkMode: false, child: WalletFrozenView()),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/fsm_states/wallet_frozen/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(isDarkMode: true, child: WalletFrozenView()),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/fsm_states/wallet_frozen/default_dark.png'),
      );
    });
  });

  goldenGroup('WalletUnderReviewView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(isDarkMode: false, child: WalletUnderReviewView()),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          'goldens/fsm_states/wallet_under_review/default_light.png',
        ),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(isDarkMode: true, child: WalletUnderReviewView()),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          'goldens/fsm_states/wallet_under_review/default_dark.png',
        ),
      );
    });
  });
}
