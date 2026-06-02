import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/feature_subscriptions/feature_subscriptions_service.dart';

final featureSubscriptionsServiceProvider =
    Provider<FeatureSubscriptionsService>((ref) {
      return FeatureSubscriptionsService(ref.watch(dioProvider));
    });
