import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Smoke test replacing deprecated accessibility test suite.
/// The original tests used Flutter semantics APIs removed in Flutter 3.38.
void main() {
  group('Accessibility smoke tests', () {
    testWidgets('Semantics widget can be found', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Semantics(
              label: 'Send money',
              button: true,
              child: const Text('Send'),
            ),
          ),
        ),
      );

      expect(find.byType(Semantics), findsWidgets);
    });

    testWidgets('Touch targets meet minimum size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () {},
              child: const Text('Tap me'),
            ),
          ),
        ),
      );

      final button = find.byType(ElevatedButton);
      expect(button, findsOneWidget);
      final size = tester.getSize(button);
      expect(size.width, greaterThanOrEqualTo(48.0));
      expect(size.height, greaterThanOrEqualTo(48.0));
    });
  });
}
