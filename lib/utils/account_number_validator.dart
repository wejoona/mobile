/// Validates bill payment account numbers by provider rules.
library;

class AccountNumberValidator {
  const AccountNumberValidator._();

  /// Validate an account number against provider-specific rules.
  static String? validate({
    required String? value,
    required String label,
    String? pattern,
    int? exactLength,
    int minLength = 4,
    int maxLength = 30,
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < minLength) {
      return '$label must be at least $minLength characters';
    }
    if (trimmed.length > maxLength) {
      return '$label must be at most $maxLength characters';
    }
    if (exactLength != null && trimmed.length != exactLength) {
      return '$label must be exactly $exactLength characters';
    }
    if (pattern != null && !RegExp(pattern).hasMatch(trimmed)) {
      return 'Invalid $label format';
    }
    return null;
  }

  /// Validate a meter number (electricity prepaid).
  static String? validateMeter(String? value) {
    return validate(
      value: value,
      label: 'Meter number',
      minLength: 8,
      maxLength: 20,
      pattern: r'^[0-9]+$',
    );
  }
}
