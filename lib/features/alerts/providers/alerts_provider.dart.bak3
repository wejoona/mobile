/// Alerts Provider
/// Riverpod state management for transaction alerts
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../services/api/api_client.dart';
import '../models/index.dart';

/// Alerts state
class AlertsState {
  final List<TransactionAlert> alerts;
  final int unreadCount;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final bool hasMore;
  final AlertStatistics? statistics;

  const AlertsState({
    this.alerts = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = false,
    this.statistics,
  });

  AlertsState copyWith({
    List<TransactionAlert>? alerts,
    int? unreadCount,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    bool? hasMore,
    AlertStatistics? statistics,
  }) {
    return AlertsState(
      alerts: alerts ?? this.alerts,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      statistics: statistics ?? this.statistics,
    );
  }
}

/// Alerts notifier
class AlertsNotifier extends Notifier<AlertsState> {
  @override
  AlertsState build() {
    return const AlertsState();
  }

  Dio get _dio => ref.read(dioProvider);

  /// Load alerts
  Future<void> loadAlerts({bool refresh = false}) async {
    if (state.isLoading && !refresh) return;

    state = state.copyWith(
      isLoading: true,
      error: null,
      currentPage: refresh ? 1 : state.currentPage,
    );

    try {
      final response = await _dio.get('/alerts', queryParameters: {
        'page': refresh ? 1 : state.currentPage,
        'limit': 20,
      });

      final paginatedAlerts = PaginatedAlerts.fromJson(
        response.data as Map<String, dynamic>,
      );

      state = state.copyWith(
        alerts: refresh
            ? paginatedAlerts.alerts
            : [...state.alerts, ...paginatedAlerts.alerts],
        isLoading: false,
        currentPage: paginatedAlerts.page,
        hasMore: paginatedAlerts.hasNext,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );
    }
  }

  /// Load more alerts (pagination)
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final response = await _dio.get('/alerts', queryParameters: {
        'page': state.currentPage + 1,
        'limit': 20,
      });

      final paginatedAlerts = PaginatedAlerts.fromJson(
        response.data as Map<String, dynamic>,
      );

      state = state.copyWith(
        alerts: [...state.alerts, ...paginatedAlerts.alerts],
        isLoadingMore: false,
        currentPage: paginatedAlerts.page,
        hasMore: paginatedAlerts.hasNext,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: _getErrorMessage(e),
      );
    }
  }

  /// Load unread count
  Future<void> loadUnreadCount() async {
    try {
      final response = await _dio.get('/alerts/count');
      final count = response.data['count'] as int;

      state = state.copyWith(unreadCount: count);
    } catch (e) {
      // Silently fail for count
    }
  }

  /// Load alert statistics
  Future<void> loadStatistics() async {
    try {
      final response = await _dio.get('/alerts/statistics');
      final stats = AlertStatistics.fromJson(
        response.data as Map<String, dynamic>,
      );

      state = state.copyWith(
        statistics: stats,
        unreadCount: stats.unread,
      );
    } catch (e) {
      // Silently fail for statistics
    }
  }

  /// Mark alert as read
  Future<void> markAsRead(String alertId) async {
    try {
      await _dio.post('/alerts/$alertId/read');

      final updatedAlerts = state.alerts.map((alert) {
        if (alert.alertId == alertId) {
          return alert.copyWith(isRead: true);
        }
        return alert;
      }).toList();

      state = state.copyWith(
        alerts: updatedAlerts,
        unreadCount: (state.unreadCount - 1).clamp(0, state.unreadCount),
      );
    } catch (e) {
      state = state.copyWith(error: _getErrorMessage(e));
    }
  }

  /// Mark all alerts as read
  Future<void> markAllAsRead() async {
    try {
      await _dio.post('/alerts/read-all');

      final updatedAlerts = state.alerts.map((alert) {
        return alert.copyWith(isRead: true);
      }).toList();

      state = state.copyWith(
        alerts: updatedAlerts,
        unreadCount: 0,
      );
    } catch (e) {
      state = state.copyWith(error: _getErrorMessage(e));
    }
  }

  /// Take action on alert
  Future<bool> takeAction(String alertId, AlertAction action, {String? notes}) async {
    try {
      final response = await _dio.post('/alerts/$alertId/action', data: {
        'action': action.value,
        if (notes != null) 'notes': notes,
      });

      final updatedAlert = TransactionAlert.fromJson(
        response.data as Map<String, dynamic>,
      );

      final updatedAlerts = state.alerts.map((alert) {
        if (alert.alertId == alertId) {
          return updatedAlert;
        }
        return alert;
      }).toList();

      state = state.copyWith(alerts: updatedAlerts);
      return true;
    } catch (e) {
      state = state.copyWith(error: _getErrorMessage(e));
      return false;
    }
  }

  /// Add new alert (from WebSocket/push notification)
  void addAlert(TransactionAlert alert) {
    final alerts = [alert, ...state.alerts];
    state = state.copyWith(
      alerts: alerts,
      unreadCount: state.unreadCount + 1,
    );
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  String _getErrorMessage(dynamic error) {
    if (error is DioException) {
      return error.response?.data?['message']?.toString() ??
          'An error occurred';
    }
    return 'An unexpected error occurred';
  }
}

/// Alerts provider
final alertsProvider = NotifierProvider<AlertsNotifier, AlertsState>(
  AlertsNotifier.new,
);

/// Unread count provider (for badge)
final alertsUnreadCountProvider = Provider<int>((ref) {
  return ref.watch(alertsProvider).unreadCount;
});

/// Single alert provider
final alertDetailProvider = FutureProvider.family<TransactionAlert?, String>((ref, alertId) async {
  final dio = ref.watch(dioProvider);

  try {
    final response = await dio.get('/alerts/$alertId');
    return TransactionAlert.fromJson(response.data as Map<String, dynamic>);
  } catch (e) {
    return null;
  }
});

/// Unread alerts provider
final unreadAlertsProvider = FutureProvider<List<TransactionAlert>>((ref) async {
  final dio = ref.watch(dioProvider);

  try {
    final response = await dio.get('/alerts/unread');
    return (response.data as List)
        .map((a) => TransactionAlert.fromJson(a as Map<String, dynamic>))
        .toList();
  } catch (e) {
    return [];
  }
});

/// Action required alerts provider
final actionRequiredAlertsProvider = FutureProvider<List<TransactionAlert>>((ref) async {
  final dio = ref.watch(dioProvider);

  try {
    final response = await dio.get('/alerts/action-required');
    return (response.data as List)
        .map((a) => TransactionAlert.fromJson(a as Map<String, dynamic>))
        .toList();
  } catch (e) {
    return [];
  }
});
