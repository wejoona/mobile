/// Bank account entity for linked bank accounts.
class BankAccount {
  final String id;
  final String userId;
  final String bankName;
  final String accountNumber;
  final String? accountName;
  final String? routingNumber;
  final BankAccountType type;
  final BankAccountStatus status;
  final String currency;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime? verifiedAt;

  const BankAccount({
    required this.id,
    required this.userId,
    required this.bankName,
    required this.accountNumber,
    this.accountName,
    this.routingNumber,
    this.type = BankAccountType.checking,
    this.status = BankAccountStatus.pending,
    this.currency = 'XOF',
    this.isDefault = false,
    required this.createdAt,
    this.verifiedAt,
  });

  /// Masked account number: "•••• 1234".
  String get maskedAccount {
    if (accountNumber.length <= 4) return accountNumber;
    return '•••• ${accountNumber.substring(accountNumber.length - 4)}';
  }

  bool get isVerified => status == BankAccountStatus.verified;
  bool get isPending => status == BankAccountStatus.pending;

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? '',
      bankName: json['bankName'] as String,
      accountNumber: json['accountNumber'] as String,
      accountName: json['accountName'] as String?,
      routingNumber: json['routingNumber'] as String?,
      type: BankAccountType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => BankAccountType.checking,
      ),
      status: BankAccountStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BankAccountStatus.pending,
      ),
      currency: json['currency'] as String? ?? 'XOF',
      isDefault: json['isDefault'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.parse(json['verifiedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'bankName': bankName,
        'accountNumber': accountNumber,
        'accountName': accountName,
        'routingNumber': routingNumber,
        'type': type.name,
        'currency': currency,
        'isDefault': isDefault,
      };
}

enum BankAccountType { checking, savings, mobile_money }

enum BankAccountStatus { pending, verified, rejected, suspended }
