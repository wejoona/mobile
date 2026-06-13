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
      if (offset != null)
        'offset': offset
      else if (page != null && limit != null)
        'offset': (page - 1) * limit,
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

  /// POST /notifications/push/token
  Future<Response> registerPushToken(Map<String, dynamic> data) =>
      _dio.post('/notifications/push/token', data: data);

  /// DELETE /notifications/push/token
  Future<Response> removePushToken(Map<String, dynamic> data) =>
      _dio.delete('/notifications/push/token', data: data);

  /// DELETE /notifications/push/tokens
  Future<Response> removeAllPushTokens() =>
      _dio.delete('/notifications/push/tokens');
}
