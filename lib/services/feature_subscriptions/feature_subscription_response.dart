class FeatureSubscriptionResponse {
  const FeatureSubscriptionResponse({
    required this.id,
    required this.featureKey,
    required this.source,
    required this.status,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.phone,
    this.email,
    this.userId,
    this.metadata,
  });

  final String id;
  final String featureKey;
  final String source;
  final String status;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? phone;
  final String? email;
  final String? userId;
  final Map<String, dynamic>? metadata;

  factory FeatureSubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return FeatureSubscriptionResponse(
      id: json['id'] as String,
      featureKey: json['featureKey'] as String,
      source: json['source'] as String,
      status: json['status'] as String,
      isActive: json['isActive'] as bool? ?? false,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      userId: json['userId'] as String?,
      metadata: _parseMetadata(json['metadata']),
    );
  }

  static DateTime _parseDate(Object? value) {
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  static Map<String, dynamic>? _parseMetadata(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }
}
