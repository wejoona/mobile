import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/core/constants/api_endpoints.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

/// Transaction statistics from GET /wallet/transactions/stats — wired to Dio.
class TransactionStats {
  final int totalCount;
  final int depositCount;
  final int withdrawalCount;
  final int transferCount;
  final double totalDeposited;
  final double totalWithdrawn;
  final double totalTransferred;
  final double netFlow;

  const TransactionStats({
    this.totalCount = 0,
    this.depositCount = 0,
    this.withdrawalCount = 0,
    this.transferCount = 0,
    this.totalDeposited = 0,
    this.totalWithdrawn = 0,
    this.totalTransferred = 0,
    this.netFlow = 0,
  });

  factory TransactionStats.fromJson(Map<String, dynamic> json) {
    final totalDeposited = (json['totalDeposited'] as num?)?.toDouble() ?? 0;
    final totalWithdrawn = (json['totalWithdrawn'] as num?)?.toDouble() ?? 0;
    final totalTransferred =
        (json['totalTransferred'] as num?)?.toDouble() ?? 0;

    return TransactionStats(
      totalCount:
          json['totalCount'] as int? ?? json['totalTransactions'] as int? ?? 0,
      depositCount:
          json['depositCount'] as int? ?? json['totalDeposits'] as int? ?? 0,
      withdrawalCount:
          json['withdrawalCount'] as int? ??
          json['totalWithdrawals'] as int? ??
          0,
      transferCount:
          json['transferCount'] as int? ?? json['totalTransfers'] as int? ?? 0,
      totalDeposited: totalDeposited,
      totalWithdrawn: totalWithdrawn,
      totalTransferred: totalTransferred,
      netFlow:
          (json['netFlow'] as num?)?.toDouble() ??
          totalDeposited - totalWithdrawn - totalTransferred,
    );
  }
}

final transactionStatsProvider = FutureProvider<TransactionStats>((ref) async {
  final dio = ref.watch(dioProvider);
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 5), () => link.close());
  ref.onDispose(() => timer.cancel());

  final response = await dio.get(ApiEndpoints.walletTransactionStats);
  return TransactionStats.fromJson(response.data as Map<String, dynamic>);
});
