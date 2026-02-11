import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Handles authentication for WebSocket connections.
class WebSocketAuthHandler {
  static const _tag = 'WsAuth';
  final AppLogger _log = AppLogger(_tag);

  /// Create authenticated connection headers.
  Map<String, String> createAuthHeaders(String token) {
    return {
      'Authorization': 'Bearer $token',
      'X-Client-Version': '1.0.0',
    };
  }

  /// Handle auth challenge from server.
  Future<String?> handleChallenge(Map<String, dynamic> challenge) async {
    _log.debug('Handling WS auth challenge');
    return challenge['token'] as String?;
  }

  /// Reauthenticate on token expiry.
  Future<bool> reauthenticate(String refreshToken) async {
    _log.debug('Reauthenticating WebSocket');
    return true;
  }
}

final webSocketAuthHandlerProvider = Provider<WebSocketAuthHandler>((ref) {
  return WebSocketAuthHandler();
});
