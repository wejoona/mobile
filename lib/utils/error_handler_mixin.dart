import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../design/components/primitives/app_toast.dart';
import '../services/api/api_client.dart';
import 'error_messages.dart';

/// Error Handler Mixin
///
/// Provides convenient error handling methods for widgets and providers.
/// Simplifies common error handling patterns.
///
/// Usage in StatefulWidget or ConsumerWidget:
/// ```dart
/// class MyView extends ConsumerStatefulWidget with ErrorHandlerMixin {
///   @override
///   void handleError(BuildContext context, Exception error) {
///     showErrorToast(context, error);
///   }
/// }
/// ```
mixin ErrorHandlerMixin {
  /// Show error as toast notification
  void showErrorToast(BuildContext context, Exception error) {
    if (!context.mounted) return;

    final l10n = AppLocalizations.of(context)!;
    final errorKey = ErrorMessages.fromException(error);
    final message = _getLocalizedMessage(l10n, errorKey);

    // Get suggestion if available
    final suggestion = ErrorMessages.getActionSuggestion(errorKey);
    final fullMessage = suggestion != null
        ? '$message\n${_getLocalizedMessage(l10n, suggestion)}'
        : message;

    AppToast.error(context, fullMessage);
  }

  /// Show error as dialog
  Future<void> showErrorDialog(
    BuildContext context,
    Exception error, {
    String? title,
    VoidCallback? onRetry,
  }) async {
    if (!context.mounted) return;

    final l10n = AppLocalizations.of(context)!;
    final errorKey = ErrorMessages.fromException(error);
    final message = _getLocalizedMessage(l10n, errorKey);
    final dialogTitle = title ?? l10n.common_error;

    final canRetry = ErrorMessages.canRetry(errorKey);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          dialogTitle,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.common_close),
          ),
          if (canRetry && onRetry != null)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onRetry();
              },
              child: Text(l10n.common_retry),
            ),
        ],
      ),
    );
  }

  /// Handle error with appropriate action (toast vs dialog)
  Future<void> handleError(
    BuildContext context,
    Exception error, {
    bool useDialog = false,
    VoidCallback? onRetry,
  }) async {
    if (!context.mounted) return;

    final errorKey = ErrorMessages.fromException(error);

    // Use dialog for critical errors
    if (useDialog || ErrorMessages.getSeverity(errorKey) == ErrorSeverity.critical) {
      await showErrorDialog(context, error, onRetry: onRetry);
    } else {
      showErrorToast(context, error);
    }

    // Handle logout if needed
    if (ErrorMessages.shouldLogout(errorKey)) {
      // Note: Actual logout implementation should be handled by caller
      // This is just a flag check
    }
  }

  /// Get localized error message
  String getErrorMessage(BuildContext context, Exception error) {
    final l10n = AppLocalizations.of(context)!;
    final errorKey = ErrorMessages.fromException(error);
    return _getLocalizedMessage(l10n, errorKey);
  }

  /// Get localized error message with suggestion
  String getErrorMessageWithSuggestion(BuildContext context, Exception error) {
    final l10n = AppLocalizations.of(context)!;
    final errorKey = ErrorMessages.fromException(error);
    final message = _getLocalizedMessage(l10n, errorKey);
    final suggestion = ErrorMessages.getActionSuggestion(errorKey);

    if (suggestion != null) {
      return '$message\n${_getLocalizedMessage(l10n, suggestion)}';
    }

    return message;
  }

  String _getLocalizedMessage(AppLocalizations l10n, String key) {
    // Map error keys to localized messages
    switch (key) {
      // Network errors
      case 'error_generic':
        return l10n.error_generic;
      case 'error_network':
        return l10n.error_network;
      case 'error_timeout':
        return l10n.error_timeout;
      case 'error_noInternet':
        return l10n.error_noInternet;
      case 'error_requestCancelled':
        return l10n.error_requestCancelled;
      case 'error_sslError':
        return l10n.error_sslError;

      // Auth errors
      case 'error_otpExpired':
        return l10n.error_otpExpired;
      case 'error_tooManyOtpAttempts':
        return l10n.error_tooManyOtpAttempts;
      case 'error_invalidCredentials':
        return l10n.error_invalidCredentials;
      case 'error_accountLocked':
        return l10n.error_accountLocked;
      case 'error_accountSuspended':
        return l10n.error_accountSuspended;
      case 'error_sessionExpired':
        return l10n.error_sessionExpired;

      // KYC errors
      case 'error_kycRequired':
        return l10n.error_kycRequired;
      case 'error_kycPending':
        return l10n.error_kycPending;
      case 'error_kycRejected':
        return l10n.error_kycRejected;
      case 'error_kycExpired':
        return l10n.error_kycExpired;

      // Transaction errors
      case 'error_amountTooLow':
        return l10n.error_amountTooLow;
      case 'error_amountTooHigh':
        return l10n.error_amountTooHigh;
      case 'error_dailyLimitExceeded':
        return l10n.error_dailyLimitExceeded;
      case 'error_monthlyLimitExceeded':
        return l10n.error_monthlyLimitExceeded;
      case 'error_transactionLimitExceeded':
        return l10n.error_transactionLimitExceeded;
      case 'error_duplicateTransaction':
        return l10n.error_duplicateTransaction;
      case 'error_insufficientBalance':
        return l10n.error_insufficientBalance;

      // PIN errors
      case 'error_pinIncorrect':
        return l10n.error_pinIncorrect;
      case 'error_pinLocked':
        return l10n.error_pinLocked;
      case 'error_pinTooWeak':
        return l10n.error_pinTooWeak;

      // Provider errors
      case 'error_providerUnavailable':
        return l10n.error_providerUnavailable;
      case 'error_providerTimeout':
        return l10n.error_providerTimeout;
      case 'error_providerMaintenance':
        return l10n.error_providerMaintenance;

      // HTTP status errors
      case 'error_badRequest':
        return l10n.error_badRequest;
      case 'error_unauthorized':
        return l10n.error_unauthorized;
      case 'error_accessDenied':
        return l10n.error_accessDenied;
      case 'error_notFound':
        return l10n.error_notFound;
      case 'error_conflict':
        return l10n.error_conflict;
      case 'error_validationFailed':
        return l10n.error_validationFailed;
      case 'error_rateLimited':
        return l10n.error_rateLimited;
      case 'error_serverError':
        return l10n.error_serverError;
      case 'error_serviceUnavailable':
        return l10n.error_serviceUnavailable;
      case 'error_gatewayTimeout':
        return l10n.error_gatewayTimeout;

      // Other errors
      case 'error_failedToLoadBalance':
        return l10n.error_failedToLoadBalance;
      case 'error_failedToLoadTransactions':
        return l10n.error_failedToLoadTransactions;
      case 'error_biometricFailed':
        return l10n.error_biometricFailed;
      case 'error_transferFailed':
        return l10n.error_transferFailed;

      // Suggestions
      case 'error_suggestion_checkConnection':
        return l10n.error_suggestion_checkConnection;
      case 'error_suggestion_tryAgain':
        return l10n.error_suggestion_tryAgain;
      case 'error_suggestion_loginAgain':
        return l10n.error_suggestion_loginAgain;
      case 'error_suggestion_completeKyc':
        return l10n.error_suggestion_completeKyc;
      case 'error_suggestion_addFunds':
        return l10n.error_suggestion_addFunds;
      case 'error_suggestion_waitOrUpgrade':
        return l10n.error_suggestion_waitOrUpgrade;
      case 'error_suggestion_tryLater':
        return l10n.error_suggestion_tryLater;
      case 'error_suggestion_resetPin':
        return l10n.error_suggestion_resetPin;
      case 'error_suggestion_slowDown':
        return l10n.error_suggestion_slowDown;

      default:
        return l10n.error_generic;
    }
  }
}

/// Provider Error Handler
///
/// Extension methods for handling errors in Riverpod providers.
extension ProviderErrorHandler on Exception {
  /// Get error key for this exception
  String get errorKey => ErrorMessages.fromException(this);

  /// Check if this error should trigger logout
  bool get shouldLogout => ErrorMessages.shouldLogout(errorKey);

  /// Check if this error can be retried
  bool get canRetry => ErrorMessages.canRetry(errorKey);

  /// Get error severity
  ErrorSeverity get severity => ErrorMessages.getSeverity(errorKey);

  /// Get action suggestion key (if any)
  String? get actionSuggestion => ErrorMessages.getActionSuggestion(errorKey);
}
