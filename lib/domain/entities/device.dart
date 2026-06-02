import 'package:usdc_wallet/utils/device_names.dart';

/// Device entity - mirrors backend registered device.
class Device {
  final String id;
  final String userId;
  final String deviceName;
  final String? brand;
  final String? deviceModel;
  final String? os;
  final String platform;
  final String? osVersion;
  final String? appVersion;
  final bool isTrusted;
  final bool isCurrent;
  final bool isActive;
  final DateTime? trustedAt;
  final DateTime lastActiveAt;
  final DateTime createdAt;
  final String? pushToken;
  final String? lastIpAddress;
  final int? loginCount;

  const Device({
    required this.id,
    required this.userId,
    required this.deviceName,
    this.brand,
    this.deviceModel,
    this.os,
    required this.platform,
    this.osVersion,
    this.appVersion,
    this.isTrusted = false,
    this.isCurrent = false,
    this.isActive = true,
    this.trustedAt,
    required this.lastActiveAt,
    required this.createdAt,
    this.pushToken,
    this.deviceIdentifier,
    this.lastIpAddress,
    this.loginCount,
  });

  /// Whether the device has been active recently (within 7 days).
  bool get isRecentlyActive =>
      DateTime.now().difference(lastActiveAt).inDays < 7;

  /// Display label: "iPhone 16 Pro Max" or "Samsung Galaxy S24".
  String get displayLabel {
    final cleanName = deviceName.trim();
    final cleanBrand = brand?.trim();
    final cleanModel = deviceModel?.trim();

    // Try to resolve machine code to marketing name (e.g. iPhone17,2 → iPhone 16 Pro Max)
    if (cleanModel != null &&
        cleanModel.isNotEmpty &&
        cleanModel != 'Unknown') {
      final resolved = iosModelName(cleanModel);
      if (resolved != cleanModel) return resolved; // Was a known machine code
      if (cleanBrand != null &&
          cleanBrand.isNotEmpty &&
          !cleanModel.toLowerCase().startsWith(cleanBrand.toLowerCase())) {
        return '$cleanBrand $cleanModel';
      }
      return cleanModel;
    }
    if (cleanName.isNotEmpty && cleanName != 'Unknown') {
      final resolved = iosModelName(cleanName);
      if (resolved != cleanName) return resolved;
      return cleanName;
    }
    if (cleanBrand != null && cleanBrand.isNotEmpty) return cleanBrand;
    switch (platform.toLowerCase()) {
      case 'ios':
        return 'iPhone';
      case 'android':
        return 'Android';
      default:
        return 'Appareil';
    }
  }

  String get osDisplay {
    final name = os?.trim().isNotEmpty == true ? os!.trim() : platform;
    final version = osVersion?.trim();
    if (version == null || version.isEmpty) return name;
    return '$name $version';
  }

  /// Backend device identifier (iOS: identifierForVendor, Android: android.id).
  final String? deviceIdentifier;

  factory Device.fromJson(Map<String, dynamic> json) {
    // Backend sends: deviceIdentifier, displayName, model, brand, os, osVersion,
    //   lastLoginAt, isActive, loginCount — map to our field names.
    final lastActiveAt = _date(json, const [
      'lastLoginAt',
      'lastActiveAt',
      'last_login_at',
      'last_active_at',
    ]);
    final createdAt = _date(json, const ['createdAt', 'created_at']);
    return Device(
      id: _string(json, const ['id']),
      userId: _string(json, const ['userId', 'user_id']),
      deviceName: _string(json, const [
        'displayName',
        'display_name',
        'deviceName',
        'device_name',
      ], fallback: 'Unknown'),
      brand: _nullableString(json, const ['brand']),
      deviceModel: _nullableString(json, const [
        'model',
        'deviceModel',
        'device_model',
      ]),
      os: _nullableString(json, const ['os']),
      platform: _string(json, const ['platform'], fallback: 'unknown'),
      osVersion: _nullableString(json, const ['osVersion', 'os_version']),
      appVersion: _nullableString(json, const ['appVersion', 'app_version']),
      isTrusted: _bool(json, const ['isTrusted', 'is_trusted']),
      isCurrent: _bool(json, const ['isCurrent', 'is_current']),
      isActive: _bool(json, const ['isActive', 'is_active'], fallback: true),
      trustedAt: _dateOrNull(json, const ['trustedAt', 'trusted_at']),
      lastActiveAt: lastActiveAt ?? DateTime.now(),
      createdAt: createdAt ?? DateTime.now(),
      pushToken: _nullableString(json, const [
        'pushToken',
        'push_token',
        'fcmToken',
        'fcm_token',
      ]),
      deviceIdentifier: _nullableString(json, const [
        'deviceIdentifier',
        'device_identifier',
      ]),
      lastIpAddress: _nullableString(json, const [
        'lastIpAddress',
        'last_ip_address',
      ]),
      loginCount: _int(json, const ['loginCount', 'login_count']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'deviceIdentifier': deviceIdentifier,
    'deviceName': deviceName,
    'brand': brand,
    'deviceModel': deviceModel,
    'os': os,
    'platform': platform,
    'osVersion': osVersion,
    'appVersion': appVersion,
    'isTrusted': isTrusted,
    'isCurrent': isCurrent,
    'isActive': isActive,
    'trustedAt': trustedAt?.toIso8601String(),
    'lastActiveAt': lastActiveAt.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'pushToken': pushToken,
    'lastIpAddress': lastIpAddress,
    'loginCount': loginCount,
  };
}

String _string(
  Map<String, dynamic> json,
  List<String> keys, {
  String fallback = '',
}) {
  return _nullableString(json, keys) ?? fallback;
}

String? _nullableString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) return value;
    if (value != null && value is! bool) return value.toString();
  }
  return null;
}

bool _bool(
  Map<String, dynamic> json,
  List<String> keys, {
  bool fallback = false,
}) {
  for (final key in keys) {
    final value = json[key];
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
  }
  return fallback;
}

int? _int(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
  }
  return null;
}

DateTime? _date(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
  }
  return null;
}

DateTime? _dateOrNull(Map<String, dynamic> json, List<String> keys) =>
    _date(json, keys);
