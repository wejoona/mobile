# Error Handling Quick Reference

Quick reference for error handling patterns in the JoonaPay mobile app.

---

## Basic Error Handling

### In a Provider

```dart
import '../../../utils/error_messages.dart';
import '../../../services/api/api_client.dart';

class MyNotifier extends Notifier<MyState> {
  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final data = await _service.getData();
      state = state.copyWith(isLoading: false, data: data);
    } on ApiException catch (e) {
      final errorKey = ErrorMessages.fromApiException(e);
      state = state.copyWith(isLoading: false, error: errorKey);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'error_generic',
      );
    }
  }
}
```

### In a Widget

```dart
import '../utils/error_handler_mixin.dart';

class MyView extends ConsumerWidget with ErrorHandlerMixin {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Show error toast
    ref.listen<MyState>(myProvider, (prev, next) {
      if (next.error != null) {
        showErrorToast(context, ApiException(message: next.error!));
      }
    });

    // Or use error state widget
    final state = ref.watch(myProvider);
    if (state.error != null) {
      return ErrorStateWidget(
        errorKey: state.error,
        onRetry: () => ref.refresh(myProvider),
      );
    }

    return YourWidget();
  }
}
```

---

## Common Patterns

### Pattern 1: Simple Error Toast

```dart
try {
  await sdk.wallet.transfer(amount: 100);
  AppToast.success(context, l10n.transfer_success);
} on ApiException catch (e) {
  final errorKey = ErrorMessages.fromApiException(e);
  AppToast.error(context, l10n.translate(errorKey));
}
```

### Pattern 2: Error with Retry

```dart
final dataAsync = ref.watch(dataProvider);

return dataAsync.when(
  data: (data) => DataList(data),
  loading: () => LoadingStateWidget(),
  error: (error, stack) {
    final errorKey = error is ApiException
        ? ErrorMessages.fromApiException(error)
        : 'error_generic';

    return ErrorStateWidget(
      errorKey: errorKey,
      onRetry: ErrorMessages.canRetry(errorKey)
          ? () => ref.refresh(dataProvider)
          : null,
    );
  },
);
```

### Pattern 3: Error with Automatic Logout

```dart
try {
  await sdk.user.getProfile();
} on ApiException catch (e) {
  final errorKey = ErrorMessages.fromApiException(e);

  if (ErrorMessages.shouldLogout(errorKey)) {
    await ref.read(authProvider.notifier).logout();
    if (context.mounted) context.go('/login');
  } else {
    AppToast.error(context, l10n.translate(errorKey));
  }
}
```

### Pattern 4: Error with KYC Redirect

```dart
try {
  await sdk.wallet.transfer(amount: 1000);
} on ApiException catch (e) {
  final errorKey = ErrorMessages.fromApiException(e);

  if (errorKey == 'error_kycRequired') {
    final verify = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: AppText(l10n.kyc_required),
        content: AppText(l10n.error_kycRequired),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: AppText(l10n.common_cancel),
          ),
          AppButton(
            label: l10n.kyc_verify,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (verify == true && context.mounted) {
      context.push('/kyc');
    }
  }
}
```

### Pattern 5: Retry with Exponential Backoff

```dart
Future<Data> loadDataWithRetry({int attempt = 0}) async {
  try {
    return await _service.getData();
  } on ApiException catch (e) {
    final errorKey = ErrorMessages.fromApiException(e);

    if (ErrorMessages.canRetry(errorKey) && attempt < 3) {
      await Future.delayed(Duration(seconds: 2 << attempt));
      return loadDataWithRetry(attempt: attempt + 1);
    }

    rethrow;
  }
}
```

---

## Widget Examples

### Error State

```dart
ErrorStateWidget(
  errorKey: 'error_network',
  onRetry: () => ref.refresh(dataProvider),
)
```

### Empty State

```dart
EmptyStateWidget(
  icon: Icons.inbox,
  title: l10n.inbox_empty,
  message: l10n.inbox_emptyMessage,
  actionLabel: l10n.inbox_refresh,
  onAction: () => ref.refresh(inboxProvider),
)
```

### Offline Banner

```dart
if (isOffline)
  OfflineBanner(
    onRetry: () => ref.refresh(dataProvider),
  )
```

### Loading State

```dart
LoadingStateWidget(
  message: l10n.loading_pleaseWait,
)
```

---

## Error Key Lookup

### Network Errors
- `error_network` - Network error
- `error_timeout` - Request timeout
- `error_noInternet` - No internet
- `error_sslError` - SSL error

### Auth Errors
- `error_sessionExpired` - Session expired
- `error_accountLocked` - Account locked
- `error_accountSuspended` - Account suspended
- `error_invalidCredentials` - Invalid credentials

### KYC Errors
- `error_kycRequired` - KYC required
- `error_kycPending` - KYC pending
- `error_kycRejected` - KYC rejected

### Transaction Errors
- `error_insufficientBalance` - Insufficient balance
- `error_dailyLimitExceeded` - Daily limit exceeded
- `error_amountTooLow` - Amount too low
- `error_amountTooHigh` - Amount too high

### Provider Errors
- `error_providerUnavailable` - Provider unavailable
- `error_providerTimeout` - Provider timeout
- `error_providerMaintenance` - Provider maintenance

---

## Utility Methods

### ErrorMessages

```dart
// Map exception to error key
final errorKey = ErrorMessages.fromApiException(apiException);
final errorKey = ErrorMessages.fromDioException(dioException);
final errorKey = ErrorMessages.fromException(exception);

// Get action suggestion
final suggestion = ErrorMessages.getActionSuggestion(errorKey);

// Check error properties
final shouldLogout = ErrorMessages.shouldLogout(errorKey);
final canRetry = ErrorMessages.canRetry(errorKey);
final severity = ErrorMessages.getSeverity(errorKey);
```

### ErrorHandlerMixin

```dart
class MyView extends ConsumerWidget with ErrorHandlerMixin {
  void handleError(BuildContext context, Exception error) {
    // Show toast
    showErrorToast(context, error);

    // Or show dialog
    showErrorDialog(context, error, onRetry: () => retry());

    // Or auto-handle
    handleError(context, error, useDialog: true);
  }
}
```

### Extension Methods

```dart
try {
  await doSomething();
} on Exception catch (e) {
  final errorKey = e.errorKey;
  final canRetry = e.canRetry;
  final shouldLogout = e.shouldLogout;
  final severity = e.severity;
}
```

---

## Best Practices

### DO ✅

- Use `ErrorMessages.fromApiException()` for API errors
- Show user-friendly messages, not technical errors
- Provide retry for network/timeout errors
- Handle session expiration gracefully
- Log errors for debugging (without sensitive data)
- Test all error states

### DON'T ❌

- Show technical error messages to users
- Use generic "Something went wrong" messages
- Block UI without retry option for network errors
- Log sensitive data (tokens, PINs, passwords)
- Forget to handle offline mode
- Ignore error severity levels

---

## Checklist

When handling a new error scenario:

- [ ] Map error code/type in `ErrorMessages`
- [ ] Add English message to `app_en.arb`
- [ ] Add French translation to `app_fr.arb`
- [ ] Run `flutter gen-l10n`
- [ ] Handle error in provider
- [ ] Show appropriate UI feedback
- [ ] Add retry if applicable
- [ ] Test in both languages
- [ ] Test offline behavior

---

## Common Mistakes

### Mistake 1: Not handling specific errors

```dart
// ❌ Bad
try {
  await doSomething();
} catch (e) {
  AppToast.error(context, 'Error: $e');
}

// ✅ Good
try {
  await doSomething();
} on ApiException catch (e) {
  final errorKey = ErrorMessages.fromApiException(e);
  AppToast.error(context, l10n.translate(errorKey));
} catch (e) {
  AppToast.error(context, l10n.error_generic);
}
```

### Mistake 2: Not providing context

```dart
// ❌ Bad
"Failed to load"

// ✅ Good
"Unable to load your balance. Pull down to refresh or try again later."
```

### Mistake 3: Not handling offline

```dart
// ❌ Bad - no offline handling
final dataAsync = ref.watch(dataProvider);

// ✅ Good - shows cached data when offline
final dataAsync = ref.watch(dataProvider);
final isOffline = ref.watch(connectivityProvider).value == ConnectivityResult.none;

if (isOffline && cachedData != null) {
  return Column(
    children: [
      OfflineBanner(),
      DataList(cachedData),
    ],
  );
}
```

### Mistake 4: Not clearing errors

```dart
// ❌ Bad - error persists after retry
void retry() {
  loadData();
}

// ✅ Good - clear error before retry
void retry() {
  state = state.copyWith(error: null);
  loadData();
}
```

---

## Testing

### Test Error States

```dart
testWidgets('shows error state when data fails to load', (tester) async {
  final container = ProviderContainer(
    overrides: [
      dataProvider.overrideWith((ref) async {
        throw ApiException(message: 'Network error');
      }),
    ],
  );

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MyApp(),
    ),
  );

  await tester.pumpAndSettle();

  expect(find.byType(ErrorStateWidget), findsOneWidget);
  expect(find.text('Unable to connect'), findsOneWidget);
});
```

---

## Quick Reference Card

| Need | Use |
|------|-----|
| Map API error | `ErrorMessages.fromApiException(e)` |
| Map network error | `ErrorMessages.fromDioException(e)` |
| Show error toast | `AppToast.error(context, message)` |
| Show error state | `ErrorStateWidget(errorKey: key)` |
| Show empty state | `EmptyStateWidget(...)` |
| Show offline banner | `OfflineBanner(...)` |
| Get suggestion | `ErrorMessages.getActionSuggestion(key)` |
| Check if retryable | `ErrorMessages.canRetry(key)` |
| Check if should logout | `ErrorMessages.shouldLogout(key)` |

---

**For full documentation, see:**
- `ERROR_HANDLING_GUIDE.md` - Complete guide
- `ERROR_MESSAGES_AUDIT_REPORT.md` - Audit results
- `/lib/utils/error_messages.dart` - Source code
