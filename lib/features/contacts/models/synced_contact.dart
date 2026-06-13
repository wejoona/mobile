/// Contact model with Korido sync status
class SyncedContact {
  final String id;
  final String name;
  final String phone;
  final List<String> lookupPhones;
  final bool isKoridoUser;
  final String? joonaPayUserId;
  final String? username;
  final String? avatarUrl;

  const SyncedContact({
    required this.id,
    required this.name,
    required this.phone,
    this.lookupPhones = const [],
    this.isKoridoUser = false,
    this.joonaPayUserId,
    this.username,
    this.avatarUrl,
  });

  bool get canSendInKorido =>
      phone.trim().isNotEmpty || (username?.trim().isNotEmpty ?? false);

  String? get displayIdentifier {
    if (phone.trim().isNotEmpty) {
      return phone;
    }
    final handle = username?.trim();
    if (handle == null || handle.isEmpty) {
      return null;
    }
    return handle.startsWith('@') ? handle : '@$handle';
  }

  factory SyncedContact.fromJson(Map<String, dynamic> json) {
    return SyncedContact(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      lookupPhones:
          (json['lookupPhones'] as List?)?.whereType<String>().toList() ??
          const [],
      isKoridoUser: json['isKoridoUser'] as bool? ?? false,
      joonaPayUserId: json['joonaPayUserId'] as String?,
      username: json['username'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'lookupPhones': lookupPhones,
    'isKoridoUser': isKoridoUser,
    'joonaPayUserId': joonaPayUserId,
    'username': username,
    'avatarUrl': avatarUrl,
  };

  SyncedContact copyWith({
    String? id,
    String? name,
    String? phone,
    List<String>? lookupPhones,
    bool? isKoridoUser,
    String? joonaPayUserId,
    String? username,
    String? avatarUrl,
  }) {
    return SyncedContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      lookupPhones: lookupPhones ?? this.lookupPhones,
      isKoridoUser: isKoridoUser ?? this.isKoridoUser,
      joonaPayUserId: joonaPayUserId ?? this.joonaPayUserId,
      username: username ?? this.username,
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
