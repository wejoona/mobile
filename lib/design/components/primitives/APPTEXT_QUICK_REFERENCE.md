# AppText Quick Reference

## Common Patterns

```dart
// Page title
AppText('Settings', variant: AppTextVariant.headlineLarge)

// Section heading
AppText('Account Information', variant: AppTextVariant.titleMedium)

// Body text (default)
AppText('Your account has been updated successfully.')

// Error message
AppText('Invalid email address', semanticColor: AppTextColor.error)

// Success message
AppText('Payment sent!', semanticColor: AppTextColor.success)

// Balance
AppText('\$12,345.67', variant: AppTextVariant.balance)

// Percentage change
AppText('+12.5%', variant: AppTextVariant.percentage)

// Label
AppText('Email Address', variant: AppTextVariant.labelMedium)

// Disabled text
AppText('Feature coming soon', semanticColor: AppTextColor.disabled)

// Link
AppText('Learn more', semanticColor: AppTextColor.link)

// Text on colored background
Container(
  color: AppColors.gold500,
  child: AppText('Featured', semanticColor: AppTextColor.inverse),
)

// Monospace (wallet address, code)
AppText('0x1234...5678', variant: AppTextVariant.monoMedium)

// Truncated text
AppText(
  'Very long text that will be cut off...',
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
)

// Custom styled
AppText(
  'Important',
  variant: AppTextVariant.bodyLarge,
  fontWeight: FontWeight.w700,
  semanticColor: AppTextColor.error,
)

// Accessible
AppText(
  '\$1,234.56',
  semanticLabel: 'One thousand two hundred thirty four dollars and fifty six cents',
)
```

## Semantic Colors Cheat Sheet

| Use Case | Semantic Color |
|----------|----------------|
| Main content | `primary` |
| Supporting text | `secondary` |
| Metadata, hints | `tertiary` |
| Unavailable features | `disabled` |
| Text on colored bg | `inverse` |
| Error messages | `error` |
| Success messages | `success` |
| Warning messages | `warning` |
| Info messages | `info` |
| Links, CTAs | `link` |

## Variant Cheat Sheet

| Use Case | Variant |
|----------|---------|
| Page title | `headlineLarge` or `headlineMedium` |
| Card title | `titleLarge` |
| List item title | `titleMedium` |
| Button text | `labelLarge` |
| Form label | `labelMedium` |
| Metadata | `labelSmall` |
| Balance amount | `balance` |
| Percentage | `percentage` |
| Wallet address | `monoMedium` |
| Transaction ID | `monoSmall` |

## Remember

1. **Default is good** - Most text needs no parameters
2. **Semantic over custom** - Use `semanticColor` instead of `color`
3. **Variants have defaults** - Headlines are primary, labels are secondary
4. **Theme-aware** - Colors adapt automatically to light/dark
5. **Accessibility** - Add semantic labels for amounts and percentages
