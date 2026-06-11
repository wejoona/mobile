import 'package:dio/dio.dart';
import 'package:usdc_wallet/services/feature_subscriptions/feature_subscription_service.dart';

class FeatureSubscriptionsService {
  FeatureSubscriptionsService(Dio dio) : _service = FeatureSubscriptionService(dio);

  final FeatureSubscriptionService _service;

  Future<FeatureSubscriptionResponse> subscribe(
    FeatureSubscriptionRequest request,
  ) => _service.subscribe(request);
}
