import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

class TransactionLimits {
  final double singleTransactionMax;
  final double dailyMax;
  final double weeklyMax;
  final double monthlyMax;
  final int dailyCountMax;
  final double crossBorderDailyMax;

  const TransactionLimits({
    this.singleTransactionMax = 5000000,
    this.dailyMax = 10000000,
    this.weeklyMax = 25000000,
    this.monthlyMax = 50000000,
    this.dailyCountMax = 50,
    this.crossBorderDailyMax = 2000000,
  });

  factory TransactionLimits.fromJson(Map<String, dynamic> json) =>
      TransactionLimits(
        singleTransactionMax:
            ((json['singleTransactionMax'] ?? json['singleTransactionLimit'])
                    as num?)
                ?.toDouble() ??
            5000000,
        dailyMax:
            ((json['dailyMax'] ?? json['dailyLimit']) as num?)?.toDouble() ??
            10000000,
        weeklyMax:
            ((json['weeklyMax'] ?? json['weeklyLimit']) as num?)?.toDouble() ??
            25000000,
        monthlyMax:
            ((json['monthlyMax'] ?? json['monthlyLimit']) as num?)
                ?.toDouble() ??
            50000000,
        dailyCountMax: json['dailyCountMax'] as int? ?? 50,
        crossBorderDailyMax:
            (json['crossBorderDailyMax'] as num?)?.toDouble() ?? 2000000,
      );
}

class LimitCheckResult {
  final bool withinLimits;
  final String? violatedLimit;
  final double? remaining;

  const LimitCheckResult({
    required this.withinLimits,
    this.violatedLimit,
    this.remaining,
  });
}

/// Gestionnaire des limites de transaction.
///
/// Applique les limites réglementaires et de tier KYC
/// sur les transactions.
class TransactionLimitManager {
  static const _tag = 'TransactionLimits';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;
  TransactionLimits? _limits;

  TransactionLimitManager({required Dio dio}) : _dio = dio;

  Future<TransactionLimits> getLimits() async {
    if (_limits != null) return _limits!;
    try {
      final response = await _dio.get('/user/limits');
      final raw = response.data;
      final data =
          raw is Map<String, dynamic> && raw['data'] is Map<String, dynamic>
          ? raw['data'] as Map<String, dynamic>
          : raw is Map<String, dynamic>
          ? raw
          : const <String, dynamic>{};
      _limits = TransactionLimits.fromJson(data);
      return _limits!;
    } catch (e) {
      _log.error('Failed to fetch limits', e);
      return const TransactionLimits();
    }
  }

  Future<LimitCheckResult> checkTransaction({
    required double amount,
    bool isCrossBorder = false,
  }) async {
    final limits = await getLimits();
    if (amount > limits.singleTransactionMax) {
      return LimitCheckResult(
        withinLimits: false,
        violatedLimit: 'Transaction unique maximale',
        remaining: limits.singleTransactionMax,
      );
    }
    if (isCrossBorder && amount > limits.crossBorderDailyMax) {
      return LimitCheckResult(
        withinLimits: false,
        violatedLimit: 'Limite transfrontalière journalière',
        remaining: limits.crossBorderDailyMax,
      );
    }
    return const LimitCheckResult(withinLimits: true);
  }

  void invalidateCache() => _limits = null;
}

final transactionLimitManagerProvider = Provider<TransactionLimitManager>((
  ref,
) {
  throw UnimplementedError('Override in ProviderScope');
});
