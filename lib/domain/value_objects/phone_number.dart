/// Value object for phone numbers with country code handling.
class PhoneNumber {
  final String raw;

  const PhoneNumber(this.raw);

  /// Normalize to E.164 format (+225XXXXXXXXXX).
  String get e164 {
    var cleaned = raw.replaceAll(RegExp(r'[\s\-()]'), '');
    if (!cleaned.startsWith('+')) {
      // Default to Côte d'Ivoire
      if (cleaned.startsWith('0')) {
        cleaned = '+225${cleaned.substring(1)}';
      } else {
        cleaned = '+225$cleaned';
      }
    }
    return cleaned;
  }

  /// Country code (e.g., "225").
  String get countryCode {
    final normalized = e164;
    if (normalized.length <= 4) return '';
    // West African codes: 2-3 digits after +
    if (normalized.startsWith('+225')) return '225'; // CI
    if (normalized.startsWith('+226')) return '226'; // BF
    if (normalized.startsWith('+227')) return '227'; // NE
    if (normalized.startsWith('+228')) return '228'; // TG
    if (normalized.startsWith('+229')) return '229'; // BJ
    if (normalized.startsWith('+221')) return '221'; // SN
    if (normalized.startsWith('+223')) return '223'; // ML
    if (normalized.startsWith('+224')) return '224'; // GN
    if (normalized.startsWith('+1')) return '1';     // US/CA
    // Default: first 3 digits
    return normalized.substring(1, 4);
  }

  /// Local number without country code.
  String get local {
    final code = countryCode;
    final normalized = e164;
    return normalized.substring(code.length + 1);
  }

  /// Formatted for display: "+225 07 08 09 10".
  String get display {
    final normalized = e164;
    if (normalized.startsWith('+225') && normalized.length == 13) {
      final local = normalized.substring(4);
      return '+225 ${local.substring(0, 2)} ${local.substring(2, 4)} ${local.substring(4, 6)} ${local.substring(6)}';
    }
    return normalized;
  }

  /// Masked for privacy: "+225 •••• •• 10".
  String get masked {
    final normalized = e164;
    if (normalized.length < 6) return normalized;
    return '${normalized.substring(0, 4)} •••• ${normalized.substring(normalized.length - 2)}';
  }

  /// Whether this is a valid phone number (basic check).
  bool get isValid {
    final normalized = e164;
    return RegExp(r'^\+\d{8,15}$').hasMatch(normalized);
  }

  /// Whether this is a UEMOA country number.
  bool get isUemoa {
    const uemoaCodes = ['225', '226', '227', '228', '229', '221', '223', '224'];
    return uemoaCodes.contains(countryCode);
  }

  @override
  bool operator ==(Object other) =>
      other is PhoneNumber && e164 == other.e164;

  @override
  int get hashCode => e164.hashCode;

  @override
  String toString() => display;
}
