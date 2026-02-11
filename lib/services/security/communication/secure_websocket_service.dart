import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Connection state of the secure WebSocket.
enum WsConnectionState { disconnected, connecting, connected, error }

/// Secure WebSocket service for real-time updates.
///
/// Maintains an authenticated, encrypted WebSocket connection
/// for receiving real-time transaction notifications and security alerts.
class SecureWebSocketService {
  static const _tag = 'SecureWs';
  final AppLogger _log = AppLogger(_tag);

  WebSocket? _socket;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 10;

  final _stateController = StreamController<WsConnectionState>.broadcast();
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<WsConnectionState> get connectionState => _stateController.stream;
  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  /// Connect to the WebSocket server.
  Future<void> connect({
    required String url,
    required String authToken,
  }) async {
    _stateController.add(WsConnectionState.connecting);
    try {
      _socket = await WebSocket.connect(
        url,
        headers: {'Authorization': 'Bearer $authToken'},
      );

      _stateController.add(WsConnectionState.connected);
      _reconnectAttempts = 0;
      _startHeartbeat();

      _socket!.listen(
        (data) {
          try {
            final msg = jsonDecode(data as String) as Map<String, dynamic>;
            _messageController.add(msg);
          } catch (e) {
            _log.error('Failed to parse WS message', e);
          }
        },
        onDone: () {
          _stateController.add(WsConnectionState.disconnected);
          _scheduleReconnect(url, authToken);
        },
        onError: (e) {
          _log.error('WebSocket error', e);
          _stateController.add(WsConnectionState.error);
          _scheduleReconnect(url, authToken);
        },
      );
    } catch (e) {
      _log.error('WebSocket connection failed', e);
      _stateController.add(WsConnectionState.error);
      _scheduleReconnect(url, authToken);
    }
  }

  /// Send a message through the WebSocket.
  void send(Map<String, dynamic> message) {
    _socket?.add(jsonEncode(message));
  }

  /// Disconnect.
  Future<void> disconnect() async {
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    await _socket?.close();
    _socket = null;
    _stateController.add(WsConnectionState.disconnected);
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => send({'type': 'ping'}),
    );
  }

  void _scheduleReconnect(String url, String token) {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      _log.error('Max reconnect attempts reached');
      return;
    }
    _reconnectAttempts++;
    final delay = Duration(seconds: _reconnectAttempts * 2);
    _reconnectTimer = Timer(delay, () => connect(url: url, authToken: token));
  }

  void dispose() {
    disconnect();
    _stateController.close();
    _messageController.close();
  }
}

final secureWebSocketServiceProvider =
    Provider<SecureWebSocketService>((ref) {
  final service = SecureWebSocketService();
  ref.onDispose(service.dispose);
  return service;
});
