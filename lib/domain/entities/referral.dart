/// Referral entity - mirrors backend Referral entity
class Referral {
  final String id;
  final String referrerId;
  final String referredId;
  final String status;
  final double? rewardAmount;
  final DateTime createdAt;
  final DateTime? completedAt;

  const Referral({
    required this.id,
    required this.referrerId,
    required this.referredId,
    required this.status,
    this.rewardAmount,
    required this.createdAt,
    this.completedAt,
  });

  factory Referral.fromJson(Map<String, dynamic> json) {
    return Referral(
      id: json['id'] as String,
      referrerId: json['referrerId'] as String,
      referredId: json['referredId'] as String,
      status: json['status'] as String,
      rewardAmount: (json['rewardAmount'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }
}

/// Referral Stats
class ReferralStats {
  final String referralCode;
  final int totalReferrals;
  final int pendingReferrals;
  final int completedReferrals;
  final double totalEarnings;

  const ReferralStats({
    required this.referralCode,
    required this.totalReferrals,
    required this.pendingReferrals,
    required this.completedReferrals,
    required this.totalEarnings,
  });

  factory ReferralStats.fromJson(Map<String, dynamic> json) {
    return ReferralStats(
      referralCode: json['referralCode'] as String,
      totalReferrals: json['totalReferrals'] as int? ?? 0,
      pendingReferrals: json['pendingReferrals'] as int? ?? 0,
      completedReferrals: json['completedReferrals'] as int? ?? 0,
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0,
    );
  }
}
