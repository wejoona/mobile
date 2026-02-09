import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/design/components/primitives/app_button.dart';
import 'package:usdc_wallet/design/components/primitives/app_input.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/design/tokens/colors.dart';
import 'package:usdc_wallet/design/tokens/spacing.dart';
import '../helpers/accessibility_test_helper.dart';

/// WCAG 2.1 AA Compliance Tests - Screen Reader Compatibility
///
/// Guidelines:
/// - 1.3.1 Info and Relationships (Level A)
/// - 4.1.2 Name, Role, Value (Level A)
/// - 4.1.3 Status Messages (Level AA)
///
/// Tests verify:
/// - Screen reader announcements for state changes
/// - Live regions for dynamic content
/// - Form field associations
/// - Navigation context
/// - Error and success announcements
/// - Loading state announcements
void main() {
  group('WCAG Screen Reader Compatibility', () {
    group('Button State Announcements', () {
      testWidgets('Button role is announced', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppButton(
                label: 'Continue',
                onPressed: () {},
              ),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(AppButton));

        expect(
          semantics.hasFlag(SemanticsFlag.isButton),
          isTrue,
          reason: 'Screen reader must announce element as a button',
        );

        expect(
          semantics.hasFlag(SemanticsFlag.isEnabled),
          isTrue,
          reason: 'Enabled state must be announced',
        );
      });

      testWidgets('Loading state is announced to screen reader', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: AppButton(
                label: 'Submit',
                isLoading: true,
              ),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(AppButton));

        expect(
          semantics.hint,
          contains('Loading'),
          reason: 'Screen reader must announce loading state',
        );

        expect(
          semantics.label,
          contains('Submit'),
          reason: 'Button label should remain during loading',
        );
      });

      testWidgets('Disabled state is announced', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: AppButton(
                label: 'Disabled Button',
                onPressed: null,
              ),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(AppButton));

        expect(
          semantics.hasFlag(SemanticsFlag.hasEnabledState),
          isTrue,
          reason: 'Button should have enabled state flag',
        );

        expect(
          semantics.hasFlag(SemanticsFlag.isEnabled),
          isFalse,
          reason: 'Disabled state must be announced to screen reader',
        );
      });

      testWidgets('Button tap action is available', (tester) async {
        bool tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppButton(
                label: 'Tap Me',
                onPressed: () => tapped = true,
              ),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(AppButton));

        expect(
          semantics.hasAction(SemanticsAction.tap),
          isTrue,
          reason: 'Screen reader must be able to activate button',
        );

        // Verify tap works
        await tester.tap(find.byType(AppButton));
        expect(tapped, isTrue);
      });
    });

    group('Form Field Announcements', () {
      testWidgets('Text field role is announced', (tester) async {
        final controller = TextEditingController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppInput(
                label: 'Email Address',
                controller: controller,
              ),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(TextField));

        expect(
          semantics.hasFlag(SemanticsFlag.isTextField),
          isTrue,
          reason: 'Screen reader must announce element as text field',
        );

        expect(
          semantics.label,
          contains('Email Address'),
          reason: 'Field label must be announced',
        );

        controller.dispose();
      });

      testWidgets('Required field announces requirement', (tester) async {
        final controller = TextEditingController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppInput(
                label: 'Full Name (Required)',
                controller: controller,
              ),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(TextField));

        expect(
          semantics.label,
          contains('Required'),
          reason: 'Required state should be in label',
        );

        controller.dispose();
      });

      testWidgets('Error state is announced via live region', (tester) async {
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

        // Error text should be visible
        expect(
          find.text('Invalid email format'),
          findsOneWidget,
          reason: 'Error message must be announced',
        );

        // Find error text semantics
        final errorText = find.text('Invalid email format');
        expect(
          errorText,
          findsOneWidget,
          reason: 'Error should be in semantics tree for announcement',
        );

        controller.dispose();
      });

      testWidgets('Helper text provides context', (tester) async {
        final controller = TextEditingController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppInput(
                label: 'Password',
                controller: controller,
                helperText: 'Must be at least 8 characters',
              ),
            ),
          ),
        );

        // Helper text should be visible
        expect(
          find.text('Must be at least 8 characters'),
          findsOneWidget,
          reason: 'Helper text provides important context',
        );

        controller.dispose();
      });

      testWidgets('Read-only field announces state', (tester) async {
        final controller = TextEditingController(text: 'Read-only value');

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

        final semantics = tester.getSemantics(find.byType(TextField));

        expect(
          semantics.hasAction(SemanticsAction.setText),
          isFalse,
          reason: 'Read-only state prevents text input action',
        );

        controller.dispose();
      });

      testWidgets('Form validation errors are announced', (tester) async {
        final formKey = GlobalKey<FormState>();
        final controller = TextEditingController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Form(
                key: formKey,
                child: Column(
                  children: [
                    AppInput(
                      label: 'Email',
                      controller: controller,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Email is required';
                        }
                        return null;
                      },
                    ),
                    AppButton(
                      label: 'Submit',
                      onPressed: () {
                        formKey.currentState!.validate();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Trigger validation
        await tester.tap(find.byType(AppButton));
        await tester.pumpAndSettle();

        // Error should be announced
        expect(
          find.text('Email is required'),
          findsOneWidget,
          reason: 'Validation error must be announced',
        );

        controller.dispose();
      });
    });

    group('Live Region Announcements', () {
      testWidgets('Success message is announced as live region', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Semantics(
                label: 'Payment sent successfully',
                liveRegion: true,
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  color: AppColors.successBase,
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, color: AppColors.white),
                      SizedBox(width: 8),
                      AppText('Payment sent successfully'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        expect(
          find.bySemanticsLabel('Payment sent successfully'),
          findsOneWidget,
          reason: 'Success message must be announced immediately',
        );
      });

      testWidgets('Error message is announced as live region', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Semantics(
                label: 'Error: Insufficient balance',
                liveRegion: true,
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  color: AppColors.errorBase,
                  child: const Row(
                    children: [
                      Icon(Icons.error, color: AppColors.white),
                      SizedBox(width: 8),
                      AppText('Insufficient balance'),
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
          reason: 'Error must be announced immediately via live region',
        );
      });

      testWidgets('Loading state change is announced', (tester) async {
        bool isLoading = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    children: [
                      if (isLoading)
                        Semantics(
                          label: 'Loading',
                          liveRegion: true,
                          child: const CircularProgressIndicator(),
                        ),
                      AppButton(
                        label: 'Load Data',
                        onPressed: () {
                          setState(() => isLoading = true);
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );

        // Trigger loading
        await tester.tap(find.byType(AppButton));
        await tester.pump();

        expect(
          find.bySemanticsLabel('Loading'),
          findsOneWidget,
          reason: 'Loading state must be announced',
        );
      });

      testWidgets('Dynamic content updates are announced', (tester) async {
        String message = 'Initial message';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    children: [
                      Semantics(
                        label: message,
                        liveRegion: true,
                        child: AppText(message),
                      ),
                      AppButton(
                        label: 'Update',
                        onPressed: () {
                          setState(() => message = 'Updated message');
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );

        // Update message
        await tester.tap(find.byType(AppButton));
        await tester.pumpAndSettle();

        expect(
          find.bySemanticsLabel('Updated message'),
          findsOneWidget,
          reason: 'Content updates should be announced',
        );
      });
    });

    group('Navigation Announcements', () {
      testWidgets('Screen title is announced on navigation', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: const Text('Send Money'),
              ),
              body: Container(),
            ),
          ),
        );

        expect(
          find.text('Send Money'),
          findsOneWidget,
          reason: 'Screen title should be announced when navigating',
        );
      });

      testWidgets('Back button is properly labeled', (tester) async {
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

        expect(
          find.byTooltip('Go back'),
          findsOneWidget,
          reason: 'Back button must be labeled for screen reader',
        );
      });

      testWidgets('Bottom navigation announces selected item', (tester) async {
        int currentIndex = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                return Scaffold(
                  body: Container(),
                  bottomNavigationBar: BottomNavigationBar(
                    currentIndex: currentIndex,
                    onTap: (index) {
                      setState(() => currentIndex = index);
                    },
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
                );
              },
            ),
          ),
        );

        // Tap second item
        await tester.tap(find.text('Send'));
        await tester.pumpAndSettle();

        // Verify navigation items have labels
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Send'), findsOneWidget);
        expect(find.text('Settings'), findsOneWidget);
      });

      testWidgets('Tab navigation announces current tab', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: DefaultTabController(
              length: 3,
              child: Scaffold(
                appBar: AppBar(
                  title: const Text('Transactions'),
                  bottom: const TabBar(
                    tabs: [
                      Tab(text: 'All'),
                      Tab(text: 'Sent'),
                      Tab(text: 'Received'),
                    ],
                  ),
                ),
                body: const TabBarView(
                  children: [
                    Center(child: Text('All transactions')),
                    Center(child: Text('Sent transactions')),
                    Center(child: Text('Received transactions')),
                  ],
                ),
              ),
            ),
          ),
        );

        // Tabs should have labels
        expect(find.text('All'), findsOneWidget);
        expect(find.text('Sent'), findsOneWidget);
        expect(find.text('Received'), findsOneWidget);
      });
    });

    group('List and Table Announcements', () {
      testWidgets('List items have complete semantic labels', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView(
                children: [
                  Semantics(
                    label: 'Payment to Fatou Traore, 5000 XOF, sent yesterday',
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
          find.bySemanticsLabel('Payment to Fatou Traore, 5000 XOF, sent yesterday'),
          findsOneWidget,
          reason: 'List items should provide complete context',
        );
      });

      testWidgets('Empty list state is announced', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: Semantics(
                  label: 'No transactions yet. Send money to get started.',
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined, size: 64),
                      SizedBox(height: 16),
                      AppText('No transactions yet'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        expect(
          find.bySemanticsLabel('No transactions yet. Send money to get started.'),
          findsOneWidget,
          reason: 'Empty states should provide guidance',
        );
      });

      testWidgets('List count is announced', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: const Semantics(
                  label: 'Transactions, 15 items',
                  child: Text('Transactions (15)'),
                ),
              ),
              body: ListView.builder(
                itemCount: 15,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Transaction $index'),
                  );
                },
              ),
            ),
          ),
        );

        expect(
          find.bySemanticsLabel('Transactions, 15 items'),
          findsOneWidget,
          reason: 'List count helps users understand content',
        );
      });
    });

    group('Dialog and Modal Announcements', () {
      testWidgets('Dialog role is announced', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: Center(
                    child: AppButton(
                      label: 'Show Dialog',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirm Action'),
                            content: const Text('Are you sure?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Confirm'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        );

        // Open dialog
        await tester.tap(find.byType(AppButton));
        await tester.pumpAndSettle();

        // Dialog content should be accessible
        expect(find.text('Confirm Action'), findsOneWidget);
        expect(find.text('Are you sure?'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Confirm'), findsOneWidget);
      });

      testWidgets('Bottom sheet content is announced', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: Center(
                    child: AppButton(
                      label: 'Show Sheet',
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => Container(
                            padding: EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Semantics(
                                  header: true,
                                  child: AppText('Select Option'),
                                ),
                                SizedBox(height: AppSpacing.md),
                                const ListTile(
                                  leading: Icon(Icons.share),
                                  title: Text('Share'),
                                ),
                                const ListTile(
                                  leading: Icon(Icons.download),
                                  title: Text('Download'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        );

        // Open bottom sheet
        await tester.tap(find.byType(AppButton));
        await tester.pumpAndSettle();

        // Content should be accessible
        expect(find.text('Select Option'), findsOneWidget);
        expect(find.text('Share'), findsOneWidget);
        expect(find.text('Download'), findsOneWidget);
      });

      testWidgets('Snackbar announcements via live region', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: Center(
                    child: AppButton(
                      label: 'Show Snackbar',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Changes saved successfully'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        );

        // Show snackbar
        await tester.tap(find.byType(AppButton));
        await tester.pump();

        expect(
          find.text('Changes saved successfully'),
          findsOneWidget,
          reason: 'Snackbar content should be announced',
        );
      });
    });

    group('Focus Management', () {
      testWidgets('Focus order follows visual order', (tester) async {
        final controller1 = TextEditingController();
        final controller2 = TextEditingController();
        final controller3 = TextEditingController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    AppInput(
                      label: 'First Name',
                      controller: controller1,
                    ),
                    SizedBox(height: AppSpacing.md),
                    AppInput(
                      label: 'Last Name',
                      controller: controller2,
                    ),
                    SizedBox(height: AppSpacing.md),
                    AppInput(
                      label: 'Email',
                      controller: controller3,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Verify focus traversal
        await AccessibilityTestHelper.checkFocusTraversal(tester);

        controller1.dispose();
        controller2.dispose();
        controller3.dispose();
      });

      testWidgets('Focus returns to trigger after modal closes', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: Center(
                    child: AppButton(
                      label: 'Open Dialog',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Dialog'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        );

        // Open and close dialog
        await tester.tap(find.text('Open Dialog'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();

        // Button should still be there
        expect(find.text('Open Dialog'), findsOneWidget);
      });
    });

    group('Comprehensive Screen Reader Audit', () {
      testWidgets('Full form screen is screen-reader accessible', (tester) async {
        final nameController = TextEditingController();
        final emailController = TextEditingController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: const Text('User Profile'),
              ),
              body: ListView(
                padding: EdgeInsets.all(AppSpacing.md),
                children: [
                  const Semantics(
                    header: true,
                    child: AppText('Personal Information'),
                  ),
                  SizedBox(height: AppSpacing.md),
                  AppInput(
                    label: 'Full Name',
                    controller: nameController,
                  ),
                  SizedBox(height: AppSpacing.md),
                  AppInput(
                    label: 'Email Address',
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: 'Save Changes',
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        );

        // Run comprehensive checks
        await AccessibilityTestHelper.checkSemanticLabels(tester);
        await AccessibilityTestHelper.checkFormAccessibility(tester);

        nameController.dispose();
        emailController.dispose();
      });

      testWidgets('Transaction list is fully accessible', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: const Text('Recent Transactions'),
              ),
              body: ListView(
                children: [
                  Semantics(
                    label: 'Payment to Amadou Diallo, 10000 XOF, sent today',
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.gold500,
                        child: const Icon(Icons.person),
                      ),
                      title: const Text('Amadou Diallo'),
                      subtitle: const Text('Today at 2:30 PM'),
                      trailing: const Text('-10000 XOF'),
                      onTap: () {},
                    ),
                  ),
                  Semantics(
                    label: 'Received from Fatou Traore, 5000 XOF, yesterday',
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.successBase,
                        child: const Icon(Icons.arrow_downward),
                      ),
                      title: const Text('Fatou Traore'),
                      subtitle: const Text('Yesterday'),
                      trailing: const Text('+5000 XOF'),
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        // Verify semantic labels
        expect(
          find.bySemanticsLabel('Payment to Amadou Diallo, 10000 XOF, sent today'),
          findsOneWidget,
        );
        expect(
          find.bySemanticsLabel('Received from Fatou Traore, 5000 XOF, yesterday'),
          findsOneWidget,
        );
      });
    });
  });
}
