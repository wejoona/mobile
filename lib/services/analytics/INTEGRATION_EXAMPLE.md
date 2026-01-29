# Firebase Analytics & Crashlytics Integration Guide

This guide shows how to integrate Analytics and Crashlytics into existing features.

## Services Available

- `AnalyticsService` - Track user events and screen views
- `CrashReportingService` - Report errors and crashes

Both services gracefully handle missing Firebase config and won't crash the app.

## 1. Auth Integration Example

### In `auth_provider.dart`

```dart
import '../../../services/analytics/analytics_service.dart';
import '../../../services/analytics/crash_reporting_service.dart';

class AuthNotifier extends Notifier<AuthState> {
  // Add service getters
  AnalyticsService get _analytics => ref.read(analyticsServiceProvider);
  CrashReportingService get _crashReporting => ref.read(crashReportingServiceProvider);

  /// Login existing user
  Future<void> login(String phone) async {
    state = state.copyWith(status: AuthStatus.loading, phone: phone);

    try {
      final response = await _authService.login(phone: phone);

      state = state.copyWith(
        status: AuthStatus.otpSent,
        otpExpiresIn: response.expiresIn,
      );

      // Track OTP sent
      await _analytics.logScreenView(screenName: 'otp_screen');
    } on ApiException catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.message);

      // Track login failure
      await _analytics.logLoginFailed(
        method: 'phone_otp',
        reason: e.message,
      );

      // Report error to Crashlytics
      await _crashReporting.recordAuthError(
        e,
        reason: 'Login failed: ${e.message}',
      );
    }
  }

  /// Verify OTP
  Future<bool> verifyOtp(String otp) async {
    if (state.phone == null) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'Phone number not found',
      );
      return false;
    }

    state = state.copyWith(status: AuthStatus.loading);

    try {
      final response = await _authService.verifyOtp(
        phone: state.phone!,
        otp: otp,
      );

      // Store tokens...
      await _storage.write(
        key: StorageKeys.accessToken,
        value: response.accessToken,
      );

      // Start session...
      await ref.read(sessionServiceProvider.notifier).startSession(
        accessToken: response.accessToken,
        tokenValidity: const Duration(hours: 1),
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: response.user,
      );

      // Track successful login
      await _analytics.logLoginSuccess(
        method: 'phone_otp',
        userId: response.user.id,
      );

      // Set user ID for analytics & crash reporting
      await _analytics.setUserId(response.user.id);
      await _crashReporting.setUserId(response.user.id);

      // Set user properties
      await _analytics.setUserProperty(
        name: 'kyc_tier',
        value: response.user.kycTier ?? 'none',
      );

      return true;
    } on ApiException catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.message);

      // Track OTP verification failure
      await _analytics.logLoginFailed(
        method: 'phone_otp',
        reason: 'OTP verification failed: ${e.message}',
      );

      await _crashReporting.recordAuthError(
        e,
        reason: 'OTP verification failed',
      );

      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    // End session first
    await ref.read(sessionServiceProvider.notifier).endSession();

    await _storage.delete(key: StorageKeys.accessToken);
    await _storage.delete(key: StorageKeys.refreshToken);

    // Clear analytics data
    await _analytics.reset();
    await _crashReporting.clearUserData();

    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}
```

## 2. Transfer Integration Example

### In `transfer_provider.dart` or similar

```dart
import '../../../services/analytics/analytics_service.dart';
import '../../../services/analytics/crash_reporting_service.dart';

class TransferNotifier extends Notifier<TransferState> {
  AnalyticsService get _analytics => ref.read(analyticsServiceProvider);
  CrashReportingService get _crashReporting => ref.read(crashReportingServiceProvider);

  Future<void> initiateTransfer({
    required String recipientPhone,
    required double amount,
    required String currency,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    // Track transfer initiation
    await _analytics.logTransferInitiated(
      transferType: 'p2p_phone',
      amount: amount,
      currency: currency,
    );

    try {
      final result = await _transferService.sendToPhone(
        phone: recipientPhone,
        amount: amount,
        currency: currency,
      );

      state = state.copyWith(
        isLoading: false,
        transaction: result,
      );

      // Track successful transfer
      await _analytics.logTransferCompleted(
        transferType: 'p2p_phone',
        amount: amount,
        currency: currency,
        transactionId: result.id,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );

      // Track transfer failure
      await _analytics.logTransferFailed(
        transferType: 'p2p_phone',
        amount: amount,
        currency: currency,
        reason: e.message,
      );

      // Report error
      await _crashReporting.recordPaymentError(
        e,
        paymentType: 'p2p_transfer',
        amount: amount.toString(),
        currency: currency,
      );
    }
  }
}
```

## 3. KYC Integration Example

### In `kyc_provider.dart`

```dart
class KycNotifier extends Notifier<KycState> {
  AnalyticsService get _analytics => ref.read(analyticsServiceProvider);
  CrashReportingService get _crashReporting => ref.read(crashReportingServiceProvider);

  Future<void> startKyc(String tier) async {
    // Track KYC start
    await _analytics.logKycStarted(tier: tier);

    state = state.copyWith(isLoading: true);

    try {
      // Start KYC flow...
      final result = await _kycService.startKyc(tier);

      state = state.copyWith(
        isLoading: false,
        currentStep: result.currentStep,
      );
    } catch (e) {
      await _crashReporting.recordKycError(
        e,
        tier: tier,
        step: 'start',
      );
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> submitKyc(String tier) async {
    state = state.copyWith(isLoading: true);

    try {
      final result = await _kycService.submitKyc(tier);

      state = state.copyWith(
        isLoading: false,
        status: result.status,
      );

      // Track KYC completion
      await _analytics.logKycCompleted(
        tier: tier,
        status: result.status,
      );
    } catch (e) {
      await _crashReporting.recordKycError(
        e,
        tier: tier,
        step: 'submit',
      );
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
```

## 4. Deposit Integration Example

### In `deposit_provider.dart`

```dart
class DepositNotifier extends Notifier<DepositState> {
  AnalyticsService get _analytics => ref.read(analyticsServiceProvider);
  CrashReportingService get _crashReporting => ref.read(crashReportingServiceProvider);

  Future<void> initiateDeposit({
    required String method,
    required double amount,
    required String currency,
  }) async {
    // Track deposit initiation
    await _analytics.logDepositInitiated(
      method: method,
      amount: amount,
      currency: currency,
    );

    state = state.copyWith(isLoading: true);

    try {
      final result = await _depositService.createDeposit(
        method: method,
        amount: amount,
        currency: currency,
      );

      state = state.copyWith(
        isLoading: false,
        depositRequest: result,
      );
    } catch (e) {
      await _crashReporting.recordPaymentError(
        e,
        paymentType: 'deposit',
        amount: amount.toString(),
        currency: currency,
      );
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Call this when deposit is confirmed
  Future<void> onDepositCompleted({
    required String method,
    required double amount,
    required String currency,
    required String transactionId,
  }) async {
    await _analytics.logDepositCompleted(
      method: method,
      amount: amount,
      currency: currency,
      transactionId: transactionId,
    );
  }
}
```

## 5. Bill Payment Integration Example

### In `bill_payment_provider.dart`

```dart
class BillPaymentNotifier extends Notifier<BillPaymentState> {
  AnalyticsService get _analytics => ref.read(analyticsServiceProvider);
  CrashReportingService get _crashReporting => ref.read(crashReportingServiceProvider);

  Future<void> payBill({
    required String billerId,
    required String billerName,
    required String category,
    required double amount,
    required String currency,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      final result = await _billPaymentService.payBill(
        billerId: billerId,
        amount: amount,
      );

      state = state.copyWith(
        isLoading: false,
        transaction: result,
      );

      // Track bill payment
      await _analytics.logBillPaymentCompleted(
        billerName: billerName,
        category: category,
        amount: amount,
        currency: currency,
        transactionId: result.id,
      );
    } catch (e) {
      await _crashReporting.recordPaymentError(
        e,
        paymentType: 'bill_payment',
        amount: amount.toString(),
        currency: currency,
      );
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
```

## 6. Screen View Tracking Example

### In any view file

```dart
class TransferView extends ConsumerStatefulWidget {
  const TransferView({super.key});

  @override
  ConsumerState<TransferView> createState() => _TransferViewState();
}

class _TransferViewState extends ConsumerState<TransferView> {
  @override
  void initState() {
    super.initState();

    // Track screen view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsServiceProvider).logScreenView(
        screenName: 'transfer_screen',
        screenClass: 'TransferView',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Build UI...
  }
}
```

## 7. API Error Tracking

### In `api_client.dart` (AuthInterceptor)

Add to the `onError` method:

```dart
@override
void onError(DioException err, ErrorInterceptorHandler handler) async {
  // Track API errors to Crashlytics
  final crashReporting = CrashReportingService();
  await crashReporting.recordApiError(
    err,
    endpoint: err.requestOptions.path,
  );

  // Existing error handling...
  if (err.response?.statusCode == 401 && !err.requestOptions.path.contains('/auth/refresh')) {
    // ...
  }

  handler.next(err);
}
```

## Testing

Both services are safe to use without Firebase configuration:

1. **Without Firebase Config**: Services gracefully degrade and log to console in debug mode
2. **With Firebase Config**: Full analytics and crash reporting functionality

### Test Events

```dart
// In debug mode, you can test tracking
final analytics = ref.read(analyticsServiceProvider);
final crashReporting = ref.read(crashReportingServiceProvider);

// Track a test event
await analytics.logLoginSuccess(method: 'test', userId: 'test-user');

// Log to Crashlytics
await crashReporting.log('Test log message');

// Test crash (debug only)
crashReporting.testCrash();
```

## Best Practices

1. **Always wrap in try-catch**: Analytics/Crashlytics should never crash your app
2. **Don't log PII**: Avoid logging sensitive user data (phone numbers, PINs, addresses)
3. **Use meaningful event names**: Follow the naming convention (e.g., `feature_action`)
4. **Set user properties**: Help segment analytics by KYC tier, country, etc.
5. **Clear on logout**: Always clear user data when user logs out
6. **Track errors contextually**: Use specialized error methods (recordPaymentError, recordKycError)

## Viewing Data

1. **Analytics**: Firebase Console → Analytics → Events
2. **Crashlytics**: Firebase Console → Crashlytics → Dashboard

Events may take 1-2 hours to appear in Firebase Console.
