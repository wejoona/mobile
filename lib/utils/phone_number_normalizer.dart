String digitsOnly(String value) => value.replaceAll(RegExp(r'\D'), '');

String normalizePhoneE164({
  required String dialCode,
  required String localNumber,
}) {
  final prefix = dialCode.trim().startsWith('+')
      ? dialCode.trim()
      : '+${digitsOnly(dialCode)}';
  return '$prefix${digitsOnly(localNumber)}';
}
