import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/features/settings/models/session.dart';

/// Sessions Repository
class SessionsRepository {
  final Dio _dio;

  SessionsRepository(this._dio);

  /// Get all active sessions
  Future<List<Session>> getSessions() async {
    try {
      final response = await _dio.get('/sessions');
      final raw = response.data;
      final List items;
      if (raw is Map) {
        items = (raw['sessions'] ?? raw['items'] ?? raw['data'] ?? []) as List;
      } else if (raw is List) {
        items = raw;
      } else {
        items = [];
      }
      return items
          .map((json) => Session.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Revoke a specific session
  Future<void> revokeSession(String sessionId) async {
    try {
      await _dio.delete(
        '/sessions/$sessionId',
        data: const {'reason': 'user_revoke_device'},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Logout from all devices (revoke all sessions)
  Future<void> logoutAllDevices() async {
    try {
      await _dio.delete(
        '/sessions',
        data: const {'reason': 'user_logout_all_devices'},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

/// Sessions Repository Provider
final sessionsRepositoryProvider = Provider<SessionsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return SessionsRepository(dio);
});
