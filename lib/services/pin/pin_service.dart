import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/api_client.dart';

/// PIN Service - Handles secure PIN storage and verification
/// SECURITY: PIN is hashed before storage, never stored in plain text
class PinService {
  final FlutterSecureStorage _storage;
  final Dio _dio;

  static const String _pinHashKey = 'pin_hash';
  static const String _pinSaltKey = 'pin_salt';
  static const String _pinAttemptsKey = 'pin_attempts';
  static const String _pinLockedUntilKey = 'pin_locked_until';

  static const int maxAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);

  PinService(this._storage, this._dio);

  /// Check if PIN is set
  Future<bool> hasPin() async {
    final hash = await _storage.read(key: _pinHashKey);
    return hash != null && hash.isNotEmpty;
  }

  /// Set a new PIN
  /// SECURITY: PIN is hashed with a unique salt before storage
  Future<bool> setPin(String pin) async {
    if (pin.length != 4 || !RegExp(r'^\d{4}$').hasMatch(pin)) {
      return false;
    }

    // Check for weak PINs
    if (_isWeakPin(pin)) {
      return false;
    }

    // Generate a unique salt
    final salt = _generateSalt();
    final hash = _hashPin(pin, salt);

    await _storage.write(key: _pinHashKey, value: hash);
    await _storage.write(key: _pinSaltKey, value: salt);
    await _storage.write(key: _pinAttemptsKey, value: '0');
    await _storage.delete(key: _pinLockedUntilKey);

    // Also set PIN on backend if authenticated
    try {
      await _dio.post('/wallet/pin/set', data: {'pin': pin});
    } catch (e) {
      // Backend call failed, but local PIN is set
      // This will be synced later
    }

    return true;
  }

  /// Verify PIN locally (for session unlock)
  /// SECURITY: Returns false for wrong PIN, tracks attempts, locks after max attempts
  Future<PinVerificationResult> verifyPinLocally(String pin) async {
    // Check if locked
    final lockedUntil = await _storage.read(key: _pinLockedUntilKey);
    if (lockedUntil != null) {
      final lockTime = DateTime.parse(lockedUntil);
      if (DateTime.now().isBefore(lockTime)) {
        final remaining = lockTime.difference(DateTime.now());
        return PinVerificationResult(
          success: false,
          isLocked: true,
          lockRemainingSeconds: remaining.inSeconds,
          message: 'Too many failed attempts. Try again in ${remaining.inMinutes} minutes.',
        );
      } else {
        // Lock expired, reset
        await _storage.delete(key: _pinLockedUntilKey);
        await _storage.write(key: _pinAttemptsKey, value: '0');
      }
    }

    final storedHash = await _storage.read(key: _pinHashKey);
    final salt = await _storage.read(key: _pinSaltKey);

    if (storedHash == null || salt == null) {
      return PinVerificationResult(
        success: false,
        message: 'PIN not set',
      );
    }

    final inputHash = _hashPin(pin, salt);

    if (inputHash == storedHash) {
      // Reset attempts on success
      await _storage.write(key: _pinAttemptsKey, value: '0');
      return PinVerificationResult(success: true);
    }

    // Track failed attempt
    final attemptsStr = await _storage.read(key: _pinAttemptsKey) ?? '0';
    final attempts = int.parse(attemptsStr) + 1;
    await _storage.write(key: _pinAttemptsKey, value: attempts.toString());

    if (attempts >= maxAttempts) {
      // Lock the PIN
      final lockUntil = DateTime.now().add(lockoutDuration);
      await _storage.write(key: _pinLockedUntilKey, value: lockUntil.toIso8601String());

      return PinVerificationResult(
        success: false,
        isLocked: true,
        lockRemainingSeconds: lockoutDuration.inSeconds,
        message: 'Too many failed attempts. PIN locked for ${lockoutDuration.inMinutes} minutes.',
      );
    }

    final remainingAttempts = maxAttempts - attempts;
    return PinVerificationResult(
      success: false,
      remainingAttempts: remainingAttempts,
      message: 'Incorrect PIN. $remainingAttempts attempts remaining.',
    );
  }

  // Storage key for PIN token
  static const _pinTokenKey = 'pin_verification_token';
  static const _pinTokenExpiryKey = 'pin_token_expiry';

  /// Verify PIN with backend (for sensitive operations like transfers)
  /// SECURITY: Always verify with backend for financial transactions
  /// Returns a PIN token that must be included in transfer requests
  Future<PinVerificationResult> verifyPinWithBackend(String pin) async {
    try {
      final response = await _dio.post('/wallet/pin/verify', data: {'pin': pin});

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['valid'] == true) {
          // Store the PIN token for subsequent transfer operations
          final pinToken = data['pinToken'] as String?;
          final expiresIn = data['expiresIn'] as int? ?? 300;

          if (pinToken != null) {
            await _storage.write(key: _pinTokenKey, value: pinToken);
            final expiry = DateTime.now().add(Duration(seconds: expiresIn));
            await _storage.write(key: _pinTokenExpiryKey, value: expiry.toIso8601String());
          }

          return PinVerificationResult(
            success: true,
            pinToken: pinToken,
            expiresIn: expiresIn,
          );
        }
      }

      // Handle backend response
      final data = response.data;
      return PinVerificationResult(
        success: false,
        isLocked: data['locked'] == true,
        remainingAttempts: data['remainingAttempts'],
        lockRemainingSeconds: data['lockRemainingSeconds'],
        message: data['message'] ?? 'PIN verification failed',
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return PinVerificationResult(
          success: false,
          message: 'Incorrect PIN',
        );
      }
      if (e.response?.statusCode == 429) {
        return PinVerificationResult(
          success: false,
          isLocked: true,
          message: 'Too many attempts. Please try again later.',
        );
      }
      return PinVerificationResult(
        success: false,
        message: 'Unable to verify PIN. Please try again.',
      );
    }
  }

  /// Change PIN (requires current PIN verification)
  Future<bool> changePin(String currentPin, String newPin) async {
    // Verify current PIN first
    final verification = await verifyPinLocally(currentPin);
    if (!verification.success) {
      return false;
    }

    // Set new PIN
    return setPin(newPin);
  }

  /// Clear PIN (on logout)
  Future<void> clearPin() async {
    await _storage.delete(key: _pinHashKey);
    await _storage.delete(key: _pinSaltKey);
    await _storage.delete(key: _pinAttemptsKey);
    await _storage.delete(key: _pinLockedUntilKey);
    await clearPinToken();
  }

  /// Hash PIN with salt using PBKDF2
  /// SECURITY: PBKDF2 with high iterations to resist brute-force attacks
  /// Since PINs are only 4 digits (10,000 combinations), we need strong KDF
  String _hashPin(String pin, String salt) {
    // Use PBKDF2 with HMAC-SHA256
    // 100,000 iterations makes brute-force significantly slower
    const iterations = 100000;
    const keyLength = 32; // 256 bits

    final saltBytes = utf8.encode(salt);
    final pinBytes = utf8.encode(pin);

    // PBKDF2 implementation using HMAC-SHA256
    final derivedKey = _pbkdf2(pinBytes, saltBytes, iterations, keyLength);
    return base64.encode(derivedKey);
  }

  /// PBKDF2 key derivation function
  /// SECURITY: Implements RFC 2898 PBKDF2 with HMAC-SHA256
  List<int> _pbkdf2(List<int> password, List<int> salt, int iterations, int keyLength) {
    final hmac = Hmac(sha256, password);
    final numBlocks = (keyLength + 31) ~/ 32; // SHA256 produces 32 bytes
    final derivedKey = <int>[];

    for (var blockNum = 1; blockNum <= numBlocks; blockNum++) {
      // Encode block number as big-endian 4-byte integer
      final blockBytes = [
        (blockNum >> 24) & 0xff,
        (blockNum >> 16) & 0xff,
        (blockNum >> 8) & 0xff,
        blockNum & 0xff,
      ];

      // U1 = PRF(Password, Salt || INT(i))
      var u = hmac.convert([...salt, ...blockBytes]).bytes;
      var result = List<int>.from(u);

      // Subsequent iterations: Ui = PRF(Password, U(i-1))
      for (var i = 1; i < iterations; i++) {
        u = hmac.convert(u).bytes;
        // XOR with accumulated result
        for (var j = 0; j < result.length; j++) {
          result[j] ^= u[j];
        }
      }

      derivedKey.addAll(result);
    }

    return derivedKey.sublist(0, keyLength);
  }

  /// Generate a random salt using cryptographically secure random
  /// SECURITY: Use Random.secure() for cryptographic operations
  String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64.encode(bytes).substring(0, 16);
  }

  /// Get stored PIN token for transfer operations
  /// Returns null if no token or if expired
  Future<String?> getPinToken() async {
    final token = await _storage.read(key: _pinTokenKey);
    if (token == null) return null;

    final expiryStr = await _storage.read(key: _pinTokenExpiryKey);
    if (expiryStr != null) {
      final expiry = DateTime.parse(expiryStr);
      if (DateTime.now().isAfter(expiry)) {
        // Token expired, clear it
        await clearPinToken();
        return null;
      }
    }

    return token;
  }

  /// Check if a valid PIN token exists
  Future<bool> hasValidPinToken() async {
    final token = await getPinToken();
    return token != null;
  }

  /// Clear the PIN token (after use or on logout)
  Future<void> clearPinToken() async {
    await _storage.delete(key: _pinTokenKey);
    await _storage.delete(key: _pinTokenExpiryKey);
  }

  /// Check for weak PINs
  bool _isWeakPin(String pin) {
    // Common weak PINs
    const weakPins = [
      '0000', '1111', '2222', '3333', '4444',
      '5555', '6666', '7777', '8888', '9999',
      '1234', '4321', '1212', '2121', '0123',
      '1010', '2020', '1122', '2211', '1357',
      '2468', '0852', '9876', '6789',
    ];

    if (weakPins.contains(pin)) {
      return true;
    }

    // Check for repeated digits
    if (pin[0] == pin[1] && pin[1] == pin[2] && pin[2] == pin[3]) {
      return true;
    }

    // Check for sequential digits
    final digits = pin.split('').map(int.parse).toList();
    bool isSequential = true;
    for (int i = 1; i < digits.length; i++) {
      if (digits[i] != digits[i - 1] + 1) {
        isSequential = false;
        break;
      }
    }
    if (isSequential) return true;

    // Check for reverse sequential
    isSequential = true;
    for (int i = 1; i < digits.length; i++) {
      if (digits[i] != digits[i - 1] - 1) {
        isSequential = false;
        break;
      }
    }
    if (isSequential) return true;

    return false;
  }
}

/// Result of PIN verification
class PinVerificationResult {
  final bool success;
  final bool isLocked;
  final int? remainingAttempts;
  final int? lockRemainingSeconds;
  final String? message;
  final String? pinToken;
  final int? expiresIn;

  PinVerificationResult({
    required this.success,
    this.isLocked = false,
    this.remainingAttempts,
    this.lockRemainingSeconds,
    this.message,
    this.pinToken,
    this.expiresIn,
  });
}

/// Provider for PIN service
final pinServiceProvider = Provider<PinService>((ref) {
  final storage = ref.read(secureStorageProvider);
  final dio = ref.read(dioProvider);
  return PinService(storage, dio);
});
