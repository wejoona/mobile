import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Stockage sécurisé des jetons d'authentification.
class SecureTokenStorage {
  static const _tag = 'SecureTokenStorage';
  final AppLogger _log = AppLogger(_tag);
  final Map<String, String> _store = {};

  Future<void> write(String key, String value) async {
    _store[key] = value;
    _log.debug('Stored token: $key');
  }

  Future<String?> read(String key) async {
    return _store[key];
  }

  Future<void> delete(String key) async {
    _store.remove(key);
    _log.debug('Deleted token: $key');
  }

  Future<void> deleteAll() async {
    _store.clear();
    _log.debug('All tokens cleared');
  }

  Future<bool> containsKey(String key) async {
    return _store.containsKey(key);
  }
}

final secureTokenStorageProvider = Provider<SecureTokenStorage>((ref) {
  return SecureTokenStorage();
});
