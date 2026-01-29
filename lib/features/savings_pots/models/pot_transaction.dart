/// Transaction type for pot operations
enum PotTransactionType {
  deposit,
  withdraw,
}

/// Transaction record for pot money movements
class PotTransaction {
  final String id;
  final String potId;
  final PotTransactionType type;
  final double amount;
  final DateTime timestamp;
  final String? note;

  const PotTransaction({
    required this.id,
    required this.potId,
    required this.type,
    required this.amount,
    required this.timestamp,
    this.note,
  });

  factory PotTransaction.fromJson(Map<String, dynamic> json) {
    return PotTransaction(
      id: json['id'] as String,
      potId: json['potId'] as String,
      type: PotTransactionType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      amount: (json['amount'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'potId': potId,
    'type': type.name,
    'amount': amount,
    'timestamp': timestamp.toIso8601String(),
    'note': note,
  };
}
