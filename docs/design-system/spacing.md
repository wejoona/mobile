# Spacing System

JoonaPay uses an 8pt grid system for consistent spacing, padding, and layout rhythm. All spacing values are multiples or divisors of 8.

## Base Grid: 8pt System

The 8pt grid ensures:
- Visual rhythm and consistency
- Easier mental math (8, 16, 24, 32...)
- Better alignment across components
- Responsive scaling

**Base unit:** 8px

---

## Spacing Scale

### Core Values

```dart
import 'package:usdc_wallet/design/tokens/spacing.dart';

AppSpacing.zero   // 0px  - No spacing
AppSpacing.xxs    // 2px  - Micro spacing
AppSpacing.xs     // 4px  - Minimal spacing
AppSpacing.sm     // 8px  - Base unit ← FUNDAMENTAL
AppSpacing.md     // 12px - Compact spacing
AppSpacing.lg     // 16px - Standard spacing
AppSpacing.xl     // 20px - Comfortable spacing
AppSpacing.xxl    // 24px - Generous spacing
AppSpacing.xxxl   // 32px - Large spacing
AppSpacing.huge   // 40px - Extra large
AppSpacing.massive // 48px - Huge spacing
AppSpacing.giant  // 64px - Maximum spacing
```

---

## Component-Specific Spacing

Pre-configured spacing for common components.

```dart
AppSpacing.cardPadding          // 20px - Standard card padding
AppSpacing.cardPaddingLarge     // 24px - Large card padding
AppSpacing.sectionGap           // 24px - Between sections
AppSpacing.screenPadding        // 20px - Screen edge padding
AppSpacing.listItemSpacing      // 12px - Between list items
AppSpacing.inputPadding         // 16px - Input field padding
AppSpacing.buttonPadding        // 16px - Button padding
AppSpacing.iconGap              // 12px - Icon to text gap
```

---

## Usage Examples

### Screen Layout

```dart
// Full screen with consistent padding
Scaffold(
  body: SafeArea(
    child: Padding(
      padding: EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        children: [
          // Header
          Text('Title', style: AppTypography.headlineLarge),
          SizedBox(height: AppSpacing.xxl), // Section gap

          // Content
          AppCard(...),
          SizedBox(height: AppSpacing.lg),
          AppCard(...),
        ],
      ),
    ),
  ),
)
```

---

### Card Layout

```dart
// Standard card
AppCard(
  padding: EdgeInsets.all(AppSpacing.cardPadding),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Card Title', style: AppTypography.titleMedium),
      SizedBox(height: AppSpacing.md),
      Text('Card content...', style: AppTypography.bodyMedium),
    ],
  ),
)

// Large card (more breathing room)
AppCard(
  padding: EdgeInsets.all(AppSpacing.cardPaddingLarge),
  child: ...,
)
```

---

### List Spacing

```dart
// List with consistent gaps
ListView.separated(
  itemCount: items.length,
  separatorBuilder: (context, index) => SizedBox(
    height: AppSpacing.listItemSpacing,
  ),
  itemBuilder: (context, index) => TransactionCard(...),
)

// Alternative using padding
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => Padding(
    padding: EdgeInsets.only(bottom: AppSpacing.listItemSpacing),
    child: TransactionCard(...),
  ),
)
```

---

### Form Spacing

```dart
// Form with consistent vertical rhythm
Form(
  child: Column(
    children: [
      AppInput(
        label: 'Phone Number',
        controller: _phoneController,
      ),
      SizedBox(height: AppSpacing.lg), // Standard gap

      AppInput(
        label: 'Amount',
        controller: _amountController,
      ),
      SizedBox(height: AppSpacing.xl), // Larger gap before button

      AppButton(
        label: 'Continue',
        onPressed: _handleSubmit,
      ),
    ],
  ),
)
```

---

### Icon + Text

```dart
// Icon next to text
Row(
  children: [
    Icon(Icons.info, size: 20),
    SizedBox(width: AppSpacing.iconGap),
    Text('Information', style: AppTypography.bodyMedium),
  ],
)

// Icon above text
Column(
  children: [
    Icon(Icons.check_circle, size: 48),
    SizedBox(height: AppSpacing.md),
    Text('Success!', style: AppTypography.titleLarge),
  ],
)
```

---

### Button Padding

```dart
// Internal button padding (handled by AppButton)
AppButton(
  label: 'Send',
  size: AppButtonSize.medium,
  // Uses AppSpacing.buttonPadding internally
)

// Custom button padding
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    padding: EdgeInsets.symmetric(
      horizontal: AppSpacing.xl,
      vertical: AppSpacing.md,
    ),
  ),
  child: Text('Custom Button'),
)
```

---

### Section Gaps

```dart
// Between major sections
Column(
  children: [
    BalanceCard(),
    SizedBox(height: AppSpacing.sectionGap),

    QuickActionsWidget(),
    SizedBox(height: AppSpacing.sectionGap),

    RecentTransactionsList(),
  ],
)
```

---

## Border Radius Scale

Rounded corners for cards, buttons, and containers.

```dart
AppRadius.none   // 0px  - Sharp corners
AppRadius.xs     // 4px  - Subtle rounding
AppRadius.sm     // 6px  - Small elements
AppRadius.md     // 8px  - Default/standard
AppRadius.lg     // 12px - Cards
AppRadius.xl     // 16px - Large cards
AppRadius.xxl    // 20px - Modals
AppRadius.xxxl   // 24px - Hero elements
AppRadius.full   // 9999 - Pills, avatars
```

### Usage

```dart
// Standard card
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(AppRadius.lg),
    color: AppColors.slate,
  ),
  child: ...,
)

// Button
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(AppRadius.md),
    color: AppColors.gold500,
  ),
  child: ...,
)

// Pill button
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(AppRadius.full),
    color: AppColors.gold500,
  ),
  child: Text('Tag'),
)

// Modal
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.vertical(
      top: Radius.circular(AppRadius.xxl),
    ),
  ),
  child: ...,
)
```

---

## Elevation Scale

Shadow intensity for layering (see [shadows.dart](./colors.md#shadows)).

```dart
AppElevation.none     // 0  - Flat (no shadow)
AppElevation.low      // 2  - Subtle lift
AppElevation.medium   // 4  - Standard card
AppElevation.high     // 8  - Floating elements
AppElevation.highest  // 16 - Modals, tooltips
```

**Note:** Use `AppShadows` for actual shadow definitions.

---

## Responsive Spacing

### Mobile-First Approach

```dart
// Base spacing (mobile)
Padding(
  padding: EdgeInsets.all(AppSpacing.screenPadding),
  child: ...,
)

// Tablet adaptation
Padding(
  padding: EdgeInsets.all(
    MediaQuery.of(context).size.width > 600
        ? AppSpacing.xxxl
        : AppSpacing.screenPadding,
  ),
  child: ...,
)
```

### Breakpoint-Based

```dart
double getResponsiveSpacing(BuildContext context) {
  final width = MediaQuery.of(context).size.width;

  if (width < 360) return AppSpacing.lg;      // Small phones
  if (width < 600) return AppSpacing.screenPadding; // Standard phones
  if (width < 900) return AppSpacing.xxl;     // Large phones / small tablets
  return AppSpacing.xxxl;                      // Tablets+
}

// Usage
Padding(
  padding: EdgeInsets.all(getResponsiveSpacing(context)),
  child: ...,
)
```

---

## Edge Insets Helpers

Common padding/margin patterns.

```dart
// Symmetric
EdgeInsets.symmetric(
  horizontal: AppSpacing.lg,
  vertical: AppSpacing.md,
)

// All sides
EdgeInsets.all(AppSpacing.cardPadding)

// Individual sides
EdgeInsets.only(
  top: AppSpacing.xl,
  left: AppSpacing.lg,
  right: AppSpacing.lg,
  bottom: AppSpacing.xxl,
)

// Directional (for RTL support)
EdgeInsetsDirectional.only(
  start: AppSpacing.lg,
  end: AppSpacing.lg,
  top: AppSpacing.md,
)
```

---

## Best Practices

### Do's
- Use spacing constants (never hardcode values)
- Maintain consistent vertical rhythm
- Use component-specific spacing where available
- Apply larger spacing between major sections
- Use smaller spacing within components

### Don'ts
- Don't use arbitrary values (e.g., `12.5` or `17`)
- Don't skip spacing tokens (e.g., jumping from `xs` to `xl`)
- Don't use fractional pixels (e.g., `15.5`)
- Don't create custom spacing values without reason
- Don't mix spacing systems (stick to 8pt grid)

---

## Common Spacing Patterns

### Vertical Stack

```dart
Column(
  children: [
    Widget1(),
    SizedBox(height: AppSpacing.lg),
    Widget2(),
    SizedBox(height: AppSpacing.lg),
    Widget3(),
  ],
)
```

### Horizontal Row

```dart
Row(
  children: [
    Widget1(),
    SizedBox(width: AppSpacing.md),
    Widget2(),
    SizedBox(width: AppSpacing.md),
    Widget3(),
  ],
)
```

### Screen Template

```dart
Scaffold(
  body: SafeArea(
    child: Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text('Title', style: AppTypography.headlineLarge),
          SizedBox(height: AppSpacing.sm),
          Text('Subtitle', style: AppTypography.bodyMedium),
          SizedBox(height: AppSpacing.xxl),

          // Content
          Expanded(
            child: ListView(...),
          ),
          SizedBox(height: AppSpacing.lg),

          // Footer
          AppButton(label: 'Action', onPressed: () {}),
        ],
      ),
    ),
  ),
)
```

---

## Visual Spacing Guide

```
zero    |                         0px
xxs     | ·                       2px
xs      | · ·                     4px
sm      | · · · ·                 8px  ← Base unit
md      | · · · · · ·             12px
lg      | · · · · · · · ·         16px
xl      | · · · · · · · · · ·     20px
xxl     | · · · · · · · · · · · · 24px
xxxl    | [16 dots]               32px
huge    | [20 dots]               40px
massive | [24 dots]               48px
giant   | [32 dots]               64px
```

---

## Related

- [Colors](./colors.md) - Color system
- [Typography](./typography.md) - Text styles
- [Components](./components.md) - Pre-built components
