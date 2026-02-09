import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../features/settings/repositories/devices_repository.dart';
import '../../utils/logger.dart';

/// Service to collect device info and register with the backend
class DeviceRegistrationService {
  final DevicesRepository _devicesRepository;

  DeviceRegistrationService(this._devicesRepository);

  /// Register the current device with the backend.
  /// Should be called after successful OTP verification / login.
  Future<void> registerCurrentDevice() async {
    final logger = AppLogger('DeviceRegistration');

    try {
      final deviceInfo = DeviceInfoPlugin();
      final packageInfo = await PackageInfo.fromPlatform();

      String deviceId;
      String platform;
      String? model;
      String? brand;
      String? osVersion;

      if (Platform.isIOS) {
        final ios = await deviceInfo.iosInfo;
        deviceId = ios.identifierForVendor ?? 'unknown-ios';
        platform = 'ios';
        model = ios.utsname.machine;
        brand = 'Apple';
        osVersion = ios.systemVersion;
      } else if (Platform.isAndroid) {
        final android = await deviceInfo.androidInfo;
        deviceId = android.id;
        platform = 'android';
        model = android.model;
        brand = android.brand;
        osVersion = android.version.release;
      } else {
        logger.debug('Unsupported platform for device registration');
        return;
      }

      // Get FCM token (may be null if Firebase not configured)
      String? fcmToken;
      try {
        fcmToken = await FirebaseMessaging.instance.getToken();
      } catch (e) {
        logger.debug('Could not get FCM token: $e');
      }

      // Get locale
      final locale = Platform.localeName;

      await _devicesRepository.registerDevice(
        deviceId: deviceId,
        platform: platform,
        model: model,
        brand: brand,
        osVersion: osVersion,
        appVersion: packageInfo.version,
        fcmToken: fcmToken,
        locale: locale,
      );

      logger.info('Device registered successfully');
    } catch (e) {
      // Don't fail login if device registration fails
      logger.error('Device registration failed', e);
    }
  }
}

/// Provider for DeviceRegistrationService
final deviceRegistrationServiceProvider = Provider<DeviceRegistrationService>((ref) {
  final devicesRepo = ref.watch(devicesRepositoryProvider);
  return DeviceRegistrationService(devicesRepo);
});
