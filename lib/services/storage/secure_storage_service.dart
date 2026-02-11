import 'dart:async';

/// Run 375: Secure storage service for sensitive data (tokens, PIN hash, etc.)
class SecureStorageService {
  static const _pinHashKey = 'korido_pin_hash';
  static const _authTokenKey = 'korido_auth_token';
  static const _refreshTokenKey = 'korido_refresh_token';
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

  // Auth tokens
  Future<void> saveAuthToken(String token) async {
    await _write(_authTokenKey, token);
  }

  Future<String?> getAuthToken() async {
    return _read(_authTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _write(_refreshTokenKey, token);
  }

  Future<String?> getRefreshToken() async {
    return _read(_refreshTokenKey);
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
  Future<void> clearAll() async {
    await _delete(_authTokenKey);
    await _delete(_refreshTokenKey);
    // Keep PIN hash and device ID across logouts
  }

  // Clear everything including PIN (for account deletion)
  Future<void> wipeAll() async {
    await _delete(_pinHashKey);
    await _delete(_authTokenKey);
    await _delete(_refreshTokenKey);
    await _delete(_biometricEnabledKey);
    await _delete(_deviceIdKey);
  }

  // Platform-specific secure storage operations
  Future<void> _write(String key, String value) async {
    // flutter_secure_storage write
  }

  Future<String?> _read(String key) async {
    // flutter_secure_storage read
    return null;
  }

  Future<void> _delete(String key) async {
    // flutter_secure_storage delete
  }
}
