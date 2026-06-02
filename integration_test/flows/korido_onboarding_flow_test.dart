import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../helpers/korido_flow_driver.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(KoridoFlowDriver.resetMocksAndStorage);

  testWidgets('completes onboarding then exercises home money paths', (
    tester,
  ) async {
    final flow = KoridoFlowDriver(tester);

    await flow.launchApp();
    await flow.completeOnboarding();
    await flow.exerciseDepositFromHome();
    await flow.returnHomeFromDeposit();
    await flow.exerciseTransferFromHome();
  });
}
