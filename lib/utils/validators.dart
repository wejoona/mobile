/// Common form field validators for Korido.

/// Validate that a field is not empty.
String? validateRequired(String? value, {String fieldName = 'This field'}) {
  if (value == null || value.trim().isEmpty) {
    return '$fieldName is required';
  }
  return null;
}

/// Validate email format.
String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) return 'Email is required';
  final regex = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,}$');
  if (!regex.hasMatch(value.trim())) return 'Enter a valid email address';
  return null;
}

/// Validate phone number.
String? validatePhone(String? value) {
  if (value == null || value.trim().isEmpty) return 'Phone number is required';
  final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
  if (digitsOnly.length < 8) return 'Phone number is too short';
  if (digitsOnly.length > 15) return 'Phone number is too long';
  return null;
}

/// Validate transfer amount.
String? validateAmount(
  String? value, {
  double min = 0.01,
  double max = 10000.0,
  String currency = 'USDC',
}) {
  if (value == null || value.trim().isEmpty) return 'Amount is required';
  final amount = double.tryParse(value.replaceAll(',', ''));
  if (amount == null) return 'Enter a valid amount';
  if (amount < min) return 'Minimum amount is $min $currency';
  if (amount > max) return 'Maximum amount is $max $currency';
  return null;
}

/// Validate PIN (6 digits).
String? validatePin(String? value) {
  if (value == null || value.isEmpty) return 'PIN is required';
  if (value.length != 6) return 'PIN must be 6 digits';
  if (!RegExp(r'^\d{6}$').hasMatch(value)) return 'PIN must contain only digits';
  // Reject simple patterns
  if (RegExp(r'^(\d)\1{5}$').hasMatch(value)) return 'PIN is too simple';
  return null;
}

/// Validate OTP (6 digits).
String? validateOtp(String? value) {
  if (value == null || value.isEmpty) return 'OTP is required';
  if (value.length != 6) return 'OTP must be 6 digits';
  if (!RegExp(r'^\d{6}$').hasMatch(value)) return 'OTP must contain only digits';
  return null;
}
