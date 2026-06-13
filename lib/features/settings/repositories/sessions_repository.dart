import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/settings/models/session.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

/// Sessions Repository
class SessionsRepository {
  final Dio _dio;

  SessionsRepository(this._dio);

  /// Get all active sessions
  Future<List<Session>> getSessions() async {
    try {
      final response = await _dio.get('/sessions');
      final items = _extractSessionItems(response.data);
      return items.map(Session.fromJson).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Revoke a specific session
  Future<void> revokeSession(String sessionId) async {
    try {
      await _dio.delete(
        '/sessions/$sessionId',
        data: {'reason': 'user_revoked'},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Logout from all devices and invalidate refresh tokens.
  Future<void> logoutAllDevices() async {
    try {
      await _dio.delete(
        '/sessions',
        data: {'reason': 'user_logout_all_devices'},
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

Object? _unwrapSessionPayload(Object? raw) {
  if (raw is Map<String, dynamic>) {
    final data = raw['data'];
    if (data is Map<String, dynamic>) return data;
  } else if (raw is Map) {
    final map = Map<String, dynamic>.from(raw);
    final data = map['data'];
    if (data is Map) return Map<String, dynamic>.from(data);
  }
  return raw;
}

List<Map<String, dynamic>> _extractSessionItems(Object? raw) {
  final payload = _unwrapSessionPayload(raw);
  final List<Object?> items = switch (payload) {
    {'sessions': final List sessions} => sessions,
    {'items': final List items} => items,
    {'data': final List data} => data,
    final List list => list,
    _ => const <Object?>[],
  };

  return items.whereType<Map>().map(Map<String, dynamic>.from).toList();
}
