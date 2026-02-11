import 'package:usdc_wallet/features/recurring_transfers/models/transfer_frequency.dart';
import 'package:usdc_wallet/features/recurring_transfers/models/recurring_transfer_status.dart';

class RecurringTransfer {
  final String id;
  final String recipientPhone;
  final String recipientName;
  final double amount;
  final String currency;
  final TransferFrequency frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime nextExecutionDate;
  final int? occurrencesRemaining;
  final RecurringTransferStatus status;
  final String? note;
  final int? dayOfWeek; // For weekly/biweekly (1=Monday, 7=Sunday)
  final int? dayOfMonth; // For monthly (1-31)
  final DateTime createdAt;
  final DateTime updatedAt;
  final int executedCount;

  const RecurringTransfer({
    required this.id,
    required this.recipientPhone,
    required this.recipientName,
    required this.amount,
    required this.currency,
    required this.frequency,
    required this.startDate,
    this.endDate,
    required this.nextExecutionDate,
    this.occurrencesRemaining,
    required this.status,
    this.note,
    this.dayOfWeek,
    this.dayOfMonth,
    required this.createdAt,
    required this.updatedAt,
    this.executedCount = 0,
  });

  factory RecurringTransfer.fromJson(Map<String, dynamic> json) {
    return RecurringTransfer(
      id: json['id'] as String,
      recipientPhone: json['recipientPhone'] as String,
      recipientName: json['recipientName'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      frequency: TransferFrequencyExtension.fromJson(json['frequency'] as String),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
      nextExecutionDate: DateTime.parse(json['nextExecutionDate'] as String),
      occurrencesRemaining: json['occurrencesRemaining'] as int?,
      status: RecurringTransferStatusExtension.fromJson(json['status'] as String),
      note: json['note'] as String?,
      dayOfWeek: json['dayOfWeek'] as int?,
      dayOfMonth: json['dayOfMonth'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      executedCount: json['executedCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'recipientPhone': recipientPhone,
    'recipientName': recipientName,
    'amount': amount,
    'currency': currency,
    'frequency': frequency.toJson(),
    'startDate': startDate.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'nextExecutionDate': nextExecutionDate.toIso8601String(),
    'occurrencesRemaining': occurrencesRemaining,
    'status': status.toJson(),
    'note': note,
    'dayOfWeek': dayOfWeek,
    'dayOfMonth': dayOfMonth,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'executedCount': executedCount,
  };

  RecurringTransfer copyWith({
    String? id,
    String? recipientPhone,
    String? recipientName,
    double? amount,
    String? currency,
    TransferFrequency? frequency,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? nextExecutionDate,
    int? occurrencesRemaining,
    RecurringTransferStatus? status,
    String? note,
    int? dayOfWeek,
    int? dayOfMonth,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? executedCount,
  }) {
    return RecurringTransfer(
      id: id ?? this.id,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      recipientName: recipientName ?? this.recipientName,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      nextExecutionDate: nextExecutionDate ?? this.nextExecutionDate,
      occurrencesRemaining: occurrencesRemaining ?? this.occurrencesRemaining,
      status: status ?? this.status,
      note: note ?? this.note,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      executedCount: executedCount ?? this.executedCount,
    );
  }

  bool get isActive => status == RecurringTransferStatus.active;
  bool get isPaused => status == RecurringTransferStatus.paused;
  bool get isCompleted => status == RecurringTransferStatus.completed;
  bool get isCancelled => status == RecurringTransferStatus.cancelled;

  String getFrequencyDescription(String locale) {
    final isFrench = locale.startsWith('fr');

    switch (frequency) {
      case TransferFrequency.daily:
        return isFrench ? 'Tous les jours à 9h00' : 'Every day at 9:00 AM';

      case TransferFrequency.weekly:
        final days = isFrench
            ? ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche']
            : ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
        final dayName = dayOfWeek != null ? days[dayOfWeek! - 1] : days[0];
        return isFrench ? 'Tous les $dayName' : 'Every $dayName';

      case TransferFrequency.biweekly:
        final days = isFrench
            ? ['lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche']
            : ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
        final dayName = dayOfWeek != null ? days[dayOfWeek! - 1] : days[4];
        return isFrench
            ? 'Toutes les 2 semaines le $dayName'
            : 'Every 2 weeks on $dayName';

      case TransferFrequency.monthly:
        final day = dayOfMonth ?? 1;
        final suffix = _getDaySuffix(day);
        return isFrench ? 'Le $day de chaque mois' : '$day$suffix of every month';
      case TransferFrequency.quarterly:
        return isFrench ? 'Tous les 3 mois' : 'Every 3 months';
    }
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }
}
