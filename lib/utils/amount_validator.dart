/// Dedicated amount validation for USDC transfers and payments.
library;

/// Result of amount validation with specific error context.
class AmountValidationResult {
  final bool isValid;
  final String? errorMessage;
  final double? parsedAmount;

  const AmountValidationResult._({
    required this.isValid,
    this.errorMessage,
    this.parsedAmount,
  });

  factory AmountValidationResult.valid(double amount) =>
      AmountValidationResult._(isValid: true, parsedAmount: amount);

  factory AmountValidationResult.invalid(String message) =>
      AmountValidationResult._(isValid: false, errorMessage: message);
}

/// Validates USDC amounts with context-aware rules.
class AmountValidator {
  const AmountValidator._();

  /// Validate a send amount.
  static AmountValidationResult validateSend({
    required String input,
    required double balance,
    required double fee,
    double minAmount = 0.01,
    double? maxPerTransaction,
    double? dailyLimitRemaining,
  }) {
    final amount = _parse(input);
    if (amount == null) {
      return AmountValidationResult.invalid('Enter a valid amount');
    }
    if (amount < minAmount) {
      return AmountValidationResult.invalid(
        'Minimum send amount is ${minAmount.toStringAsFixed(2)} USDC',
      );
    }
    if (amount + fee > balance) {
      return AmountValidationResult.invalid(
        'Insufficient balance (including ${fee.toStringAsFixed(2)} fee)',
      );
    }
    if (maxPerTransaction != null && amount > maxPerTransaction) {
      return AmountValidationResult.invalid(
        'Maximum per transaction is ${maxPerTransaction.toStringAsFixed(2)} USDC',
      );
    }
    if (dailyLimitRemaining != null && amount > dailyLimitRemaining) {
      return AmountValidationResult.invalid(
        'Exceeds daily limit. Remaining: ${dailyLimitRemaining.toStringAsFixed(2)} USDC',
      );
    }
    return AmountValidationResult.valid(amount);
  }

  /// Validate a deposit amount.
  static AmountValidationResult validateDeposit({
    required String input,
    double minAmount = 1.0,
    double? maxAmount,
  }) {
    final amount = _parse(input);
    if (amount == null) {
      return AmountValidationResult.invalid('Enter a valid amount');
    }
    if (amount < minAmount) {
      return AmountValidationResult.invalid(
        'Minimum deposit is ${minAmount.toStringAsFixed(2)} USDC',
      );
    }
    if (maxAmount != null && amount > maxAmount) {
      return AmountValidationResult.invalid(
        'Maximum deposit is ${maxAmount.toStringAsFixed(2)} USDC',
      );
    }
    return AmountValidationResult.valid(amount);
  }

  /// Validate a savings pot contribution.
  static AmountValidationResult validatePotContribution({
    required String input,
    required double balance,
    double? targetRemaining,
  }) {
    final amount = _parse(input);
    if (amount == null) {
      return AmountValidationResult.invalid('Enter a valid amount');
    }
    if (amount <= 0) {
      return AmountValidationResult.invalid('Amount must be greater than zero');
    }
    if (amount > balance) {
      return AmountValidationResult.invalid('Insufficient balance');
    }
    if (targetRemaining != null && amount > targetRemaining) {
      return AmountValidationResult.invalid(
        'Amount exceeds remaining target (${targetRemaining.toStringAsFixed(2)} USDC)',
      );
    }
    return AmountValidationResult.valid(amount);
  }

  /// Validate a bill payment amount.
  static AmountValidationResult validateBillPayment({
    required String input,
    required double balance,
    required double fee,
    required double minAmount,
    required double maxAmount,
  }) {
    final amount = _parse(input);
    if (amount == null) {
      return AmountValidationResult.invalid('Enter a valid amount');
    }
    if (amount < minAmount) {
      return AmountValidationResult.invalid(
        'Minimum payment is ${minAmount.toStringAsFixed(2)}',
      );
    }
    if (amount > maxAmount) {
      return AmountValidationResult.invalid(
        'Maximum payment is ${maxAmount.toStringAsFixed(2)}',
      );
    }
    if (amount + fee > balance) {
      return AmountValidationResult.invalid('Insufficient balance (including fees)');
    }
    return AmountValidationResult.valid(amount);
  }

  static double? _parse(String input) {
    final cleaned = input.replaceAll(',', '').replaceAll(' ', '').trim();
    if (cleaned.isEmpty) return null;
    return double.tryParse(cleaned);
  }
}
