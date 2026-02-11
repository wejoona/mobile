/// Reusable form field validators.
class FormValidators {
  FormValidators._();

  /// Required field.
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  /// Email validation.
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  /// Phone number validation.
  static String? phone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    final cleaned = value.replaceAll(RegExp(r'[\s\-()]'), '');
    if (!RegExp(r'^\+?\d{8,15}$').hasMatch(cleaned)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  /// Amount validation.
  static String? amount(
    String? value, {
    double? min,
    double? max,
    String currency = 'USDC',
  }) {
    if (value == null || value.isEmpty) return 'Amount is required';
    final amount = double.tryParse(value.replaceAll(',', ''));
    if (amount == null) return 'Enter a valid amount';
    if (amount <= 0) return 'Amount must be greater than 0';
    if (min != null && amount < min) {
      return 'Minimum amount is $min $currency';
    }
    if (max != null && amount > max) {
      return 'Maximum amount is $max $currency';
    }
    return null;
  }

  /// PIN validation (digits only, exact length).
  static String? pin(String? value, {int length = 4}) {
    if (value == null || value.isEmpty) return 'PIN is required';
    if (value.length != length) return 'PIN must be $length digits';
    if (!RegExp(r'^\d+$').hasMatch(value)) return 'PIN must contain only digits';
    // Check for sequential patterns
    if (_isSequential(value)) return 'PIN cannot be sequential (e.g. 1234)';
    // Check for repeated digits
    if (value.split('').toSet().length == 1) {
      return 'PIN cannot be all the same digit';
    }
    return null;
  }

  /// OTP validation.
  static String? otp(String? value, {int length = 6}) {
    if (value == null || value.isEmpty) return 'OTP is required';
    if (value.length != length) return 'OTP must be $length digits';
    if (!RegExp(r'^\d+$').hasMatch(value)) return 'OTP must contain only digits';
    return null;
  }

  /// Minimum length.
  static String? minLength(String? value, int min, {String? fieldName}) {
    if (value == null || value.length < min) {
      return '${fieldName ?? 'Field'} must be at least $min characters';
    }
    return null;
  }

  /// Maximum length.
  static String? maxLength(String? value, int max, {String? fieldName}) {
    if (value != null && value.length > max) {
      return '${fieldName ?? 'Field'} must be at most $max characters';
    }
    return null;
  }

  /// Wallet address validation.
  static String? walletAddress(String? value) {
    if (value == null || value.isEmpty) return 'Address is required';
    if (value.length < 32) return 'Address is too short';
    if (value.length > 64) return 'Address is too long';
    return null;
  }

  /// Compose multiple validators.
  static String? Function(String?) compose(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }

  static bool _isSequential(String pin) {
    bool ascending = true;
    bool descending = true;
    for (var i = 1; i < pin.length; i++) {
      if (pin.codeUnitAt(i) - pin.codeUnitAt(i - 1) != 1) ascending = false;
      if (pin.codeUnitAt(i - 1) - pin.codeUnitAt(i) != 1) descending = false;
    }
    return ascending || descending;
  }
}
