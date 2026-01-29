# Transaction Limits Implementation

## Overview
Implemented comprehensive transaction limits display and enforcement for the JoonaPay mobile app.

## Files Created

### Models
- `/lib/features/limits/models/transaction_limits.dart`
  - Core model with dailyLimit, monthlyLimit, dailyUsed, monthlyUsed, kycTier
  - Helper getters for remaining amounts, percentages, and limit status checks
  - Supports 4 KYC tiers (0-3) with tier upgrade information

### Providers
- `/lib/features/limits/providers/limits_provider.dart`
  - Riverpod Notifier pattern for state management
  - Fetches limits from API via wallet service
  - Caches limits state with loading/error handling
  - Refresh functionality

### Views
- `/lib/features/limits/views/limits_view.dart`
  - Full limits screen with daily/monthly sections
  - Account tier badge with KYC navigation
  - Upgrade prompt for next tier
  - Info card explaining limit resets
  - Pull-to-refresh support

### Widgets
- `/lib/features/limits/widgets/limit_card.dart`
  - Reusable card showing limit usage
  - Progress bar with color coding
  - Icon, used/limit amounts, remaining display

- `/lib/features/limits/widgets/limit_progress_bar.dart`
  - Visual progress indicator
  - Color states: gold (normal), warning (80%+), error (100%)

- `/lib/features/limits/widgets/upgrade_prompt.dart`
  - CTA for KYC upgrade
  - Shows next tier benefits
  - Tappable, navigates to /kyc

- `/lib/features/limits/widgets/limit_warning_banner.dart`
  - Warning banner for approaching/reached limits
  - Shows on wallet home and amount screen
  - Tappable, navigates to limits view

### Services
- Updated `/lib/services/wallet/wallet_service.dart`
  - Added `getTransactionLimits()` method
  - Added `TransactionLimitsResponse` class extending `TransactionLimits`
  - API endpoint: GET /wallet/limits

### Mocks
- `/lib/mocks/services/limits/limits_mock.dart`
  - Mock data for 4 KYC tier scenarios
  - Default returns Tier 1 (Basic) with usage data
  - Registered in mock_registry.dart

## KYC Tiers

| Tier | Name       | Daily Limit | Monthly Limit | Status       |
|------|------------|-------------|---------------|--------------|
| 0    | Unverified | $100        | $500          | No KYC       |
| 1    | Basic      | $500        | $2,000        | Basic KYC    |
| 2    | Verified   | $2,000      | $10,000       | Full KYC     |
| 3    | Premium    | $10,000     | $50,000       | Enhanced KYC |

## Integration Points

### Wallet Home Screen
- Added limit warning banner (conditional)
- Shows when approaching (80%+) or at limit
- Placed between KYC banner and transactions
- Loads limits on init
- File: `/lib/features/wallet/views/wallet_home_screen.dart`

### Amount Screen (Send Flow)
- Added limit warning banner
- Validates amount against daily/monthly limits
- Shows error in form validation
- Prevents submission if limit exceeded
- File: `/lib/features/send/views/amount_screen.dart`

### Settings
- Updated `/lib/features/settings/views/limits_view.dart` to export new implementation
- Route already exists: `/settings/limits`

## Localization

### English Keys (lib/l10n/app_en.arb)
```
limits_title, limits_dailyLimits, limits_monthlyLimits
limits_dailyTransactions, limits_monthlyTransactions
limits_remaining, limits_of
limits_upgradeTitle, limits_upgradeDescription, limits_upgradeToTier
limits_day, limits_month
limits_aboutTitle, limits_aboutDescription
limits_kycPrompt, limits_maxTier, limits_noData
limits_limitReached, limits_dailyLimitReached, limits_monthlyLimitReached
limits_upgradeToIncrease
limits_approachingLimit, limits_remainingToday, limits_remainingThisMonth
```

### French Keys (lib/l10n/app_fr.arb)
All keys translated to French

## Routes

Existing route at `/settings/limits` now uses new implementation:
```dart
GoRoute(
  path: '/settings/limits',
  pageBuilder: (context, state) => AppPageTransitions.fade(
    state: state,
    child: const LimitsView(),
  ),
),
```

## Usage

### Fetch Limits
```dart
ref.read(limitsProvider.notifier).fetchLimits();
```

### Watch Limits State
```dart
final limitsState = ref.watch(limitsProvider);
if (limitsState.limits != null) {
  final limits = limitsState.limits!;
  // Use limits.dailyRemaining, limits.isDailyAtLimit, etc.
}
```

### Show Warning Banner
```dart
if (limits.isDailyNearLimit || limits.isDailyAtLimit) {
  LimitWarningBanner(limits: limits);
}
```

### Validate Amount
```dart
if (amount > limits.dailyRemaining) {
  return 'Daily limit exceeded';
}
```

## Features

### Limit Card
- Icon for transaction type
- Used/limit amounts
- Remaining amount with color coding
- Progress bar visualization
- Color states:
  - Gold: Normal usage (< 80%)
  - Warning: Approaching limit (80-99%)
  - Error: At/over limit (100%)

### Upgrade Prompt
- Only shows if next tier available
- Displays next tier name and limits
- Format: "$X/day • $Y/month"
- Tappable, navigates to KYC flow
- Gradient gold styling

### Warning Banner
- Compact, dismissible by navigation
- Shows on home screen and send flow
- Prioritizes daily over monthly warnings
- Clear messaging for limit status
- Tappable, navigates to full limits view

### Limits View
- Account tier badge with icon
- Separate daily/monthly sections
- Pull-to-refresh
- Loading/error states
- Empty state handling
- Info card with UTC reset notice

## Design System Compliance

### Components Used
- AppCard (variant: subtle, elevated)
- AppText (all variants)
- AppButton (primary variant)
- AppColors (gold, warning, error palettes)
- AppSpacing (consistent spacing)
- AppRadius (rounded corners)
- ThemeColors from context

### Patterns Followed
- ConsumerWidget/ConsumerStatefulWidget
- Riverpod Notifier pattern
- context.push() navigation
- AppLocalizations.of(context)
- Formatters.formatCurrency()
- Error handling with try-catch
- Loading states
- Empty states

## Testing

### Mock Scenarios
The mock provides 4 scenarios:
1. Tier 0 - Low usage (45/100 daily)
2. Tier 1 - Near limit (420/500 daily) **DEFAULT**
3. Tier 2 - At limit (2000/2000 daily)
4. Tier 3 - Premium with low usage

Default scenario (Tier 1) shows warning banner for testing.

### Manual Test Cases
1. Navigate to /settings/limits
2. View limit progress bars
3. Tap upgrade prompt → navigates to KYC
4. Pull to refresh → reloads data
5. Go to send flow → see warning banner
6. Enter amount > daily limit → see validation error
7. Check wallet home → see warning banner if approaching limit

## API Contract

### Request
```
GET /wallet/limits
Authorization: Bearer {token}
```

### Response
```json
{
  "dailyLimit": 500.0,
  "monthlyLimit": 2000.0,
  "dailyUsed": 420.0,
  "monthlyUsed": 1250.0,
  "kycTier": 1,
  "tierName": "Basic",
  "nextTierName": "Verified",
  "nextTierDailyLimit": 2000.0,
  "nextTierMonthlyLimit": 10000.0
}
```

## Accessibility

- All interactive elements tappable
- Clear color coding for status
- Descriptive labels
- Icon + text for all actions
- High contrast for warnings/errors
- Proper font scaling

## Performance

- Cached limits state in provider
- Lazy loading (only on init/refresh)
- Progress bar uses ClipRRect for smooth rendering
- Conditional widget rendering (SizedBox.shrink for hidden)
- No unnecessary rebuilds

## Future Enhancements

1. Real-time limit tracking as transactions occur
2. Push notifications when approaching limits
3. Daily/monthly limit reset countdown timer
4. Limit history/analytics
5. Per-transaction-type limits (send vs. withdraw)
6. Custom limit requests for verified users

## Notes

- Limits reset at midnight UTC
- Validation happens client-side and should be confirmed server-side
- Warning shows at 80% usage
- Error shows at 100% usage
- Mock data returns Tier 1 by default for testing warnings
