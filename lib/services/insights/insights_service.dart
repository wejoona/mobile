import 'package:flutter/material.dart';
import 'package:usdc_wallet/domain/entities/transaction.dart';
import 'package:usdc_wallet/domain/enums/index.dart';
import 'package:usdc_wallet/features/insights/models/insights_period.dart';
import 'package:usdc_wallet/features/insights/models/spending_category.dart';
import 'package:usdc_wallet/features/insights/models/spending_summary.dart';
import 'package:usdc_wallet/features/insights/models/spending_trend.dart';
import 'package:usdc_wallet/features/insights/models/top_recipient.dart';
import 'package:usdc_wallet/design/tokens/colors.dart';

/// Service for calculating spending insights and analytics
class InsightsService {
  /// Get spending summary for a period
  SpendingSummary getSpendingSummary(
    List<Transaction> transactions,
    InsightsPeriod period,
  ) {
    final now = DateTime.now();
    final startDate = _getStartDate(now, period);
    final previousStartDate = _getPreviousStartDate(startDate, period);

    // Filter transactions for current period
    final currentPeriodTxns = transactions.where((txn) {
      return txn.createdAt.isAfter(startDate) &&
          txn.isCompleted &&
          txn.createdAt.isBefore(now);
    }).toList();

    // Filter transactions for previous period
    final previousPeriodTxns = transactions.where((txn) {
      return txn.createdAt.isAfter(previousStartDate) &&
          txn.createdAt.isBefore(startDate) &&
          txn.isCompleted;
    }).toList();

    // Calculate totals
    final totalSpent = currentPeriodTxns
        .where((t) => _isSpending(t))
        .fold(0.0, (sum, t) => sum + t.amount);

    final totalReceived = currentPeriodTxns
        .where((t) => _isIncome(t))
        .fold(0.0, (sum, t) => sum + t.amount);

    final netFlow = totalReceived - totalSpent;

    // Calculate previous period spending
    final previousSpent = previousPeriodTxns
        .where((t) => _isSpending(t))
        .fold(0.0, (sum, t) => sum + t.amount);

    // Calculate percentage change
    final percentageChange = previousSpent > 0
        ? ((totalSpent - previousSpent) / previousSpent) * 100
        : 0.0;
    final isIncrease = totalSpent > previousSpent;

    // Get top categories
    final categories = getSpendingByCategory(transactions, period);
    final topCategories = categories.take(3).toList();

    return SpendingSummary(
      totalSpent: totalSpent,
      totalReceived: totalReceived,
      netFlow: netFlow,
      topCategories: topCategories,
      percentageChange: percentageChange.abs(),
      isIncrease: isIncrease,
    );
  }

  /// Get spending breakdown by category
  List<SpendingCategory> getSpendingByCategory(
    List<Transaction> transactions,
    InsightsPeriod period,
  ) {
    final now = DateTime.now();
    final startDate = _getStartDate(now, period);

    // Filter spending transactions for period
    final spendingTxns = transactions.where((txn) {
      return txn.createdAt.isAfter(startDate) &&
          txn.isCompleted &&
          txn.createdAt.isBefore(now) &&
          _isSpending(txn);
    }).toList();

    final totalSpent = spendingTxns.fold(0.0, (sum, t) => sum + t.amount);

    if (totalSpent == 0) return [];

    // Group by category
    final categoryMap = <String, List<Transaction>>{};
    for (final txn in spendingTxns) {
      final category = _getCategoryName(txn);
      categoryMap.putIfAbsent(category, () => []).add(txn);
    }

    // Create category summaries
    final categories = categoryMap.entries.map((entry) {
      final amount = entry.value.fold(0.0, (sum, t) => sum + t.amount);
      final percentage = (amount / totalSpent) * 100;

      return SpendingCategory(
        name: entry.key,
        amount: amount,
        percentage: percentage,
        color: _getCategoryColor(entry.key),
        transactionCount: entry.value.length,
      );
    }).toList();

    // Sort by amount descending
    categories.sort((a, b) => b.amount.compareTo(a.amount));

    return categories;
  }

  /// Get spending trend over time
  List<SpendingTrend> getSpendingTrend(
    List<Transaction> transactions,
    InsightsPeriod period,
  ) {
    final now = DateTime.now();
    final startDate = _getStartDate(now, period);

    // Filter spending transactions
    final spendingTxns = transactions.where((txn) {
      return txn.createdAt.isAfter(startDate) &&
          txn.isCompleted &&
          txn.createdAt.isBefore(now) &&
          _isSpending(txn);
    }).toList();

    // Group by date interval
    final intervalDays = _getIntervalDays(period);
    final trendMap = <DateTime, double>{};

    for (final txn in spendingTxns) {
      final intervalDate = _roundToInterval(txn.createdAt, intervalDays);
      trendMap[intervalDate] = (trendMap[intervalDate] ?? 0) + txn.amount;
    }

    // Create trend points
    final trends = <SpendingTrend>[];
    var currentDate = startDate;
    while (currentDate.isBefore(now)) {
      final intervalDate = _roundToInterval(currentDate, intervalDays);
      final amount = trendMap[intervalDate] ?? 0;
      trends.add(SpendingTrend(date: intervalDate, amount: amount));
      currentDate = currentDate.add(Duration(days: intervalDays));
    }

    return trends;
  }

  /// Get top recipients by amount sent
  List<TopRecipient> getTopRecipients(
    List<Transaction> transactions,
    InsightsPeriod period,
  ) {
    final now = DateTime.now();
    final startDate = _getStartDate(now, period);

    // Filter sent transactions
    final sentTxns = transactions.where((txn) {
      return txn.createdAt.isAfter(startDate) &&
          txn.isCompleted &&
          txn.createdAt.isBefore(now) &&
          (txn.type == TransactionType.transferInternal ||
              txn.type == TransactionType.transferExternal);
    }).toList();

    final totalSent = sentTxns.fold(0.0, (sum, t) => sum + t.amount);

    if (totalSent == 0) return [];

    // Group by recipient
    final recipientMap = <String, List<Transaction>>{};
    for (final txn in sentTxns) {
      final recipientId = txn.recipientWalletId ??
          txn.recipientPhone ??
          txn.recipientAddress ??
          'unknown';
      recipientMap.putIfAbsent(recipientId, () => []).add(txn);
    }

    // Create recipient summaries
    final recipients = recipientMap.entries.map((entry) {
      final txns = entry.value;
      final amount = txns.fold(0.0, (sum, t) => sum + t.amount);
      final percentage = (amount / totalSent) * 100;
      final firstTxn = txns.first;

      // Extract name from metadata or use phone/address
      final name = firstTxn.metadata?['recipientName'] as String? ??
          firstTxn.recipientPhone ??
          firstTxn.recipientAddress?.substring(0, 10) ??
          'Unknown';

      return TopRecipient(
        id: entry.key,
        name: name,
        phoneNumber: firstTxn.recipientPhone,
        avatarUrl: firstTxn.metadata?['recipientAvatar'] as String?,
        totalSent: amount,
        percentage: percentage,
        transactionCount: txns.length,
      );
    }).toList();

    // Sort by amount descending and take top 5
    recipients.sort((a, b) => b.totalSent.compareTo(a.totalSent));
    return recipients.take(5).toList();
  }

  // Helper methods

  DateTime _getStartDate(DateTime now, InsightsPeriod period) {
    switch (period) {
      case InsightsPeriod.week:
        return now.subtract(const Duration(days: 7));
      case InsightsPeriod.month:
        return now.subtract(const Duration(days: 30));
      case InsightsPeriod.year:
        return now.subtract(const Duration(days: 365));
    }
  }

  DateTime _getPreviousStartDate(DateTime startDate, InsightsPeriod period) {
    switch (period) {
      case InsightsPeriod.week:
        return startDate.subtract(const Duration(days: 7));
      case InsightsPeriod.month:
        return startDate.subtract(const Duration(days: 30));
      case InsightsPeriod.year:
        return startDate.subtract(const Duration(days: 365));
    }
  }

  int _getIntervalDays(InsightsPeriod period) {
    switch (period) {
      case InsightsPeriod.week:
        return 1; // Daily
      case InsightsPeriod.month:
        return 3; // Every 3 days
      case InsightsPeriod.year:
        return 30; // Monthly
    }
  }

  DateTime _roundToInterval(DateTime date, int intervalDays) {
    final daysSinceEpoch = date.difference(DateTime(1970)).inDays;
    final roundedDays = (daysSinceEpoch ~/ intervalDays) * intervalDays;
    return DateTime(1970).add(Duration(days: roundedDays));
  }

  bool _isSpending(Transaction txn) {
    return txn.type == TransactionType.withdrawal ||
        txn.type == TransactionType.transferExternal ||
        (txn.type == TransactionType.transferInternal && txn.amount < 0);
  }

  bool _isIncome(Transaction txn) {
    return txn.type == TransactionType.deposit ||
        (txn.type == TransactionType.transferInternal && txn.amount > 0);
  }

  String _getCategoryName(Transaction txn) {
    // Check metadata for category
    if (txn.metadata != null && txn.metadata!.containsKey('category')) {
      return txn.metadata!['category'] as String;
    }

    // Categorize by type
    switch (txn.type) {
      case TransactionType.withdrawal:
        return 'Bills';
      case TransactionType.transferExternal:
      case TransactionType.transferInternal:
        return 'Transfers';
      case TransactionType.deposit:
        return 'Deposits';
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'transfers':
        return AppColors.gold500;
      case 'bills':
        return AppColors.infoBase;
      case 'deposits':
        return AppColors.successBase;
      default:
        return AppColors.textSecondary;
    }
  }
}
