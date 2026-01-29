import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../utils/logger.dart';

/// Session configuration
class SessionConfig {
  /// Inactivity timeout before auto-logout (default: 5 minutes)
  final Duration inactivityTimeout;

  /// Warning before logout (default: 30 seconds)
  final Duration warningDuration;

  /// Token refresh threshold (refresh when less than this time remaining)
  final Duration tokenRefreshThreshold;

  /// Background timeout (auto-logout when app is in background too long)
  final Duration backgroundTimeout;

  const SessionConfig({
    this.inactivityTimeout = const Duration(minutes: 5),
    this.warningDuration = const Duration(seconds: 30),
    this.tokenRefreshThreshold = const Duration(minutes: 5),
    this.backgroundTimeout = const Duration(minutes: 15),
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
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _tokenExpiryKey = 'token_expiry';
  static const _sessionStartKey = 'session_start';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final SessionConfig _config;

  Timer? _inactivityTimer;
  Timer? _warningTimer;
  Timer? _countdownTimer;
  Timer? _tokenRefreshTimer;
  DateTime? _backgroundEnteredAt;

  SessionService({SessionConfig? config}) : _config = config ?? const SessionConfig();

  @override
  SessionState build() {
    // Check for existing session on startup
    _checkExistingSession();
    return const SessionState();
  }

  /// Start a new session after successful login
  Future<void> startSession({
    required String accessToken,
    String? refreshToken,
    Duration? tokenValidity,
  }) async {
    final now = DateTime.now();
    final expiresAt = tokenValidity != null ? now.add(tokenValidity) : null;

    // Store tokens securely
    await _storage.write(key: _accessTokenKey, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    }
    if (expiresAt != null) {
      await _storage.write(key: _tokenExpiryKey, value: expiresAt.toIso8601String());
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
    if (state.status == SessionStatus.inactive || state.status == SessionStatus.expired) {
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
  }

  /// Unlock the session after successful PIN/biometric
  void unlockSession() {
    state = state.copyWith(
      status: SessionStatus.active,
      lastActivity: DateTime.now(),
    );
    _startInactivityTimer();
  }

  /// End the session (logout)
  Future<void> endSession() async {
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
  void onAppBackground() {
    _backgroundEnteredAt = DateTime.now();
    state = state.copyWith(isInBackground: true);

    // Optionally lock session when going to background
    // lockSession();
  }

  /// App returned to foreground
  void onAppForeground() {
    final wasInBackground = _backgroundEnteredAt;
    _backgroundEnteredAt = null;
    state = state.copyWith(isInBackground: false);

    if (wasInBackground != null && state.status != SessionStatus.inactive) {
      final backgroundDuration = DateTime.now().difference(wasInBackground);

      if (backgroundDuration >= _config.backgroundTimeout) {
        // Been in background too long, expire session
        _expireSession();
      } else if (backgroundDuration >= const Duration(minutes: 1)) {
        // Been in background for a while, lock session
        lockSession();
      } else {
        // Brief background, just record activity
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

  // Private methods

  Future<void> _checkExistingSession() async {
    final token = await _storage.read(key: _accessTokenKey);
    final expiryStr = await _storage.read(key: _tokenExpiryKey);
    final sessionStartStr = await _storage.read(key: _sessionStartKey);

    if (token != null) {
      DateTime? expiresAt;
      DateTime? sessionStarted;

      if (expiryStr != null) {
        expiresAt = DateTime.tryParse(expiryStr);
        // Check if token is expired
        if (expiresAt != null && DateTime.now().isAfter(expiresAt)) {
          await endSession();
          return;
        }
      }

      if (sessionStartStr != null) {
        sessionStarted = DateTime.tryParse(sessionStartStr);
      }

      // Restore session - start as active (lock will happen on app background)
      state = SessionState(
        status: SessionStatus.active,
        sessionStarted: sessionStarted,
        tokenExpiresAt: expiresAt,
        lastActivity: DateTime.now(),
      );

      // Start inactivity timer
      _startInactivityTimer();
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
    _cancelAllTimers();
    state = state.copyWith(
      status: SessionStatus.expired,
      remainingSeconds: null,
    );
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
        _refreshToken();
      });
    } else if (expiresAt.isAfter(now)) {
      // Already past refresh threshold but not expired, refresh now
      _refreshToken();
    }
  }

  Future<void> _refreshToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) return;

    try {
      // Import Dio at the top of the file
      final dio = Dio(BaseOptions(
        baseUrl: 'https://api.joonapay.com/api/v1', // Use ApiConfig.baseUrl if available
        connectTimeout: const Duration(seconds: 30),
      ));

      final response = await dio.post('/auth/refresh', data: {
        'refreshToken': refreshToken,
      });

      if (response.statusCode == 200) {
        final newAccessToken = response.data['accessToken'];
        final newRefreshToken = response.data['refreshToken'];
        final expiresIn = response.data['expiresIn'] as int?; // seconds

        await _storage.write(key: _accessTokenKey, value: newAccessToken);
        await _storage.write(key: _refreshTokenKey, value: newRefreshToken);

        if (expiresIn != null) {
          final expiresAt = DateTime.now().add(Duration(seconds: expiresIn));
          await _storage.write(key: _tokenExpiryKey, value: expiresAt.toIso8601String());
          state = state.copyWith(tokenExpiresAt: expiresAt);
        }

        AppLogger('Debug').debug('Token refreshed successfully');
        _startTokenRefreshTimer();
      }
    } catch (e) {
      AppLogger('Token refresh failed').error('Token refresh failed', e);
      // If refresh fails, session will eventually expire
    }
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
    _inactivityTimer = null;
    _warningTimer = null;
    _countdownTimer = null;
    _tokenRefreshTimer = null;
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
