# Typography System

JoonaPay uses a three-font system optimized for luxury wallet applications with emphasis on readability and sophistication.

## Font Families

### Display: Playfair Display
Serif font for headlines, balance amounts, and high-impact text.

**Characteristics:**
- High-contrast strokes
- Elegant serifs
- Premium feel
- Used for: Amounts, headlines, hero text

**Font weights:** 600 (SemiBold), 700 (Bold)

---

### Body: DM Sans
Modern sans-serif for body text, labels, and UI elements.

**Characteristics:**
- Clean, geometric
- Excellent readability
- Neutral, professional
- Used for: All UI text, buttons, labels

**Font weights:** 400 (Regular), 500 (Medium), 600 (SemiBold)

---

### Mono: JetBrains Mono
Monospaced font for numbers, codes, and technical text.

**Characteristics:**
- Equal character width
- Coding-optimized
- Enhanced legibility
- Used for: Transaction IDs, PINs, OTPs, amounts in certain contexts

**Font weights:** 400 (Regular), 500 (Medium)

---

## Type Scale

### Display Styles (Playfair Display)

Large headlines, balance amounts, hero text.

```dart
import 'package:usdc_wallet/design/tokens/typography.dart';

AppTypography.displayLarge
// Size: 72px
// Weight: 700 (Bold)
// Letter spacing: -2
// Use: Hero amounts, splash screens

AppTypography.displayMedium
// Size: 48px
// Weight: 700 (Bold)
// Letter spacing: -1.5
// Use: Large headings, balance displays

AppTypography.displaySmall
// Size: 36px
// Weight: 600 (SemiBold)
// Letter spacing: -1
// Use: Section headings, feature titles
```

**Usage:**
```dart
// Main balance display
Text(
  '1,234.56 USDC',
  style: AppTypography.displayMedium,
)

// Hero heading
Text(
  'Welcome to JoonaPay',
  style: AppTypography.displayLarge,
)
```

---

### Headline Styles (DM Sans)

Page titles, card headers, section headings.

```dart
AppTypography.headlineLarge
// Size: 32px
// Weight: 600 (SemiBold)
// Letter spacing: -0.5
// Use: Page titles

AppTypography.headlineMedium
// Size: 28px
// Weight: 600 (SemiBold)
// Letter spacing: -0.25
// Use: Modal titles, feature headings

AppTypography.headlineSmall
// Size: 24px
// Weight: 600 (SemiBold)
// Letter spacing: 0
// Use: Card titles, subsection headings
```

**Usage:**
```dart
// AppBar title
AppBar(
  title: Text(
    'Send Money',
    style: AppTypography.headlineSmall,
  ),
)

// Page heading
Text(
  'Transaction History',
  style: AppTypography.headlineLarge,
)
```

---

### Title Styles (DM Sans)

List item titles, input labels, prominent text.

```dart
AppTypography.titleLarge
// Size: 22px
// Weight: 600 (SemiBold)
// Letter spacing: 0
// Use: Large list items, step titles

AppTypography.titleMedium
// Size: 18px
// Weight: 500 (Medium)
// Letter spacing: 0.15
// Use: List item titles, card headers

AppTypography.titleSmall
// Size: 16px
// Weight: 500 (Medium)
// Letter spacing: 0.1
// Use: Small headers, emphasized text
```

**Usage:**
```dart
// Transaction list item
ListTile(
  title: Text(
    'Amadou Diallo',
    style: AppTypography.titleMedium,
  ),
)

// Step header
Text(
  'Step 1: Enter Amount',
  style: AppTypography.titleLarge,
)
```

---

### Body Styles (DM Sans)

Paragraphs, descriptions, general content.

```dart
AppTypography.bodyLarge
// Size: 16px
// Weight: 400 (Regular)
// Letter spacing: 0.5
// Use: Primary body text, descriptions

AppTypography.bodyMedium
// Size: 14px
// Weight: 400 (Regular)
// Letter spacing: 0.25
// Use: Secondary body text, list items

AppTypography.bodySmall
// Size: 12px
// Weight: 400 (Regular)
// Letter spacing: 0.4
// Color: textSecondary (default)
// Use: Captions, helper text
```

**Usage:**
```dart
// Description paragraph
Text(
  'Send USDC to anyone in West Africa instantly.',
  style: AppTypography.bodyLarge,
)

// Transaction details
Text(
  'Transaction completed successfully',
  style: AppTypography.bodyMedium,
)

// Helper text
Text(
  'Processing may take up to 2 minutes',
  style: AppTypography.bodySmall,
)
```

---

### Label Styles (DM Sans)

Form labels, tags, small UI text.

```dart
AppTypography.labelLarge
// Size: 14px
// Weight: 500 (Medium)
// Letter spacing: 0.1
// Use: Input labels, button text

AppTypography.labelMedium
// Size: 12px
// Weight: 500 (Medium)
// Letter spacing: 0.5
// Color: textSecondary (default)
// Use: Field labels, tags

AppTypography.labelSmall
// Size: 11px
// Weight: 500 (Medium)
// Letter spacing: 0.5
// Color: textTertiary (default)
// Use: Tiny labels, metadata
```

**Usage:**
```dart
// Input label
Text(
  'Phone Number',
  style: AppTypography.labelMedium,
)

// Status tag
Container(
  child: Text(
    'PENDING',
    style: AppTypography.labelSmall,
  ),
)
```

---

### Mono Styles (JetBrains Mono)

Numbers, codes, technical data.

```dart
AppTypography.monoLarge
// Size: 24px
// Weight: 500 (Medium)
// Letter spacing: -0.5
// Use: Large amounts, PIN display

AppTypography.monoMedium
// Size: 16px
// Weight: 400 (Regular)
// Letter spacing: 0
// Use: Transaction IDs, addresses

AppTypography.monoSmall
// Size: 12px
// Weight: 400 (Regular)
// Letter spacing: 0
// Color: textSecondary (default)
// Use: Small codes, timestamps
```

**Usage:**
```dart
// Transaction ID
Text(
  'TX-8B2F4C9E1A3D',
  style: AppTypography.monoMedium,
)

// PIN entry
Text(
  '1234',
  style: AppTypography.monoLarge,
)

// Wallet address
Text(
  '0x742d...9f3e',
  style: AppTypography.monoSmall,
)
```

---

## Special Styles

Pre-configured styles for specific use cases.

```dart
AppTypography.balanceDisplay
// Size: 42px
// Weight: 700 (Bold)
// Family: Playfair Display
// Letter spacing: -1
// Use: Main wallet balance

AppTypography.percentageChange
// Size: 14px
// Weight: 500 (Medium)
// Letter spacing: 0
// Color: successText
// Use: Balance change indicators

AppTypography.button
// Size: 16px
// Weight: 600 (SemiBold)
// Letter spacing: 0.5
// Color: textInverse
// Use: Button labels (via AppButton)

AppTypography.cardLabel
// Size: 13px
// Weight: 500 (Medium)
// Letter spacing: 0.5
// Color: textSecondary
// Use: Card metadata, timestamps

AppTypography.caption
// Alias for labelSmall
// Use: Legacy compatibility
```

**Usage:**
```dart
// Balance card
Text(
  '12,345.67 USDC',
  style: AppTypography.balanceDisplay,
)

// Percentage gain
Text(
  '+5.2%',
  style: AppTypography.percentageChange,
)

// Card timestamp
Text(
  '2 hours ago',
  style: AppTypography.cardLabel,
)
```

---

## Customizing Styles

All typography styles can be customized using `copyWith()`:

```dart
// Change color
Text(
  'Error message',
  style: AppTypography.bodyMedium.copyWith(
    color: AppColors.errorText,
  ),
)

// Change weight
Text(
  'Bold text',
  style: AppTypography.bodyLarge.copyWith(
    fontWeight: FontWeight.w700,
  ),
)

// Multiple properties
Text(
  'Custom',
  style: AppTypography.titleMedium.copyWith(
    color: AppColors.gold500,
    fontSize: 20,
    letterSpacing: 1.0,
  ),
)
```

---

## Responsive Typography

For responsive scaling based on device size:

```dart
// Scale based on screen width
final scale = MediaQuery.of(context).size.width / 375; // Base: iPhone SE

Text(
  'Responsive',
  style: AppTypography.headlineLarge.copyWith(
    fontSize: 32 * scale.clamp(0.8, 1.2),
  ),
)
```

---

## Accessibility

### Font Scaling
Support system font scaling for accessibility:

```dart
// Font sizes automatically scale with device settings
Text(
  'Scales with system',
  style: AppTypography.bodyLarge,
  // Respects MediaQuery.textScaleFactor
)

// Limit maximum scale factor
MediaQuery(
  data: MediaQuery.of(context).copyWith(
    textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.5),
  ),
  child: Text('Clamped scaling', style: AppTypography.bodyMedium),
)
```

### Color Contrast
All typography defaults use accessible colors:

```dart
// Default colors meet WCAG AA
AppTypography.bodyLarge        // textPrimary (16.2:1)
AppTypography.bodyMedium       // textPrimary (16.2:1)
AppTypography.bodySmall        // textSecondary (8.5:1)
AppTypography.labelMedium      // textSecondary (8.5:1)
AppTypography.labelSmall       // textTertiary (4.8:1)
```

---

## Best Practices

### Do's
- Use semantic styles (e.g., `headlineMedium` not raw sizes)
- Apply mono font for numeric/code content
- Maintain type hierarchy (display > headline > title > body > label)
- Use `copyWith()` for one-off customizations
- Test with large system fonts

### Don'ts
- Don't use raw `TextStyle()` - always start from `AppTypography`
- Don't mix font families arbitrarily
- Don't use sizes smaller than 11px
- Don't use letter-spacing > 1.5 (hurts readability)
- Don't set fixed heights (breaks accessibility)

---

## Type Hierarchy Example

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // Display
    Text('1,234.56 USDC', style: AppTypography.displayMedium),

    // Headline
    Text('Your Balance', style: AppTypography.headlineSmall),

    // Title
    Text('Recent Transactions', style: AppTypography.titleLarge),

    // Body
    Text('Sent to Amadou Diallo', style: AppTypography.bodyMedium),

    // Label
    Text('2 hours ago', style: AppTypography.labelSmall),
  ],
)
```

---

## Font Loading

Fonts are loaded via Google Fonts package:

```yaml
# pubspec.yaml
dependencies:
  google_fonts: ^6.0.0
```

```dart
// Automatically cached and loaded
import 'package:google_fonts/google_fonts.dart';

// Fonts are lazy-loaded on first use
Text('Hello', style: AppTypography.bodyLarge)
```

---

## Related

- [Colors](./colors.md) - Color system and palette
- [Spacing](./spacing.md) - Layout and spacing tokens
- [Components](./components.md) - Components using typography
