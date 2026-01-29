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
    return Session(
      id: json['id'] as String,
      deviceId: json['deviceId'] as String?,
      ipAddress: json['ipAddress'] as String?,
      userAgent: json['userAgent'] as String?,
      location: json['location'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      lastActivityAt: DateTime.parse(json['lastActivityAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      revokedAt: json['revokedAt'] != null
          ? DateTime.parse(json['revokedAt'] as String)
          : null,
      revokedReason: json['revokedReason'] as String?,
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
    if (ua.contains('android')) return 'Android Device';

    // Desktop browsers
    if (ua.contains('chrome')) return 'Chrome Browser';
    if (ua.contains('firefox')) return 'Firefox Browser';
    if (ua.contains('safari')) return 'Safari Browser';
    if (ua.contains('edge')) return 'Edge Browser';

    return 'Unknown Device';
  }
}
