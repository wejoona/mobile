# Korido Design System

## Tokens
- **colors.dart** / **colors_dark.dart** / **colors_light.dart** — Raw color values
- **theme_colors.dart** — Theme-aware `context.colors.X` (use this, NOT raw AppColors)
- **typography.dart** — Font styles (AppTypography)
- **spacing.dart** — `AppSpacing.xs/sm/md/lg/xl/xxl`
- **radii.dart** — `AppRadius.sm/md/lg/xl/full`
- **shadows.dart** — Elevation shadows

## Usage
```dart
// Colors — always use context.colors for theme support
final bg = context.colors.canvas;      // Screen background
final card = context.colors.container; // Card background
final text = context.colors.textPrimary;
final gold = context.colors.gold;      // Brand accent

// Typography
AppText('Hello', variant: AppTextVariant.headlineMedium);

// Spacing
const SizedBox(height: AppSpacing.lg);
```

## Composed Components (lib/design/components/composed/)
| Component | Usage |
|-----------|-------|
| `AsyncContent<T>` | Generic loading/error/data handler for Riverpod AsyncValue |
| `BalanceCard` | Wallet balance display with hide/show toggle |
| `ListScaffold<T>` | Standardized list screen with pull-to-refresh + empty state |
| `PinPad` + `PinDots` | PIN entry (used by lock, login, OTP, change PIN) |
| `TransactionRow` | Transaction list item |
| `OfflineBanner` | Connectivity status banner |
| `PinConfirmationSheet` | Bottom sheet for PIN confirmation |

## Primitive Components (lib/design/components/primitives/)
54 components including: AppButton, AppText, AppTextField, AppCard,
ShimmerLoading, BalanceDisplay, ContactTile, TransactionTile,
SearchBar, SectionHeader, StepIndicator, SuccessAnimation, etc.

## Rules
1. **Use `context.colors.X`** — never hardcode `AppColors.X` in views
2. **All PIN/lock views use design system PinPad** — not features/pin/widgets
3. **No emojis** — use Lucide/Material icons
4. **French is primary locale** — all strings must be in app_fr.arb
5. **No foreign-looking components** — reuse existing design system
