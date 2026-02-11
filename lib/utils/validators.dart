/// Input validation utilities.

/// Validate email format
String? validateEmail(String? value) {
  if (value == null || value.isEmpty) return 'Email is required';
  final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  if (!emailRegex.hasMatch(value)) return 'Invalid email format';
  return null;
}

/// Validate phone number (E.164)
String? validatePhone(String? value) {
  if (value == null || value.isEmpty) return 'Phone number is required';
  final cleaned = value.replaceAll(RegExp(r'[\s\-()]'), '');
  if (!RegExp(r'^\+\d{8,15}$').hasMatch(cleaned)) return 'Invalid phone number';
  return null;
}

/// Validate PIN (4 digits)
String? validatePin(String? value) {
  if (value == null || value.isEmpty) return 'PIN is required';
  if (value.length != 4) return 'PIN must be 4 digits';
  if (!RegExp(r'^\d{4}$').hasMatch(value)) return 'PIN must contain only digits';
  // Reject common patterns
  if (['1234', '0000', '1111', '2222', '3333', '4444', '5555', '6666', '7777', '8888', '9999'].contains(value)) {
    return 'PIN is too simple. Choose a more secure PIN';
  }
  return null;
}

/// Validate amount
String? validateAmount(String? value, {double min = 0.01, double max = 10000000}) {
  if (value == null || value.isEmpty) return 'Amount is required';
  final amount = double.tryParse(value);
  if (amount == null) return 'Invalid amount';
  if (amount < min) return 'Minimum amount is ${min.toStringAsFixed(2)}';
  if (amount > max) return 'Maximum amount is ${max.toStringAsFixed(0)}';
  return null;
}

/// Validate username (alphanumeric, 3-20 chars)
String? validateUsername(String? value) {
  if (value == null || value.isEmpty) return 'Username is required';
  if (value.length < 3) return 'Username must be at least 3 characters';
  if (value.length > 20) return 'Username must be 20 characters or less';
  if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) return 'Only letters, numbers, and underscores';
  return null;
}
