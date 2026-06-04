import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../helpers/korido_flow_driver.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(KoridoFlowDriver.resetMocksAndStorage);

  group('PIN security flows', () {
    testWidgets('correct PIN authorizes a transfer', (tester) async {
      final driver = KoridoFlowDriver(tester);

      await driver.launchApp();
      await driver.completeOnboarding();
      await driver.exerciseTransferFromHome();
    });
  });
}
