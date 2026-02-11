/// Mixin providing common form validation patterns for Korido forms.
library;

import 'package:flutter/material.dart';

/// Provides reusable form validation helpers.
mixin FormValidationMixin {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool validateForm() {
    return formKey.currentState?.validate() ?? false;
  }

  void resetForm() {
    formKey.currentState?.reset();
  }

  /// Validates a required field.
  String? validateRequired(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates a USDC amount.
  String? validateAmount(
    String? value, {
    double min = 0.01,
    double? max,
    double? availableBalance,
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an amount';
    }
    final amount = double.tryParse(value.replaceAll(',', ''));
    if (amount == null) {
      return 'Please enter a valid amount';
    }
    if (amount < min) {
      return 'Minimum amount is ${min.toStringAsFixed(2)} USDC';
    }
    if (max != null && amount > max) {
      return 'Maximum amount is ${max.toStringAsFixed(2)} USDC';
    }
    if (availableBalance != null && amount > availableBalance) {
      return 'Insufficient balance';
    }
    return null;
  }

  /// Validates a phone number (West Africa format).
  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleaned.length < 8 || cleaned.length > 15) {
      return 'Please enter a valid phone number';
    }
    if (!RegExp(r'^\+?[0-9]+$').hasMatch(cleaned)) {
      return 'Phone number can only contain digits';
    }
    return null;
  }

  /// Validates an email address.
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Email often optional
    }
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates a wallet address (USDC on Stellar/Solana patterns).
  String? validateWalletAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Wallet address is required';
    }
    final trimmed = value.trim();
    // Stellar: 56 chars starting with G
    // Solana: 32-44 base58 chars
    if (trimmed.length < 32 || trimmed.length > 56) {
      return 'Please enter a valid wallet address';
    }
    if (!RegExp(r'^[A-Za-z0-9]+$').hasMatch(trimmed)) {
      return 'Wallet address contains invalid characters';
    }
    return null;
  }

  /// Validates a PIN (4-6 digits).
  String? validatePin(String? value, {int length = 4}) {
    if (value == null || value.isEmpty) {
      return 'PIN is required';
    }
    if (value.length != length) {
      return 'PIN must be $length digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'PIN must contain only digits';
    }
    // Reject trivial PINs
    if (RegExp(r'^(.)\1+$').hasMatch(value)) {
      return 'PIN cannot be all the same digit';
    }
    if (_isSequential(value)) {
      return 'PIN cannot be a sequential number';
    }
    return null;
  }

  /// Validates a name field.
  String? validateName(String? value, {String fieldName = 'Name'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (value.trim().length < 2) {
      return '$fieldName must be at least 2 characters';
    }
    if (value.trim().length > 50) {
      return '$fieldName must be less than 50 characters';
    }
    return null;
  }

  /// Validates a description/note field.
  String? validateDescription(String? value, {int maxLength = 200}) {
    if (value != null && value.length > maxLength) {
      return 'Maximum $maxLength characters';
    }
    return null;
  }

  bool _isSequential(String pin) {
    final digits = pin.codeUnits;
    bool ascending = true;
    bool descending = true;
    for (int i = 1; i < digits.length; i++) {
      if (digits[i] != digits[i - 1] + 1) ascending = false;
      if (digits[i] != digits[i - 1] - 1) descending = false;
    }
    return ascending || descending;
  }
}
