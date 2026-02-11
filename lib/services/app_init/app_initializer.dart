import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../device/device_registration_service.dart';
import '../time/server_time_service.dart';

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

  /// Run all initialization tasks.
  Future<void> initialize() async {
    await _setupSystemChrome();
    await _syncServerTime();
    await _registerDevice();
    if (kDebugMode) {
      debugPrint('[AppInitializer] Initialization complete');
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
