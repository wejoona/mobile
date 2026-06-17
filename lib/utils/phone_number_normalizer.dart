String digitsOnly(String value) => value.replaceAll(RegExp(r'\D'), '');

String localPhoneDigits({
  required String dialCode,
  required String phoneNumber,
}) {
  final digits = digitsOnly(phoneNumber);
  final prefixDigits = digitsOnly(dialCode);
  if (prefixDigits.isNotEmpty && digits.startsWith(prefixDigits)) {
    return digits.substring(prefixDigits.length);
  }
  return digits;
}

String normalizePhoneE164({
  required String dialCode,
  required String localNumber,
}) {
  final prefix = dialCode.trim().startsWith('+')
      ? dialCode.trim()
      : '+${digitsOnly(dialCode)}';
  return '$prefix${digitsOnly(localNumber)}';
}
