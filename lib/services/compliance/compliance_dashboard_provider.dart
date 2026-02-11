import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';
import 'reporting_aggregator.dart';

/// Compliance dashboard state.
class ComplianceDashboardState {
  final ReportingSummary? dailySummary;
  final ReportingSummary? monthlySummary;
  final double complianceScore;
  final int pendingReports;
  final List<String> activeAlerts;
  final bool isLoading;

  const ComplianceDashboardState({
    this.dailySummary,
    this.monthlySummary,
    this.complianceScore = 100.0,
    this.pendingReports = 0,
    this.activeAlerts = const [],
    this.isLoading = false,
  });

  ComplianceDashboardState copyWith({
    ReportingSummary? dailySummary,
    ReportingSummary? monthlySummary,
    double? complianceScore,
    int? pendingReports,
    List<String>? activeAlerts,
    bool? isLoading,
  }) {
    return ComplianceDashboardState(
      dailySummary: dailySummary ?? this.dailySummary,
      monthlySummary: monthlySummary ?? this.monthlySummary,
      complianceScore: complianceScore ?? this.complianceScore,
      pendingReports: pendingReports ?? this.pendingReports,
      activeAlerts: activeAlerts ?? this.activeAlerts,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Provides compliance dashboard data.
class ComplianceDashboardNotifier
    extends StateNotifier<ComplianceDashboardState> {
  static const _tag = 'ComplianceDashboard';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  ComplianceDashboardNotifier({required Dio dio})
      : _dio = dio,
        super(const ComplianceDashboardState());

  /// Refresh dashboard data from backend.
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _dio.get('/compliance/dashboard');
      final data = response.data as Map<String, dynamic>;

      state = state.copyWith(
        complianceScore: (data['score'] as num?)?.toDouble() ?? 100.0,
        pendingReports: data['pendingReports'] as int? ?? 0,
        activeAlerts: List<String>.from(data['alerts'] ?? []),
        isLoading: false,
      );
    } catch (e) {
      _log.error('Failed to refresh compliance dashboard', e);
      state = state.copyWith(isLoading: false);
    }
  }
}

final complianceDashboardProvider = StateNotifierProvider<
    ComplianceDashboardNotifier, ComplianceDashboardState>((ref) {
  return ComplianceDashboardNotifier(dio: Dio());
});
