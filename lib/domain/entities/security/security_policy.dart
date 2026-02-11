/// Politique de sécurité configurable.
class SecurityPolicy {
  final String id;
  final String name;
  final bool enabled;
  final int maxLoginAttempts;
  final Duration sessionTimeout;
  final Duration mfaCooldown;
  final bool requireBiometric;
  final bool requirePinForTransactions;
  final double stepUpThreshold; // Amount triggering step-up auth
  final bool allowScreenshots;
  final bool enforceSSLPinning;
  final Map<String, dynamic> customRules;

  const SecurityPolicy({
    required this.id,
    required this.name,
    this.enabled = true,
    this.maxLoginAttempts = 5,
    this.sessionTimeout = const Duration(minutes: 15),
    this.mfaCooldown = const Duration(seconds: 60),
    this.requireBiometric = true,
    this.requirePinForTransactions = true,
    this.stepUpThreshold = 100000,
    this.allowScreenshots = false,
    this.enforceSSLPinning = true,
    this.customRules = const {},
  });

  SecurityPolicy copyWith({
    bool? enabled,
    int? maxLoginAttempts,
    Duration? sessionTimeout,
    bool? requireBiometric,
    double? stepUpThreshold,
  }) {
    return SecurityPolicy(
      id: id,
      name: name,
      enabled: enabled ?? this.enabled,
      maxLoginAttempts: maxLoginAttempts ?? this.maxLoginAttempts,
      sessionTimeout: sessionTimeout ?? this.sessionTimeout,
      mfaCooldown: mfaCooldown,
      requireBiometric: requireBiometric ?? this.requireBiometric,
      requirePinForTransactions: requirePinForTransactions,
      stepUpThreshold: stepUpThreshold ?? this.stepUpThreshold,
      allowScreenshots: allowScreenshots,
      enforceSSLPinning: enforceSSLPinning,
      customRules: customRules,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'enabled': enabled,
    'maxLoginAttempts': maxLoginAttempts,
    'sessionTimeoutMinutes': sessionTimeout.inMinutes,
    'stepUpThreshold': stepUpThreshold,
  };

  factory SecurityPolicy.fromJson(Map<String, dynamic> json) {
    return SecurityPolicy(
      id: json['id'] as String,
      name: json['name'] as String,
      enabled: json['enabled'] as bool? ?? true,
      maxLoginAttempts: json['maxLoginAttempts'] as int? ?? 5,
      sessionTimeout: Duration(minutes: json['sessionTimeoutMinutes'] as int? ?? 15),
      stepUpThreshold: (json['stepUpThreshold'] as num?)?.toDouble() ?? 100000,
    );
  }
}
