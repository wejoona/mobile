import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Keys for secure storage
class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String phone = 'phone';
  static const String pinHash = 'pin_hash';
  static const String biometricEnabled = 'biometric_enabled';
  static const String avatarUrl = 'avatar_url';
  static const String preferredLocale = 'preferred_locale';
  static const String onboardingComplete = 'onboarding_complete';
  static const String lastSyncTimestamp = 'last_sync_timestamp';
  static const String deviceId = 'device_id';
  static const String fcmToken = 'fcm_token';
}

/// Provider for secure storage
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );
});

/// Convenience wrapper around FlutterSecureStorage with positional args.
class SecurePrefs {
  final FlutterSecureStorage _storage;
  const SecurePrefs(this._storage);

  Future<String?> read(String key) => _storage.read(key: key);
  Future<void> write(String key, String value) => _storage.write(key: key, value: value);
  Future<void> delete(String key) => _storage.delete(key: key);
}

/// Provider for SecurePrefs convenience wrapper.
final securePrefsProvider = Provider<SecurePrefs>((ref) {
  return SecurePrefs(ref.watch(secureStorageProvider));
});
