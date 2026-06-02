import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../helpers/korido_flow_driver.dart';
import '../helpers/test_helpers.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(KoridoFlowDriver.resetMocksAndStorage);

  testWidgets('shows wallet balance and supports refresh after onboarding', (
    tester,
  ) async {
    final flow = KoridoFlowDriver(tester);

    try {
      await flow.launchApp();
      await flow.completeOnboarding();

      expect(flow.hasAnyText(['Total Balance', 'Solde total']), isTrue);
      expect(flow.hasAnyText(['USDC']), isTrue);

      await flow.pullToRefreshHome();
    } catch (_) {
      await TestHelpers.takeScreenshot(binding, 'wallet_flow_error');
      rethrow;
    }
  });
}
