class FeatureSubscriptionRequest {
  const FeatureSubscriptionRequest({
    required this.featureKey,
    required this.source,
    this.status,
    this.phone,
    this.email,
    this.metadata,
  });

  final String featureKey;
  final String source;
  final String? status;
  final String? phone;
  final String? email;
  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toJson() => {
    'featureKey': featureKey,
    'source': source,
    if (status != null) 'status': status,
    if (phone != null) 'phone': phone,
    if (email != null) 'email': email,
    if (metadata != null) 'metadata': metadata,
  };
}
