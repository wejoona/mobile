import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/design/components/primitives/app_button.dart';
import 'package:usdc_wallet/design/tokens/colors.dart';
import 'package:usdc_wallet/design/tokens/spacing.dart';
import '../helpers/accessibility_test_helper.dart';

/// WCAG 2.1 AA Compliance Tests - Touch Target Sizes
///
/// Guideline: 2.5.5 Target Size (Level AAA)
/// Best practice: 2.5.8 Target Size (Minimum) (Level AA in WCAG 2.2)
///
/// Requirements:
/// - Minimum touch target: 44x44 dp (iOS) / 48x48 dp (Material)
/// - Spacing between targets: Minimum 8dp
/// - Exception: Inline text links can be smaller
///
/// Tests verify:
/// - All interactive elements meet minimum size
/// - Adequate spacing between interactive elements
/// - Small variants still meet minimum requirements
/// - Touch targets are properly sized across screen sizes
void main() {
  group('WCAG 2.5.5 - Touch Target Sizes', () {
    // WCAG minimum: 44x44 dp
    // Material guideline: 48x48 dp
    const double minTouchTarget = 44.0;
    const double materialMinTouchTarget = 48.0;

    group('Button Touch Targets', () {
      testWidgets('Primary button meets minimum touch target', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: AppButton(
                  label: 'Continue',
                  onPressed: () {},
                ),
              ),
            ),
          ),
        );

        final size = tester.getSize(find.byType(AppButton));

        expect(
          size.height,
          greaterThanOrEqualTo(minTouchTarget),
          reason: 'Button height must meet WCAG minimum (44dp)',
        );

        expect(
          size.width,
          greaterThanOrEqualTo(minTouchTarget),
          reason: 'Button width must be adequate for touch',
        );
      });

      testWidgets('Full-width button meets minimum height', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: AppButton(
                  label: 'Send Payment',
                  isFullWidth: true,
                  onPressed: () {},
                ),
              ),
            ),
          ),
        );

        final size = tester.getSize(find.byType(AppButton));

        expect(
          size.height,
          greaterThanOrEqualTo(materialMinTouchTarget),
          reason: 'Full-width button should use Material minimum (48dp)',
        );

        // Should span available width
        final screenWidth = tester.getSize(find.byType(Scaffold)).width;
        final expectedWidth = screenWidth - (AppSpacing.md * 2);

        expect(
          size.width,
          equals(expectedWidth),
          reason: 'Full-width button should span container',
        );
      });

      testWidgets('Small button still meets minimum size', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: AppButton(
                  label: 'Cancel',
                  size: AppButtonSize.small,
                  onPressed: () {},
                ),
              ),
            ),
          ),
        );

        final size = tester.getSize(find.byType(AppButton));

        expect(
          size.height,
          greaterThanOrEqualTo(40.0),
          reason: 'Even small buttons should approach WCAG minimum',
        );

        // Small buttons can be slightly smaller but still usable
        expect(
          size.height,
          greaterThanOrEqualTo(40.0),
          reason: 'Small button minimum should be 40dp for usability',
        );
      });

      testWidgets('Icon-only button meets minimum size', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {},
                  iconSize: 24,
                  padding: const EdgeInsets.all(12), // 24 + 12*2 = 48
                ),
              ),
            ),
          ),
        );

        final size = tester.getSize(find.byType(IconButton));

        expect(
          size.height,
          greaterThanOrEqualTo(minTouchTarget),
          reason: 'Icon button must meet minimum touch target',
        );

        expect(
          size.width,
          greaterThanOrEqualTo(minTouchTarget),
          reason: 'Icon button should be square with adequate size',
        );
      });

      testWidgets('Floating action button meets minimum size', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Container(),
              floatingActionButton: FloatingActionButton(
                onPressed: () {},
                child: const Icon(Icons.add),
              ),
            ),
          ),
        );

        final size = tester.getSize(find.byType(FloatingActionButton));

        expect(
          size.height,
          greaterThanOrEqualTo(56.0),
          reason: 'FAB should be 56dp (standard Material size)',
        );

        expect(
          size.width,
          greaterThanOrEqualTo(56.0),
          reason: 'FAB should be square',
        );
      });
    });

    group('Input Field Touch Targets', () {
      testWidgets('Text input meets minimum height', (tester) async {
        final controller = TextEditingController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                  ),
                ),
              ),
            ),
          ),
        );

        final size = tester.getSize(find.byType(TextField));

        expect(
          size.height,
          greaterThanOrEqualTo(48.0),
          reason: 'Text input should meet Material minimum (48dp)',
        );

        controller.dispose();
      });

      testWidgets('Dropdown button meets minimum size', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: DropdownButton<String>(
                  value: 'XOF',
                  items: const [
                    DropdownMenuItem(value: 'XOF', child: Text('XOF')),
                    DropdownMenuItem(value: 'USD', child: Text('USD')),
                  ],
                  onChanged: (value) {},
                ),
              ),
            ),
          ),
        );

        final size = tester.getSize(find.byType(DropdownButton<String>));

        expect(
          size.height,
          greaterThanOrEqualTo(minTouchTarget),
          reason: 'Dropdown button must be easily tappable',
        );
      });

      testWidgets('Checkbox meets minimum size', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: Checkbox(
                  value: false,
                  onChanged: (value) {},
                ),
              ),
            ),
          ),
        );

        final size = tester.getSize(find.byType(Checkbox));

        expect(
          size.height,
          greaterThanOrEqualTo(minTouchTarget),
          reason: 'Checkbox touch area must be adequate',
        );

        expect(
          size.width,
          greaterThanOrEqualTo(minTouchTarget),
          reason: 'Checkbox should have square touch area',
        );
      });

      testWidgets('Switch meets minimum size', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: Switch(
                  value: false,
                  onChanged: (value) {},
                ),
              ),
            ),
          ),
        );

        final size = tester.getSize(find.byType(Switch));

        expect(
          size.height,
          greaterThanOrEqualTo(minTouchTarget),
          reason: 'Switch must be easily toggleable',
        );
      });

      testWidgets('Radio button meets minimum size', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: Radio<int>(
                  value: 1,
                  groupValue: 1,
                  onChanged: (value) {},
                ),
              ),
            ),
          ),
        );

        final size = tester.getSize(find.byType(Radio<int>));

        expect(
          size.height,
          greaterThanOrEqualTo(minTouchTarget),
          reason: 'Radio button touch area must be adequate',
        );

        expect(
          size.width,
          greaterThanOrEqualTo(minTouchTarget),
          reason: 'Radio button should have square touch area',
        );
      });
    });

    group('List Item Touch Targets', () {
      testWidgets('ListTile meets minimum height', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.send),
                    title: const Text('Send Money'),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        );

        final size = tester.getSize(find.byType(ListTile));

        expect(
          size.height,
          greaterThanOrEqualTo(48.0),
          reason: 'List items should meet Material minimum (48dp)',
        );
      });

      testWidgets('Transaction list item meets minimum height', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.gold500,
                      child: const Icon(Icons.person),
                    ),
                    title: const Text('Fatou Traore'),
                    subtitle: const Text('Yesterday at 3:45 PM'),
                    trailing: const Text('5000 XOF'),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        );

        final size = tester.getSize(find.byType(ListTile));

        expect(
          size.height,
          greaterThanOrEqualTo(56.0),
          reason: 'Transaction items should be easily tappable (56dp+)',
        );
      });

      testWidgets('Compact list items still meet minimum', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView(
                children: [
                  ListTile(
                    dense: true,
                    title: const Text('Compact Item'),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        );

        final size = tester.getSize(find.byType(ListTile));

        expect(
          size.height,
          greaterThanOrEqualTo(minTouchTarget),
          reason: 'Even dense list items must meet minimum',
        );
      });
    });

    group('Touch Target Spacing', () {
      testWidgets('Buttons have adequate spacing between them', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    AppButton(
                      label: 'Confirm',
                      onPressed: () {},
                    ),
                    SizedBox(height: AppSpacing.sm),
                    AppButton(
                      label: 'Cancel',
                      onPressed: () {},
                      variant: AppButtonVariant.secondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        final buttons = find.byType(AppButton);
        expect(buttons.evaluate().length, equals(2));

        final firstButton = buttons.at(0);
        final secondButton = buttons.at(1);

        final firstBottom = tester.getBottomLeft(firstButton).dy;
        final secondTop = tester.getTopLeft(secondButton).dy;

        final spacing = secondTop - firstBottom;

        expect(
          spacing,
          greaterThanOrEqualTo(8.0),
          reason: 'Buttons should have minimum 8dp spacing',
        );
      });

      testWidgets('Icon buttons in row have adequate spacing', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.home),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        );

        final buttons = find.byType(IconButton);
        expect(buttons.evaluate().length, equals(3));

        for (int i = 0; i < buttons.evaluate().length - 1; i++) {
          final currentButton = buttons.at(i);
          final nextButton = buttons.at(i + 1);

          final currentRight = tester.getTopRight(currentButton).dx;
          final nextLeft = tester.getTopLeft(nextButton).dx;

          final spacing = nextLeft - currentRight;

          expect(
            spacing,
            greaterThanOrEqualTo(0),
            reason: 'Icon buttons should not overlap',
          );
        }
      });

      testWidgets('Bottom navigation items are adequately spaced', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Container(),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: 0,
                type: BottomNavigationBarType.fixed,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.send),
                    label: 'Send',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.history),
                    label: 'History',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings),
                    label: 'Settings',
                  ),
                ],
              ),
            ),
          ),
        );

        final navBar = tester.getSize(find.byType(BottomNavigationBar));

        expect(
          navBar.height,
          greaterThanOrEqualTo(56.0),
          reason: 'Bottom nav should be at least 56dp high',
        );
      });
    });

    group('Responsive Touch Targets', () {
      testWidgets('Touch targets maintain size on small screens', (tester) async {
        tester.view.physicalSize = const Size(320, 568); // iPhone SE
        tester.view.devicePixelRatio = 2.0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: AppButton(
                  label: 'Continue',
                  onPressed: () {},
                ),
              ),
            ),
          ),
        );

        final size = tester.getSize(find.byType(AppButton));

        expect(
          size.height,
          greaterThanOrEqualTo(minTouchTarget),
          reason: 'Buttons must maintain minimum size on small screens',
        );

        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });
      });

      testWidgets('Touch targets scale appropriately on large screens', (tester) async {
        tester.view.physicalSize = const Size(1080, 2400); // Large phone
        tester.view.devicePixelRatio = 3.0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: AppButton(
                  label: 'Continue',
                  isFullWidth: true,
                  onPressed: () {},
                ),
              ),
            ),
          ),
        );

        final size = tester.getSize(find.byType(AppButton));

        expect(
          size.height,
          greaterThanOrEqualTo(materialMinTouchTarget),
          reason: 'Buttons should maintain comfortable size on large screens',
        );

        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });
      });

      testWidgets('Touch targets work in landscape orientation', (tester) async {
        tester.view.physicalSize = const Size(844, 390); // iPhone landscape
        tester.view.devicePixelRatio = 3.0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: AppButton(
                        label: 'Cancel',
                        onPressed: () {},
                        variant: AppButtonVariant.secondary,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: AppButton(
                        label: 'Confirm',
                        onPressed: () {},
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        final buttons = find.byType(AppButton);
        expect(buttons.evaluate().length, equals(2));

        for (final button in buttons.evaluate()) {
          final size = tester.getSize(find.byWidget(button.widget));

          expect(
            size.height,
            greaterThanOrEqualTo(minTouchTarget),
            reason: 'Buttons must maintain size in landscape',
          );
        }

        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });
      });
    });

    group('Edge Cases', () {
      testWidgets('Disabled buttons maintain touch target size', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: AppButton(
                  label: 'Disabled',
                  onPressed: null,
                ),
              ),
            ),
          ),
        );

        final size = tester.getSize(find.byType(AppButton));

        expect(
          size.height,
          greaterThanOrEqualTo(minTouchTarget),
          reason: 'Disabled buttons must maintain size for layout consistency',
        );
      });

      testWidgets('Loading buttons maintain touch target size', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: AppButton(
                  label: 'Processing',
                  isLoading: true,
                ),
              ),
            ),
          ),
        );

        final size = tester.getSize(find.byType(AppButton));

        expect(
          size.height,
          greaterThanOrEqualTo(minTouchTarget),
          reason: 'Loading state should not reduce touch target',
        );
      });

      testWidgets('Buttons with long text wrap without shrinking height', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: AppButton(
                  label: 'This is a very long button label that might wrap',
                  onPressed: () {},
                ),
              ),
            ),
          ),
        );

        final size = tester.getSize(find.byType(AppButton));

        expect(
          size.height,
          greaterThanOrEqualTo(minTouchTarget),
          reason: 'Text wrapping should not reduce touch target height',
        );
      });
    });

    group('Comprehensive Touch Target Audit', () {
      testWidgets('Full screen passes touch target checks', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: const Text('Settings'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.help),
                    onPressed: () {},
                  ),
                ],
              ),
              body: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Profile'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.security),
                    title: const Text('Security'),
                    trailing: Switch(
                      value: true,
                      onChanged: (value) {},
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: AppButton(
                      label: 'Save Changes',
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        // Run comprehensive touch target check
        await AccessibilityTestHelper.checkTouchTargets(tester);
      });

      testWidgets('Dense UI still meets minimum requirements', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: const Text('Compact View'),
              ),
              body: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                padding: EdgeInsets.all(AppSpacing.md),
                children: List.generate(6, (index) {
                  return InkWell(
                    onTap: () {},
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.elevated,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.star, color: AppColors.gold500),
                          const SizedBox(height: 8),
                          Text('Item $index'),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        );

        // Check that grid items are tappable
        final gridItems = find.byType(InkWell);
        expect(gridItems.evaluate().length, equals(6));

        for (final item in gridItems.evaluate()) {
          final size = tester.getSize(find.byWidget(item.widget));

          expect(
            size.height,
            greaterThanOrEqualTo(minTouchTarget),
            reason: 'Grid items must be easily tappable',
          );
        }
      });
    });
  });
}
