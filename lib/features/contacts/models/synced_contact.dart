/// Contact model with Korido sync status
class SyncedContact {
  final String id;
  final String name;
  final String phone;
  final String? maskedPhone;
  final List<String> lookupPhones;
  final bool isKoridoUser;
  final String? joonaPayUserId;
  final String? username;
  final String? avatarUrl;

  const SyncedContact({
    required this.id,
    required this.name,
    required this.phone,
    this.maskedPhone,
    this.lookupPhones = const [],
    this.isKoridoUser = false,
    this.joonaPayUserId,
    this.username,
    this.avatarUrl,
  });

  bool get canSendInKorido =>
      phone.trim().isNotEmpty ||
      (username?.trim().isNotEmpty ?? false) ||
      (joonaPayUserId?.trim().isNotEmpty ?? false);

  String? get displayIdentifier {
    if (phone.trim().isNotEmpty) {
      return phone;
    }
    final handle = username?.trim();
    if (handle != null && handle.isNotEmpty) {
      return handle.startsWith('@') ? handle : '@$handle';
    }
    final masked = maskedPhone?.trim();
    return masked == null || masked.isEmpty ? null : masked;
  }

  factory SyncedContact.fromJson(Map<String, dynamic> json) {
    return SyncedContact(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      maskedPhone: json['maskedPhone'] as String?,
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
    'maskedPhone': maskedPhone,
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
    String? maskedPhone,
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
      maskedPhone: maskedPhone ?? this.maskedPhone,
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
