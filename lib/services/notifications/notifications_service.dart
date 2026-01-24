import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../../domain/entities/index.dart';

/// Notifications Service - mirrors backend NotificationsController
class NotificationsService {
  final Dio _dio;

  NotificationsService(this._dio);

  /// GET /notifications
  Future<List<AppNotification>> getNotifications() async {
    try {
      final response = await _dio.get('/notifications');
      final List<dynamic> data = response.data ?? [];
      return data
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// GET /notifications/unread/count
  Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get('/notifications/unread/count');
      return response.data['count'] as int? ?? 0;
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
      await _dio.post('/notifications/device-token', data: {
        'token': token,
      });
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
