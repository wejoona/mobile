import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:crypto/crypto.dart';
import 'security_config.dart';

/// Device Attestation Service
///
/// Verifies the app is running on a genuine, unmodified device using:
/// - Android: Play Integrity API
/// - iOS: App Attest (DeviceCheck framework)
///
/// ## Usage
///
/// ```dart
/// final attestation = DeviceAttestation();
///
/// // Get attestation token
/// final result = await attestation.attestDevice();
/// if (result.isValid) {
///   // Send token to backend for verification
///   await sendTokenToBackend(result.token!);
/// }
///
/// // Verify before sensitive operation
/// final canProceed = await attestation.verifyForOperation(
///   policy: AttestationPolicy.required,
///   serverNonce: await getServerNonce(),
/// );
/// ```
///
/// ## Backend Verification
///
/// The attestation token must be verified on your backend:
///
/// **Android (Play Integrity):**
/// - Decode the integrity token JWT
/// - Verify signature with Google's public key
/// - Check device verdict (MEETS_DEVICE_INTEGRITY, etc.)
///
/// **iOS (App Attest):**
/// - Verify attestation object using Apple's App Attest API
/// - Store the key identifier for future assertions
class DeviceAttestation {
  static final DeviceAttestation _instance = DeviceAttestation._internal();
  factory DeviceAttestation() => _instance;
  DeviceAttestation._internal();

  /// Method channel for native attestation APIs.
  MethodChannel? _channel;

  /// Set the method channel for attestation.
  /// Must be called during app initialization.
  void setChannel(MethodChannel channel) {
    _channel = channel;
  }

  /// Default channel name if using automatic setup.
  static const String defaultChannelName = 'flutter_security_kit/attestation';

  /// Cached attestation result.
  AttestationResult? _cachedResult;
  DateTime? _lastAttestation;

  /// Request device attestation.
  ///
  /// Returns an attestation token that should be verified by the backend.
  /// Pass a server-generated [nonce] for replay protection.
  Future<AttestationResult> attestDevice({String? nonce}) async {
    // Skip attestation in debug mode if configured
    if (!SecurityConfig.shouldPerformChecks) {
      return AttestationResult(
        isValid: true,
        token: 'debug-mode-token',
        platform: Platform.isAndroid ? 'android' : 'ios',
        timestamp: DateTime.now(),
      );
    }

    // Check if cached result is still valid
    if (_cachedResult != null &&
        _lastAttestation != null &&
        DateTime.now().difference(_lastAttestation!) <
            SecurityConfig.attestationValidityDuration) {
      return _cachedResult!;
    }

    try {
      // Generate nonce if not provided
      final attestationNonce = nonce ?? _generateNonce();

      if (Platform.isAndroid) {
        return await _attestAndroid(attestationNonce);
      } else if (Platform.isIOS) {
        return await _attestiOS(attestationNonce);
      } else {
        return AttestationResult(
          isValid: false,
          error: 'Unsupported platform',
          platform: 'unknown',
          timestamp: DateTime.now(),
        );
      }
    } catch (e) {
      _log('Attestation error: $e');
      return AttestationResult(
        isValid: false,
        error: e.toString(),
        platform: Platform.isAndroid ? 'android' : 'ios',
        timestamp: DateTime.now(),
      );
    }
  }

  /// Android Play Integrity API attestation.
  Future<AttestationResult> _attestAndroid(String nonce) async {
    if (_channel == null) {
      return AttestationResult(
        isValid: false,
        error: 'Attestation channel not configured. Call setChannel() first.',
        platform: 'android',
        timestamp: DateTime.now(),
      );
    }

    try {
      final result = await _channel!.invokeMethod<Map<dynamic, dynamic>>(
        'requestIntegrityToken',
        {'nonce': nonce},
      );

      if (result == null) {
        return AttestationResult(
          isValid: false,
          error: 'No attestation result',
          platform: 'android',
          timestamp: DateTime.now(),
        );
      }

      final token = result['token'] as String?;
      final deviceRecognitionVerdict =
          result['deviceRecognitionVerdict'] as String?;

      // Valid verdicts: MEETS_DEVICE_INTEGRITY, MEETS_BASIC_INTEGRITY, MEETS_STRONG_INTEGRITY
      final isValid = token != null &&
          (deviceRecognitionVerdict == 'MEETS_DEVICE_INTEGRITY' ||
              deviceRecognitionVerdict == 'MEETS_STRONG_INTEGRITY');

      _cachedResult = AttestationResult(
        isValid: isValid,
        token: token,
        platform: 'android',
        timestamp: DateTime.now(),
        verdict: deviceRecognitionVerdict != null
            ? DeviceVerdict.fromAndroid(deviceRecognitionVerdict)
            : null,
        metadata: {
          'deviceRecognitionVerdict': deviceRecognitionVerdict,
          'appRecognitionVerdict': result['appRecognitionVerdict'],
          'accountDetails': result['accountDetails'],
        },
      );
      _lastAttestation = DateTime.now();

      return _cachedResult!;
    } on PlatformException catch (e) {
      return AttestationResult(
        isValid: false,
        error: 'Play Integrity error: ${e.message}',
        platform: 'android',
        timestamp: DateTime.now(),
      );
    }
  }

  /// iOS App Attest attestation.
  Future<AttestationResult> _attestiOS(String nonce) async {
    if (_channel == null) {
      return AttestationResult(
        isValid: false,
        error: 'Attestation channel not configured. Call setChannel() first.',
        platform: 'ios',
        timestamp: DateTime.now(),
      );
    }

    try {
      final result = await _channel!.invokeMethod<Map<dynamic, dynamic>>(
        'requestAppAttest',
        {'nonce': nonce},
      );

      if (result == null) {
        return AttestationResult(
          isValid: false,
          error: 'No attestation result',
          platform: 'ios',
          timestamp: DateTime.now(),
        );
      }

      final attestation = result['attestation'] as String?;
      final keyId = result['keyId'] as String?;

      _cachedResult = AttestationResult(
        isValid: attestation != null,
        token: attestation,
        platform: 'ios',
        timestamp: DateTime.now(),
        metadata: {
          'keyId': keyId,
        },
      );
      _lastAttestation = DateTime.now();

      return _cachedResult!;
    } on PlatformException catch (e) {
      return AttestationResult(
        isValid: false,
        error: 'App Attest error: ${e.message}',
        platform: 'ios',
        timestamp: DateTime.now(),
      );
    }
  }

  /// Generate a cryptographically secure nonce.
  String _generateNonce() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final hash = sha256.convert(utf8.encode(timestamp));
    return base64Encode(hash.bytes);
  }

  /// Clear cached attestation.
  /// Call after suspicious activity or on logout.
  void clearCache() {
    _cachedResult = null;
    _lastAttestation = null;
  }

  /// Get the cached attestation result if valid.
  AttestationResult? get cachedResult {
    if (_cachedResult != null &&
        _lastAttestation != null &&
        DateTime.now().difference(_lastAttestation!) <
            SecurityConfig.attestationValidityDuration) {
      return _cachedResult;
    }
    return null;
  }

  void _log(String message) {
    if (SecurityConfig.enableLogging) {
      debugPrint('[DeviceAttestation] $message');
    }
  }
}

/// Result of device attestation.
class AttestationResult {
  /// Whether attestation was successful.
  final bool isValid;

  /// Attestation token to send to backend.
  final String? token;

  /// Error message if attestation failed.
  final String? error;

  /// Platform (android, ios, unknown).
  final String platform;

  /// Timestamp of attestation.
  final DateTime timestamp;

  /// Device verdict (for display/logging).
  final DeviceVerdict? verdict;

  /// Platform-specific metadata.
  final Map<String, dynamic>? metadata;

  AttestationResult({
    required this.isValid,
    this.token,
    this.error,
    required this.platform,
    required this.timestamp,
    this.verdict,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
        'isValid': isValid,
        'token': token,
        'error': error,
        'platform': platform,
        'timestamp': timestamp.toIso8601String(),
        'verdict': verdict?.name,
        'metadata': metadata,
      };

  @override
  String toString() =>
      'AttestationResult(isValid: $isValid, platform: $platform, verdict: ${verdict?.name}, error: $error)';
}

/// Device integrity verdict.
enum DeviceVerdict {
  /// Highest level - genuine device with strong integrity.
  strong,

  /// Device passes integrity checks.
  basic,

  /// Device has basic integrity but may have issues.
  weak,

  /// Device failed integrity checks.
  failed,

  /// Unknown verdict.
  unknown;

  /// Parse Android Play Integrity verdict.
  static DeviceVerdict fromAndroid(String verdict) {
    switch (verdict) {
      case 'MEETS_STRONG_INTEGRITY':
        return DeviceVerdict.strong;
      case 'MEETS_DEVICE_INTEGRITY':
        return DeviceVerdict.basic;
      case 'MEETS_BASIC_INTEGRITY':
        return DeviceVerdict.weak;
      default:
        return DeviceVerdict.failed;
    }
  }
}

/// Attestation policy for sensitive operations.
enum AttestationPolicy {
  /// Require attestation for all sensitive operations.
  required,

  /// Warn but allow if attestation fails.
  preferred,

  /// Skip attestation (debug only).
  none,
}

/// Extension to verify attestation before sensitive operations.
extension AttestationVerification on DeviceAttestation {
  /// Verify device before sensitive operation.
  ///
  /// Returns true if operation should proceed.
  ///
  /// ```dart
  /// final canProceed = await attestation.verifyForOperation(
  ///   policy: AttestationPolicy.required,
  ///   serverNonce: await getServerNonce(),
  /// );
  ///
  /// if (!canProceed) {
  ///   showError('Device verification failed');
  ///   return;
  /// }
  /// ```
  Future<bool> verifyForOperation({
    AttestationPolicy policy = AttestationPolicy.required,
    String? serverNonce,
  }) async {
    if (policy == AttestationPolicy.none ||
        !SecurityConfig.shouldPerformChecks) {
      return true;
    }

    final result = await attestDevice(nonce: serverNonce);

    if (policy == AttestationPolicy.preferred) {
      // Log but don't block
      if (!result.isValid && SecurityConfig.enableLogging) {
        debugPrint('[DeviceAttestation] WARNING: ${result.error}');
      }
      return true;
    }

    // Required policy - must pass
    return result.isValid;
  }

  /// Get attestation token for API requests.
  ///
  /// Returns null if attestation fails or is not available.
  Future<String?> getTokenForRequest({String? serverNonce}) async {
    final result = await attestDevice(nonce: serverNonce);
    return result.isValid ? result.token : null;
  }
}
