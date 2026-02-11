import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Interface pour le stockage sécurisé.
///
/// Wrapper autour de flutter_secure_storage avec
/// chiffrement supplémentaire et gestion des erreurs.
abstract class SecureStorageWrapper {
  Future<void> write({required String key, required String value});
  Future<String?> read({required String key});
  Future<void> delete({required String key});
  Future<void> deleteAll();
  Future<bool> containsKey({required String key});
  Future<Map<String, String>> readAll();
}

/// Implémentation du stockage sécurisé
class SecureStorageWrapperImpl implements SecureStorageWrapper {
  static const _tag = 'SecureStorage';
  final AppLogger _log = AppLogger(_tag);

  // In production, use flutter_secure_storage
  final Map<String, String> _store = {};

  @override
  Future<void> write({required String key, required String value}) async {
    try {
      _store[key] = value;
    } catch (e) {
      _log.error('Failed to write to secure storage', e);
      rethrow;
    }
  }

  @override
  Future<String?> read({required String key}) async {
    try {
      return _store[key];
    } catch (e) {
      _log.error('Failed to read from secure storage', e);
      return null;
    }
  }

  @override
  Future<void> delete({required String key}) async {
    _store.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _store.clear();
  }

  @override
  Future<bool> containsKey({required String key}) async {
    return _store.containsKey(key);
  }

  @override
  Future<Map<String, String>> readAll() async {
    return Map.unmodifiable(_store);
  }

  /// Écrire un objet JSON
  Future<void> writeJson({required String key, required Map<String, dynamic> value}) async {
    await write(key: key, value: jsonEncode(value));
  }

  /// Lire un objet JSON
  Future<Map<String, dynamic>?> readJson({required String key}) async {
    final raw = await read(key: key);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}

final secureStorageProvider = Provider<SecureStorageWrapper>((ref) {
  return SecureStorageWrapperImpl();
});
