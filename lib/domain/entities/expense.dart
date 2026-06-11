/// Expense entity for categorized spending tracking.
class Expense {
  final String id;
  final String transactionId;
  final String category;
  final String? subcategory;
  final double amount;
  final String currency;
  final String? merchantName;
  final String? vendor;
  final String? note;
  final String? description;
  final String? receiptImagePath;
  final DateTime date;
  final DateTime? createdAt;
  final List<String>? tags;

  const Expense({
    required this.id,
    this.transactionId = '',
    required this.category,
    this.subcategory,
    required this.amount,
    this.currency = 'USDC',
    this.merchantName,
    this.vendor,
    this.note,
    this.description,
    this.receiptImagePath,
    required this.date,
    this.createdAt,
    this.tags,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    final id =
        _string(json, const ['id', 'categoryId', 'category_id']) ??
        _string(json, const ['category'], fallback: 'expense');
    final category = _string(json, const [
      'category',
      'name',
    ], fallback: ExpenseCategory.other)!;
    final date =
        _date(json, const ['date', 'createdAt', 'created_at']) ??
        DateTime.now();

    return Expense(
      id: id!,
      transactionId:
          _string(json, const ['transactionId', 'transaction_id']) ?? '',
      category: category,
      subcategory: _string(json, const ['subcategory', 'sub_category']),
      amount: _amount(json),
      currency: _string(json, const ['currency'], fallback: 'USDC')!,
      merchantName: _string(json, const ['merchantName', 'merchant_name']),
      vendor: _string(json, const ['vendor', 'merchant', 'label', 'name']),
      note: _string(json, const ['note']),
      description: _string(json, const ['description']),
      receiptImagePath: _string(json, const [
        'receiptImagePath',
        'receipt_image_path',
      ]),
      date: date,
      createdAt: _date(json, const ['createdAt', 'created_at']),
      tags: (json['tags'] as List?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'transactionId': transactionId,
    'category': category,
    'subcategory': subcategory,
    'amount': amount,
    'currency': currency,
    'merchantName': merchantName,
    'vendor': vendor,
    'note': note,
    'description': description,
    'receiptImagePath': receiptImagePath,
    'date': date.toIso8601String(),
    'createdAt': createdAt?.toIso8601String(),
    'tags': tags,
  };
}

String? _string(
  Map<String, dynamic> json,
  List<String> keys, {
  String? fallback,
}) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final string = value.toString().trim();
    if (string.isNotEmpty) return string;
  }
  return fallback;
}

double _amount(Map<String, dynamic> json) {
  for (final key in const ['amount', 'totalAmount', 'total_amount', 'value']) {
    final value = json[key];
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
  }
  return 0;
}

DateTime? _date(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is DateTime) return value;
    if (value == null) continue;
    final parsed = DateTime.tryParse(value.toString());
    if (parsed != null) return parsed;
  }
  return null;
}

/// Spending summary by category.
class SpendingSummary {
  final String category;
  final double totalAmount;
  final int transactionCount;
  final double percentageOfTotal;

  const SpendingSummary({
    required this.category,
    required this.totalAmount,
    required this.transactionCount,
    required this.percentageOfTotal,
  });

  factory SpendingSummary.fromJson(Map<String, dynamic> json) {
    return SpendingSummary(
      category: json['category'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      transactionCount: json['transactionCount'] as int,
      percentageOfTotal: (json['percentageOfTotal'] as num).toDouble(),
    );
  }
}

/// Alias for backward compatibility.
typedef ExpenseCategory = ExpenseCategories;

/// OCR receipt processing result (placeholder).
class OcrResult {
  final double? amount;
  final String? vendor;
  final String? category;
  final DateTime? date;
  final String? currency;

  const OcrResult({
    this.amount,
    this.vendor,
    this.category,
    this.date,
    this.currency,
  });
}

/// Predefined expense categories for West Africa.
class ExpenseCategories {
  ExpenseCategories._();

  static const transport = 'transport';
  static const travel = 'travel';
  static const food = 'food';
  static const meals = 'meals';
  static const utilities = 'utilities';
  static const telecom = 'telecom';
  static const health = 'health';
  static const education = 'education';
  static const shopping = 'shopping';
  static const entertainment = 'entertainment';
  static const transfers = 'transfers';
  static const bills = 'bills';
  static const savings = 'savings';
  static const office = 'office';
  static const other = 'other';

  static const all = [
    transport,
    travel,
    food,
    meals,
    utilities,
    telecom,
    health,
    education,
    shopping,
    entertainment,
    transfers,
    bills,
    savings,
    office,
    other,
  ];

  static String label(String category) {
    switch (category) {
      case transport:
        return 'Transport';
      case food:
        return 'Food & Drink';
      case utilities:
        return 'Utilities';
      case telecom:
        return 'Mobile & Internet';
      case health:
        return 'Health';
      case education:
        return 'Education';
      case shopping:
        return 'Shopping';
      case entertainment:
        return 'Entertainment';
      case transfers:
        return 'Transfers';
      case bills:
        return 'Bills';
      case savings:
        return 'Savings';
      case office:
        return 'Office';
      case travel:
        return 'Travel';
      case meals:
        return 'Meals';
      default:
        return 'Other';
    }
  }
}
