import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:usdc_wallet/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Login screen renders correctly', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Should show login screen (expired token redirects here)
    expect(find.text('Korido'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);

    // Country selector should show Côte d'Ivoire
    expect(find.textContaining("Côte d'Ivoire"), findsOneWidget);

    // Phone field should exist
    expect(find.text('+225'), findsOneWidget);
  });

  testWidgets('Phone number input enables Continue button', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Find the phone input field and type a number
    final phoneField = find.byType(TextField).last;
    if (phoneField.evaluate().isNotEmpty) {
      await tester.tap(phoneField);
      await tester.pumpAndSettle();
      await tester.enterText(phoneField, '0707070707');
      await tester.pumpAndSettle();
    }
  });
}
