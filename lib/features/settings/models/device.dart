/// Device model representing a user's device
class Device {
  final String id;
  final String? deviceIdentifier;
  final String? brand;
  final String? model;
  final String? os;
  final String? osVersion;
  final String? appVersion;
  final String? platform;
  final bool isTrusted;
  final DateTime? trustedAt;
  final bool isActive;
  final DateTime? lastLoginAt;
  final String? lastIpAddress;
  final int loginCount;

  const Device({
    required this.id,
    this.deviceIdentifier,
    this.brand,
    this.model,
    this.os,
    this.osVersion,
    this.appVersion,
    this.platform,
    this.isTrusted = false,
    this.trustedAt,
    this.isActive = true,
    this.lastLoginAt,
    this.lastIpAddress,
    this.loginCount = 0,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: (json['id'] ?? json['deviceId'] ?? '') as String,
      deviceIdentifier: (json['device_identifier'] ?? json['deviceIdentifier']) as String?,
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      os: json['os'] as String?,
      osVersion: (json['os_version'] ?? json['osVersion']) as String?,
      appVersion: (json['app_version'] ?? json['appVersion']) as String?,
      platform: json['platform'] as String?,
      isTrusted: (json['is_trusted'] ?? json['isTrusted']) as bool? ?? false,
      trustedAt: (json['trusted_at'] ?? json['trustedAt']) != null
          ? DateTime.tryParse((json['trusted_at'] ?? json['trustedAt']).toString())
          : null,
      isActive: (json['is_active'] ?? json['isActive']) as bool? ?? true,
      lastLoginAt: (json['last_login_at'] ?? json['lastLoginAt']) != null
          // ignore: avoid_dynamic_calls
          ? DateTime.tryParse((json['last_login_at'] ?? json['lastLoginAt']).toString())
          : null,
      lastIpAddress: (json['last_ip_address'] ?? json['lastIpAddress']) as String?,
      loginCount: ((json['login_count'] ?? json['loginCount']) as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'device_identifier': deviceIdentifier,
        'brand': brand,
        'model': model,
        'os': os,
        'os_version': osVersion,
        'app_version': appVersion,
        'platform': platform,
        'is_trusted': isTrusted,
        'trusted_at': trustedAt?.toIso8601String(),
        'is_active': isActive,
        'last_login_at': lastLoginAt?.toIso8601String(),
        'last_ip_address': lastIpAddress,
        'login_count': loginCount,
      };

  Device copyWith({
    String? id,
    String? deviceIdentifier,
    String? brand,
    String? model,
    String? os,
    String? osVersion,
    String? appVersion,
    String? platform,
    bool? isTrusted,
    DateTime? trustedAt,
    bool? isActive,
    DateTime? lastLoginAt,
    String? lastIpAddress,
    int? loginCount,
  }) {
    return Device(
      id: id ?? this.id,
      deviceIdentifier: deviceIdentifier ?? this.deviceIdentifier,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      os: os ?? this.os,
      osVersion: osVersion ?? this.osVersion,
      appVersion: appVersion ?? this.appVersion,
      platform: platform ?? this.platform,
      isTrusted: isTrusted ?? this.isTrusted,
      trustedAt: trustedAt ?? this.trustedAt,
      isActive: isActive ?? this.isActive,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      lastIpAddress: lastIpAddress ?? this.lastIpAddress,
      loginCount: loginCount ?? this.loginCount,
    );
  }

  /// Get display name for device (e.g., "iPhone 15 Pro", "Samsung Galaxy S23")
  String get displayName {
    if (brand != null && model != null) {
      return '$brand $model';
    } else if (brand != null) {
      return brand!;
    } else if (model != null) {
      return model!;
    }
    return 'Unknown Device';
  }

  /// Get OS display (e.g., "iOS 17.2", "Android 14")
  String get osDisplay {
    if (os != null && osVersion != null) {
      return '$os $osVersion';
    } else if (os != null) {
      return os!;
    }
    return 'Unknown OS';
  }

  /// Get platform icon name
  String get platformIcon {
    switch (platform?.toLowerCase()) {
      case 'ios':
        return 'phone_iphone';
      case 'android':
        return 'smartphone';
      case 'web':
        return 'computer';
      default:
        return 'devices';
    }
  }
}
