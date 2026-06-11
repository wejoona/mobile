import 'package:dio/dio.dart';
import 'package:usdc_wallet/services/feature_subscriptions/feature_subscription_request.dart';
import 'package:usdc_wallet/services/feature_subscriptions/feature_subscription_response.dart';

class FeatureSubscriptionsService {
  FeatureSubscriptionsService(this._dio);

  final Dio _dio;

  Future<FeatureSubscriptionResponse> subscribe(
    FeatureSubscriptionRequest request,
  ) async {
    final response = await _dio.post(
      '/feature-subscriptions',
      data: request.toJson(),
    );

    return FeatureSubscriptionResponse.fromJson(
      _readSubscriptionPayload(response.data),
    );
  }
}

Map<String, dynamic> _readSubscriptionPayload(Object? raw) {
  if (raw is Map) {
    final map = Map<String, dynamic>.from(raw);
    final data = map['data'];
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    final subscription = map['subscription'];
    if (subscription is Map) {
      return Map<String, dynamic>.from(subscription);
    }
    return map;
  }
  return const {};
}
