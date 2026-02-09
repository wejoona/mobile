import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../biometric/biometric_service.dart';
import 'device_security.dart';

/// Collected device fingerprint data sent to backend
class DeviceFingerprint {
  final String deviceId;
  final String fingerprintHash;
  final String? brand;
  final String? model;
  final String os;
  final String? osVersion;
  final String appVersion;
  final String? buildNumber;
  final String locale;
  final double screenWidth;
  final double screenHeight;
  final bool isPhysicalDevice;
  final bool isCompromised;
  final bool biometricsAvailable;
  final String platform;

  const DeviceFingerprint({
    required this.deviceId,
    required this.fingerprintHash,
    this.brand,
    this.model,
    required this.os,
    this.osVersion,
    required this.appVersion,
    this.buildNumber,
    required this.locale,
    required this.screenWidth,
    required this.screenHeight,
    required this.isPhysicalDevice,
    required this.isCompromised,
    required this.biometricsAvailable,
    required this.platform,
  });

  Map<String, dynamic> toJson() => {
        'deviceId': deviceId,
        'fingerprintHash': fingerprintHash,
        'brand': brand,
        'model': model,
        'os': os,
        'osVersion': osVersion,
        'appVersion': appVersion,
        'buildNumber': buildNumber,
        'locale': locale,
        'screenWidth': screenWidth,
        'screenHeight': screenHeight,
        'isPhysicalDevice': isPhysicalDevice,
        'isCompromised': isCompromised,
        'biometricsAvailable': biometricsAvailable,
        'platform': platform,
      };
}

/// Service that collects device fingerprint data for security tracking.
///
/// Gathers device model, OS, screen size, jailbreak/root status,
/// biometrics availability, and produces a stable fingerprint hash.
class DeviceFingerprintService {
  final BiometricService _biometricService;

  DeviceFingerprintService({required BiometricService biometricService})
      : _biometricService = biometricService;

  DeviceFingerprint? _cached;

  /// Collect full device fingerprint. Cached after first call.
  Future<DeviceFingerprint> collect() async {
    if (_cached != null) return _cached!;

    final deviceInfo = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();

    String deviceId;
    String? brand;
    String? model;
    String os;
    String? osVersion;
    bool isPhysical = true;

    if (Platform.isIOS) {
      final info = await deviceInfo.iosInfo;
      deviceId = info.identifierForVendor ?? 'unknown-ios';
      brand = 'Apple';
      model = info.utsname.machine;
      os = 'iOS';
      osVersion = info.systemVersion;
      isPhysical = info.isPhysicalDevice;
    } else if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      deviceId = info.id;
      brand = info.brand;
      model = info.model;
      os = 'Android';
      osVersion = info.version.release;
      isPhysical = info.isPhysicalDevice;
    } else {
      deviceId = 'unknown';
      os = Platform.operatingSystem;
      osVersion = Platform.operatingSystemVersion;
    }

    // Screen size from Flutter window
    final window = PlatformDispatcher.instance.views.first;
    final screenWidth = window.physicalSize.width / window.devicePixelRatio;
    final screenHeight = window.physicalSize.height / window.devicePixelRatio;

    // Device security check (jailbreak/root)
    final security = DeviceSecurity();
    final securityResult = await security.checkSecurity();

    // Biometrics
    final biometricsAvailable = await _biometricService.isDeviceSupported();

    // Generate stable fingerprint hash from immutable device properties
    final fingerprintSource = '$deviceId|$brand|$model|$os|'
        '${screenWidth.toInt()}x${screenHeight.toInt()}';
    final fingerprintHash =
        sha256.convert(utf8.encode(fingerprintSource)).toString();

    _cached = DeviceFingerprint(
      deviceId: deviceId,
      fingerprintHash: fingerprintHash,
      brand: brand,
      model: model,
      os: os,
      osVersion: osVersion,
      appVersion: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
      locale: PlatformDispatcher.instance.locale.toString(),
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      isPhysicalDevice: isPhysical,
      isCompromised: !securityResult.isSecure,
      biometricsAvailable: biometricsAvailable,
      platform: Platform.isIOS ? 'ios' : 'android',
    );

    return _cached!;
  }

  /// Get cached device ID quickly (returns null if not yet collected).
  String? get cachedDeviceId => _cached?.deviceId;

  /// Get cached fingerprint hash quickly.
  String? get cachedFingerprintHash => _cached?.fingerprintHash;

  /// Clear cache (e.g. on logout).
  void clearCache() => _cached = null;
}

/// Provider for DeviceFingerprintService
final deviceFingerprintServiceProvider =
    Provider<DeviceFingerprintService>((ref) {
  return DeviceFingerprintService(
    biometricService: ref.watch(biometricServiceProvider),
  );
});
