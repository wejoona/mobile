import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Résultat de tentative de connexion
enum LoginAttemptResult { success, failure, locked, mfaRequired, mfaFailed }

/// Entrée de tentative de connexion
class LoginAttempt {
  final String attemptId;
  final LoginAttemptResult result;
  final String? method; // pin, biometric, password
  final String? deviceId;
  final String? ipAddress;
  final String? failureReason;
  final DateTime timestamp;

  const LoginAttempt({
    required this.attemptId,
    required this.result,
    this.method,
    this.deviceId,
    this.ipAddress,
    this.failureReason,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'attemptId': attemptId,
    'result': result.name,
    if (method != null) 'method': method,
    if (deviceId != null) 'deviceId': deviceId,
    if (ipAddress != null) 'ipAddress': ipAddress,
    if (failureReason != null) 'failureReason': failureReason,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// Service de suivi des tentatives de connexion.
///
/// Enregistre et analyse les tentatives de connexion
/// pour détecter les attaques par force brute.
class LoginAttemptTracker {
  static const _tag = 'LoginAttemptTracker';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;
  final List<LoginAttempt> _recentAttempts = [];

  LoginAttemptTracker({required Dio dio}) : _dio = dio;

  /// Enregistrer une tentative de connexion
  Future<void> recordAttempt({
    required LoginAttemptResult result,
    String? method,
    String? deviceId,
    String? failureReason,
  }) async {
    final attempt = LoginAttempt(
      attemptId: '${DateTime.now().millisecondsSinceEpoch}',
      result: result,
      method: method,
      deviceId: deviceId,
      failureReason: failureReason,
      timestamp: DateTime.now(),
    );
    _recentAttempts.add(attempt);

    try {
      await _dio.post('/audit/login-attempts', data: attempt.toJson());
    } catch (e) {
      _log.error('Failed to record login attempt', e);
    }
  }

  /// Nombre d'échecs consécutifs récents
  int get consecutiveFailures {
    int count = 0;
    for (final a in _recentAttempts.reversed) {
      if (a.result == LoginAttemptResult.failure) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }

  /// Vérifier si le compte devrait être verrouillé
  bool shouldLockAccount({int maxAttempts = 5}) {
    return consecutiveFailures >= maxAttempts;
  }

  /// Obtenir l'historique des connexions
  Future<List<LoginAttempt>> getHistory({int limit = 20}) async {
    try {
      final response = await _dio.get('/audit/login-attempts',
          queryParameters: {'limit': limit});
      return (response.data as List).map((e) {
        final m = e as Map<String, dynamic>;
        return LoginAttempt(
          attemptId: m['attemptId'] as String,
          result: LoginAttemptResult.values.byName(m['result'] as String),
          method: m['method'] as String?,
          deviceId: m['deviceId'] as String?,
          failureReason: m['failureReason'] as String?,
          timestamp: DateTime.parse(m['timestamp'] as String),
        );
      }).toList();
    } catch (e) {
      _log.error('Failed to fetch login history', e);
      return [];
    }
  }
}

final loginAttemptTrackerProvider = Provider<LoginAttemptTracker>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
