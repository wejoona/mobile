import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:usdc_wallet/features/settings/repositories/devices_repository.dart';
import 'package:usdc_wallet/mocks/mock_config.dart';
import 'package:usdc_wallet/utils/device_names.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Service to collect device info and register with the backend
class DeviceRegistrationService {
  DeviceRegistrationService(this._devicesRepository);
  final DevicesRepository _devicesRepository;

  /// Register the current device with the backend.
  /// Should be called after successful OTP verification / login.
  Future<void> registerCurrentDevice() async {
    const logger = AppLogger('DeviceRegistration');

    try {
      final deviceInfo = DeviceInfoPlugin();
      final packageInfo = await PackageInfo.fromPlatform();

      String deviceId;
      String platform;
      String? model;
      String? brand;
      String? os;
      String? osVersion;
      String? deviceName;

      if (Platform.isIOS) {
        final ios = await deviceInfo.iosInfo;
        deviceId = ios.identifierForVendor ?? 'unknown-ios';
        platform = 'ios';
        deviceName = ios.name; // e.g. "Ben's iPhone 16 Pro Max"
        model = ios.utsname.machine;
        brand = 'Apple';
        os = 'iOS';
        osVersion = ios.systemVersion;
      } else if (Platform.isAndroid) {
        final android = await deviceInfo.androidInfo;
        deviceId = android.id;
        platform = 'android';
        model = androidModelName(android.brand, android.model);
        deviceName = model;
        brand = android.brand;
        os = 'Android';
        osVersion = android.version.release;
      } else {
        logger.debug('Unsupported platform for device registration');
        return;
      }

      // Get FCM token (may be null if Firebase not configured)
      String? fcmToken;
      if (!MockConfig.useMocks) {
        try {
          fcmToken = await FirebaseMessaging.instance.getToken();
        } on Object catch (error) {
          logger.debug('Could not get FCM token: $error');
        }
      }

      // Get locale
      final locale = Platform.localeName;

      await _devicesRepository.registerDevice(
        deviceId: deviceId,
        platform: platform,
        deviceName: deviceName,
        model: model,
        brand: brand,
        os: os,
        osVersion: osVersion,
        appVersion: packageInfo.version,
        fcmToken: fcmToken,
        locale: locale,
      );

      logger.info('Device registered successfully');
    } on Object catch (error) {
      // Don't fail login if device registration fails
      logger.error('Device registration failed', error);
    }
  }
}

/// Provider for DeviceRegistrationService
final deviceRegistrationServiceProvider = Provider<DeviceRegistrationService>((
  ref,
) {
  final devicesRepo = ref.watch(devicesRepositoryProvider);
  return DeviceRegistrationService(devicesRepo);
});
