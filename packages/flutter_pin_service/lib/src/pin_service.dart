import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_pin_service/src/pin_config.dart';
import 'package:flutter_pin_service/src/pin_hasher.dart';
import 'package:flutter_pin_service/src/pin_validator.dart';

/// Secure PIN Service
///
/// Handles all PIN operations with security best practices:
/// - PIN is hashed with PBKDF2 before storage (never stored in plain text)
/// - Brute-force protection with lockout after max attempts
/// - Weak PIN detection and rejection
/// - Secure storage using flutter_secure_storage
///
/// ## Usage
///
/// ```dart
/// final pinService = PinService();
///
/// // Check if PIN is set
/// if (!await pinService.hasPin()) {
///   // Set a new PIN
///   await pinService.setPin('1234');
/// }
///
/// // Verify PIN
/// final result = await pinService.verifyPin('1234');
/// if (result.success) {
///   // PIN is correct
/// } else if (result.isLocked) {
///   // Too many failed attempts
///   print('Locked for ${result.lockRemainingSeconds} seconds');
/// } else {
///   // Wrong PIN
///   print('${result.remainingAttempts} attempts remaining');
/// }
/// ```
class PinService {
  final FlutterSecureStorage _storage;

  /// Create a PIN service with optional custom storage.
  PinService([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  /// Check if a PIN has been set.
  Future<bool> hasPin() async {
    final hash = await _storage.read(key: PinStorageKeys.pinHash);
    return hash != null && hash.isNotEmpty;
  }

  /// Set a new PIN.
  ///
  /// Returns [SetPinResult] indicating success or failure.
  /// Will reject weak PINs if [PinConfig.rejectWeakPins] is true.
  Future<SetPinResult> setPin(String pin) async {
    // Validate PIN format and strength
    final validation = PinValidator.validate(pin);
    if (!validation.isValid) {
      return SetPinResult(
        success: false,
        error: SetPinError.validationFailed,
        message: validation.message ?? 'Invalid PIN',
      );
    }

    try {
      // Generate salt and hash
      final salt = PinHasher.generateSalt();
      final hash = PinHasher.hashPin(pin, salt);

      // Store securely
      await _storage.write(key: PinStorageKeys.pinHash, value: hash);
      await _storage.write(key: PinStorageKeys.pinSalt, value: salt);
      await _storage.write(key: PinStorageKeys.pinAttempts, value: '0');
      await _storage.delete(key: PinStorageKeys.pinLockedUntil);

      return SetPinResult(success: true);
    } catch (e) {
      return SetPinResult(
        success: false,
        error: SetPinError.storageError,
        message: 'Failed to save PIN: $e',
      );
    }
  }

  /// Verify a PIN.
  ///
  /// Returns [PinVerificationResult] with success status, lockout info, etc.
  /// Tracks failed attempts and locks after [PinConfig.maxAttempts].
  Future<PinVerificationResult> verifyPin(String pin) async {
    // Check if locked
    final lockCheck = await _checkLockout();
    if (lockCheck != null) {
      return lockCheck;
    }

    // Get stored hash and salt
    final storedHash = await _storage.read(key: PinStorageKeys.pinHash);
    final salt = await _storage.read(key: PinStorageKeys.pinSalt);

    if (storedHash == null || salt == null) {
      return PinVerificationResult(
        success: false,
        message: 'PIN not set',
      );
    }

    // Verify PIN
    if (PinHasher.verifyPin(pin, storedHash, salt)) {
      // Success - reset attempts
      await _storage.write(key: PinStorageKeys.pinAttempts, value: '0');
      return PinVerificationResult(success: true);
    }

    // Failed - track attempt
    return await _handleFailedAttempt();
  }

  /// Change PIN (requires current PIN verification).
  ///
  /// Returns [ChangePinResult] indicating success or failure.
  Future<ChangePinResult> changePin(String currentPin, String newPin) async {
    // Verify current PIN first
    final verification = await verifyPin(currentPin);
    if (!verification.success) {
      return ChangePinResult(
        success: false,
        error: ChangePinError.currentPinWrong,
        message: verification.message ?? 'Current PIN is incorrect',
        isLocked: verification.isLocked,
        lockRemainingSeconds: verification.lockRemainingSeconds,
      );
    }

    // Set new PIN
    final setResult = await setPin(newPin);
    if (!setResult.success) {
      return ChangePinResult(
        success: false,
        error: ChangePinError.newPinInvalid,
        message: setResult.message ?? 'New PIN is invalid',
      );
    }

    return ChangePinResult(success: true);
  }

  /// Clear all PIN data.
  ///
  /// Call this on logout to remove all stored PIN information.
  Future<void> clearPin() async {
    await _storage.delete(key: PinStorageKeys.pinHash);
    await _storage.delete(key: PinStorageKeys.pinSalt);
    await _storage.delete(key: PinStorageKeys.pinAttempts);
    await _storage.delete(key: PinStorageKeys.pinLockedUntil);
    await _storage.delete(key: PinStorageKeys.pinToken);
    await _storage.delete(key: PinStorageKeys.pinTokenExpiry);
  }

  /// Get the number of remaining attempts before lockout.
  Future<int> getRemainingAttempts() async {
    final attemptsStr = await _storage.read(key: PinStorageKeys.pinAttempts) ?? '0';
    final attempts = int.tryParse(attemptsStr) ?? 0;
    return PinConfig.maxAttempts - attempts;
  }

  /// Check if PIN is currently locked.
  Future<bool> isLocked() async {
    final lockedUntil = await _storage.read(key: PinStorageKeys.pinLockedUntil);
    if (lockedUntil == null) return false;

    final lockTime = DateTime.parse(lockedUntil);
    return DateTime.now().isBefore(lockTime);
  }

  /// Get seconds remaining in lockout.
  Future<int> getLockRemainingSeconds() async {
    final lockedUntil = await _storage.read(key: PinStorageKeys.pinLockedUntil);
    if (lockedUntil == null) return 0;

    final lockTime = DateTime.parse(lockedUntil);
    final remaining = lockTime.difference(DateTime.now());
    return remaining.isNegative ? 0 : remaining.inSeconds;
  }

  /// Get hash for transmission to backend.
  ///
  /// Use this when sending PIN to backend for verification.
  /// The backend should re-hash with its own salt for storage.
  String getTransmissionHash(String pin) {
    return PinHasher.hashPinForTransmission(pin);
  }

  // --- PIN Token Management ---

  /// Store a PIN token (e.g., from backend verification).
  Future<void> storePinToken(String token, {Duration? expiresIn}) async {
    await _storage.write(key: PinStorageKeys.pinToken, value: token);

    if (expiresIn != null) {
      final expiry = DateTime.now().add(expiresIn);
      await _storage.write(
        key: PinStorageKeys.pinTokenExpiry,
        value: expiry.toIso8601String(),
      );
    }
  }

  /// Get stored PIN token if valid.
  Future<String?> getPinToken() async {
    final token = await _storage.read(key: PinStorageKeys.pinToken);
    if (token == null) return null;

    // Check expiry
    final expiryStr = await _storage.read(key: PinStorageKeys.pinTokenExpiry);
    if (expiryStr != null) {
      final expiry = DateTime.parse(expiryStr);
      if (DateTime.now().isAfter(expiry)) {
        await clearPinToken();
        return null;
      }
    }

    return token;
  }

  /// Check if a valid PIN token exists.
  Future<bool> hasValidPinToken() async {
    final token = await getPinToken();
    return token != null;
  }

  /// Clear PIN token.
  Future<void> clearPinToken() async {
    await _storage.delete(key: PinStorageKeys.pinToken);
    await _storage.delete(key: PinStorageKeys.pinTokenExpiry);
  }

  // --- Private Helpers ---

  Future<PinVerificationResult?> _checkLockout() async {
    final lockedUntil = await _storage.read(key: PinStorageKeys.pinLockedUntil);
    if (lockedUntil == null) return null;

    final lockTime = DateTime.parse(lockedUntil);
    if (DateTime.now().isBefore(lockTime)) {
      final remaining = lockTime.difference(DateTime.now());
      return PinVerificationResult(
        success: false,
        isLocked: true,
        lockRemainingSeconds: remaining.inSeconds,
        message: 'Too many failed attempts. Try again in ${_formatDuration(remaining)}.',
      );
    }

    // Lock expired, reset
    await _storage.delete(key: PinStorageKeys.pinLockedUntil);
    await _storage.write(key: PinStorageKeys.pinAttempts, value: '0');
    return null;
  }

  Future<PinVerificationResult> _handleFailedAttempt() async {
    final attemptsStr = await _storage.read(key: PinStorageKeys.pinAttempts) ?? '0';
    final attempts = (int.tryParse(attemptsStr) ?? 0) + 1;
    await _storage.write(key: PinStorageKeys.pinAttempts, value: attempts.toString());

    if (attempts >= PinConfig.maxAttempts) {
      // Lock the PIN
      final lockUntil = DateTime.now().add(PinConfig.lockoutDuration);
      await _storage.write(
        key: PinStorageKeys.pinLockedUntil,
        value: lockUntil.toIso8601String(),
      );

      return PinVerificationResult(
        success: false,
        isLocked: true,
        lockRemainingSeconds: PinConfig.lockoutDuration.inSeconds,
        message: 'Too many failed attempts. PIN locked for ${_formatDuration(PinConfig.lockoutDuration)}.',
      );
    }

    final remainingAttempts = PinConfig.maxAttempts - attempts;
    return PinVerificationResult(
      success: false,
      remainingAttempts: remainingAttempts,
      message: 'Incorrect PIN. $remainingAttempts attempt${remainingAttempts == 1 ? '' : 's'} remaining.',
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minute${duration.inMinutes == 1 ? '' : 's'}';
    }
    return '${duration.inSeconds} second${duration.inSeconds == 1 ? '' : 's'}';
  }
}

/// Result of PIN verification.
class PinVerificationResult {
  /// Whether verification succeeded.
  final bool success;

  /// Whether PIN is locked due to too many failures.
  final bool isLocked;

  /// Remaining attempts before lockout.
  final int? remainingAttempts;

  /// Seconds remaining in lockout.
  final int? lockRemainingSeconds;

  /// Human-readable message.
  final String? message;

  PinVerificationResult({
    required this.success,
    this.isLocked = false,
    this.remainingAttempts,
    this.lockRemainingSeconds,
    this.message,
  });

  @override
  String toString() =>
      'PinVerificationResult(success: $success, isLocked: $isLocked, remaining: $remainingAttempts)';
}

/// Result of setting a PIN.
class SetPinResult {
  final bool success;
  final SetPinError? error;
  final String? message;

  SetPinResult({
    required this.success,
    this.error,
    this.message,
  });
}

/// Errors when setting a PIN.
enum SetPinError {
  validationFailed,
  storageError,
}

/// Result of changing a PIN.
class ChangePinResult {
  final bool success;
  final ChangePinError? error;
  final String? message;
  final bool isLocked;
  final int? lockRemainingSeconds;

  ChangePinResult({
    required this.success,
    this.error,
    this.message,
    this.isLocked = false,
    this.lockRemainingSeconds,
  });
}

/// Errors when changing a PIN.
enum ChangePinError {
  currentPinWrong,
  newPinInvalid,
}
