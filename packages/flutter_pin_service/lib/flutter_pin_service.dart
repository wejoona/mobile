/// Flutter PIN Service
///
/// Secure PIN management for Flutter applications including:
/// - PIN hashing with PBKDF2 and salt
/// - Brute-force protection with configurable lockout
/// - Weak PIN detection and rejection
/// - Secure storage integration
///
/// ## Quick Start
///
/// ```dart
/// import 'package:flutter_pin_service/flutter_pin_service.dart';
///
/// final pinService = PinService();
///
/// // Set a PIN
/// await pinService.setPin('1234');
///
/// // Verify PIN
/// final result = await pinService.verifyPin('1234');
/// if (result.success) {
///   print('PIN verified!');
/// } else {
///   print('Error: ${result.message}');
/// }
/// ```
library flutter_pin_service;

export 'src/pin_service.dart';
export 'src/pin_config.dart';
export 'src/pin_hasher.dart';
export 'src/pin_validator.dart';
