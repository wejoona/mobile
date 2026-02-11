/// Événement de sécurité enregistré par le système.
class SecurityEvent {
  final String id;
  final String type;
  final String severity; // low, medium, high, critical
  final String description;
  final String? userId;
  final String? deviceId;
  final String? ipAddress;
  final Map<String, dynamic> metadata;
  final DateTime occurredAt;
  final bool resolved;

  const SecurityEvent({
    required this.id,
    required this.type,
    required this.severity,
    required this.description,
    this.userId,
    this.deviceId,
    this.ipAddress,
    this.metadata = const {},
    required this.occurredAt,
    this.resolved = false,
  });

  SecurityEvent copyWith({
    String? severity,
    bool? resolved,
    Map<String, dynamic>? metadata,
  }) {
    return SecurityEvent(
      id: id,
      type: type,
      severity: severity ?? this.severity,
      description: description,
      userId: userId,
      deviceId: deviceId,
      ipAddress: ipAddress,
      metadata: metadata ?? this.metadata,
      occurredAt: occurredAt,
      resolved: resolved ?? this.resolved,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'type': type, 'severity': severity,
    'description': description, 'userId': userId,
    'occurredAt': occurredAt.toIso8601String(), 'resolved': resolved,
  };

  factory SecurityEvent.fromJson(Map<String, dynamic> json) {
    return SecurityEvent(
      id: json['id'] as String,
      type: json['type'] as String,
      severity: json['severity'] as String,
      description: json['description'] as String,
      userId: json['userId'] as String?,
      deviceId: json['deviceId'] as String?,
      ipAddress: json['ipAddress'] as String?,
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? {},
      occurredAt: DateTime.parse(json['occurredAt'] as String),
      resolved: json['resolved'] as bool? ?? false,
    );
  }
}
