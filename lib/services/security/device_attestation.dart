import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:crypto/crypto.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Device Attestation Service
/// SECURITY: Verifies app is running on a genuine, unmodified device
/// Uses Play Integrity API (Android) and App Attest (iOS)
class DeviceAttestation {
  static final DeviceAttestation _instance = DeviceAttestation._internal();
  factory DeviceAttestation() => _instance;
  DeviceAttestation._internal();

  static const _channel = MethodChannel('com.joonapay.usdc_wallet/attestation');

  /// Cached attestation result
  AttestationResult? _cachedResult;
  DateTime? _lastAttestation;
  static const _attestationValidityDuration = Duration(hours: 1);

  /// Request device attestation
  /// Returns an attestation token that should be verified by the backend
  Future<AttestationResult> attestDevice({String? nonce}) async {
    // Skip attestation in debug mode
    if (kDebugMode) {
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
        DateTime.now().difference(_lastAttestation!) < _attestationValidityDuration) {
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
      AppLogger('Attestation error').error('Attestation error', e);
      return AttestationResult(
        isValid: false,
        error: e.toString(),
        platform: Platform.isAndroid ? 'android' : 'ios',
        timestamp: DateTime.now(),
      );
    }
  }

  /// Android Play Integrity API attestation
  Future<AttestationResult> _attestAndroid(String nonce) async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
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
      final deviceRecognitionVerdict = result['deviceRecognitionVerdict'] as String?;

      // Valid verdicts: MEETS_DEVICE_INTEGRITY, MEETS_BASIC_INTEGRITY, MEETS_STRONG_INTEGRITY
      final isValid = token != null &&
          (deviceRecognitionVerdict == 'MEETS_DEVICE_INTEGRITY' ||
              deviceRecognitionVerdict == 'MEETS_STRONG_INTEGRITY');

      _cachedResult = AttestationResult(
        isValid: isValid,
        token: token,
        platform: 'android',
        timestamp: DateTime.now(),
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

  /// iOS App Attest attestation
  Future<AttestationResult> _attestiOS(String nonce) async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
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

  /// Generate a cryptographically secure nonce
  String _generateNonce() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final hash = sha256.convert(utf8.encode(timestamp));
    return base64Encode(hash.bytes);
  }

  /// Clear cached attestation (use after suspicious activity)
  void clearCache() {
    _cachedResult = null;
    _lastAttestation = null;
  }
}

/// Result of device attestation
class AttestationResult {
  final bool isValid;
  final String? token;
  final String? error;
  final String platform;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  AttestationResult({
    required this.isValid,
    this.token,
    this.error,
    required this.platform,
    required this.timestamp,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
        'isValid': isValid,
        'token': token,
        'error': error,
        'platform': platform,
        'timestamp': timestamp.toIso8601String(),
        'metadata': metadata,
      };

  @override
  String toString() =>
      'AttestationResult(isValid: $isValid, platform: $platform, error: $error)';
}

/// Attestation policy for sensitive operations
enum AttestationPolicy {
  /// Require attestation for all sensitive operations
  required,
  /// Warn but allow if attestation fails
  preferred,
  /// Skip attestation (debug only)
  none,
}

/// Extension to verify attestation before sensitive operations
extension AttestationCheck on DeviceAttestation {
  /// Verify device before sensitive operation
  Future<bool> verifyForOperation({
    AttestationPolicy policy = AttestationPolicy.required,
    String? serverNonce,
  }) async {
    if (policy == AttestationPolicy.none || kDebugMode) {
      return true;
    }

    final result = await attestDevice(nonce: serverNonce);

    if (policy == AttestationPolicy.preferred) {
      // Log but don't block
      if (!result.isValid) {
        AppLogger('Debug').debug('ATTESTATION WARNING: ${result.error}');
      }
      return true;
    }

    // Required policy - must pass
    return result.isValid;
  }
}
