class FeatureSubscriptionRequest {
  const FeatureSubscriptionRequest({
    required this.featureKey,
    required this.source,
    this.status,
    this.phone,
    this.email,
    this.featureName,
    this.requestedFeature,
    this.countryCode,
    this.locale,
    this.platform,
    this.appVersion,
    this.metadata,
  });

  final String featureKey;
  final String source;
  final String? status;
  final String? phone;
  final String? email;
  final String? featureName;
  final String? requestedFeature;
  final String? countryCode;
  final String? locale;
  final String? platform;
  final String? appVersion;
  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toJson() => {
    'featureKey': featureKey,
    'source': source,
    if (status != null && status!.isNotEmpty) 'status': status,
    if (phone != null && phone!.isNotEmpty) 'phone': phone,
    if (email != null && email!.isNotEmpty) 'email': email,
    if (featureName != null && featureName!.isNotEmpty)
      'featureName': featureName,
    if (requestedFeature != null && requestedFeature!.isNotEmpty)
      'requestedFeature': requestedFeature,
    if (countryCode != null && countryCode!.isNotEmpty)
      'countryCode': countryCode,
    if (locale != null && locale!.isNotEmpty) 'locale': locale,
    if (platform != null && platform!.isNotEmpty) 'platform': platform,
    if (appVersion != null && appVersion!.isNotEmpty) 'appVersion': appVersion,
    if (metadata != null && metadata!.isNotEmpty) 'metadata': metadata,
  };

  FeatureSubscriptionRequest copyWith({
    String? status,
    String? platform,
    String? appVersion,
  }) => FeatureSubscriptionRequest(
    featureKey: featureKey,
    source: source,
    status: status ?? this.status,
    phone: phone,
    email: email,
    featureName: featureName,
    requestedFeature: requestedFeature,
    countryCode: countryCode,
    locale: locale,
    platform: platform ?? this.platform,
    appVersion: appVersion ?? this.appVersion,
    metadata: metadata,
  );
}
