import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/design/components/primitives/app_select.dart';

import '../../helpers/test_wrapper.dart';

void main() {
  group('AppSelect Widget Tests', () {
    final testItems = [
      const AppSelectItem(value: 'option1', label: 'Option 1'),
      const AppSelectItem(value: 'option2', label: 'Option 2'),
      const AppSelectItem(value: 'option3', label: 'Option 3'),
    ];

    testWidgets('renders with label', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: AppSelect<String>(
            items: testItems,
            value: null,
            onChanged: (_) {},
            label: 'Select Option',
          ),
        ),
      );

      expect(find.text('Select Option'), findsOneWidget);
    });

    testWidgets('renders with hint when no value selected', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: AppSelect<String>(
            items: testItems,
            value: null,
            onChanged: (_) {},
            hint: 'Choose an option',
          ),
        ),
      );

      expect(find.text('Choose an option'), findsOneWidget);
    });

    testWidgets('displays selected value', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: AppSelect<String>(
            items: testItems,
            value: 'option2',
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Option 2'), findsOneWidget);
    });

    testWidgets('shows dropdown when tapped', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: AppSelect<String>(
            items: testItems,
            value: null,
            onChanged: (_) {},
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      expect(find.text('Option 1'), findsWidgets);
      expect(find.text('Option 2'), findsWidgets);
      expect(find.text('Option 3'), findsWidgets);
    });

    testWidgets('calls onChanged when option selected', (tester) async {
      String? selectedValue;

      await tester.pumpWidget(
        TestWrapper(
          child: AppSelect<String>(
            items: testItems,
            value: null,
            onChanged: (value) => selectedValue = value,
          ),
        ),
      );

      // Open dropdown
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      // Select option
      await tester.tap(find.text('Option 2').last);
      await tester.pumpAndSettle();

      expect(selectedValue, 'option2');
    });

    testWidgets('closes dropdown after selection', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: AppSelect<String>(
            items: testItems,
            value: null,
            onChanged: (_) {},
          ),
        ),
      );

      // Open dropdown
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      // Select option
      await tester.tap(find.text('Option 1').last);
      await tester.pumpAndSettle();

      // Dropdown should be closed
      expect(find.text('Option 2'), findsNothing);
    });

    testWidgets('displays error message', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: AppSelect<String>(
            items: testItems,
            value: null,
            onChanged: (_) {},
            error: 'Please select an option',
          ),
        ),
      );

      expect(find.text('Please select an option'), findsOneWidget);
    });

    testWidgets('displays helper text', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: AppSelect<String>(
            items: testItems,
            value: null,
            onChanged: (_) {},
            helper: 'Select your preferred option',
          ),
        ),
      );

      expect(find.text('Select your preferred option'), findsOneWidget);
    });

    testWidgets('is disabled when enabled is false', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: AppSelect<String>(
            items: testItems,
            value: null,
            onChanged: (_) {},
            enabled: false,
          ),
        ),
      );

      // Attempt to tap
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      // Dropdown should not open
      expect(find.text('Option 1'), findsNothing);
    });

    group('Items with Icons', () {
      final itemsWithIcons = [
        const AppSelectItem(value: 'home', label: 'Home', icon: Icons.home),
        const AppSelectItem(value: 'work', label: 'Work', icon: Icons.work),
      ];

      testWidgets('displays item icons in dropdown', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: AppSelect<String>(
              items: itemsWithIcons,
              value: null,
              onChanged: (_) {},
            ),
          ),
        );

        // Open dropdown
        await tester.tap(find.byType(GestureDetector).first);
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.home), findsOneWidget);
        expect(find.byIcon(Icons.work), findsOneWidget);
      });

      testWidgets('displays selected item icon', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: AppSelect<String>(
              items: itemsWithIcons,
              value: 'home',
              onChanged: (_) {},
            ),
          ),
        );

        expect(find.byIcon(Icons.home), findsOneWidget);
      });
    });

    group('Items with Subtitles', () {
      final itemsWithSubtitles = [
        const AppSelectItem(
          value: '1',
          label: 'Option 1',
          subtitle: 'Description 1',
        ),
        const AppSelectItem(
          value: '2',
          label: 'Option 2',
          subtitle: 'Description 2',
        ),
      ];

      testWidgets('displays subtitles in dropdown', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: AppSelect<String>(
              items: itemsWithSubtitles,
              value: null,
              onChanged: (_) {},
            ),
          ),
        );

        // Open dropdown
        await tester.tap(find.byType(GestureDetector).first);
        await tester.pumpAndSettle();

        expect(find.text('Description 1'), findsOneWidget);
        expect(find.text('Description 2'), findsOneWidget);
      });
    });

    group('Disabled Items', () {
      final itemsWithDisabled = [
        const AppSelectItem(value: '1', label: 'Enabled'),
        const AppSelectItem(value: '2', label: 'Disabled', enabled: false),
      ];

      testWidgets('does not select disabled items', (tester) async {
        String? selectedValue;

        await tester.pumpWidget(
          TestWrapper(
            child: AppSelect<String>(
              items: itemsWithDisabled,
              value: null,
              onChanged: (value) => selectedValue = value,
            ),
          ),
        );

        // Open dropdown
        await tester.tap(find.byType(GestureDetector).first);
        await tester.pumpAndSettle();

        // Try to tap disabled item
        await tester.tap(find.text('Disabled'));
        await tester.pumpAndSettle();

        expect(selectedValue, isNull);
      });
    });

    testWidgets('shows checkmark on selected item', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: AppSelect<String>(
            items: testItems,
            value: 'option1',
            onChanged: (_) {},
            showCheckmark: true,
          ),
        ),
      );

      // Open dropdown
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('hides checkmark when showCheckmark is false', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: AppSelect<String>(
            items: testItems,
            value: 'option1',
            onChanged: (_) {},
            showCheckmark: false,
          ),
        ),
      );

      // Open dropdown
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle), findsNothing);
    });

    testWidgets('renders prefix icon', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: AppSelect<String>(
            items: testItems,
            value: null,
            onChanged: (_) {},
            prefixIcon: Icons.category,
          ),
        ),
      );

      expect(find.byIcon(Icons.category), findsOneWidget);
    });

    testWidgets('shows dropdown arrow icon', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: AppSelect<String>(
            items: testItems,
            value: null,
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
    });

    group('Edge Cases', () {
      testWidgets('handles empty items list', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: AppSelect<String>(
              items: const [],
              value: null,
              onChanged: (_) {},
            ),
          ),
        );

        // Open dropdown
        await tester.tap(find.byType(GestureDetector).first);
        await tester.pumpAndSettle();

        expect(find.byType(ListView), findsOneWidget);
      });

      testWidgets('handles very long option labels', (tester) async {
        final longItems = [
          const AppSelectItem(
            value: '1',
            label: 'This is a very long option label that might overflow',
          ),
        ];

        await tester.pumpWidget(
          TestWrapper(
            child: AppSelect<String>(
              items: longItems,
              value: null,
              onChanged: (_) {},
            ),
          ),
        );

        expect(find.text('This is a very long option label that might overflow'), findsOneWidget);
      });

      testWidgets('handles rapid open/close', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: AppSelect<String>(
              items: testItems,
              value: null,
              onChanged: (_) {},
            ),
          ),
        );

        // Open
        await tester.tap(find.byType(GestureDetector).first);
        await tester.pump();

        // Close by tapping outside
        await tester.tapAt(const Offset(0, 0));
        await tester.pumpAndSettle();

        // Open again
        await tester.tap(find.byType(GestureDetector).first);
        await tester.pumpAndSettle();

        expect(find.text('Option 1'), findsWidgets);
      });
    });
  });

  group('AppSelectItem Tests', () {
    test('creates item with required fields', () {
      const item = AppSelectItem(value: 'test', label: 'Test');

      expect(item.value, 'test');
      expect(item.label, 'Test');
      expect(item.enabled, isTrue);
      expect(item.icon, isNull);
      expect(item.subtitle, isNull);
    });

    test('creates item with all fields', () {
      const item = AppSelectItem(
        value: 'test',
        label: 'Test',
        icon: Icons.star,
        subtitle: 'Subtitle',
        enabled: false,
      );

      expect(item.value, 'test');
      expect(item.label, 'Test');
      expect(item.icon, Icons.star);
      expect(item.subtitle, 'Subtitle');
      expect(item.enabled, isFalse);
    });
  });
}
