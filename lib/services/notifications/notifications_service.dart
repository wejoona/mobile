import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../api/api_client.dart';
import '../../domain/entities/index.dart';
import '../../domain/enums/index.dart';

/// Notifications Service - mirrors backend NotificationsController
class NotificationsService {
  final Dio _dio;

  NotificationsService(this._dio);

  /// GET /notifications
  Future<List<AppNotification>> getNotifications() async {
    try {
      final response = await _dio.get('/notifications');
      final responseData = response.data;

      // Handle different response formats
      List<dynamic> data;
      if (responseData is List) {
        data = responseData;
      } else if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('data')) {
          data = responseData['data'] as List<dynamic>? ?? [];
        } else if (responseData.containsKey('notifications')) {
          data = responseData['notifications'] as List<dynamic>? ?? [];
        } else {
          data = [];
        }
      } else {
        data = [];
      }

      return data
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      // Return empty list for 404 (endpoint not yet deployed)
      if (e.response?.statusCode == 404) {
        return [];
      }
      throw ApiException.fromDioError(e);
    }
  }

  /// GET /notifications/unread/count
  Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get('/notifications/unread/count');
      final countData = response.data as Map<String, dynamic>?;
      return countData?['count'] as int? ?? 0;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// PUT /notifications/:id/read
  Future<void> markAsRead(String id) async {
    try {
      await _dio.put('/notifications/$id/read');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// PUT /notifications/read-all
  Future<void> markAllAsRead() async {
    try {
      await _dio.put('/notifications/read-all');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// POST /notifications/device-token
  /// Legacy method - use PushNotificationService.registerWithBackend() instead
  Future<void> registerDeviceToken(String token) async {
    try {
      await _dio.post('/notifications/device-token', data: {
        'token': token,
      });
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// POST /notifications/push/token - Full FCM token registration
  Future<void> registerFcmToken({
    required String token,
    required String platform,
    String? deviceId,
    String? deviceName,
    String? appVersion,
    String? osVersion,
  }) async {
    try {
      await _dio.post('/notifications/push/token', data: {
        'token': token,
        'platform': platform,
        if (deviceId != null) 'deviceId': deviceId,
        if (deviceName != null) 'deviceName': deviceName,
        if (appVersion != null) 'appVersion': appVersion,
        if (osVersion != null) 'osVersion': osVersion,
      });
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// DELETE /notifications/push/token - Remove FCM token
  Future<void> removeFcmToken(String token) async {
    try {
      await _dio.delete('/notifications/push/token', data: {
        'token': token,
      });
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// DELETE /notifications/push/tokens - Remove all FCM tokens for user
  Future<void> removeAllFcmTokens() async {
    try {
      await _dio.delete('/notifications/push/tokens');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// DELETE /notifications/device-token/:token
  Future<void> removeDeviceToken(String token) async {
    try {
      await _dio.delete('/notifications/device-token/$token');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

/// Notifications Service Provider
final notificationsServiceProvider = Provider<NotificationsService>((ref) {
  return NotificationsService(ref.watch(dioProvider));
});

// ============================================
// NOTIFICATION PREFERENCES
// ============================================

/// Notification preference settings
class NotificationPreferences {
  final bool transactionAlerts;
  final bool securityAlerts;
  final bool promotions;
  final bool priceAlerts;
  final bool weeklySummary;
  final double largeTransactionThreshold; // USDC amount to trigger alert
  final double lowBalanceThreshold; // USDC amount to trigger low balance alert

  const NotificationPreferences({
    this.transactionAlerts = true,
    this.securityAlerts = true,
    this.promotions = true,
    this.priceAlerts = false,
    this.weeklySummary = true,
    this.largeTransactionThreshold = 1000,
    this.lowBalanceThreshold = 100,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      transactionAlerts: json['transactionAlerts'] as bool? ?? true,
      securityAlerts: json['securityAlerts'] as bool? ?? true,
      promotions: json['promotions'] as bool? ?? true,
      priceAlerts: json['priceAlerts'] as bool? ?? false,
      weeklySummary: json['weeklySummary'] as bool? ?? true,
      largeTransactionThreshold:
          (json['largeTransactionThreshold'] as num?)?.toDouble() ?? 1000,
      lowBalanceThreshold:
          (json['lowBalanceThreshold'] as num?)?.toDouble() ?? 100,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionAlerts': transactionAlerts,
      'securityAlerts': securityAlerts,
      'promotions': promotions,
      'priceAlerts': priceAlerts,
      'weeklySummary': weeklySummary,
      'largeTransactionThreshold': largeTransactionThreshold,
      'lowBalanceThreshold': lowBalanceThreshold,
    };
  }

  NotificationPreferences copyWith({
    bool? transactionAlerts,
    bool? securityAlerts,
    bool? promotions,
    bool? priceAlerts,
    bool? weeklySummary,
    double? largeTransactionThreshold,
    double? lowBalanceThreshold,
  }) {
    return NotificationPreferences(
      transactionAlerts: transactionAlerts ?? this.transactionAlerts,
      securityAlerts: securityAlerts ?? this.securityAlerts,
      promotions: promotions ?? this.promotions,
      priceAlerts: priceAlerts ?? this.priceAlerts,
      weeklySummary: weeklySummary ?? this.weeklySummary,
      largeTransactionThreshold:
          largeTransactionThreshold ?? this.largeTransactionThreshold,
      lowBalanceThreshold: lowBalanceThreshold ?? this.lowBalanceThreshold,
    );
  }

  /// Check if a notification type is enabled
  bool isEnabled(NotificationType type) {
    switch (type) {
      case NotificationType.transactionComplete:
      case NotificationType.transactionFailed:
      case NotificationType.withdrawalPending:
        return transactionAlerts;
      case NotificationType.securityAlert:
      case NotificationType.newDeviceLogin:
      case NotificationType.largeTransaction:
      case NotificationType.addressWhitelisted:
        return securityAlerts;
      case NotificationType.promotion:
        return promotions;
      case NotificationType.priceAlert:
        return priceAlerts;
      case NotificationType.weeklySpendingSummary:
        return weeklySummary;
      case NotificationType.lowBalance:
        return transactionAlerts;
      case NotificationType.general:
      default:
        return true;
    }
  }
}

/// Notification Preferences Service
class NotificationPreferencesService {
  final FlutterSecureStorage _storage;
  static const String _prefsKey = 'notification_preferences';

  NotificationPreferencesService(this._storage);

  /// Load saved preferences
  Future<NotificationPreferences> getPreferences() async {
    final data = await _storage.read(key: _prefsKey);
    if (data == null) {
      return const NotificationPreferences();
    }
    return NotificationPreferences.fromJson(
      jsonDecode(data) as Map<String, dynamic>,
    );
  }

  /// Save preferences
  Future<void> savePreferences(NotificationPreferences prefs) async {
    await _storage.write(
      key: _prefsKey,
      value: jsonEncode(prefs.toJson()),
    );
  }

  /// Update a single preference
  Future<NotificationPreferences> updatePreference({
    bool? transactionAlerts,
    bool? securityAlerts,
    bool? promotions,
    bool? priceAlerts,
    bool? weeklySummary,
    double? largeTransactionThreshold,
    double? lowBalanceThreshold,
  }) async {
    final current = await getPreferences();
    final updated = current.copyWith(
      transactionAlerts: transactionAlerts,
      securityAlerts: securityAlerts,
      promotions: promotions,
      priceAlerts: priceAlerts,
      weeklySummary: weeklySummary,
      largeTransactionThreshold: largeTransactionThreshold,
      lowBalanceThreshold: lowBalanceThreshold,
    );
    await savePreferences(updated);
    return updated;
  }
}

/// Notification Preferences Service Provider
final notificationPreferencesServiceProvider =
    Provider<NotificationPreferencesService>((ref) {
  return NotificationPreferencesService(ref.watch(secureStorageProvider));
});

/// Notification Preferences Provider
final notificationPreferencesProvider =
    FutureProvider<NotificationPreferences>((ref) async {
  final service = ref.watch(notificationPreferencesServiceProvider);
  return service.getPreferences();
});
