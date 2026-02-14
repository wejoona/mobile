import 'package:flutter/material.dart';

/// Savings pot entity — consolidated from domain + feature models.
class SavingsPot {
  final String id;
  final String userId;
  final String name;
  final String emoji;
  final Color color;
  final double targetAmount;
  final double currentAmount;
  final String currency;
  final DateTime? targetDate;
  final bool isLocked;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const SavingsPot({
    required this.id,
    this.userId = '',
    required this.name,
    this.emoji = '💰',
    this.color = const Color(0xFFD4A843),
    this.targetAmount = 0,
    required this.currentAmount,
    this.currency = 'USDC',
    this.targetDate,
    this.isLocked = false,
    required this.createdAt,
    this.updatedAt,
  });

  /// Progress toward goal (0.0 to 1.0).
  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  /// Progress as percentage (0 to 100).
  int get progressPercent => (progress * 100).round();

  /// Remaining amount to reach goal.
  double get remaining => (targetAmount - currentAmount).clamp(0, targetAmount);

  /// Whether the goal has been reached.
  bool get isGoalReached => currentAmount >= targetAmount && targetAmount > 0;

  /// Whether the target date has passed.
  bool get isOverdue =>
      targetDate != null && DateTime.now().isAfter(targetDate!);

  /// Days remaining until target date.
  int? get daysRemaining => targetDate?.difference(DateTime.now()).inDays;

  factory SavingsPot.fromJson(Map<String, dynamic> json) {
    return SavingsPot(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String,
      emoji: json['emoji'] as String? ?? '💰',
      color: json['color'] != null ? Color(json['color'] as int) : const Color(0xFFD4A843),
      targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0,
      currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'USDC',
      targetDate: json['targetDate'] != null
          ? DateTime.parse(json['targetDate'] as String)
          : null,
      isLocked: json['isLocked'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'name': name,
        'emoji': emoji,
        'color': color.value,
        'targetAmount': targetAmount,
        'currentAmount': currentAmount,
        'currency': currency,
        'targetDate': targetDate?.toIso8601String(),
        'isLocked': isLocked,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  SavingsPot copyWith({
    String? id,
    String? userId,
    String? name,
    String? emoji,
    Color? color,
    double? targetAmount,
    double? currentAmount,
    String? currency,
    DateTime? targetDate,
    bool? isLocked,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavingsPot(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      currency: currency ?? this.currency,
      targetDate: targetDate ?? this.targetDate,
      isLocked: isLocked ?? this.isLocked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
