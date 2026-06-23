import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:usdc_wallet/services/api/api_client.dart'
    show secureStorageProvider;

export 'package:usdc_wallet/services/api/api_client.dart'
    show StorageKeys, secureStorageProvider;

/// Convenience wrapper around FlutterSecureStorage with positional args.
class SecurePrefs {
  final FlutterSecureStorage _storage;
  const SecurePrefs(this._storage);

  Future<String?> read(String key) => _storage.read(key: key);
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);
  Future<void> delete(String key) => _storage.delete(key: key);
}

/// Provider for SecurePrefs convenience wrapper.
final securePrefsProvider = Provider<SecurePrefs>((ref) {
  return SecurePrefs(ref.watch(secureStorageProvider));
});
