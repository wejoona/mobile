import 'dart:convert';

import 'package:usdc_wallet/utils/phone_number_normalizer.dart';

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
  final String userId;
  final String? displayName;
  final String? note;
  final String? walletAddress;
  final String? recipient;
  final String? merchantId;
  final String? merchantMcc;
  final String? merchantCategory;
  final String? paymentLinkId;

  const QrPaymentData({
    this.type = 'korido',
    this.version = 1,
    this.phone = '',
    this.amount,
    this.currency,
    this.name,
    this.reference,
    this.userId = '',
    this.displayName,
    this.note,
    this.walletAddress,
    this.recipient,
    this.merchantId,
    this.merchantMcc,
    this.merchantCategory,
    this.paymentLinkId,
  });

  /// Create from JSON
  factory QrPaymentData.fromJson(Map<String, dynamic> json) {
    return QrPaymentData(
      type: json['type'] as String? ?? 'korido',
      version: json['version'] as int? ?? 1,
      userId: json['userId'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      amount: json['amount'] != null
          ? (json['amount'] is String
                ? double.tryParse(json['amount'] as String)
                : (json['amount'] as num).toDouble())
          : null,
      currency: json['currency'] as String?,
      name: json['name'] as String? ?? json['displayName'] as String?,
      displayName: json['displayName'] as String? ?? json['name'] as String?,
      reference: json['reference'] as String?,
      note: json['note'] as String?,
      walletAddress: json['address'] as String?,
      recipient: json['recipient'] as String?,
      merchantId: json['merchantId'] as String?,
      merchantMcc: json['merchantMcc'] as String? ?? json['mcc'] as String?,
      merchantCategory: json['merchantCategory'] as String?,
      paymentLinkId: json['paymentLinkId'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'type': type, 'version': version};

    if (userId.isNotEmpty) json['userId'] = userId;
    if (phone.isNotEmpty) json['phone'] = phone;
    if (amount != null) json['amount'] = amount;
    if (currency != null) json['currency'] = currency;
    if (name != null || displayName != null) json['name'] = name ?? displayName;
    if (displayName != null) json['displayName'] = displayName;
    if (reference != null) json['reference'] = reference;
    if (note != null) json['note'] = note;
    if (walletAddress != null) json['address'] = walletAddress;
    if (recipient != null) json['recipient'] = recipient;
    if (merchantId != null) json['merchantId'] = merchantId;
    if (merchantMcc != null) json['merchantMcc'] = merchantMcc;
    if (merchantCategory != null) json['merchantCategory'] = merchantCategory;
    if (paymentLinkId != null) json['paymentLinkId'] = paymentLinkId;

    return json;
  }

  /// Encode as Korido deep-link QR string for receive/payment surfaces.
  String encode() {
    final data = {
      'type': 'korido_pay',
      'version': version,
      if (userId.isNotEmpty) 'userId': userId,
      if (phone.isNotEmpty) 'phone': phone,
      if (displayName != null || name != null) 'name': displayName ?? name,
      if (amount != null) 'amount': amount,
      if (note != null) 'note': note,
      if (walletAddress != null) 'address': walletAddress,
      if (reference != null) 'reference': reference,
    };

    return Uri(
      scheme: 'korido',
      host: 'pay',
      queryParameters: {'data': _mapToString(data)},
    ).toString();
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
      return decode(qrString);
    }
  }

  /// Decode from Korido deep-link QR string.
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
        final separator = part.indexOf('=');
        if (separator <= 0) continue;
        map[part.substring(0, separator)] = part.substring(separator + 1);
      }

      return QrPaymentData(
        type: map['type'] ?? 'korido_pay',
        version: int.tryParse(map['version'] ?? '') ?? 1,
        userId: map['userId'] ?? '',
        phone: map['phone'] ?? '',
        displayName: map['name'],
        name: map['name'],
        amount: double.tryParse(map['amount'] ?? ''),
        note: map['note'],
        walletAddress: map['address'],
        reference: map['reference'],
      );
    } catch (_) {
      return null;
    }
  }

  String? get canonicalRecipientPhone {
    for (final value in [recipient, phone, userId]) {
      final normalized = PhoneNumberValue.tryFromAny(phoneNumber: value);
      if (normalized != null) return normalized.e164;
    }
    return null;
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
    String? userId,
    String? displayName,
    String? note,
    String? walletAddress,
    String? recipient,
    String? merchantId,
    String? merchantMcc,
    String? merchantCategory,
    String? paymentLinkId,
  }) {
    return QrPaymentData(
      type: type ?? this.type,
      version: version ?? this.version,
      phone: phone ?? this.phone,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      name: name ?? this.name,
      reference: reference ?? this.reference,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      note: note ?? this.note,
      walletAddress: walletAddress ?? this.walletAddress,
      recipient: recipient ?? this.recipient,
      merchantId: merchantId ?? this.merchantId,
      merchantMcc: merchantMcc ?? this.merchantMcc,
      merchantCategory: merchantCategory ?? this.merchantCategory,
      paymentLinkId: paymentLinkId ?? this.paymentLinkId,
    );
  }

  @override
  String toString() {
    return 'QrPaymentData(type: $type, version: $version, phone: $phone, '
        'amount: $amount, currency: $currency, name: $name, reference: $reference)';
  }

  static String _mapToString(Map<String, dynamic> map) {
    return map.entries.map((entry) => '${entry.key}=${entry.value}').join('&');
  }
}
