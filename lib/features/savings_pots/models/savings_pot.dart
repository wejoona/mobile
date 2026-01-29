import 'package:flutter/material.dart';

/// Savings Pot Model - A labeled container for saving money toward specific goals
class SavingsPot {
  final String id;
  final String name;
  final String emoji;
  final Color color;
  final double currentAmount;
  final double? targetAmount; // Optional goal
  final DateTime createdAt;
  final DateTime updatedAt;

  const SavingsPot({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    required this.currentAmount,
    this.targetAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Progress percentage (0.0 to 1.0) if goal is set
  double? get progress {
    if (targetAmount == null || targetAmount! <= 0) return null;
    return (currentAmount / targetAmount!).clamp(0.0, 1.0);
  }

  /// Whether the goal has been reached
  bool get isGoalReached {
    if (targetAmount == null) return false;
    return currentAmount >= targetAmount!;
  }

  factory SavingsPot.fromJson(Map<String, dynamic> json) {
    return SavingsPot(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String,
      color: Color(json['color'] as int),
      currentAmount: (json['currentAmount'] as num).toDouble(),
      targetAmount: json['targetAmount'] != null
          ? (json['targetAmount'] as num).toDouble()
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'emoji': emoji,
    'color': color.value,
    'currentAmount': currentAmount,
    'targetAmount': targetAmount,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  SavingsPot copyWith({
    String? id,
    String? name,
    String? emoji,
    Color? color,
    double? currentAmount,
    double? targetAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavingsPot(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
      currentAmount: currentAmount ?? this.currentAmount,
      targetAmount: targetAmount ?? this.targetAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
