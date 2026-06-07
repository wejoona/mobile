import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/send/models/transfer_request.dart';
import 'package:usdc_wallet/features/send/providers/send_provider.dart';
import 'package:usdc_wallet/features/send/views/amount_screen.dart';

import '../helpers/golden_test_helper.dart';

/// Golden tests for Send - Amount Screen
///
/// Status: ACTIVE (MVP Critical)
/// File: lib/features/send/views/amount_screen.dart
/// Route: /send/amount
///
/// Test Matrix:
/// - Light/Dark mode
/// - Initial state
///
/// To update goldens:
/// flutter test --update-goldens test/golden/send/amount_screen_golden_test.dart
void main() {
  if (skipVisualSuiteIfDisabled()) return;

  setUpAll(() async {
    await GoldenTestUtils.init();
  });

  goldenGroup('AmountScreen Golden Tests', () {
    goldenGroup('Light Mode', () {
      testWidgets('initial state', (tester) async {
        await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);

        await tester.pumpWidget(
          GoldenTestWrapper(
            isDarkMode: false,
            overrides: [
              sendMoneyProvider.overrideWith(_GoldenSendNotifier.new),
            ],
            child: AmountScreen(),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/send/amount_screen/initial_light.png'),
        );
      });
    });

    goldenGroup('Dark Mode', () {
      testWidgets('initial state', (tester) async {
        await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);

        await tester.pumpWidget(
          GoldenTestWrapper(
            isDarkMode: true,
            overrides: [
              sendMoneyProvider.overrideWith(_GoldenSendNotifier.new),
            ],
            child: AmountScreen(),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/send/amount_screen/initial_dark.png'),
        );
      });
    });
  });
}

class _GoldenSendNotifier extends SendMoneyNotifier {
  @override
  SendMoneyState build() => const SendMoneyState(
    recipient: RecipientInfo(
      phoneNumber: '+2250711223344',
      name: 'Awa Kone',
      isKoridoUser: true,
    ),
    availableBalance: 1250,
  );
}
