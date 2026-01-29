# App Review - Quick Start Guide

## What Was Added

App store review prompts that appear after users complete successful transactions. The system is intelligent and non-intrusive.

## Automatic Integration

Already tracking these actions:
- ✅ Internal transfers (P2P)
- ✅ External transfers (crypto)
- ✅ Bill payments

No additional code needed for these!

## When Will Users See Review Prompt?

Only when ALL of these are true:
1. User has 5+ successful transactions
2. User has been using app for 2+ weeks
3. Haven't shown prompt in last 30 days
4. User hasn't reviewed yet

## How to Add to More Features

In any success screen, add this line:

```dart
// After successful action
final appReviewService = ref.read(appReviewServiceProvider);
await appReviewService.trackSuccessfulTransaction();
```

Example locations to add:
- Deposit success
- Withdrawal success
- Recurring transfer creation
- Payment link creation
- KYC completion

## Adding "Rate Us" Button in Settings

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../services/app_review/app_review_service.dart';

ListTile(
  leading: Icon(Icons.star_outline),
  title: Text(l10n.settings_rateApp),
  subtitle: Text(l10n.settings_rateAppDescription),
  trailing: Icon(Icons.chevron_right),
  onTap: () async {
    final appReviewService = ref.read(appReviewServiceProvider);
    await appReviewService.openAppStore();
  },
)
```

## Testing

### Check current state
```dart
final service = ref.read(appReviewServiceProvider);
final state = service.currentState;

print('Transactions: ${state?.successfulTransactions}/5');
print('Usage days: ${DateTime.now().difference(state?.firstUsageDate ?? DateTime.now()).inDays}/14');
print('Has reviewed: ${state?.hasReviewed}');
```

### Force prompt for testing
```dart
// Temporarily change thresholds in app_review_service.dart:
static const int _transactionsThreshold = 1;  // Was 5
static const int _usageDaysThreshold = 0;     // Was 14
```

### Reset state
```dart
await ref.read(appReviewServiceProvider).reset();
```

## Localization Strings

Already added:
- English: `settings_rateApp`, `settings_rateAppDescription`
- French: `settings_rateApp`, `settings_rateAppDescription`

## Files to Know

- **Service**: `/lib/services/app_review/app_review_service.dart`
- **Documentation**: `/lib/services/app_review/README.md`
- **Tests**: `/test/services/app_review_service_test.dart`

## Analytics Events

Automatically tracked:
- `review_prompt_shown` - When prompt displays
- `user_reviewed` - When user is marked as reviewed
- `manual_review_opened` - When user taps "Rate Us" button

## Monitoring

Check Firebase Analytics for:
1. How many users see the prompt
2. Conversion rate (prompt → review)
3. Optimal transaction threshold

## Adjusting Thresholds

Edit `/lib/services/app_review/app_review_service.dart`:

```dart
// Current values
static const int _transactionsThreshold = 5;      // Min transactions
static const int _usageDaysThreshold = 14;        // Min usage days
static const int _daysBetweenPrompts = 30;        // Cooldown period
```

Recommended approach:
1. Start with current values (5, 14, 30)
2. Monitor analytics for 2 weeks
3. Adjust based on conversion data
4. Consider A/B testing different values

## Platform Behavior

- **iOS**: Native StoreKit prompt (user can rate directly)
- **Android**: Play In-App Review (user can rate directly)
- Both platforms limit how often prompts can be shown

## Common Questions

**Q: Will this spam users?**
A: No. Multiple safeguards: transaction threshold, usage duration, 30-day cooldown, and one-time only.

**Q: Can I force show the prompt?**
A: Not directly (platform limitation), but you can add a "Rate Us" button that opens the app store.

**Q: Does this work in development?**
A: The prompt may not show in debug builds. Test on TestFlight/Internal Testing.

**Q: What if user dismisses the prompt?**
A: Service waits 30 days before showing again (unless they've reached review).

**Q: Can I track if user actually reviewed?**
A: Not directly via API. Use analytics correlation with app store reviews.

## Quick Checklist

- [x] Package added to pubspec.yaml
- [x] Service created and initialized
- [x] Tracking added to 3 transaction types
- [x] Localization strings added (EN/FR)
- [x] Tests written and passing
- [x] Analytics integration complete

## Next Steps

1. Deploy to staging/production
2. Monitor analytics events
3. Add "Rate Us" button in settings
4. Add tracking to more success screens
5. Adjust thresholds based on data

## Support

For issues or questions, check:
- `/lib/services/app_review/README.md` - Full documentation
- `/lib/services/app_review/IMPLEMENTATION.md` - Technical details
- Tests for usage examples
