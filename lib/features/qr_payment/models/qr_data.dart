/// Model for QR code payment data.
class QrPaymentData {
  final String userId;
  final String? phone;
  final String? displayName;
  final double? amount;
  final String? note;
  final String? walletAddress;

  const QrPaymentData({
    required this.userId,
    this.phone,
    this.displayName,
    this.amount,
    this.note,
    this.walletAddress,
  });

  /// Encode as JSON string for QR code.
  String encode() {
    final data = {
      'type': 'korido_pay',
      'version': 1,
      'userId': userId,
      if (phone != null) 'phone': phone,
      if (displayName != null) 'name': displayName,
      if (amount != null) 'amount': amount,
      if (note != null) 'note': note,
      if (walletAddress != null) 'address': walletAddress,
    };
    // Simple JSON encoding — in production, consider signing this
    return Uri.encodeFull('korido://pay?data=${Uri.encodeComponent(_mapToString(data))}');
  }

  /// Decode from scanned QR string.
  static QrPaymentData? decode(String raw) {
    try {
      final uri = Uri.parse(raw);
      if (uri.scheme != 'korido' || uri.host != 'pay') return null;

      final dataStr = uri.queryParameters['data'];
      if (dataStr == null) return null;

      final decoded = Uri.decodeComponent(dataStr);
      final parts = decoded.split('&');
      final map = <String, String>{};
      for (final part in parts) {
        final kv = part.split('=');
        if (kv.length == 2) map[kv[0]] = kv[1];
      }

      return QrPaymentData(
        userId: map['userId'] ?? '',
        phone: map['phone'],
        displayName: map['name'],
        amount: double.tryParse(map['amount'] ?? ''),
        note: map['note'],
        walletAddress: map['address'],
      );
    } catch (_) {
      return null;
    }
  }

  static String _mapToString(Map<String, dynamic> map) {
    return map.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
  }
}
