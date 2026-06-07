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
      Map<String, dynamic>.from(response.data as Map),
    );
  }
}
