import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

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
  Timer(const Duration(minutes: 10), () => link.close());

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
  final alerts = ref.watch(activeAlertsProvider).valueOrNull ?? [];
  final dismissed = ref.watch(dismissedAlertsProvider);
  return alerts.where((a) => !dismissed.contains(a.id)).toList();
});
