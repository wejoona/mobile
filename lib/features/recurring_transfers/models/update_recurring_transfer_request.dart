import 'package:usdc_wallet/features/recurring_transfers/models/transfer_frequency.dart';

class UpdateRecurringTransferRequest {
  final double? amount;
  final TransferFrequency? frequency;
  final DateTime? endDate;
  final int? occurrences;
  final String? note;
  final int? dayOfWeek;
  final int? dayOfMonth;

  const UpdateRecurringTransferRequest({
    this.amount,
    this.frequency,
    this.endDate,
    this.occurrences,
    this.note,
    this.dayOfWeek,
    this.dayOfMonth,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (amount != null) data['amount'] = amount;
    if (frequency != null) data['frequency'] = frequency!.toJson();
    if (endDate != null) data['endDate'] = endDate!.toIso8601String();
    if (occurrences != null) data['occurrences'] = occurrences;
    if (note != null) data['note'] = note;
    if (dayOfWeek != null) data['dayOfWeek'] = dayOfWeek;
    if (dayOfMonth != null) data['dayOfMonth'] = dayOfMonth;
    return data;
  }
}
