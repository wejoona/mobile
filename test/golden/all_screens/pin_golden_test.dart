// Golden tests for PIN feature screens
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/settings/views/change_pin_view.dart';
import 'package:usdc_wallet/features/pin/views/enter_pin_view.dart';
import 'package:usdc_wallet/features/pin/views/pin_locked_view.dart';
import 'package:usdc_wallet/features/pin/views/reset_pin_view.dart';

import '../helpers/golden_test_helper.dart';

void main() {
  if (skipVisualSuiteIfDisabled()) return;

  setUpAll(() async {
    await GoldenTestUtils.init();
  });

  goldenGroup('ChangePinView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(isDarkMode: false, child: ChangePinView()),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/pin/change_pin/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(isDarkMode: true, child: ChangePinView()),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/pin/change_pin/default_dark.png'),
      );
    });
  });

  goldenGroup('EnterPinView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: false,
          child: EnterPinView(title: 'Enter PIN'),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/pin/enter_pin/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: true,
          child: EnterPinView(title: 'Enter PIN'),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/pin/enter_pin/default_dark.png'),
      );
    });
  });

  goldenGroup('PinLockedView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(isDarkMode: false, child: PinLockedView()),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/pin/pin_locked/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(isDarkMode: true, child: PinLockedView()),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/pin/pin_locked/default_dark.png'),
      );
    });
  });

  goldenGroup('ResetPinView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(isDarkMode: false, child: ResetPinView()),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/pin/reset_pin/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(isDarkMode: true, child: ResetPinView()),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/pin/reset_pin/default_dark.png'),
      );
    });
  });
}
