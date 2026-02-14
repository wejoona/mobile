/// Account Types for Beneficiaries
enum AccountType {
  joonapayUser('korido_user'),
  externalWallet('external_wallet'),
  bankAccount('bank_account'),
  mobileMoney('mobile_money');

  final String value;
  const AccountType(this.value);

  static AccountType fromString(String value) {
    return AccountType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AccountType.joonapayUser,
    );
  }
}

/// Beneficiary Model
class Beneficiary {
  final String id;
  final String walletId;
  final String name;
  final String? phoneE164;
  final AccountType accountType;
  final String? beneficiaryUserId;
  final String? beneficiaryWalletAddress;
  final String? bankCode;
  final String? bankAccountNumber;
  final String? mobileMoneyProvider;
  final bool isFavorite;
  final bool isVerified;
  final int transferCount;
  final double totalTransferred;
  final DateTime? lastTransferAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Beneficiary({
    required this.id,
    required this.walletId,
    required this.name,
    this.phoneE164,
    required this.accountType,
    this.beneficiaryUserId,
    this.beneficiaryWalletAddress,
    this.bankCode,
    this.bankAccountNumber,
    this.mobileMoneyProvider,
    this.isFavorite = false,
    this.isVerified = false,
    this.transferCount = 0,
    this.totalTransferred = 0.0,
    this.lastTransferAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Beneficiary.fromJson(Map<String, dynamic> json) {
    return Beneficiary(
      id: json['id'] as String,
      walletId: json['wallet_id'] as String,
      name: json['name'] as String,
      phoneE164: json['phone_e164'] as String?,
      accountType: AccountType.fromString(json['account_type'] as String),
      beneficiaryUserId: json['beneficiary_user_id'] as String?,
      beneficiaryWalletAddress: json['beneficiary_wallet_address'] as String?,
      bankCode: json['bank_code'] as String?,
      bankAccountNumber: json['bank_account_number'] as String?,
      mobileMoneyProvider: json['mobile_money_provider'] as String?,
      isFavorite: json['is_favorite'] as bool? ?? false,
      isVerified: json['is_verified'] as bool? ?? false,
      transferCount: json['transfer_count'] as int? ?? 0,
      totalTransferred:
          (json['total_transferred'] as num?)?.toDouble() ?? 0.0,
      lastTransferAt: json['last_transfer_at'] != null
          ? DateTime.parse(json['last_transfer_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'wallet_id': walletId,
        'name': name,
        'phone_e164': phoneE164,
        'account_type': accountType.value,
        'beneficiary_user_id': beneficiaryUserId,
        'beneficiary_wallet_address': beneficiaryWalletAddress,
        'bank_code': bankCode,
        'bank_account_number': bankAccountNumber,
        'mobile_money_provider': mobileMoneyProvider,
        'is_favorite': isFavorite,
        'is_verified': isVerified,
        'transfer_count': transferCount,
        'total_transferred': totalTransferred,
        'last_transfer_at': lastTransferAt?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  Beneficiary copyWith({
    String? id,
    String? walletId,
    String? name,
    String? phoneE164,
    AccountType? accountType,
    String? beneficiaryUserId,
    String? beneficiaryWalletAddress,
    String? bankCode,
    String? bankAccountNumber,
    String? mobileMoneyProvider,
    bool? isFavorite,
    bool? isVerified,
    int? transferCount,
    double? totalTransferred,
    DateTime? lastTransferAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Beneficiary(
      id: id ?? this.id,
      walletId: walletId ?? this.walletId,
      name: name ?? this.name,
      phoneE164: phoneE164 ?? this.phoneE164,
      accountType: accountType ?? this.accountType,
      beneficiaryUserId: beneficiaryUserId ?? this.beneficiaryUserId,
      beneficiaryWalletAddress:
          beneficiaryWalletAddress ?? this.beneficiaryWalletAddress,
      bankCode: bankCode ?? this.bankCode,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      mobileMoneyProvider: mobileMoneyProvider ?? this.mobileMoneyProvider,
      isFavorite: isFavorite ?? this.isFavorite,
      isVerified: isVerified ?? this.isVerified,
      transferCount: transferCount ?? this.transferCount,
      totalTransferred: totalTransferred ?? this.totalTransferred,
      lastTransferAt: lastTransferAt ?? this.lastTransferAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Create Beneficiary Request
class CreateBeneficiaryRequest {
  final String name;
  final String? phoneE164;
  final AccountType accountType;
  final String? beneficiaryWalletAddress;
  final String? bankCode;
  final String? bankAccountNumber;
  final String? mobileMoneyProvider;

  const CreateBeneficiaryRequest({
    required this.name,
    this.phoneE164,
    required this.accountType,
    this.beneficiaryWalletAddress,
    this.bankCode,
    this.bankAccountNumber,
    this.mobileMoneyProvider,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone_e164': phoneE164,
        'account_type': accountType.value,
        'beneficiary_wallet_address': beneficiaryWalletAddress,
        'bank_code': bankCode,
        'bank_account_number': bankAccountNumber,
        'mobile_money_provider': mobileMoneyProvider,
      };
}

/// Update Beneficiary Request
class UpdateBeneficiaryRequest {
  final String? name;
  final String? phoneE164;

  const UpdateBeneficiaryRequest({
    this.name,
    this.phoneE164,
  });

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (phoneE164 != null) 'phone_e164': phoneE164,
      };
}
