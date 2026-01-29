/// Top recipient data for insights
class TopRecipient {
  final String id;
  final String name;
  final String? phoneNumber;
  final String? avatarUrl;
  final double totalSent;
  final double percentage;
  final int transactionCount;

  const TopRecipient({
    required this.id,
    required this.name,
    this.phoneNumber,
    this.avatarUrl,
    required this.totalSent,
    required this.percentage,
    required this.transactionCount,
  });

  factory TopRecipient.fromJson(Map<String, dynamic> json) {
    return TopRecipient(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      totalSent: (json['totalSent'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
      transactionCount: json['transactionCount'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phoneNumber': phoneNumber,
        'avatarUrl': avatarUrl,
        'totalSent': totalSent,
        'percentage': percentage,
        'transactionCount': transactionCount,
      };
}
