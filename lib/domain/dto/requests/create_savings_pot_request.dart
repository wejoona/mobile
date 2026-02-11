/// Request DTO for creating a savings pot.
class CreateSavingsPotRequest {
  final String name;
  final double targetAmount;
  final String currency;
  final String? description;
  final DateTime? targetDate;
  final String? iconName;
  final String? colorHex;

  const CreateSavingsPotRequest({
    required this.name,
    required this.targetAmount,
    this.currency = 'USDC',
    this.description,
    this.targetDate,
    this.iconName,
    this.colorHex,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'targetAmount': targetAmount,
        'currency': currency,
        if (description != null) 'description': description,
        if (targetDate != null) 'targetDate': targetDate!.toIso8601String(),
        if (iconName != null) 'iconName': iconName,
        if (colorHex != null) 'colorHex': colorHex,
      };
}
