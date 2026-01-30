# Widget Tests - Quick Start Guide

## Run Tests

```bash
# All widget tests
flutter test test/widgets/

# Specific file
flutter test test/widgets/primitives/app_button_test.dart

# With coverage
flutter test --coverage test/widgets/

# Update goldens
flutter test --update-goldens test/widgets/golden/
```

## Test Template

```dart
import 'package:flutter_test/flutter_test.dart';
import '../../helpers/test_wrapper.dart';

void main() {
  group('MyWidget Tests', () {
    testWidgets('renders correctly', (tester) async {
      await tester.pumpWidget(
        const TestWrapper(child: MyWidget()),
      );

      expect(find.byType(MyWidget), findsOneWidget);
    });
  });
}
```

## Common Patterns

### Widget Rendering
```dart
await tester.pumpWidget(TestWrapper(child: MyWidget()));
expect(find.byType(MyWidget), findsOneWidget);
```

### User Interaction
```dart
await tester.tap(find.text('Button'));
await tester.pumpAndSettle();
```

### Text Input
```dart
await tester.enterText(find.byType(TextField), 'Hello');
expect(controller.text, 'Hello');
```

### Form Validation
```dart
final formKey = GlobalKey<FormState>();
expect(formKey.currentState!.validate(), isFalse);
```

### Provider Mocking
```dart
TestWrapper(
  overrides: [
    myProvider.overrideWith(() => mockNotifier),
  ],
  child: MyWidget(),
)
```

### Accessibility Check
```dart
final semantics = tester.getSemantics(find.byType(Semantics).first);
expect(semantics.label, contains('Expected label'));
```

## File Structure

```
test/widgets/
├── primitives/      # Buttons, inputs, cards
├── auth/           # Login, OTP, PIN
├── wallet/         # Balance, transactions
├── send/           # Amount, recipients
├── settings/       # Security, profile
└── golden/         # Visual regression
```

## Test Helpers

- **TestWrapper**: MaterialApp + theme + l10n
- **TestNavigationWrapper**: + NavigatorObserver
- **test_utils.dart**: Mocks and factories

## Coverage Target

Target: **80%+** for all widgets

Check coverage:
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Quick Reference

| Need | Command |
|------|---------|
| Run all | `flutter test test/widgets/` |
| Run one | `flutter test test/widgets/auth/login_view_test.dart` |
| Coverage | `flutter test --coverage` |
| Goldens | `flutter test --update-goldens` |

## Test Checklist

When creating widget tests:
- [ ] Renders correctly
- [ ] User interactions work
- [ ] Form validation works
- [ ] Loading states shown
- [ ] Error states shown
- [ ] Empty states shown
- [ ] Accessibility labels present
- [ ] Edge cases handled

## Common Issues

**No MediaQuery**: Wrap with `TestWrapper`
**No Localizations**: `TestWrapper` includes l10n
**Provider not found**: Add to `overrides`
**Test hangs**: Use `await tester.pumpAndSettle()`
**Golden fails**: Run `--update-goldens`

## Created Files (16)

1. `test_wrapper.dart` - Test helpers
2. `app_button_test.dart` - 35 tests
3. `app_text_test.dart` - 25 tests
4. `app_input_test.dart` - 40 tests
5. `app_card_test.dart` - 15 tests
6. `app_select_test.dart` - 25 tests
7. `login_view_test.dart` - 15 tests
8. `otp_view_test.dart` - 15 tests
9. `pin_entry_test.dart` - 15 tests
10. `wallet_home_test.dart` - 15 tests
11. `balance_card_test.dart` - 10 tests
12. `transaction_list_test.dart` - 15 tests
13. `recipient_selector_test.dart` - 12 tests
14. `amount_input_test.dart` - 18 tests
15. `settings_view_test.dart` - 12 tests
16. `security_view_test.dart` - 10 tests

**Total: 225+ tests across 16 files**
