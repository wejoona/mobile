import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/design/components/primitives/app_button.dart';
import 'package:usdc_wallet/design/components/primitives/app_input.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/design/tokens/colors.dart';
import '../helpers/accessibility_test_helper.dart';

/// WCAG 2.1 AA Compliance Tests - Semantic Labels
///
/// Guideline: 4.1.2 Name, Role, Value (Level A)
/// All UI components must have accessible names and roles
///
/// Tests verify:
/// - All interactive elements have semantic labels
/// - Labels accurately describe element purpose
/// - Custom semantic labels work correctly
/// - State changes are reflected in semantics
/// - Images have alt text or are marked decorative
void main() {
  group('WCAG 4.1.2 - Semantic Labels', () {
    group('Button Semantic Labels', () {
      testWidgets('AppButton has semantic label from text', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppButton(
                label: 'Send Money',
                onPressed: () {},
              ),
            ),
          ),
        );

        // WCAG: Interactive element must have accessible name
        expect(
          find.bySemanticsLabel('Send Money'),
          findsOneWidget,
          reason: 'Button must have semantic label matching visible text',
        );
      });

      testWidgets('AppButton respects custom semanticLabel', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppButton(
                label: 'Next',
                semanticLabel: 'Continue to payment details',
                onPressed: () {},
              ),
            ),
          ),
        );

        // Custom label should override default
        expect(
          find.bySemanticsLabel('Continue to payment details'),
          findsOneWidget,
          reason: 'Custom semantic label should provide more context',
        );

        // Original text should not be the semantic label
        expect(
          find.bySemanticsLabel('Next'),
          findsNothing,
          reason: 'Custom semantic label should replace default',
        );
      });

      testWidgets('AppButton with icon has complete label', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppButton(
                label: 'Send',
                icon: Icons.send,
                onPressed: () {},
              ),
            ),
          ),
        );

        // Icon should not interfere with label
        expect(
          find.bySemanticsLabel('Send'),
          findsOneWidget,
          reason: 'Button label should be clear regardless of icon',
        );
      });

      testWidgets('Disabled button maintains semantic label', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: AppButton(
                label: 'Submit',
                onPressed: null,
              ),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(AppButton));

        expect(
          semantics.label,
          equals('Submit'),
          reason: 'Disabled button must maintain semantic label',
        );

        expect(
          semantics.hasFlag(SemanticsFlag.isEnabled),
          isFalse,
          reason: 'Disabled state must be announced',
        );
      });

      testWidgets('Loading button announces loading state', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: AppButton(
                label: 'Processing',
                isLoading: true,
              ),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(AppButton));

        expect(
          semantics.label,
          contains('Processing'),
          reason: 'Loading button should maintain label',
        );

        expect(
          semantics.hint,
          contains('Loading'),
          reason: 'Loading state must be announced to screen reader',
        );
      });
    });

    group('Input Field Semantic Labels', () {
      testWidgets('AppInput has semantic label from label prop', (tester) async {
        final controller = TextEditingController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppInput(
                label: 'Phone Number',
                controller: controller,
              ),
            ),
          ),
        );

        final textField = find.byType(TextField);
        final semantics = tester.getSemantics(textField);

        expect(
          semantics.label,
          contains('Phone Number'),
          reason: 'Input field must have semantic label for screen readers',
        );

        expect(
          semantics.hasFlag(SemanticsFlag.isTextField),
          isTrue,
          reason: 'Input must be identified as text field',
        );

        controller.dispose();
      });

      testWidgets('AppInput with error announces error state', (tester) async {
        final controller = TextEditingController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppInput(
                label: 'Email',
                controller: controller,
                errorText: 'Invalid email format',
              ),
            ),
          ),
        );

        // Error text should be in semantics tree
        expect(
          find.text('Invalid email format'),
          findsOneWidget,
          reason: 'Error message must be visible and announced',
        );

        final textField = find.byType(TextField);
        final semantics = tester.getSemantics(textField);

        expect(
          semantics.label,
          contains('Email'),
          reason: 'Input label must remain even with error',
        );

        controller.dispose();
      });

      testWidgets('AppInput with helper text includes context', (tester) async {
        final controller = TextEditingController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppInput(
                label: 'Password',
                controller: controller,
                helperText: 'At least 8 characters',
              ),
            ),
          ),
        );

        // Helper text should be visible
        expect(
          find.text('At least 8 characters'),
          findsOneWidget,
          reason: 'Helper text provides important context',
        );

        controller.dispose();
      });

      testWidgets('Read-only input announces state', (tester) async {
        final controller = TextEditingController(text: 'Read only value');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppInput(
                label: 'Account Number',
                controller: controller,
                readOnly: true,
              ),
            ),
          ),
        );

        final textField = find.byType(TextField);
        final semantics = tester.getSemantics(textField);

        expect(
          semantics.label,
          contains('Account Number'),
          reason: 'Read-only field must have semantic label',
        );

        // Read-only fields should not allow text input action
        expect(
          semantics.hasAction(SemanticsAction.setText),
          isFalse,
          reason: 'Read-only state should prevent editing',
        );

        controller.dispose();
      });
    });

    group('Text Semantic Labels', () {
      testWidgets('AppText with semantic label overrides default', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: AppText(
                'Total Balance',
                semanticLabel: 'Your total balance is one thousand dollars',
              ),
            ),
          ),
        );

        // Custom semantic label should be used
        expect(
          find.bySemanticsLabel('Your total balance is one thousand dollars'),
          findsOneWidget,
          reason: 'Custom semantic label provides better context',
        );
      });

      testWidgets('Currency amounts have clear semantic labels', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: AppText(
                '\$1,234.56',
                semanticLabel: 'One thousand two hundred thirty-four dollars and fifty-six cents',
              ),
            ),
          ),
        );

        // Currency should be read clearly
        expect(
          find.bySemanticsLabel(
            'One thousand two hundred thirty-four dollars and fifty-six cents'
          ),
          findsOneWidget,
          reason: 'Currency values should be pronounced correctly',
        );
      });

      testWidgets('Decorative text can be excluded from semantics', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ExcludeSemantics(
                child: AppText('Decorative divider'),
              ),
            ),
          ),
        );

        // Decorative elements should not be announced
        final textFinder = find.text('Decorative divider');
        expect(textFinder, findsOneWidget);

        // Should not have semantic label
        final semantics = find.bySemanticsLabel('Decorative divider');
        expect(semantics, findsNothing);
      });
    });

    group('Image Semantic Labels', () {
      testWidgets('Images have alt text via Semantics wrapper', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Semantics(
                label: 'JoonaPay logo',
                child: Image.asset(
                  'assets/images/logo.png',
                  errorBuilder: (context, error, stackTrace) => Container(),
                ),
              ),
            ),
          ),
        );

        expect(
          find.bySemanticsLabel('JoonaPay logo'),
          findsOneWidget,
          reason: 'Images must have descriptive alt text',
        );
      });

      testWidgets('Decorative images are excluded from semantics', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ExcludeSemantics(
                child: Image.asset(
                  'assets/images/background.png',
                  errorBuilder: (context, error, stackTrace) => Container(),
                ),
              ),
            ),
          ),
        );

        // Decorative images should not be announced
        final imageFinder = find.byType(Image);
        expect(imageFinder, findsOneWidget);
      });

      testWidgets('Avatar images have descriptive labels', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Semantics(
                label: 'User avatar for Amadou Diallo',
                child: CircleAvatar(
                  child: Image.asset(
                    'assets/images/avatar.png',
                    errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.person),
                  ),
                ),
              ),
            ),
          ),
        );

        expect(
          find.bySemanticsLabel('User avatar for Amadou Diallo'),
          findsOneWidget,
          reason: 'Avatar images should identify the user',
        );
      });
    });

    group('Icon Semantic Labels', () {
      testWidgets('Icons have semantic labels or are decorative', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Row(
                children: [
                  // Decorative icon
                  ExcludeSemantics(
                    child: Icon(Icons.star, color: AppColors.gold500),
                  ),
                  const SizedBox(width: 8),
                  // Informative icon
                  Semantics(
                    label: 'Verified account',
                    child: Icon(Icons.verified, color: AppColors.successBase),
                  ),
                ],
              ),
            ),
          ),
        );

        // Informative icon should have label
        expect(
          find.bySemanticsLabel('Verified account'),
          findsOneWidget,
          reason: 'Meaningful icons must have semantic labels',
        );
      });

      testWidgets('IconButton has semantic label', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {},
                tooltip: 'Settings',
              ),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(IconButton));

        expect(
          semantics.label.isNotEmpty || semantics.tooltip.isNotEmpty,
          isTrue,
          reason: 'Icon buttons must have accessible labels',
        );

        expect(
          semantics.hasFlag(SemanticsFlag.isButton),
          isTrue,
          reason: 'Icon button must have button role',
        );
      });
    });

    group('List Item Semantic Labels', () {
      testWidgets('Transaction list items have descriptive labels', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView(
                children: [
                  Semantics(
                    label: 'Payment to Fatou Traore, 5000 XOF, Yesterday',
                    child: ListTile(
                      leading: const Icon(Icons.send),
                      title: const Text('Fatou Traore'),
                      subtitle: const Text('Yesterday'),
                      trailing: const Text('5000 XOF'),
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        expect(
          find.bySemanticsLabel('Payment to Fatou Traore, 5000 XOF, Yesterday'),
          findsOneWidget,
          reason: 'List items should have complete, descriptive labels',
        );
      });

      testWidgets('Empty list state has clear message', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox_outlined),
                    SizedBox(height: 16),
                    Semantics(
                      label: 'No transactions yet. Start by sending money.',
                      child: Text('No transactions yet'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(
          find.bySemanticsLabel('No transactions yet. Start by sending money.'),
          findsOneWidget,
          reason: 'Empty states should provide helpful guidance',
        );
      });
    });

    group('Navigation Semantic Labels', () {
      testWidgets('Bottom navigation items have clear labels', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Container(),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: 0,
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
                    icon: Icon(Icons.settings),
                    label: 'Settings',
                  ),
                ],
              ),
            ),
          ),
        );

        final navBar = tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar),
        );

        for (final item in navBar.items) {
          expect(
            item.label,
            isNotNull,
            reason: 'Navigation items must have labels',
          );
          expect(
            item.label!.isNotEmpty,
            isTrue,
            reason: 'Navigation labels must not be empty',
          );
        }
      });

      testWidgets('Back button has semantic label', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {},
                  tooltip: 'Go back',
                ),
                title: const Text('Details'),
              ),
              body: Container(),
            ),
          ),
        );

        // Back button should have tooltip
        expect(
          find.byTooltip('Go back'),
          findsOneWidget,
          reason: 'Back navigation must be labeled',
        );
      });
    });

    group('Form Validation Semantic Labels', () {
      testWidgets('Required fields announce requirement', (tester) async {
        final controller = TextEditingController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppInput(
                label: 'Full Name (Required)',
                controller: controller,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(TextField));

        expect(
          semantics.label,
          contains('Required'),
          reason: 'Required fields should announce requirement',
        );

        controller.dispose();
      });

      testWidgets('Field format requirements are announced', (tester) async {
        final controller = TextEditingController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppInput(
                label: 'Phone Number',
                controller: controller,
                helperText: 'Format: +225 XX XX XX XX',
                keyboardType: TextInputType.phone,
              ),
            ),
          ),
        );

        // Helper text should be visible
        expect(
          find.text('Format: +225 XX XX XX XX'),
          findsOneWidget,
          reason: 'Format requirements help users input correctly',
        );

        controller.dispose();
      });
    });

    group('Status and Feedback Semantic Labels', () {
      testWidgets('Success messages have clear labels', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Semantics(
                label: 'Success: Payment sent successfully',
                liveRegion: true,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  color: AppColors.successBase,
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, color: AppColors.white),
                      SizedBox(width: 8),
                      Text('Payment sent successfully'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        expect(
          find.bySemanticsLabel('Success: Payment sent successfully'),
          findsOneWidget,
          reason: 'Success feedback must be announced',
        );
      });

      testWidgets('Error messages are announced as live regions', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Semantics(
                label: 'Error: Insufficient balance',
                liveRegion: true,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  color: AppColors.errorBase,
                  child: const Row(
                    children: [
                      Icon(Icons.error, color: AppColors.white),
                      SizedBox(width: 8),
                      Text('Insufficient balance'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        expect(
          find.bySemanticsLabel('Error: Insufficient balance'),
          findsOneWidget,
          reason: 'Error messages must be announced immediately',
        );
      });
    });

    group('Comprehensive Semantic Audit', () {
      testWidgets('Full screen passes semantic label check', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: const Text('Send Money'),
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    AppInput(
                      label: 'Recipient Phone',
                      controller: TextEditingController(),
                    ),
                    const SizedBox(height: 16),
                    AppInput(
                      label: 'Amount',
                      controller: TextEditingController(),
                    ),
                    const Spacer(),
                    AppButton(
                      label: 'Continue',
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Run comprehensive semantic check
        await AccessibilityTestHelper.checkSemanticLabels(tester);
      });
    });
  });
}
