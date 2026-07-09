import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/settings/repositories/devices_repository.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/notifications/push_notification_service.dart';
import 'package:usdc_wallet/services/security/device_fingerprint_service.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Service to collect device info and register with the backend
class DeviceRegistrationService {
  DeviceRegistrationService(
    this._devicesRepository,
    this._fingerprintService, {
    String? Function()? fcmTokenProvider,
  }) : _fcmTokenProvider = fcmTokenProvider;

  final DevicesRepository _devicesRepository;
  final DeviceFingerprintService _fingerprintService;
  final String? Function()? _fcmTokenProvider;

  /// Register the current device with the backend.
  /// Should be called after successful OTP verification / login.
  Future<void> registerCurrentDevice() async {
    const logger = AppLogger('DeviceRegistration');

    try {
      final fingerprint = await _fingerprintService.collect();
      final deviceInfo = DeviceInfoPlugin();
      String? deviceName;

      if (Platform.isIOS) {
        final ios = await deviceInfo.iosInfo;
        deviceName = ios.name; // e.g. "Ben's iPhone 16 Pro Max"
      } else if (Platform.isAndroid) {
        final android = await deviceInfo.androidInfo;
        deviceName = android.model;
      } else {
        logger.debug('Unsupported platform for device registration');
        return;
      }

      await _devicesRepository.registerDevice(
        deviceId: fingerprint.deviceId,
        platform: fingerprint.platform,
        deviceName: deviceName,
        model: fingerprint.model,
        brand: fingerprint.brand,
        os: fingerprint.os,
        osVersion: fingerprint.osVersion,
        appVersion: fingerprint.appVersion,
        fcmToken: _fcmTokenProvider?.call(),
        locale: fingerprint.locale,
        metadata: {
          'fingerprintHash': fingerprint.fingerprintHash,
          'buildNumber': fingerprint.buildNumber,
          'screenWidth': fingerprint.screenWidth,
          'screenHeight': fingerprint.screenHeight,
          'isPhysicalDevice': fingerprint.isPhysicalDevice,
          'isCompromised': fingerprint.isCompromised,
          'biometricsAvailable': fingerprint.biometricsAvailable,
        },
      );

      logger.info('Device registered successfully');
    } on ApiException catch (error) {
      if (error.isDeviceBlacklisted) {
        rethrow;
      }

      // Don't fail login if device registration fails
      logger.error('Device registration failed', error);
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
  final fingerprintService = ref.watch(deviceFingerprintServiceProvider);
  return DeviceRegistrationService(
    devicesRepo,
    fingerprintService,
    fcmTokenProvider: () =>
        ref.read(pushNotificationServiceProvider).currentToken,
  );
});
