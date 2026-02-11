import 'package:flutter/material.dart';
import 'package:usdc_wallet/utils/accessibility_utils.dart';

/// Accessibility enhancements for the wallet home screen and critical flows
///
/// This file contains helper methods to add proper semantics to wallet components

class WalletAccessibility {
  WalletAccessibility._();

  /// Create semantic label for balance display
  static String balanceLabel(double amount, {bool isHidden = false}) {
    if (isHidden) {
      return 'Balance hidden, double tap balance visibility icon to show';
    }
    return 'Available balance: ${AccessibilityUtils.formatCurrencyForScreenReader(amount)}';
  }

  /// Create semantic label for transaction row
  static String transactionLabel({
    required String title,
    required double amount,
    required DateTime date,
    required bool isIncoming,
  }) {
    final amountLabel = AccessibilityUtils.formatCurrencyForScreenReader(amount.abs());
    final dateLabel = AccessibilityUtils.formatDateForScreenReader(date);
    final direction = isIncoming ? 'received' : 'sent';

    return '$title, $direction $amountLabel, $dateLabel';
  }

  /// Create semantic label for quick action button
  static String quickActionLabel(String action) {
    return '$action, button, double tap to $action';
  }

  /// Create semantic label for toggle visibility button
  static String balanceVisibilityLabel(bool isHidden) {
    return isHidden ? 'Show balance' : 'Hide balance';
  }

  /// Create semantic hint for balance visibility toggle
  static String balanceVisibilityHint(bool isHidden) {
    return 'Double tap to ${isHidden ? 'show' : 'hide'} your balance';
  }
}

class SendMoneyAccessibility {
  SendMoneyAccessibility._();

  /// Create semantic label for contact chip
  static String contactChipLabel({
    required String name,
    required bool isSelected,
    required bool hasApp,
  }) {
    final selection = isSelected ? 'Selected' : 'Not selected';
    final appStatus = hasApp ? 'JoonaPay user' : '';
    return '$name, $selection, $appStatus'.trim();
  }

  /// Create semantic label for amount input
  static String amountInputLabel(String amount) {
    if (amount.isEmpty) {
      return 'Enter amount in dollars';
    }
    final numAmount = double.tryParse(amount) ?? 0;
    return 'Amount: ${AccessibilityUtils.formatCurrencyForScreenReader(numAmount)}';
  }

  /// Create semantic label for phone input
  static String phoneInputLabel(String phone, String countryCode) {
    if (phone.isEmpty) {
      return 'Enter recipient phone number';
    }
    return 'Recipient: ${AccessibilityUtils.formatPhoneForScreenReader('$countryCode$phone')}';
  }

  /// Create semantic label for wallet address input
  static String walletAddressLabel(String address) {
    if (address.isEmpty) {
      return 'Enter recipient wallet address';
    }
    return 'Recipient: ${AccessibilityUtils.formatWalletAddressForScreenReader(address)}';
  }

  /// Create semantic label for validation error
  static String validationErrorLabel(String error) {
    return 'Error: $error';
  }
}

class AuthAccessibility {
  AuthAccessibility._();

  /// Create semantic label for country selector
  static String countrySelectorLabel({
    required String countryName,
    required String prefix,
    required String currency,
  }) {
    return 'Selected country: $countryName, phone code $prefix, currency $currency';
  }

  /// Create semantic label for phone number input
  static String phoneNumberInputLabel({
    required String phone,
    required int expectedLength,
    bool isValid = false,
  }) {
    if (phone.isEmpty) {
      return 'Enter your phone number, $expectedLength digits required';
    }

    final status = isValid ? 'valid' : 'invalid, ${phone.length} of $expectedLength digits entered';
    return 'Phone number: ${AccessibilityUtils.formatPhoneForScreenReader(phone)}, $status';
  }

  /// Create semantic label for OTP input
  static String otpInputLabel(String otp, int expectedLength) {
    if (otp.isEmpty) {
      return 'Enter verification code, $expectedLength digits required';
    }
    return 'Verification code: ${otp.split('').join(' ')}, ${otp.length} of $expectedLength entered';
  }

  /// Create semantic label for login/register toggle
  static String authModeToggleLabel(bool isRegistering) {
    return isRegistering
        ? 'Creating new account, double tap to switch to sign in'
        : 'Signing in, double tap to switch to create account';
  }
}

/// Widget wrapper for improved accessibility
class AccessibleWidget {
  /// Wrap a balance display with proper semantics
  static Widget balanceDisplay({
    required Widget child,
    required double amount,
    required bool isHidden,
  }) {
    return Semantics(
      label: WalletAccessibility.balanceLabel(amount, isHidden: isHidden),
      value: isHidden ? 'Hidden' : '\$${amount.toStringAsFixed(2)}',
      excludeSemantics: true,
      child: child,
    );
  }

  /// Wrap a transaction row with proper semantics
  static Widget transactionRow({
    required Widget child,
    required String title,
    required double amount,
    required DateTime date,
    required bool isIncoming,
    VoidCallback? onTap,
  }) {
    return Semantics(
      label: WalletAccessibility.transactionLabel(
        title: title,
        amount: amount,
        date: date,
        isIncoming: isIncoming,
      ),
      button: onTap != null,
      onTap: onTap,
      excludeSemantics: true,
      child: child,
    );
  }

  /// Wrap icon button with descriptive label
  static Widget iconButton({
    required Widget child,
    required String label,
    required String action,
    bool enabled = true,
  }) {
    return Semantics(
      label: label,
      hint: 'Double tap to $action',
      button: true,
      enabled: enabled,
      excludeSemantics: true,
      child: child,
    );
  }

  /// Wrap list tile with proper semantics
  static Widget listTile({
    required Widget child,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    final label = subtitle != null ? '$title, $subtitle' : title;
    return Semantics(
      label: label,
      button: onTap != null,
      onTap: onTap,
      excludeSemantics: true,
      child: child,
    );
  }

  /// Create a loading announcement
  static Widget loadingAnnouncement(String message) {
    return Semantics(
      liveRegion: true,
      label: message,
      child: const SizedBox.shrink(),
    );
  }

  /// Create an error announcement
  static Widget errorAnnouncement(String error) {
    return Semantics(
      liveRegion: true,
      label: 'Error: $error',
      child: const SizedBox.shrink(),
    );
  }
}

/// Extensions for common accessibility patterns
extension AccessibilityWidgetExtensions on Widget {
  /// Add semantic label to any widget
  Widget withSemantics({
    required String label,
    String? hint,
    String? value,
    bool button = false,
    VoidCallback? onTap,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      button: button,
      onTap: onTap,
      excludeSemantics: true,
      child: this,
    );
  }

  /// Exclude from semantics tree
  Widget excludeFromSemantics() {
    return ExcludeSemantics(child: this);
  }

  /// Merge semantics from children
  Widget mergeSemantics() {
    return MergeSemantics(child: this);
  }
}
