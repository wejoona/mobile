import 'package:flutter/foundation.dart';

/// Transaction filter model for advanced search and filtering
/// Supports type, status, date range, amount range, text search, and sorting
@immutable
class TransactionFilter {
  /// Filter by transaction type
  final String? type;

  /// Filter by transaction status
  final String? status;

  /// Filter transactions from this date
  final DateTime? startDate;

  /// Filter transactions until this date
  final DateTime? endDate;

  /// Filter transactions with amount >= minAmount
  final double? minAmount;

  /// Filter transactions with amount <= maxAmount
  final double? maxAmount;

  /// Search by reference, description, or recipient
  final String? search;

  /// Field to sort by (createdAt or amount)
  final String sortBy;

  /// Sort order (ASC or DESC)
  final String sortOrder;

  const TransactionFilter({
    this.type,
    this.status,
    this.startDate,
    this.endDate,
    this.minAmount,
    this.maxAmount,
    this.search,
    this.sortBy = 'createdAt',
    this.sortOrder = 'DESC',
  });

  /// Convert to query parameters for API call
  Map<String, dynamic> toQueryParams() {
    return {
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (startDate != null) 'startDate': startDate!.toUtc().toIso8601String(),
      if (endDate != null) 'endDate': endDate!.toUtc().toIso8601String(),
      if (minAmount != null) 'minAmount': minAmount,
      if (maxAmount != null) 'maxAmount': maxAmount,
      if (search != null && search!.isNotEmpty) 'search': search,
      'sortBy': sortBy,
      'sortOrder': sortOrder,
    };
  }

  /// Check if any filters are active (excluding sort)
  bool get hasActiveFilters =>
      type != null ||
      status != null ||
      startDate != null ||
      endDate != null ||
      minAmount != null ||
      maxAmount != null;

  /// Count of active filters (for badge display)
  int get activeFilterCount {
    int count = 0;
    if (type != null) count++;
    if (status != null) count++;
    if (startDate != null || endDate != null) count++;
    if (minAmount != null || maxAmount != null) count++;
    return count;
  }

  /// Check if there's an active search query
  bool get hasSearchQuery => search != null && search!.isNotEmpty;

  /// Create a copy with modified values
  TransactionFilter copyWith({
    String? type,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
    String? search,
    String? sortBy,
    String? sortOrder,
    bool clearType = false,
    bool clearStatus = false,
    bool clearDateRange = false,
    bool clearAmountRange = false,
    bool clearSearch = false,
  }) {
    return TransactionFilter(
      type: clearType ? null : (type ?? this.type),
      status: clearStatus ? null : (status ?? this.status),
      startDate: clearDateRange ? null : (startDate ?? this.startDate),
      endDate: clearDateRange ? null : (endDate ?? this.endDate),
      minAmount: clearAmountRange ? null : (minAmount ?? this.minAmount),
      maxAmount: clearAmountRange ? null : (maxAmount ?? this.maxAmount),
      search: clearSearch ? null : (search ?? this.search),
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  /// Reset all filters to default
  TransactionFilter clear() {
    return const TransactionFilter();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionFilter &&
        other.type == type &&
        other.status == status &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.minAmount == minAmount &&
        other.maxAmount == maxAmount &&
        other.search == search &&
        other.sortBy == sortBy &&
        other.sortOrder == sortOrder;
  }

  @override
  int get hashCode {
    return Object.hash(
      type,
      status,
      startDate,
      endDate,
      minAmount,
      maxAmount,
      search,
      sortBy,
      sortOrder,
    );
  }

  @override
  String toString() {
    return 'TransactionFilter(type: $type, status: $status, startDate: $startDate, '
        'endDate: $endDate, minAmount: $minAmount, maxAmount: $maxAmount, '
        'search: $search, sortBy: $sortBy, sortOrder: $sortOrder)';
  }
}

/// Predefined date range options for quick selection
enum DateRangeOption {
  today,
  thisWeek,
  thisMonth,
  lastMonth,
  last3Months,
  thisYear,
  custom,
}

extension DateRangeOptionExt on DateRangeOption {
  String get label {
    switch (this) {
      case DateRangeOption.today:
        return 'Today';
      case DateRangeOption.thisWeek:
        return 'This Week';
      case DateRangeOption.thisMonth:
        return 'This Month';
      case DateRangeOption.lastMonth:
        return 'Last Month';
      case DateRangeOption.last3Months:
        return 'Last 3 Months';
      case DateRangeOption.thisYear:
        return 'This Year';
      case DateRangeOption.custom:
        return 'Custom';
    }
  }

  /// Get date range for the option
  ({DateTime start, DateTime end}) get dateRange {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (this) {
      case DateRangeOption.today:
        return (
          start: today,
          end: today.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1)),
        );
      case DateRangeOption.thisWeek:
        final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
        return (
          start: startOfWeek,
          end: now,
        );
      case DateRangeOption.thisMonth:
        return (
          start: DateTime(now.year, now.month, 1),
          end: now,
        );
      case DateRangeOption.lastMonth:
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        final endOfLastMonth = DateTime(now.year, now.month, 0, 23, 59, 59);
        return (
          start: lastMonth,
          end: endOfLastMonth,
        );
      case DateRangeOption.last3Months:
        return (
          start: DateTime(now.year, now.month - 3, now.day),
          end: now,
        );
      case DateRangeOption.thisYear:
        return (
          start: DateTime(now.year, 1, 1),
          end: now,
        );
      case DateRangeOption.custom:
        return (start: today, end: now);
    }
  }
}
