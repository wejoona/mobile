import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/settings/models/session.dart';
import 'package:usdc_wallet/features/settings/repositories/sessions_repository.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

/// Sessions State
class SessionsState {
  final bool isLoading;
  final String? error;
  final List<Session> sessions;
  final String? currentSessionId;

  const SessionsState({
    this.isLoading = false,
    this.error,
    this.sessions = const [],
    this.currentSessionId,
  });

  SessionsState copyWith({
    bool? isLoading,
    String? error,
    List<Session>? sessions,
    String? currentSessionId,
  }) {
    return SessionsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      sessions: sessions ?? this.sessions,
      currentSessionId: currentSessionId ?? this.currentSessionId,
    );
  }
}

/// Sessions Notifier
class SessionsNotifier extends Notifier<SessionsState> {
  @override
  SessionsState build() => const SessionsState();

  /// Load all active sessions
  Future<void> loadSessions() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repository = ref.read(sessionsRepositoryProvider);
      final sessions = await repository.getSessions();

      // Identify current session (most recent activity)
      final currentSession = sessions.isNotEmpty
          ? sessions.reduce(
              (a, b) => a.lastActivityAt.isAfter(b.lastActivityAt) ? a : b,
            )
          : null;

      state = state.copyWith(
        isLoading: false,
        sessions: sessions,
        currentSessionId: currentSession?.id,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: _friendlyError(e));
    } catch (_) {
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
      state = state.copyWith(error: _friendlyError(e));
      return false;
    } catch (_) {
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

      // Clear sessions
      state = state.copyWith(sessions: []);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(error: _friendlyError(e));
      return false;
    } catch (_) {
      state = state.copyWith(
        error: 'Unable to log out other devices. Please try again.',
      );
      return false;
    }
  }

  String _friendlyError(ApiException error) {
    if (error.statusCode == 401) {
      return 'Your session has expired. Please sign in again.';
    }
    if (error.statusCode == 403) {
      return 'You do not have permission to manage sessions right now.';
    }
    return error.message;
  }
}

/// Sessions Provider
final sessionsProvider = NotifierProvider<SessionsNotifier, SessionsState>(
  SessionsNotifier.new,
);
