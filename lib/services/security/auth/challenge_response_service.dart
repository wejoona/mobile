import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// A challenge issued by the server.
class AuthChallenge {
  final String id;
  final String nonce;
  final String algorithm;
  final DateTime expiresAt;

  const AuthChallenge({
    required this.id,
    required this.nonce,
    required this.algorithm,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  factory AuthChallenge.fromJson(Map<String, dynamic> json) {
    return AuthChallenge(
      id: json['id'] as String,
      nonce: json['nonce'] as String,
      algorithm: json['algorithm'] as String? ?? 'SHA-256',
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }
}

/// Handles cryptographic challenge-response authentication flows.
///
/// Used for step-up auth and device verification where the server
/// issues a challenge and the client must prove possession of a secret.
class ChallengeResponseService {
  static const _tag = 'ChallengeResponse';
  final AppLogger _log = AppLogger(_tag);

  /// Solve a challenge using the client secret.
  String solveChallenge(AuthChallenge challenge, String clientSecret) {
    if (challenge.isExpired) {
      throw StateError('Challenge has expired');
    }

    final payload = '${challenge.nonce}:$clientSecret:${challenge.id}';
    // In production: HMAC-SHA256(clientSecret, nonce + challengeId)
    final response = base64Encode(utf8.encode(payload));
    _log.debug('Challenge solved: ${challenge.id}');
    return response;
  }

  /// Generate a client nonce for additional entropy.
  String generateClientNonce() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }
}

final challengeResponseServiceProvider =
    Provider<ChallengeResponseService>((ref) {
  return ChallengeResponseService();
});
