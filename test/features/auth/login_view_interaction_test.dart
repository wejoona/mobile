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
    await tester.pumpWidget(
      GoldenTestWrapper(isDarkMode: false, child: const LoginView()),
    );
    await tester.pumpAndSettle();

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
}
