import 'dart:io';
import 'package:flutter/foundation.dart';
import 'security_config.dart';

/// Device Security Service
///
/// Detects security threats on the device including:
/// - Rooted Android devices
/// - Jailbroken iOS devices
/// - Attached debuggers
/// - Emulators/simulators
/// - Tampering indicators
///
/// ## Usage
///
/// ```dart
/// final security = DeviceSecurity();
///
/// // Full security check
/// final result = await security.checkSecurity();
/// if (!result.isSecure) {
///   print('Threats detected: ${result.threats}');
/// }
///
/// // Quick check with cached result
/// if (security.isCompromised) {
///   // Handle compromised device
/// }
///
/// // Enforce policy
/// final canProceed = await security.enforcePolicy(
///   policy: CompromisedDevicePolicy.block,
///   onCompromised: (result) => showBlockedDialog(),
/// );
/// ```
class DeviceSecurity {
  static final DeviceSecurity _instance = DeviceSecurity._internal();
  factory DeviceSecurity() => _instance;
  DeviceSecurity._internal();

  // Cache the result to avoid repeated checks
  bool? _isCompromised;
  List<SecurityThreat>? _detectedThreats;
  DateTime? _lastCheck;

  /// How long to cache security check results.
  static const Duration cacheValidity = Duration(minutes: 5);

  /// Check if device security is compromised.
  ///
  /// Returns [DeviceSecurityResult] with detailed threat information.
  /// Results are cached for [cacheValidity] duration.
  Future<DeviceSecurityResult> checkSecurity({bool forceRefresh = false}) async {
    // Skip checks if configured
    if (!SecurityConfig.shouldPerformChecks) {
      return DeviceSecurityResult(
        isSecure: true,
        threats: [],
        message: 'Security checks skipped (debug mode)',
      );
    }

    // Return cached result if valid
    if (!forceRefresh &&
        _lastCheck != null &&
        DateTime.now().difference(_lastCheck!) < cacheValidity &&
        _detectedThreats != null) {
      return DeviceSecurityResult(
        isSecure: _detectedThreats!.isEmpty,
        threats: _detectedThreats!,
        message: _detectedThreats!.isEmpty
            ? 'Device security verified (cached)'
            : 'Security threats detected: ${_detectedThreats!.length}',
      );
    }

    final threats = <SecurityThreat>[];

    if (Platform.isAndroid) {
      threats.addAll(await _checkAndroidRoot());
    } else if (Platform.isIOS) {
      threats.addAll(await _checkiOSJailbreak());
    }

    // Check for debugger
    if (!SecurityConfig.allowDebugger && await _isDebuggerAttached()) {
      threats.add(const SecurityThreat(
        id: ThreatIds.debuggerAttached,
        description: 'Debugger attached',
        severity: ThreatSeverity.high,
      ));
    }

    // Check for emulator/simulator
    if (!SecurityConfig.allowEmulator && await _isEmulator()) {
      threats.add(const SecurityThreat(
        id: ThreatIds.emulator,
        description: 'Running on emulator/simulator',
        severity: ThreatSeverity.medium,
      ));
    }

    _isCompromised = threats.isNotEmpty;
    _detectedThreats = threats;
    _lastCheck = DateTime.now();

    // Notify threat handler if configured
    if (threats.isNotEmpty) {
      SecurityConfig.onThreatsDetected
          ?.call(threats.map((t) => t.description).toList());
    }

    return DeviceSecurityResult(
      isSecure: threats.isEmpty,
      threats: threats,
      message: threats.isEmpty
          ? 'Device security verified'
          : 'Security threats detected: ${threats.length}',
    );
  }

  /// Quick check using cached result.
  bool get isCompromised => _isCompromised ?? false;

  /// Get detected threats (from cache).
  List<SecurityThreat> get detectedThreats => _detectedThreats ?? [];

  /// Clear cached security check results.
  void clearCache() {
    _isCompromised = null;
    _detectedThreats = null;
    _lastCheck = null;
  }

  /// Check for Android root indicators.
  Future<List<SecurityThreat>> _checkAndroidRoot() async {
    final threats = <SecurityThreat>[];

    // Check for su binary in common locations
    final suPaths = [
      '/system/bin/su',
      '/system/xbin/su',
      '/sbin/su',
      '/system/su',
      '/system/bin/.ext/.su',
      '/system/usr/we-need-root/su-backup',
      '/system/xbin/mu',
      '/data/local/xbin/su',
      '/data/local/bin/su',
      '/data/local/su',
      '/su/bin/su',
      '/su/bin',
      '/magisk/.core/bin/su',
    ];

    for (final path in suPaths) {
      if (await _fileExists(path)) {
        threats.add(SecurityThreat(
          id: ThreatIds.rootBinary,
          description: 'Root binary found',
          severity: ThreatSeverity.critical,
          metadata: {'path': path},
        ));
        break; // One is enough to flag
      }
    }

    // Check for root management apps
    final rootApps = [
      '/system/app/Superuser.apk',
      '/system/app/SuperSU.apk',
      '/system/app/Magisk.apk',
      '/data/data/com.noshufou.android.su',
      '/data/data/com.thirdparty.superuser',
      '/data/data/eu.chainfire.supersu',
      '/data/data/com.koushikdutta.superuser',
      '/data/data/com.zachspong.temprootremovejb',
      '/data/data/com.ramdroid.appquarantine',
      '/data/data/com.topjohnwu.magisk',
    ];

    for (final path in rootApps) {
      if (await _fileExists(path)) {
        threats.add(const SecurityThreat(
          id: ThreatIds.rootManagementApp,
          description: 'Root management app found',
          severity: ThreatSeverity.critical,
        ));
        break;
      }
    }

    // Check for busybox
    final busyboxPaths = [
      '/system/xbin/busybox',
      '/system/bin/busybox',
      '/sbin/busybox',
      '/system/sd/xbin/busybox',
    ];

    for (final path in busyboxPaths) {
      if (await _fileExists(path)) {
        threats.add(const SecurityThreat(
          id: ThreatIds.busybox,
          description: 'Busybox found',
          severity: ThreatSeverity.medium,
        ));
        break;
      }
    }

    // Check if /system is writable (indicates tampering)
    try {
      final testFile =
          '/system/.security_test_${DateTime.now().millisecondsSinceEpoch}';
      final file = File(testFile);
      await file.writeAsString('test');
      await file.delete();
      threats.add(const SecurityThreat(
        id: ThreatIds.writableSystem,
        description: 'System partition is writable',
        severity: ThreatSeverity.critical,
      ));
    } catch (_) {
      // Expected - system should not be writable
    }

    return threats;
  }

  /// Check for iOS jailbreak indicators.
  Future<List<SecurityThreat>> _checkiOSJailbreak() async {
    final threats = <SecurityThreat>[];

    // Check for jailbreak files
    final jailbreakPaths = [
      '/Applications/Cydia.app',
      '/Applications/Sileo.app',
      '/Applications/Zebra.app',
      '/Applications/blackra1n.app',
      '/Applications/FakeCarrier.app',
      '/Applications/Icy.app',
      '/Applications/IntelliScreen.app',
      '/Applications/MxTube.app',
      '/Applications/RockApp.app',
      '/Applications/SBSettings.app',
      '/Applications/WinterBoard.app',
      '/Library/MobileSubstrate/MobileSubstrate.dylib',
      '/Library/MobileSubstrate/DynamicLibraries',
      '/bin/bash',
      '/bin/sh',
      '/etc/apt',
      '/etc/ssh/sshd_config',
      '/private/var/lib/apt/',
      '/private/var/lib/cydia',
      '/private/var/mobile/Library/SBSettings/Themes',
      '/private/var/stash',
      '/private/var/tmp/cydia.log',
      '/usr/bin/ssh',
      '/usr/bin/sshd',
      '/usr/libexec/sftp-server',
      '/usr/libexec/ssh-keysign',
      '/usr/sbin/sshd',
      '/var/cache/apt',
      '/var/lib/cydia',
      '/var/log/syslog',
      '/var/tmp/cydia.log',
      '/usr/sbin/frida-server',
      '/usr/bin/cycript',
      '/usr/local/bin/cycript',
    ];

    for (final path in jailbreakPaths) {
      if (await _fileExists(path)) {
        threats.add(SecurityThreat(
          id: ThreatIds.jailbreakIndicator,
          description: 'Jailbreak indicator found',
          severity: ThreatSeverity.critical,
          metadata: {'path': path},
        ));
        break;
      }
    }

    // Check for hooking frameworks
    final hookingFrameworks = [
      '/usr/sbin/frida-server',
      '/usr/bin/cycript',
      '/usr/local/bin/cycript',
    ];

    for (final path in hookingFrameworks) {
      if (await _fileExists(path)) {
        threats.add(SecurityThreat(
          id: ThreatIds.hookingFramework,
          description: 'Hooking framework detected',
          severity: ThreatSeverity.critical,
          metadata: {'framework': path.split('/').last},
        ));
        break;
      }
    }

    // Check if can write outside sandbox
    try {
      final testFile =
          '/private/.security_test_${DateTime.now().millisecondsSinceEpoch}';
      final file = File(testFile);
      await file.writeAsString('test');
      await file.delete();
      threats.add(const SecurityThreat(
        id: ThreatIds.sandboxEscape,
        description: 'Can write outside sandbox',
        severity: ThreatSeverity.critical,
      ));
    } catch (_) {
      // Expected - should not be able to write outside sandbox
    }

    return threats;
  }

  /// Check if debugger is attached.
  Future<bool> _isDebuggerAttached() async {
    bool debuggerAttached = false;
    assert(() {
      debuggerAttached = true;
      return true;
    }());
    return debuggerAttached;
  }

  /// Check if running on emulator/simulator.
  Future<bool> _isEmulator() async {
    if (Platform.isAndroid) {
      // Check for emulator indicators
      final emulatorFiles = [
        '/dev/socket/qemud',
        '/dev/qemu_pipe',
        '/system/lib/libc_malloc_debug_qemu.so',
        '/sys/qemu_trace',
        '/system/bin/qemu-props',
      ];

      for (final path in emulatorFiles) {
        if (await _fileExists(path)) {
          return true;
        }
      }
    }

    // iOS simulator detection would require native code
    return false;
  }

  /// Helper to check if file exists.
  Future<bool> _fileExists(String path) async {
    try {
      return await File(path).exists();
    } catch (_) {
      return false;
    }
  }
}

/// Result of device security check.
class DeviceSecurityResult {
  /// Whether the device passed all security checks.
  final bool isSecure;

  /// List of detected security threats.
  final List<SecurityThreat> threats;

  /// Human-readable message.
  final String message;

  /// Timestamp of the check.
  final DateTime timestamp;

  DeviceSecurityResult({
    required this.isSecure,
    required this.threats,
    required this.message,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Get threats by severity.
  List<SecurityThreat> threatsBySeverity(ThreatSeverity severity) {
    return threats.where((t) => t.severity == severity).toList();
  }

  /// Check if any critical threats were detected.
  bool get hasCriticalThreats =>
      threats.any((t) => t.severity == ThreatSeverity.critical);

  @override
  String toString() =>
      'DeviceSecurityResult(isSecure: $isSecure, threats: ${threats.length})';

  Map<String, dynamic> toJson() => {
        'isSecure': isSecure,
        'threats': threats.map((t) => t.toJson()).toList(),
        'message': message,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// Extension for policy enforcement.
extension DeviceSecurityPolicyEnforcement on DeviceSecurity {
  /// Run security check and handle based on policy.
  ///
  /// Returns true if the app should proceed, false if blocked.
  ///
  /// ```dart
  /// final canProceed = await security.enforcePolicy(
  ///   policy: CompromisedDevicePolicy.block,
  ///   onCompromised: (result) => showBlockedDialog(result.threats),
  /// );
  ///
  /// if (!canProceed) {
  ///   return; // App should not continue
  /// }
  /// ```
  Future<bool> enforcePolicy({
    CompromisedDevicePolicy? policy,
    void Function(DeviceSecurityResult)? onCompromised,
  }) async {
    final effectivePolicy = policy ?? SecurityConfig.defaultPolicy;
    final result = await checkSecurity();

    if (!result.isSecure) {
      onCompromised?.call(result);

      switch (effectivePolicy) {
        case CompromisedDevicePolicy.block:
          _log('SECURITY BLOCKED: ${result.message}');
          return false;
        case CompromisedDevicePolicy.warn:
          _log('SECURITY WARNING: ${result.message}');
          return true;
        case CompromisedDevicePolicy.monitor:
          _log('SECURITY MONITOR: ${result.message}');
          return true;
      }
    }

    return true;
  }

  void _log(String message) {
    if (SecurityConfig.enableLogging) {
      debugPrint('[DeviceSecurity] $message');
    }
  }
}
