/// Linked Bank Account Model
library;

enum BankAccountStatus {
  pending,
  verified,
  failed,
  suspended;

  String get value {
    switch (this) {
      case BankAccountStatus.pending:
        return 'pending';
      case BankAccountStatus.verified:
        return 'verified';
      case BankAccountStatus.failed:
        return 'failed';
      case BankAccountStatus.suspended:
        return 'suspended';
    }
  }

  static BankAccountStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return BankAccountStatus.pending;
      case 'verified':
        return BankAccountStatus.verified;
      case 'failed':
        return BankAccountStatus.failed;
      case 'suspended':
        return BankAccountStatus.suspended;
      default:
        return BankAccountStatus.pending;
    }
  }
}

class LinkedBankAccount {
  final String id;
  final String walletId;
  final String bankCode;
  final String bankName;
  final String bankLogoUrl;
  final String accountNumber;
  final String accountNumberMasked;
  final String accountHolderName;
  final BankAccountStatus status;
  final double? availableBalance;
  final String currency;
  final bool isPrimary;
  final DateTime? lastVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LinkedBankAccount({
    required this.id,
    required this.walletId,
    required this.bankCode,
    required this.bankName,
    required this.bankLogoUrl,
    required this.accountNumber,
    required this.accountNumberMasked,
    required this.accountHolderName,
    required this.status,
    this.availableBalance,
    this.currency = 'XOF',
    this.isPrimary = false,
    this.lastVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LinkedBankAccount.fromJson(Map<String, dynamic> json) {
    return LinkedBankAccount(
      id: json['id'] as String,
      walletId: json['wallet_id'] as String,
      bankCode: json['bank_code'] as String,
      bankName: json['bank_name'] as String,
      bankLogoUrl: json['bank_logo_url'] as String,
      accountNumber: json['account_number'] as String,
      accountNumberMasked: json['account_number_masked'] as String,
      accountHolderName: json['account_holder_name'] as String,
      status: BankAccountStatus.fromString(json['status'] as String),
      availableBalance: json['available_balance'] as double?,
      currency: json['currency'] as String? ?? 'XOF',
      isPrimary: json['is_primary'] as bool? ?? false,
      lastVerifiedAt: json['last_verified_at'] != null
          ? DateTime.parse(json['last_verified_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'wallet_id': walletId,
        'bank_code': bankCode,
        'bank_name': bankName,
        'bank_logo_url': bankLogoUrl,
        'account_number': accountNumber,
        'account_number_masked': accountNumberMasked,
        'account_holder_name': accountHolderName,
        'status': status.value,
        'available_balance': availableBalance,
        'currency': currency,
        'is_primary': isPrimary,
        'last_verified_at': lastVerifiedAt?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  LinkedBankAccount copyWith({
    String? id,
    String? walletId,
    String? bankCode,
    String? bankName,
    String? bankLogoUrl,
    String? accountNumber,
    String? accountNumberMasked,
    String? accountHolderName,
    BankAccountStatus? status,
    double? availableBalance,
    String? currency,
    bool? isPrimary,
    DateTime? lastVerifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LinkedBankAccount(
      id: id ?? this.id,
      walletId: walletId ?? this.walletId,
      bankCode: bankCode ?? this.bankCode,
      bankName: bankName ?? this.bankName,
      bankLogoUrl: bankLogoUrl ?? this.bankLogoUrl,
      accountNumber: accountNumber ?? this.accountNumber,
      accountNumberMasked: accountNumberMasked ?? this.accountNumberMasked,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      status: status ?? this.status,
      availableBalance: availableBalance ?? this.availableBalance,
      currency: currency ?? this.currency,
      isPrimary: isPrimary ?? this.isPrimary,
      lastVerifiedAt: lastVerifiedAt ?? this.lastVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
