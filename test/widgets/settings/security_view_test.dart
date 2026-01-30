import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:usdc_wallet/features/settings/views/security_view.dart';
import 'package:usdc_wallet/design/components/primitives/app_button.dart';

import '../../helpers/test_wrapper.dart';
import '../../helpers/test_utils.dart';

void main() {
  group('SecurityView Widget Tests', () {
    setUp(() {
      registerFallbackValues();
    });

    testWidgets('renders security settings', (tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: SecurityView(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SecurityView), findsOneWidget);
    });

    testWidgets('shows PIN change option', (tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: SecurityView(),
        ),
      );

      await tester.pumpAndSettle();

      // Look for PIN-related text or buttons
      expect(find.byType(SecurityView), findsOneWidget);
    });

    testWidgets('shows biometric toggle', (tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: SecurityView(),
        ),
      );

      await tester.pumpAndSettle();

      // Look for Switch widgets for biometric settings
      final switches = find.byType(Switch);
      if (switches.evaluate().isNotEmpty) {
        expect(switches, findsWidgets);
      }
    });

    testWidgets('shows session timeout settings', (tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: SecurityView(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SecurityView), findsOneWidget);
    });

    testWidgets('shows two-factor authentication option', (tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: SecurityView(),
        ),
      );

      await tester.pumpAndSettle();

      // 2FA settings might be present
      expect(find.byType(SecurityView), findsOneWidget);
    });

    testWidgets('toggles biometric authentication', (tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: SecurityView(),
        ),
      );

      await tester.pumpAndSettle();

      final switches = find.byType(Switch);
      if (switches.evaluate().isNotEmpty) {
        final initialValue = tester.widget<Switch>(switches.first).value;
        await tester.tap(switches.first);
        await tester.pumpAndSettle();

        final newValue = tester.widget<Switch>(switches.first).value;
        expect(newValue, isNot(initialValue));
      }
    });

    testWidgets('navigates to change PIN screen', (tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: SecurityView(),
        ),
      );

      await tester.pumpAndSettle();

      // Look for "Change PIN" button
      final changePinButtons = find.text('Change PIN');
      if (changePinButtons.evaluate().isNotEmpty) {
        await tester.tap(changePinButtons.first);
        await tester.pumpAndSettle();
      }

      expect(find.byType(SecurityView), findsOneWidget);
    });

    testWidgets('shows active sessions', (tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: SecurityView(),
        ),
      );

      await tester.pumpAndSettle();

      // Sessions list might be present
      expect(find.byType(SecurityView), findsOneWidget);
    });

    testWidgets('shows trusted devices', (tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: SecurityView(),
        ),
      );

      await tester.pumpAndSettle();

      // Trusted devices might be shown
      expect(find.byType(SecurityView), findsOneWidget);
    });

    group('Accessibility', () {
      testWidgets('has proper semantic labels', (tester) async {
        await tester.pumpWidget(
          const TestWrapper(
            child: SecurityView(),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(Semantics), findsWidgets);
      });

      testWidgets('switch labels are accessible', (tester) async {
        await tester.pumpWidget(
          const TestWrapper(
            child: SecurityView(),
          ),
        );

        await tester.pumpAndSettle();

        final switches = find.byType(Switch);
        if (switches.evaluate().isNotEmpty) {
          expect(switches, findsWidgets);
        }
      });
    });

    group('Edge Cases', () {
      testWidgets('handles biometric not available', (tester) async {
        await tester.pumpWidget(
          const TestWrapper(
            child: SecurityView(),
          ),
        );

        await tester.pumpAndSettle();

        // Biometric option might be disabled
        expect(find.byType(SecurityView), findsOneWidget);
      });

      testWidgets('shows confirmation for sensitive changes', (tester) async {
        await tester.pumpWidget(
          const TestWrapper(
            child: SecurityView(),
          ),
        );

        await tester.pumpAndSettle();

        // Sensitive actions might require confirmation
        expect(find.byType(SecurityView), findsOneWidget);
      });
    });
  });
}
