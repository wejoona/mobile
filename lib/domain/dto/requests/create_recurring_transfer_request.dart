/// Request DTO for creating a recurring transfer.
class CreateRecurringTransferRequest {
  final String recipientPhone;
  final double amount;
  final String currency;
  final String frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final String? description;

  const CreateRecurringTransferRequest({
    required this.recipientPhone,
    required this.amount,
    this.currency = 'USDC',
    required this.frequency,
    required this.startDate,
    this.endDate,
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'recipientPhone': recipientPhone,
        'amount': amount,
        'currency': currency,
        'frequency': frequency,
        'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate!.toIso8601String(),
        if (description != null) 'description': description,
      };
}
