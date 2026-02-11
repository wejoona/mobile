/// Phone number formatting utilities.

/// Mask phone for privacy: +225****1234
String maskPhone(String phone) {
  if (phone.length <= 6) return phone;
  final prefix = phone.substring(0, 4);
  final suffix = phone.substring(phone.length - 4);
  return '$prefix${'*' * (phone.length - 8)}$suffix';
}

/// Format phone for display: +225 07 00 00 00 00
String formatPhone(String phone) {
  if (!phone.startsWith('+')) return phone;
  // Remove country code and format
  if (phone.startsWith('+225') && phone.length >= 13) {
    final local = phone.substring(4);
    return '+225 ${local.substring(0, 2)} ${local.substring(2, 4)} ${local.substring(4, 6)} ${local.substring(6, 8)} ${local.substring(8)}';
  }
  return phone;
}

/// Validate E.164 phone number
bool isValidPhone(String phone) {
  return RegExp(r'^\+\d{8,15}$').hasMatch(phone.replaceAll(RegExp(r'[\s\-()]'), ''));
}

/// Clean phone number to E.164
String cleanPhone(String phone) {
  return phone.replaceAll(RegExp(r'[\s\-()]'), '');
}
