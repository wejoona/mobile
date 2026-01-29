# Analytics & Crashlytics - Quick Reference

## Import

```dart
import '../../services/analytics/analytics_service.dart';
import '../../services/analytics/crash_reporting_service.dart';
```

## Get Services

```dart
// In a ConsumerWidget/ConsumerStatefulWidget
final analytics = ref.read(analyticsServiceProvider);
final crashReporting = ref.read(crashReportingServiceProvider);
```

## Track Events

### Authentication

```dart
// Login success
await analytics.logLoginSuccess(method: 'phone_otp', userId: user.id);

// Login failed
await analytics.logLoginFailed(method: 'phone_otp', reason: 'Invalid OTP');
```

### Transfers

```dart
// Initiated
await analytics.logTransferInitiated(
  transferType: 'p2p_phone', // or 'p2p_wallet', 'external_crypto'
  amount: 1000.0,
  currency: 'XOF',
);

// Completed
await analytics.logTransferCompleted(
  transferType: 'p2p_phone',
  amount: 1000.0,
  currency: 'XOF',
  transactionId: 'txn_123',
);

// Failed
await analytics.logTransferFailed(
  transferType: 'p2p_phone',
  amount: 1000.0,
  currency: 'XOF',
  reason: 'Insufficient balance',
);
```

### KYC

```dart
// Started
await analytics.logKycStarted(tier: 'tier_1');

// Completed
await analytics.logKycCompleted(tier: 'tier_1', status: 'approved');
```

### Deposits

```dart
// Initiated
await analytics.logDepositInitiated(
  method: 'orange_money', // or 'mtn_momo', 'wave'
  amount: 5000.0,
  currency: 'XOF',
);

// Completed
await analytics.logDepositCompleted(
  method: 'orange_money',
  amount: 5000.0,
  currency: 'XOF',
  transactionId: 'dep_123',
);
```

### Bill Payments

```dart
await analytics.logBillPaymentCompleted(
  billerName: 'CIE',
  category: 'electricity',
  amount: 2000.0,
  currency: 'XOF',
  transactionId: 'bill_123',
);
```

### Screen Views

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.read(analyticsServiceProvider).logScreenView(
      screenName: 'transfer_screen',
      screenClass: 'TransferView',
    );
  });
}
```

### User Properties

```dart
// Set user ID
await analytics.setUserId(user.id);

// Set custom property
await analytics.setUserProperty(name: 'kyc_tier', value: 'tier_1');
```

### Reset (on logout)

```dart
await analytics.reset();
```

## Report Errors

### API Errors

```dart
try {
  await sdk.wallet.transfer(...);
} on DioException catch (e) {
  await crashReporting.recordApiError(
    e,
    endpoint: '/wallet/transfer',
    userId: currentUserId,
  );
}
```

### Auth Errors

```dart
try {
  await authService.login(...);
} catch (e) {
  await crashReporting.recordAuthError(
    e,
    reason: 'Login failed',
    userId: userId,
  );
}
```

### Payment Errors

```dart
try {
  await transferService.send(...);
} catch (e) {
  await crashReporting.recordPaymentError(
    e,
    paymentType: 'p2p_transfer',
    amount: '1000.0',
    currency: 'XOF',
    transactionId: txnId,
    userId: userId,
  );
}
```

### KYC Errors

```dart
try {
  await kycService.uploadDocument(...);
} catch (e) {
  await crashReporting.recordKycError(
    e,
    tier: 'tier_1',
    step: 'document_upload',
    userId: userId,
  );
}
```

### Generic Errors

```dart
try {
  // Some operation
} catch (e, stack) {
  await crashReporting.recordError(
    e,
    stack,
    reason: 'Failed to load data',
    fatal: false,
  );
}
```

### Logging

```dart
// Log breadcrumb
await crashReporting.log('User tapped send button');

// Set custom key
await crashReporting.setCustomKey('feature_enabled', true);

// Set user ID
await crashReporting.setUserId(user.id);

// Clear on logout
await crashReporting.clearUserData();
```

## Common Patterns

### In Providers/Notifiers

```dart
class TransferNotifier extends Notifier<TransferState> {
  AnalyticsService get _analytics => ref.read(analyticsServiceProvider);
  CrashReportingService get _crashReporting => ref.read(crashReportingServiceProvider);

  Future<void> sendMoney(...) async {
    await _analytics.logTransferInitiated(...);

    try {
      final result = await _transferService.send(...);
      await _analytics.logTransferCompleted(...);
    } catch (e) {
      await _crashReporting.recordPaymentError(e, ...);
      await _analytics.logTransferFailed(...);
    }
  }
}
```

### In Views

```dart
class MyView extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyView> createState() => _MyViewState();
}

class _MyViewState extends ConsumerState<MyView> {
  @override
  void initState() {
    super.initState();
    _trackScreenView();
  }

  void _trackScreenView() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsServiceProvider).logScreenView(
        screenName: 'my_screen',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // ...
  }
}
```

## Transfer Types

- `p2p_phone` - Send to phone number
- `p2p_wallet` - Send to wallet address
- `external_crypto` - Withdraw to external wallet

## Deposit Methods

- `orange_money` - Orange Money
- `mtn_momo` - MTN Mobile Money
- `wave` - Wave
- `bank_transfer` - Bank transfer

## Bill Categories

- `electricity` - Electricity bills
- `water` - Water bills
- `internet` - Internet bills
- `airtime` - Mobile airtime

## KYC Tiers

- `tier_0` - No KYC
- `tier_1` - Basic KYC
- `tier_2` - Enhanced KYC
- `tier_3` - Full KYC

## Important Notes

1. Services gracefully handle missing Firebase config
2. All methods are async - use `await`
3. Never log PII (phone numbers, full names)
4. Always track both success AND failure
5. Clear user data on logout
6. Use descriptive reasons for failures
