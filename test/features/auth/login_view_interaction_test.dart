import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/design/components/primitives/app_button.dart';
import 'package:usdc_wallet/features/auth/views/login_view.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

import '../../golden/helpers/golden_test_helper.dart';
import '../../helpers/test_utils.dart';

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

  testWidgets(
    'phone input keeps country code separate when full number pasted',
    (tester) async {
      await _pumpLoginView(tester);

      final phoneFieldFinder = find.byType(TextField).first;

      await tester.enterText(phoneFieldFinder, '+225+2250748805663');
      await tester.pumpAndSettle();

      expect(find.text('+225'), findsOneWidget);
      expect(
        tester.widget<TextField>(phoneFieldFinder).controller?.text,
        '0748805663',
      );
      expect(find.textContaining('+225+225'), findsNothing);
    },
  );

  testWidgets('remembered phone hydrates as local digits in the login field', (
    tester,
  ) async {
    final storage = MockSecureStorage();
    await storage.write(
      key: StorageKeys.rememberedPhone,
      value: '+225|+2250748805663',
    );

    await _pumpLoginView(
      tester,
      overrides: [secureStorageProvider.overrideWithValue(storage)],
    );

    final phoneFieldFinder = find.byType(TextField).first;
    expect(
      tester.widget<TextField>(phoneFieldFinder).controller?.text,
      '0748805663',
    );
    expect(find.textContaining('+225+225'), findsNothing);
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
    expect(source, contains("context.fsmGo('/login/otp')"));
    expect(
      source,
      isNot(contains("context.fsmGo('/otp')")),
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
      contains("context.fsmGo('/signup')"),
      reason:
          'Sign up from login must open the explicit signup flow, not the intro carousel',
    );
    expect(
      source,
      isNot(contains("context.fsmGo('/onboarding/phone')")),
      reason:
          'The signup flow should not use onboarding names for account creation',
    );
    expect(
      source,
      isNot(contains("context.fsmGo('/onboarding')")),
      reason:
          'The intro carousel must not be wired as the login sign-up target',
    );
  });

  test('login OTP shows a visible verification cue before PIN handoff', () {
    final source = File(
      'lib/features/auth/views/login_otp_view.dart',
    ).readAsStringSync();

    expect(source, contains('OtpVerificationOverlay'));
    expect(source, contains('visible: isBusy'));
    expect(source, contains('_isSubmittingOtp = true'));
    expect(source, contains("en: 'Code accepted. Securing your session...'"));
    expect(source, contains('_holdOtpCue(submittedAt)'));
    expect(source, contains('Duration(milliseconds: 1600)'));
    expect(source, contains("context.fsmGo('/login/pin')"));
  });
}

Future<void> _pumpLoginView(
  WidgetTester tester, {
  List<dynamic> overrides = const [],
}) async {
  await tester.binding.setSurfaceSize(const Size(944, 2048));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    GoldenTestWrapper(overrides: overrides, child: const LoginView()),
  );
  await tester.pumpAndSettle();
}
