/// Notifications API — list, preferences
library;

import 'package:dio/dio.dart';

class NotificationsApi {
  NotificationsApi(this._dio);
  final Dio _dio;

  /// GET /notifications
  Future<Response> list({int? page, int? limit, int? offset}) => _dio.get(
    '/notifications',
    queryParameters: {
      if (limit != null) 'limit': limit,
      if (_resolvedOffset(page: page, limit: limit, offset: offset) != null)
        'offset': _resolvedOffset(page: page, limit: limit, offset: offset),
    },
  );

  /// GET /notifications/unread-count
  Future<Response> unreadCount() => _dio.get('/notifications/unread-count');

  /// GET /notifications/preferences
  Future<Response> getPreferences() => _dio.get('/notifications/preferences');

  /// PUT /notifications/preferences
  Future<Response> updatePreferences(Map<String, dynamic> data) =>
      _dio.put('/notifications/preferences', data: data);

  /// POST /notifications/device-token
  Future<Response> registerDeviceToken(Map<String, dynamic> data) =>
      _dio.post('/notifications/device-token', data: data);

  /// DELETE /notifications/device-token/:token
  Future<Response> unregisterDeviceToken(String token) =>
      _dio.delete('/notifications/device-token/${Uri.encodeComponent(token)}');

  /// Legacy facade for FCM/APNs token registration.
  Future<Response> registerPushToken(Map<String, dynamic> data) =>
      registerDeviceToken({
        'token': data['token'],
        'platform': _notificationPlatform(data['platform']),
      });

  /// Legacy facade for FCM/APNs token removal.
  Future<Response> removePushToken(Map<String, dynamic> data) {
    final token = data['token'];
    if (token is! String || token.isEmpty) {
      throw ArgumentError.value(data, 'data', 'token is required');
    }
    return unregisterDeviceToken(token);
  }

  /// Bulk token removal is intentionally unsupported by the live API.
  Future<Response> removeAllPushTokens() {
    throw UnsupportedError(
      'Bulk push-token removal is not supported by the Korido API. '
      'Remove the active device token individually.',
    );
  }
}

int? _resolvedOffset({int? page, int? limit, int? offset}) {
  if (offset != null) {
    return offset < 0 ? 0 : offset;
  }
  if (page != null && limit != null && limit > 0) {
    final safePage = page < 1 ? 1 : page;
    return (safePage - 1) * limit;
  }
  return null;
}

String _notificationPlatform(Object? platform) {
  final normalized = platform?.toString().trim().toLowerCase();
  if (normalized == 'ios' || normalized == 'android' || normalized == 'web') {
    return normalized!;
  }
  return 'ios';
}
