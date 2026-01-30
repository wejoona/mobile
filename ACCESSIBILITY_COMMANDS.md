# Accessibility Commands Quick Reference

> Common commands for accessibility testing and validation

## Quick Start

```bash
# Run full accessibility check
./scripts/check_accessibility.sh

# Run all accessibility tests
flutter test test/accessibility/

# Run specific test file
flutter test test/accessibility/button_accessibility_test.dart
```

---

## Testing Commands

### Run All Tests

```bash
# All accessibility tests
flutter test test/accessibility/

# With coverage
flutter test test/accessibility/ --coverage

# Generate HTML coverage report
flutter test test/accessibility/ --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Run Specific Tests

```bash
# Button tests only
flutter test test/accessibility/button_accessibility_test.dart

# Input tests only
flutter test test/accessibility/input_accessibility_test.dart

# Tests matching name
flutter test test/accessibility/ --name "semantic label"
flutter test test/accessibility/ --name "contrast"
flutter test test/accessibility/ --name "touch target"
```

### Test with Different Settings

```bash
# Enable semantics debugger
flutter run --enable-asserts --debug

# Run on specific device
flutter test --device-id=<device-id>

# Verbose output
flutter test test/accessibility/ --verbose
```

---

## Analysis Commands

### Code Analysis

```bash
# Run analyzer
flutter analyze

# With fatal warnings
flutter analyze --fatal-warnings

# Specific directory
flutter analyze lib/design/components/
```

### Find Potential Issues

```bash
# Find unlabeled interactive widgets
grep -r "GestureDetector\|InkWell" lib/ | grep -v "Semantics" | grep -v ".g.dart"

# Find images without alt text
grep -r "Image\." lib/ | grep -v "Semantics\|ExcludeSemantics" | grep -v ".g.dart"

# Find fixed heights (anti-pattern for scaling)
grep -r "height: [0-9]" lib/ | grep -v "minHeight" | grep -v ".g.dart"

# Find custom colors (should use design tokens)
grep -r "Color(0x" lib/ | grep -v "AppColors" | grep -v ".g.dart"
```

---

## Manual Testing Commands

### Screen Reader Testing

**Android (TalkBack)**

```bash
# Enable TalkBack via adb
adb shell settings put secure enabled_accessibility_services com.google.android.marvin.talkback/.TalkBackService

# Disable TalkBack
adb shell settings put secure enabled_accessibility_services ""
```

**iOS (VoiceOver)**

```bash
# Can't control via command line
# Use Settings > Accessibility > VoiceOver
# Or triple-click Home/Side button if configured
```

### Text Scaling Testing

**Android**

```bash
# Set font scale to 2.0 (200%)
adb shell settings put system font_scale 2.0

# Reset to default
adb shell settings put system font_scale 1.0
```

**iOS**

```bash
# Use Settings > Accessibility > Display & Text Size > Larger Text
# Or iOS Simulator: Settings > Accessibility > Larger Text
```

### Reduced Motion Testing

**Android**

```bash
# Enable reduced motion (requires API 17+)
adb shell settings put secure transition_animation_scale 0
adb shell settings put secure window_animation_scale 0
adb shell settings put secure animator_duration_scale 0

# Reset animations
adb shell settings put secure transition_animation_scale 1
adb shell settings put secure window_animation_scale 1
adb shell settings put secure animator_duration_scale 1
```

**iOS**

```bash
# Use Settings > Accessibility > Motion > Reduce Motion
```

---

## Development Commands

### Generate Localization

```bash
# After adding accessibility strings
flutter gen-l10n
```

### Format Code

```bash
# Format all files
flutter format .

# Format specific directory
flutter format lib/design/components/
```

### Clean Build

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

---

## CI/CD Commands

### Pre-commit Checks

```bash
# Run before committing
flutter analyze --fatal-warnings
flutter test test/accessibility/
flutter format --set-exit-if-changed .
```

### Full Validation

```bash
# Complete accessibility validation
./scripts/check_accessibility.sh
```

---

## Debugging Commands

### Enable Semantics Debugger

**At Runtime**

```bash
# Run with semantics debugger
flutter run --debug

# Then in app, press 'S' to toggle semantics debugger
```

**In Code**

```dart
// In main.dart or specific widget
MaterialApp(
  showSemanticsDebugger: true, // Enable globally
  // or
  debugShowMaterialGrid: true,
  // ...
)
```

### Inspect Semantics Tree

```bash
# Flutter DevTools
flutter pub global activate devtools
flutter pub global run devtools

# Then open DevTools and go to Inspector > Show Semantics Tree
```

### Check Accessibility Features

**Android**

```bash
# Check accessibility services status
adb shell settings get secure enabled_accessibility_services

# Check font scale
adb shell settings get system font_scale

# Check animation scales
adb shell settings get global transition_animation_scale
adb shell settings get global window_animation_scale
adb shell settings get global animator_duration_scale
```

**iOS**

```bash
# Use Xcode Accessibility Inspector
# Xcode > Open Developer Tool > Accessibility Inspector
```

---

## Documentation Commands

### View Documentation

```bash
# Main compliance doc
open ACCESSIBILITY_COMPLIANCE.md

# Quick start guide
open docs/ACCESSIBILITY_QUICK_START.md

# Screen reader testing
open docs/SCREEN_READER_TESTING.md

# Dynamic type guide
open docs/DYNAMIC_TYPE_GUIDE.md
```

### Generate Docs

```bash
# Generate API documentation
flutter pub global activate dartdoc
dartdoc

# Open generated docs
open doc/api/index.html
```

---

## Reporting Commands

### Generate Test Report

```bash
# JSON report
flutter test test/accessibility/ --reporter=json > accessibility_report.json

# Compact report
flutter test test/accessibility/ --reporter=compact

# Expanded report
flutter test test/accessibility/ --reporter=expanded
```

### Coverage Report

```bash
# Generate coverage
flutter test test/accessibility/ --coverage

# Convert to HTML
genhtml coverage/lcov.info -o coverage/html

# View in browser
open coverage/html/index.html
```

### Contrast Report

```bash
# Run only contrast tests
flutter test test/accessibility/ --name "contrast" --reporter=expanded
```

---

## Batch Operations

### Test All Components

```bash
# Test all buttons
flutter test test/accessibility/ --name "Button"

# Test all inputs
flutter test test/accessibility/ --name "Input"

# Test all cards
flutter test test/accessibility/ --name "Card"
```

### Check All Screens

```bash
# Create script to test each screen
for screen in lib/features/*/views/*_view.dart; do
  echo "Testing: $screen"
  flutter test --name "$(basename $screen .dart)"
done
```

---

## Useful Aliases

Add to your `.bashrc` or `.zshrc`:

```bash
# Accessibility test aliases
alias a11y-test='flutter test test/accessibility/'
alias a11y-check='./scripts/check_accessibility.sh'
alias a11y-cov='flutter test test/accessibility/ --coverage && genhtml coverage/lcov.info -o coverage/html && open coverage/html/index.html'
alias a11y-debug='flutter run --enable-asserts --debug'

# Quick checks
alias check-labels='grep -r "GestureDetector\|InkWell" lib/ | grep -v "Semantics"'
alias check-images='grep -r "Image\." lib/ | grep -v "Semantics\|ExcludeSemantics"'
alias check-heights='grep -r "height: [0-9]" lib/ | grep -v "minHeight"'
```

---

## Integration with IDEs

### VS Code

**tasks.json**

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Accessibility Tests",
      "type": "shell",
      "command": "flutter test test/accessibility/",
      "problemMatcher": []
    },
    {
      "label": "Accessibility Check",
      "type": "shell",
      "command": "./scripts/check_accessibility.sh",
      "problemMatcher": []
    }
  ]
}
```

**launch.json**

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter (Semantics Debug)",
      "request": "launch",
      "type": "dart",
      "args": ["--enable-asserts", "--debug"]
    }
  ]
}
```

### Android Studio / IntelliJ

1. Run > Edit Configurations
2. Add new Flutter Test configuration
3. Set test scope to: `test/accessibility/`
4. Add to toolbar for quick access

---

## Quick Reference Card

```
┌─────────────────────────────────────────────┐
│  Accessibility Commands Cheat Sheet         │
├─────────────────────────────────────────────┤
│                                             │
│  Test:                                      │
│    flutter test test/accessibility/         │
│                                             │
│  Check:                                     │
│    ./scripts/check_accessibility.sh         │
│                                             │
│  Debug:                                     │
│    flutter run --debug (then press 'S')     │
│                                             │
│  Coverage:                                  │
│    flutter test test/accessibility/ --coverage │
│                                             │
│  Analyze:                                   │
│    flutter analyze --fatal-warnings         │
│                                             │
│  Docs:                                      │
│    open docs/ACCESSIBILITY_QUICK_START.md   │
│                                             │
└─────────────────────────────────────────────┘
```

---

## Troubleshooting

### Tests Fail with "Semantics not enabled"

```bash
# Ensure test uses proper MaterialApp wrapper
# Add to test:
await tester.pumpWidget(
  MaterialApp(
    home: Scaffold(
      body: MyWidget(),
    ),
  ),
);
```

### Coverage Not Generating

```bash
# Clean and regenerate
flutter clean
flutter pub get
flutter test test/accessibility/ --coverage
```

### Analyzer Warnings

```bash
# Fix auto-fixable issues
dart fix --apply

# Then review remaining issues
flutter analyze
```

---

## External Tools

### Accessibility Scanner (Android)

```bash
# Install from Play Store
adb install -r AccessibilityScanner.apk

# Or download from:
# https://play.google.com/store/apps/details?id=com.google.android.apps.accessibility.auditor
```

### Contrast Checker (Web)

```bash
# WebAIM Contrast Checker
open https://webaim.org/resources/contrastchecker/

# Or use browser extension
# Chrome: "WCAG Color Contrast Checker"
```

---

**Last Updated:** 2026-01-29

**See Also:**
- [ACCESSIBILITY_COMPLIANCE.md](./ACCESSIBILITY_COMPLIANCE.md)
- [ACCESSIBILITY_QUICK_START.md](./docs/ACCESSIBILITY_QUICK_START.md)
- [test/accessibility/README.md](./test/accessibility/README.md)
