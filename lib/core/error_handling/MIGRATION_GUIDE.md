# Migration Guide: Adding Error Boundaries to Existing App

This guide helps you integrate the error handling system into the JoonaPay mobile app.

## Phase 1: Setup (5 minutes)

### Step 1: Add Localization Strings

Add these to `lib/l10n/app_en.arb`:

```json
{
  "error_boundary_title": "Something Went Wrong",
  "error_boundary_message": "We encountered an issue. Our team has been notified.",
  "error_boundary_retry": "Try Again",
  "error_boundary_goHome": "Go to Home",
  "error_network_title": "Connection Issue",
  "error_auth_title": "Authentication Required",
  "error_validation_title": "Invalid Input",
  "error_business_title": "Unable to Complete"
}
```

Add French translations to `lib/l10n/app_fr.arb`:

```json
{
  "error_boundary_title": "Une Erreur s'est Produite",
  "error_boundary_message": "Nous avons rencontré un problème. Notre équipe a été notifiée.",
  "error_boundary_retry": "Réessayer",
  "error_boundary_goHome": "Aller à l'accueil",
  "error_network_title": "Problème de Connexion",
  "error_auth_title": "Authentification Requise",
  "error_validation_title": "Saisie Invalide",
  "error_business_title": "Impossible de Terminer"
}
```

### Step 2: Update main.dart

```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'core/error_handling/index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // NEW: Configure Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  runApp(
    ProviderScope(
      child: RootErrorBoundary(  // NEW: Wrap with error boundary
        child: const MyApp(),
      ),
    ),
  );
}
```

## Phase 2: Add to Critical Screens (15 minutes)

Wrap high-traffic screens first:

### Login Screen

```dart
// Before
class LoginView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(...);
  }
}

// After
class LoginView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ErrorBoundary(
      errorContext: 'LoginScreen',
      child: Scaffold(...),
    );
  }
}
```

### Wallet Screen

```dart
class WalletView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ErrorBoundary(
      errorContext: 'WalletScreen',
      child: _WalletContent(),  // Extract content to separate widget
    );
  }
}
```

### Transfer Screen

```dart
class TransferView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ErrorBoundary(
      errorContext: 'TransferScreen',
      child: _TransferContent(),
    );
  }
}
```

**Priority Screens:**
1. Login/OTP
2. Wallet/Home
3. Transfer/Send
4. Transactions
5. Settings

## Phase 3: Update Async Operations (30 minutes)

### Pattern 1: Widget State

```dart
// Before
class MyWidgetState extends ConsumerState<MyWidget> {
  Future<void> _loadData() async {
    try {
      final data = await api.getData();
      setState(() => _data = data);
    } catch (e) {
      // Manual error handling
      print(e);
    }
  }
}

// After
class MyWidgetState extends ConsumerState<MyWidget>
    with ErrorHandlerMixin {  // NEW
  Future<void> _loadData() async {
    await handleAsyncError(  // NEW
      () async {
        final data = await api.getData();
        setState(() => _data = data);
      },
      context: 'LoadData',
    );
  }
}
```

### Pattern 2: Providers/Notifiers

```dart
// Before
class WalletNotifier extends Notifier<WalletState> {
  @override
  WalletState build() => const WalletState();

  Future<void> refreshBalance() async {
    state = state.copyWith(isLoading: true);
    try {
      final balance = await sdk.wallet.getBalance();
      state = state.copyWith(balance: balance, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

// After
class WalletNotifier extends Notifier<WalletState>
    with NotifierErrorHandler {  // NEW
  @override
  WalletState build() => const WalletState();

  Future<void> refreshBalance() async {
    state = state.copyWith(isLoading: true);

    try {
      await handleAsyncError(  // NEW
        () async {
          final balance = await sdk.wallet.getBalance();
          state = state.copyWith(balance: balance, isLoading: false);
        },
        context: 'WalletNotifier.refreshBalance',
      );
    } catch (e) {
      state = state.copyWith(
        error: e.userFriendlyMessage,  // NEW
        isLoading: false,
      );
    }
  }
}
```

## Phase 4: Replace FutureBuilders (15 minutes)

```dart
// Before
FutureBuilder<List<Transaction>>(
  future: api.getTransactions(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return LoadingWidget();
    }
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }
    return TransactionList(transactions: snapshot.data!);
  },
)

// After
AsyncErrorBoundary<List<Transaction>>(
  future: api.getTransactions(),
  builder: (context, transactions) {
    return TransactionList(transactions: transactions);
  },
  loadingBuilder: (context) => LoadingWidget(),
  errorContext: 'TransactionList',
)
```

## Phase 5: Set User Context (5 minutes)

Update auth provider to set user info on login:

```dart
// In AuthNotifier or similar
Future<void> login(String phone, String otp) async {
  // ... existing login logic ...

  // NEW: Set user info for error reporting
  final errorReporter = ref.read(errorReporterProvider);
  await errorReporter.setUserInfo(
    userId: user.id,
    email: user.email,
    phoneNumber: user.phoneNumber,
  );
}

Future<void> logout() async {
  // ... existing logout logic ...

  // NEW: Clear user info
  final errorReporter = ref.read(errorReporterProvider);
  await errorReporter.clearUserInfo();
}
```

## Phase 6: Replace Manual Error Handling (Ongoing)

### Before: Manual Try-Catch

```dart
try {
  await sendMoney(amount, recipient);
  context.push('/success');
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: $e')),
  );
}
```

### After: Error Handler Mixin

```dart
await handleAsyncError(
  () async {
    await sendMoney(amount, recipient);
    context.push('/success');
  },
  context: 'SendMoney',
  customErrorMessage: l10n.transfer_errorSending,
);
```

### Before: Manual Error Display

```dart
if (state.error != null) {
  return Container(
    padding: EdgeInsets.all(16),
    color: Colors.red,
    child: Text(state.error!),
  );
}
```

### After: Compact Error Widget

```dart
if (state.error != null) {
  return CompactErrorWidget(
    message: state.error!,
    onRetry: _reload,
  );
}
```

## Checklist

Use this checklist to track migration progress:

### Setup
- [ ] Add localization strings (EN + FR)
- [ ] Update main.dart with RootErrorBoundary
- [ ] Test Crashlytics integration

### Critical Screens (Wrap with ErrorBoundary)
- [ ] Login/OTP
- [ ] Wallet/Home
- [ ] Transfer/Send
- [ ] Transactions List
- [ ] Settings

### Async Operations
- [ ] Update auth flows
- [ ] Update wallet operations
- [ ] Update transfer flows
- [ ] Update transaction loading
- [ ] Update KYC flows

### Providers
- [ ] WalletNotifier
- [ ] AuthNotifier
- [ ] TransactionNotifier
- [ ] TransferNotifier
- [ ] SettingsNotifier

### User Context
- [ ] Set user info on login
- [ ] Clear user info on logout
- [ ] Add breadcrumbs for critical flows

### Testing
- [ ] Test error boundaries catch errors
- [ ] Test Crashlytics receives errors
- [ ] Test retry functionality
- [ ] Test offline error handling
- [ ] Test network error messages

## Testing

### Manual Testing

1. **Test Network Errors**
   - Turn off WiFi/mobile data
   - Try to load wallet
   - Should see network error message
   - Turn on connection, tap retry
   - Should reload successfully

2. **Test Error Boundaries**
   - Force an error in a protected screen
   - Should see error UI, not red crash screen
   - Tap retry
   - Should reload screen

3. **Test Crashlytics**
   - Trigger an error
   - Check Firebase Console > Crashlytics
   - Should see error report with context

### Automated Testing

```bash
# Run error boundary tests
flutter test test/core/error_handling/

# Run all tests
flutter test
```

## Rollback Plan

If issues arise:

1. Remove `RootErrorBoundary` from main.dart
2. Remove `ErrorBoundary` wraps from screens
3. Remove `ErrorHandlerMixin` from widgets
4. Revert to previous error handling

The system is designed to be non-breaking, so partial rollback is safe.

## Performance Impact

- Negligible overhead (~1ms per error boundary)
- No impact on normal app flow
- Crashlytics reporting is async
- No additional dependencies required

## FAQ

**Q: Should I wrap every widget?**
A: No, wrap at screen/feature level only.

**Q: What about validation errors?**
A: Don't report to Crashlytics. Use local state or snackbars.

**Q: How do I test Crashlytics locally?**
A: Use debug logging. Reports appear in console. Real reports only in release.

**Q: Can I use this with existing try-catch?**
A: Yes, error boundaries are a safety net. Explicit error handling still works.

**Q: What if I need custom error handling?**
A: Use `onError` callback or `shouldCapture` predicate.

## Support

For issues or questions:
1. Check README.md for documentation
2. Review example_usage.dart for patterns
3. Check test files for examples
