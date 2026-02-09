# AppText Component - Theme-Aware Typography

## Overview

The `AppText` component is a theme-aware text widget that automatically adapts colors to light and dark themes. It provides consistent typography across the app with built-in accessibility support.

## Features

- **Theme-Aware Colors**: Automatically adapts text colors to light/dark themes
- **Semantic Colors**: Use semantic color names that change based on theme
- **All Text Variants**: Support for all Material 3 text styles (display, headline, title, body, label)
- **Special Variants**: Balance displays, percentages, card labels, monospace text
- **Accessibility**: Semantic labels and exclude semantics support
- **Custom Overrides**: Override colors, font weight, alignment, etc.

## Basic Usage

```dart
// Simple text with default styling
AppText('Hello World')

// With variant
AppText('Page Title', variant: AppTextVariant.headlineLarge)

// With semantic color
AppText('Error Message', semanticColor: AppTextColor.error)

// Custom color override
AppText('Custom', color: Colors.purple)
```

## Text Variants

### Display Variants
Large, attention-grabbing text using Playfair Display font.

```dart
AppText('72px', variant: AppTextVariant.displayLarge)
AppText('48px', variant: AppTextVariant.displayMedium)
AppText('36px', variant: AppTextVariant.displaySmall)
```

### Headline Variants
Section headings using DM Sans font.

```dart
AppText('Section Heading', variant: AppTextVariant.headlineLarge)   // 32px
AppText('Sub Heading', variant: AppTextVariant.headlineMedium)      // 28px
AppText('Small Heading', variant: AppTextVariant.headlineSmall)     // 24px
```

### Title Variants
Card titles and list item headings.

```dart
AppText('Card Title', variant: AppTextVariant.titleLarge)    // 22px, w600
AppText('List Title', variant: AppTextVariant.titleMedium)   // 18px, w500
AppText('Item Title', variant: AppTextVariant.titleSmall)    // 16px, w500
```

### Body Variants
Main content text (default is bodyMedium).

```dart
AppText('Large body text', variant: AppTextVariant.bodyLarge)   // 16px
AppText('Normal body text', variant: AppTextVariant.bodyMedium) // 14px (default)
AppText('Small body text', variant: AppTextVariant.bodySmall)   // 12px
```

### Label Variants
Form labels, buttons, and metadata.

```dart
AppText('BUTTON', variant: AppTextVariant.labelLarge)   // 14px, w500
AppText('Label', variant: AppTextVariant.labelMedium)   // 12px, w500
AppText('Meta', variant: AppTextVariant.labelSmall)     // 11px, w500
```

### Monospace Variants
Numbers, codes, addresses using JetBrains Mono font.

```dart
AppText('1234567890', variant: AppTextVariant.monoLarge)   // 24px
AppText('ABC-123-XYZ', variant: AppTextVariant.monoMedium) // 16px
AppText('0x1a2b3c', variant: AppTextVariant.monoSmall)     // 12px
```

### Special Variants

```dart
// Balance display (Playfair Display, 42px, w700)
AppText('\$12,345.67', variant: AppTextVariant.balance)

// Percentage change (success color by default)
AppText('+12.5%', variant: AppTextVariant.percentage)

// Card label (13px, w500, secondary color)
AppText('Expiry Date', variant: AppTextVariant.cardLabel)
```

## Semantic Colors

Semantic colors automatically adapt to the current theme (light/dark).

```dart
// Text colors
AppText('High emphasis', semanticColor: AppTextColor.primary)
AppText('Medium emphasis', semanticColor: AppTextColor.secondary)
AppText('Low emphasis', semanticColor: AppTextColor.tertiary)
AppText('Disabled state', semanticColor: AppTextColor.disabled)

// Inverse (for colored backgrounds)
Container(
  color: AppColors.gold500,
  child: AppText('Text on gold', semanticColor: AppTextColor.inverse),
)

// Status colors
AppText('Error occurred', semanticColor: AppTextColor.error)
AppText('Success!', semanticColor: AppTextColor.success)
AppText('Warning!', semanticColor: AppTextColor.warning)
AppText('Information', semanticColor: AppTextColor.info)

// Link color
AppText('Click here', semanticColor: AppTextColor.link)
```

### Semantic Color Mapping

| Semantic Color | Dark Theme | Light Theme |
|----------------|------------|-------------|
| `primary` | `#F5F5F0` (ivory) | `#1A1A1F` (near black) |
| `secondary` | `#9A9A9E` (gray) | `#5A5A5E` (dark gray) |
| `tertiary` | `#6B6B70` (lighter gray) | `#8A8A8E` (medium gray) |
| `disabled` | `#4A4A4E` (dim gray) | `#AAAAAE` (light gray) |
| `inverse` | `#0A0A0C` (obsidian) | `#F5F5F0` (ivory) |
| `error` | `#E57B8D` (light red) | `#8B2942` (dark red) |
| `success` | `#7DD3A8` (light green) | `#1A5C3E` (dark green) |
| `warning` | `#F0C674` (light amber) | `#8A6420` (dark amber) |
| `info` | `#8BB4E0` (light blue) | `#2B4A73` (dark blue) |
| `link` | `#C9A962` (gold) | `#B8943D` (darker gold) |

## Default Colors by Variant

Each variant has a default color based on its semantic meaning:

```dart
// These use textPrimary (high emphasis)
displayLarge, displayMedium, displaySmall
headlineLarge, headlineMedium, headlineSmall
titleLarge, titleMedium, titleSmall
bodyLarge, labelLarge
monoLarge, monoMedium
balance

// These use textSecondary (medium emphasis)
bodyMedium, labelMedium
cardLabel, monoSmall

// These use textTertiary (low emphasis)
bodySmall, labelSmall

// Percentage uses successText
percentage
```

## Custom Styling

```dart
// Custom color
AppText('Purple text', color: Colors.purple)

// Font weight override
AppText('Bold', fontWeight: FontWeight.w700)

// Text alignment
AppText('Centered', textAlign: TextAlign.center)

// Max lines with ellipsis
AppText(
  'Long text that will be truncated...',
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
)

// Combine multiple properties
AppText(
  'Custom styled text',
  variant: AppTextVariant.titleLarge,
  semanticColor: AppTextColor.primary,
  fontWeight: FontWeight.w800,
  textAlign: TextAlign.center,
)
```

## Accessibility

### Semantic Labels

Provide alternative text for screen readers:

```dart
AppText(
  '\$1,234.56',
  semanticLabel: 'Balance: one thousand two hundred thirty four dollars and fifty six cents',
)

AppText(
  '+12.5%',
  variant: AppTextVariant.percentage,
  semanticLabel: 'Increase of twelve point five percent',
)
```

### Exclude from Semantics

Hide decorative text from screen readers:

```dart
AppText(
  '⭐',
  excludeSemantics: true,
)
```

## Theme-Aware Best Practices

### DO ✅

```dart
// Use semantic colors for theme adaptation
AppText('Error', semanticColor: AppTextColor.error)

// Let variants use their default colors
AppText('Title', variant: AppTextVariant.titleLarge)

// Use inverse color on colored backgrounds
Container(
  color: context.isDarkMode ? AppColors.gold500 : AppColorsLight.gold500,
  child: AppText('Text', semanticColor: AppTextColor.inverse),
)
```

### DON'T ❌

```dart
// Don't hardcode theme-specific colors
AppText('Text', color: AppColors.textPrimary) // Won't adapt to light theme

// Don't use context.appColors directly (use semanticColor instead)
AppText('Text', color: context.appColors.textPrimary)

// Don't mix semantic and custom colors inconsistently
AppText('Text', semanticColor: AppTextColor.primary, color: Colors.red) // Custom wins
```

## Migration Guide

### From Old AppText (Hardcoded Colors)

```dart
// OLD - colors won't adapt to theme
AppText('Hello', variant: AppTextVariant.bodyMedium)
// Color was hardcoded in AppTypography

// NEW - colors adapt automatically
AppText('Hello', variant: AppTextVariant.bodyMedium)
// Uses textSecondary from current theme

// Or be explicit
AppText('Hello', semanticColor: AppTextColor.secondary)
```

### From Plain Text Widget

```dart
// OLD
Text(
  'Title',
  style: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Theme.of(context).brightness == Brightness.dark
        ? AppColors.textPrimary
        : AppColorsLight.textPrimary,
  ),
)

// NEW
AppText('Title', variant: AppTextVariant.headlineSmall)
```

## Testing

The component includes comprehensive tests for theme adaptation:

```bash
flutter test test/design/components/app_text_theme_test.dart
```

Tests cover:
- Light/dark theme color adaptation
- All text variants render correctly
- Semantic colors map to correct theme colors
- Custom colors override semantic colors
- Accessibility features work
- Font weight and alignment overrides

## Example App

Run the example to see all variants in action:

```dart
import 'package:usdc_wallet/design/components/primitives/app_text_example.dart';

void main() => runApp(const AppTextExample());
```

The example includes:
- All text variants
- All semantic colors
- Light/dark theme toggle
- Text on colored backgrounds
- Custom styling examples
- Accessibility examples

## Technical Details

### Color Resolution Order

1. `color` parameter (highest priority)
2. `semanticColor` parameter
3. Default color for variant (based on variant type)

### Typography Source

- Display variants: Playfair Display (serif, elegant)
- Body/Label/Title variants: DM Sans (sans-serif, readable)
- Mono variants: JetBrains Mono (monospace, code)

### Theme Integration

AppText reads the current theme using `Theme.of(context)` and:
- Checks `brightness` to determine light/dark mode
- Maps semantic colors to appropriate theme values
- Maintains consistent typography across themes

## Files Modified

- `/lib/design/tokens/typography.dart` - Removed hardcoded colors, added line heights
- `/lib/design/components/primitives/app_text.dart` - Added semantic color support
- `/lib/design/theme/app_theme.dart` - Changed extensions from const to non-const
- `/test/design/components/app_text_theme_test.dart` - Comprehensive theme tests
- `/lib/design/components/primitives/app_text_example.dart` - Visual example app

## Performance Notes

- Theme lookups are optimized by Flutter's build context
- Color calculations happen only during builds
- No runtime color interpolation (discrete light/dark values)
- Typography styles are cached by Google Fonts package
