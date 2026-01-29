import 'transfer_frequency.dart';

class CreateRecurringTransferRequest {
  final String recipientPhone;
  final String recipientName;
  final double amount;
  final String currency;
  final TransferFrequency frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final int? occurrences;
  final String? note;
  final int? dayOfWeek; // For weekly/biweekly (1=Monday, 7=Sunday)
  final int? dayOfMonth; // For monthly (1-31)

  const CreateRecurringTransferRequest({
    required this.recipientPhone,
    required this.recipientName,
    required this.amount,
    required this.currency,
    required this.frequency,
    required this.startDate,
    this.endDate,
    this.occurrences,
    this.note,
    this.dayOfWeek,
    this.dayOfMonth,
  });

  Map<String, dynamic> toJson() => {
    'recipientPhone': recipientPhone,
    'recipientName': recipientName,
    'amount': amount,
    'currency': currency,
    'frequency': frequency.toJson(),
    'startDate': startDate.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'occurrences': occurrences,
    'note': note,
    'dayOfWeek': dayOfWeek,
    'dayOfMonth': dayOfMonth,
  };

  CreateRecurringTransferRequest copyWith({
    String? recipientPhone,
    String? recipientName,
    double? amount,
    String? currency,
    TransferFrequency? frequency,
    DateTime? startDate,
    DateTime? endDate,
    int? occurrences,
    String? note,
    int? dayOfWeek,
    int? dayOfMonth,
  }) {
    return CreateRecurringTransferRequest(
      recipientPhone: recipientPhone ?? this.recipientPhone,
      recipientName: recipientName ?? this.recipientName,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      occurrences: occurrences ?? this.occurrences,
      note: note ?? this.note,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
    );
  }
}
