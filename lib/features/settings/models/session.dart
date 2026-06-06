/// Session Model
class Session {
  final String id;
  final String? deviceId;
  final String? ipAddress;
  final String? userAgent;
  final String? location;
  final bool isActive;
  final DateTime lastActivityAt;
  final DateTime expiresAt;
  final DateTime? revokedAt;
  final String? revokedReason;

  const Session({
    required this.id,
    this.deviceId,
    this.ipAddress,
    this.userAgent,
    this.location,
    required this.isActive,
    required this.lastActivityAt,
    required this.expiresAt,
    this.revokedAt,
    this.revokedReason,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    final lastActivityAt =
        _readDateTime(json, const [
          'lastActivityAt',
          'last_activity_at',
          'lastSeenAt',
          'last_seen_at',
          'lastActiveAt',
          'last_active_at',
          'updatedAt',
          'updated_at',
          'createdAt',
          'created_at',
        ]) ??
        DateTime.now();

    return Session(
      id: _readString(json, const ['id', 'sessionId', 'session_id']) ?? '',
      deviceId: _readString(json, const ['deviceId', 'device_id']),
      ipAddress: _readString(json, const ['ipAddress', 'ip_address', 'ip']),
      userAgent: _readString(json, const ['userAgent', 'user_agent']),
      location: _readString(json, const ['location']),
      isActive:
          _readBool(json, const ['isActive', 'is_active', 'active']) ?? true,
      lastActivityAt: lastActivityAt,
      expiresAt:
          _readDateTime(json, const ['expiresAt', 'expires_at']) ??
          lastActivityAt.add(const Duration(days: 7)),
      revokedAt: _readDateTime(json, const ['revokedAt', 'revoked_at']),
      revokedReason: _readString(json, const [
        'revokedReason',
        'revoked_reason',
      ]),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'deviceId': deviceId,
    'ipAddress': ipAddress,
    'userAgent': userAgent,
    'location': location,
    'isActive': isActive,
    'lastActivityAt': lastActivityAt.toIso8601String(),
    'expiresAt': expiresAt.toIso8601String(),
    'revokedAt': revokedAt?.toIso8601String(),
    'revokedReason': revokedReason,
  };

  Session copyWith({
    String? id,
    String? deviceId,
    String? ipAddress,
    String? userAgent,
    String? location,
    bool? isActive,
    DateTime? lastActivityAt,
    DateTime? expiresAt,
    DateTime? revokedAt,
    String? revokedReason,
  }) {
    return Session(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      ipAddress: ipAddress ?? this.ipAddress,
      userAgent: userAgent ?? this.userAgent,
      location: location ?? this.location,
      isActive: isActive ?? this.isActive,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      expiresAt: expiresAt ?? this.expiresAt,
      revokedAt: revokedAt ?? this.revokedAt,
      revokedReason: revokedReason ?? this.revokedReason,
    );
  }

  /// Get a simple device description from user agent
  String get deviceDescription {
    if (userAgent == null) return 'Unknown Device';

    final ua = userAgent!.toLowerCase();

    // Mobile devices
    if (ua.contains('iphone')) return 'iPhone';
    if (ua.contains('ipad')) return 'iPad';
    if (ua.contains('ios')) return 'iOS Device';
    if (ua.contains('android')) return 'Android Device';

    // Desktop browsers
    if (ua.contains('chrome')) return 'Chrome Browser';
    if (ua.contains('firefox')) return 'Firefox Browser';
    if (ua.contains('safari')) return 'Safari Browser';
    if (ua.contains('edge')) return 'Edge Browser';

    return 'Unknown Device';
  }

  String get displayIpAddress {
    final ip = ipAddress;
    if (ip == null || ip.isEmpty) return 'Unknown IP';
    if (ip.startsWith('::ffff:')) return ip.substring(7);
    return ip;
  }

  static String? _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;
      final stringValue = value.toString().trim();
      if (stringValue.isNotEmpty) return stringValue;
    }
    return null;
  }

  static bool? _readBool(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is bool) return value;
      if (value is String) {
        final normalized = value.toLowerCase();
        if (normalized == 'true') return true;
        if (normalized == 'false') return false;
      }
    }
    return null;
  }

  static DateTime? _readDateTime(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is DateTime) return value;
      if (value == null) continue;
      final parsed = DateTime.tryParse(value.toString());
      if (parsed != null) return parsed;
    }
    return null;
  }
}
