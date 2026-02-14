import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/services/performance/index.dart';

/// Performance Monitor View - Debug tool for viewing app performance metrics
class PerformanceMonitorView extends ConsumerStatefulWidget {
  const PerformanceMonitorView({super.key});

  @override
  ConsumerState<PerformanceMonitorView> createState() => _PerformanceMonitorViewState();
}

class _PerformanceMonitorViewState extends ConsumerState<PerformanceMonitorView> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final performanceService = ref.watch(performanceServiceProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: AppText('Performance Monitor', style: AppTypography.headlineSmall),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _clearMetrics(performanceService),
            tooltip: 'Clear metrics',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: _buildTabContent(performanceService),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.backgroundSecondary,
      child: Row(
        children: [
          _buildTab('Overview', 0),
          _buildTab('Screens', 1),
          _buildTab('API', 2),
          _buildTab('Frames', 3),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? context.colors.gold : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: AppText(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: isSelected ? context.colors.gold : context.colors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(PerformanceService service) {
    switch (_selectedTab) {
      case 0:
        return _buildOverviewTab(service);
      case 1:
        return _buildScreensTab(service);
      case 2:
        return _buildApiTab(service);
      case 3:
        return _buildFramesTab(service);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildOverviewTab(PerformanceService service) {
    final summary = service.getPerformanceSummary();

    return ListView(
      padding: EdgeInsets.all(AppSpacing.md),
      children: [
        _buildMetricCard(
          icon: Icons.speed,
          title: 'Total Metrics',
          value: '${summary['total_metrics']}',
          color: context.colors.gold,
        ),
        SizedBox(height: AppSpacing.md),
        _buildMetricCard(
          icon: Icons.screen_search_desktop,
          title: 'Screen Renders',
          value: '${summary['screen_renders']}',
          subtitle: 'Avg: ${summary['avg_screen_render_ms']}ms',
          color: Colors.blue,
        ),
        SizedBox(height: AppSpacing.md),
        _buildMetricCard(
          icon: Icons.cloud_outlined,
          title: 'API Calls',
          value: '${summary['api_calls']}',
          subtitle: 'Avg: ${summary['avg_api_response_ms']}ms',
          color: Colors.purple,
        ),
        SizedBox(height: AppSpacing.md),
        _buildMetricCard(
          icon: Icons.video_settings,
          title: 'Frame Rate',
          value: '${summary['current_fps'] ?? 'N/A'} FPS',
          subtitle: 'Drops: ${summary['frame_drop_percentage']}%',
          color: Colors.green,
        ),
        SizedBox(height: AppSpacing.md),
        _buildMetricCard(
          icon: Icons.memory,
          title: 'Memory Usage',
          value: '${summary['last_memory_mb']} MB',
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildScreensTab(PerformanceService service) {
    final metrics = service.getMetrics(type: MetricType.screenRender);

    if (metrics.isEmpty) {
      return _buildEmptyState('No screen metrics yet');
    }

    // Group by screen name
    final screenMap = <String, List<PerformanceMetric>>{};
    for (final metric in metrics) {
      final screen = metric.attributes?['screen'] as String? ?? 'Unknown';
      screenMap.putIfAbsent(screen, () => []).add(metric);
    }

    final sortedScreens = screenMap.entries.toList()
      ..sort((a, b) {
        final aAvg = a.value.fold<int>(0, (sum, m) => sum + (m.duration?.inMilliseconds ?? 0)) ~/
            a.value.length;
        final bAvg = b.value.fold<int>(0, (sum, m) => sum + (m.duration?.inMilliseconds ?? 0)) ~/
            b.value.length;
        return bAvg.compareTo(aAvg);
      });

    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.md),
      itemCount: sortedScreens.length,
      itemBuilder: (context, index) {
        final entry = sortedScreens[index];
        final screen = entry.key;
        final screenMetrics = entry.value;
        final avgDuration = screenMetrics.fold<int>(
              0,
              (sum, m) => sum + (m.duration?.inMilliseconds ?? 0),
            ) ~/
            screenMetrics.length;

        return _buildListCard(
          title: screen,
          subtitle: '${screenMetrics.length} renders',
          trailing: '${avgDuration}ms',
          color: avgDuration > 1000 ? AppColors.warning : AppColors.success,
        );
      },
    );
  }

  Widget _buildApiTab(PerformanceService service) {
    final metrics = service.getMetrics(type: MetricType.apiCall);

    if (metrics.isEmpty) {
      return _buildEmptyState('No API metrics yet');
    }

    // Group by endpoint
    final endpointMap = <String, List<PerformanceMetric>>{};
    for (final metric in metrics) {
      final endpoint = metric.attributes?['endpoint'] as String? ?? 'Unknown';
      endpointMap.putIfAbsent(endpoint, () => []).add(metric);
    }

    final sortedEndpoints = endpointMap.entries.toList()
      ..sort((a, b) {
        final aAvg = a.value.fold<int>(0, (sum, m) => sum + (m.duration?.inMilliseconds ?? 0)) ~/
            a.value.length;
        final bAvg = b.value.fold<int>(0, (sum, m) => sum + (m.duration?.inMilliseconds ?? 0)) ~/
            b.value.length;
        return bAvg.compareTo(aAvg);
      });

    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.md),
      itemCount: sortedEndpoints.length,
      itemBuilder: (context, index) {
        final entry = sortedEndpoints[index];
        final endpoint = entry.key;
        final apiMetrics = entry.value;
        final avgDuration = apiMetrics.fold<int>(
              0,
              (sum, m) => sum + (m.duration?.inMilliseconds ?? 0),
            ) ~/
            apiMetrics.length;
        final errorCount = apiMetrics.where((m) => m.attributes?['is_error'] == true).length;

        return _buildListCard(
          title: endpoint,
          subtitle: '${apiMetrics.length} calls',
          trailing: '${avgDuration}ms',
          color: avgDuration > 3000 ? AppColors.error : AppColors.success,
          badge: errorCount > 0 ? '$errorCount errors' : null,
        );
      },
    );
  }

  Widget _buildFramesTab(PerformanceService service) {
    final fps = service.getCurrentFrameRate();
    final dropPercentage = service.getFrameDropPercentage();

    return ListView(
      padding: EdgeInsets.all(AppSpacing.md),
      children: [
        _buildMetricCard(
          icon: Icons.movie_filter,
          title: 'Current FPS',
          value: fps != null ? fps.toStringAsFixed(1) : 'N/A',
          color: fps != null && fps >= 55 ? AppColors.success : AppColors.warning,
        ),
        SizedBox(height: AppSpacing.md),
        _buildMetricCard(
          icon: Icons.warning_amber,
          title: 'Frame Drops',
          value: '${dropPercentage.toStringAsFixed(1)}%',
          color: dropPercentage < 5 ? AppColors.success : AppColors.warning,
        ),
        SizedBox(height: AppSpacing.md),
        AppCard(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  'Frame Performance',
                  style: AppTypography.headlineSmall,
                ),
                SizedBox(height: AppSpacing.sm),
                AppText(
                  'Target: 60 FPS (16.67ms per frame)',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.silver),
                ),
                SizedBox(height: AppSpacing.sm),
                _buildPerformanceIndicator(
                  'Excellent',
                  fps != null && fps >= 55,
                  AppColors.success,
                ),
                _buildPerformanceIndicator(
                  'Good',
                  fps != null && fps >= 45 && fps < 55,
                  AppColors.warning,
                ),
                _buildPerformanceIndicator(
                  'Poor',
                  fps != null && fps < 45,
                  AppColors.error,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
    String? subtitle,
    required Color color,
  }) {
    return AppCard(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    title,
                    style: AppTypography.bodyMedium.copyWith(color: context.colors.textSecondary),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  AppText(
                    value,
                    style: AppTypography.headlineMedium.copyWith(
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: AppSpacing.xs),
                    AppText(
                      subtitle,
                      style: AppTypography.bodySmall.copyWith(color: context.colors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListCard({
    required String title,
    required String subtitle,
    required String trailing,
    required Color color,
    String? badge,
  }) {
    return AppCard(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    title,
                    style: AppTypography.bodyMedium.copyWith(color: context.colors.textPrimary),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      AppText(
                        subtitle,
                        style: AppTypography.bodySmall.copyWith(color: context.colors.textSecondary),
                      ),
                      if (badge != null) ...[
                        SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: AppText(
                            badge,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.error,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: AppText(
                trailing,
                style: AppTypography.bodyMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceIndicator(String label, bool isActive, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isActive ? color : context.colors.textSecondary.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          AppText(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: isActive ? context.colors.textPrimary : context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: context.colors.textSecondary.withValues(alpha: 0.5),
          ),
          SizedBox(height: AppSpacing.md),
          AppText(
            message,
            style: AppTypography.bodyLarge.copyWith(color: context.colors.textSecondary),
          ),
        ],
      ),
    );
  }

  void _clearMetrics(PerformanceService service) {
    service.clearMetrics();
    setState(() {});
  }
}
