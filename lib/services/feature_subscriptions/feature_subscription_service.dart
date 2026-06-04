import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

class FeatureSubscriptionRequest {
  const FeatureSubscriptionRequest({
    required this.featureKey,
    required this.source,
    this.status = 'subscribed',
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
  final String status;
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
    'status': status,
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
}

class FeatureSubscription {
  const FeatureSubscription({
    required this.id,
    required this.featureKey,
    required this.source,
    required this.status,
    required this.isActive,
    this.phone,
    this.email,
    this.metadata,
  });

  final String id;
  final String featureKey;
  final String source;
  final String status;
  final bool isActive;
  final String? phone;
  final String? email;
  final Map<String, dynamic>? metadata;

  factory FeatureSubscription.fromJson(Map<String, dynamic> json) {
    return FeatureSubscription(
      id: json['id'] as String,
      featureKey: json['featureKey'] as String,
      source: json['source'] as String,
      status: json['status'] as String? ?? 'subscribed',
      isActive: json['isActive'] as bool? ?? true,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      metadata: json['metadata'] is Map
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
    );
  }
}

class FeatureSubscriptionService {
  FeatureSubscriptionService(this._dio);

  final Dio _dio;

  Future<FeatureSubscription> subscribe(
    FeatureSubscriptionRequest request,
  ) async {
    final response = await _dio.post(
      '/feature-subscriptions',
      data: request.toJson(),
    );
    return FeatureSubscription.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<List<FeatureSubscription>> listMine({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get(
      '/feature-subscriptions',
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = response.data;
    final List<dynamic> items;
    if (data is Map<String, dynamic>) {
      items =
          (data['items'] ?? data['data'] ?? data['subscriptions']) as List? ??
          [];
    } else if (data is List) {
      items = data;
    } else {
      items = [];
    }
    return items
        .map(
          (item) => FeatureSubscription.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }
}

final featureSubscriptionServiceProvider = Provider<FeatureSubscriptionService>(
  (ref) {
    return FeatureSubscriptionService(ref.watch(dioProvider));
  },
);
