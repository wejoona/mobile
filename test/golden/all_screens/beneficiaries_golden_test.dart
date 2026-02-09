// Golden tests for Beneficiaries feature screens
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/beneficiaries/views/add_beneficiary_screen.dart';
import 'package:usdc_wallet/features/beneficiaries/views/beneficiaries_screen.dart';
import 'package:usdc_wallet/features/beneficiaries/views/beneficiary_detail_view.dart';

import '../helpers/golden_test_helper.dart';

void main() {
  setUpAll(() async {
    await GoldenTestUtils.init();
  });

  group('BeneficiariesScreen Golden Tests', () {
    testWidgets('light mode - empty', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(
          isDarkMode: false,
          child: BeneficiariesScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/beneficiaries/list/empty_light.png'),
      );
    });

    testWidgets('dark mode - empty', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(
          isDarkMode: true,
          child: BeneficiariesScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/beneficiaries/list/empty_dark.png'),
      );
    });
  });

  group('AddBeneficiaryScreen Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(
          isDarkMode: false,
          child: AddBeneficiaryScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/beneficiaries/add/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(
          isDarkMode: true,
          child: AddBeneficiaryScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/beneficiaries/add/default_dark.png'),
      );
    });
  });

  group('BeneficiaryDetailView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(
          isDarkMode: false,
          child: BeneficiaryDetailView(beneficiaryId: 'ben_001'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/beneficiaries/detail/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(
          isDarkMode: true,
          child: BeneficiaryDetailView(beneficiaryId: 'ben_001'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/beneficiaries/detail/default_dark.png'),
      );
    });
  });
}
