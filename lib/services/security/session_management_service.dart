import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// État de la session utilisateur
enum SessionState { active, idle, locked, expired, terminated }

/// Informations de session
class SessionInfo {
  final String sessionId;
  final SessionState state;
  final DateTime createdAt;
  final DateTime lastActivityAt;
  final Duration maxIdleTime;
  final Duration maxSessionTime;
  final String? deviceId;
  final String? ipAddress;

  const SessionInfo({
    required this.sessionId,
    required this.state,
    required this.createdAt,
    required this.lastActivityAt,
    this.maxIdleTime = const Duration(minutes: 15),
    this.maxSessionTime = const Duration(hours: 24),
    this.deviceId,
    this.ipAddress,
  });

  bool get isExpired {
    final now = DateTime.now();
    if (now.difference(lastActivityAt) > maxIdleTime) return true;
    if (now.difference(createdAt) > maxSessionTime) return true;
    return false;
  }

  SessionInfo copyWith({
    SessionState? state,
    DateTime? lastActivityAt,
  }) => SessionInfo(
    sessionId: sessionId,
    state: state ?? this.state,
    createdAt: createdAt,
    lastActivityAt: lastActivityAt ?? this.lastActivityAt,
    maxIdleTime: maxIdleTime,
    maxSessionTime: maxSessionTime,
    deviceId: deviceId,
    ipAddress: ipAddress,
  );
}

/// Gestion des sessions utilisateur.
///
/// Contrôle la durée de session, le verrouillage automatique
/// et la terminaison en cas d'inactivité.
class SessionManagementService {
  static const _tag = 'SessionManagement';
  final AppLogger _log = AppLogger(_tag);
  SessionInfo? _currentSession;

  SessionInfo? get currentSession => _currentSession;
  bool get hasActiveSession => _currentSession?.state == SessionState.active;

  /// Créer une nouvelle session
  SessionInfo createSession({required String sessionId, String? deviceId}) {
    _currentSession = SessionInfo(
      sessionId: sessionId,
      state: SessionState.active,
      createdAt: DateTime.now(),
      lastActivityAt: DateTime.now(),
      deviceId: deviceId,
    );
    _log.info('Session created: $sessionId');
    return _currentSession!;
  }

  /// Mettre à jour l'activité
  void touchSession() {
    if (_currentSession == null) return;
    if (_currentSession!.isExpired) {
      _currentSession = _currentSession!.copyWith(state: SessionState.expired);
      return;
    }
    _currentSession = _currentSession!.copyWith(lastActivityAt: DateTime.now());
  }

  /// Verrouiller la session
  void lockSession() {
    if (_currentSession == null) return;
    _currentSession = _currentSession!.copyWith(state: SessionState.locked);
    _log.info('Session locked');
  }

  /// Terminer la session
  void terminateSession() {
    if (_currentSession == null) return;
    _log.info('Session terminated: ${_currentSession!.sessionId}');
    _currentSession = _currentSession!.copyWith(state: SessionState.terminated);
  }

  /// Vérifier si la session est toujours valide
  bool validateSession() {
    if (_currentSession == null) return false;
    if (_currentSession!.isExpired) {
      _currentSession = _currentSession!.copyWith(state: SessionState.expired);
      return false;
    }
    return _currentSession!.state == SessionState.active;
  }
}

final sessionManagementProvider = Provider<SessionManagementService>((ref) {
  return SessionManagementService();
});
