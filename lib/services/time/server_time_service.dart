import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Service to sync local clock with server time.
/// Used to prevent clock-skew issues with token expiry, OTP timing, etc.
class ServerTimeService {
  final Dio _api;
  final _logger = AppLogger('ServerTime');

  /// Offset in milliseconds: serverTime - localTime
  /// Positive = server is ahead, negative = server is behind
  int _offsetMs = 0;
  DateTime? _lastSyncAt;

  ServerTimeService(this._api);

  /// Current server-adjusted time
  DateTime get now => DateTime.now().add(Duration(milliseconds: _offsetMs));

  /// Millisecond offset from server
  int get offsetMs => _offsetMs;

  /// Whether we've successfully synced at least once
  bool get hasSynced => _lastSyncAt != null;

  /// Sync with server. Call on app start and periodically.
  Future<void> sync() async {
    try {
      final localBefore = DateTime.now().millisecondsSinceEpoch;

      final response = await _api.get('/health/time');
      if (response.statusCode != 200) return;

      final localAfter = DateTime.now().millisecondsSinceEpoch;
      final roundTripMs = localAfter - localBefore;
      final localMidpoint = localBefore + (roundTripMs ~/ 2);

      final serverTimestamp = response.data['timestamp'] as int;
      _offsetMs = serverTimestamp - localMidpoint;
      _lastSyncAt = DateTime.now();

      if (_offsetMs.abs() > 5000) {
        _logger.warn('Clock skew detected: ${_offsetMs}ms (server ${_offsetMs > 0 ? "ahead" : "behind"})');
      } else {
        _logger.debug('Time synced, offset: ${_offsetMs}ms, RTT: ${roundTripMs}ms');
      }
    } catch (e) {
      _logger.debug('Time sync failed (non-critical): $e');
    }
  }
}

final serverTimeServiceProvider = Provider<ServerTimeService>((ref) {
  final api = ref.watch(dioProvider);
  return ServerTimeService(api);
});
