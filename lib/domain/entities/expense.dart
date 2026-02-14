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
    return Expense(
      id: json['id'] as String,
      transactionId: json['transactionId'] as String,
      category: json['category'] as String,
      subcategory: json['subcategory'] as String?,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USDC',
      merchantName: json['merchantName'] as String?,
      vendor: json['vendor'] as String?,
      note: json['note'] as String?,
      description: json['description'] as String?,
      receiptImagePath: json['receiptImagePath'] as String?,
      date: DateTime.parse(json['date'] as String),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
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

  const OcrResult({this.amount, this.vendor, this.category, this.date, this.currency});
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
    transport, travel, food, meals, utilities, telecom, health, education,
    shopping, entertainment, transfers, bills, savings, office, other,
  ];

  static String label(String category) {
    switch (category) {
      case transport: return 'Transport';
      case food: return 'Food & Drink';
      case utilities: return 'Utilities';
      case telecom: return 'Mobile & Internet';
      case health: return 'Health';
      case education: return 'Education';
      case shopping: return 'Shopping';
      case entertainment: return 'Entertainment';
      case transfers: return 'Transfers';
      case bills: return 'Bills';
      case savings: return 'Savings';
      case office: return 'Office';
      case travel: return 'Travel';
      case meals: return 'Meals';
      default: return 'Other';
    }
  }
}
