import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/features/alerts/models/alert_model.dart';

/// Alert types in the app.
enum AlertType { info, warning, error, promotion }

/// In-app alert model.
class AppAlert {
  final String id;
  final String title;
  final String message;
  final AlertType type;
  final bool isDismissible;
  final String? actionUrl;
  final DateTime createdAt;

  const AppAlert({
    required this.id,
    required this.title,
    required this.message,
    this.type = AlertType.info,
    this.isDismissible = true,
    this.actionUrl,
    required this.createdAt,
  });

  factory AppAlert.fromJson(Map<String, dynamic> json) => AppAlert(
    id: json['id'] as String,
    title: json['title'] as String? ?? '',
    message: json['message'] as String? ?? '',
    type: AlertType.values.firstWhere(
      (t) => t.name == json['type'],
      orElse: () => AlertType.info,
    ),
    isDismissible: json['isDismissible'] as bool? ?? true,
    actionUrl: json['actionUrl'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

/// Active alerts provider — fetches from /alerts endpoint.
final activeAlertsProvider = FutureProvider<List<AppAlert>>((ref) async {
  final dio = ref.watch(dioProvider);
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 10), () => link.close());
  ref.onDispose(() => timer.cancel());

  try {
    final response = await dio.get('/alerts');
    final data = response.data;
    final items = (data is Map ? data['data'] : data) as List? ?? [];
    return items.map((e) => AppAlert.fromJson(e as Map<String, dynamic>)).toList();
  } catch (_) {
    // Alerts are non-critical — return empty on failure
    return [];
  }
});

/// Dismissed alert IDs (stored locally).
final dismissedAlertsProvider = StateProvider<Set<String>>((ref) => {});

/// Visible alerts (active minus dismissed).
final visibleAlertsProvider = Provider<List<AppAlert>>((ref) {
  final alerts = ref.watch(activeAlertsProvider).value ?? [];
  final dismissed = ref.watch(dismissedAlertsProvider);
  return alerts.where((a) => !dismissed.contains(a.id)).toList();
});

/// Alerts list state for the full alerts feature.
class AlertsListState {
  final List<TransactionAlert> alerts;
  final AlertStatistics? statistics;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int unreadCount;
  final bool isLoadingMore;

  const AlertsListState({
    this.alerts = const [],
    this.statistics,
    this.isLoading = false,
    this.error,
    this.hasMore = false,
    this.unreadCount = 0,
    this.isLoadingMore = false,
  });

  AlertsListState copyWith({
    List<TransactionAlert>? alerts,
    AlertStatistics? statistics,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? unreadCount,
    bool? isLoadingMore,
  }) => AlertsListState(
    alerts: alerts ?? this.alerts,
    statistics: statistics ?? this.statistics,
    isLoading: isLoading ?? this.isLoading,
    error: error,
    hasMore: hasMore ?? this.hasMore,
    unreadCount: unreadCount ?? this.unreadCount,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );
}

/// Alerts notifier — manages paginated alerts list.
class AlertsNotifier extends Notifier<AlertsListState> {
  int _page = 1;

  @override
  AlertsListState build() {
    Future.microtask(() => loadAlerts());
    return const AlertsListState(isLoading: true);
  }

  Future<void> loadAlerts({bool refresh = false}) async {
    if (refresh) _page = 1;
    state = state.copyWith(isLoading: true);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/alerts', queryParameters: {'page': _page, 'limit': 20});
      final data = response.data as Map<String, dynamic>;
      final paginated = PaginatedAlerts.fromJson(data);
      state = state.copyWith(
        alerts: refresh ? paginated.alerts : [...state.alerts, ...paginated.alerts],
        isLoading: false,
        hasMore: paginated.hasNext,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;
    _page++;
    await loadAlerts();
  }

  Future<void> loadStatistics() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/alerts/statistics');
      final stats = AlertStatistics.fromJson(response.data as Map<String, dynamic>);
      state = state.copyWith(statistics: stats);
    } catch (_) {}
  }

  Future<void> markAsRead(String alertId) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.put('/alerts/$alertId/read');
      state = state.copyWith(
        alerts: state.alerts.map((a) => a.alertId == alertId ? a.copyWith(isRead: true) : a).toList(),
      );
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      final dio = ref.read(dioProvider);
      await dio.put('/alerts/read-all');
      state = state.copyWith(
        alerts: state.alerts.map((a) => a.copyWith(isRead: true)).toList(),
      );
    } catch (_) {}
  }

  Future<bool> takeAction(String alertId, String action) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/alerts/$alertId/action', data: {'action': action});
      return true;
    } catch (_) {
      return false;
    }
  }
}

/// Main alerts provider with full notifier.
final alertsProvider = NotifierProvider<AlertsNotifier, AlertsListState>(AlertsNotifier.new);

/// Alert detail provider — fetches a single alert by ID.
final alertDetailProvider = FutureProvider.family<TransactionAlert, String>((ref, alertId) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get('/alerts/$alertId');
  return TransactionAlert.fromJson(response.data as Map<String, dynamic>);
});

/// Unread alerts count provider.
final alertsUnreadCountProvider = Provider<int>((ref) {
  final state = ref.watch(alertsProvider);
  return state.alerts.where((a) => !a.isRead).length;
});
