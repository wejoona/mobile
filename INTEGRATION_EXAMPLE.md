# Error Handling Integration Example

This document shows how to integrate the new error handling system into existing code.

---

## Example: Wallet Balance Screen

### Before (Old Pattern)

```dart
// wallet_provider.dart - OLD
class WalletNotifier extends Notifier<WalletState> {
  Future<void> loadBalance() async {
    state = state.copyWith(isLoading: true);

    try {
      final balance = await _service.getBalance();
      state = state.copyWith(isLoading: false, balance: balance);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load balance', // Generic message
      );
    }
  }
}

// wallet_view.dart - OLD
class WalletView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(walletProvider);

    if (state.error != null) {
      return Center(
        child: Text(state.error!), // Shows technical error
      );
    }

    return BalanceCard(balance: state.balance);
  }
}
```

### After (New Pattern)

```dart
// wallet_provider.dart - NEW
import '../../../utils/error_messages.dart';
import '../../../services/api/api_client.dart';

class WalletNotifier extends Notifier<WalletState> {
  Future<void> loadBalance() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final balance = await _service.getBalance();
      state = state.copyWith(isLoading: false, balance: balance);
    } on ApiException catch (e) {
      // Map to user-friendly error key
      final errorKey = ErrorMessages.fromApiException(e);
      state = state.copyWith(isLoading: false, error: errorKey);

      // Handle session expiration
      if (ErrorMessages.shouldLogout(errorKey)) {
        await ref.read(authProvider.notifier).logout();
      }
    } catch (e) {
      // Fallback for unexpected errors
      state = state.copyWith(
        isLoading: false,
        error: 'error_generic',
      );
    }
  }
}

// wallet_view.dart - NEW
import '../../../design/components/error_state_widget.dart';
import '../../../utils/error_messages.dart';

class WalletView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(walletProvider);

    // Handle error state with user-friendly UI
    if (state.error != null) {
      return ErrorStateWidget(
        errorKey: state.error,
        icon: Icons.account_balance_wallet,
        onRetry: ErrorMessages.canRetry(state.error!)
            ? () => ref.read(walletProvider.notifier).loadBalance()
            : null,
      );
    }

    // Handle loading state
    if (state.isLoading) {
      return LoadingStateWidget(
        message: l10n.wallet_loadingBalance,
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(walletProvider.notifier).loadBalance(),
      child: BalanceCard(balance: state.balance),
    );
  }
}
```

---

## Example: Send Money Flow

### Complete Implementation

```dart
// send_money_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/index.dart';
import '../../../utils/error_messages.dart';

class SendMoneyState {
  final bool isLoading;
  final String? error;
  final String? transactionId;
  final double? amount;
  final String? recipientPhone;

  const SendMoneyState({
    this.isLoading = false,
    this.error,
    this.transactionId,
    this.amount,
    this.recipientPhone,
  });

  SendMoneyState copyWith({
    bool? isLoading,
    String? error,
    String? transactionId,
    double? amount,
    String? recipientPhone,
  }) {
    return SendMoneyState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      transactionId: transactionId ?? this.transactionId,
      amount: amount ?? this.amount,
      recipientPhone: recipientPhone ?? this.recipientPhone,
    );
  }
}

class SendMoneyNotifier extends Notifier<SendMoneyState> {
  @override
  SendMoneyState build() => const SendMoneyState();

  void setAmount(double amount) {
    state = state.copyWith(amount: amount);
  }

  void setRecipient(String phone) {
    state = state.copyWith(recipientPhone: phone);
  }

  Future<bool> send() async {
    if (state.amount == null || state.recipientPhone == null) {
      state = state.copyWith(error: 'error_validationFailed');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await ref.read(sdkProvider).transfers.createInternalTransfer(
            recipientPhone: state.recipientPhone!,
            amount: state.amount!,
            description: 'Transfer',
          );

      state = state.copyWith(
        isLoading: false,
        transactionId: result.id,
      );

      return true;
    } on ApiException catch (e) {
      final errorKey = ErrorMessages.fromApiException(e);
      state = state.copyWith(isLoading: false, error: errorKey);

      // Handle specific errors
      if (ErrorMessages.shouldLogout(errorKey)) {
        await ref.read(authProvider.notifier).logout();
      }

      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'error_transferFailed',
      );
      return false;
    }
  }

  void reset() {
    state = const SendMoneyState();
  }
}

final sendMoneyProvider = NotifierProvider<SendMoneyNotifier, SendMoneyState>(
  SendMoneyNotifier.new,
);

// send_money_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../utils/error_handler_mixin.dart';
import '../../../utils/error_messages.dart';

class SendMoneyView extends ConsumerStatefulWidget {
  const SendMoneyView({super.key});

  @override
  ConsumerState<SendMoneyView> createState() => _SendMoneyViewState();
}

class _SendMoneyViewState extends ConsumerState<SendMoneyView>
    with ErrorHandlerMixin {
  final _amountController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(sendMoneyProvider);

    // Listen for errors and show appropriate feedback
    ref.listen<SendMoneyState>(sendMoneyProvider, (prev, next) {
      if (next.error != null) {
        final severity = ErrorMessages.getSeverity(next.error!);

        // Use dialog for critical errors, toast for others
        if (severity == ErrorSeverity.critical) {
          showErrorDialog(
            context,
            ApiException(message: next.error!),
          );
        } else {
          showErrorToast(context, ApiException(message: next.error!));
        }

        // Handle KYC requirement
        if (next.error == 'error_kycRequired') {
          _handleKycRequired(context, l10n);
        }

        // Handle limit exceeded
        if (next.error == 'error_dailyLimitExceeded' ||
            next.error == 'error_monthlyLimitExceeded') {
          _handleLimitExceeded(context, l10n);
        }
      }

      // Navigate on success
      if (next.transactionId != null && prev?.transactionId == null) {
        AppToast.success(context, l10n.transfer_success);
        Navigator.pop(context);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: AppText(l10n.send_title, style: AppTypography.headlineSmall),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              // Recipient Phone
              AppInput(
                label: l10n.send_recipient,
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone,
                onChanged: (value) {
                  ref.read(sendMoneyProvider.notifier).setRecipient(value);
                },
              ),

              SizedBox(height: AppSpacing.md),

              // Amount
              AppInput(
                label: l10n.send_amount,
                controller: _amountController,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.attach_money,
                onChanged: (value) {
                  final amount = double.tryParse(value);
                  if (amount != null) {
                    ref.read(sendMoneyProvider.notifier).setAmount(amount);
                  }
                },
              ),

              const Spacer(),

              // Send Button
              AppButton(
                label: l10n.send_confirm,
                onPressed: state.isLoading ? null : _handleSend,
                isLoading: state.isLoading,
                icon: Icons.send,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSend() async {
    final success = await ref.read(sendMoneyProvider.notifier).send();

    if (!success && mounted) {
      // Error is already handled by listener
      // Just provide haptic feedback
      HapticFeedback.mediumImpact();
    }
  }

  Future<void> _handleKycRequired(BuildContext context, AppLocalizations l10n) async {
    final shouldVerify = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.charcoal,
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
            size: ButtonSize.small,
          ),
        ],
      ),
    );

    if (shouldVerify == true && mounted) {
      Navigator.pushNamed(context, '/kyc');
    }
  }

  Future<void> _handleLimitExceeded(BuildContext context, AppLocalizations l10n) async {
    final shouldUpgrade = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.charcoal,
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
            size: ButtonSize.small,
          ),
        ],
      ),
    );

    if (shouldUpgrade == true && mounted) {
      Navigator.pushNamed(context, '/settings/upgrade');
    }
  }
}
```

---

## Example: Offline Detection

### Implementation

```dart
// connectivity_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final connectivityProvider = StreamProvider<ConnectivityResult>((ref) {
  return Connectivity().onConnectivityChanged;
});

final isOfflineProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return connectivity.value == ConnectivityResult.none;
});

// home_view.dart with offline detection
import '../../../design/components/error_state_widget.dart';
import '../providers/connectivity_provider.dart';

class HomeView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isOffline = ref.watch(isOfflineProvider);
    final balanceAsync = ref.watch(walletBalanceProvider);

    return Scaffold(
      body: Column(
        children: [
          // Offline Banner
          if (isOffline)
            OfflineBanner(
              onRetry: () => ref.refresh(walletBalanceProvider),
            ),

          // Content
          Expanded(
            child: balanceAsync.when(
              data: (balance) => BalanceCard(balance: balance),
              loading: () => LoadingStateWidget(),
              error: (error, stack) {
                // If offline, show cached data or offline message
                if (isOffline) {
                  return ErrorStateWidget(
                    errorKey: 'error_noInternet',
                    icon: Icons.cloud_off,
                    showRetry: true,
                    onRetry: () => ref.refresh(walletBalanceProvider),
                  );
                }

                // Otherwise, handle error normally
                final errorKey = error is ApiException
                    ? ErrorMessages.fromApiException(error)
                    : 'error_generic';

                return ErrorStateWidget(
                  errorKey: errorKey,
                  onRetry: ErrorMessages.canRetry(errorKey)
                      ? () => ref.refresh(walletBalanceProvider)
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## Migration Checklist

When updating an existing screen:

### 1. Update Provider

- [ ] Import `error_messages.dart`
- [ ] Change catch blocks to use `on ApiException`
- [ ] Map errors using `ErrorMessages.fromApiException()`
- [ ] Store error key instead of error message
- [ ] Handle `shouldLogout()` cases

### 2. Update View

- [ ] Import `error_state_widget.dart`
- [ ] Replace custom error displays with `ErrorStateWidget`
- [ ] Add `ErrorHandlerMixin` if using toast/dialogs
- [ ] Listen for errors in `ref.listen()`
- [ ] Handle specific errors (KYC, limits, etc.)

### 3. Add Offline Support

- [ ] Import connectivity provider
- [ ] Show `OfflineBanner` when offline
- [ ] Handle offline errors gracefully
- [ ] Consider caching strategies

### 4. Test

- [ ] Test with network errors (offline, timeout)
- [ ] Test with API errors (400, 401, 500)
- [ ] Test with specific errors (KYC, limits)
- [ ] Test in both English and French
- [ ] Test retry functionality
- [ ] Test error recovery flows

---

## Summary

The new error handling system provides:

1. **Centralized Mapping**: All errors go through `ErrorMessages` utility
2. **User-Friendly Messages**: No technical jargon, clear guidance
3. **Reusable Components**: `ErrorStateWidget`, `OfflineBanner`, etc.
4. **Consistent Patterns**: Same approach across all screens
5. **Localization Support**: English and French messages
6. **Actionable Feedback**: Suggestions for user next steps
7. **Error Recovery**: Automatic handling of session expiry, KYC, limits

By following these patterns, all screens will have consistent, user-friendly error handling.
