import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/referral.dart';
import '../../../services/api/api_client.dart';

/// Referral program state provider.
final referralProvider = FutureProvider<ReferralInfo>((ref) async {
  final dio = ref.watch(dioProvider);
  final link = ref.keepAlive();

  Timer(const Duration(minutes: 5), () => link.close());

  final response = await dio.get('/referrals');
  return ReferralInfo.fromJson(response.data as Map<String, dynamic>);
});

/// Referral info model.
class ReferralInfo {
  final String referralCode;
  final String referralLink;
  final int totalReferrals;
  final int successfulReferrals;
  final double totalEarned;
  final String currency;
  final List<ReferralEntry> referrals;

  const ReferralInfo({
    required this.referralCode,
    required this.referralLink,
    this.totalReferrals = 0,
    this.successfulReferrals = 0,
    this.totalEarned = 0,
    this.currency = 'USDC',
    this.referrals = const [],
  });

  factory ReferralInfo.fromJson(Map<String, dynamic> json) {
    return ReferralInfo(
      referralCode: json['referralCode'] as String? ?? '',
      referralLink: json['referralLink'] as String? ?? '',
      totalReferrals: json['totalReferrals'] as int? ?? 0,
      successfulReferrals: json['successfulReferrals'] as int? ?? 0,
      totalEarned: (json['totalEarned'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'USDC',
      referrals: (json['referrals'] as List?)
              ?.map((e) =>
                  ReferralEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ReferralEntry {
  final String id;
  final String referredName;
  final String status;
  final double? reward;
  final DateTime createdAt;

  const ReferralEntry({
    required this.id,
    required this.referredName,
    required this.status,
    this.reward,
    required this.createdAt,
  });

  factory ReferralEntry.fromJson(Map<String, dynamic> json) {
    return ReferralEntry(
      id: json['id'] as String,
      referredName: json['referredName'] as String? ?? 'Unknown',
      status: json['status'] as String? ?? 'pending',
      reward: (json['reward'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
