# App Review Service

Non-intrusive app store review prompts based on user engagement metrics.

## Features

- Tracks successful transactions
- Shows review prompt after meeting criteria:
  - 5+ successful transactions
  - 2+ weeks of usage
  - Not shown in last 30 days
- Stores review state locally
- Analytics tracking integration
- Manual app store opening for "Rate Us" buttons

## Usage

### Initialize Service

The service is automatically initialized when the app starts (in `SessionManager`).

```dart
final appReviewService = ref.read(appReviewServiceProvider);
await appReviewService.initialize();
```

### Track Successful Transaction

Call this after any successful transaction (transfer, bill payment, etc.):

```dart
final appReviewService = ref.read(appReviewServiceProvider);
await appReviewService.trackSuccessfulTransaction();
```

This is already integrated in:
- `/lib/features/send/providers/send_provider.dart` (internal transfers)
- `/lib/features/send_external/providers/external_transfer_provider.dart` (external transfers)
- `/lib/features/bill_payments/providers/bill_payments_provider.dart` (bill payments)

### Manual Review Request

For a "Rate Us" button in settings:

```dart
final appReviewService = ref.read(appReviewServiceProvider);
await appReviewService.openAppStore();
```

### Mark User as Reviewed

If you detect the user has left a review:

```dart
final appReviewService = ref.read(appReviewServiceProvider);
await appReviewService.markAsReviewed();
```

## Conditions for Showing Review

The review prompt will only show when ALL conditions are met:

1. **Transaction Threshold**: User has completed 5+ successful transactions
2. **Usage Duration**: User has been using the app for 2+ weeks
3. **Cooldown Period**: 30+ days since last prompt (if previously shown)
4. **Not Previously Reviewed**: User hasn't already reviewed the app

## State Management

Review state is stored locally using `SharedPreferences`:

```dart
class AppReviewState {
  final int successfulTransactions;     // Number of completed transactions
  final DateTime? firstUsageDate;       // When user first opened the app
  final DateTime? lastReviewPromptDate; // Last time prompt was shown
  final bool hasReviewed;               // Whether user has reviewed
}
```

## Analytics Integration

The service tracks the following events:
- `review_prompt_shown`: When the review prompt is displayed
- `user_reviewed`: When user is marked as having reviewed
- `manual_review_opened`: When user opens app store manually

## Configuration

Thresholds can be adjusted in `app_review_service.dart`:

```dart
static const int _transactionsThreshold = 5;      // Min transactions
static const int _usageDaysThreshold = 14;        // Min usage days
static const int _daysBetweenPrompts = 30;        // Cooldown period
```

## Testing

For testing, you can reset the review state:

```dart
final appReviewService = ref.read(appReviewServiceProvider);
await appReviewService.reset();
```

Check current state:

```dart
final state = appReviewService.currentState;
print('Transactions: ${state?.successfulTransactions}');
print('Has reviewed: ${state?.hasReviewed}');
```

## Platform Support

Uses the `in_app_review` package which supports:
- iOS (StoreKit)
- Android (Play In-App Review API)

The API will gracefully handle unsupported platforms by not showing the prompt.

## Best Practices

1. **Only track real success**: Only call `trackSuccessfulTransaction()` after confirmed success
2. **Don't spam**: The service already implements cooldown periods
3. **Respect user choice**: If user dismisses, we wait 30 days before asking again
4. **Track analytics**: Use the analytics events to understand review funnel
5. **Manual option**: Always provide a "Rate Us" button in settings as fallback

## Localization

Strings for manual review buttons:
- `settings_rateApp`: "Rate JoonaPay" / "Noter JoonaPay"
- `settings_rateAppDescription`: App store rating description

## Example: Settings Integration

```dart
ListTile(
  leading: Icon(Icons.star_outline),
  title: Text(l10n.settings_rateApp),
  subtitle: Text(l10n.settings_rateAppDescription),
  onTap: () async {
    final appReviewService = ref.read(appReviewServiceProvider);
    await appReviewService.openAppStore();
  },
)
```

## Troubleshooting

### Review prompt not showing
- Check if all conditions are met using `currentState`
- Verify in_app_review is available: `InAppReview.instance.isAvailable()`
- Check logs for debug messages

### State not persisting
- Ensure SharedPreferences is initialized
- Check storage permissions on Android

### Analytics not tracking
- Verify Firebase Analytics is initialized
- Check network connectivity
