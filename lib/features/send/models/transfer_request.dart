// Transfer Request Models

import 'package:usdc_wallet/utils/phone_number_normalizer.dart';

/// Transfer Request - for internal transfers
class TransferRequest {
  final String? recipientId;
  final String? recipientPhone;
  final String? recipientUsername;
  final double amount;
  final String? note;

  const TransferRequest({
    this.recipientId,
    this.recipientPhone,
    this.recipientUsername,
    required this.amount,
    this.note,
  });

  Map<String, dynamic> toJson() {
    final body = <String, dynamic>{
      ..._recipientIdentifierBody(),
      'amount': amount,
      if (note != null) 'note': note,
    };

    return body;
  }

  Map<String, String> _recipientIdentifierBody() {
    final normalizedRecipientId = recipientId?.trim();
    if (normalizedRecipientId != null && normalizedRecipientId.isNotEmpty) {
      return {'recipientId': normalizedRecipientId};
    }

    final normalizedUsername = _normalizeUsername(recipientUsername);
    if (normalizedUsername != null && normalizedUsername.isNotEmpty) {
      return {'recipientUsername': normalizedUsername};
    }

    final normalizedPhone = PhoneNumberValue.tryFromAny(
      phoneNumber: recipientPhone,
    )?.e164;
    if (normalizedPhone != null && normalizedPhone.isNotEmpty) {
      return {'toPhone': normalizedPhone};
    }

    return const {};
  }

  TransferRequest copyWith({
    String? recipientId,
    String? recipientPhone,
    String? recipientUsername,
    double? amount,
    String? note,
  }) {
    return TransferRequest(
      recipientId: recipientId ?? this.recipientId,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      recipientUsername: recipientUsername ?? this.recipientUsername,
      amount: amount ?? this.amount,
      note: note ?? this.note,
    );
  }
}

/// Recipient Info - for display and validation
class RecipientInfo {
  final String phoneNumber;
  final String? name;
  final String? userId;
  final String? username;
  final bool isKoridoUser;
  final bool isBeneficiary;
  final String? beneficiaryId;

  const RecipientInfo({
    required this.phoneNumber,
    this.name,
    this.userId,
    this.username,
    this.isKoridoUser = false,
    this.isBeneficiary = false,
    this.beneficiaryId,
  });

  bool get hasPhone => phoneNumber.trim().isNotEmpty;

  bool get hasUsername => username?.trim().isNotEmpty ?? false;

  bool get hasUserId => userId?.trim().isNotEmpty ?? false;

  bool get canSend => hasPhone || hasUsername || hasUserId;

  String get displayIdentifier {
    if (hasPhone) {
      return phoneNumber;
    }
    final handle = username?.trim();
    if (handle != null && handle.isNotEmpty) {
      return handle.startsWith('@') ? handle : '@$handle';
    }
    return userId ?? '';
  }

  RecipientInfo copyWith({
    String? phoneNumber,
    String? name,
    String? userId,
    String? username,
    bool? isKoridoUser,
    bool? isBeneficiary,
    String? beneficiaryId,
  }) {
    return RecipientInfo(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      isKoridoUser: isKoridoUser ?? this.isKoridoUser,
      isBeneficiary: isBeneficiary ?? this.isBeneficiary,
      beneficiaryId: beneficiaryId ?? this.beneficiaryId,
    );
  }
}

/// Recent Recipient - for quick access
class RecentRecipient {
  final String phoneNumber;
  final String name;
  final String? userId;
  final String? username;
  final DateTime lastTransferDate;
  final double lastAmount;
  final bool isKoridoUser;

  const RecentRecipient({
    required this.phoneNumber,
    required this.name,
    this.userId,
    this.username,
    required this.lastTransferDate,
    required this.lastAmount,
    this.isKoridoUser = false,
  });

  factory RecentRecipient.fromJson(Map<String, dynamic> json) {
    return RecentRecipient(
      phoneNumber: (json['phoneNumber'] ?? json['phone']) as String,
      name: json['name'] as String,
      userId:
          (json['userId'] ?? json['recipientId'] ?? json['contactUserId'])
              as String?,
      username: (json['username'] ?? json['recipientUsername']) as String?,
      lastTransferDate: DateTime.parse(json['lastTransferDate'] as String),
      lastAmount: (json['lastAmount'] as num).toDouble(),
      isKoridoUser:
          (json['isKoridoUser'] ?? json['isJoonaPayUser']) as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'phoneNumber': phoneNumber,
    'name': name,
    if (userId != null && userId!.isNotEmpty) 'userId': userId,
    if (username != null && username!.isNotEmpty) 'username': username,
    'lastTransferDate': lastTransferDate.toIso8601String(),
    'lastAmount': lastAmount,
    'isKoridoUser': isKoridoUser,
  };
}

String? _normalizeUsername(String? username) {
  final trimmed = username?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }

  final withoutPrefix = trimmed.startsWith('@')
      ? trimmed.substring(1)
      : trimmed;
  return withoutPrefix.toLowerCase();
}
