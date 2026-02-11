/// Alerte de sécurité pour l'utilisateur ou l'administrateur.
class SecurityAlert {
  final String id;
  final String title;
  final String message;
  final String severity; // info, warning, danger, critical
  final String category; // auth, network, compliance, device
  final bool requiresAction;
  final String? actionUrl;
  final DateTime createdAt;
  final DateTime? acknowledgedAt;
  final bool dismissed;

  const SecurityAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    required this.category,
    this.requiresAction = false,
    this.actionUrl,
    required this.createdAt,
    this.acknowledgedAt,
    this.dismissed = false,
  });

  bool get isActive => !dismissed && acknowledgedAt == null;

  SecurityAlert acknowledge() => SecurityAlert(
    id: id, title: title, message: message,
    severity: severity, category: category,
    requiresAction: requiresAction, actionUrl: actionUrl,
    createdAt: createdAt, acknowledgedAt: DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'message': message,
    'severity': severity, 'category': category,
    'createdAt': createdAt.toIso8601String(),
  };

  factory SecurityAlert.fromJson(Map<String, dynamic> json) {
    return SecurityAlert(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      severity: json['severity'] as String,
      category: json['category'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
