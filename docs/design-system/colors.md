# Color System

JoonaPay uses a luxury dark-first color palette with gold accents and sophisticated low-saturation colors. The system supports both dark and light modes.

## Philosophy

- **Dark = Premium**: Deep blacks create luxury feel
- **Gold = Achievement**: Premium accent color for CTAs and rewards
- **Low Saturation = Sophistication**: Muted colors avoid overwhelming users
- **70-20-5-5 Rule**: 70% dark backgrounds, 20% text, 5% gold accents, 5% semantic colors

---

## Dark Mode (Primary)

### Foundations (70% of UI)

Background colors that create the canvas for content.

```dart
import 'package:usdc_wallet/design/tokens/colors.dart';

// Darkest to lightest
AppColors.obsidian        // #0A0A0C - Main canvas (deep void)
AppColors.graphite        // #111115 - Elevated surfaces
AppColors.slate           // #1A1A1F - Cards, containers
AppColors.elevated        // #222228 - Hover states, inputs
AppColors.glass           // #1A1A1F with 85% opacity - Glassmorphism

// Aliases for semantic usage
AppColors.backgroundPrimary    // → obsidian
AppColors.backgroundSecondary  // → graphite
AppColors.backgroundTertiary   // → slate
AppColors.backgroundElevated   // → elevated
```

**Usage:**
```dart
// Screen background
Scaffold(
  backgroundColor: AppColors.obsidian,
  body: Container(...),
)

// Card background
Container(
  color: AppColors.slate,
  child: ...,
)

// Input field background
TextField(
  decoration: InputDecoration(
    fillColor: AppColors.elevated,
  ),
)
```

---

### Text Hierarchy (20% of UI)

Text colors with emphasis levels for content hierarchy.

```dart
AppColors.textPrimary    // #F5F5F0 - High emphasis (ivory)
AppColors.textSecondary  // #9A9A9E - Medium emphasis (labels)
AppColors.textTertiary   // #6B6B70 - Low emphasis (hints)
AppColors.textDisabled   // #4A4A4E - Disabled states
AppColors.textInverse    // #0A0A0C - On gold/light backgrounds
```

**Usage:**
```dart
// Primary heading
Text(
  'Balance',
  style: AppTypography.headlineMedium.copyWith(
    color: AppColors.textPrimary,
  ),
)

// Secondary label
Text(
  'Available to withdraw',
  style: AppTypography.bodyMedium.copyWith(
    color: AppColors.textSecondary,
  ),
)

// Hint text
Text(
  'Tap to refresh',
  style: AppTypography.bodySmall.copyWith(
    color: AppColors.textTertiary,
  ),
)
```

---

### Gold Accent System (5% of UI)

Premium gold palette for CTAs, rewards, and highlights.

```dart
AppColors.gold50    // #FDF8E7 - Lightest tint
AppColors.gold100   // #F9EDCC
AppColors.gold200   // #F0D999
AppColors.gold300   // #E5C266
AppColors.gold400   // #D9AE40
AppColors.gold500   // #C9A962 - PRIMARY CTA color
AppColors.gold600   // #B89852 - Pressed state
AppColors.gold700   // #9A7A3D - Borders
AppColors.gold800   // #7A5E2F - Dark accent
AppColors.gold900   // #5C4522 - Subtle gold

// Gradient
AppColors.goldGradient  // [gold500, gold300, gold500]
```

**Usage:**
```dart
// Primary button
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: AppColors.goldGradient,
    ),
  ),
  child: Text(
    'Send Money',
    style: TextStyle(color: AppColors.textInverse),
  ),
)

// Gold accent border
Container(
  decoration: BoxDecoration(
    border: Border.all(color: AppColors.gold500),
  ),
)

// Gold icon
Icon(Icons.star, color: AppColors.gold500)
```

---

### Semantic Colors

Status and feedback colors with base, light, dark, and text variants.

#### Success (Emerald - wealth, growth)
```dart
AppColors.successBase   // #2D6A4F - Base color
AppColors.successLight  // #3D8B6E - Lighter variant
AppColors.successDark   // #1E4D38 - Darker variant
AppColors.successText   // #7DD3A8 - For text on dark

AppColors.success       // Alias → successBase
```

#### Warning (Amber)
```dart
AppColors.warningBase   // #C9943A
AppColors.warningLight  // #DAA84E
AppColors.warningDark   // #A67828
AppColors.warningText   // #F0C674

AppColors.warning       // Alias → warningBase
```

#### Error (Crimson velvet)
```dart
AppColors.errorBase     // #8B2942
AppColors.errorLight    // #A63D4E
AppColors.errorDark     // #6D1F33
AppColors.errorText     // #E57B8D

AppColors.error         // Alias → errorBase
```

#### Info (Steel blue)
```dart
AppColors.infoBase      // #4A6FA5
AppColors.infoLight     // #5B82B8
AppColors.infoDark      // #3A5A89
AppColors.infoText      // #8BB4E0

AppColors.info          // Alias → infoBase
```

**Usage:**
```dart
// Success message
Container(
  color: AppColors.successBase.withOpacity(0.1),
  child: Text(
    'Transaction successful',
    style: TextStyle(color: AppColors.successText),
  ),
)

// Error state
TextField(
  decoration: InputDecoration(
    errorText: 'Invalid amount',
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.errorBase),
    ),
  ),
)
```

---

### Borders & Dividers

Semi-transparent overlays for borders and separators.

```dart
AppColors.borderSubtle       // 6% white opacity
AppColors.borderDefault      // 10% white opacity
AppColors.borderStrong       // 15% white opacity
AppColors.borderGold         // 30% gold opacity
AppColors.borderGoldStrong   // 50% gold opacity

AppColors.border             // Alias → borderDefault
```

**Usage:**
```dart
// Subtle divider
Divider(color: AppColors.borderSubtle)

// Card border
Container(
  decoration: BoxDecoration(
    border: Border.all(color: AppColors.borderDefault),
  ),
)

// Gold accent border
Container(
  decoration: BoxDecoration(
    border: Border.all(color: AppColors.borderGold),
  ),
)
```

---

### Overlays

Semi-transparent layers for modals, tooltips, and scrim.

```dart
AppColors.overlayLight   // 5% white - Subtle hover
AppColors.overlayMedium  // 10% white - Tooltips
AppColors.overlayDark    // 50% black - Disabled overlay
AppColors.overlayScrim   // 80% black - Modal backdrop
```

**Usage:**
```dart
// Modal backdrop
Container(
  color: AppColors.overlayScrim,
  child: Dialog(...),
)

// Hover effect
InkWell(
  splashColor: AppColors.overlayLight,
  onTap: () {},
)
```

---

## Light Mode

Light mode inverts the palette while maintaining luxury aesthetic.

### Foundations
```dart
AppColorsLight.canvas          // #FAFAF8 - Warm white
AppColorsLight.surface         // #F5F5F2 - Elevated
AppColorsLight.container       // #FFFFFF - Cards
AppColorsLight.elevated        // #EDEDEB - Inputs
AppColorsLight.glass           // #FFFFFF with 90% opacity

// Aliases
AppColorsLight.backgroundPrimary
AppColorsLight.backgroundSecondary
AppColorsLight.backgroundTertiary
AppColorsLight.backgroundElevated
```

### Text
```dart
AppColorsLight.textPrimary     // #1A1A1F - Near black
AppColorsLight.textSecondary   // #5A5A5E - Gray
AppColorsLight.textTertiary    // #8A8A8E - Light gray
AppColorsLight.textDisabled    // #AAAAAE - Disabled
AppColorsLight.textInverse     // #F5F5F0 - On dark
```

### Gold (slightly darker for contrast)
```dart
AppColorsLight.gold500         // #B8943D
AppColorsLight.gold600         // #A68535
AppColorsLight.gold700         // #8A6E2B
```

### Semantic (adjusted for light backgrounds)
```dart
// Success
AppColorsLight.successBase     // #1E7D52
AppColorsLight.successLight    // #E8F5ED
AppColorsLight.successText     // #1A5C3E

// Warning
AppColorsLight.warningBase     // #B8862D
AppColorsLight.warningLight    // #FFF5E6
AppColorsLight.warningText     // #8A6420

// Error
AppColorsLight.errorBase       // #B83A4F
AppColorsLight.errorLight      // #FCEBF0
AppColorsLight.errorText       // #8B2942

// Info
AppColorsLight.infoBase        // #3A6399
AppColorsLight.infoLight       // #E8F0F8
AppColorsLight.infoText        // #2B4A73
```

---

## Legacy Aliases

For backwards compatibility:

```dart
AppColors.charcoal  // → graphite
AppColors.silver    // → textSecondary
AppColors.white     // #FFFFFF - Pure white
```

---

## Theme-Aware Usage

Use the `ThemeColors` extension for automatic theme switching:

```dart
final colors = context.colors;

Container(
  color: colors.background,        // Adapts to theme
  child: Text(
    'Hello',
    style: TextStyle(color: colors.textPrimary),
  ),
)
```

---

## Best Practices

### Do's
- Use `AppColors` constants directly
- Use text hierarchy for proper contrast
- Apply gold sparingly (5% rule)
- Use semantic colors for feedback
- Leverage opacity for subtle effects

### Don'ts
- Don't hardcode hex values
- Don't use pure black (#000000)
- Don't overuse gold (loses impact)
- Don't mix semantic colors (e.g., green text on red background)
- Don't use full opacity overlays

---

## Accessibility

All color combinations meet WCAG AA standards:

| Combination | Contrast Ratio | Rating |
|-------------|----------------|--------|
| textPrimary on obsidian | 16.2:1 | AAA |
| textSecondary on obsidian | 8.5:1 | AAA |
| textTertiary on obsidian | 4.8:1 | AA |
| gold500 on obsidian | 6.2:1 | AA+ |
| successText on obsidian | 5.8:1 | AA |
| errorText on obsidian | 5.5:1 | AA |

---

## Related

- [Typography](./typography.md) - Text styles and font families
- [Spacing](./spacing.md) - Spacing and layout tokens
- [Components](./components.md) - Pre-built components using these colors
