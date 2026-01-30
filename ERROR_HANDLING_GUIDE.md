# Error Handling Guide

This guide explains error handling patterns, error message strategies, and best practices for the JoonaPay mobile app.

## Table of Contents

1. [Error Message Principles](#error-message-principles)
2. [Error Messages Utility](#error-messages-utility)
3. [When to Show Errors](#when-to-show-errors)
4. [Retry Patterns](#retry-patterns)
5. [Offline Fallbacks](#offline-fallbacks)
6. [Error Recovery](#error-recovery)
7. [Examples](#examples)

---

## Error Message Principles

### User-Friendly

**DON'T:**
- "ApiException: Failed with status code 422"
- "DioException: Connection timeout"
- "Something went wrong"

**DO:**
- "Unable to connect. Please check your internet connection and try again."
- "Request timed out. Please check your connection and try again."
- "We encountered an issue. Please try again in a moment."

### Actionable

Every error should tell the user what to do next.

**DON'T:**
- "Daily limit exceeded"
- "KYC required"

**DO:**
- "Daily transaction limit reached. Try again tomorrow or upgrade your account."
- "Identity verification required to continue. Complete verification in settings."

### Specific

Avoid generic messages when you have context.

**DON'T:**
- "Failed to load" (for everything)
- "Error occurred"

**DO:**
- "Unable to load your balance. Pull down to refresh or try again later."
- "Unable to load transactions. Pull down to refresh or try again later."
- "Service provider is currently unavailable. Please try again later."

### Localized

All error messages must be in both English and French.

---

## Error Messages Utility

### Usage

```dart
import 'package:your_app/utils/error_messages.dart';

// In a catch block
try {
  await sdk.wallet.getBalance();
} on ApiException catch (e) {
  final errorKey = ErrorMessages.fromApiException(e);
  final message = l10n.translate(errorKey);

  // Show error with suggestion
  final suggestion = ErrorMessages.getActionSuggestion(errorKey);
  if (suggestion != null) {
    AppToast.error(context, '$message\n${l10n.translate(suggestion)}');
  } else {
    AppToast.error(context, message);
  }
} on DioException catch (e) {
  final errorKey = ErrorMessages.fromDioException(e);
  AppToast.error(context, l10n.translate(errorKey));
}
```

### API

#### `fromApiException(ApiException)`

Maps `ApiException` to localized error message key. Checks backend error codes first, then falls back to HTTP status codes.

#### `fromDioException(DioException)`

Maps `DioException` (network errors) to localized error message key.

#### `fromException(Exception)`

General exception mapper. Detects exception type and routes to appropriate handler.

#### `getActionSuggestion(String errorKey)`

Returns an actionable suggestion key (or `null`) for the given error.

Examples:
- `error_noInternet` → `error_suggestion_checkConnection`
- `error_kycRequired` → `error_suggestion_completeKyc`
- `error_insufficientBalance` → `error_suggestion_addFunds`

#### `shouldLogout(String errorKey)`

Returns `true` if the error should trigger logout.

Examples: `error_sessionExpired`, `error_accountLocked`, `error_accountSuspended`

#### `canRetry(String errorKey)`

Returns `true` if the error is retryable (network/timeout errors).

#### `getSeverity(String errorKey)`

Returns error severity level:
- `ErrorSeverity.info` - Temporary issues, can retry
- `ErrorSeverity.warning` - User action needed
- `ErrorSeverity.error` - Standard errors
- `ErrorSeverity.critical` - Account-level issues

---

## When to Show Errors

### Snackbar vs Dialog vs Inline

#### Use Snackbar (AppToast) For:
- ✅ Transient errors (network, timeout)
- ✅ Non-critical errors
- ✅ Success messages
- ✅ Background operation failures

```dart
AppToast.error(context, l10n.error_network);
```

#### Use Dialog For:
- ✅ Critical errors (account locked, suspended)
- ✅ Errors requiring user decision
- ✅ Session expired (with login redirect)

```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: AppText(l10n.error_sessionExpired_title),
    content: AppText(l10n.error_sessionExpired),
    actions: [
      AppButton(
        label: l10n.common_login,
        onPressed: () {
          context.go('/login');
        },
      ),
    ],
  ),
);
```

#### Use Inline Errors For:
- ✅ Form validation errors
- ✅ Input-specific errors
- ✅ Real-time feedback

```dart
AppInput(
  label: l10n.auth_phoneNumber,
  errorText: state.phoneError,
  validator: (v) => v?.isEmpty == true ? l10n.error_phoneRequired : null,
)
```

### Empty States vs Error States

#### Empty State
Use when there's no data but no error (e.g., no transactions yet).

```dart
if (transactions.isEmpty) {
  return EmptyStateWidget(
    icon: Icons.history,
    title: l10n.transactions_emptyTitle,
    message: l10n.transactions_emptyMessage,
  );
}
```

#### Error State
Use when data loading failed.

```dart
if (state.hasError) {
  return ErrorStateWidget(
    icon: Icons.error_outline,
    title: l10n.transactions_errorTitle,
    message: l10n.error_failedToLoadTransactions,
    onRetry: () => ref.refresh(transactionsProvider),
  );
}
```

---

## Retry Patterns

### Automatic Retry (Provider-Level)

For critical operations, implement automatic retry with exponential backoff.

```dart
class WalletNotifier extends Notifier<WalletState> {
  Future<void> loadBalance({int retryCount = 0}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final balance = await _service.getBalance();
      state = state.copyWith(isLoading: false, balance: balance);
    } on ApiException catch (e) {
      final errorKey = ErrorMessages.fromApiException(e);

      // Retry network errors up to 3 times
      if (ErrorMessages.canRetry(errorKey) && retryCount < 3) {
        await Future.delayed(Duration(seconds: 2 << retryCount)); // 2s, 4s, 8s
        return loadBalance(retryCount: retryCount + 1);
      }

      state = state.copyWith(isLoading: false, error: errorKey);
    }
  }
}
```

### Manual Retry (UI-Level)

For user-initiated operations, show retry button.

```dart
if (state.hasError) {
  return Column(
    children: [
      AppText(l10n.translate(state.error!)),
      SizedBox(height: AppSpacing.md),
      if (ErrorMessages.canRetry(state.error!))
        AppButton(
          label: l10n.common_retry,
          onPressed: () => ref.read(walletProvider.notifier).loadBalance(),
        ),
    ],
  );
}
```

### Pull-to-Refresh

For list screens, implement pull-to-refresh for easy retry.

```dart
RefreshIndicator(
  onRefresh: () async {
    ref.invalidate(transactionsProvider);
    // Wait for provider to reload
    await ref.read(transactionsProvider.future);
  },
  child: ListView.builder(...),
)
```

---

## Offline Fallbacks

### Detect Offline Mode

```dart
import 'package:connectivity_plus/connectivity_plus.dart';

final connectivityProvider = StreamProvider<ConnectivityResult>((ref) {
  return Connectivity().onConnectivityChanged;
});

// In widget
final connectivity = ref.watch(connectivityProvider);
final isOffline = connectivity.value == ConnectivityResult.none;

if (isOffline) {
  return OfflineBar(
    message: l10n.error_offline_message,
    onRetry: () => ref.refresh(walletBalanceProvider),
  );
}
```

### Cache Strategy

Use cached data when offline:

```dart
final walletBalanceProvider = FutureProvider<WalletBalanceResponse>((ref) async {
  final service = ref.watch(walletServiceProvider);
  final connectivity = ref.watch(connectivityProvider);

  try {
    final balance = await service.getBalance();
    // Cache the result
    ref.read(balanceCacheProvider.notifier).set(balance);
    return balance;
  } catch (e) {
    // If offline, return cached data
    if (connectivity.value == ConnectivityResult.none) {
      final cached = ref.read(balanceCacheProvider);
      if (cached != null) return cached;
    }
    rethrow;
  }
});
```

### Show Cached Data Indicator

```dart
if (isUsingCache) {
  Row(
    children: [
      Icon(Icons.cloud_off, size: 16),
      SizedBox(width: AppSpacing.xs),
      AppText(l10n.offline_cachedData),
    ],
  );
}
```

---

## Error Recovery

### Session Expired

Automatically redirect to login:

```dart
if (ErrorMessages.shouldLogout(errorKey)) {
  // Clear tokens
  final storage = ref.read(secureStorageProvider);
  await storage.delete(key: StorageKeys.accessToken);
  await storage.delete(key: StorageKeys.refreshToken);

  // Navigate to login
  if (context.mounted) {
    context.go('/login');
  }
}
```

### KYC Required

Navigate to KYC flow:

```dart
if (errorKey == 'error_kycRequired') {
  final shouldVerify = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: AppText(l10n.kyc_required_title),
      content: AppText(l10n.error_kycRequired),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: AppText(l10n.common_cancel),
        ),
        AppButton(
          label: l10n.kyc_startVerification,
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    ),
  );

  if (shouldVerify == true && context.mounted) {
    context.push('/kyc');
  }
}
```

### Limit Exceeded

Show upgrade prompt:

```dart
if (errorKey == 'error_dailyLimitExceeded') {
  final shouldUpgrade = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: AppText(l10n.limit_exceeded_title),
      content: AppText(l10n.error_dailyLimitExceeded),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: AppText(l10n.common_cancel),
        ),
        AppButton(
          label: l10n.account_upgrade,
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    ),
  );

  if (shouldUpgrade == true && context.mounted) {
    context.push('/settings/upgrade');
  }
}
```

---

## Examples

### Example 1: Send Money Flow

```dart
class SendMoneyNotifier extends Notifier<SendMoneyState> {
  Future<void> send() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _service.sendMoney(
        recipientPhone: state.recipientPhone,
        amount: state.amount,
      );

      state = state.copyWith(
        isLoading: false,
        success: true,
        transactionId: result.id,
      );
    } on ApiException catch (e) {
      final errorKey = ErrorMessages.fromApiException(e);
      state = state.copyWith(isLoading: false, error: errorKey);

      // Handle specific errors
      if (ErrorMessages.shouldLogout(errorKey)) {
        // Session expired - logout
        ref.read(authProvider.notifier).logout();
      }
    } catch (e) {
      final errorKey = ErrorMessages.fromException(e as Exception);
      state = state.copyWith(isLoading: false, error: errorKey);
    }
  }
}

// In UI
class SendMoneyView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(sendMoneyProvider);

    // Listen for errors
    ref.listen<SendMoneyState>(sendMoneyProvider, (prev, next) {
      if (next.error != null) {
        final message = l10n.translate(next.error!);
        final suggestion = ErrorMessages.getActionSuggestion(next.error!);

        if (suggestion != null) {
          AppToast.error(context, '$message\n${l10n.translate(suggestion)}');
        } else {
          AppToast.error(context, message);
        }
      }
    });

    return Scaffold(
      body: Column(
        children: [
          // Form fields...
          AppButton(
            label: l10n.send_confirm,
            onPressed: state.isLoading ? null : () {
              ref.read(sendMoneyProvider.notifier).send();
            },
            isLoading: state.isLoading,
          ),
        ],
      ),
    );
  }
}
```

### Example 2: Load Transactions with Retry

```dart
final transactionsProvider = FutureProvider<List<Transaction>>((ref) async {
  final service = ref.watch(transactionsServiceProvider);

  // Implement retry logic
  int attempts = 0;
  const maxAttempts = 3;

  while (attempts < maxAttempts) {
    try {
      return await service.getTransactions();
    } on ApiException catch (e) {
      final errorKey = ErrorMessages.fromApiException(e);

      // Only retry network errors
      if (ErrorMessages.canRetry(errorKey) && attempts < maxAttempts - 1) {
        attempts++;
        await Future.delayed(Duration(seconds: 2 << attempts));
        continue;
      }

      rethrow;
    }
  }

  throw Exception('Max retry attempts exceeded');
});

// In UI
class TransactionsView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final transactionsAsync = ref.watch(transactionsProvider);

    return transactionsAsync.when(
      data: (transactions) => ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) => TransactionCard(transactions[index]),
      ),
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stack) {
        final errorKey = error is ApiException
            ? ErrorMessages.fromApiException(error)
            : ErrorMessages.fromException(error as Exception);

        return ErrorStateWidget(
          icon: Icons.error_outline,
          title: l10n.transactions_errorTitle,
          message: l10n.translate(errorKey),
          onRetry: ErrorMessages.canRetry(errorKey)
              ? () => ref.refresh(transactionsProvider)
              : null,
        );
      },
    );
  }
}
```

### Example 3: Offline Detection

```dart
class HomeView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final connectivity = ref.watch(connectivityProvider);
    final isOffline = connectivity.value == ConnectivityResult.none;

    return Scaffold(
      body: Column(
        children: [
          // Show offline banner
          if (isOffline)
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              color: AppColors.warning,
              child: Row(
                children: [
                  Icon(Icons.cloud_off, color: AppColors.obsidian),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppText(
                      l10n.error_offline_message,
                      style: AppTypography.bodySmall,
                    ),
                  ),
                  TextButton(
                    onPressed: () => ref.refresh(walletBalanceProvider),
                    child: AppText(l10n.error_offline_retry),
                  ),
                ],
              ),
            ),

          // Main content...
        ],
      ),
    );
  }
}
```

---

## Best Practices Checklist

### Error Messages

- [ ] Never show technical error messages to users
- [ ] Always provide context (what failed)
- [ ] Always provide action (what to do next)
- [ ] Use ErrorMessages utility for consistent mapping
- [ ] Ensure both English and French translations exist
- [ ] Test all error states in UI

### Error Handling

- [ ] Catch specific exceptions (ApiException, DioException)
- [ ] Provide fallback for unexpected exceptions
- [ ] Log errors for debugging (in development)
- [ ] Don't log sensitive data (tokens, PINs)
- [ ] Implement retry for network errors
- [ ] Handle session expiration gracefully
- [ ] Clear sensitive data on critical errors

### User Experience

- [ ] Show loading states during operations
- [ ] Disable buttons during async operations
- [ ] Provide clear feedback on error
- [ ] Allow retry for retryable errors
- [ ] Cache data for offline viewing
- [ ] Show offline indicator when appropriate
- [ ] Don't block UI unnecessarily

---

## Error Message Localization Keys

All error keys are prefixed with `error_` and available in:
- `/lib/l10n/app_en.arb` (English)
- `/lib/l10n/app_fr.arb` (French)

Run `flutter gen-l10n` after adding new keys.

### Common Error Keys

| Key | English | Usage |
|-----|---------|-------|
| `error_generic` | We encountered an issue... | Fallback for unknown errors |
| `error_network` | Unable to connect... | Network connectivity issues |
| `error_timeout` | Request timed out... | Request timeout |
| `error_noInternet` | No internet connection... | Offline mode |
| `error_sessionExpired` | Your session has expired... | Session expired |
| `error_kycRequired` | Identity verification required... | KYC required |
| `error_insufficientBalance` | Insufficient balance | Not enough funds |
| `error_dailyLimitExceeded` | Daily transaction limit reached... | Limit exceeded |

See full list in `/lib/l10n/app_en.arb`.

---

## Summary

1. **Use ErrorMessages utility** for consistent error mapping
2. **Show user-friendly messages** - no technical jargon
3. **Provide actionable feedback** - tell users what to do
4. **Handle errors gracefully** - retry, cache, fallback
5. **Test all error states** - network, timeout, server errors
6. **Localize everything** - English and French

Following these patterns ensures a consistent, user-friendly error handling experience across the entire app.
