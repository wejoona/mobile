# Quick Reference Guide

Fast lookup for common design tokens and components.

## Colors

### Backgrounds
```dart
AppColors.obsidian        // #0A0A0C - Main canvas
AppColors.graphite        // #111115 - Elevated surfaces
AppColors.slate           // #1A1A1F - Cards
AppColors.elevated        // #222228 - Inputs
```

### Text
```dart
AppColors.textPrimary     // #F5F5F0 - High emphasis
AppColors.textSecondary   // #9A9A9E - Labels
AppColors.textTertiary    // #6B6B70 - Hints
AppColors.gold500         // #C9A962 - Gold accent
```

### Semantic
```dart
AppColors.success         // #2D6A4F - Green
AppColors.warning         // #C9943A - Amber
AppColors.error           // #8B2942 - Red
AppColors.info            // #4A6FA5 - Blue
```

---

## Typography

### Display (Playfair - amounts, headlines)
```dart
AppTypography.displayLarge    // 72px Bold
AppTypography.displayMedium   // 48px Bold
AppTypography.displaySmall    // 36px SemiBold
```

### Headline (DM Sans - titles)
```dart
AppTypography.headlineLarge   // 32px SemiBold
AppTypography.headlineMedium  // 28px SemiBold
AppTypography.headlineSmall   // 24px SemiBold
```

### Body (DM Sans - content)
```dart
AppTypography.bodyLarge       // 16px Regular
AppTypography.bodyMedium      // 14px Regular
AppTypography.bodySmall       // 12px Regular
```

### Special
```dart
AppTypography.balanceDisplay  // 42px Bold
AppTypography.button          // 16px SemiBold
AppTypography.monoMedium      // 16px Mono
```

---

## Spacing

### Scale (8pt grid)
```dart
AppSpacing.xs      // 4px
AppSpacing.sm      // 8px   ← Base
AppSpacing.md      // 12px
AppSpacing.lg      // 16px
AppSpacing.xl      // 20px
AppSpacing.xxl     // 24px
AppSpacing.xxxl    // 32px
```

### Component-Specific
```dart
AppSpacing.screenPadding   // 20px
AppSpacing.cardPadding     // 20px
AppSpacing.sectionGap      // 24px
```

### Border Radius
```dart
AppRadius.md      // 8px  - Buttons
AppRadius.lg      // 12px - Cards
AppRadius.xl      // 16px - Large cards
AppRadius.full    // 9999 - Circles
```

---

## Components

### Button
```dart
AppButton(
  label: 'Send',
  onPressed: () {},
  variant: AppButtonVariant.primary,  // primary, secondary, ghost
  size: AppButtonSize.medium,         // small, medium, large
  isLoading: false,
  isFullWidth: false,
  icon: Icons.send,
)
```

### Input
```dart
AppInput(
  label: 'Phone',
  controller: _controller,
  variant: AppInputVariant.standard,  // standard, phone, pin, amount
  hint: 'Enter phone',
  error: 'Invalid phone',
  prefixIcon: Icons.phone,
)
```

### Card
```dart
AppCard(
  variant: AppCardVariant.elevated,   // elevated, goldAccent, subtle, glass
  padding: EdgeInsets.all(AppSpacing.cardPadding),
  onTap: () {},
  child: Widget(),
)
```

### Select
```dart
AppSelect<String>(
  label: 'Currency',
  items: [
    AppSelectItem(value: 'USD', label: 'US Dollar'),
  ],
  value: selected,
  onChanged: (v) => setState(() => selected = v),
)
```

### Text
```dart
AppText(
  'Hello',
  variant: AppTextVariant.bodyLarge,
  color: AppColors.textPrimary,
  maxLines: 2,
)
```

---

## Common Patterns

### Screen Layout
```dart
Scaffold(
  backgroundColor: AppColors.obsidian,
  body: SafeArea(
    child: Padding(
      padding: EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        children: [
          AppText('Title', variant: AppTextVariant.headlineLarge),
          SizedBox(height: AppSpacing.xxl),
          Expanded(child: ListView(...)),
          SizedBox(height: AppSpacing.lg),
          AppButton(label: 'Action', onPressed: () {}),
        ],
      ),
    ),
  ),
)
```

### Form
```dart
Column(
  children: [
    AppInput(label: 'Field 1', controller: _c1),
    SizedBox(height: AppSpacing.lg),
    AppInput(label: 'Field 2', controller: _c2),
    SizedBox(height: AppSpacing.xl),
    AppButton(label: 'Submit', onPressed: () {}),
  ],
)
```

### List
```dart
ListView.separated(
  itemCount: items.length,
  separatorBuilder: (_, __) => SizedBox(height: AppSpacing.listItemSpacing),
  itemBuilder: (_, i) => AppCard(child: Item(items[i])),
)
```

---

## Import Statements

```dart
// Tokens
import 'package:usdc_wallet/design/tokens/index.dart';

// Components
import 'package:usdc_wallet/design/components/primitives/index.dart';

// Localization
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
```

---

## Cheat Sheet

| Need | Use |
|------|-----|
| Button | `AppButton` |
| Input | `AppInput` |
| Dropdown | `AppSelect` |
| Text | `AppText` |
| Card | `AppCard` |
| Loading | `AppSkeleton` |
| Pull-to-refresh | `AppRefreshIndicator` |
| Primary color | `AppColors.gold500` |
| Background | `AppColors.obsidian` |
| Text color | `AppColors.textPrimary` |
| Error color | `AppColors.errorText` |
| Success color | `AppColors.successText` |
| Small spacing | `AppSpacing.sm` |
| Standard spacing | `AppSpacing.lg` |
| Section gap | `AppSpacing.sectionGap` |
| Card radius | `AppRadius.lg` |
| Button radius | `AppRadius.md` |

---

## Do's and Don'ts

### ✅ Do
- Use `AppColors.gold500`
- Use `AppTypography.bodyLarge`
- Use `AppSpacing.lg`
- Use `AppButton`
- Apply spacing from 8pt grid
- Provide semantic labels
- Test with large fonts

### ❌ Don't
- Hardcode `Color(0xFFC9A962)`
- Use raw `TextStyle(fontSize: 16)`
- Use arbitrary spacing like `15`
- Use raw `ElevatedButton`
- Mix spacing systems
- Ignore accessibility
- Skip component library

---

## Accessibility Checklist

- [ ] Touch targets ≥ 48x48 px
- [ ] Text contrast ≥ 4.5:1 (AA)
- [ ] Semantic labels on interactive elements
- [ ] Support system font scaling
- [ ] Keyboard navigation support
- [ ] Screen reader compatible
- [ ] Color not sole indicator

---

## Related Docs

- [Complete Colors →](./colors.md)
- [Complete Typography →](./typography.md)
- [Complete Spacing →](./spacing.md)
- [Complete Components →](./components.md)
- [Design System Home →](./README.md)
