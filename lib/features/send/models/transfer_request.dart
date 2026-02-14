/// Transfer Request Models

/// Transfer Request - for internal transfers
class TransferRequest {
  final String recipientPhone;
  final double amount;
  final String? note;

  const TransferRequest({
    required this.recipientPhone,
    required this.amount,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'recipientPhone': recipientPhone,
        'amount': amount,
        if (note != null) 'note': note,
      };

  TransferRequest copyWith({
    String? recipientPhone,
    double? amount,
    String? note,
  }) {
    return TransferRequest(
      recipientPhone: recipientPhone ?? this.recipientPhone,
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
  final bool isKoridoUser;
  final bool isBeneficiary;
  final String? beneficiaryId;

  const RecipientInfo({
    required this.phoneNumber,
    this.name,
    this.userId,
    this.isKoridoUser = false,
    this.isBeneficiary = false,
    this.beneficiaryId,
  });

  RecipientInfo copyWith({
    String? phoneNumber,
    String? name,
    String? userId,
    bool? isKoridoUser,
    bool? isBeneficiary,
    String? beneficiaryId,
  }) {
    return RecipientInfo(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      userId: userId ?? this.userId,
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
  final DateTime lastTransferDate;
  final double lastAmount;

  const RecentRecipient({
    required this.phoneNumber,
    required this.name,
    required this.lastTransferDate,
    required this.lastAmount,
  });

  factory RecentRecipient.fromJson(Map<String, dynamic> json) {
    return RecentRecipient(
      phoneNumber: json['phoneNumber'] as String,
      name: json['name'] as String,
      lastTransferDate: DateTime.parse(json['lastTransferDate'] as String),
      lastAmount: (json['lastAmount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'phoneNumber': phoneNumber,
        'name': name,
        'lastTransferDate': lastTransferDate.toIso8601String(),
        'lastAmount': lastAmount,
      };
}
