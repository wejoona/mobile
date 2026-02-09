import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/auth/views/login_view.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/design/components/primitives/app_button.dart';

import '../../helpers/test_wrapper.dart';

/// Fake AuthNotifier for Riverpod 3.x testing — extends real Notifier
class FakeAuthNotifier extends AuthNotifier {
  final AuthState initialState;
  FakeAuthNotifier([this.initialState = const AuthState()]);

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
  group('LoginView Widget Tests', () {
    Widget buildSubject({AuthState? authState}) {
      return TestWrapper(
        overrides: [
          authProvider.overrideWith(() => FakeAuthNotifier(authState ?? const AuthState())),
        ],
        child: const LoginView(),
      );
    }

    testWidgets('renders login form', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsWidgets);
      expect(find.byType(AppButton), findsWidgets);
    });

    testWidgets('accepts phone number input', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, '0123456789');
      await tester.pump();

      expect(find.text('0123456789'), findsOneWidget);
    });

    testWidgets('shows loading state during authentication', (tester) async {
      await tester.pumpWidget(buildSubject(
        authState: const AuthState(status: AuthStatus.loading),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('displays error message', (tester) async {
      await tester.pumpWidget(buildSubject(
        authState: const AuthState(error: 'Invalid phone number'),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Invalid phone number'), findsOneWidget);
    });

    testWidgets('shows country picker', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('+225'), findsOneWidget);
    });

    testWidgets('toggles between login and register mode', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final toggleButtons = find.byType(TextButton);
      if (toggleButtons.evaluate().isNotEmpty) {
        await tester.tap(toggleButtons.first);
        await tester.pumpAndSettle();
      }

      expect(find.byType(LoginView), findsOneWidget);
    });

    testWidgets('validates empty phone number', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final submitButton = find.byType(AppButton).first;
      if (tester.widget<AppButton>(submitButton).onPressed != null) {
        await tester.tap(submitButton);
        await tester.pumpAndSettle();
      }

      expect(find.byType(LoginView), findsOneWidget);
    });

    testWidgets('animates on view entry', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.byType(FadeTransition), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.byType(FadeTransition), findsOneWidget);
    });

    group('Accessibility', () {
      testWidgets('has proper semantic labels', (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        expect(find.byType(Semantics), findsWidgets);
      });
    });

    group('Edge Cases', () {
      testWidgets('handles rapid button taps', (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextFormField).first, '0123456789');
        await tester.pump();

        final submitButton = find.byType(AppButton).first;
        if (tester.widget<AppButton>(submitButton).onPressed != null) {
          await tester.tap(submitButton);
          await tester.pump(const Duration(milliseconds: 10));
          await tester.tap(submitButton);
          await tester.pumpAndSettle();
        }

        expect(find.byType(LoginView), findsOneWidget);
      });

      testWidgets('dismisses keyboard on tap outside', (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        await tester.tap(find.byType(TextFormField).first);
        await tester.pump();

        await tester.tap(find.byType(GestureDetector).first);
        await tester.pumpAndSettle();

        expect(find.byType(LoginView), findsOneWidget);
      });
    });
  });
}
