import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/feature_subscriptions/feature_subscription_request.dart';
import 'package:usdc_wallet/services/feature_subscriptions/feature_subscription_response.dart';
import 'package:usdc_wallet/utils/app_info.dart';

export 'package:usdc_wallet/services/feature_subscriptions/feature_subscription_request.dart';
export 'package:usdc_wallet/services/feature_subscriptions/feature_subscription_response.dart';

typedef FeatureSubscription = FeatureSubscriptionResponse;

class FeatureSubscriptionService {
  FeatureSubscriptionService(this._dio);

  final Dio _dio;

  Future<FeatureSubscription> subscribe(
    FeatureSubscriptionRequest request,
  ) async {
    final enrichedRequest = await _withRuntimeContext(request);
    final response = await _dio.post(
      '/feature-subscriptions',
      data: enrichedRequest.toJson(),
    );
    return FeatureSubscriptionResponse.fromJson(
      _readSubscriptionPayload(response.data),
    );
  }

  Future<List<FeatureSubscriptionResponse>> listMine({
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
          (item) => FeatureSubscriptionResponse.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  Future<FeatureSubscriptionRequest> _withRuntimeContext(
    FeatureSubscriptionRequest request,
  ) async {
    final status = request.status ?? 'subscribed';
    final platform = request.platform ?? _mobilePlatform();
    final appVersion = request.appVersion ?? await _safeAppVersion();
    if (request.status == status && platform == null && appVersion == null) {
      return request;
    }
    return request.copyWith(
      status: status,
      platform: platform,
      appVersion: appVersion,
    );
  }

  String? _mobilePlatform() {
    if (Platform.isIOS) {
      return 'ios';
    }
    if (Platform.isAndroid) {
      return 'android';
    }
    return null;
  }

  Future<String?> _safeAppVersion() async {
    try {
      return await AppInfo.getVersion();
    } on Object {
      return null;
    }
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

final featureSubscriptionServiceProvider = Provider<FeatureSubscriptionService>(
  (ref) => FeatureSubscriptionService(ref.watch(dioProvider)),
);
