# Dynamic Type & Text Scaling Guide

> WCAG 2.1 AA - 1.4.4 Resize Text

## Overview

This guide covers implementing and testing dynamic type support in JoonaPay Mobile to ensure text can scale up to 200% without loss of functionality.

---

## Table of Contents

1. [Flutter Text Scaling](#flutter-text-scaling)
2. [Implementation Patterns](#implementation-patterns)
3. [Testing Text Scaling](#testing-text-scaling)
4. [Layout Adaptation](#layout-adaptation)
5. [Common Pitfalls](#common-pitfalls)
6. [Accessibility Guidelines](#accessibility-guidelines)

---

## Flutter Text Scaling

### How It Works

Flutter automatically respects system text scaling via `MediaQuery.textScaleFactor`:

```dart
final textScaleFactor = MediaQuery.of(context).textScaleFactor;
// Default: 1.0
// Range: 0.8 - 2.0 (iOS), 0.85 - 2.0 (Android)
```

All `Text` widgets automatically scale unless explicitly disabled:

```dart
// Good - scales automatically
Text('Hello', style: TextStyle(fontSize: 16))

// Bad - disables scaling
Text(
  'Hello',
  textScaleFactor: 1.0, // Don't do this!
  style: TextStyle(fontSize: 16),
)
```

### System Settings

**iOS:**
- Settings > Accessibility > Display & Text Size > Larger Text
- Drag slider to desired size

**Android:**
- Settings > Accessibility > Text and display > Font size
- Select size: Small / Default / Large / Largest

---

## Implementation Patterns

### Typography System

Our `AppTypography` automatically scales:

```dart
// lib/design/tokens/typography.dart
class AppTypography {
  static const headlineLarge = TextStyle(
    fontSize: 32, // Base size - will scale
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  static const bodyMedium = TextStyle(
    fontSize: 16, // Base size - will scale
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
  );
}

// Usage
AppText(
  'Welcome',
  variant: AppTextVariant.headlineLarge,
  // Automatically scales with system setting
)
```

### Responsive Text

For text that needs to adapt to available space:

```dart
// Good - adapts to scale factor
LayoutBuilder(
  builder: (context, constraints) {
    final scale = MediaQuery.of(context).textScaleFactor;

    return AppText(
      'Long text that might wrap',
      maxLines: scale > 1.5 ? 3 : 2, // More lines at large sizes
      overflow: TextOverflow.ellipsis,
    );
  },
)
```

### Fixed-Size Contexts

Some contexts genuinely need clamped text (badges, icons):

```dart
// Acceptable use of clamped text
MediaQuery(
  data: MediaQuery.of(context).copyWith(
    textScaleFactor: 1.0.clamp(0.8, 1.2), // Max 120%
  ),
  child: Text('99+'), // Badge count
)
```

**When to clamp:**
- Badges with counts
- Icon labels (single characters)
- Decorative text in graphics
- System UI chrome

**When NOT to clamp:**
- Body text
- Headings
- Button labels
- Form labels
- Error messages
- Any content text

---

## Testing Text Scaling

### Manual Testing

#### iOS Simulator

1. Open Settings app
2. Accessibility > Display & Text Size > Larger Text
3. Toggle "Larger Accessibility Sizes"
4. Drag slider to maximum
5. Return to app and verify

#### Android Emulator

1. Open Settings
2. Accessibility > Font size
3. Select "Largest"
4. Return to app and verify

### Widget Tests

```dart
testWidgets('Text scales to 200%', (tester) async {
  // Build at normal scale
  await tester.pumpWidget(
    const MaterialApp(home: MyScreen()),
  );

  final normalSize = tester.getSize(find.text('Title'));

  // Build at 200% scale
  await tester.pumpWidget(
    MediaQuery(
      data: const MediaQueryData(textScaleFactor: 2.0),
      child: const MaterialApp(home: MyScreen()),
    ),
  );

  final scaledSize = tester.getSize(find.text('Title'));

  // Verify scaled (at least 1.5x larger to account for constraints)
  expect(scaledSize.height, greaterThan(normalSize.height * 1.5));
});
```

### Integration Tests

```dart
// test_driver/text_scaling_test.dart
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Text Scaling Integration', () {
    late FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      await driver.close();
    });

    test('Login screen at 200% scale', () async {
      // Change scale factor
      await driver.setTextScale(2.0);

      // Navigate to login
      await driver.waitFor(find.byValueKey('login_screen'));

      // Verify elements visible and not clipped
      await driver.waitFor(find.text('Welcome to JoonaPay'));
      await driver.waitFor(find.byValueKey('phone_input'));
      await driver.waitFor(find.byValueKey('continue_button'));

      // Take screenshot
      await driver.screenshot();
    });
  });
}
```

### Automated Checks

```dart
// test/helpers/text_scaling_test_helper.dart
class TextScalingTestHelper {
  static Future<void> testAtAllScales(
    WidgetTester tester,
    Widget widget,
  ) async {
    final scales = [0.85, 1.0, 1.3, 1.5, 2.0];

    for (final scale in scales) {
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(textScaleFactor: scale),
          child: MaterialApp(home: widget),
        ),
      );

      // Verify no overflow
      expect(tester.takeException(), isNull);

      // Verify all text visible
      final texts = find.byType(Text);
      for (final text in texts.evaluate()) {
        final renderObject = text.renderObject as RenderBox?;
        expect(renderObject?.hasVisualOverflow, isFalse,
          reason: 'Text overflow at ${scale}x scale');
      }
    }
  }
}

// Usage
testWidgets('Home screen scales properly', (tester) async {
  await TextScalingTestHelper.testAtAllScales(
    tester,
    const HomeView(),
  );
});
```

---

## Layout Adaptation

### Flexible Layouts

Use flex layouts that adapt to content size:

```dart
// Good - adapts to text size
Column(
  children: [
    AppText('Title', variant: AppTextVariant.headlineMedium),
    const SizedBox(height: AppSpacing.md),
    Flexible(
      child: AppText(
        'Long description...',
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    ),
  ],
)

// Bad - fixed height causes clipping
Column(
  children: [
    SizedBox(
      height: 100, // Will clip at large scales!
      child: AppText('Long description...'),
    ),
  ],
)
```

### Responsive Spacing

Spacing should scale with text:

```dart
// Good - spacing scales proportionally
class AppSpacing {
  static double adaptive(BuildContext context, double base) {
    final scale = MediaQuery.of(context).textScaleFactor;
    return base * scale.clamp(1.0, 1.5); // Cap scaling at 150%
  }
}

// Usage
SizedBox(height: AppSpacing.adaptive(context, 16))
```

### Scrollable Areas

Ensure content can scroll when scaled:

```dart
// Good - always scrollable when needed
SingleChildScrollView(
  child: Column(
    children: [
      // Content that might expand
    ],
  ),
)

// Bad - fixed height without scroll
SizedBox(
  height: 600,
  child: Column(
    children: [
      // Content might overflow!
    ],
  ),
)
```

### Multi-Column Layouts

Adapt columns based on scale factor:

```dart
// Responsive grid
LayoutBuilder(
  builder: (context, constraints) {
    final scale = MediaQuery.of(context).textScaleFactor;
    final crossAxisCount = scale > 1.3 ? 2 : 3; // Fewer columns at large scale

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: scale > 1.3 ? 1.5 : 1.0,
      ),
      itemBuilder: (context, index) => MyCard(),
    );
  },
)
```

### Button Labels

Buttons should expand to fit text:

```dart
// Good - intrinsic sizing
AppButton(
  label: 'Continue to payment', // Expands as needed
  isFullWidth: true, // Or let it size naturally
  onPressed: () {},
)

// Bad - fixed width
SizedBox(
  width: 200, // Might clip at large scale!
  child: AppButton(
    label: 'Continue to payment',
    onPressed: () {},
  ),
)
```

---

## Common Pitfalls

### 1. Fixed Heights

**Problem:**
```dart
Container(
  height: 60, // Fixed height
  child: AppText('This might be multiple lines at 200% scale'),
)
```

**Solution:**
```dart
Container(
  constraints: const BoxConstraints(minHeight: 60), // Minimum, can expand
  child: AppText(
    'This might be multiple lines at 200% scale',
    maxLines: 3,
  ),
)
```

### 2. Assumed Line Count

**Problem:**
```dart
// Assumes text fits on one line
Row(
  children: [
    Icon(Icons.check),
    Text('This label might wrap at large scales'),
  ],
)
```

**Solution:**
```dart
Row(
  crossAxisAlignment: CrossAxisAlignment.start, // Align to top
  children: [
    Icon(Icons.check),
    const SizedBox(width: AppSpacing.sm),
    Expanded(
      child: Text(
        'This label might wrap at large scales',
        maxLines: 2,
      ),
    ),
  ],
)
```

### 3. Overflow in Stack

**Problem:**
```dart
Stack(
  children: [
    Positioned(
      top: 20,
      child: Text('Positioned text'), // Might overflow stack
    ),
  ],
)
```

**Solution:**
```dart
Stack(
  children: [
    Positioned(
      top: 20,
      left: 0,
      right: 0, // Constrain width
      child: Text(
        'Positioned text',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    ),
  ],
)
```

### 4. Clipped Dialogs

**Problem:**
```dart
AlertDialog(
  content: Text('Very long message...'), // Might overflow dialog
)
```

**Solution:**
```dart
AlertDialog(
  content: SingleChildScrollView(
    child: Text('Very long message...'), // Scrollable
  ),
)
```

### 5. Icon-Text Misalignment

**Problem:**
```dart
Row(
  children: [
    Icon(Icons.star, size: 20), // Fixed size
    Text('Label', style: TextStyle(fontSize: 16)), // Scales
  ],
)
```

**Solution:**
```dart
Row(
  children: [
    Icon(Icons.star, size: 20 * textScaleFactor), // Scale with text
    Text('Label', style: TextStyle(fontSize: 16)),
  ],
)

// Or use IconTheme
IconTheme(
  data: IconThemeData(
    size: 20 * MediaQuery.of(context).textScaleFactor,
  ),
  child: Row(
    children: [
      Icon(Icons.star),
      Text('Label'),
    ],
  ),
)
```

---

## Accessibility Guidelines

### WCAG Requirements

**1.4.4 Resize Text (Level AA)**
- Text can be resized up to 200% without:
  - Loss of content
  - Loss of functionality
  - Requiring horizontal scrolling

### Best Practices

1. **Always Use Relative Units**
   - Use `em`, `rem` equivalents (in Flutter, base font sizes)
   - Avoid pixel-perfect layouts

2. **Test at Extremes**
   - Test at 50% (if supported)
   - Test at 200% (required)
   - Test at 300% (nice to have)

3. **Provide Adequate Spacing**
   - Line height: 1.5x minimum
   - Paragraph spacing: 2x font size minimum
   - Letter spacing: 0.12x font size minimum

4. **Enable Line Wrapping**
   - Multi-line text should wrap, not truncate
   - Use `maxLines` wisely (3-5 for descriptions)

5. **Avoid Fixed Dimensions**
   - Use `Flexible`, `Expanded`, `LayoutBuilder`
   - Constrain with `minHeight`/`maxHeight`, not `height`

### Testing Checklist

Per screen, verify at 200% scale:

- [ ] All text is readable (not clipped)
- [ ] No horizontal scrolling required
- [ ] Buttons are still tappable
- [ ] Forms are still usable
- [ ] No content hidden
- [ ] Layout doesn't break
- [ ] Images don't overlap text
- [ ] Navigation is still accessible

---

## Reference Implementation

### Responsive Text Component

```dart
class ResponsiveText extends StatelessWidget {
  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.textAlign,
  });

  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).textScaleFactor;

    // Increase max lines at large scales
    final effectiveMaxLines = maxLines != null
        ? (scale > 1.5 ? (maxLines! * 1.5).ceil() : maxLines)
        : null;

    return Text(
      text,
      style: style,
      maxLines: effectiveMaxLines,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
    );
  }
}
```

### Scale-Aware Container

```dart
class ScaleAwareContainer extends StatelessWidget {
  const ScaleAwareContainer({
    super.key,
    required this.child,
    this.baseHeight,
    this.padding,
  });

  final Widget child;
  final double? baseHeight;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).textScaleFactor;

    return Container(
      constraints: baseHeight != null
          ? BoxConstraints(
              minHeight: baseHeight! * scale.clamp(1.0, 1.5),
            )
          : null,
      padding: padding != null
          ? EdgeInsets.all(
              (padding as EdgeInsets).left * scale.clamp(1.0, 1.3),
            )
          : null,
      child: child,
    );
  }
}
```

---

## Resources

- [Flutter Accessibility - Text Scaling](https://docs.flutter.dev/development/accessibility-and-localization/accessibility#large-fonts)
- [WCAG 2.1 - 1.4.4 Resize Text](https://www.w3.org/WAI/WCAG21/Understanding/resize-text.html)
- [Material Design - Typography Scale](https://material.io/design/typography/the-type-system.html#type-scale)
- [iOS - Dynamic Type](https://developer.apple.com/design/human-interface-guidelines/foundations/typography/#dynamic-type-sizes)
- [Android - Font Size](https://developer.android.com/guide/topics/ui/look-and-feel/fonts-in-xml#font-size)

---

**Last Updated:** 2026-01-29
