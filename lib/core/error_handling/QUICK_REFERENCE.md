# Error Handling Quick Reference

One-page cheat sheet for common error handling patterns.

## Import

```dart
import '../../core/error_handling/index.dart';
```

## Wrap Screen

```dart
ErrorBoundary(
  errorContext: 'ScreenName',
  child: MyScreen(),
)
```

## Widget with Async Operations

```dart
class MyWidget extends ConsumerStatefulWidget {...}

class MyWidgetState extends ConsumerState<MyWidget>
    with ErrorHandlerMixin {

  Future<void> _loadData() async {
    await handleAsyncError(() async {
      final data = await api.getData();
      setState(() => _data = data);
    }, context: 'LoadData');
  }
}
```

## Provider/Notifier

```dart
class MyNotifier extends Notifier<MyState>
    with NotifierErrorHandler {

  Future<void> loadData() async {
    await handleAsyncError(() async {
      final data = await api.getData();
      state = state.copyWith(data: data);
    }, context: 'MyNotifier.loadData');
  }
}
```

## FutureBuilder Replacement

```dart
AsyncErrorBoundary<List<Item>>(
  future: api.getItems(),
  builder: (context, items) => ItemList(items),
  errorContext: 'ItemList',
)
```

## Show Error Snackbar

```dart
// Simple
context.showErrorSnackbar('Error message');

// From exception
context.showError(error);

// With retry
SnackbarError.show(context, 'Failed', onRetry: _retry);
```

## Inline Error Display

```dart
if (state.error != null) {
  return CompactErrorWidget(
    message: state.error!,
    onRetry: _reload,
  );
}
```

## Empty State with Error

```dart
EmptyStateErrorWidget(
  title: 'No Data',
  message: 'Failed to load',
  onRetry: _reload,
)
```

## Manual Error Reporting

```dart
final errorReporter = ref.read(errorReporterProvider);

// Report error
await errorReporter.reportError(
  error,
  stackTrace,
  context: 'OperationName',
  severity: ErrorSeverity.error,
);

// Log breadcrumb
errorReporter.logBreadcrumb('User action', metadata: {...});
```

## Throw Custom Errors

```dart
// Network
throw const NetworkError('Connection failed');

// Auth
throw AuthError.sessionExpired;

// Validation
throw const ValidationError('Invalid input', field: 'email');

// Business
throw BusinessError.insufficientBalance;
```

## Get User-Friendly Message

```dart
final message = error.userFriendlyMessage;
```

## Set User Info (on login)

```dart
final errorReporter = ref.read(errorReporterProvider);
await errorReporter.setUserInfo(
  userId: user.id,
  email: user.email,
  phoneNumber: user.phoneNumber,
);
```

## Error Severity Levels

```dart
ErrorSeverity.info     // Informational
ErrorSeverity.warning  // Unexpected but handled
ErrorSeverity.error    // Real error
ErrorSeverity.fatal    // Critical error
```

## Common Patterns

### API Call

```dart
await handleAsyncError(() async {
  final result = await api.call();
  // Handle success
}, context: 'APICall');
```

### API Call with Result

```dart
final result = await handleAsyncErrorWithResult(
  () => api.call(),
  context: 'APICall',
);
if (result != null) {
  // Use result
}
```

### Custom Error Message

```dart
await handleAsyncError(
  () async {...},
  customErrorMessage: 'Custom user message',
);
```

### With Metadata

```dart
await errorReporter.reportError(
  error,
  stackTrace,
  context: 'Payment',
  metadata: {
    'amount': amount,
    'recipient': recipientId,
  },
);
```

## Error Type Checks

```dart
if (error.isNetworkError) {...}
if (error.isAuthError) {...}
if (error.isValidationError) {...}
if (error.isBusinessError) {...}
```

## Testing

```dart
testWidgets('shows error UI', (tester) async {
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

## When to Use What

| Scenario | Solution |
|----------|----------|
| Wrap entire app | `RootErrorBoundary` |
| Wrap screen/feature | `ErrorBoundary` |
| Widget async operation | `ErrorHandlerMixin` |
| Provider async operation | `NotifierErrorHandler` |
| Replace FutureBuilder | `AsyncErrorBoundary` |
| Show quick error | `SnackbarError.show()` |
| Inline error | `CompactErrorWidget` |
| Empty state error | `EmptyStateErrorWidget` |
| Manual reporting | `errorReporter.reportError()` |

## DO

✅ Wrap screens with ErrorBoundary
✅ Use ErrorHandlerMixin for async ops
✅ Show user-friendly messages
✅ Provide retry options
✅ Report errors to Crashlytics
✅ Add context to errors
✅ Set user info on login
✅ Clear user info on logout

## DON'T

❌ Wrap every widget (only screens)
❌ Show stack traces to users
❌ Report validation errors
❌ Swallow errors silently
❌ Use generic error messages
❌ Forget to add context
❌ Over-report trivial issues
❌ Let errors crash the app
