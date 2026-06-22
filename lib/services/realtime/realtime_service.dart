import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:usdc_wallet/config/api_config.dart';
import 'package:usdc_wallet/features/notifications/providers/notifications_provider.dart';
import 'package:usdc_wallet/features/transactions/providers/transactions_provider.dart';
import 'package:usdc_wallet/features/wallet/providers/balance_provider.dart';
import 'package:usdc_wallet/features/wallet/providers/saved_recipients_provider.dart'
    as wallet_recipients;
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/state/fsm/index.dart';
import 'package:usdc_wallet/state/kyc_state_machine.dart';
import 'package:usdc_wallet/state/transaction_state_machine.dart';
import 'package:usdc_wallet/state/wallet_state_machine.dart';

/// Real-time sync service — Socket.IO primary, polling fallback.
///
/// Architecture:
/// - **Socket.IO**: Server pushes events (balance.updated, transaction.created, etc.)
/// - **Polling**: Fallback every 30s when the socket is disconnected
/// - **Event-driven**: Call refreshAfterTransaction() after user actions
/// - **Pull-to-refresh**: Manual user trigger on screens
class RealtimeService {
  RealtimeService(this._ref);

  final Ref _ref;
  io.Socket? _socket;
  Timer? _pollTimer;
  Timer? _reconnectTimer;
  bool _isConnected = false;
  bool _isPaused = false;
  int _reconnectAttempts = 0;
  static const _maxReconnectDelay = 30;
  static const _pollInterval = Duration(seconds: 30);

  bool get isConnected => _isConnected;

  /// Start the real-time connection (Socket.IO + polling fallback)
  Future<void> start() async {
    _isPaused = false;
    await _connectRealtimeSocket();
    _startPolling();
  }

  /// Stop everything
  void stop() {
    _isPaused = true;
    _disconnectSocket();
    _stopPolling();
  }

  /// Pause on app background
  void pause() {
    _isPaused = true;
    _disconnectSocket();
    _stopPolling();
  }

  /// Resume on app foreground
  Future<void> resume() async {
    _isPaused = false;
    await _connectRealtimeSocket();
    _startPolling();
    // Immediate pull on resume
    pullAll();
  }

  /// Pull all data from server (used by polling + pull-to-refresh)
  void pullAll() {
    try {
      _ref
        ..invalidate(walletBalanceProvider)
        ..invalidate(transactionsProvider)
        ..invalidate(notificationsProvider)
        ..invalidate(unreadNotificationCountProvider);
      _invalidateRecipientProviders();
      unawaited(_ref.read(walletStateMachineProvider.notifier).refresh());
      unawaited(_ref.read(transactionStateMachineProvider.notifier).refresh());
    } on Object catch (_) {}
  }

  /// Refresh balance and transactions (after send/deposit/withdraw)
  void refreshAfterTransaction() {
    try {
      _ref
        ..invalidate(walletBalanceProvider)
        ..invalidate(transactionsProvider);
      _invalidateRecipientProviders();
      unawaited(_ref.read(walletStateMachineProvider.notifier).refresh());
      unawaited(_ref.read(transactionStateMachineProvider.notifier).refresh());
    } on Object catch (_) {}
  }

  // ── Socket.IO ──

  Future<void> _connectRealtimeSocket() async {
    if (_isPaused) {
      return;
    }
    _disconnectSocket();

    try {
      final storage = _ref.read(secureStorageProvider);
      final token = await storage.read(key: StorageKeys.accessToken);
      if (token == null) {
        return;
      }

      final completer = Completer<void>();
      final socket = io.io(
        ApiConfiguration.wsUrl,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setAuth({'token': token})
            .setQuery({'deviceType': 'mobile'})
            .build(),
      );

      _socket = socket;
      _registerSocketHandlers(socket, completer);
      socket.connect();

      await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException('Socket.IO connect timeout'),
      );
    } on Object catch (_) {
      _disconnectSocket();
      _isConnected = false;
      _scheduleReconnect();
    }
  }

  void _registerSocketHandlers(io.Socket socket, Completer<void> completer) {
    socket
      ..onConnect((_) {
        _isConnected = true;
        _reconnectAttempts = 0;
        if (!completer.isCompleted) {
          completer.complete();
        }
        socket.emit('subscribe', {
          'channels': ['balance', 'transactions', 'notifications', 'kyc'],
        });
      })
      ..onDisconnect((_) => _onDisconnect())
      ..onConnectError((error) {
        if (!completer.isCompleted) {
          completer.completeError(error ?? 'Socket.IO connect error');
        }
        _onDisconnect();
      })
      ..onError((error) {
        if (!completer.isCompleted) {
          completer.completeError(error ?? 'Socket.IO error');
        }
        _onDisconnect();
      })
      ..on('connected', (_) {})
      ..on(
        'balance.updated',
        (data) => _onRealtimeEvent('balance.updated', data),
      )
      ..on('balance_update', (data) => _onRealtimeEvent('balance_update', data))
      ..on(
        'transaction.created',
        (data) => _onRealtimeEvent('transaction.created', data),
      )
      ..on(
        'transaction.completed',
        (data) => _onRealtimeEvent('transaction.completed', data),
      )
      ..on(
        'transaction.failed',
        (data) => _onRealtimeEvent('transaction.failed', data),
      )
      ..on(
        'transaction_new',
        (data) => _onRealtimeEvent('transaction_new', data),
      )
      ..on(
        'deposit.completed',
        (data) => _onRealtimeEvent('deposit.completed', data),
      )
      ..on(
        'withdrawal.completed',
        (data) => _onRealtimeEvent('withdrawal.completed', data),
      )
      ..on(
        'transfer.received',
        (data) => _onRealtimeEvent('transfer.received', data),
      )
      ..on('transfer.sent', (data) => _onRealtimeEvent('transfer.sent', data))
      ..on(
        'kyc.status_updated',
        (data) => _onRealtimeEvent('kyc.status_updated', data),
      )
      ..on(
        'notification.new',
        (data) => _onRealtimeEvent('notification.new', data),
      )
      ..on(
        'notification_new',
        (data) => _onRealtimeEvent('notification_new', data),
      )
      ..on(
        'session.expired',
        (data) => _onRealtimeEvent('session.expired', data),
      )
      ..on(
        'session_expired',
        (data) => _onRealtimeEvent('session_expired', data),
      )
      ..on(
        'force_disconnect',
        (data) => _onRealtimeEvent('force_disconnect', data),
      )
      ..on(
        'account.suspended',
        (data) => _onRealtimeEvent('account.suspended', data),
      )
      ..on(
        'account.unsuspended',
        (data) => _onRealtimeEvent('account.unsuspended', data),
      )
      ..on(
        'security.alert',
        (data) => _onRealtimeEvent('security.alert', data),
      );
  }

  void _disconnectSocket() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    try {
      _socket?.disconnect();
      _socket?.dispose();
    } on Object catch (_) {}
    _socket = null;
    _isConnected = false;
  }

  void _onRealtimeEvent(String eventType, Object? data) {
    final payload = _payloadMap(data);
    final type = (payload['type'] as String?) ?? eventType;

    switch (type) {
      case 'balance.updated':
      case 'balance_update':
        _refreshBalanceOnly();
        break;
      case 'transaction.created':
      case 'transaction.completed':
      case 'transaction.failed':
      case 'transaction_new':
      case 'deposit.completed':
      case 'withdrawal.completed':
      case 'transfer.received':
      case 'transfer.sent':
        _refreshTransactionSurfaces();
        break;
      case 'notification.new':
      case 'notification_new':
      case 'security.alert':
      case 'account.suspended':
      case 'account.unsuspended':
        _refreshNotificationSurfaces();
        break;
      case 'kyc.status_updated':
        _refreshKycState();
        break;
      case 'session.expired':
      case 'session_expired':
      case 'force_disconnect':
        _logoutFromRealtime();
        break;
    }
  }

  Map<String, dynamic> _payloadMap(Object? data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return data.map((key, value) => MapEntry(key.toString(), value));
    }
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        if (decoded is Map) {
          return decoded.map((key, value) => MapEntry(key.toString(), value));
        }
      } on Object catch (_) {}
    }
    return const {};
  }

  void _refreshBalanceOnly() {
    _ref.invalidate(walletBalanceProvider);
    unawaited(_ref.read(walletStateMachineProvider.notifier).refresh());
  }

  void _refreshTransactionSurfaces() {
    _ref
      ..invalidate(walletBalanceProvider)
      ..invalidate(transactionsProvider);
    _invalidateRecipientProviders();
    unawaited(_ref.read(walletStateMachineProvider.notifier).refresh());
    unawaited(_ref.read(transactionStateMachineProvider.notifier).refresh());
  }

  void _refreshNotificationSurfaces() {
    _ref
      ..invalidate(notificationsProvider)
      ..invalidate(unreadNotificationCountProvider);
  }

  void _refreshKycState() {
    unawaited(_ref.read(kycStateMachineProvider.notifier).fetch());
    _refreshNotificationSurfaces();
  }

  void _logoutFromRealtime() {
    try {
      _ref.read(appFsmProvider.notifier).logout();
    } on Object catch (_) {}
  }

  void _onDisconnect() {
    _isConnected = false;
    if (!_isPaused) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    if (_isPaused) {
      return;
    }

    final delay = min(pow(2, _reconnectAttempts).toInt(), _maxReconnectDelay);
    _reconnectAttempts++;

    _reconnectTimer = Timer(Duration(seconds: delay), () {
      if (!_isPaused) {
        unawaited(_connectRealtimeSocket());
      }
    });
  }

  // ── Polling (fallback) ──

  void _startPolling() {
    _stopPolling();
    _pollTimer = Timer.periodic(_pollInterval, (_) {
      if (!_isConnected && !_isPaused) {
        pullAll();
      }
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  void _invalidateRecipientProviders() {
    _ref
      ..invalidate(wallet_recipients.savedRecipientsProvider)
      ..invalidate(wallet_recipients.favoriteRecipientsProvider)
      ..invalidate(wallet_recipients.recentRecipientsProvider);
  }

  void dispose() {
    stop();
  }
}

final realtimeServiceProvider = Provider<RealtimeService>((ref) {
  final service = RealtimeService(ref);
  ref.onDispose(service.dispose);
  return service;
});
