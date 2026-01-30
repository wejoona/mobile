# Accessibility Tests

Automated accessibility testing for JoonaPay Mobile.

## Overview

This directory contains comprehensive accessibility tests ensuring WCAG 2.1 Level AA compliance.

## Running Tests

### All Accessibility Tests

```bash
flutter test test/accessibility/
```

### Specific Test File

```bash
flutter test test/accessibility/button_accessibility_test.dart
```

### With Coverage

```bash
flutter test test/accessibility/ --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Specific Test Case

```bash
flutter test test/accessibility/button_accessibility_test.dart --name "has proper semantic label"
```

---

## Test Files

### button_accessibility_test.dart

Tests for AppButton component accessibility:

- ✅ Semantic labels (default and custom)
- ✅ Loading state announcements
- ✅ Disabled state announcements
- ✅ Button role/trait
- ✅ Touch target sizes (44x44dp minimum)
- ✅ Contrast ratios (WCAG AA)
- ✅ Icon button accessibility
- ✅ All button variants (primary, secondary, ghost, success, danger)

**22 tests**

### input_accessibility_test.dart

Tests for AppInput component accessibility:

- ✅ Semantic labels (from label prop)
- ✅ Text field role
- ✅ Error state announcements
- ✅ Helper text announcements
- ✅ Read-only state announcements
- ✅ Touch target height (56dp minimum)
- ✅ Contrast ratios
- ✅ Input variants (phone, PIN, amount, search)
- ✅ PhoneInput component

**19 tests**

---

## Test Categories

### Semantic Tests

Verify that all components have proper semantic labels and roles.

```dart
testWidgets('has proper semantic label', (tester) async {
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

  expect(find.bySemanticsLabel('Continue'), findsOneWidget);
});
```

### Touch Target Tests

Verify all interactive elements meet 44x44dp minimum.

```dart
testWidgets('meets minimum touch target size', (tester) async {
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

  final size = tester.getSize(find.byType(AppButton));
  expect(size.height, greaterThanOrEqualTo(44.0));
});
```

### Contrast Tests

Verify color combinations meet WCAG AA standards (4.5:1 for text, 3:1 for UI).

```dart
test('primary button contrast ratio', () {
  AccessibilityTestHelper.verifyContrastRatio(
    AppColors.textInverse,
    AppColors.gold500,
    reason: 'Primary button text must be readable',
  );
});
```

### State Announcement Tests

Verify state changes are announced to screen readers.

```dart
testWidgets('announces loading state', (tester) async {
  await tester.pumpWidget(
    const MaterialApp(
      home: Scaffold(
        body: AppButton(
          label: 'Continue',
          isLoading: true,
        ),
      ),
    ),
  );

  final semantics = tester.getSemantics(find.byType(AppButton));
  expect(semantics.hint, contains('Loading'));
});
```

---

## Using AccessibilityTestHelper

The helper provides utilities for common accessibility checks:

### Full Audit

```dart
testWidgets('Screen is accessible', (tester) async {
  await tester.pumpWidget(const MyApp());

  // Run all checks
  await AccessibilityTestHelper.runFullAudit(tester);
});
```

### Individual Checks

```dart
// Check semantic labels
await AccessibilityTestHelper.checkSemanticLabels(tester);

// Check touch targets
await AccessibilityTestHelper.checkTouchTargets(tester);

// Check contrast (basic)
AccessibilityTestHelper.checkBasicContrast(tester);

// Check focus order
await AccessibilityTestHelper.checkFocusTraversal(tester);

// Check text scaling
await AccessibilityTestHelper.checkTextScaling(tester);
```

### Contrast Ratio Calculation

```dart
// Calculate contrast ratio
final ratio = AccessibilityTestHelper.calculateContrastRatio(
  AppColors.textPrimary,
  AppColors.obsidian,
);

// Verify meets WCAG AA
AccessibilityTestHelper.verifyContrastRatio(
  AppColors.textPrimary,
  AppColors.obsidian,
  reason: 'Text must be readable',
);

// Verify meets WCAG AAA
AccessibilityTestHelper.verifyContrastRatioAAA(
  AppColors.textPrimary,
  AppColors.obsidian,
  isLargeText: false,
);
```

---

## Writing New Tests

### Template

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design/components/primitives/my_component.dart';
import '../helpers/accessibility_test_helper.dart';

void main() {
  group('MyComponent Accessibility Tests', () {
    testWidgets('has proper semantic label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MyComponent(
              label: 'My Label',
            ),
          ),
        ),
      );

      // Check semantic label
      expect(
        find.bySemanticsLabel('My Label'),
        findsOneWidget,
      );
    });

    testWidgets('meets touch target requirements', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MyComponent(),
          ),
        ),
      );

      await AccessibilityTestHelper.checkTouchTargets(tester);
    });

    testWidgets('has proper role', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MyComponent(),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(MyComponent));
      expect(semantics.hasFlag(SemanticsFlag.isButton), isTrue);
    });

    test('meets contrast requirements', () {
      AccessibilityTestHelper.verifyContrastRatio(
        foregroundColor,
        backgroundColor,
        reason: 'Component must be readable',
      );
    });
  });
}
```

### Best Practices

1. **Group Related Tests**
   ```dart
   group('MyComponent Accessibility', () {
     group('Semantic Labels', () { ... });
     group('Touch Targets', () { ... });
     group('Contrast', () { ... });
   });
   ```

2. **Use Descriptive Names**
   ```dart
   testWidgets('announces loading state to screen reader', ...);
   // Better than:
   testWidgets('loading test', ...);
   ```

3. **Test Edge Cases**
   ```dart
   testWidgets('disabled button still meets contrast minimum', ...);
   testWidgets('small button still meets touch target', ...);
   ```

4. **Document WCAG Guidelines**
   ```dart
   // WCAG 2.4.7 - Focus Visible
   testWidgets('has visible focus indicator', ...);
   ```

---

## Continuous Integration

Tests run automatically on:
- Pull requests
- Pushes to main/develop branches

See `.github/workflows/accessibility.yml` for CI configuration.

### CI Checks

1. **Accessibility Tests** - All tests must pass
2. **Contrast Check** - Contrast ratio tests must pass
3. **Semantics Check** - No unlabeled interactive widgets
4. **Touch Target Check** - All touch targets adequate

---

## Coverage Goals

| Category | Target | Current |
|----------|--------|---------|
| Design System Components | 100% | 100% |
| Core Screens | 100% | 40% |
| Form Flows | 100% | 60% |
| Navigation | 100% | 80% |
| **Overall** | **100%** | **70%** |

---

## Adding Tests for New Components

When creating a new component:

1. **Create test file**
   ```bash
   touch test/accessibility/my_component_accessibility_test.dart
   ```

2. **Add basic tests**
   - Semantic label
   - Touch target
   - Contrast
   - Role/trait

3. **Add specific tests**
   - State announcements
   - Error handling
   - Variants

4. **Run tests**
   ```bash
   flutter test test/accessibility/my_component_accessibility_test.dart
   ```

5. **Update coverage**
   - Document in ACCESSIBILITY_COMPLIANCE.md
   - Update this README

---

## Common Issues

### Issue: "Semantics not found"

**Cause:** Component might use `ExcludeSemantics` or not have proper Semantics wrapper.

**Fix:**
```dart
// Wrap in Semantics
Semantics(
  label: 'My label',
  child: MyComponent(),
)
```

### Issue: "Multiple semantics found"

**Cause:** Duplicate semantic nodes.

**Fix:**
```dart
// Use more specific finder
find.bySemanticsLabel(RegExp('Exact label'));
```

### Issue: "Touch target too small"

**Cause:** Component doesn't enforce minimum size.

**Fix:**
```dart
Container(
  constraints: BoxConstraints(minWidth: 44, minHeight: 44),
  child: MyComponent(),
)
```

### Issue: "Contrast ratio fails"

**Cause:** Color combination doesn't meet WCAG standards.

**Fix:**
```dart
// Use design system colors (verified)
AppColors.textPrimary  // 14.7:1 on obsidian
AppColors.textSecondary  // 6.2:1 on obsidian
```

---

## Resources

### Documentation

- [ACCESSIBILITY_COMPLIANCE.md](../../ACCESSIBILITY_COMPLIANCE.md) - Full compliance guide
- [ACCESSIBILITY_QUICK_START.md](../../docs/ACCESSIBILITY_QUICK_START.md) - Developer guide
- [SCREEN_READER_TESTING.md](../../docs/SCREEN_READER_TESTING.md) - Manual testing

### Helpers

- [AccessibilityTestHelper](../helpers/accessibility_test_helper.dart) - Test utilities
- [ReducedMotionHelper](../../lib/utils/reduced_motion_helper.dart) - Motion support

### External

- [Flutter Accessibility Testing](https://docs.flutter.dev/development/accessibility-and-localization/accessibility#testing)
- [WCAG 2.1 Quick Reference](https://www.w3.org/WAI/WCAG21/quickref/)
- [Material Accessibility](https://material.io/design/usability/accessibility.html)

---

## Contributing

### Before Submitting PR

1. Run all accessibility tests
   ```bash
   flutter test test/accessibility/
   ```

2. Add tests for new components

3. Update documentation

4. Test manually with screen reader

### PR Checklist

- [ ] All accessibility tests pass
- [ ] New components have tests
- [ ] Contrast ratios verified
- [ ] Touch targets verified
- [ ] Semantic labels added
- [ ] Documentation updated

---

**Last Updated:** 2026-01-29

**Test Count:** 41 tests

**Coverage:** 70% (target: 100%)
