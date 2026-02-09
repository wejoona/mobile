// Golden tests for Business feature screens
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/business/views/business_profile_view.dart';
import 'package:usdc_wallet/features/business/views/business_setup_view.dart';

import '../helpers/golden_test_helper.dart';

void main() {
  setUpAll(() async {
    await GoldenTestUtils.init();
  });

  group('BusinessSetupView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: false,
          child: BusinessSetupView(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/business/setup/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: true,
          child: BusinessSetupView(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/business/setup/default_dark.png'),
      );
    });
  });

  group('BusinessProfileView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: false,
          child: BusinessProfileView(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/business/profile/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: true,
          child: BusinessProfileView(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/business/profile/default_dark.png'),
      );
    });
  });
}
