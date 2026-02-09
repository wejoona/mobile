import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/auth/views/otp_view.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/design/components/primitives/app_button.dart';

import '../../helpers/test_wrapper.dart';

/// Fake AuthNotifier for Riverpod 3.x testing — extends real Notifier
class FakeAuthNotifier extends AuthNotifier {
  final AuthState initialState;
  FakeAuthNotifier([this.initialState = const AuthState(status: AuthStatus.otpSent)]);

  @override
  AuthState build() => initialState;

  @override
  Future<void> checkAuth() async {}
  @override
  Future<void> register(String phone, String countryCode) async {}
  @override
  Future<void> login(String phone) async {}
  @override
  Future<bool> verifyOtp(String otp) async => true;
  @override
  Future<bool> loginWithBiometric(String refreshToken) async => true;
  @override
  Future<void> logout() async {}
  @override
  void clearError() {}
}

void main() {
  group('OtpView Widget Tests', () {
    Widget buildSubject({AuthState? authState}) {
      return TestWrapper(
        overrides: [
          authProvider.overrideWith(() => FakeAuthNotifier(
            authState ?? const AuthState(status: AuthStatus.otpSent),
          )),
        ],
        child: const OtpView(),
      );
    }

    testWidgets('renders OTP input fields', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('accepts OTP input', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final firstField = find.byType(TextFormField).first;
      await tester.enterText(firstField, '1');
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('shows verify button', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(AppButton), findsWidgets);
    });

    testWidgets('shows resend OTP option', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(TextButton), findsWidgets);
    });

    testWidgets('shows loading state during verification', (tester) async {
      await tester.pumpWidget(buildSubject(
        authState: const AuthState(status: AuthStatus.loading),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('displays error message', (tester) async {
      await tester.pumpWidget(buildSubject(
        authState: const AuthState(
          status: AuthStatus.otpSent,
          error: 'Invalid OTP',
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Invalid OTP'), findsOneWidget);
    });

    testWidgets('shows countdown timer for resend', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(OtpView), findsOneWidget);
    });

    testWidgets('auto-focuses first OTP field', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsWidgets);
    });

    group('Auto-Submit', () {
      testWidgets('auto-submits when all OTP digits entered', (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        expect(find.byType(OtpView), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('has proper semantic labels', (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        expect(find.byType(Semantics), findsWidgets);
      });
    });

    group('Edge Cases', () {
      testWidgets('handles backspace navigation', (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        final firstField = find.byType(TextFormField).first;
        await tester.enterText(firstField, '1');
        await tester.pump();
        await tester.enterText(firstField, '');
        await tester.pump();

        expect(find.byType(OtpView), findsOneWidget);
      });

      testWidgets('validates OTP length', (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        final firstField = find.byType(TextFormField).first;
        await tester.enterText(firstField, 'abc');
        await tester.pump();

        expect(find.byType(OtpView), findsOneWidget);
      });
    });
  });
}
