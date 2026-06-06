import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/domain/entities/notification_preferences.dart';

/// Notification Preferences Service - mirrors backend NotificationPreferencesController
class NotificationPreferencesApiService {
  final Dio _dio;

  NotificationPreferencesApiService(this._dio);

  /// GET /notifications/preferences
  /// Fetches the current user's notification preferences from the backend
  Future<UserNotificationPreferences> getPreferences() async {
    try {
      final response = await _dio.get('/notifications/preferences');
      return UserNotificationPreferences.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// PUT /notifications/preferences
  /// Updates the current user's notification preferences
  Future<UserNotificationPreferences> updatePreferences(
    UserNotificationPreferences preferences,
  ) async {
    try {
      final response = await _dio.put(
        '/notifications/preferences',
        data: preferences.toUpdateJson(),
      );
      return UserNotificationPreferences.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Update a single preference field
  /// Convenience method for updating individual settings
  Future<UserNotificationPreferences> updateSinglePreference({
    bool? pushEnabled,
    bool? pushTransactions,
    bool? pushSecurity,
    bool? pushMarketing,
    bool? emailEnabled,
    bool? emailTransactions,
    bool? emailMonthlyStatement,
    bool? emailMarketing,
    bool? smsEnabled,
    bool? smsTransactions,
    bool? smsSecurity,
    double? largeTransactionThreshold,
    double? lowBalanceThreshold,
  }) async {
    try {
      final data = <String, dynamic>{};
      final channels = <String, dynamic>{};
      final categories = <String, dynamic>{};

      if (pushEnabled != null) channels['push'] = pushEnabled;
      if (pushTransactions != null) {
        categories['transaction'] = pushTransactions;
      }
      if (pushSecurity != null) categories['security'] = pushSecurity;
      if (pushMarketing != null) categories['marketing'] = pushMarketing;
      if (emailEnabled != null) channels['email'] = emailEnabled;
      if (emailTransactions != null) {
        categories['transaction'] = emailTransactions;
      }
      if (emailMonthlyStatement != null) {
        categories['system'] = emailMonthlyStatement;
      }
      if (emailMarketing != null) categories['marketing'] = emailMarketing;
      if (smsEnabled != null) channels['sms'] = smsEnabled;
      if (smsTransactions != null) {
        categories['transaction'] = smsTransactions;
      }
      if (smsSecurity != null) categories['security'] = smsSecurity;
      if (channels.isNotEmpty) data['channels'] = channels;
      if (categories.isNotEmpty) data['categories'] = categories;

      final response = await _dio.put('/notifications/preferences', data: data);
      return UserNotificationPreferences.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

/// Notification Preferences API Service Provider
final notificationPreferencesApiServiceProvider =
    Provider<NotificationPreferencesApiService>((ref) {
      return NotificationPreferencesApiService(ref.watch(dioProvider));
    });
