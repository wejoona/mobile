import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api/api_client.dart';
import '../models/session.dart';

/// Sessions Repository
class SessionsRepository {
  final Dio _dio;

  SessionsRepository(this._dio);

  /// Get all active sessions
  Future<List<Session>> getSessions() async {
    final response = await _dio.get('/sessions');
    return (response.data['sessions'] as List)
        .map((json) => Session.fromJson(json))
        .toList();
  }

  /// Revoke a specific session
  Future<void> revokeSession(String sessionId) async {
    await _dio.delete('/sessions/$sessionId');
  }

  /// Logout from all devices (revoke all sessions)
  Future<void> logoutAllDevices() async {
    await _dio.delete('/sessions');
  }
}

/// Sessions Repository Provider
final sessionsRepositoryProvider = Provider<SessionsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return SessionsRepository(dio);
});
