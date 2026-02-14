import 'dart:convert';

/// QR Payment Data Model
/// Represents payment information encoded in a Korido QR code
class QrPaymentData {
  final String type;
  final int version;
  final String phone;
  final double? amount;
  final String? currency;
  final String? name;
  final String? reference;

  const QrPaymentData({
    this.type = 'joonapay',
    this.version = 1,
    required this.phone,
    this.amount,
    this.currency,
    this.name,
    this.reference,
  });

  /// Create from JSON
  factory QrPaymentData.fromJson(Map<String, dynamic> json) {
    return QrPaymentData(
      type: json['type'] as String? ?? 'joonapay',
      version: json['version'] as int? ?? 1,
      phone: json['phone'] as String,
      amount: json['amount'] != null
          ? (json['amount'] is String
              ? double.tryParse(json['amount'] as String)
              : (json['amount'] as num).toDouble())
          : null,
      currency: json['currency'] as String?,
      name: json['name'] as String?,
      reference: json['reference'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'type': type,
      'version': version,
      'phone': phone,
    };

    if (amount != null) json['amount'] = amount;
    if (currency != null) json['currency'] = currency;
    if (name != null) json['name'] = name;
    if (reference != null) json['reference'] = reference;

    return json;
  }

  /// Encode as QR string (JSON format)
  String toQrString() {
    return jsonEncode(toJson());
  }

  /// Create from QR string
  static QrPaymentData? fromQrString(String qrString) {
    try {
      final json = jsonDecode(qrString) as Map<String, dynamic>;
      return QrPaymentData.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  /// Copy with method
  QrPaymentData copyWith({
    String? type,
    int? version,
    String? phone,
    double? amount,
    String? currency,
    String? name,
    String? reference,
  }) {
    return QrPaymentData(
      type: type ?? this.type,
      version: version ?? this.version,
      phone: phone ?? this.phone,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      name: name ?? this.name,
      reference: reference ?? this.reference,
    );
  }

  @override
  String toString() {
    return 'QrPaymentData(type: $type, version: $version, phone: $phone, '
        'amount: $amount, currency: $currency, name: $name, reference: $reference)';
  }
}
