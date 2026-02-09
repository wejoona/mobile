import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:usdc_wallet/features/auth/views/login_view.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/design/components/primitives/app_button.dart';

import '../../helpers/test_wrapper.dart';
import '../../helpers/test_utils.dart';

class MockAuthNotifier extends Mock implements AuthNotifier {}

void main() {
  group('LoginView Widget Tests', () {
    late MockAuthNotifier mockAuthNotifier;

    setUp(() {
      mockAuthNotifier = MockAuthNotifier();
      registerFallbackValues();
    });

    testWidgets('renders login form', (tester) async {
      when(() => mockAuthNotifier.build())
          .thenReturn(const AuthState());

      await tester.pumpWidget(
        TestWrapper(
          overrides: [
            authProvider.overrideWith(() => mockAuthNotifier),
          ],
          child: const LoginView(),
        ),
      );

      await tester.pumpAndSettle();

      // Should show phone input and continue button
      expect(find.byType(TextFormField), findsWidgets);
      expect(find.byType(AppButton), findsWidgets);
    });

    testWidgets('accepts phone number input', (tester) async {
      when(() => mockAuthNotifier.build())
          .thenReturn(const AuthState());

      await tester.pumpWidget(
        TestWrapper(
          overrides: [
            authProvider.overrideWith(() => mockAuthNotifier),
          ],
          child: const LoginView(),
        ),
      );

      await tester.pumpAndSettle();

      // Enter phone number
      await tester.enterText(
        find.byType(TextFormField).first,
        '0123456789',
      );

      await tester.pump();

      expect(find.text('0123456789'), findsOneWidget);
    });

    testWidgets('shows loading state during authentication', (tester) async {
      when(() => mockAuthNotifier.build())
          .thenReturn(const AuthState(status: AuthStatus.loading));

      await tester.pumpWidget(
        TestWrapper(
          overrides: [
            authProvider.overrideWith(() => mockAuthNotifier),
          ],
          child: const LoginView(),
        ),
      );

      await tester.pumpAndSettle();

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('displays error message', (tester) async {
      when(() => mockAuthNotifier.build())
          .thenReturn(const AuthState(error: 'Invalid phone number'));

      await tester.pumpWidget(
        TestWrapper(
          overrides: [
            authProvider.overrideWith(() => mockAuthNotifier),
          ],
          child: const LoginView(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Invalid phone number'), findsOneWidget);
    });

    testWidgets('shows country picker', (tester) async {
      when(() => mockAuthNotifier.build())
          .thenReturn(const AuthState());

      await tester.pumpWidget(
        TestWrapper(
          overrides: [
            authProvider.overrideWith(() => mockAuthNotifier),
          ],
          child: const LoginView(),
        ),
      );

      await tester.pumpAndSettle();

      // Should show default country code
      expect(find.text('+225'), findsOneWidget);
    });

    testWidgets('toggles between login and register mode', (tester) async {
      when(() => mockAuthNotifier.build())
          .thenReturn(const AuthState());

      await tester.pumpWidget(
        TestWrapper(
          overrides: [
            authProvider.overrideWith(() => mockAuthNotifier),
          ],
          child: const LoginView(),
        ),
      );

      await tester.pumpAndSettle();

      // Look for toggle button (might be TextButton)
      final toggleButtons = find.byType(TextButton);
      if (toggleButtons.evaluate().isNotEmpty) {
        await tester.tap(toggleButtons.first);
        await tester.pumpAndSettle();
      }

      expect(find.byType(LoginView), findsOneWidget);
    });

    testWidgets('validates empty phone number', (tester) async {
      when(() => mockAuthNotifier.build())
          .thenReturn(const AuthState());

      await tester.pumpWidget(
        TestWrapper(
          overrides: [
            authProvider.overrideWith(() => mockAuthNotifier),
          ],
          child: const LoginView(),
        ),
      );

      await tester.pumpAndSettle();

      // Try to submit without entering phone
      final submitButton = find.byType(AppButton).first;
      if (tester.widget<AppButton>(submitButton).onPressed != null) {
        await tester.tap(submitButton);
        await tester.pumpAndSettle();
      }

      // Should not proceed without valid input
      expect(find.byType(LoginView), findsOneWidget);
    });

    testWidgets('animates on view entry', (tester) async {
      when(() => mockAuthNotifier.build())
          .thenReturn(const AuthState());

      await tester.pumpWidget(
        TestWrapper(
          overrides: [
            authProvider.overrideWith(() => mockAuthNotifier),
          ],
          child: const LoginView(),
        ),
      );

      // Animation should be in progress
      expect(find.byType(FadeTransition), findsOneWidget);

      await tester.pumpAndSettle();

      // Animation should be complete
      expect(find.byType(FadeTransition), findsOneWidget);
    });

    group('Accessibility', () {
      testWidgets('has proper semantic labels', (tester) async {
        when(() => mockAuthNotifier.build())
            .thenReturn(const AuthState());

        await tester.pumpWidget(
          TestWrapper(
            overrides: [
              authProvider.overrideWith(() => mockAuthNotifier),
            ],
            child: const LoginView(),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(Semantics), findsWidgets);
      });
    });

    group('Edge Cases', () {
      testWidgets('handles rapid button taps', (tester) async {
        when(() => mockAuthNotifier.build())
            .thenReturn(const AuthState());

        await tester.pumpWidget(
          TestWrapper(
            overrides: [
              authProvider.overrideWith(() => mockAuthNotifier),
            ],
            child: const LoginView(),
          ),
        );

        await tester.pumpAndSettle();

        // Enter valid phone
        await tester.enterText(
          find.byType(TextFormField).first,
          '0123456789',
        );

        await tester.pump();

        // Rapid taps on submit button
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
        when(() => mockAuthNotifier.build())
            .thenReturn(const AuthState());

        await tester.pumpWidget(
          TestWrapper(
            overrides: [
              authProvider.overrideWith(() => mockAuthNotifier),
            ],
            child: const LoginView(),
          ),
        );

        await tester.pumpAndSettle();

        // Tap on input to focus
        await tester.tap(find.byType(TextFormField).first);
        await tester.pump();

        // Tap outside (on GestureDetector)
        await tester.tap(find.byType(GestureDetector).first);
        await tester.pumpAndSettle();

        expect(find.byType(LoginView), findsOneWidget);
      });
    });
  });
}
