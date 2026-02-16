import 'package:usdc_wallet/utils/device_names.dart';

/// Device entity - mirrors backend registered device.
class Device {
  final String id;
  final String userId;
  final String deviceName;
  final String? deviceModel;
  final String platform;
  final String? osVersion;
  final String? appVersion;
  final bool isTrusted;
  final bool isCurrent;
  final DateTime lastActiveAt;
  final DateTime createdAt;
  final String? pushToken;

  const Device({
    required this.id,
    required this.userId,
    required this.deviceName,
    this.deviceModel,
    required this.platform,
    this.osVersion,
    this.appVersion,
    this.isTrusted = false,
    this.isCurrent = false,
    required this.lastActiveAt,
    required this.createdAt,
    this.pushToken,
    this.deviceIdentifier,
  });

  /// Whether the device has been active recently (within 7 days).
  bool get isRecentlyActive =>
      DateTime.now().difference(lastActiveAt).inDays < 7;

  /// Display label: "iPhone 16 Pro Max" or "Samsung Galaxy S24".
  String get displayLabel {
    // Try to resolve machine code to marketing name (e.g. iPhone17,2 → iPhone 16 Pro Max)
    if (deviceModel != null && deviceModel!.isNotEmpty && deviceModel != 'Unknown') {
      final resolved = iosModelName(deviceModel!);
      if (resolved != deviceModel) return resolved; // Was a known machine code
      return deviceModel!;
    }
    if (deviceName.isNotEmpty && deviceName != 'Unknown') {
      final resolved = iosModelName(deviceName);
      if (resolved != deviceName) return resolved;
      return deviceName;
    }
    switch (platform.toLowerCase()) {
      case 'ios': return 'iPhone';
      case 'android': return 'Android';
      default: return 'Appareil';
    }
  }

  /// Backend device identifier (iOS: identifierForVendor, Android: android.id).
  final String? deviceIdentifier;

  factory Device.fromJson(Map<String, dynamic> json) {
    // Backend sends: deviceIdentifier, displayName, model, brand, os, osVersion,
    //   lastLoginAt, isActive, loginCount — map to our field names.
    return Device(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? '',
      deviceName: json['displayName'] as String? ??
          json['deviceName'] as String? ??
          'Unknown',
      deviceModel: json['model'] as String? ??
          json['deviceModel'] as String?,
      platform: json['platform'] as String? ?? 'unknown',
      osVersion: json['osVersion'] as String?,
      appVersion: json['appVersion'] as String?,
      isTrusted: json['isTrusted'] as bool? ?? false,
      isCurrent: json['isCurrent'] as bool? ?? false,
      lastActiveAt: DateTime.parse(
        json['lastLoginAt'] as String? ??
            json['lastActiveAt'] as String? ??
            DateTime.now().toIso8601String(),
      ),
      createdAt: DateTime.parse(
        json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
      pushToken: json['pushToken'] as String? ?? json['fcmToken'] as String?,
      deviceIdentifier: json['deviceIdentifier'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'deviceName': deviceName,
        'deviceModel': deviceModel,
        'platform': platform,
        'osVersion': osVersion,
        'appVersion': appVersion,
        'isTrusted': isTrusted,
        'pushToken': pushToken,
      };
}
