import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/device/device_registration_service.dart';
import 'package:usdc_wallet/services/time/server_time_service.dart';
import 'package:usdc_wallet/services/security/device_integrity_service.dart';
import 'package:usdc_wallet/services/analytics/analytics_service.dart';
import 'package:usdc_wallet/services/security/tamper_detection_service.dart';

/// Application initialization service.
///
/// Handles all startup tasks in the correct order:
/// 1. System chrome setup
/// 2. Device registration
/// 3. Server time sync
/// 4. Feature flag fetch
/// 5. Push notification setup
class AppInitializer {
  final Ref _ref;

  AppInitializer(this._ref);

  /// Rapport d'intégrité — disponible après initialize()
  DeviceIntegrityReport? integrityReport;

  /// Whether the device was flagged as rooted/jailbroken.
  bool get isDeviceTampered =>
      _ref.read(tamperDetectionServiceProvider).isCompromised;

  /// Run all initialization tasks.
  Future<void> initialize() async {
    await _setupSystemChrome();
    await _initAnalytics();
    await _checkTamperDetection();
    await _checkDeviceIntegrity();
    await _syncServerTime();
    await _registerDevice();
    if (kDebugMode) {
      debugPrint('[AppInitializer] Initialization complete');
    }
  }

  Future<void> _checkTamperDetection() async {
    try {
      final tamperService = _ref.read(tamperDetectionServiceProvider);
      final compromised = await tamperService.check();
      if (compromised) {
        if (kDebugMode) {
          debugPrint('[AppInitializer] Device is rooted/jailbroken — will block');
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[AppInitializer] Tamper detection failed: $e');
    }
  }

  Future<void> _initAnalytics() async {
    try {
      final analytics = _ref.read(analyticsServiceProvider);
      await analytics.initialize();
    } catch (e) {
      if (kDebugMode) debugPrint('[AppInitializer] Analytics init failed: $e');
    }
  }

  Future<void> _checkDeviceIntegrity() async {
    try {
      final integrityService = _ref.read(deviceIntegrityServiceProvider);
      integrityReport = await integrityService.checkAll();
      if (kDebugMode && integrityReport != null && !integrityReport!.isSecure) {
        debugPrint('[AppInitializer] Device integrity warnings: ${integrityReport!.threats}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[AppInitializer] Device integrity check failed: $e');
    }
  }

  Future<void> _setupSystemChrome() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  Future<void> _syncServerTime() async {
    try {
      final serverTimeService = _ref.read(serverTimeServiceProvider);
      await serverTimeService.sync();
    } catch (e) {
      if (kDebugMode) debugPrint('[AppInitializer] Server time sync failed: $e');
    }
  }

  Future<void> _registerDevice() async {
    try {
      final deviceService = _ref.read(deviceRegistrationServiceProvider);
      await deviceService.registerCurrentDevice();
    } catch (e) {
      if (kDebugMode) debugPrint('[AppInitializer] Device registration failed: $e');
    }
  }
}

final appInitializerProvider = Provider<AppInitializer>((ref) {
  return AppInitializer(ref);
});
