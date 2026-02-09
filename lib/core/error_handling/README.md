# Error Handling System

Comprehensive error handling for JoonaPay mobile app with error boundaries, Crashlytics reporting, and user-friendly error displays.

## Features

- **Error Boundaries**: Catch and handle errors without crashing the app
- **Crashlytics Integration**: Automatic error reporting to Firebase
- **User-Friendly Messages**: Convert technical errors to readable messages
- **Retry Mechanisms**: Allow users to retry failed operations
- **Context Tracking**: Track where errors occur for better debugging
- **Type-Safe Errors**: Custom error types for different scenarios
- **Accessibility**: Screen reader support for error messages

## Setup

### 1. Root Error Boundary

Wrap your entire app with `RootErrorBoundary` in `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Enable Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  runApp(
    ProviderScope(
      child: RootErrorBoundary(
        child: MyApp(),
      ),
    ),
  );
}
```

### 2. Feature-Level Boundaries

Wrap individual features or screens:

```dart
class WalletScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ErrorBoundary(
      errorContext: 'WalletScreen',
      child: WalletView(),
    );
  }
}
```

### 3. Set User Info (After Login)

```dart
final errorReporter = ref.read(errorReporterProvider);
await errorReporter.setUserInfo(
  userId: user.id,
  email: user.email,
  phoneNumber: user.phoneNumber,
);
```

## Usage Examples

### Basic Error Boundary

```dart
ErrorBoundary(
  errorContext: 'TransferFlow',
  child: TransferWidget(),
)
```

### Custom Error UI

```dart
ErrorBoundary(
  fallbackBuilder: (context, error, stackTrace, reset) {
    return CustomErrorWidget(
      message: error.userFriendlyMessage,
      onRetry: reset,
    );
  },
  child: MyWidget(),
)
```

### Async Operations

```dart
AsyncErrorBoundary(
  future: api.fetchTransactions(),
  builder: (context, transactions) {
    return TransactionList(transactions: transactions);
  },
  loadingBuilder: (context) => LoadingSpinner(),
  errorContext: 'TransactionList',
)
```

### Widget Error Handling

```dart
class MyWidgetState extends ConsumerState<MyWidget> with ErrorHandlerMixin {
  Future<void> _sendMoney() async {
    await handleAsyncError(
      () async {
        await api.sendMoney(amount, recipient);
        context.push('/success');
      },
      context: 'SendMoney',
      customErrorMessage: 'Failed to send money. Please try again.',
    );
  }

  Future<void> _loadBalance() async {
    final balance = await handleAsyncErrorWithResult(
      () => api.getBalance(),
      context: 'LoadBalance',
    );

    if (balance != null) {
      setState(() => _balance = balance);
    }
  }
}
```

### Notifier Error Handling

```dart
class WalletNotifier extends Notifier<WalletState> with NotifierErrorHandler {
  @override
  WalletState build() => const WalletState();

  Future<void> refreshBalance() async {
    state = state.copyWith(isLoading: true);

    await handleAsyncError(
      () async {
        final balance = await sdk.wallet.getBalance();
        state = state.copyWith(
          balance: balance,
          isLoading: false,
        );
      },
      context: 'WalletNotifier.refreshBalance',
      severity: ErrorSeverity.warning,
    );
  }
}
```

### Manual Error Reporting

```dart
final errorReporter = ref.read(errorReporterProvider);

// Report error
await errorReporter.reportError(
  error,
  stackTrace,
  context: 'PaymentProcessing',
  severity: ErrorSeverity.error,
  metadata: {
    'amount': amount,
    'recipient': recipientId,
  },
);

// Report network error
await errorReporter.reportNetworkError(
  error,
  stackTrace,
  endpoint: '/api/transfer',
  statusCode: 500,
);

// Log breadcrumb
errorReporter.logBreadcrumb(
  'User initiated transfer',
  metadata: {'amount': amount},
);
```

### Error Display Widgets

#### Full Screen Error

```dart
ErrorFallbackUI(
  error: error,
  onRetry: _retry,
  context: 'FeatureName',
)
```

#### Compact Error (Inline)

```dart
CompactErrorWidget(
  message: 'Failed to load data',
  onRetry: _reload,
)
```

#### Empty State Error

```dart
EmptyStateErrorWidget(
  title: 'No Transactions',
  message: 'Failed to load your transactions',
  onRetry: _reload,
  icon: Icons.receipt_long_rounded,
)
```

#### Snackbar Error

```dart
// Simple
context.showErrorSnackbar('Failed to save');

// From exception
context.showError(error);

// With retry
SnackbarError.show(
  context,
  'Network error',
  onRetry: _retry,
);
```

## Custom Error Types

### Define Custom Error

```dart
class PaymentError extends AppError {
  const PaymentError(super.message, {super.code});

  static const paymentFailed = PaymentError(
    'Payment failed. Please try again.',
    code: 'PAYMENT_FAILED',
  );

  static const cardDeclined = PaymentError(
    'Your card was declined. Please use another payment method.',
    code: 'CARD_DECLINED',
  );
}
```

### Throw Custom Error

```dart
if (insufficientFunds) {
  throw BusinessError.insufficientBalance;
}

if (invalidCard) {
  throw PaymentError.cardDeclined;
}
```

### Handle Specific Errors

```dart
try {
  await processPayment();
} on NetworkError catch (e) {
  context.showErrorSnackbar('Please check your connection');
} on BusinessError catch (e) {
  context.showErrorSnackbar(e.message);
} catch (e) {
  context.showError(e);
}
```

## Error Severity Levels

- **info**: Informational, not an error (e.g., validation warnings)
- **warning**: Something unexpected but handled (e.g., network retry)
- **error**: Real error that was handled gracefully
- **fatal**: Critical error preventing app operation

```dart
errorReporter.reportError(
  error,
  stackTrace,
  severity: ErrorSeverity.warning, // Choose appropriate level
);
```

## Best Practices

### DO

- Wrap entire app with `RootErrorBoundary`
- Wrap features/screens with `ErrorBoundary`
- Use `ErrorHandlerMixin` for async operations in widgets
- Provide context when reporting errors
- Use custom error types for domain-specific errors
- Show user-friendly messages, not stack traces
- Provide retry options when possible
- Test error scenarios

### DON'T

- Let errors crash the app
- Show technical error messages to users
- Report validation errors to Crashlytics
- Swallow errors silently
- Use generic try-catch without reporting
- Forget to set user info after login
- Over-report trivial issues

## Localization

Add error messages to `app_en.arb` and `app_fr.arb`:

```json
{
  "error_generic": "We encountered an issue. Please try again.",
  "error_network": "Unable to connect. Please check your internet.",
  "error_unauthorized": "Your session expired. Please login again.",
  "action_retry": "Retry"
}
```

## Testing

### Test Error Boundary

```dart
testWidgets('shows error UI on exception', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: ErrorBoundary(
          child: ThrowingWidget(),
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();

  expect(find.byType(ErrorFallbackUI), findsOneWidget);
});
```

### Test Crash Reporting

```dart
void testCrashReporting() {
  final errorReporter = ErrorReporter();

  // This will crash in debug mode only
  errorReporter.testCrash();
}
```

## Architecture

```
lib/core/error_handling/
├── error_boundary.dart          # Error boundary widgets
├── error_reporter.dart          # Crashlytics integration
├── error_types.dart             # Custom error types
├── error_fallback_ui.dart       # Error UI components
├── error_handler_mixin.dart     # Helper mixins
├── index.dart                   # Exports
└── README.md                    # This file
```

## Performance

- Error boundaries add minimal overhead (~1ms)
- Crashlytics reporting is async and non-blocking
- Error UI is lazy-loaded only when needed
- No impact on normal app flow

## Accessibility

All error UI components include:
- Semantic labels for screen readers
- Clear, actionable error messages
- Keyboard-accessible retry buttons
- High contrast error colors
- Focus management

## Troubleshooting

### Errors Not Reported to Crashlytics

1. Check Firebase is initialized
2. Verify Crashlytics is enabled in Firebase Console
3. Run app in release mode (debug reports may be delayed)
4. Check internet connection

### Error Boundary Not Catching Errors

1. Ensure error occurs in child widget tree
2. Check `shouldCapture` predicate if used
3. Verify error boundary wraps the failing widget
4. Use `RootErrorBoundary` for global catching

### Custom Error Messages Not Showing

1. Add to localization files
2. Implement `userFriendlyMessage` extension
3. Provide `customErrorMessage` to error handler
