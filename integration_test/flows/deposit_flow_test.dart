import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../helpers/korido_flow_driver.dart';
import '../helpers/test_helpers.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(KoridoFlowDriver.resetMocksAndStorage);

  testWidgets('completes Orange Money deposit from home', (tester) async {
    final flow = KoridoFlowDriver(tester);

    try {
      await flow.launchApp();
      await flow.completeOnboarding();
      await flow.exerciseDepositFromHome();
      await flow.returnHomeFromDeposit();
    } catch (_) {
      await TestHelpers.takeScreenshot(binding, 'deposit_flow_error');
      rethrow;
    }
  });
}
