# Firebase Analytics & Crashlytics - Setup Checklist

## Files Created

### Service Files
- [x] `/lib/services/analytics/analytics_service.dart` - Analytics tracking service
- [x] `/lib/services/analytics/crash_reporting_service.dart` - Crash reporting service
- [x] `/lib/services/analytics/index.dart` - Service exports

### Documentation
- [x] `/lib/services/analytics/README.md` - Full documentation
- [x] `/lib/services/analytics/INTEGRATION_EXAMPLE.md` - Detailed examples
- [x] `/lib/services/analytics/QUICK_REFERENCE.md` - Quick reference guide
- [x] `/lib/services/analytics/SETUP_CHECKLIST.md` - This file

### Tests
- [x] `/test/services/analytics/analytics_service_test.dart` - Analytics tests (28 tests, all passing)
- [x] `/test/services/analytics/crash_reporting_service_test.dart` - Crashlytics tests (13 tests, all passing)

### Integration
- [x] Updated `/lib/services/index.dart` - Exported analytics services
- [x] Updated `/lib/main.dart` - Initialized Crashlytics

## Dependencies (Already in pubspec.yaml)

```yaml
firebase_core: ^3.8.1
firebase_analytics: ^11.3.6
firebase_crashlytics: ^4.1.6
```

## Configuration Steps

### 1. Firebase Project Setup (Not Required for Development)

The services work WITHOUT Firebase configuration - they gracefully degrade.

For production, you'll need:

1. Create Firebase project at https://console.firebase.google.com
2. Add iOS app (Bundle ID: `com.joonapay.usdcwallet`)
3. Add Android app (Package name: `com.joonapay.usdc_wallet`)

### 2. iOS Configuration (Production)

1. Download `GoogleService-Info.plist` from Firebase Console
2. Add to `ios/Runner/` directory
3. Add to Xcode project (Runner target)
4. Update `ios/Runner/Info.plist` if needed

### 3. Android Configuration (Production)

1. Download `google-services.json` from Firebase Console
2. Add to `android/app/` directory
3. Build files are already configured to use it

### 4. Integration in Existing Code

#### Auth Provider Example

```dart
// Add to lib/features/auth/providers/auth_provider.dart

import '../../../services/analytics/analytics_service.dart';
import '../../../services/analytics/crash_reporting_service.dart';

class AuthNotifier extends Notifier<AuthState> {
  AnalyticsService get _analytics => ref.read(analyticsServiceProvider);
  CrashReportingService get _crashReporting => ref.read(crashReportingServiceProvider);

  Future<bool> verifyOtp(String otp) async {
    // ... existing code ...

    try {
      final response = await _authService.verifyOtp(...);

      // Track success
      await _analytics.logLoginSuccess(
        method: 'phone_otp',
        userId: response.user.id,
      );

      // Set user context
      await _analytics.setUserId(response.user.id);
      await _crashReporting.setUserId(response.user.id);

      return true;
    } on ApiException catch (e) {
      // Track failure
      await _analytics.logLoginFailed(
        method: 'phone_otp',
        reason: e.message,
      );

      await _crashReporting.recordAuthError(e, reason: 'OTP verification failed');

      return false;
    }
  }

  Future<void> logout() async {
    // ... existing logout code ...

    // Clear analytics data
    await _analytics.reset();
    await _crashReporting.clearUserData();
  }
}
```

#### Transfer Integration Example

Look for transfer/send providers in:
- `/lib/features/transfers/`
- `/lib/features/send/`

Add tracking:

```dart
// Track initiation
await _analytics.logTransferInitiated(
  transferType: 'p2p_phone',
  amount: amount,
  currency: 'XOF',
);

// Track completion
await _analytics.logTransferCompleted(
  transferType: 'p2p_phone',
  amount: amount,
  currency: 'XOF',
  transactionId: result.id,
);

// Track failure
await _analytics.logTransferFailed(
  transferType: 'p2p_phone',
  amount: amount,
  currency: 'XOF',
  reason: e.message,
);
```

#### KYC Integration Example

Add to KYC providers in `/lib/features/settings/` or similar:

```dart
// Start KYC
await _analytics.logKycStarted(tier: 'tier_1');

// Complete KYC
await _analytics.logKycCompleted(tier: 'tier_1', status: 'approved');

// Error handling
await _crashReporting.recordKycError(
  e,
  tier: 'tier_1',
  step: 'document_upload',
);
```

#### Screen View Tracking

Add to ANY view that extends `ConsumerStatefulWidget`:

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

## Testing

### Run Tests

```bash
# Run all analytics tests
flutter test test/services/analytics/

# Expected output: All 41 tests passing
```

### Manual Testing (Debug Mode)

1. Run app: `flutter run`
2. Perform actions (login, transfer, etc.)
3. Check console logs for:
   - `[Analytics] Event: ...`
   - `[Crashlytics] Error recorded: ...`

### Production Testing

1. Configure Firebase (add config files)
2. Build release app: `flutter build apk --release`
3. Install and test
4. Check Firebase Console:
   - Analytics → Events (1-2 hour delay)
   - Crashlytics → Dashboard (real-time)

## Verification Checklist

- [ ] Services initialize without crashing (even without Firebase config)
- [ ] Login events tracked on successful authentication
- [ ] Transfer events tracked on send/receive
- [ ] KYC events tracked during verification
- [ ] Errors logged to Crashlytics
- [ ] User data cleared on logout
- [ ] All 41 tests passing
- [ ] No console errors in debug mode

## Next Steps

1. **Immediate (No Firebase Config Required)**
   - [x] Services are installed and working
   - [ ] Add analytics to auth provider (login/logout)
   - [ ] Add analytics to transfer flows
   - [ ] Add screen view tracking to main screens

2. **Short Term (Optional)**
   - [ ] Set up Firebase project
   - [ ] Add Firebase config files
   - [ ] Test in staging environment

3. **Production**
   - [ ] Configure Firebase for production
   - [ ] Set up BigQuery export (optional)
   - [ ] Configure crash alert notifications

## Support

- **Documentation**: See `README.md` for full details
- **Examples**: See `INTEGRATION_EXAMPLE.md` for code examples
- **Quick Ref**: See `QUICK_REFERENCE.md` for common patterns

## Current Status

✅ **Services Installed**: Analytics and Crashlytics services are ready to use
✅ **Tests Passing**: All 41 tests pass without Firebase configuration
✅ **Graceful Degradation**: Services work in dev mode without Firebase
✅ **Production Ready**: Just add Firebase config files when ready

The services are **fully functional** and can be integrated into your codebase immediately. They will log to console in debug mode and won't affect app functionality.
