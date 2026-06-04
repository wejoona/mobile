import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../helpers/korido_flow_driver.dart';
import '../helpers/test_helpers.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Bill Pay Flow Tests', () {
    setUp(KoridoFlowDriver.resetMocksAndStorage);

    testWidgets('Browse bill categories and select provider', (tester) async {
      final flow = KoridoFlowDriver(tester);

      try {
        await flow.launchApp();
        await flow.completeOnboarding();
        await flow.goToRoute('/bill-payments');

        await flow.pumpUntil(
          () => flow.hasAnyText(['Pay Bills', 'Payer les factures']),
          reason: 'bill pay screen',
        );

        await flow.pumpUntil(
          () => flow.hasAnyText(['CIE', 'SODECI', 'Orange']),
          reason: 'bill pay providers',
        );
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'bill_pay_flow_error');
        rethrow;
      }
    });

    testWidgets('Complete bill payment flow', (tester) async {
      final flow = KoridoFlowDriver(tester);

      try {
        await flow.launchApp();
        await flow.completeOnboarding();
        await flow.goToRoute('/bill-payments');

        await flow.pumpUntil(
          () => flow.hasAnyText(['CIE', 'SODECI', 'Orange']),
          reason: 'bill pay providers',
        );

        final provider = find.textContaining(RegExp(r'CIE|SODECI|Orange'));
        expect(provider, findsAtLeast(1));
        await tester.tap(provider.first);
        await tester.pump(const Duration(milliseconds: 700));

        await flow.pumpUntil(
          () =>
              flow.hasAnyText(['Verify Account', 'Vérifier le compte']) ||
              flow.hasAnyText(['Amount', 'Montant']),
          reason: 'bill pay form',
        );
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'bill_pay_complete_error');
        rethrow;
      }
    });
  });
}
