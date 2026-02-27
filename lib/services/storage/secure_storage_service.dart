import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage service for sensitive data (tokens, PIN hash, etc.)
class SecureStorageService {
  static const _pinHashKey = 'korido_pin_hash';
  static const _biometricEnabledKey = 'korido_biometric_enabled';
  static const _deviceIdKey = 'korido_device_id';

  // PIN
  Future<void> savePinHash(String hash) async {
    await _write(_pinHashKey, hash);
  }

  Future<String?> getPinHash() async {
    return _read(_pinHashKey);
  }

  Future<void> clearPinHash() async {
    await _delete(_pinHashKey);
  }

  // Biometric preference
  Future<void> setBiometricEnabled(bool enabled) async {
    await _write(_biometricEnabledKey, enabled.toString());
  }

  Future<bool> isBiometricEnabled() async {
    final value = await _read(_biometricEnabledKey);
    return value == 'true';
  }

  // Device ID
  Future<void> saveDeviceId(String deviceId) async {
    await _write(_deviceIdKey, deviceId);
  }

  Future<String?> getDeviceId() async {
    return _read(_deviceIdKey);
  }

  // Clear all secure data on logout
  // Note: auth tokens are managed by UserStateMachine via StorageKeys, not here
  Future<void> clearAll() async {
    // Keep PIN hash and device ID across logouts
  }

  // Clear everything including PIN (for account deletion)
  Future<void> wipeAll() async {
    await _delete(_pinHashKey);
    await _delete(_biometricEnabledKey);
    await _delete(_deviceIdKey);
  }

  // Platform-specific secure storage operations
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  Future<void> _write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> _read(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> _delete(String key) async {
    await _storage.delete(key: key);
  }
}
