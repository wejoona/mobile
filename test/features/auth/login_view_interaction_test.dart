import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/design/components/primitives/app_button.dart';
import 'package:usdc_wallet/features/auth/views/login_view.dart';

import '../../golden/helpers/golden_test_helper.dart';

void main() {
  setUpAll(() async {
    await GoldenTestUtils.init();
  });

  testWidgets('phone input row focuses and accepts typed login phone', (
    tester,
  ) async {
    await _pumpLoginView(tester);

    expect(find.text('By continuing, you agree to our'), findsNothing);

    final phoneFieldFinder = find.byType(TextField).first;
    final phoneField = tester.widget<TextField>(phoneFieldFinder);

    expect(phoneField.focusNode?.hasFocus, isFalse);

    await tester.tap(find.text('+225'));
    await tester.pump();

    expect(phoneField.focusNode?.hasFocus, isTrue);

    await tester.enterText(phoneFieldFinder, '0748805663');
    await tester.pumpAndSettle();

    expect(
      tester.widget<TextField>(phoneFieldFinder).controller?.text,
      '0748805663',
    );
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(
      tester.widget<AppButton>(find.byType(AppButton).first).onPressed,
      isNotNull,
    );
  });

  testWidgets('terms acceptance stays out of returning-user login', (
    tester,
  ) async {
    await _pumpLoginView(tester);

    expect(find.text('By continuing, you agree to our'), findsNothing);
    expect(find.text('Terms of Service'), findsNothing);
    expect(find.text('Privacy Policy'), findsNothing);

    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsNothing);
  });
}

Future<void> _pumpLoginView(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(944, 2048));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(GoldenTestWrapper(child: const LoginView()));
  await tester.pumpAndSettle();
}
