/// String extension methods used across the app.
extension StringExtensions on String {
  /// Capitalize first letter.
  String get capitalized =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// Capitalize first letter of each word.
  String get titleCase => split(' ').map((w) => w.capitalized).join(' ');

  /// Truncate with ellipsis.
  String truncate(int maxLength, {String suffix = '…'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - suffix.length)}$suffix';
  }

  /// Mask middle characters (for phone, account numbers).
  String get masked {
    if (length <= 4) return this;
    final visible = 4;
    final start = substring(0, 2);
    final end = substring(length - visible ~/ 2);
    return '$start${'•' * (length - visible)}$end';
  }

  /// Mask phone number: +225 07 XX XX 34
  String get maskedPhone {
    if (length < 8) return this;
    final prefix = substring(0, length > 10 ? 6 : 3);
    final suffix = substring(length - 2);
    return '$prefix ${'•' * 4} $suffix';
  }

  /// Check if string is a valid email.
  bool get isEmail => RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      ).hasMatch(this);

  /// Check if string is a valid phone number (basic check).
  bool get isPhone => RegExp(r'^\+?\d{8,15}$').hasMatch(replaceAll(' ', ''));

  /// Check if string is a valid wallet address (hex or base32).
  bool get isWalletAddress => length >= 32 && length <= 64;

  /// Remove all whitespace.
  String get stripped => replaceAll(RegExp(r'\s+'), '');

  /// Convert to initials (max 2 characters).
  String get initials {
    final words = trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return '';
    if (words.length == 1) {
      return words[0].substring(0, words[0].length.clamp(0, 2)).toUpperCase();
    }
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  /// Parse as double safely.
  double? get toDoubleOrNull => double.tryParse(replaceAll(',', ''));

  /// Check if string contains only digits.
  bool get isDigitsOnly => RegExp(r'^\d+$').hasMatch(this);
}

/// Nullable string helpers.
extension NullableStringExtensions on String? {
  /// Returns true if null or empty.
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Returns true if not null and not empty.
  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;

  /// Returns the string or a fallback.
  String orDefault([String fallback = '']) => this ?? fallback;
}
