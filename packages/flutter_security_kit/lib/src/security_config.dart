import 'package:flutter/foundation.dart';

/// Security configuration for the Flutter Security Kit.
///
/// Configure security policies and behaviors globally:
///
/// ```dart
/// // Skip all security checks in debug mode (default)
/// SecurityConfig.skipInDebugMode = true;
///
/// // Enable strict mode (block on any threat)
/// SecurityConfig.defaultPolicy = CompromisedDevicePolicy.block;
///
/// // Allow emulators in development
/// SecurityConfig.allowEmulator = true;
/// ```
class SecurityConfig {
  SecurityConfig._();

  /// Skip security checks in debug mode.
  /// Default: true (recommended for development)
  static bool skipInDebugMode = true;

  /// Default policy for handling compromised devices.
  static CompromisedDevicePolicy defaultPolicy = CompromisedDevicePolicy.block;

  /// Allow running on emulators/simulators.
  /// Set to false in production for financial apps.
  static bool allowEmulator = kDebugMode;

  /// Allow running with debugger attached.
  /// Set to false in production for security-critical apps.
  static bool allowDebugger = kDebugMode;

  /// Attestation token validity duration.
  /// Cached attestation results are reused within this window.
  static Duration attestationValidityDuration = const Duration(hours: 1);

  /// Enable logging of security events.
  static bool enableLogging = kDebugMode;

  /// Custom threat handler callback.
  /// Called when threats are detected (for analytics, logging, etc.)
  static void Function(List<String> threats)? onThreatsDetected;

  /// Check if security checks should be performed.
  static bool get shouldPerformChecks {
    if (skipInDebugMode && kDebugMode) {
      return false;
    }
    return true;
  }
}

/// Policy for handling compromised devices.
enum CompromisedDevicePolicy {
  /// Block all functionality - show error and prevent usage.
  block,

  /// Warn user but allow limited functionality.
  /// Good for monitoring phase before enforcing strict policy.
  warn,

  /// Allow but log for monitoring.
  /// Useful for analytics and understanding user base.
  monitor,
}

/// Threat severity levels.
enum ThreatSeverity {
  /// Critical - immediate security risk (root, jailbreak, tampered app).
  critical,

  /// High - significant risk (debugger, hooking framework).
  high,

  /// Medium - potential risk (emulator, unusual environment).
  medium,

  /// Low - informational (outdated OS, developer mode).
  low,
}

/// Represents a detected security threat.
class SecurityThreat {
  /// Threat identifier.
  final String id;

  /// Human-readable description.
  final String description;

  /// Severity level.
  final ThreatSeverity severity;

  /// Platform-specific details.
  final Map<String, dynamic>? metadata;

  const SecurityThreat({
    required this.id,
    required this.description,
    required this.severity,
    this.metadata,
  });

  @override
  String toString() => 'SecurityThreat($id: $description [$severity])';

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'severity': severity.name,
        'metadata': metadata,
      };
}

/// Common threat identifiers.
class ThreatIds {
  ThreatIds._();

  // Root/Jailbreak
  static const String rootBinary = 'root_binary';
  static const String rootManagementApp = 'root_management_app';
  static const String jailbreakIndicator = 'jailbreak_indicator';
  static const String writableSystem = 'writable_system';
  static const String sandboxEscape = 'sandbox_escape';

  // Debug/Development
  static const String debuggerAttached = 'debugger_attached';
  static const String emulator = 'emulator';
  static const String developerMode = 'developer_mode';

  // Tampering
  static const String appTampered = 'app_tampered';
  static const String hookingFramework = 'hooking_framework';
  static const String reverseEngineering = 'reverse_engineering';

  // Environment
  static const String unsafeEnvironment = 'unsafe_environment';
  static const String busybox = 'busybox';
}
