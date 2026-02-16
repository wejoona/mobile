import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/features/wallet/providers/balance_provider.dart';
import 'package:usdc_wallet/features/transactions/providers/transactions_provider.dart';
import 'package:usdc_wallet/features/notifications/providers/notifications_provider.dart';
import 'package:usdc_wallet/state/fsm/index.dart';

/// Real-time sync service — WebSocket primary, polling fallback.
///
/// Architecture:
/// - **WebSocket**: Server pushes events (balance_update, transaction_new, etc.)
/// - **Polling**: Fallback every 30s when WS is disconnected
/// - **Event-driven**: Call refreshAfterTransaction() after user actions
/// - **Pull-to-refresh**: Manual user trigger on screens
class RealtimeService {
  final Ref _ref;
  WebSocketChannel? _channel;
  Timer? _pollTimer;
  Timer? _reconnectTimer;
  bool _isConnected = false;
  bool _isPaused = false;
  int _reconnectAttempts = 0;
  static const _maxReconnectDelay = 30;
  static const _pollInterval = Duration(seconds: 30);

  RealtimeService(this._ref);

  bool get isConnected => _isConnected;

  /// Start the real-time connection (WebSocket + polling fallback)
  Future<void> start() async {
    _isPaused = false;
    await _connectWebSocket();
    _startPolling();
  }

  /// Stop everything
  void stop() {
    _isPaused = true;
    _disconnectWebSocket();
    _stopPolling();
  }

  /// Pause on app background
  void pause() {
    _isPaused = true;
    _disconnectWebSocket();
    _stopPolling();
  }

  /// Resume on app foreground
  Future<void> resume() async {
    _isPaused = false;
    await _connectWebSocket();
    _startPolling();
    // Immediate pull on resume
    pullAll();
  }

  /// Pull all data from server (used by polling + pull-to-refresh)
  void pullAll() {
    try {
      _ref.invalidate(walletBalanceProvider);
      _ref.invalidate(transactionsProvider);
      _ref.invalidate(notificationsProvider);
    } catch (_) {}
  }

  /// Refresh balance and transactions (after send/deposit/withdraw)
  void refreshAfterTransaction() {
    try {
      _ref.invalidate(walletBalanceProvider);
      _ref.invalidate(transactionsProvider);
    } catch (_) {}
  }

  // ── WebSocket ──

  Future<void> _connectWebSocket() async {
    if (_isPaused) return;
    _disconnectWebSocket();

    try {
      final storage = _ref.read(secureStorageProvider);
      final token = await storage.read(key: StorageKeys.accessToken);
      if (token == null) return;

      final baseUrl = ApiConfig.baseUrl;
      final wsUrl = baseUrl
          .replaceFirst('https://', 'wss://')
          .replaceFirst('http://', 'ws://');

      final uri = Uri.parse('$wsUrl/ws?token=$token');

      _channel = WebSocketChannel.connect(uri);

      await _channel!.ready.timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException('WS connect timeout'),
      );

      _isConnected = true;
      _reconnectAttempts = 0;

      _channel!.stream.listen(
        _onMessage,
        onError: (_) => _onDisconnect(),
        onDone: _onDisconnect,
        cancelOnError: false,
      );
    } catch (_) {
      _isConnected = false;
      _scheduleReconnect();
    }
  }

  void _disconnectWebSocket() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    try {
      _channel?.sink.close(ws_status.goingAway);
    } catch (_) {}
    _channel = null;
    _isConnected = false;
  }

  void _onMessage(dynamic data) {
    try {
      final event = jsonDecode(data as String) as Map<String, dynamic>;
      final type = event['type'] as String?;

      switch (type) {
        case 'balance_update':
          _ref.invalidate(walletBalanceProvider);
        case 'transaction_new':
          _ref.invalidate(walletBalanceProvider);
          _ref.invalidate(transactionsProvider);
        case 'notification_new':
          _ref.invalidate(notificationsProvider);
        case 'session_expired':
          try {
            _ref.read(appFsmProvider.notifier).logout();
          } catch (_) {}
      }
    } catch (_) {}
  }

  void _onDisconnect() {
    _isConnected = false;
    if (!_isPaused) _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    if (_isPaused) return;

    final delay = min(pow(2, _reconnectAttempts).toInt(), _maxReconnectDelay);
    _reconnectAttempts++;

    _reconnectTimer = Timer(Duration(seconds: delay), () {
      if (!_isPaused) _connectWebSocket();
    });
  }

  // ── Polling (fallback) ──

  void _startPolling() {
    _stopPolling();
    _pollTimer = Timer.periodic(_pollInterval, (_) {
      if (!_isConnected && !_isPaused) pullAll();
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  void dispose() {
    stop();
  }
}

final realtimeServiceProvider = Provider<RealtimeService>((ref) {
  final service = RealtimeService(ref);
  ref.onDispose(() => service.dispose());
  return service;
});
