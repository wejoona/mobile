/// Entrée de journal d'audit immuable.
class AuditEntry {
  final String id;
  final String action;
  final String actorId;
  final String actorType; // user, system, admin
  final String entityType;
  final String? entityId;
  final Map<String, dynamic>? previousState;
  final Map<String, dynamic>? newState;
  final String? ipAddress;
  final String? deviceId;
  final DateTime timestamp;
  final String? reason;

  const AuditEntry({
    required this.id,
    required this.action,
    required this.actorId,
    this.actorType = 'user',
    required this.entityType,
    this.entityId,
    this.previousState,
    this.newState,
    this.ipAddress,
    this.deviceId,
    required this.timestamp,
    this.reason,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'action': action, 'actorId': actorId,
    'actorType': actorType, 'entityType': entityType,
    'entityId': entityId, 'timestamp': timestamp.toIso8601String(),
    'reason': reason,
  };

  factory AuditEntry.fromJson(Map<String, dynamic> json) {
    return AuditEntry(
      id: json['id'] as String,
      action: json['action'] as String,
      actorId: json['actorId'] as String,
      actorType: json['actorType'] as String? ?? 'user',
      entityType: json['entityType'] as String,
      entityId: json['entityId'] as String?,
      previousState: json['previousState'] as Map<String, dynamic>?,
      newState: json['newState'] as Map<String, dynamic>?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      reason: json['reason'] as String?,
    );
  }
}
