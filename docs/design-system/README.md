# JoonaPay Design System

A luxury dark-first design system for USDC wallet applications, optimized for West African markets.

## Overview

The JoonaPay design system provides a complete set of design tokens, components, and patterns for building consistent, accessible, and premium mobile experiences.

### Philosophy

- **Dark = Premium**: Deep blacks and low-saturation colors create a sophisticated, luxury feel
- **Gold = Achievement**: Premium gold accents for CTAs and rewards (used sparingly)
- **Consistency**: 8pt grid system ensures visual rhythm
- **Accessibility**: WCAG AA compliant color contrasts and touch targets
- **Performance**: Optimized components with minimal re-renders

### Visual Language

**70-20-5-5 Rule:**
- 70% dark backgrounds (obsidian, graphite, slate)
- 20% text (ivory, gray hierarchy)
- 5% gold accents (CTAs, highlights)
- 5% semantic colors (success, error, warning)

---

## Documentation

### Design Tokens

Foundational values for colors, typography, and spacing.

| Document | Description |
|----------|-------------|
| **[Colors](./colors.md)** | Color palette, semantic colors, overlays, borders |
| **[Typography](./typography.md)** | Font families, type scale, text styles |
| **[Spacing](./spacing.md)** | 8pt grid, spacing scale, border radius, elevation |

### Components

Reusable UI components with usage examples.

| Document | Description |
|----------|-------------|
| **[Components](./components.md)** | Complete component library with API reference |

---

## Quick Start

### Installation

The design system is built into the app. Import tokens and components:

```dart
// Import design tokens
import 'package:usdc_wallet/design/tokens/index.dart';

// Import components
import 'package:usdc_wallet/design/components/primitives/index.dart';
```

### Basic Example

```dart
import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Heading with display typography
              AppText(
                'Welcome to JoonaPay',
                variant: AppTextVariant.displayMedium,
              ),
              SizedBox(height: AppSpacing.md),

              // Body text
              AppText(
                'Your USDC wallet for West Africa',
                variant: AppTextVariant.bodyLarge,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: AppSpacing.xxxl),

              // Premium card
              AppCard(
                variant: AppCardVariant.goldAccent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'Balance',
                      variant: AppTextVariant.labelMedium,
                    ),
                    SizedBox(height: AppSpacing.xs),
                    AppText(
                      '1,234.56 USDC',
                      variant: AppTextVariant.displayMedium,
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.lg),

              // Input field
              AppInput(
                label: 'Phone Number',
                hint: '0X XX XX XX XX',
                variant: AppInputVariant.phone,
              ),
              SizedBox(height: AppSpacing.lg),

              // Primary CTA
              AppButton(
                label: 'Get Started',
                isFullWidth: true,
                onPressed: () {
                  // Navigate
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## Design Principles

### 1. Mobile-First

All components are optimized for mobile:
- Minimum touch target: 48x48 px
- Bottom sheets for dropdowns
- Thumb-friendly layouts
- Responsive spacing

### 2. Dark-First

Primary theme is dark mode:
- Obsidian (#0A0A0C) canvas
- Graphite (#111115) elevated surfaces
- Slate (#1A1A1F) containers
- Light mode available via `AppColorsLight`

### 3. Gold Accent System

Gold is used sparingly for maximum impact:
- Primary CTAs (buttons)
- Achievement indicators
- Premium features
- Active states

### 4. Typography Hierarchy

Three fonts for distinct purposes:
- **Playfair Display**: Amounts, headlines (premium serif)
- **DM Sans**: UI text, labels (modern sans-serif)
- **JetBrains Mono**: Numbers, codes (monospace)

### 5. 8pt Grid

All spacing is based on 8px increments:
- Ensures visual rhythm
- Simplifies responsive design
- Easier mental math
- Better alignment

---

## Color System

### Dark Mode Palette

```dart
// Backgrounds (dark to light)
AppColors.obsidian        // #0A0A0C
AppColors.graphite        // #111115
AppColors.slate           // #1A1A1F
AppColors.elevated        // #222228

// Text (high to low emphasis)
AppColors.textPrimary     // #F5F5F0
AppColors.textSecondary   // #9A9A9E
AppColors.textTertiary    // #6B6B70
AppColors.textDisabled    // #4A4A4E

// Gold accent
AppColors.gold500         // #C9A962

// Semantic
AppColors.success         // #2D6A4F
AppColors.warning         // #C9943A
AppColors.error           // #8B2942
AppColors.info            // #4A6FA5
```

**[See full color documentation →](./colors.md)**

---

## Typography Scale

### Display (Playfair Display)

```dart
AppTypography.displayLarge    // 72px, Bold
AppTypography.displayMedium   // 48px, Bold
AppTypography.displaySmall    // 36px, SemiBold
```

### Headline (DM Sans)

```dart
AppTypography.headlineLarge   // 32px, SemiBold
AppTypography.headlineMedium  // 28px, SemiBold
AppTypography.headlineSmall   // 24px, SemiBold
```

### Body (DM Sans)

```dart
AppTypography.bodyLarge       // 16px, Regular
AppTypography.bodyMedium      // 14px, Regular
AppTypography.bodySmall       // 12px, Regular
```

### Special

```dart
AppTypography.balanceDisplay  // 42px, Bold (Playfair)
AppTypography.button          // 16px, SemiBold
AppTypography.monoMedium      // 16px, Regular (JetBrains Mono)
```

**[See full typography documentation →](./typography.md)**

---

## Spacing Scale

### Core Values (8pt Grid)

```dart
AppSpacing.xs      // 4px
AppSpacing.sm      // 8px   ← Base unit
AppSpacing.md      // 12px
AppSpacing.lg      // 16px
AppSpacing.xl      // 20px
AppSpacing.xxl     // 24px
AppSpacing.xxxl    // 32px
AppSpacing.huge    // 40px
AppSpacing.massive // 48px
```

### Component Spacing

```dart
AppSpacing.screenPadding   // 20px
AppSpacing.cardPadding     // 20px
AppSpacing.sectionGap      // 24px
AppSpacing.listItemSpacing // 12px
```

### Border Radius

```dart
AppRadius.md      // 8px  - Buttons, inputs
AppRadius.lg      // 12px - Cards
AppRadius.xl      // 16px - Large cards
AppRadius.xxl     // 20px - Modals
AppRadius.full    // 9999 - Pills, avatars
```

**[See full spacing documentation →](./spacing.md)**

---

## Components

### Primitive Components

| Component | Purpose | Variants |
|-----------|---------|----------|
| **AppButton** | Buttons, CTAs | primary, secondary, ghost, success, danger |
| **AppInput** | Text fields | standard, phone, pin, amount, search |
| **AppText** | Text display | 15 typography variants |
| **AppCard** | Containers | elevated, goldAccent, subtle, glass |
| **AppSelect** | Dropdowns | Bottom sheet UI for mobile |
| **AppSkeleton** | Loading states | Shimmer effect |
| **AppRefreshIndicator** | Pull-to-refresh | Gold accent |

### Usage

```dart
// Button
AppButton(
  label: 'Send Money',
  variant: AppButtonVariant.primary,
  onPressed: () => send(),
)

// Input
AppInput(
  label: 'Amount',
  variant: AppInputVariant.amount,
  controller: _amountController,
)

// Card
AppCard(
  variant: AppCardVariant.goldAccent,
  child: BalanceWidget(),
)

// Select
AppSelect<Currency>(
  label: 'Currency',
  items: currencies,
  value: selectedCurrency,
  onChanged: (value) => setState(() => selectedCurrency = value),
)
```

**[See full component library →](./components.md)**

---

## Accessibility

### WCAG Compliance

All color combinations meet WCAG AA standards:

| Pair | Contrast | Rating |
|------|----------|--------|
| textPrimary on obsidian | 16.2:1 | AAA |
| textSecondary on obsidian | 8.5:1 | AAA |
| gold500 on obsidian | 6.2:1 | AA+ |
| successText on obsidian | 5.8:1 | AA |

### Touch Targets

- Minimum: 48x48 px (WCAG 2.5.5)
- Recommended: 56x56 px for primary actions
- Spacing between: ≥8px

### Screen Readers

All components support semantic labels:

```dart
AppButton(
  label: 'Send',
  semanticLabel: 'Send money to selected contact',
  onPressed: () => send(),
)

AppInput(
  label: 'Amount',
  semanticLabel: 'Enter amount to send in USDC',
  controller: _amountController,
)
```

### Font Scaling

Components respect system font size settings:

```dart
// Automatically scales with MediaQuery.textScaleFactor
Text('Hello', style: AppTypography.bodyLarge)
```

---

## Best Practices

### Do's

✅ Use design tokens (`AppColors.gold500` not `Color(0xFFC9A962)`)
✅ Use component library (`AppButton` not `ElevatedButton`)
✅ Follow 8pt grid for spacing
✅ Apply gold sparingly (5% rule)
✅ Maintain text hierarchy
✅ Test with large fonts
✅ Provide semantic labels

### Don'ts

❌ Don't hardcode colors/spacing/sizes
❌ Don't create custom components without checking library first
❌ Don't use arbitrary spacing (e.g., 15px)
❌ Don't overuse gold (loses impact)
❌ Don't mix font families randomly
❌ Don't use text smaller than 11px
❌ Don't ignore accessibility

---

## Theme Support

### Dark Mode (Default)

```dart
// Automatically uses dark theme
Scaffold(
  backgroundColor: AppColors.obsidian,
  body: ...,
)
```

### Light Mode

```dart
// Use light mode colors
Scaffold(
  backgroundColor: AppColorsLight.canvas,
  body: Text(
    'Hello',
    style: TextStyle(color: AppColorsLight.textPrimary),
  ),
)
```

### Theme-Aware Components

```dart
// Components adapt to theme automatically
final colors = context.colors;

Container(
  color: colors.background,  // Dark or light based on theme
  child: AppText('Hello'),   // Text color adapts
)
```

---

## File Structure

```
lib/design/
├── tokens/              # Design tokens
│   ├── colors.dart      # Color palette
│   ├── typography.dart  # Text styles
│   ├── spacing.dart     # Spacing scale
│   ├── shadows.dart     # Shadow system
│   ├── theme_colors.dart # Theme helpers
│   └── index.dart       # Barrel export
│
├── components/
│   ├── primitives/      # Basic components
│   │   ├── app_button.dart
│   │   ├── app_input.dart
│   │   ├── app_text.dart
│   │   ├── app_card.dart
│   │   ├── app_select.dart
│   │   ├── app_skeleton.dart
│   │   ├── app_refresh_indicator.dart
│   │   └── index.dart
│   │
│   └── composed/        # Complex components
│       ├── balance_card.dart
│       ├── transaction_list_item.dart
│       └── ...
│
└── docs/                # This documentation
    └── design-system/
        ├── README.md    # This file
        ├── colors.md
        ├── typography.md
        ├── spacing.md
        └── components.md
```

---

## Examples

### Complete Form

```dart
class SendMoneyForm extends StatefulWidget {
  @override
  State<SendMoneyForm> createState() => _SendMoneyFormState();
}

class _SendMoneyFormState extends State<SendMoneyForm> {
  final _amountController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedCurrency = 'USDC';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: AppText(
          'Send Money',
          variant: AppTextVariant.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            'Recipient',
                            variant: AppTextVariant.titleMedium,
                          ),
                          SizedBox(height: AppSpacing.lg),

                          PhoneInput(
                            label: 'Phone Number',
                            controller: _phoneController,
                            countryCode: '+225',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSpacing.lg),

                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            'Amount',
                            variant: AppTextVariant.titleMedium,
                          ),
                          SizedBox(height: AppSpacing.lg),

                          AppInput(
                            label: 'Amount',
                            variant: AppInputVariant.amount,
                            controller: _amountController,
                            hint: '0.00',
                          ),
                          SizedBox(height: AppSpacing.lg),

                          AppSelect<String>(
                            label: 'Currency',
                            items: [
                              AppSelectItem(value: 'USDC', label: 'USDC'),
                              AppSelectItem(value: 'XOF', label: 'XOF'),
                            ],
                            value: _selectedCurrency,
                            onChanged: (value) {
                              setState(() => _selectedCurrency = value);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.lg),

              AppButton(
                label: 'Continue',
                isFullWidth: true,
                isLoading: _isLoading,
                onPressed: _handleSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    setState(() => _isLoading = true);
    try {
      // Process transfer
      await Future.delayed(Duration(seconds: 2));
      Navigator.push(context, ...);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
```

---

## Contributing

When adding to the design system:

1. **Follow conventions**: Use existing patterns
2. **Update documentation**: Document new tokens/components
3. **Test accessibility**: Ensure WCAG compliance
4. **Get review**: Design system changes need approval
5. **Update examples**: Add usage examples

---

## Resources

### Internal

- [Color Tokens](../../lib/design/tokens/colors.dart)
- [Typography Tokens](../../lib/design/tokens/typography.dart)
- [Spacing Tokens](../../lib/design/tokens/spacing.dart)
- [Component Library](../../lib/design/components/)

### External

- [Material Design](https://m3.material.io/)
- [WCAG Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [8pt Grid System](https://spec.fm/specifics/8-pt-grid)
- [Flutter Accessibility](https://docs.flutter.dev/development/accessibility-and-localization/accessibility)

---

## Support

For questions or issues with the design system:

1. Check this documentation first
2. Review component source code
3. Check existing usage in codebase
4. Ask in #design-system channel

---

**Version:** 1.0
**Last Updated:** January 2026
**Maintained by:** JoonaPay Design Team
