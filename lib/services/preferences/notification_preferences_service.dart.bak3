import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../../domain/entities/notification_preferences.dart';

/// Notification Preferences Service - mirrors backend NotificationPreferencesController
class NotificationPreferencesApiService {
  final Dio _dio;

  NotificationPreferencesApiService(this._dio);

  /// GET /user/notification-preferences
  /// Fetches the current user's notification preferences from the backend
  Future<UserNotificationPreferences> getPreferences() async {
    try {
      final response = await _dio.get('/user/notification-preferences');
      return UserNotificationPreferences.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// PUT /user/notification-preferences
  /// Updates the current user's notification preferences
  Future<UserNotificationPreferences> updatePreferences(
    UserNotificationPreferences preferences,
  ) async {
    try {
      final response = await _dio.put(
        '/user/notification-preferences',
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

      if (pushEnabled != null) data['pushEnabled'] = pushEnabled;
      if (pushTransactions != null) data['pushTransactions'] = pushTransactions;
      if (pushSecurity != null) data['pushSecurity'] = pushSecurity;
      if (pushMarketing != null) data['pushMarketing'] = pushMarketing;
      if (emailEnabled != null) data['emailEnabled'] = emailEnabled;
      if (emailTransactions != null) {
        data['emailTransactions'] = emailTransactions;
      }
      if (emailMonthlyStatement != null) {
        data['emailMonthlyStatement'] = emailMonthlyStatement;
      }
      if (emailMarketing != null) data['emailMarketing'] = emailMarketing;
      if (smsEnabled != null) data['smsEnabled'] = smsEnabled;
      if (smsTransactions != null) data['smsTransactions'] = smsTransactions;
      if (smsSecurity != null) data['smsSecurity'] = smsSecurity;
      if (largeTransactionThreshold != null) {
        data['largeTransactionThreshold'] = largeTransactionThreshold;
      }
      if (lowBalanceThreshold != null) {
        data['lowBalanceThreshold'] = lowBalanceThreshold;
      }

      final response = await _dio.put(
        '/user/notification-preferences',
        data: data,
      );
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
