import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/domain/entities/device.dart';
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
    this.currentSessionResolved = false,
    this.requiresUnlock = false,
  });

  final bool isLoading;
  final String? error;
  final List<Session> sessions;
  final String? currentSessionId;
  final bool currentSessionResolved;
  final bool requiresUnlock;

  SessionsState copyWith({
    bool? isLoading,
    String? error,
    List<Session>? sessions,
    String? currentSessionId,
    bool? currentSessionResolved,
    bool? requiresUnlock,
    bool clearCurrentSessionId = false,
  }) => SessionsState(
    isLoading: isLoading ?? this.isLoading,
    error: error,
    sessions: sessions ?? this.sessions,
    currentSessionId: clearCurrentSessionId
        ? null
        : (currentSessionId ?? this.currentSessionId),
    currentSessionResolved:
        currentSessionResolved ?? this.currentSessionResolved,
    requiresUnlock: requiresUnlock ?? this.requiresUnlock,
  );
}

/// Sessions Notifier
class SessionsNotifier extends Notifier<SessionsState> {
  @override
  SessionsState build() => const SessionsState();

  /// Load all active sessions
  Future<void> loadSessions() async {
    final authReady = await _ensureAuthenticatedForSessionRead();
    if (!authReady) {
      return;
    }

    state = state.copyWith(isLoading: true);
    final repository = ref.read(sessionsRepositoryProvider);
    try {
      final sessions = await repository.getSessions();

      final currentSession = await _resolveCurrentSessionId(sessions);

      state = state.copyWith(
        isLoading: false,
        sessions: sessions,
        currentSessionId: currentSession.sessionId,
        currentSessionResolved: currentSession.isResolved,
        clearCurrentSessionId: currentSession.sessionId == null,
        requiresUnlock: false,
      );
    } on ApiException catch (e) {
      if (e.isDeviceBlacklisted) {
        await _clearLocalSessionAfterSecurityBlock(e);
        return;
      }
      if (e.statusCode == 401 && await _refreshAuthForRetry()) {
        try {
          final sessions = await repository.getSessions();
          final currentSession = await _resolveCurrentSessionId(sessions);
          state = state.copyWith(
            isLoading: false,
            sessions: sessions,
            currentSessionId: currentSession.sessionId,
            currentSessionResolved: currentSession.isResolved,
            clearCurrentSessionId: currentSession.sessionId == null,
            error: null,
            requiresUnlock: false,
          );
          return;
        } on ApiException catch (retryError) {
          if (retryError.isDeviceBlacklisted) {
            await _clearLocalSessionAfterSecurityBlock(retryError);
            return;
          }
          if (await _handleExpiredSession(retryError)) {
            state = state.copyWith(
              isLoading: false,
              sessions: const [],
              error: _friendlyError(retryError),
              requiresUnlock: true,
            );
            return;
          }
          state = state.copyWith(
            isLoading: false,
            error: _friendlyError(retryError),
            requiresUnlock: false,
          );
          return;
        }
      }
      if (await _handleExpiredSession(e)) {
        state = state.copyWith(
          isLoading: false,
          sessions: const [],
          error: _friendlyError(e),
          requiresUnlock: true,
        );
        return;
      }
      state = state.copyWith(
        isLoading: false,
        error: _friendlyError(e),
        requiresUnlock: false,
      );
    } on Object {
      state = state.copyWith(
        isLoading: false,
        error: 'Unable to load active sessions. Please try again.',
        requiresUnlock: false,
      );
    }
  }

  /// Revoke a specific session
  Future<bool> revokeSession(String sessionId) async {
    if (!state.currentSessionResolved || state.currentSessionId == null) {
      state = state.copyWith(
        error: 'We are still verifying this device. Refresh and try again.',
        requiresUnlock: false,
      );
      return false;
    }

    if (sessionId == state.currentSessionId) {
      state = state.copyWith(
        error: 'Use Log out to end your current session.',
        requiresUnlock: false,
      );
      return false;
    }

    try {
      final repository = ref.read(sessionsRepositoryProvider);
      await repository.revokeSession(sessionId);

      // Reload sessions after revoke
      await loadSessions();
      return true;
    } on ApiException catch (e) {
      if (e.isDeviceBlacklisted) {
        await _clearLocalSessionAfterSecurityBlock(e);
        return false;
      }
      if (await _handleExpiredSession(e)) {
        state = state.copyWith(error: _friendlyError(e), requiresUnlock: true);
        return false;
      }
      state = state.copyWith(error: _friendlyError(e), requiresUnlock: false);
      return false;
    } on Object {
      state = state.copyWith(
        error: 'Unable to revoke this device. Please try again.',
        requiresUnlock: false,
      );
      return false;
    }
  }

  /// Logout from all devices
  Future<bool> logoutAllDevices() async {
    try {
      final repository = ref.read(sessionsRepositoryProvider);
      await repository.logoutAllDevices();

      await _clearLocalSessionAfterLogoutAll();
      return true;
    } on ApiException catch (e) {
      if (e.isDeviceBlacklisted) {
        await _clearLocalSessionAfterSecurityBlock(e);
        return true;
      }
      if (e.statusCode == 401 || e.statusCode == 403) {
        await _clearLocalSessionAfterLogoutAll();
        return true;
      }
      if (await _handleExpiredSession(e)) {
        state = state.copyWith(error: _friendlyError(e), requiresUnlock: true);
        return false;
      }
      state = state.copyWith(error: _friendlyError(e), requiresUnlock: false);
      return false;
    } on Object {
      state = state.copyWith(
        error: 'Unable to log out other devices. Please try again.',
        requiresUnlock: false,
      );
      return false;
    }
  }

  Future<void> _clearLocalSessionAfterLogoutAll() async {
    await ref.read(authProvider.notifier).clearLocalSession();
    state = state.copyWith(
      sessions: const [],
      currentSessionId: null,
      currentSessionResolved: false,
      clearCurrentSessionId: true,
      error: null,
      requiresUnlock: false,
    );
  }

  Future<void> _clearLocalSessionAfterSecurityBlock(ApiException error) async {
    await ref.read(authProvider.notifier).clearLocalSession();
    state = state.copyWith(
      isLoading: false,
      sessions: const [],
      currentSessionId: null,
      currentSessionResolved: false,
      clearCurrentSessionId: true,
      error: error.message,
      requiresUnlock: false,
    );
  }

  String _friendlyError(ApiException error) {
    if (error.isDeviceBlacklisted) {
      return error.message;
    }
    if (error.statusCode == 401) {
      return ref.read(authProvider).isLocked
          ? 'Please unlock Korido again to continue.'
          : 'Please sign in again to manage active sessions.';
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
    await ref.read(authProvider.notifier).setLocked();
    return ref.read(authProvider).isLocked;
  }

  Future<bool> _refreshAuthForRetry() {
    return ref
        .read(authProvider.notifier)
        .refreshAccessTokenForForegroundRequest();
  }

  Future<bool> _ensureAuthenticatedForSessionRead() async {
    var authState = ref.read(authProvider);
    if (authState.status == AuthStatus.initial ||
        authState.status == AuthStatus.loading) {
      await ref.read(authProvider.notifier).checkAuth();
      authState = ref.read(authProvider);
    }

    if (authState.isAuthenticated) {
      return true;
    }

    state = state.copyWith(
      isLoading: false,
      sessions: const [],
      error: authState.isLocked
          ? 'Please unlock Korido again to continue.'
          : 'Please sign in again to manage active sessions.',
      requiresUnlock: authState.isLocked,
      currentSessionResolved: false,
      clearCurrentSessionId: true,
    );
    return false;
  }

  Future<_CurrentSessionResolution> _resolveCurrentSessionId(
    List<Session> sessions,
  ) async {
    if (sessions.isEmpty) {
      return const _CurrentSessionResolution(sessionId: null, isResolved: true);
    }

    final devices = await ref
        .read(devicesProvider.future)
        .catchError((_) => const <Device>[]);
    var localDeviceId = '';
    try {
      localDeviceId = await ref.read(localDeviceIdProvider.future);
    } on Object {
      localDeviceId = '';
    }

    String? currentDeviceId;
    for (final device in devices) {
      final isCurrentDevice =
          device.isCurrent ||
          (localDeviceId.isNotEmpty &&
              device.deviceIdentifier == localDeviceId);
      if (isCurrentDevice) {
        currentDeviceId = device.id;
        break;
      }
    }

    if (currentDeviceId != null && currentDeviceId.isNotEmpty) {
      for (final session in sessions) {
        if (session.deviceId == currentDeviceId) {
          return _CurrentSessionResolution(
            sessionId: session.id,
            isResolved: true,
          );
        }
      }
    }

    return const _CurrentSessionResolution(sessionId: null, isResolved: false);
  }
}

class _CurrentSessionResolution {
  const _CurrentSessionResolution({
    required this.sessionId,
    required this.isResolved,
  });

  final String? sessionId;
  final bool isResolved;
}

/// Sessions Provider
final sessionsProvider = NotifierProvider<SessionsNotifier, SessionsState>(
  SessionsNotifier.new,
);
