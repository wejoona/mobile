/// Account Types for Beneficiaries
enum AccountType {
  joonapayUser('joonapay_user'),
  externalWallet('external_wallet'),
  bankAccount('bank_account'),
  mobileMoney('mobile_money');

  final String value;
  const AccountType(this.value);

  static AccountType fromString(String value) {
    if (value == 'korido_user' || value == 'internal') {
      return AccountType.joonapayUser;
    }
    if (value == 'external') {
      return AccountType.externalWallet;
    }
    if (value == 'bank') {
      return AccountType.bankAccount;
    }
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
    Object? read(String camel, String snake) => json[camel] ?? json[snake];
    String? readString(String camel, String snake) =>
        read(camel, snake)?.toString();
    int readInt(String camel, String snake) {
      final value = read(camel, snake);
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    double readDouble(String camel, String snake) {
      final value = read(camel, snake);
      if (value is double) return value;
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0.0;
    }

    bool readBool(String camel, String snake) {
      final value = read(camel, snake);
      if (value is bool) return value;
      return value?.toString().toLowerCase() == 'true';
    }

    DateTime? readDate(String camel, String snake) {
      final value = readString(camel, snake);
      if (value == null || value.isEmpty) return null;
      return DateTime.tryParse(value);
    }

    final now = DateTime.now();
    final createdAtValue = readDate('createdAt', 'created_at') ?? now;
    final updatedAtValue =
        readDate('updatedAt', 'updated_at') ?? createdAtValue;
    final accountTypeValue =
        readString('accountType', 'account_type') ??
        AccountType.joonapayUser.value;

    return Beneficiary(
      id: json['id'] as String,
      walletId: readString('walletId', 'wallet_id') ?? '',
      name: json['name'] as String,
      phoneE164: readString('phoneE164', 'phone_e164'),
      accountType: AccountType.fromString(accountTypeValue),
      beneficiaryUserId: readString('beneficiaryUserId', 'beneficiary_user_id'),
      beneficiaryWalletAddress: readString(
        'beneficiaryWalletAddress',
        'beneficiary_wallet_address',
      ),
      bankCode: readString('bankCode', 'bank_code'),
      bankAccountNumber: readString('bankAccountNumber', 'bank_account_number'),
      mobileMoneyProvider: readString(
        'mobileMoneyProvider',
        'mobile_money_provider',
      ),
      isFavorite: readBool('isFavorite', 'is_favorite'),
      isVerified: readBool('isVerified', 'is_verified'),
      transferCount: readInt('transferCount', 'transfer_count'),
      totalTransferred: readDouble('totalTransferred', 'total_transferred'),
      lastTransferAt: readDate('lastTransferAt', 'last_transfer_at'),
      createdAt: createdAtValue,
      updatedAt: updatedAtValue,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'walletId': walletId,
    'name': name,
    'phoneE164': phoneE164,
    'accountType': accountType.value,
    'beneficiaryUserId': beneficiaryUserId,
    'beneficiaryWalletAddress': beneficiaryWalletAddress,
    'bankCode': bankCode,
    'bankAccountNumber': bankAccountNumber,
    'mobileMoneyProvider': mobileMoneyProvider,
    'isFavorite': isFavorite,
    'isVerified': isVerified,
    'transferCount': transferCount,
    'totalTransferred': totalTransferred,
    'lastTransferAt': lastTransferAt?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
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
    'phoneE164': phoneE164,
    'accountType': accountType.value,
    'beneficiaryWalletAddress': beneficiaryWalletAddress,
    'bankCode': bankCode,
    'bankAccountNumber': bankAccountNumber,
    'mobileMoneyProvider': mobileMoneyProvider,
  };
}

/// Update Beneficiary Request
class UpdateBeneficiaryRequest {
  final String? name;

  const UpdateBeneficiaryRequest({this.name});

  Map<String, dynamic> toJson() => {if (name != null) 'name': name};
}
