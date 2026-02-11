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
  });

  /// Whether the device has been active recently (within 7 days).
  bool get isRecentlyActive =>
      DateTime.now().difference(lastActiveAt).inDays < 7;

  /// Display label: "iPhone 15 Pro (iOS 18.0)".
  String get displayLabel {
    final parts = <String>[deviceModel ?? deviceName];
    if (osVersion != null) parts.add('($platform $osVersion)');
    return parts.join(' ');
  }

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? '',
      deviceName: json['deviceName'] as String? ?? 'Unknown',
      deviceModel: json['deviceModel'] as String?,
      platform: json['platform'] as String? ?? 'unknown',
      osVersion: json['osVersion'] as String?,
      appVersion: json['appVersion'] as String?,
      isTrusted: json['isTrusted'] as bool? ?? false,
      isCurrent: json['isCurrent'] as bool? ?? false,
      lastActiveAt: DateTime.parse(
        json['lastActiveAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
      createdAt: DateTime.parse(
        json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
      pushToken: json['pushToken'] as String?,
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
