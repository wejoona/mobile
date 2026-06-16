enum TransactionLimitOperation { send, deposit, withdraw }

class MoneyFlowPermissions {
  final bool canSend;
  final bool canDeposit;
  final bool canWithdraw;
  final bool canReceive;
  final String? blockReason;
  final bool reviewRequired;

  const MoneyFlowPermissions({
    this.canSend = true,
    this.canDeposit = true,
    this.canWithdraw = true,
    this.canReceive = true,
    this.blockReason,
    this.reviewRequired = false,
  });

  factory MoneyFlowPermissions.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const MoneyFlowPermissions();
    }

    return MoneyFlowPermissions(
      canSend: _boolOf(json, const ['canSend', 'can_send']) ?? true,
      canDeposit: _boolOf(json, const ['canDeposit', 'can_deposit']) ?? true,
      canWithdraw: _boolOf(json, const ['canWithdraw', 'can_withdraw']) ?? true,
      canReceive: _boolOf(json, const ['canReceive', 'can_receive']) ?? true,
      blockReason: _stringOf(json, const [
        'blockReason',
        'block_reason',
      ])?.trim(),
      reviewRequired:
          _boolOf(json, const ['reviewRequired', 'review_required']) ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'canSend': canSend,
    'canDeposit': canDeposit,
    'canWithdraw': canWithdraw,
    'canReceive': canReceive,
    'blockReason': blockReason,
    'reviewRequired': reviewRequired,
  };

  bool can(TransactionLimitOperation operation) {
    return switch (operation) {
      TransactionLimitOperation.send => canSend,
      TransactionLimitOperation.deposit => canDeposit,
      TransactionLimitOperation.withdraw => canWithdraw,
    };
  }
}

class TransactionLimits {
  final double dailyLimit;
  final double dailyDepositLimit;
  final double dailyDepositUsed;
  final double dailyWithdrawLimit;
  final double dailyWithdrawUsed;
  final double weeklyLimit;
  final double monthlyLimit;
  final double singleTransactionLimit;
  final double singleTransactionMax;
  final double withdrawalLimit;
  final double dailyUsed;
  final double weeklyUsed;
  final double monthlyUsed;
  final String currency;
  final int kycTier;
  final String tierName;
  final String? kycStatus;
  final String? upgradeMessage;
  final String? nextTierName;
  final double? nextTierDailyLimit;
  final double? nextTierMonthlyLimit;
  final DateTime? resetTime;
  final int? hoursUntilReset;
  final int? minutesUntilReset;
  final bool overrideActive;
  final String? overrideReason;
  final DateTime? overrideExpiresAt;
  final MoneyFlowPermissions permissions;

  const TransactionLimits({
    required this.dailyLimit,
    this.dailyDepositLimit = 0,
    this.dailyDepositUsed = 0,
    this.dailyWithdrawLimit = 0,
    this.dailyWithdrawUsed = 0,
    this.weeklyLimit = 0,
    required this.monthlyLimit,
    required this.singleTransactionLimit,
    this.singleTransactionMax = 0,
    required this.withdrawalLimit,
    required this.dailyUsed,
    this.weeklyUsed = 0,
    required this.monthlyUsed,
    this.currency = 'USDC',
    required this.kycTier,
    required this.tierName,
    this.kycStatus,
    this.upgradeMessage,
    this.nextTierName,
    this.nextTierDailyLimit,
    this.nextTierMonthlyLimit,
    this.resetTime,
    this.hoursUntilReset,
    this.minutesUntilReset,
    this.overrideActive = false,
    this.overrideReason,
    this.overrideExpiresAt,
    this.permissions = const MoneyFlowPermissions(),
  });

  factory TransactionLimits.fromJson(Map<String, dynamic> json) {
    final daily = _mapOf(json['daily']);
    final dailySend = _mapOf(daily['send']);
    final dailyDeposit = _mapOf(daily['deposit']);
    final dailyWithdraw = _mapOf(daily['withdraw']);
    final monthly = _mapOf(json['monthly']);
    final monthlyTotal = _mapOf(monthly['total']);
    final perTransaction = _mapOf(json['perTransaction']);
    final tier = json['tier'] as String?;

    final singleTransactionLimit =
        _numberOf(json['singleTransactionLimit']) ??
        _numberOf(perTransaction['send']) ??
        0.0;

    return TransactionLimits(
      dailyLimit:
          _numberOf(json['dailyLimit']) ?? _numberOf(dailySend['limit']) ?? 0.0,
      dailyDepositLimit:
          _numberOf(dailyDeposit['limit']) ??
          _numberOf(json['dailyLimit']) ??
          0.0,
      dailyDepositUsed:
          _numberOf(json['dailyDepositUsed']) ??
          _numberOf(dailyDeposit['used']) ??
          0.0,
      dailyWithdrawLimit:
          _numberOf(dailyWithdraw['limit']) ??
          _numberOf(json['dailyLimit']) ??
          0.0,
      dailyWithdrawUsed:
          _numberOf(json['dailyWithdrawUsed']) ??
          _numberOf(dailyWithdraw['used']) ??
          0.0,
      weeklyLimit: _numberOf(json['weeklyLimit']) ?? 0.0,
      monthlyLimit:
          _numberOf(json['monthlyLimit']) ??
          _numberOf(monthlyTotal['limit']) ??
          0.0,
      singleTransactionLimit: singleTransactionLimit,
      singleTransactionMax:
          _numberOf(json['singleTransactionMax']) ?? singleTransactionLimit,
      withdrawalLimit:
          _numberOf(json['withdrawalLimit']) ??
          _numberOf(perTransaction['withdraw']) ??
          0.0,
      dailyUsed:
          _numberOf(json['dailyUsed']) ?? _numberOf(dailySend['used']) ?? 0.0,
      weeklyUsed: _numberOf(json['weeklyUsed']) ?? 0.0,
      monthlyUsed:
          _numberOf(json['monthlyUsed']) ??
          _numberOf(monthlyTotal['used']) ??
          0.0,
      currency: json['currency'] as String? ?? 'USDC',
      kycTier: (json['kycTier'] as num?)?.toInt() ?? _tierNumberFromName(tier),
      tierName: json['tierName'] as String? ?? _tierDisplayName(tier),
      kycStatus: json['kycStatus'] as String?,
      upgradeMessage: json['upgradeMessage'] as String?,
      nextTierName: json['nextTierName'] as String?,
      nextTierDailyLimit: _numberOf(json['nextTierDailyLimit']),
      nextTierMonthlyLimit: _numberOf(json['nextTierMonthlyLimit']),
      resetTime: _dateOf(json['resetTime']),
      hoursUntilReset: json['hoursUntilReset'] as int?,
      minutesUntilReset: json['minutesUntilReset'] as int?,
      overrideActive:
          _boolOf(json, const ['overrideActive', 'override_active']) ?? false,
      overrideReason: _stringOf(json, const [
        'overrideReason',
        'override_reason',
      ]),
      overrideExpiresAt: _dateOf(
        json['overrideExpiresAt'] ?? json['override_expires_at'],
      ),
      permissions: MoneyFlowPermissions.fromJson(
        _nullableMapOf(json['permissions']),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'dailyLimit': dailyLimit,
    'dailyDepositLimit': dailyDepositLimit,
    'dailyDepositUsed': dailyDepositUsed,
    'dailyWithdrawLimit': dailyWithdrawLimit,
    'dailyWithdrawUsed': dailyWithdrawUsed,
    'monthlyLimit': monthlyLimit,
    'singleTransactionLimit': singleTransactionLimit,
    'withdrawalLimit': withdrawalLimit,
    'dailyUsed': dailyUsed,
    'monthlyUsed': monthlyUsed,
    'kycTier': kycTier,
    'tierName': tierName,
    'kycStatus': kycStatus,
    'upgradeMessage': upgradeMessage,
    'nextTierName': nextTierName,
    'nextTierDailyLimit': nextTierDailyLimit,
    'nextTierMonthlyLimit': nextTierMonthlyLimit,
    'resetTime': resetTime?.toIso8601String(),
    'hoursUntilReset': hoursUntilReset,
    'minutesUntilReset': minutesUntilReset,
    'overrideActive': overrideActive,
    'overrideReason': overrideReason,
    'overrideExpiresAt': overrideExpiresAt?.toIso8601String(),
    'permissions': permissions.toJson(),
  };

  TransactionLimits copyWith({
    double? dailyLimit,
    double? dailyDepositLimit,
    double? dailyDepositUsed,
    double? dailyWithdrawLimit,
    double? dailyWithdrawUsed,
    double? monthlyLimit,
    double? singleTransactionLimit,
    double? withdrawalLimit,
    double? dailyUsed,
    double? monthlyUsed,
    int? kycTier,
    String? tierName,
    String? kycStatus,
    String? upgradeMessage,
    String? nextTierName,
    double? nextTierDailyLimit,
    double? nextTierMonthlyLimit,
    DateTime? resetTime,
    int? hoursUntilReset,
    int? minutesUntilReset,
    bool? overrideActive,
    String? overrideReason,
    DateTime? overrideExpiresAt,
    MoneyFlowPermissions? permissions,
  }) {
    return TransactionLimits(
      dailyLimit: dailyLimit ?? this.dailyLimit,
      dailyDepositLimit: dailyDepositLimit ?? this.dailyDepositLimit,
      dailyDepositUsed: dailyDepositUsed ?? this.dailyDepositUsed,
      dailyWithdrawLimit: dailyWithdrawLimit ?? this.dailyWithdrawLimit,
      dailyWithdrawUsed: dailyWithdrawUsed ?? this.dailyWithdrawUsed,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      singleTransactionLimit:
          singleTransactionLimit ?? this.singleTransactionLimit,
      withdrawalLimit: withdrawalLimit ?? this.withdrawalLimit,
      dailyUsed: dailyUsed ?? this.dailyUsed,
      monthlyUsed: monthlyUsed ?? this.monthlyUsed,
      kycTier: kycTier ?? this.kycTier,
      tierName: tierName ?? this.tierName,
      kycStatus: kycStatus ?? this.kycStatus,
      upgradeMessage: upgradeMessage ?? this.upgradeMessage,
      nextTierName: nextTierName ?? this.nextTierName,
      nextTierDailyLimit: nextTierDailyLimit ?? this.nextTierDailyLimit,
      nextTierMonthlyLimit: nextTierMonthlyLimit ?? this.nextTierMonthlyLimit,
      resetTime: resetTime ?? this.resetTime,
      hoursUntilReset: hoursUntilReset ?? this.hoursUntilReset,
      minutesUntilReset: minutesUntilReset ?? this.minutesUntilReset,
      overrideActive: overrideActive ?? this.overrideActive,
      overrideReason: overrideReason ?? this.overrideReason,
      overrideExpiresAt: overrideExpiresAt ?? this.overrideExpiresAt,
      permissions: permissions ?? this.permissions,
    );
  }

  // Helper getters
  double get dailyRemaining => (dailyLimit - dailyUsed).clamp(0.0, dailyLimit);
  double get dailyDepositRemaining {
    final limit = dailyDepositLimit > 0 ? dailyDepositLimit : dailyLimit;
    return (limit - dailyDepositUsed).clamp(0.0, limit);
  }

  double get dailyWithdrawRemaining {
    final limit = dailyWithdrawLimit > 0 ? dailyWithdrawLimit : dailyLimit;
    return (limit - dailyWithdrawUsed).clamp(0.0, limit);
  }

  double get monthlyRemaining =>
      (monthlyLimit - monthlyUsed).clamp(0.0, monthlyLimit);
  double get dailyPercentage =>
      dailyLimit > 0 ? (dailyUsed / dailyLimit).clamp(0.0, 1.0) : 0.0;
  double get monthlyPercentage =>
      monthlyLimit > 0 ? (monthlyUsed / monthlyLimit).clamp(0.0, 1.0) : 0.0;
  bool get isDailyNearLimit => dailyPercentage >= 0.8;
  bool get isDailyAtLimit => dailyPercentage >= 1.0;
  bool get isMonthlyNearLimit => monthlyPercentage >= 0.8;
  bool get isMonthlyAtLimit => monthlyPercentage >= 1.0;
  bool get hasNextTier => nextTierName != null;
  bool get hasActiveOverride => overrideActive;

  double dailyLimitFor(TransactionLimitOperation operation) {
    return switch (operation) {
      TransactionLimitOperation.send => dailyLimit,
      TransactionLimitOperation.deposit =>
        dailyDepositLimit > 0 ? dailyDepositLimit : dailyLimit,
      TransactionLimitOperation.withdraw =>
        dailyWithdrawLimit > 0 ? dailyWithdrawLimit : dailyLimit,
    };
  }

  double dailyUsedFor(TransactionLimitOperation operation) {
    return switch (operation) {
      TransactionLimitOperation.send => dailyUsed,
      TransactionLimitOperation.deposit => dailyDepositUsed,
      TransactionLimitOperation.withdraw => dailyWithdrawUsed,
    };
  }

  double dailyRemainingFor(TransactionLimitOperation operation) {
    return switch (operation) {
      TransactionLimitOperation.send => dailyRemaining,
      TransactionLimitOperation.deposit => dailyDepositRemaining,
      TransactionLimitOperation.withdraw => dailyWithdrawRemaining,
    };
  }

  double dailyPercentageFor(TransactionLimitOperation operation) {
    final limit = dailyLimitFor(operation);
    return limit > 0 ? (dailyUsedFor(operation) / limit).clamp(0.0, 1.0) : 0.0;
  }

  bool isDailyNearLimitFor(TransactionLimitOperation operation) {
    return dailyPercentageFor(operation) >= 0.8;
  }

  bool isDailyAtLimitFor(TransactionLimitOperation operation) {
    return dailyPercentageFor(operation) >= 1.0;
  }

  double get effectiveMax {
    return effectiveMaxFor(TransactionLimitOperation.send);
  }

  double effectiveMaxFor(TransactionLimitOperation operation) {
    if (!permissions.can(operation)) {
      return 0;
    }

    final dailyForOperation = switch (operation) {
      TransactionLimitOperation.send => dailyRemaining,
      TransactionLimitOperation.deposit => dailyDepositRemaining,
      TransactionLimitOperation.withdraw => dailyWithdrawRemaining,
    };
    final operationLimit = operation == TransactionLimitOperation.withdraw
        ? withdrawalLimit
        : singleTransactionLimit;
    final candidates = [
      dailyForOperation,
      monthlyRemaining,
      operationLimit,
    ].where((value) => value > 0).toList();
    if (candidates.isEmpty) {
      return 0;
    }
    return candidates.reduce((a, b) => a < b ? a : b);
  }

  String? limitHitBy(double amount) {
    return limitHitByFor(TransactionLimitOperation.send, amount);
  }

  String? limitHitByFor(TransactionLimitOperation operation, double amount) {
    if (!permissions.can(operation)) {
      return permissions.reviewRequired
          ? 'manual_review_required'
          : 'kyc_required';
    }

    final operationLimit = operation == TransactionLimitOperation.withdraw
        ? withdrawalLimit
        : singleTransactionLimit;
    if (amount > operationLimit && operationLimit > 0) {
      return 'single_transaction';
    }
    final dailyLimit = dailyLimitFor(operation);
    if (dailyLimit > 0 && amount > dailyRemainingFor(operation)) {
      return 'daily';
    }
    if (monthlyLimit > 0 && amount > monthlyRemaining) {
      return 'monthly';
    }
    return null;
  }
}

Map<String, dynamic> _mapOf(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return const {};
}

Map<String, dynamic>? _nullableMapOf(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return null;
}

double? _numberOf(Object? value) {
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value);
  }
  return null;
}

bool? _boolOf(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
        return true;
      }
      if (normalized == 'false' || normalized == '0' || normalized == 'no') {
        return false;
      }
    }
  }
  return null;
}

String? _stringOf(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.isNotEmpty) {
      return value;
    }
  }
  return null;
}

DateTime? _dateOf(Object? value) {
  if (value is! String || value.isEmpty) {
    return null;
  }
  return DateTime.tryParse(value);
}

int _tierNumberFromName(String? tier) {
  switch (tier?.toLowerCase()) {
    case 'basic':
      return 1;
    case 'verified':
      return 2;
    case 'premium':
      return 3;
    case 'unverified':
    default:
      return 0;
  }
}

String _tierDisplayName(String? tier) {
  switch (tier?.toLowerCase()) {
    case 'basic':
      return 'Basic';
    case 'verified':
      return 'Verified';
    case 'premium':
      return 'Premium';
    case 'unverified':
    default:
      return 'Unverified';
  }
}
