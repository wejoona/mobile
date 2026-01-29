class Expense {
  final String id;
  final String category;
  final double amount;
  final String currency;
  final DateTime date;
  final String? vendor;
  final String? description;
  final String? receiptImagePath;
  final String? transactionId;
  final DateTime createdAt;

  const Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.currency,
    required this.date,
    this.vendor,
    this.description,
    this.receiptImagePath,
    this.transactionId,
    required this.createdAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'XOF',
      date: DateTime.parse(json['date'] as String),
      vendor: json['vendor'] as String?,
      description: json['description'] as String?,
      receiptImagePath: json['receiptImagePath'] as String?,
      transactionId: json['transactionId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'amount': amount,
        'currency': currency,
        'date': date.toIso8601String(),
        'vendor': vendor,
        'description': description,
        'receiptImagePath': receiptImagePath,
        'transactionId': transactionId,
        'createdAt': createdAt.toIso8601String(),
      };

  Expense copyWith({
    String? id,
    String? category,
    double? amount,
    String? currency,
    DateTime? date,
    String? vendor,
    String? description,
    String? receiptImagePath,
    String? transactionId,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      date: date ?? this.date,
      vendor: vendor ?? this.vendor,
      description: description ?? this.description,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      transactionId: transactionId ?? this.transactionId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ExpenseCategory {
  static const String travel = 'travel';
  static const String meals = 'meals';
  static const String office = 'office';
  static const String transport = 'transport';
  static const String other = 'other';

  static const List<String> all = [
    travel,
    meals,
    office,
    transport,
    other,
  ];
}

class OcrResult {
  final double? amount;
  final DateTime? date;
  final String? vendor;

  const OcrResult({
    this.amount,
    this.date,
    this.vendor,
  });
}
