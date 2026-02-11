class BulkPayment {
  final String phone;
  final double amount;
  final String description;
  final bool isValid;
  final String? error;

  const BulkPayment({
    required this.phone,
    required this.amount,
    required this.description,
    this.isValid = true,
    this.error,
  });

  factory BulkPayment.fromCsvRow(List<String> row, int rowIndex) {
    if (row.length < 3) {
      return BulkPayment(
        phone: row.isNotEmpty ? row[0].trim() : '',
        amount: 0,
        description: '',
        isValid: false,
        error: 'Invalid CSV format: missing columns',
      );
    }

    final phone = row[0].trim();
    final amountStr = row[1].trim();
    final description = row[2].trim();

    // Validate phone
    if (phone.isEmpty) {
      return BulkPayment(
        phone: phone,
        amount: 0,
        description: description,
        isValid: false,
        error: 'Phone number is required',
      );
    }

    if (!_isValidPhone(phone)) {
      return BulkPayment(
        phone: phone,
        amount: 0,
        description: description,
        isValid: false,
        error: 'Invalid phone number format',
      );
    }

    // Validate amount
    final amount = double.tryParse(amountStr);
    if (amount == null) {
      return BulkPayment(
        phone: phone,
        amount: 0,
        description: description,
        isValid: false,
        error: 'Invalid amount: must be a number',
      );
    }

    if (amount <= 0) {
      return BulkPayment(
        phone: phone,
        amount: amount,
        description: description,
        isValid: false,
        error: 'Amount must be greater than 0',
      );
    }

    // Validate description
    if (description.isEmpty) {
      return BulkPayment(
        phone: phone,
        amount: amount,
        description: description,
        isValid: false,
        error: 'Description is required',
      );
    }

    return BulkPayment(
      phone: phone,
      amount: amount,
      description: description,
      isValid: true,
    );
  }

  static bool _isValidPhone(String phone) {
    // West African phone format: +225XXXXXXXXXX or similar
    final phoneRegex = RegExp(r'^\+[0-9]{10,15}$');
    return phoneRegex.hasMatch(phone);
  }

  bool get hasErrors => !isValid || error != null;

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'amount': amount,
        'description': description,
      };

  BulkPayment copyWith({
    String? phone,
    double? amount,
    String? description,
    bool? isValid,
    String? error,
  }) {
    return BulkPayment(
      phone: phone ?? this.phone,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      isValid: isValid ?? this.isValid,
      error: error ?? this.error,
    );
  }
}
