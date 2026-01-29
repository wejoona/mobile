import 'package:flutter/material.dart';

/// Category of spending for analytics
class SpendingCategory {
  final String name;
  final double amount;
  final double percentage;
  final Color color;
  final int transactionCount;

  const SpendingCategory({
    required this.name,
    required this.amount,
    required this.percentage,
    required this.color,
    required this.transactionCount,
  });

  factory SpendingCategory.fromJson(Map<String, dynamic> json) {
    return SpendingCategory(
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
      color: Color(json['color'] as int),
      transactionCount: json['transactionCount'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'amount': amount,
        'percentage': percentage,
        'color': color.toARGB32(),
        'transactionCount': transactionCount,
      };
}
