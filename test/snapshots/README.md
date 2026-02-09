# Golden/Snapshot Tests

Comprehensive golden file tests for visual regression testing of major UI components.

## Overview

Golden tests (also called snapshot tests) capture the visual output of widgets and compare them against reference images. They help prevent unintended visual changes and ensure consistency across the app.

## Test Files

### Primitive Components
- **app_button_snapshot_test.dart** - All button variants, sizes, states, and combinations
- **app_card_snapshot_test.dart** - Card variants, padding, borders, and content variations
- **app_input_snapshot_test.dart** - Input variants, states, icons, and special widgets (PhoneInput)
- **app_select_snapshot_test.dart** - Select/dropdown states, items with icons/subtitles

### Composed Components
- **balance_card_snapshot_test.dart** - Wallet balance display with various amounts and change indicators
- **transaction_item_snapshot_test.dart** - Transaction list items for different transaction types and states

## Running Tests

### Run all snapshot tests
```bash
flutter test test/snapshots/
```

### Run specific test file
```bash
flutter test test/snapshots/app_button_snapshot_test.dart
```

### Update golden files (after intentional UI changes)
```bash
flutter test --update-goldens test/snapshots/
```

### Update specific golden file
```bash
flutter test --update-goldens test/snapshots/app_button_snapshot_test.dart
```

## Golden File Structure

Golden files are stored in the following structure:
```
test/snapshots/goldens/
├── button/
│   ├── primary.png
│   ├── secondary.png
│   ├── loading.png
│   └── ...
├── card/
│   ├── elevated.png
│   ├── gold_accent.png
│   └── ...
├── input/
│   ├── standard_idle.png
│   ├── focused.png
│   └── ...
└── ...
```

## Test Coverage

### AppButton (33 tests)
- ✓ All 5 variants (primary, secondary, ghost, success, danger)
- ✓ All 3 sizes (small, medium, large)
- ✓ States (disabled, loading)
- ✓ Icons (left, right, small)
- ✓ Width (full, auto)
- ✓ Combined states
- ✓ Text overflow

### AppCard (15 tests)
- ✓ All 4 variants (elevated, goldAccent, subtle, glass)
- ✓ Padding variations (default, custom, none)
- ✓ Border radius (default, custom)
- ✓ Interactive (tappable)
- ✓ Content variations (icons, dividers)
- ✓ Margin

### AppInput (28 tests)
- ✓ All 5 variants (standard, phone, pin, amount, search)
- ✓ States (idle, focused, filled, error, disabled, readonly)
- ✓ Helper text
- ✓ Icons (prefix, suffix, both)
- ✓ Prefix/suffix widgets
- ✓ Multiline
- ✓ Obscure text (passwords)
- ✓ PhoneInput widget (3 states)
- ✓ No label

### AppSelect (11 tests)
- ✓ States (idle, selected, disabled, error)
- ✓ Helper text
- ✓ Icons (prefix, item icons)
- ✓ Subtitles
- ✓ Disabled items
- ✓ Currency selection example
- ✓ Without checkmark

### BalanceCard (21 tests)
- ✓ Basic states (default, loading, zero)
- ✓ Balance amounts (small, medium, large, very large)
- ✓ Change indicators (positive, negative, zero, large, small)
- ✓ Different currencies (USD, XOF, EUR)
- ✓ Action buttons (deposit, withdraw, both, none)
- ✓ Edge cases (many decimals, very small)
- ✓ Responsive layouts

### TransactionItem (18 tests)
- ✓ Transaction types (deposit, withdrawal, transfer sent/received, bill payment, airtime)
- ✓ Status (pending, failed, processing, completed)
- ✓ Text overflow (long names, descriptions)
- ✓ Large amounts
- ✓ With date
- ✓ Different icons (QR, recurring)

**Total: 126 snapshot tests**

## Best Practices

### When to Update Goldens
Update goldens only when you've made **intentional** visual changes:
- Design system updates (colors, spacing, typography)
- Component refinements
- Bug fixes that change appearance

### When NOT to Update Goldens
Never update goldens to "make tests pass" without understanding why they failed:
- Unexplained visual changes indicate bugs
- Review the diff carefully before updating
- If unsure, ask for review

### Reviewing Golden Changes
Before updating goldens:
1. Run tests to see which failed
2. Check the actual vs expected diff in your IDE or CI
3. Verify the change is intentional
4. Update goldens only for intended changes
5. Commit both test code and golden files together

### CI/CD Integration
Golden tests should run in CI/CD to catch unintended visual regressions:
```yaml
- name: Run Golden Tests
  run: flutter test test/snapshots/
```

If goldens need updating in CI:
```yaml
- name: Update Goldens
  run: flutter test --update-goldens test/snapshots/
```

## Debugging Failed Tests

### Visual Comparison
Most IDEs show a visual diff when golden tests fail:
- **VS Code**: Install Flutter extension, click on test failure
- **Android Studio**: Right-click test failure → Show difference

### Manual Comparison
Golden files are PNG images you can open:
```bash
# Expected (reference)
open test/snapshots/goldens/button/primary.png

# Actual (generated during test)
open test/failures/goldens/button/primary.png
```

### Common Failures
1. **Font rendering differences** - Platform-specific font rendering can vary
2. **Pixel density** - Test on consistent device/emulator
3. **Animation frames** - Ensure animations are settled with `await tester.pumpAndSettle()`
4. **Async state** - Wait for async operations before capturing

## Platform Considerations

### Different Platforms
Golden files may differ between platforms (iOS, Android, macOS, Linux, Windows):
- Generate goldens on your CI/CD platform
- Use `flutter_test_config.dart` to customize per-platform
- Consider platform-specific golden directories

### Consistent Environment
For reproducible goldens:
- Use same Flutter version across team
- Run on same platform (preferably CI/CD)
- Use consistent device/emulator settings

## Accessibility Testing

These snapshot tests also serve as visual accessibility checks:
- ✓ Color contrast (visible text on backgrounds)
- ✓ Touch target sizes (buttons, tappable areas)
- ✓ Text scaling (readable at different sizes)
- ✓ Focus indicators (visible focus states)

## Complementary Tests

Golden tests work alongside:
- **Unit tests** - Test logic and state
- **Widget tests** - Test interactions and behavior
- **Integration tests** - Test full user flows
- **Accessibility tests** - Test semantic labels and screen reader support

## Maintenance

### Regular Updates
Review and update goldens regularly:
- After design system changes
- After dependency updates (Flutter SDK, packages)
- After platform updates (iOS, Android versions)

### Cleanup
Remove unused golden files:
```bash
# Find golden files not referenced in tests
grep -r "matchesGoldenFile" test/snapshots/*.dart | \
  sed -E "s/.*'goldens\/(.*)'.*/\1/" | \
  sort > referenced.txt

find test/snapshots/goldens -type f -name "*.png" | \
  sed 's|test/snapshots/goldens/||' | \
  sort > existing.txt

comm -13 referenced.txt existing.txt
```

## Troubleshooting

### Tests Pass Locally, Fail in CI
- Ensure CI uses same Flutter version
- Check platform differences (macOS vs Linux)
- Generate goldens in CI environment

### Flaky Tests
- Animations not settled - add `await tester.pumpAndSettle()`
- Async operations - wait for futures to complete
- Random data - use fixed test data

### Large File Sizes
Golden PNGs can be large:
- Use appropriate widget sizes (not full screen)
- Optimize PNG compression
- Consider separating concerns (test smaller widgets)

## Contributing

When adding new components:
1. Create comprehensive snapshot tests
2. Cover all variants and states
3. Include edge cases
4. Document in this README
5. Generate goldens locally first
6. Verify in CI before merging

## Resources

- [Flutter Golden File Testing](https://docs.flutter.dev/cookbook/testing/integration/introduction#5-golden-file-comparisons)
- [flutter_test package](https://api.flutter.dev/flutter/flutter_test/flutter_test-library.html)
- [Golden Toolkit package](https://pub.dev/packages/golden_toolkit) (for advanced golden testing)
