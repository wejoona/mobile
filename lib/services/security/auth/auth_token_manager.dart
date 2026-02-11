import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Manages secure storage and rotation of authentication tokens.
class AuthTokenManager {
  static const _tag = 'AuthTokenManager';
  final AppLogger _log = AppLogger(_tag);

  String? _accessToken;
  String? _refreshToken;
  DateTime? _accessTokenExpiry;
  Timer? _refreshTimer;
  final _onTokenRefreshed = StreamController<String>.broadcast();

  Stream<String> get onTokenRefreshed => _onTokenRefreshed.stream;

  /// Set tokens after login or refresh.
  void setTokens({
    required String accessToken,
    required String refreshToken,
    required Duration accessTokenTtl,
  }) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _accessTokenExpiry = DateTime.now().add(accessTokenTtl);
    _scheduleRefresh(accessTokenTtl);
    _log.debug('Tokens set, expires in ${accessTokenTtl.inMinutes}m');
  }

  String? get accessToken => _accessToken;
  bool get isAuthenticated => _accessToken != null;

  bool get isAccessTokenExpired {
    if (_accessTokenExpiry == null) return true;
    return DateTime.now().isAfter(_accessTokenExpiry!);
  }

  /// Clear tokens on logout.
  void clear() {
    _accessToken = null;
    _refreshToken = null;
    _accessTokenExpiry = null;
    _refreshTimer?.cancel();
    _log.debug('Tokens cleared');
  }

  void _scheduleRefresh(Duration ttl) {
    _refreshTimer?.cancel();
    // Refresh at 80% of TTL
    final refreshDelay = Duration(milliseconds: (ttl.inMilliseconds * 0.8).toInt());
    _refreshTimer = Timer(refreshDelay, _performRefresh);
  }

  Future<void> _performRefresh() async {
    if (_refreshToken == null) return;
    // Would call auth API to refresh
    _log.debug('Token refresh triggered');
  }

  void dispose() {
    _refreshTimer?.cancel();
    _onTokenRefreshed.close();
  }
}

final authTokenManagerProvider = Provider<AuthTokenManager>((ref) {
  final manager = AuthTokenManager();
  ref.onDispose(manager.dispose);
  return manager;
});
