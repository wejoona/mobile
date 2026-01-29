/// Bank Model
library;

enum BankVerificationMethod {
  microDeposit,
  otp,
  instantVerification;

  String get value {
    switch (this) {
      case BankVerificationMethod.microDeposit:
        return 'micro_deposit';
      case BankVerificationMethod.otp:
        return 'otp';
      case BankVerificationMethod.instantVerification:
        return 'instant_verification';
    }
  }

  static BankVerificationMethod fromString(String value) {
    switch (value) {
      case 'micro_deposit':
        return BankVerificationMethod.microDeposit;
      case 'otp':
        return BankVerificationMethod.otp;
      case 'instant_verification':
        return BankVerificationMethod.instantVerification;
      default:
        return BankVerificationMethod.otp;
    }
  }
}

class Bank {
  final String code;
  final String name;
  final String logoUrl;
  final String country;
  final bool isSupported;
  final List<BankVerificationMethod> verificationMethods;
  final bool supportsBalanceCheck;
  final bool supportsDirectDebit;

  const Bank({
    required this.code,
    required this.name,
    required this.logoUrl,
    required this.country,
    this.isSupported = true,
    this.verificationMethods = const [BankVerificationMethod.otp],
    this.supportsBalanceCheck = false,
    this.supportsDirectDebit = true,
  });

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      code: json['code'] as String,
      name: json['name'] as String,
      logoUrl: json['logo_url'] as String,
      country: json['country'] as String,
      isSupported: json['is_supported'] as bool? ?? true,
      verificationMethods: (json['verification_methods'] as List?)
              ?.map((m) => BankVerificationMethod.fromString(m as String))
              .toList() ??
          [BankVerificationMethod.otp],
      supportsBalanceCheck: json['supports_balance_check'] as bool? ?? false,
      supportsDirectDebit: json['supports_direct_debit'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'logo_url': logoUrl,
        'country': country,
        'is_supported': isSupported,
        'verification_methods':
            verificationMethods.map((m) => m.value).toList(),
        'supports_balance_check': supportsBalanceCheck,
        'supports_direct_debit': supportsDirectDebit,
      };
}
