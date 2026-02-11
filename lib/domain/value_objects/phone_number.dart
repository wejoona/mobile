/// Value object for phone numbers with validation.
class PhoneNumber {
  final String countryCode;
  final String number;

  const PhoneNumber({
    required this.countryCode,
    required this.number,
  });

  /// Full international format: +225XXXXXXXXXX
  String get international => '+$countryCode$number';

  /// Display format: +225 XX XX XX XX XX
  String get display {
    final formatted = number.replaceAllMapped(
      RegExp(r'(\d{2})'),
      (m) => '${m[1]} ',
    ).trim();
    return '+$countryCode $formatted';
  }

  /// Parse from international format.
  factory PhoneNumber.parse(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.startsWith('+')) {
      // Try common prefixes
      for (final prefix in ['225', '233', '234', '221', '1']) {
        if (cleaned.startsWith('+$prefix')) {
          return PhoneNumber(
            countryCode: prefix,
            number: cleaned.substring(prefix.length + 1),
          );
        }
      }
    }
    return PhoneNumber(countryCode: '', number: cleaned.replaceAll('+', ''));
  }

  bool get isValid => countryCode.isNotEmpty && number.length >= 8;

  @override
  bool operator ==(Object other) =>
      other is PhoneNumber &&
      other.countryCode == countryCode &&
      other.number == number;

  @override
  int get hashCode => Object.hash(countryCode, number);

  @override
  String toString() => international;
}
