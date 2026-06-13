import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/features/settings/models/session.dart';
import 'package:usdc_wallet/features/settings/providers/devices_provider.dart';
import 'package:usdc_wallet/features/settings/repositories/sessions_repository.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

/// Sessions State
class SessionsState {
  const SessionsState({
    this.isLoading = false,
    this.error,
    this.sessions = const [],
    this.currentSessionId,
  });

  final bool isLoading;
  final String? error;
  final List<Session> sessions;
  final String? currentSessionId;

  SessionsState copyWith({
    bool? isLoading,
    String? error,
    List<Session>? sessions,
    String? currentSessionId,
  }) => SessionsState(
    isLoading: isLoading ?? this.isLoading,
    error: error,
    sessions: sessions ?? this.sessions,
    currentSessionId: currentSessionId ?? this.currentSessionId,
  );
}

/// Sessions Notifier
class SessionsNotifier extends Notifier<SessionsState> {
  @override
  SessionsState build() => const SessionsState();

  /// Load all active sessions
  Future<void> loadSessions() async {
    state = state.copyWith(isLoading: true);
    final repository = ref.read(sessionsRepositoryProvider);
    try {
      final sessions = await repository.getSessions();

      final currentSession = _resolveCurrentSession(sessions);

      state = state.copyWith(
        isLoading: false,
        sessions: sessions,
        currentSessionId: currentSession?.id,
      );
    } on ApiException catch (e) {
      if (e.statusCode == 401 && await _refreshAuthForRetry()) {
        try {
          final sessions = await repository.getSessions();
          final currentSession = _resolveCurrentSession(sessions);
          state = state.copyWith(
            isLoading: false,
            sessions: sessions,
            currentSessionId: currentSession?.id,
            error: null,
          );
          return;
        } on ApiException catch (retryError) {
          if (await _handleExpiredSession(retryError)) {
            state = state.copyWith(
              isLoading: false,
              sessions: const [],
              error: null,
            );
            return;
          }
          state = state.copyWith(
            isLoading: false,
            error: _friendlyError(retryError),
          );
          return;
        }
      }
      if (await _handleExpiredSession(e)) {
        state = state.copyWith(
          isLoading: false,
          sessions: const [],
          error: null,
        );
        return;
      }
      state = state.copyWith(isLoading: false, error: _friendlyError(e));
    } on Object {
      state = state.copyWith(
        isLoading: false,
        error: 'Unable to load active sessions. Please try again.',
      );
    }
  }

  /// Revoke a specific session
  Future<bool> revokeSession(String sessionId) async {
    try {
      final repository = ref.read(sessionsRepositoryProvider);
      await repository.revokeSession(sessionId);

      // Reload sessions after revoke
      await loadSessions();
      return true;
    } on ApiException catch (e) {
      if (await _handleExpiredSession(e)) {
        state = state.copyWith(error: null);
        return false;
      }
      state = state.copyWith(error: _friendlyError(e));
      return false;
    } on Object {
      state = state.copyWith(
        error: 'Unable to revoke this device. Please try again.',
      );
      return false;
    }
  }

  /// Logout from all devices
  Future<bool> logoutAllDevices() async {
    try {
      final repository = ref.read(sessionsRepositoryProvider);
      await repository.logoutAllDevices();

      await ref.read(authProvider.notifier).clearLocalSession();
      state = state.copyWith(sessions: []);
      return true;
    } on ApiException catch (e) {
      if (await _handleExpiredSession(e)) {
        state = state.copyWith(error: null);
        return false;
      }
      state = state.copyWith(error: _friendlyError(e));
      return false;
    } on Object {
      state = state.copyWith(
        error: 'Unable to log out other devices. Please try again.',
      );
      return false;
    }
  }

  String _friendlyError(ApiException error) {
    if (error.statusCode == 401) {
      return 'Please unlock Korido again to continue.';
    }
    if (error.statusCode == 403) {
      return 'You do not have permission to manage sessions right now.';
    }
    return error.message;
  }

  Future<bool> _handleExpiredSession(ApiException error) async {
    if (error.statusCode != 401) {
      return false;
    }
    ref.read(authProvider.notifier).setLocked();
    return true;
  }

  Future<bool> _refreshAuthForRetry() {
    return ref
        .read(authProvider.notifier)
        .refreshAccessTokenForForegroundRequest();
  }

  Session? _resolveCurrentSession(List<Session> sessions) {
    if (sessions.isEmpty) {
      return null;
    }

    final currentDevice = ref.read(currentDeviceProvider);
    final currentDeviceId = currentDevice?.id;
    if (currentDeviceId != null && currentDeviceId.isNotEmpty) {
      for (final session in sessions) {
        if (session.deviceId == currentDeviceId) {
          return session;
        }
      }
    }

    return sessions.reduce(
      (a, b) => a.lastActivityAt.isAfter(b.lastActivityAt) ? a : b,
    );
  }
}

/// Sessions Provider
final sessionsProvider = NotifierProvider<SessionsNotifier, SessionsState>(
  SessionsNotifier.new,
);
