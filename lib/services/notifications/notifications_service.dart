import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/domain/entities/index.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

/// Notifications Service - mirrors backend NotificationsController
class NotificationsService {
  NotificationsService(this._dio);

  final Dio _dio;

  /// GET /notifications
  Future<List<AppNotification>> getNotifications({
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final response = await _dio.get(
        '/notifications',
        queryParameters: {'limit': pageSize, 'offset': (page - 1) * pageSize},
      );
      final data = _notificationItems(response.data);

      return data
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// GET /notifications/unread-count
  Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get('/notifications/unread-count');
      return _notificationCount(response.data);
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
  Future<void> registerDeviceToken(String token) async {
    try {
      await _dio.post(
        '/notifications/device-token',
        data: {'token': token, 'platform': 'ios'},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// POST /notifications/push/token - FCM/APNs token registration.
  Future<void> registerFcmToken({
    required String token,
    required String platform,
    String? deviceId,
    String? deviceName,
    String? appVersion,
    String? osVersion,
  }) async {
    try {
      await _dio.post(
        '/notifications/push/token',
        data: {
          'token': token,
          'platform': platform,
          if (deviceId != null && deviceId.isNotEmpty) 'deviceId': deviceId,
          if (deviceName != null && deviceName.isNotEmpty)
            'deviceName': deviceName,
          if (appVersion != null && appVersion.isNotEmpty)
            'appVersion': appVersion,
          if (osVersion != null && osVersion.isNotEmpty) 'osVersion': osVersion,
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// DELETE /notifications/push/token - Remove FCM/APNs token
  Future<void> removeFcmToken(String token) async {
    try {
      await _dio.delete('/notifications/push/token', data: {'token': token});
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// DELETE /notifications/push/tokens - Remove all FCM/APNs tokens for user
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
      await _dio.delete(
        '/notifications/device-token/${Uri.encodeComponent(token)}',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

/// Notifications Service Provider
final notificationsServiceProvider = Provider<NotificationsService>(
  (ref) => NotificationsService(ref.watch(dioProvider)),
);

List<dynamic> _notificationItems(Object? raw) {
  if (raw is List) {
    return raw;
  }
  if (raw is! Map) {
    return const [];
  }

  final map = Map<String, dynamic>.from(raw);
  final data = map['data'];
  if (data is List) {
    return data;
  }
  if (data is Map) {
    final dataMap = Map<String, dynamic>.from(data);
    return _listValue(dataMap, const ['notifications', 'items', 'data']);
  }

  return _listValue(map, const ['notifications', 'items', 'results']);
}

List<dynamic> _listValue(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is List) {
      return value;
    }
  }
  return const [];
}

int _notificationCount(Object? raw) {
  if (raw is num) {
    return raw.toInt();
  }
  if (raw is String) {
    return int.tryParse(raw) ?? 0;
  }
  if (raw is! Map) {
    return 0;
  }

  final map = Map<String, dynamic>.from(raw);
  final data = map['data'];
  if (data is Map) {
    final count = _intValue(Map<String, dynamic>.from(data), const [
      'count',
      'unreadCount',
      'unread_count',
      'total',
    ]);
    if (count != null) {
      return count;
    }
  }

  return _intValue(map, const [
        'count',
        'unreadCount',
        'unread_count',
        'total',
      ]) ??
      0;
}

int? _intValue(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }
  }
  return null;
}
