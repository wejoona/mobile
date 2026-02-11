import 'dart:math';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Generates cryptographic challenge tokens for auth flows.
class ChallengeTokenGenerator {
  static const _tag = 'ChallengeToken';
  final AppLogger _log = AppLogger(_tag);
  final Random _random = Random.secure();

  /// Generate a random challenge of [length] bytes, returned as base64.
  String generate({int length = 32}) {
    final bytes = List<int>.generate(length, (_) => _random.nextInt(256));
    return base64Url.encode(bytes);
  }

  /// Generate a time-bound challenge with embedded expiry.
  Map<String, dynamic> generateTimeBound({
    int length = 32,
    Duration validity = const Duration(minutes: 5),
  }) {
    final token = generate(length: length);
    final expiry = DateTime.now().add(validity);
    return {'token': token, 'expiresAt': expiry.toIso8601String()};
  }

  /// Validate that a time-bound challenge hasn't expired.
  bool isValid(Map<String, dynamic> challenge) {
    final expiresAt = DateTime.tryParse(challenge['expiresAt'] ?? '');
    if (expiresAt == null) return false;
    return DateTime.now().isBefore(expiresAt);
  }
}

final challengeTokenGeneratorProvider = Provider<ChallengeTokenGenerator>((ref) {
  return ChallengeTokenGenerator();
});
