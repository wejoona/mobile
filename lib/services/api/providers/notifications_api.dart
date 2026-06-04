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

  /// GET /notifications/:id
  Future<Response> getById(String id) => _dio.get('/notifications/$id');

  /// GET /user/notification-preferences
  Future<Response> getPreferences() =>
      _dio.get('/user/notification-preferences');

  /// PUT /user/notification-preferences
  Future<Response> updatePreferences(Map<String, dynamic> data) =>
      _dio.put('/user/notification-preferences', data: data);
}
