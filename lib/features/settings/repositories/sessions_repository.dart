import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/domain/entities/device.dart';
import 'package:usdc_wallet/features/settings/models/session.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

/// Sessions Repository
class SessionsRepository {
  final Dio _dio;

  SessionsRepository(this._dio);

  /// Get all active sessions
  Future<List<Session>> getSessions() async {
    try {
      final response = await _dio.get('/devices');
      final raw = _unwrapSessionPayload(response.data);
      final List items;
      if (raw is Map) {
        items = (raw['devices'] ?? raw['items'] ?? raw['data'] ?? []) as List;
      } else if (raw is List) {
        items = raw;
      } else {
        items = [];
      }
      return items
          .map(
            (json) => _sessionFromDevice(
              Device.fromJson(Map<String, dynamic>.from(json)),
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Revoke a specific session
  Future<void> revokeSession(String sessionId) async {
    try {
      await _dio.delete('/devices/$sessionId');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Logout from all devices (revoke all sessions)
  Future<void> logoutAllDevices() async {
    try {
      await _dio.delete('/devices');
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

Session _sessionFromDevice(Device device) {
  final lastSeen = device.lastActiveAt;
  final userAgent = [
    device.deviceModel,
    device.osDisplay == 'Unknown OS' ? null : device.osDisplay,
    device.platform,
  ].whereType<String>().where((value) => value.trim().isNotEmpty).join(' ');

  return Session(
    id: device.id,
    deviceId: device.id,
    ipAddress: device.lastIpAddress,
    userAgent: userAgent.isEmpty ? device.displayLabel : userAgent,
    isActive: device.isActive,
    lastActivityAt: lastSeen,
    expiresAt: lastSeen.add(const Duration(days: 30)),
  );
}
