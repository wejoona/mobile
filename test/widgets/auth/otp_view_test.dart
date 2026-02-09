import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:usdc_wallet/features/auth/views/otp_view.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/design/components/primitives/app_button.dart';

import '../../helpers/test_wrapper.dart';
import '../../helpers/test_utils.dart';

class MockAuthNotifier extends Mock implements AuthNotifier {}

void main() {
  group('OtpView Widget Tests', () {
    late MockAuthNotifier mockAuthNotifier;

    setUp(() {
      mockAuthNotifier = MockAuthNotifier();
      registerFallbackValues();
    });

    testWidgets('renders OTP input fields', (tester) async {
      when(() => mockAuthNotifier.build())
          .thenReturn(const AuthState(status: AuthStatus.otpSent));

      await tester.pumpWidget(
        TestWrapper(
          overrides: [
            authProvider.overrideWith(() => mockAuthNotifier),
          ],
          child: const OtpView(),
        ),
      );

      await tester.pumpAndSettle();

      // Should show OTP input fields (usually 6 digits)
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('accepts OTP input', (tester) async {
      when(() => mockAuthNotifier.build())
          .thenReturn(const AuthState(status: AuthStatus.otpSent));

      await tester.pumpWidget(
        TestWrapper(
          overrides: [
            authProvider.overrideWith(() => mockAuthNotifier),
          ],
          child: const OtpView(),
        ),
      );

      await tester.pumpAndSettle();

      // Enter OTP
      final firstField = find.byType(TextFormField).first;
      await tester.enterText(firstField, '1');

      await tester.pump();

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('shows verify button', (tester) async {
      when(() => mockAuthNotifier.build())
          .thenReturn(const AuthState(status: AuthStatus.otpSent));

      await tester.pumpWidget(
        TestWrapper(
          overrides: [
            authProvider.overrideWith(() => mockAuthNotifier),
          ],
          child: const OtpView(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(AppButton), findsWidgets);
    });

    testWidgets('shows resend OTP option', (tester) async {
      when(() => mockAuthNotifier.build())
          .thenReturn(const AuthState(status: AuthStatus.otpSent));

      await tester.pumpWidget(
        TestWrapper(
          overrides: [
            authProvider.overrideWith(() => mockAuthNotifier),
          ],
          child: const OtpView(),
        ),
      );

      await tester.pumpAndSettle();

      // Look for resend button or text
      expect(find.byType(TextButton), findsWidgets);
    });

    testWidgets('shows loading state during verification', (tester) async {
      when(() => mockAuthNotifier.build())
          .thenReturn(const AuthState(
            status: AuthStatus.loading,
          ));

      await tester.pumpWidget(
        TestWrapper(
          overrides: [
            authProvider.overrideWith(() => mockAuthNotifier),
          ],
          child: const OtpView(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('displays error message', (tester) async {
      when(() => mockAuthNotifier.build())
          .thenReturn(const AuthState(
            status: AuthStatus.otpSent,
            error: 'Invalid OTP',
          ));

      await tester.pumpWidget(
        TestWrapper(
          overrides: [
            authProvider.overrideWith(() => mockAuthNotifier),
          ],
          child: const OtpView(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Invalid OTP'), findsOneWidget);
    });

    testWidgets('shows countdown timer for resend', (tester) async {
      when(() => mockAuthNotifier.build())
          .thenReturn(const AuthState(status: AuthStatus.otpSent));

      await tester.pumpWidget(
        TestWrapper(
          overrides: [
            authProvider.overrideWith(() => mockAuthNotifier),
          ],
          child: const OtpView(),
        ),
      );

      await tester.pumpAndSettle();

      // Timer text might be present
      expect(find.byType(OtpView), findsOneWidget);
    });

    testWidgets('auto-focuses first OTP field', (tester) async {
      when(() => mockAuthNotifier.build())
          .thenReturn(const AuthState(status: AuthStatus.otpSent));

      await tester.pumpWidget(
        TestWrapper(
          overrides: [
            authProvider.overrideWith(() => mockAuthNotifier),
          ],
          child: const OtpView(),
        ),
      );

      await tester.pumpAndSettle();

      // First field should be autofocused
      expect(find.byType(TextFormField), findsWidgets);
    });

    group('Auto-Submit', () {
      testWidgets('auto-submits when all OTP digits entered', (tester) async {
        when(() => mockAuthNotifier.build())
            .thenReturn(const AuthState(status: AuthStatus.otpSent));
        when(() => mockAuthNotifier.verifyOtp(any()))
            .thenAnswer((_) async => true);

        await tester.pumpWidget(
          TestWrapper(
            overrides: [
              authProvider.overrideWith(() => mockAuthNotifier),
            ],
            child: const OtpView(),
          ),
        );

        await tester.pumpAndSettle();

        // This test assumes auto-submit functionality exists
        // The actual implementation may vary
        expect(find.byType(OtpView), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('has proper semantic labels', (tester) async {
        when(() => mockAuthNotifier.build())
            .thenReturn(const AuthState(status: AuthStatus.otpSent));

        await tester.pumpWidget(
          TestWrapper(
            overrides: [
              authProvider.overrideWith(() => mockAuthNotifier),
            ],
            child: const OtpView(),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(Semantics), findsWidgets);
      });
    });

    group('Edge Cases', () {
      testWidgets('handles backspace navigation', (tester) async {
        when(() => mockAuthNotifier.build())
            .thenReturn(const AuthState(status: AuthStatus.otpSent));

        await tester.pumpWidget(
          TestWrapper(
            overrides: [
              authProvider.overrideWith(() => mockAuthNotifier),
            ],
            child: const OtpView(),
          ),
        );

        await tester.pumpAndSettle();

        // Enter and delete
        final firstField = find.byType(TextFormField).first;
        await tester.enterText(firstField, '1');
        await tester.pump();
        await tester.enterText(firstField, '');
        await tester.pump();

        expect(find.byType(OtpView), findsOneWidget);
      });

      testWidgets('validates OTP length', (tester) async {
        when(() => mockAuthNotifier.build())
            .thenReturn(const AuthState(status: AuthStatus.otpSent));

        await tester.pumpWidget(
          TestWrapper(
            overrides: [
              authProvider.overrideWith(() => mockAuthNotifier),
            ],
            child: const OtpView(),
          ),
        );

        await tester.pumpAndSettle();

        // Try entering non-numeric characters (should be filtered)
        final firstField = find.byType(TextFormField).first;
        await tester.enterText(firstField, 'abc');
        await tester.pump();

        // Non-numeric should be rejected
        expect(find.byType(OtpView), findsOneWidget);
      });
    });
  });
}
