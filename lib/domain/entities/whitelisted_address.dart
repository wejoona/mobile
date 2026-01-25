/// Whitelisted address entity - trusted withdrawal addresses
class WhitelistedAddress {
  final String id;
  final String address;
  final String label;
  final String addressType; // internal, external
  final String? network;
  final String status; // pending, active, revoked
  final bool isVerified;
  final bool isNewAddress;
  final int hoursUntilTrusted;
  final int usageCount;
  final DateTime? lastUsedAt;
  final DateTime createdAt;

  const WhitelistedAddress({
    required this.id,
    required this.address,
    required this.label,
    required this.addressType,
    this.network,
    required this.status,
    required this.isVerified,
    required this.isNewAddress,
    required this.hoursUntilTrusted,
    required this.usageCount,
    this.lastUsedAt,
    required this.createdAt,
  });

  /// Truncated address for display
  String get truncatedAddress {
    if (address.length <= 12) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  /// Whether this address is active
  bool get isActive => status == 'active';

  /// Whether this address is pending verification
  bool get isPending => status == 'pending';

  factory WhitelistedAddress.fromJson(Map<String, dynamic> json) {
    return WhitelistedAddress(
      id: json['id'] as String,
      address: json['address'] as String,
      label: json['label'] as String,
      addressType: json['addressType'] as String? ?? 'external',
      network: json['network'] as String?,
      status: json['status'] as String? ?? 'pending',
      isVerified: json['isVerified'] as bool? ?? false,
      isNewAddress: json['isNewAddress'] as bool? ?? true,
      hoursUntilTrusted: json['hoursUntilTrusted'] as int? ?? 24,
      usageCount: json['usageCount'] as int? ?? 0,
      lastUsedAt: json['lastUsedAt'] != null
          ? DateTime.parse(json['lastUsedAt'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address,
      'label': label,
      'addressType': addressType,
      'network': network,
      'status': status,
      'isVerified': isVerified,
      'isNewAddress': isNewAddress,
      'hoursUntilTrusted': hoursUntilTrusted,
      'usageCount': usageCount,
      'lastUsedAt': lastUsedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// Result of checking an address before withdrawal
class AddressCheckResult {
  final bool isWhitelisted;
  final bool isNew;
  final int hoursUntilTrusted;
  final bool requiresDelay;
  final double instantLimit;

  const AddressCheckResult({
    required this.isWhitelisted,
    required this.isNew,
    required this.hoursUntilTrusted,
    required this.requiresDelay,
    required this.instantLimit,
  });

  factory AddressCheckResult.fromJson(Map<String, dynamic> json) {
    return AddressCheckResult(
      isWhitelisted: json['isWhitelisted'] as bool? ?? false,
      isNew: json['isNew'] as bool? ?? true,
      hoursUntilTrusted: json['hoursUntilTrusted'] as int? ?? 24,
      requiresDelay: json['requiresDelay'] as bool? ?? true,
      instantLimit: (json['instantLimit'] as num?)?.toDouble() ?? 0,
    );
  }
}
