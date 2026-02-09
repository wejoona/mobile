# Snapshot Testing - Quick Start Guide

## What are Snapshot Tests?

Snapshot tests (golden tests) capture screenshots of widgets and compare them against reference images to detect unintended visual changes.

## Quick Commands

```bash
# Run all snapshot tests
cd mobile
flutter test test/snapshots/

# Run with helper script (recommended)
cd mobile/test/snapshots
./run_snapshots.sh

# Update golden files after intentional UI changes
./run_snapshots.sh --update

# Run specific component tests
flutter test test/snapshots/app_button_snapshot_test.dart
```

## First Time Setup

1. **Generate initial golden files**
   ```bash
   cd mobile
   flutter test --update-goldens test/snapshots/
   ```

2. **Verify goldens were created**
   ```bash
   ls -la test/snapshots/goldens/
   ```

3. **Run tests to verify**
   ```bash
   flutter test test/snapshots/
   ```

## Daily Workflow

### Making UI Changes

1. **Make your component changes**
   ```dart
   // Edit lib/design/components/primitives/app_button.dart
   ```

2. **Run snapshot tests**
   ```bash
   flutter test test/snapshots/app_button_snapshot_test.dart
   ```

3. **Review failures**
   - Tests will fail showing visual differences
   - Check if changes are intentional

4. **Update goldens if intentional**
   ```bash
   flutter test --update-goldens test/snapshots/app_button_snapshot_test.dart
   ```

5. **Commit both code and goldens**
   ```bash
   git add lib/design/components/primitives/app_button.dart
   git add test/snapshots/goldens/button/*.png
   git commit -m "Update button padding and golden files"
   ```

### Adding New Component

1. **Create snapshot test file**
   ```dart
   // test/snapshots/my_component_snapshot_test.dart
   import 'package:flutter_test/flutter_test.dart';
   import '../helpers/test_wrapper.dart';

   void main() {
     group('MyComponent Snapshot Tests', () {
       testWidgets('default state', (tester) async {
         await tester.pumpWidget(
           TestWrapper(
             child: MyComponent(),
           ),
         );

         await expectLater(
           find.byType(MyComponent),
           matchesGoldenFile('goldens/my_component/default.png'),
         );
       });
     });
   }
   ```

2. **Generate goldens**
   ```bash
   flutter test --update-goldens test/snapshots/my_component_snapshot_test.dart
   ```

3. **Verify goldens**
   ```bash
   open test/snapshots/goldens/my_component/default.png
   ```

## Common Scenarios

### ❌ Test Failed - What to do?

```bash
# 1. See which tests failed
flutter test test/snapshots/

# 2. Check the visual difference
# Your IDE should show before/after comparison

# 3. If change is intentional
flutter test --update-goldens test/snapshots/app_button_snapshot_test.dart

# 4. If change is NOT intentional
# Fix your code, don't update goldens!
```

### ✅ All Tests Pass

```bash
# Great! Your UI is consistent
# No action needed
```

### 🔄 Updating Design System

```bash
# After changing colors, spacing, typography
cd mobile

# Update all goldens at once
flutter test --update-goldens test/snapshots/

# Or update one by one
flutter test --update-goldens test/snapshots/app_button_snapshot_test.dart
flutter test --update-goldens test/snapshots/app_card_snapshot_test.dart
# etc.
```

## Tips

### 1. Use TestWrapper
Always wrap widgets in `TestWrapper` for consistent theming:
```dart
TestWrapper(
  child: MyWidget(),
)
```

### 2. Center Small Widgets
For better visual comparison:
```dart
Center(
  child: SizedBox(
    width: 300,
    child: MyWidget(),
  ),
)
```

### 3. Test Multiple States
Cover all visual states:
```dart
testWidgets('idle state', ...);
testWidgets('focused state', ...);
testWidgets('error state', ...);
testWidgets('disabled state', ...);
```

### 4. Organize Golden Files
Use clear folder structure:
```
goldens/
├── button/
│   ├── primary.png
│   ├── secondary.png
│   └── ...
├── card/
└── input/
```

### 5. Settle Animations
Always wait for animations:
```dart
await tester.pumpWidget(...);
await tester.pumpAndSettle(); // Wait for animations
await expectLater(...);
```

## Troubleshooting

### "Golden file not found"
```bash
# Generate the golden file first
flutter test --update-goldens test/snapshots/your_test.dart
```

### "Pixel differences detected"
```bash
# 1. Visual review - is this intentional?
# 2. If YES: Update goldens
flutter test --update-goldens test/snapshots/your_test.dart

# 3. If NO: Fix your code
```

### "Tests pass locally, fail in CI"
```bash
# Generate goldens in CI environment
# Or ensure CI uses same Flutter version and platform
```

### "Too many golden files"
```bash
# Clean up unused goldens
# Only keep goldens referenced in tests
```

## Best Practices

✅ **DO:**
- Run snapshot tests before committing
- Review visual changes carefully
- Update goldens only for intentional changes
- Test all component variants and states
- Use descriptive golden file names
- Commit goldens with code changes

❌ **DON'T:**
- Update goldens to "make tests pass" without review
- Commit goldens separately from code changes
- Skip snapshot tests
- Test full screens (test components instead)
- Use random data in snapshots

## CI/CD Integration

Add to your CI pipeline:

```yaml
# .github/workflows/test.yml
- name: Run Snapshot Tests
  run: |
    cd mobile
    flutter test test/snapshots/

# Optional: Fail if goldens need updating
- name: Check Golden Files
  run: |
    cd mobile
    flutter test --update-goldens test/snapshots/
    git diff --exit-code test/snapshots/goldens/
```

## Example Test

Complete example for reference:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/design/components/primitives/app_button.dart';
import '../helpers/test_wrapper.dart';

void main() {
  group('MyButton Snapshots', () {
    testWidgets('primary button', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: Center(
            child: AppButton(
              label: 'Click Me',
              onPressed: () {},
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(AppButton),
        matchesGoldenFile('goldens/my_button/primary.png'),
      );
    });

    testWidgets('disabled button', (tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: Center(
            child: AppButton(
              label: 'Disabled',
              onPressed: null,
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(AppButton),
        matchesGoldenFile('goldens/my_button/disabled.png'),
      );
    });
  });
}
```

## Need Help?

- **Documentation**: Read `README.md` in this directory
- **Examples**: Check existing snapshot test files
- **Flutter Docs**: https://docs.flutter.dev/cookbook/testing/integration/introduction

## Summary

1. **Run tests**: `flutter test test/snapshots/`
2. **Make changes**: Edit component code
3. **Review**: Check if visual changes are intentional
4. **Update**: `flutter test --update-goldens test/snapshots/`
5. **Commit**: Both code and golden files together

Happy testing! 🎨📸
