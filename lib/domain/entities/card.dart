int _parseInt(dynamic value, int fallback) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? fallback;
  if (value is num) return value.toInt();
  return fallback;
}

/// Card entity - mirrors backend Card domain entity.
class KoridoCard {
  final String id;
  final String userId;
  final String last4;
  final String brand;
  final CardType type;
  final CardStatus status;
  final String? nickname;
  final int expiryMonth;
  final int expiryYear;
  final double? spendingLimit;
  final double? currentSpend;
  final DateTime createdAt;
  final DateTime? blockedAt;

  const KoridoCard({
    required this.id,
    required this.userId,
    required this.last4,
    required this.brand,
    required this.type,
    required this.status,
    this.nickname,
    required this.expiryMonth,
    required this.expiryYear,
    this.spendingLimit,
    this.currentSpend,
    required this.createdAt,
    this.blockedAt,
  });

  /// Display name: nickname or "Visa •••• 1234".
  String get displayName => nickname ?? '$brand •••• $last4';

  /// Expiry as "MM/YY".
  String get expiryFormatted =>
      '${expiryMonth.toString().padLeft(2, '0')}/${expiryYear.toString().substring(2)}';

  /// Whether the card is active and usable.
  bool get isActive => status == CardStatus.active;

  /// Whether the card is expired.
  bool get isExpired {
    final now = DateTime.now();
    return now.year > expiryYear ||
        (now.year == expiryYear && now.month > expiryMonth);
  }

  /// Spending limit usage (0.0 to 1.0).
  double get spendingUsage {
    if (spendingLimit == null || spendingLimit! <= 0) return 0;
    return ((currentSpend ?? 0) / spendingLimit!).clamp(0.0, 1.0);
  }

  factory KoridoCard.fromJson(Map<String, dynamic> json) {
    // Extract last4 from maskedCardNumber if 'last4' not present
    String last4 = json['last4'] as String? ?? '';
    if (last4.isEmpty && json['maskedCardNumber'] != null) {
      final masked = json['maskedCardNumber'] as String;
      last4 = masked.length >= 4 ? masked.substring(masked.length - 4) : masked;
    }
    if (last4.isEmpty) last4 = '****';

    // Map backend 'cardType' to CardType enum
    final rawType = json['type'] ?? json['cardType'];
    final cardType = CardType.values.firstWhere(
      (e) => e.name == rawType,
      orElse: () => CardType.virtual,
    );

    // Map backend status: derive from frozenAt if needed
    final rawStatus = json['status'] as String? ?? 'active';
    final isFrozenFromBackend = json['frozenAt'] != null;
    CardStatus status;
    if (isFrozenFromBackend && rawStatus == 'active') {
      status = CardStatus.frozen;
    } else {
      status = CardStatus.values.firstWhere(
        (e) => e.name == rawStatus,
        orElse: () => CardStatus.active,
      );
    }

    return KoridoCard(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? '',
      last4: last4,
      brand: json['brand'] as String? ?? 'Visa',
      type: cardType,
      status: status,
      nickname: json['nickname'] as String?,
      expiryMonth: _parseInt(json['expiryMonth'], 12),
      expiryYear: _parseInt(json['expiryYear'], 2030),
      spendingLimit: (json['spendingLimit'] as num?)?.toDouble(),
      currentSpend: (json['currentSpend'] as num?)?.toDouble() ?? (json['spentAmount'] as num?)?.toDouble(),
      createdAt: DateTime.parse(
        json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
      blockedAt: json['blockedAt'] != null
          ? DateTime.parse(json['blockedAt'] as String)
          : json['frozenAt'] != null
              ? DateTime.parse(json['frozenAt'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'last4': last4,
        'brand': brand,
        'type': type.name,
        'status': status.name,
        'nickname': nickname,
        'expiryMonth': expiryMonth,
        'expiryYear': expiryYear,
        'spendingLimit': spendingLimit,
        'currentSpend': currentSpend,
      };
  // Computed getters
  String get maskedNumber => '•••• $last4';
  String? get cardNumber => null; // Full number never exposed client-side
  bool get isFrozen => status == CardStatus.frozen;
  String get expiryDate => '${expiryMonth.toString().padLeft(2, '0')}/${expiryYear.toString().substring(2)}';

  // Aliases expected by generated views
  String? get cvv => null; // Never exposed client-side
  String get expiry => expiryFormatted;
  String get currency => 'USD';
  double get spentAmount => currentSpend ?? 0;
  double get availableLimit => (spendingLimit ?? 0) - spentAmount;
  bool get isVirtual => type == CardType.virtual;
  String get lastFourDigits => last4;
  double? get dailyLimit => spendingLimit;
  double? get transactionLimit => spendingLimit;
}

enum CardType { virtual, physical }

enum CardStatus { active, blocked, frozen, expired, cancelled }
