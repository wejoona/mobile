enum KycTier {
  tier0, // Unverified
  tier1, // Basic verification (ID + selfie)
  tier2, // Address verification
  tier3; // Enhanced verification (video + source of funds)

  bool get isTier0 => this == KycTier.tier0;
  bool get isTier1 => this == KycTier.tier1;
  bool get isTier2 => this == KycTier.tier2;
  bool get isTier3 => this == KycTier.tier3;

  int get level {
    switch (this) {
      case KycTier.tier0:
        return 0;
      case KycTier.tier1:
        return 1;
      case KycTier.tier2:
        return 2;
      case KycTier.tier3:
        return 3;
    }
  }

  static KycTier fromInt(int tier) {
    switch (tier) {
      case 0:
        return KycTier.tier0;
      case 1:
        return KycTier.tier1;
      case 2:
        return KycTier.tier2;
      case 3:
        return KycTier.tier3;
      default:
        return KycTier.tier0;
    }
  }

  String toApiString() {
    return level.toString();
  }
}

class TierLimits {
  final String dailyLimit;
  final String monthlyLimit;
  final String perTransactionLimit;

  const TierLimits({
    required this.dailyLimit,
    required this.monthlyLimit,
    required this.perTransactionLimit,
  });

  factory TierLimits.fromJson(Map<String, dynamic> json) {
    return TierLimits(
      dailyLimit: json['dailyLimit'] as String,
      monthlyLimit: json['monthlyLimit'] as String,
      perTransactionLimit: json['perTransactionLimit'] as String,
    );
  }
}

class TierBenefits {
  final KycTier tier;
  final String name;
  final String description;
  final TierLimits limits;
  final List<String> features;
  final bool requiresAddressProof;
  final bool requiresVideoVerification;
  final bool requiresSourceOfFunds;

  const TierBenefits({
    required this.tier,
    required this.name,
    required this.description,
    required this.limits,
    required this.features,
    this.requiresAddressProof = false,
    this.requiresVideoVerification = false,
    this.requiresSourceOfFunds = false,
  });

  factory TierBenefits.fromJson(Map<String, dynamic> json) {
    return TierBenefits(
      tier: KycTier.fromInt(json['tier'] as int),
      name: json['name'] as String,
      description: json['description'] as String,
      limits: TierLimits.fromJson(json['limits'] as Map<String, dynamic>),
      features: (json['features'] as List<dynamic>).cast<String>(),
      requiresAddressProof: json['requiresAddressProof'] as bool? ?? false,
      requiresVideoVerification: json['requiresVideoVerification'] as bool? ?? false,
      requiresSourceOfFunds: json['requiresSourceOfFunds'] as bool? ?? false,
    );
  }

  static TierBenefits tier0() {
    return const TierBenefits(
      tier: KycTier.tier0,
      name: 'Basic',
      description: 'Limited access to core features',
      limits: TierLimits(
        dailyLimit: '0',
        monthlyLimit: '0',
        perTransactionLimit: '0',
      ),
      features: ['View balance', 'Receive funds'],
    );
  }

  static TierBenefits tier1() {
    return const TierBenefits(
      tier: KycTier.tier1,
      name: 'Verified',
      description: 'Standard transaction limits',
      limits: TierLimits(
        dailyLimit: '500000',
        monthlyLimit: '2000000',
        perTransactionLimit: '100000',
      ),
      features: [
        'Send & receive funds',
        'Mobile money deposits',
        'Bill payments',
        'QR payments',
      ],
    );
  }

  static TierBenefits tier2() {
    return const TierBenefits(
      tier: KycTier.tier2,
      name: 'Enhanced',
      description: 'Higher limits for regular users',
      limits: TierLimits(
        dailyLimit: '2000000',
        monthlyLimit: '10000000',
        perTransactionLimit: '500000',
      ),
      features: [
        'All Tier 1 features',
        'External transfers',
        'Virtual cards',
        'Savings pots',
        'Higher transaction limits',
      ],
      requiresAddressProof: true,
    );
  }

  static TierBenefits tier3() {
    return const TierBenefits(
      tier: KycTier.tier3,
      name: 'Premium',
      description: 'Maximum limits for power users',
      limits: TierLimits(
        dailyLimit: '10000000',
        monthlyLimit: '50000000',
        perTransactionLimit: '2000000',
      ),
      features: [
        'All Tier 2 features',
        'Business accounts',
        'Payment links',
        'Merchant services',
        'Priority support',
        'Maximum transaction limits',
      ],
      requiresAddressProof: true,
      requiresVideoVerification: true,
      requiresSourceOfFunds: true,
    );
  }
}
