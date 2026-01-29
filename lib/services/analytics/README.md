# Analytics & Crash Reporting

Firebase Analytics and Crashlytics integration for JoonaPay mobile app.

## Overview

This module provides two services:

- **AnalyticsService**: Track user events, screen views, and user properties
- **CrashReportingService**: Report crashes and non-fatal errors to Firebase

Both services are designed to fail gracefully if Firebase is not configured.

## Features

### AnalyticsService

- Track authentication events (login success/failure)
- Track transfer events (initiated, completed, failed)
- Track KYC events (started, completed)
- Track deposit events (initiated, completed)
- Track bill payment events
- Track screen views
- Set user properties for segmentation
- Automatic reset on logout

### CrashReportingService

- Automatic crash reporting (release mode only)
- Non-fatal error tracking
- Specialized error handlers:
  - API errors with endpoint context
  - Authentication errors
  - Payment/transfer errors with transaction context
  - KYC errors with tier/step context
- Custom key-value pairs for crash context
- User identification
- Automatic data clearing on logout

## Usage

### 1. Initialize (already done in main.dart)

```dart
import 'services/analytics/crash_reporting_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final crashReporting = CrashReportingService();
  await crashReporting.initialize();

  runApp(MyApp());
}
```

### 2. Track Events

```dart
// Get service from provider
final analytics = ref.read(analyticsServiceProvider);

// Track login
await analytics.logLoginSuccess(
  method: 'phone_otp',
  userId: user.id,
);

// Track transfer
await analytics.logTransferCompleted(
  transferType: 'p2p_phone',
  amount: 1000.0,
  currency: 'XOF',
  transactionId: 'txn_123',
);

// Track screen view
await analytics.logScreenView(
  screenName: 'transfer_screen',
  screenClass: 'TransferView',
);

// Set user properties
await analytics.setUserId(user.id);
await analytics.setUserProperty(name: 'kyc_tier', value: 'tier_1');
```

### 3. Report Errors

```dart
// Get service from provider
final crashReporting = ref.read(crashReportingServiceProvider);

// Record API error
await crashReporting.recordApiError(
  dioException,
  endpoint: '/wallet/transfer',
  userId: user.id,
);

// Record payment error
await crashReporting.recordPaymentError(
  exception,
  paymentType: 'deposit',
  amount: '1000.0',
  currency: 'XOF',
  transactionId: 'txn_123',
);

// Record generic error
await crashReporting.recordError(
  exception,
  stackTrace,
  reason: 'Failed to load wallet',
  fatal: false,
);

// Log message
await crashReporting.log('User initiated transfer');

// Set custom key
await crashReporting.setCustomKey('feature_flag_enabled', true);
```

### 4. Clean Up on Logout

```dart
await analytics.reset();
await crashReporting.clearUserData();
```

## Key Events

### Authentication
- `login_success` - User successfully logged in
- `login_failed` - Login attempt failed

### Transfers
- `transfer_initiated` - User started a transfer
- `transfer_completed` - Transfer succeeded
- `transfer_failed` - Transfer failed

### KYC
- `kyc_started` - User started KYC process
- `kyc_completed` - User completed KYC

### Deposits
- `deposit_initiated` - User initiated a deposit
- `deposit_completed` - Deposit succeeded

### Bill Payments
- `bill_payment_completed` - User paid a bill

## Error Categories

### API Errors
Includes endpoint, status code, error type

### Auth Errors
Authentication and authorization failures

### Payment Errors
Includes payment type, amount, currency, transaction ID

### KYC Errors
Includes tier and step information

## Configuration

### Firebase Setup (Production)

1. Add `google-services.json` to `android/app/`
2. Add `GoogleService-Info.plist` to `ios/Runner/`
3. Services will auto-enable when Firebase is configured

### Development (No Firebase)

Services gracefully handle missing Firebase config:
- Analytics events log to console in debug mode
- Crashlytics is disabled
- App continues to work normally

## Testing

### Debug Mode

Both services log all operations to console when `kDebugMode == true`:

```
[Analytics] Event: login_success {method: phone_otp, user_id: user_123}
[Crashlytics] Error recorded: DioException
```

### Test Crash

```dart
// Debug mode only
crashReporting.testCrash();
```

### Verify Events

1. Run app in release mode with Firebase configured
2. Trigger events (login, transfer, etc.)
3. Check Firebase Console:
   - Analytics → Events (1-2 hour delay)
   - Crashlytics → Dashboard (real-time)

## Privacy & Security

### DO NOT Log

- Phone numbers
- PINs or passwords
- Full names or addresses
- Transaction amounts over $10,000 (configurable)
- Wallet addresses or private keys

### DO Log

- User IDs (anonymized)
- Event types and categories
- Error messages (sanitized)
- Feature usage
- KYC tier (not documents)

### Compliance

- GDPR: User data is cleared on logout and account deletion
- CCPA: Analytics can be disabled via feature flag
- PCI DSS: No payment card data is logged

## Performance

- All operations are async and non-blocking
- Failed logging doesn't crash the app
- Minimal network usage (batched by Firebase SDK)
- Debug logs only in debug mode

## Troubleshooting

### Events not appearing in Firebase

- Wait 1-2 hours for Analytics dashboard to update
- Check DebugView in Firebase Console for real-time events
- Ensure Firebase is configured (`google-services.json` exists)
- Verify app is in release mode (debug events aren't collected)

### Crashlytics not reporting

- Crashes only reported in release mode
- Check Firebase Console → Crashlytics → Settings
- Ensure collection is enabled: `setCrashlyticsCollectionEnabled(true)`

### "Firebase not initialized" error

- Check Firebase.initializeApp() in main()
- Verify Firebase config files exist
- Services will gracefully handle this and continue

## See Also

- [INTEGRATION_EXAMPLE.md](./INTEGRATION_EXAMPLE.md) - Detailed integration examples
- [Firebase Analytics Docs](https://firebase.google.com/docs/analytics)
- [Firebase Crashlytics Docs](https://firebase.google.com/docs/crashlytics)
