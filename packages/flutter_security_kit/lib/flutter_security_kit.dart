/// Flutter Security Kit
///
/// Security utilities for Flutter applications including:
/// - Device security checks (root/jailbreak detection)
/// - Device attestation (Play Integrity API / App Attest)
/// - Screenshot protection
/// - Secure storage helpers
///
/// ## Quick Start
///
/// ```dart
/// import 'package:flutter_security_kit/flutter_security_kit.dart';
///
/// // Check device security
/// final security = DeviceSecurity();
/// final result = await security.checkSecurity();
/// if (!result.isSecure) {
///   print('Threats: ${result.threats}');
/// }
///
/// // Device attestation
/// final attestation = DeviceAttestation();
/// final attestResult = await attestation.attestDevice();
/// if (attestResult.isValid) {
///   print('Token: ${attestResult.token}');
/// }
/// ```
library flutter_security_kit;

export 'package:flutter_security_kit/src/device_security.dart';
export 'package:flutter_security_kit/src/device_attestation.dart';
export 'package:flutter_security_kit/src/screenshot_protection.dart';
export 'package:flutter_security_kit/src/security_config.dart';
