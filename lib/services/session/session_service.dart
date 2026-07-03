import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:usdc_wallet/config/api_config.dart';
import 'package:usdc_wallet/utils/logger.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/features/settings/providers/security_settings_provider.dart';
import 'package:usdc_wallet/domain/entities/user.dart';
import 'package:usdc_wallet/services/security/security_headers_interceptor.dart';
import 'package:usdc_wallet/services/storage/secure_storage_provider.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

/// Session configuration
class SessionConfig {
  /// Inactivity timeout before showing warning (default: 30 minutes)
  /// This only locks the screen — does NOT log out.
  final Duration inactivityTimeout;

  /// Warning before lock (default: 60 seconds)
  final Duration warningDuration;

  /// Token refresh threshold (refresh when less than this time remaining)
  final Duration tokenRefreshThreshold;

  /// Background timeout — lock after this duration in background (default: 5 minutes)
  /// Short backgrounds (camera, image picker) are handled by grace period.
  final Duration backgroundTimeout;

  const SessionConfig({
    this.inactivityTimeout = const Duration(minutes: 30),
    this.warningDuration = const Duration(seconds: 60),
    this.tokenRefreshThreshold = const Duration(minutes: 5),
    this.backgroundTimeout = const Duration(minutes: 5),
  });
}

/// Session state
enum SessionStatus {
  /// No active session
  inactive,

  /// Session is active
  active,

  /// Session is about to expire (warning shown)
  expiring,

  /// Session has expired
  expired,

  /// Session is locked (requires PIN/biometric)
  locked,
}

enum SessionRefreshStatus { success, rejected, unavailable }

class SessionRefreshResult {
  final SessionRefreshStatus status;
  final User? user;
  final String? kycStatus;

  const SessionRefreshResult(this.status, {this.user, this.kycStatus});

  bool get success => status == SessionRefreshStatus.success;
  bool get rejected => status == SessionRefreshStatus.rejected;
}

class SessionState {
  final SessionStatus status;
  final DateTime? lastActivity;
  final DateTime? sessionStarted;
  final DateTime? tokenExpiresAt;
  final int? remainingSeconds;
  final bool isInBackground;

  const SessionState({
    this.status = SessionStatus.inactive,
    this.lastActivity,
    this.sessionStarted,
    this.tokenExpiresAt,
    this.remainingSeconds,
    this.isInBackground = false,
  });

  bool get isActive => status == SessionStatus.active;
  bool get isExpiring => status == SessionStatus.expiring;
  bool get isExpired => status == SessionStatus.expired;
  bool get isLocked => status == SessionStatus.locked;

  SessionState copyWith({
    SessionStatus? status,
    DateTime? lastActivity,
    DateTime? sessionStarted,
    DateTime? tokenExpiresAt,
    int? remainingSeconds,
    bool? isInBackground,
  }) {
    return SessionState(
      status: status ?? this.status,
      lastActivity: lastActivity ?? this.lastActivity,
      sessionStarted: sessionStarted ?? this.sessionStarted,
      tokenExpiresAt: tokenExpiresAt ?? this.tokenExpiresAt,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isInBackground: isInBackground ?? this.isInBackground,
    );
  }
}

/// Session service that manages user session lifecycle
class SessionService extends Notifier<SessionState> {
  static const _accessTokenKey = StorageKeys.accessToken;
  static const _refreshTokenKey = StorageKeys.refreshToken;
  static const _tokenExpiryKey = 'token_expiry';
  static const _sessionStartKey = 'session_start';

  final SessionConfig _config;

  Timer? _inactivityTimer;
  Timer? _warningTimer;
  Timer? _countdownTimer;
  Timer? _tokenRefreshTimer;
  DateTime? _backgroundEnteredAt;
  Future<SessionRefreshResult>? _refreshInFlight;
  int _sessionGeneration = 0;

  SessionService({SessionConfig? config})
    : _config = config ?? const SessionConfig();

  FlutterSecureStorage get _storage => ref.read(secureStorageProvider);

  bool get _canApplyStartupRestore => state.status == SessionStatus.inactive;

  @override
  SessionState build() {
    final storage = ref.read(secureStorageProvider);
    ref.onDispose(_cancelAllTimers);

    // Check for existing session on startup
    unawaited(_checkExistingSession(storage));
    return const SessionState();
  }

  /// Start a new session after successful login
  Future<void> startSession({
    required String accessToken,
    String? refreshToken,
    Duration? tokenValidity,
  }) async {
    _sessionGeneration++;
    _refreshInFlight = null;
    final now = DateTime.now();
    final expiresAt = tokenValidity != null ? now.add(tokenValidity) : null;

    // Store tokens securely
    await _storage.write(key: _accessTokenKey, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    }
    if (expiresAt != null) {
      await _storage.write(
        key: _tokenExpiryKey,
        value: expiresAt.toIso8601String(),
      );
    }
    await _storage.write(key: _sessionStartKey, value: now.toIso8601String());

    state = SessionState(
      status: SessionStatus.active,
      lastActivity: now,
      sessionStarted: now,
      tokenExpiresAt: expiresAt,
    );

    _startInactivityTimer();
    _startTokenRefreshTimer();
  }

  /// Record user activity to reset inactivity timer
  void recordActivity() {
    if (state.status == SessionStatus.inactive ||
        state.status == SessionStatus.locked ||
        state.status == SessionStatus.expired) {
      return;
    }

    final now = DateTime.now();

    // If session was expiring, reset to active
    if (state.status == SessionStatus.expiring) {
      _cancelWarningTimer();
      state = state.copyWith(
        status: SessionStatus.active,
        lastActivity: now,
        remainingSeconds: null,
      );
    } else {
      state = state.copyWith(lastActivity: now);
    }

    _startInactivityTimer();
  }

  /// Lock the session (requires PIN/biometric to unlock)
  void lockSession() {
    _cancelAllTimers();
    state = state.copyWith(status: SessionStatus.locked);
    // Sync with AuthProvider so router shows lock screen
    try {
      unawaited(ref.read(authProvider.notifier).setLocked());
    } catch (_) {}
    try {
      ref.read(appFsmProvider.notifier).lockSession(reason: 'Session locked');
    } catch (_) {}
  }

  /// Unlock the session after successful PIN/biometric
  void unlockSession() {
    _cancelWarningTimer();
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _warningTimer?.cancel();
    _warningTimer = null;
    _backgroundLockTimer?.cancel();
    _backgroundLockTimer = null;
    _backgroundEnteredAt = null;
    state = state.copyWith(
      status: SessionStatus.active,
      lastActivity: DateTime.now(),
      remainingSeconds: null,
      isInBackground: false,
    );
    _startInactivityTimer();
  }

  /// End the session (logout)
  Future<void> endSession() async {
    _sessionGeneration++;
    _refreshInFlight = null;
    _cancelAllTimers();

    // Clear stored tokens
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _tokenExpiryKey);
    await _storage.delete(key: _sessionStartKey);

    state = const SessionState(status: SessionStatus.inactive);
  }

  /// Extend the session (user chose to stay logged in)
  void extendSession() {
    recordActivity();
  }

  /// App entered background
  Timer? _backgroundLockTimer;

  void onAppBackground() {
    _backgroundEnteredAt = DateTime.now();
    state = state.copyWith(isInBackground: true);

    // Don't lock immediately — give a grace period for camera, image picker,
    // biometric prompts, etc. which briefly send the app to background.
    _backgroundLockTimer?.cancel();
    final settings = ref.read(securitySettingsProvider);
    if (!settings.isLoaded) {
      return;
    }
    if (!settings.pinOnAppOpen) {
      return;
    }

    final lockDelay = Duration(minutes: settings.autoLockMinutes);
    final effectiveDelay = lockDelay < const Duration(seconds: 60)
        ? const Duration(seconds: 60)
        : lockDelay;

    _backgroundLockTimer = Timer(effectiveDelay, () {
      if (state.isInBackground && state.status == SessionStatus.active) {
        lockSession();
      }
    });
  }

  /// App returned to foreground
  void onAppForeground() {
    _backgroundLockTimer?.cancel();
    _backgroundLockTimer = null;
    final wasInBackground = _backgroundEnteredAt;
    _backgroundEnteredAt = null;
    state = state.copyWith(isInBackground: false);

    if (wasInBackground != null && state.status != SessionStatus.inactive) {
      final backgroundDuration = DateTime.now().difference(wasInBackground);
      final settings = ref.read(securitySettingsProvider);

      if (settings.isLoaded &&
          settings.pinOnAppOpen &&
          backgroundDuration >= Duration(minutes: settings.autoLockMinutes)) {
        // Been in background too long (>5 min), lock session (NOT expire/logout)
        lockSession();
      } else {
        // Brief background (<5 min), just record activity and continue
        recordActivity();
      }
    }
  }

  /// Get the stored access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// Get the stored refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Check if tokens are stored (for auto-login)
  Future<bool> hasStoredSession() async {
    final token = await _storage.read(key: _accessTokenKey);
    return token != null;
  }

  Future<SessionRefreshResult> refreshStoredSession() async {
    final existing = _refreshInFlight;
    if (existing != null) {
      return existing;
    }

    final future = _performRefreshToken();
    _refreshInFlight = future;
    try {
      return await future;
    } finally {
      if (identical(_refreshInFlight, future)) {
        _refreshInFlight = null;
      }
    }
  }

  // Private methods

  Future<void> _checkExistingSession(FlutterSecureStorage storage) async {
    final token = await storage.read(key: _accessTokenKey);
    final expiryStr = await storage.read(key: _tokenExpiryKey);
    final sessionStartStr = await storage.read(key: _sessionStartKey);
    if (!ref.mounted) {
      return;
    }
    if (!_canApplyStartupRestore) {
      return;
    }

    if (token != null) {
      DateTime? expiresAt;
      DateTime? sessionStarted;

      if (expiryStr != null) {
        expiresAt = DateTime.tryParse(expiryStr);
        // Check if token is expired - try to refresh before giving up
        if (expiresAt != null && DateTime.now().isAfter(expiresAt)) {
          final refreshToken = await storage.read(key: _refreshTokenKey);
          if (!ref.mounted) {
            return;
          }
          if (refreshToken != null) {
            // Attempt to refresh the token
            final refreshed = await refreshStoredSession();
            if (!ref.mounted) {
              return;
            }
            if (refreshed.rejected) {
              if (!_canApplyStartupRestore) {
                return;
              }
              await _invalidateLocalSession();
              return;
            }
            if (!refreshed.success) {
              expiresAt = DateTime.now().add(_config.tokenRefreshThreshold);
            }
            // Re-read to check if refresh succeeded
            final newToken = await storage.read(key: _accessTokenKey);
            if (!ref.mounted) {
              return;
            }
            if (refreshed.success && (newToken == null || newToken == token)) {
              if (!_canApplyStartupRestore) {
                return;
              }
              // Refresh failed, end session
              await _invalidateLocalSession();
              return;
            }
            // Refresh succeeded, update expiry
            final newExpiryStr = await storage.read(key: _tokenExpiryKey);
            if (!ref.mounted) {
              return;
            }
            if (newExpiryStr != null) {
              expiresAt = DateTime.tryParse(newExpiryStr);
            }
          } else {
            if (!_canApplyStartupRestore) {
              return;
            }
            // No refresh token, end session
            await endSession();
            return;
          }
        }
      }

      if (sessionStartStr != null) {
        sessionStarted = DateTime.tryParse(sessionStartStr);
      }

      if (!_canApplyStartupRestore) {
        return;
      }
      // Restore session - start as locked (user must enter PIN first)
      state = SessionState(
        status: SessionStatus.locked,
        sessionStarted: sessionStarted,
        tokenExpiresAt: expiresAt,
        lastActivity: DateTime.now(),
      );

      // Only start token refresh timer, NOT inactivity timer
      // Inactivity timer starts when session is unlocked via PIN/biometric
      _startTokenRefreshTimer();
    }
  }

  void _startInactivityTimer() {
    _inactivityTimer?.cancel();

    final warningTime = _config.inactivityTimeout - _config.warningDuration;

    _inactivityTimer = Timer(warningTime, () {
      _showExpiryWarning();
    });
  }

  void _showExpiryWarning() {
    state = state.copyWith(
      status: SessionStatus.expiring,
      remainingSeconds: _config.warningDuration.inSeconds,
    );

    // Start countdown
    _countdownTimer?.cancel();
    var remaining = _config.warningDuration.inSeconds;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      remaining--;

      if (remaining <= 0) {
        timer.cancel();
        _expireSession();
      } else {
        state = state.copyWith(remainingSeconds: remaining);
      }
    });

    // Set final expiry timer
    _warningTimer?.cancel();
    _warningTimer = Timer(_config.warningDuration, () {
      _expireSession();
    });
  }

  void _expireSession() {
    // Don't actually expire (logout) — just lock the session.
    // The user has a persistent session stored on device.
    // True session expiry only happens after 30 days of inactivity
    // (handled by UserSessionRepository).
    lockSession();
  }

  void _startTokenRefreshTimer() {
    if (state.tokenExpiresAt == null) return;

    _tokenRefreshTimer?.cancel();

    final now = DateTime.now();
    final expiresAt = state.tokenExpiresAt!;
    final refreshAt = expiresAt.subtract(_config.tokenRefreshThreshold);

    if (refreshAt.isAfter(now)) {
      final delay = refreshAt.difference(now);
      _tokenRefreshTimer = Timer(delay, () {
        unawaited(refreshStoredSession());
      });
    } else if (expiresAt.isAfter(now)) {
      // Already past refresh threshold but not expired, refresh now
      unawaited(refreshStoredSession());
    }
  }

  Future<SessionRefreshResult> _performRefreshToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) {
      return const SessionRefreshResult(SessionRefreshStatus.rejected);
    }
    final refreshGeneration = _sessionGeneration;

    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: ApiConfiguration.baseUrl,
          connectTimeout: const Duration(
            milliseconds: ApiConfiguration.connectTimeout,
          ),
          receiveTimeout: const Duration(
            milliseconds: ApiConfiguration.receiveTimeout,
          ),
        ),
      );
      final securityHeaders = await ref
          .read(securityHeadersInterceptorProvider)
          .buildHeadersForPath('/auth/refresh');

      final response = await dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(headers: securityHeaders),
      );

      if (response.statusCode == 200) {
        final payload = _responsePayload(response.data);
        if (payload == null) {
          return const SessionRefreshResult(SessionRefreshStatus.unavailable);
        }

        final newAccessToken = payload['accessToken'] as String?;
        final newRefreshToken = payload['refreshToken'] as String?;
        final expiresIn = _parseExpiresIn(payload['expiresIn']) ?? 900;
        final refreshedUser = _parseUser(payload);
        final kycStatus =
            (payload['kycStatus'] ?? payload['kyc_status']) as String?;

        if (newAccessToken == null || newAccessToken.isEmpty) {
          return const SessionRefreshResult(SessionRefreshStatus.unavailable);
        }

        if (refreshGeneration != _sessionGeneration) {
          return const SessionRefreshResult(SessionRefreshStatus.unavailable);
        }

        final accessWritten = await _writeRefreshValueIfCurrent(
          refreshGeneration,
          key: _accessTokenKey,
          value: newAccessToken,
        );
        if (!accessWritten) {
          return const SessionRefreshResult(SessionRefreshStatus.unavailable);
        }
        if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
          final refreshWritten = await _writeRefreshValueIfCurrent(
            refreshGeneration,
            key: _refreshTokenKey,
            value: newRefreshToken,
          );
          if (!refreshWritten) {
            return const SessionRefreshResult(SessionRefreshStatus.unavailable);
          }
        }

        final expiresAt = DateTime.now().add(Duration(seconds: expiresIn));
        final expiryWritten = await _writeRefreshValueIfCurrent(
          refreshGeneration,
          key: _tokenExpiryKey,
          value: expiresAt.toIso8601String(),
        );
        if (!expiryWritten) {
          return const SessionRefreshResult(SessionRefreshStatus.unavailable);
        }
        state = state.copyWith(tokenExpiresAt: expiresAt);

        const AppLogger('Debug').debug('Token refreshed successfully');
        _startTokenRefreshTimer();
        return SessionRefreshResult(
          SessionRefreshStatus.success,
          user: refreshedUser,
          kycStatus: kycStatus,
        );
      }
      if (response.statusCode == 401 || response.statusCode == 403) {
        return const SessionRefreshResult(SessionRefreshStatus.rejected);
      }
      return const SessionRefreshResult(SessionRefreshStatus.unavailable);
    } on DioException catch (e) {
      const AppLogger('Token refresh failed').error('Token refresh failed', e);
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        return const SessionRefreshResult(SessionRefreshStatus.rejected);
      }
      return const SessionRefreshResult(SessionRefreshStatus.unavailable);
    } on Object catch (e) {
      const AppLogger('Token refresh failed').error('Token refresh failed', e);
      return const SessionRefreshResult(SessionRefreshStatus.unavailable);
    }
  }

  Map<String, dynamic>? _responsePayload(Object? data) {
    if (data is Map<String, dynamic>) {
      final nestedData = data['data'];
      if (nestedData is Map<String, dynamic>) {
        return nestedData;
      }
      if (nestedData is Map) {
        return Map<String, dynamic>.from(nestedData);
      }
      return data;
    }
    if (data is Map) {
      final normalized = Map<String, dynamic>.from(data);
      final nestedData = normalized['data'];
      if (nestedData is Map<String, dynamic>) {
        return nestedData;
      }
      if (nestedData is Map) {
        return Map<String, dynamic>.from(nestedData);
      }
      return normalized;
    }
    return null;
  }

  User? _parseUser(Map<String, dynamic> payload) {
    final rawUser = payload['user'];
    if (rawUser is Map<String, dynamic>) {
      return User.fromJson(rawUser);
    }
    if (rawUser is Map) {
      return User.fromJson(Map<String, dynamic>.from(rawUser));
    }
    return null;
  }

  Future<bool> _writeRefreshValueIfCurrent(
    int refreshGeneration, {
    required String key,
    required String value,
  }) async {
    if (refreshGeneration != _sessionGeneration) {
      return false;
    }

    await _storage.write(key: key, value: value);

    if (refreshGeneration == _sessionGeneration) {
      return true;
    }

    final currentValue = await _storage.read(key: key);
    if (currentValue == value) {
      await _storage.delete(key: key);
    }
    return false;
  }

  int? _parseExpiresIn(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  Future<void> _invalidateLocalSession() async {
    await endSession();
    try {
      final signal = ref.read(authSessionInvalidatedProvider.notifier);
      signal.state = signal.state + 1;
    } catch (_) {}
  }

  void _cancelWarningTimer() {
    _warningTimer?.cancel();
    _countdownTimer?.cancel();
    _warningTimer = null;
    _countdownTimer = null;
  }

  void _cancelAllTimers() {
    _inactivityTimer?.cancel();
    _warningTimer?.cancel();
    _countdownTimer?.cancel();
    _tokenRefreshTimer?.cancel();
    _backgroundLockTimer?.cancel();
    _inactivityTimer = null;
    _warningTimer = null;
    _countdownTimer = null;
    _tokenRefreshTimer = null;
    _backgroundLockTimer = null;
  }
}

/// Provider for session service
final sessionServiceProvider = NotifierProvider<SessionService, SessionState>(
  SessionService.new,
);

/// Provider to check if session is active
final isSessionActiveProvider = Provider<bool>((ref) {
  final session = ref.watch(sessionServiceProvider);
  return session.isActive;
});

/// Provider for session remaining seconds (for countdown display)
final sessionRemainingSecondsProvider = Provider<int?>((ref) {
  final session = ref.watch(sessionServiceProvider);
  return session.remainingSeconds;
});
