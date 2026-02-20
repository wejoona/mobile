import 'package:usdc_wallet/features/insights/models/spending_category.dart';

/// Summary of spending for a period
class SpendingSummary {
  final double totalSpent;
  final double totalReceived;
  final double netFlow;
  final List<SpendingCategory> topCategories;
  final double percentageChange;
  final bool isIncrease;

  const SpendingSummary({
    required this.totalSpent,
    required this.totalReceived,
    required this.netFlow,
    required this.topCategories,
    required this.percentageChange,
    required this.isIncrease,
  });

  factory SpendingSummary.fromJson(Map<String, dynamic> json) {
    return SpendingSummary(
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0,
      totalReceived: (json['totalReceived'] as num?)?.toDouble() ?? 0,
      netFlow: (json['netFlow'] as num?)?.toDouble() ?? 0,
      topCategories: (json['topCategories'] as List<dynamic>?)
              ?.map((e) => SpendingCategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      percentageChange: (json['percentageChange'] as num?)?.toDouble() ?? 0,
      isIncrease: json['isIncrease'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalSpent': totalSpent,
        'totalReceived': totalReceived,
        'netFlow': netFlow,
        'topCategories': topCategories.map((c) => c.toJson()).toList(),
        'percentageChange': percentageChange,
        'isIncrease': isIncrease,
      };

  factory SpendingSummary.empty() {
    return const SpendingSummary(
      totalSpent: 0,
      totalReceived: 0,
      netFlow: 0,
      topCategories: [],
      percentageChange: 0,
      isIncrease: false,
    );
  }
}
