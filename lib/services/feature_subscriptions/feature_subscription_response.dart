class FeatureSubscriptionResponse {
  const FeatureSubscriptionResponse({
    required this.id,
    required this.featureKey,
    required this.source,
    required this.status,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.featureName,
    this.requestedFeature,
    this.phone,
    this.email,
    this.userId,
    this.countryCode,
    this.locale,
    this.platform,
    this.appVersion,
    this.metadata,
  });

  factory FeatureSubscriptionResponse.fromJson(Map<String, dynamic> json) {
    final metadata = _parseMetadata(json['metadata']);
    return FeatureSubscriptionResponse(
      id: json['id'] as String,
      featureKey: json['featureKey'] as String,
      featureName:
          json['featureName'] as String? ??
          _metadataString(metadata, 'featureName'),
      requestedFeature:
          json['requestedFeature'] as String? ??
          _metadataString(metadata, 'requestedFeature'),
      source: json['source'] as String,
      status: json['status'] as String? ?? 'subscribed',
      isActive: json['isActive'] as bool? ?? true,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      userId: json['userId'] as String?,
      countryCode:
          json['countryCode'] as String? ??
          _metadataString(metadata, 'countryCode'),
      locale: json['locale'] as String? ?? _metadataString(metadata, 'locale'),
      platform:
          json['platform'] as String? ?? _metadataString(metadata, 'platform'),
      appVersion:
          json['appVersion'] as String? ??
          _metadataString(metadata, 'appVersion'),
      metadata: metadata,
    );
  }

  final String id;
  final String featureKey;
  final String? featureName;
  final String? requestedFeature;
  final String source;
  final String status;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? phone;
  final String? email;
  final String? userId;
  final String? countryCode;
  final String? locale;
  final String? platform;
  final String? appVersion;
  final Map<String, dynamic>? metadata;

  static DateTime _parseDate(Object? value) {
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  static Map<String, dynamic>? _parseMetadata(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  static String? _metadataString(Map<String, dynamic>? metadata, String key) {
    final value = metadata?[key];
    return value is String && value.trim().isNotEmpty ? value.trim() : null;
  }
}
