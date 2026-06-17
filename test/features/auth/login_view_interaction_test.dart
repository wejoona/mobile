import 'dart:io';

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

  test('returning-user login uses the PIN-aware login OTP flow', () {
    final source = File(
      'lib/features/auth/views/login_view.dart',
    ).readAsStringSync();

    expect(source, contains('loginProvider'));
    expect(source, contains("context.go('/login/otp')"));
    expect(
      source,
      isNot(contains("context.go('/otp')")),
      reason:
          'returning-user login must use the login OTP/PIN handoff, not the legacy OTP route',
    );
    expect(
      source,
      isNot(contains('acceptedTerms')),
      reason: 'terms acceptance belongs to register/onboarding, never login',
    );
    expect(
      source,
      contains("context.go('/signup')"),
      reason:
          'Sign up from login must open the explicit signup flow, not the intro carousel',
    );
    expect(
      source,
      isNot(contains("context.go('/onboarding/phone')")),
      reason:
          'The signup flow should not use onboarding names for account creation',
    );
    expect(
      source,
      isNot(contains("context.go('/onboarding')")),
      reason:
          'The intro carousel must not be wired as the login sign-up target',
    );
  });
}

Future<void> _pumpLoginView(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(944, 2048));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(GoldenTestWrapper(child: const LoginView()));
  await tester.pumpAndSettle();
}
