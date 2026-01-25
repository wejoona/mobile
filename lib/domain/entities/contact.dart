/// Contact entity - represents a saved contact/recipient
class Contact {
  final String id;
  final String name;
  final String? phone;
  final String? walletAddress;
  final String? username;
  final bool isFavorite;
  final int transactionCount;
  final DateTime? lastTransactionAt;
  final bool isJoonaPayUser;

  const Contact({
    required this.id,
    required this.name,
    this.phone,
    this.walletAddress,
    this.username,
    this.isFavorite = false,
    this.transactionCount = 0,
    this.lastTransactionAt,
    this.isJoonaPayUser = false,
  });

  /// Returns @username if set
  String? get usernameDisplay => username != null ? '@$username' : null;

  /// Returns the best display identifier
  String get displayIdentifier {
    if (username != null) return '@$username';
    if (phone != null) return phone!;
    if (walletAddress != null) {
      // Truncate wallet address for display
      if (walletAddress!.length > 12) {
        return '${walletAddress!.substring(0, 6)}...${walletAddress!.substring(walletAddress!.length - 4)}';
      }
      return walletAddress!;
    }
    return name;
  }

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      walletAddress: json['walletAddress'] as String?,
      username: json['username'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      transactionCount: json['transactionCount'] as int? ?? 0,
      lastTransactionAt: json['lastTransactionAt'] != null
          ? DateTime.parse(json['lastTransactionAt'] as String)
          : null,
      isJoonaPayUser: json['isJoonaPayUser'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'walletAddress': walletAddress,
      'username': username,
      'isFavorite': isFavorite,
      'transactionCount': transactionCount,
      'lastTransactionAt': lastTransactionAt?.toIso8601String(),
      'isJoonaPayUser': isJoonaPayUser,
    };
  }

  Contact copyWith({
    String? id,
    String? name,
    String? phone,
    String? walletAddress,
    String? username,
    bool? isFavorite,
    int? transactionCount,
    DateTime? lastTransactionAt,
    bool? isJoonaPayUser,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      walletAddress: walletAddress ?? this.walletAddress,
      username: username ?? this.username,
      isFavorite: isFavorite ?? this.isFavorite,
      transactionCount: transactionCount ?? this.transactionCount,
      lastTransactionAt: lastTransactionAt ?? this.lastTransactionAt,
      isJoonaPayUser: isJoonaPayUser ?? this.isJoonaPayUser,
    );
  }
}
