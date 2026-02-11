import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Central security configuration.
class SecurityConfig {
  static const _tag = 'SecurityConfig';
  final bool enforceSSLPinning;
  final bool enableMitMDetection;
  final bool enableVpnDetection;
  final bool enableScreenshotProtection;
  final bool enableBiometricAuth;
  final int maxLoginAttempts;
  final Duration sessionTimeout;
  final Duration mfaCooldown;
  final double stepUpThreshold;

  const SecurityConfig({
    this.enforceSSLPinning = true,
    this.enableMitMDetection = true,
    this.enableVpnDetection = true,
    this.enableScreenshotProtection = true,
    this.enableBiometricAuth = true,
    this.maxLoginAttempts = 5,
    this.sessionTimeout = const Duration(minutes: 15),
    this.mfaCooldown = const Duration(seconds: 60),
    this.stepUpThreshold = 100000,
  });

  /// Debug config with relaxed security.
  factory SecurityConfig.debug() => const SecurityConfig(
    enforceSSLPinning: false,
    enableMitMDetection: false,
    enableVpnDetection: false,
    enableScreenshotProtection: false,
  );
}

final securityConfigProvider = Provider<SecurityConfig>((ref) {
  return const SecurityConfig();
});
