/// Contact model with Korido sync status
class SyncedContact {
  final String id;
  final String name;
  final String phone;
  final bool isKoridoUser;
  final String? joonaPayUserId;
  final String? avatarUrl;

  const SyncedContact({
    required this.id,
    required this.name,
    required this.phone,
    this.isKoridoUser = false,
    this.joonaPayUserId,
    this.avatarUrl,
  });

  factory SyncedContact.fromJson(Map<String, dynamic> json) {
    return SyncedContact(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      isKoridoUser: json['isKoridoUser'] as bool? ?? false,
      joonaPayUserId: json['joonaPayUserId'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'isKoridoUser': isKoridoUser,
        'joonaPayUserId': joonaPayUserId,
        'avatarUrl': avatarUrl,
      };

  SyncedContact copyWith({
    String? id,
    String? name,
    String? phone,
    bool? isKoridoUser,
    String? joonaPayUserId,
    String? avatarUrl,
  }) {
    return SyncedContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      isKoridoUser: isKoridoUser ?? this.isKoridoUser,
      joonaPayUserId: joonaPayUserId ?? this.joonaPayUserId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncedContact &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          phone == other.phone;

  @override
  int get hashCode => id.hashCode ^ phone.hashCode;
}
