# Widget Tests

Comprehensive widget tests for the JoonaPay USDC Wallet mobile app.

## Overview

This directory contains **50+ widget tests** covering:
- Primitive components (buttons, inputs, cards, selects)
- Authentication flows (login, OTP, PIN entry)
- Wallet screens (home, balance, transactions)
- Send money flows (recipient selection, amount input, confirmation)
- Settings screens (security, profile, preferences)
- Golden tests for visual regression

## Structure

```
test/widgets/
├── primitives/          # Design system components
│   ├── app_button_test.dart
│   ├── app_text_test.dart
│   ├── app_input_test.dart
│   ├── app_card_test.dart
│   └── app_select_test.dart
├── auth/                # Authentication flows
│   ├── login_view_test.dart
│   ├── otp_view_test.dart
│   └── pin_entry_test.dart
├── wallet/              # Wallet screens
│   ├── wallet_home_test.dart
│   ├── balance_card_test.dart
│   └── transaction_list_test.dart
├── send/                # Send money flows
│   ├── recipient_selector_test.dart
│   ├── amount_input_test.dart
│   └── confirmation_view_test.dart
├── settings/            # Settings screens
│   ├── settings_view_test.dart
│   ├── security_view_test.dart
│   └── biometric_settings_test.dart
└── golden/              # Visual regression tests
    └── app_button_golden_test.dart
```

## Running Tests

### Run all widget tests
```bash
flutter test test/widgets/
```

### Run specific test file
```bash
flutter test test/widgets/primitives/app_button_test.dart
```

### Run with coverage
```bash
flutter test --coverage test/widgets/
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Update golden files
```bash
flutter test --update-goldens test/widgets/golden/
```

## Test Helpers

### TestWrapper
Provides theme, localization, and Riverpod provider scope for widget tests.

```dart
await tester.pumpWidget(
  TestWrapper(
    child: MyWidget(),
  ),
);
```

### TestNavigationWrapper
Includes navigation observer for route testing.

```dart
final observer = MockNavigatorObserver();
await tester.pumpWidget(
  TestNavigationWrapper(
    navigatorObserver: observer,
    child: MyWidget(),
  ),
);
```

### Provider Overrides
Override providers for isolated testing:

```dart
await tester.pumpWidget(
  TestWrapper(
    overrides: [
      authProvider.overrideWith(() => mockAuthNotifier),
    ],
    child: LoginView(),
  ),
);
```

## Test Coverage

### Primitives (100+ tests)
- **AppButton**: All variants, sizes, states, accessibility
- **AppText**: All text styles, variants, overflow handling
- **AppInput**: All input types, validation, formatters, focus
- **AppCard**: All variants, tap handling, decoration
- **AppSelect**: Dropdown behavior, item selection, keyboard navigation

### Authentication (40+ tests)
- **LoginView**: Phone input, country selection, validation, errors
- **OtpView**: OTP entry, auto-submit, resend, timer
- **PinEntry**: PIN creation, confirmation, security, validation

### Wallet (30+ tests)
- **WalletHome**: Balance display, quick actions, transactions, refresh
- **BalanceCard**: Balance visibility toggle, formatting, animations
- **TransactionList**: Empty state, loading, pagination, filtering

### Send Money (25+ tests)
- **RecipientSelector**: Search, selection, recent contacts
- **AmountInput**: Decimal validation, min/max, balance check, formatting
- **ConfirmationView**: Details display, PIN verification, submission

### Settings (20+ tests)
- **SettingsView**: Navigation, preferences, account info
- **SecurityView**: PIN change, biometric toggle, session timeout
- **BiometricSettings**: Availability check, enrollment, error handling

## Testing Patterns

### Widget Rendering
```dart
testWidgets('renders widget', (tester) async {
  await tester.pumpWidget(TestWrapper(child: MyWidget()));
  expect(find.byType(MyWidget), findsOneWidget);
});
```

### User Interaction
```dart
testWidgets('responds to tap', (tester) async {
  var tapped = false;
  await tester.pumpWidget(
    TestWrapper(
      child: AppButton(
        label: 'Tap Me',
        onPressed: () => tapped = true,
      ),
    ),
  );

  await tester.tap(find.byType(AppButton));
  await tester.pumpAndSettle();

  expect(tapped, isTrue);
});
```

### Text Input
```dart
testWidgets('accepts input', (tester) async {
  final controller = TextEditingController();
  await tester.pumpWidget(
    TestWrapper(child: AppInput(controller: controller)),
  );

  await tester.enterText(find.byType(TextFormField), 'Hello');
  expect(controller.text, 'Hello');

  controller.dispose();
});
```

### Form Validation
```dart
testWidgets('validates form', (tester) async {
  final formKey = GlobalKey<FormState>();
  await tester.pumpWidget(
    TestWrapper(
      child: Form(
        key: formKey,
        child: AppInput(
          validator: (v) => v?.isEmpty == true ? 'Required' : null,
        ),
      ),
    ),
  );

  expect(formKey.currentState!.validate(), isFalse);
  expect(find.text('Required'), findsOneWidget);
});
```

### Provider State
```dart
testWidgets('watches provider state', (tester) async {
  final mockNotifier = MockNotifier();
  when(() => mockNotifier.build()).thenReturn(MyState.initial());

  await tester.pumpWidget(
    TestWrapper(
      overrides: [
        myProvider.overrideWith(() => mockNotifier),
      ],
      child: MyWidget(),
    ),
  );

  // Verify widget responds to state
});
```

### Navigation
```dart
testWidgets('navigates on action', (tester) async {
  await tester.pumpWidget(TestNavigationWrapper(child: MyWidget()));

  await tester.tap(find.text('Next'));
  await tester.pumpAndSettle();

  expect(find.byType(NextScreen), findsOneWidget);
});
```

### Accessibility
```dart
testWidgets('has semantic labels', (tester) async {
  await tester.pumpWidget(
    TestWrapper(
      child: AppButton(
        label: 'Submit',
        semanticLabel: 'Submit form',
      ),
    ),
  );

  final semantics = tester.getSemantics(find.byType(Semantics).first);
  expect(semantics.label, contains('Submit form'));
  expect(semantics.hasFlag(SemanticsFlag.isButton), isTrue);
});
```

## Edge Cases Tested

✅ Empty states
✅ Loading states
✅ Error states
✅ Long text overflow
✅ Rapid user interactions
✅ Invalid input
✅ Network failures
✅ Permission denials
✅ Form validation
✅ Navigation edge cases

## Accessibility Checks

✅ Semantic labels
✅ Button roles
✅ Text field announcements
✅ Error announcements
✅ Loading state announcements
✅ Disabled state indication
✅ Focus management

## Performance Considerations

- Use `setUp()` and `tearDown()` to clean up resources
- Dispose controllers after tests
- Use `pumpAndSettle()` for animations
- Mock expensive operations
- Batch related tests in groups

## Golden Tests

Golden tests create reference images for visual regression testing.

### Generate goldens
```bash
flutter test --update-goldens test/widgets/golden/
```

### Compare against goldens
```bash
flutter test test/widgets/golden/
```

Golden files are stored in `test/widgets/golden/goldens/` and should be committed to version control.

## Best Practices

1. **Test behavior, not implementation** - Focus on user-facing behavior
2. **Use descriptive test names** - `testWidgets('shows error when input is invalid')`
3. **Test one thing at a time** - Keep tests focused
4. **Use test helpers** - DRY principle with TestWrapper
5. **Mock external dependencies** - Isolate widget under test
6. **Test accessibility** - Ensure semantic labels exist
7. **Test edge cases** - Empty, error, loading states
8. **Clean up resources** - Dispose controllers, close streams

## CI/CD Integration

Tests run automatically on:
- Pull request creation
- Push to main/develop branches
- Pre-release builds

### GitHub Actions Example
```yaml
- name: Run widget tests
  run: flutter test test/widgets/ --coverage

- name: Upload coverage
  uses: codecov/codecov-action@v3
  with:
    files: coverage/lcov.info
```

## Troubleshooting

### Test fails with "No MediaQuery ancestor"
Wrap widget with `TestWrapper` which provides MaterialApp.

### Test fails with "No Localizations"
`TestWrapper` includes localization delegates.

### Golden test failures
Run `flutter test --update-goldens` to regenerate reference images.

### Provider not found
Add provider override in `TestWrapper.overrides`.

### Async test hangs
Ensure all futures complete and use `await tester.pumpAndSettle()`.

## Contributing

When adding new widgets:
1. Create corresponding test file in appropriate directory
2. Test all variants and states
3. Include accessibility tests
4. Add edge case tests
5. Consider golden tests for visual components
6. Update this README if adding new patterns

## Resources

- [Flutter Testing Docs](https://docs.flutter.dev/testing)
- [Widget Testing Best Practices](https://docs.flutter.dev/testing/overview#widget-tests)
- [Mocktail Package](https://pub.dev/packages/mocktail)
- [Golden Toolkit](https://pub.dev/packages/golden_toolkit)
