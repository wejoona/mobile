import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Prevents replay attacks by tracking used nonces.
class AntiReplayService {
  static const _tag = 'AntiReplay';
  final AppLogger _log = AppLogger(_tag);
  final Set<String> _usedNonces = {};
  final Duration _nonceLifetime;

  AntiReplayService({
    Duration nonceLifetime = const Duration(minutes: 10),
  }) : _nonceLifetime = nonceLifetime;

  /// Check if a nonce has been used. If not, mark it as used.
  bool validateNonce(String nonce, DateTime timestamp) {
    if (DateTime.now().difference(timestamp) > _nonceLifetime) {
      _log.warn('Nonce expired: $nonce');
      return false;
    }
    if (_usedNonces.contains(nonce)) {
      _log.warn('Replay detected: $nonce');
      return false;
    }
    _usedNonces.add(nonce);
    return true;
  }

  /// Prune expired nonces from memory.
  void prune() {
    // In production, store nonces with timestamps
    if (_usedNonces.length > 10000) {
      final toRemove = _usedNonces.length - 5000;
      _usedNonces.removeAll(_usedNonces.take(toRemove).toList());
      _log.debug('Pruned $toRemove nonces');
    }
  }
}

final antiReplayServiceProvider = Provider<AntiReplayService>((ref) {
  return AntiReplayService();
});
