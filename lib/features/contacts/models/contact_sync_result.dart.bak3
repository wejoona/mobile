/// Result of contact sync operation
class ContactSyncResult {
  final int totalContacts;
  final int joonaPayUsersFound;
  final DateTime syncedAt;
  final bool success;
  final String? error;

  const ContactSyncResult({
    required this.totalContacts,
    required this.joonaPayUsersFound,
    required this.syncedAt,
    this.success = true,
    this.error,
  });

  factory ContactSyncResult.fromJson(Map<String, dynamic> json) {
    return ContactSyncResult(
      totalContacts: json['totalContacts'] as int,
      joonaPayUsersFound: json['joonaPayUsersFound'] as int,
      syncedAt: DateTime.parse(json['syncedAt'] as String),
      success: json['success'] as bool? ?? true,
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalContacts': totalContacts,
        'joonaPayUsersFound': joonaPayUsersFound,
        'syncedAt': syncedAt.toIso8601String(),
        'success': success,
        'error': error,
      };

  ContactSyncResult copyWith({
    int? totalContacts,
    int? joonaPayUsersFound,
    DateTime? syncedAt,
    bool? success,
    String? error,
  }) {
    return ContactSyncResult(
      totalContacts: totalContacts ?? this.totalContacts,
      joonaPayUsersFound: joonaPayUsersFound ?? this.joonaPayUsersFound,
      syncedAt: syncedAt ?? this.syncedAt,
      success: success ?? this.success,
      error: error ?? this.error,
    );
  }
}
