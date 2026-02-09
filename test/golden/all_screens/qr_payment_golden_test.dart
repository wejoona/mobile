// Golden tests for QR Payment feature
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/qr_payment/views/receive_qr_screen.dart';
import 'package:usdc_wallet/features/qr_payment/views/scan_qr_screen.dart';

import '../helpers/golden_test_helper.dart';

void main() {
  setUpAll(() async {
    await GoldenTestUtils.init();
  });

  group('ReceiveQrScreen Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: false,
          child: ReceiveQrScreen(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/qr_payment/receive_qr/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: true,
          child: ReceiveQrScreen(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/qr_payment/receive_qr/default_dark.png'),
      );
    });
  });

  group('ScanQrScreen Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: false,
          child: ScanQrScreen(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/qr_payment/scan_qr/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: true,
          child: ScanQrScreen(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/qr_payment/scan_qr/default_dark.png'),
      );
    });
  });
}
