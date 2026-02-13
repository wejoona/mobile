import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Device Security Service
/// SECURITY: Detects rooted/jailbroken devices and other security threats
/// Financial apps should not run on compromised devices
class DeviceSecurity {
  static final DeviceSecurity _instance = DeviceSecurity._internal();
  factory DeviceSecurity() => _instance;
  DeviceSecurity._internal();

  // Cache the result to avoid repeated checks
  bool? _isCompromised;
  List<String>? _detectedThreats;

  /// Check if device security is compromised
  /// Returns true if rooted (Android) or jailbroken (iOS)
  Future<DeviceSecurityResult> checkSecurity() async {
    // Skip checks in debug mode for development
    if (kDebugMode) {
      return DeviceSecurityResult(
        isSecure: true,
        threats: [],
        message: 'Security checks skipped in debug mode',
      );
    }

    final threats = <String>[];

    if (Platform.isAndroid) {
      threats.addAll(await _checkAndroidRoot());
    } else if (Platform.isIOS) {
      threats.addAll(await _checkiOSJailbreak());
    }

    // Check for debugger
    if (await _isDebuggerAttached()) {
      threats.add('Debugger attached');
    }

    // Check for emulator/simulator
    if (await _isEmulator()) {
      threats.add('Running on emulator/simulator');
    }

    _isCompromised = threats.isNotEmpty;
    _detectedThreats = threats;

    return DeviceSecurityResult(
      isSecure: threats.isEmpty,
      threats: threats,
      message: threats.isEmpty
          ? 'Device security verified'
          : 'Security threats detected: ${threats.join(', ')}',
    );
  }

  /// Quick check using cached result
  bool get isCompromised => _isCompromised ?? false;
  List<String> get detectedThreats => _detectedThreats ?? [];

  /// Check for Android root indicators
  Future<List<String>> _checkAndroidRoot() async {
    final threats = <String>[];

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
        threats.add('Root binary found: $path');
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
        threats.add('Root management app found');
        break;
      }
    }

    // Check for dangerous props (would need native code for full check)
    // Check for busybox
    final busyboxPaths = [
      '/system/xbin/busybox',
      '/system/bin/busybox',
      '/sbin/busybox',
      '/system/sd/xbin/busybox',
    ];

    for (final path in busyboxPaths) {
      if (await _fileExists(path)) {
        threats.add('Busybox found');
        break;
      }
    }

    // Check if /system is writable (indicates tampering)
    try {
      final testFile = '/system/.security_test_${DateTime.now().millisecondsSinceEpoch}';
      final file = File(testFile);
      await file.writeAsString('test');
      await file.delete();
      threats.add('System partition is writable');
    } catch (_) {
      // Expected - system should not be writable
    }

    return threats;
  }

  /// Check for iOS jailbreak indicators
  Future<List<String>> _checkiOSJailbreak() async {
    final threats = <String>[];

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
      '/etc/apt',
      '/private/var/lib/apt/',
      '/private/var/lib/cydia',
      '/private/var/mobile/Library/SBSettings/Themes',
      '/private/var/stash',
      '/private/var/tmp/cydia.log',
      '/var/cache/apt',
      '/var/lib/cydia',
      '/var/tmp/cydia.log',
      '/usr/sbin/frida-server',
      '/usr/bin/cycript',
      '/usr/local/bin/cycript',
    ];

    for (final path in jailbreakPaths) {
      if (await _fileExists(path)) {
        threats.add('Jailbreak indicator found: $path');
        break;
      }
    }

    // Check if can write outside sandbox
    try {
      final testFile = '/private/.security_test_${DateTime.now().millisecondsSinceEpoch}';
      final file = File(testFile);
      await file.writeAsString('test');
      await file.delete();
      threats.add('Can write outside sandbox');
    } catch (_) {
      // Expected - should not be able to write outside sandbox
    }

    // Check for URL schemes associated with jailbreak
    // Note: This would require native code to fully implement
    // canOpenURL for cydia://, sileo://, zebra://

    return threats;
  }

  /// Check if debugger is attached
  Future<bool> _isDebuggerAttached() async {
    // In release mode, assert is removed, so this is a simple check
    // For more robust detection, native code would be needed
    bool debuggerAttached = false;
    assert(() {
      debuggerAttached = true;
      return true;
    }());
    return debuggerAttached;
  }

  /// Check if running on emulator/simulator
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

      // Additional checks would require platform channels
      // to read Build.FINGERPRINT, Build.MODEL, etc.
    }

    // iOS simulator detection would require native code
    // to check ProcessInfo.processInfo.environment

    return false;
  }

  /// Helper to check if file exists
  Future<bool> _fileExists(String path) async {
    try {
      return await File(path).exists();
    } catch (_) {
      return false;
    }
  }
}

/// Result of device security check
class DeviceSecurityResult {
  final bool isSecure;
  final List<String> threats;
  final String message;

  DeviceSecurityResult({
    required this.isSecure,
    required this.threats,
    required this.message,
  });

  @override
  String toString() => 'DeviceSecurityResult(isSecure: $isSecure, threats: $threats)';
}

/// Security policy for handling compromised devices
enum CompromisedDevicePolicy {
  /// Block all functionality
  block,
  /// Warn user but allow limited functionality
  warn,
  /// Allow but log for monitoring
  monitor,
}

/// Extension for easy security checks in widgets
extension DeviceSecurityCheck on DeviceSecurity {
  /// Run security check and handle based on policy
  Future<bool> enforcePolicy({
    CompromisedDevicePolicy policy = CompromisedDevicePolicy.block,
    void Function(DeviceSecurityResult)? onCompromised,
  }) async {
    final result = await checkSecurity();

    if (!result.isSecure) {
      onCompromised?.call(result);

      switch (policy) {
        case CompromisedDevicePolicy.block:
          return false;
        case CompromisedDevicePolicy.warn:
          // Log and allow with warning
          AppLogger('Debug').debug('SECURITY WARNING: ${result.message}');
          return true;
        case CompromisedDevicePolicy.monitor:
          // Just log
          AppLogger('Debug').debug('SECURITY MONITOR: ${result.message}');
          return true;
      }
    }

    return true;
  }
}
