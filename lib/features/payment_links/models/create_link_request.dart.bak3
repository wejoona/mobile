class CreateLinkRequest {
  final double amount;
  final String currency;
  final String? description;
  final int? expiryHours; // Optional expiry in hours (default 24h)

  const CreateLinkRequest({
    required this.amount,
    required this.currency,
    this.description,
    this.expiryHours = 24,
  });

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'currency': currency,
        if (description != null && description!.isNotEmpty) 'description': description,
        if (expiryHours != null) 'expiryHours': expiryHours,
      };

  CreateLinkRequest copyWith({
    double? amount,
    String? currency,
    String? description,
    int? expiryHours,
  }) {
    return CreateLinkRequest(
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      expiryHours: expiryHours ?? this.expiryHours,
    );
  }
}
