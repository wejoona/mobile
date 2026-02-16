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
    final response = await _dio.get('/sessions');
    final raw = response.data;
    final List items;
    if (raw is Map<String, dynamic>) {
      items = (raw['sessions'] ?? raw['data'] ?? []) as List;
    } else if (raw is List) {
      items = raw;
    } else {
      items = [];
    }
    return items
        .map((json) => Session.fromJson(json as Map<String, dynamic>))
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
