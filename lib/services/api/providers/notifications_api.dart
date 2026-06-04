/// Notifications API — list, preferences
library;

import 'package:dio/dio.dart';

class NotificationsApi {
  NotificationsApi(this._dio);
  final Dio _dio;

  /// GET /notifications
  Future<Response> list({int? page, int? limit}) => _dio.get(
    '/notifications',
    queryParameters: {
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
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
      _dio.delete('/notifications/device-token/$token');
}
