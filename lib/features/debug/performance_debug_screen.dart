import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/services/index.dart';

/// Debug screen for monitoring cache and performance
/// Only available in debug builds
class PerformanceDebugScreen extends ConsumerStatefulWidget {
  const PerformanceDebugScreen({super.key});

  @override
  ConsumerState<PerformanceDebugScreen> createState() =>
      _PerformanceDebugScreenState();
}

class _PerformanceDebugScreenState
    extends ConsumerState<PerformanceDebugScreen> {
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _refreshStats();
  }

  void _refreshStats() {
    final perfUtils = ref.read(performanceUtilsProvider);
    setState(() {
      _stats = perfUtils.getAllStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const AppText(
          'Performance Debug',
          variant: AppTextVariant.titleLarge,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshStats,
            tooltip: 'Refresh Stats',
          ),
        ],
      ),
      body: _stats == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCacheSection(colors),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildInFlightSection(colors),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildActionsSection(colors),
                ],
              ),
            ),
    );
  }

  Widget _buildCacheSection(ThemeColors colors) {
    final cacheStats = _stats!['cache'] as Map<String, dynamic>;
    final entries = cacheStats['entries'] as List<dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'HTTP Response Cache',
          variant: AppTextVariant.titleMedium,
          color: colors.textPrimary,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildStatCard(
          colors: colors,
          title: 'Cache Summary',
          items: [
            _StatItem(
              label: 'Total Entries',
              value: '${cacheStats['total']}',
              color: AppColors.infoBase,
            ),
            _StatItem(
              label: 'Active',
              value: '${cacheStats['active']}',
              color: context.colors.success,
            ),
            _StatItem(
              label: 'Expired',
              value: '${cacheStats['expired']}',
              color: AppColors.warningBase,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (entries.isNotEmpty) ...[
          AppText(
            'Cached Entries',
            variant: AppTextVariant.labelLarge,
            color: colors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.sm),
          ...entries.map((entry) => _buildCacheEntry(entry, colors)),
        ] else
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Center(
              child: AppText(
                'No cached entries',
                variant: AppTextVariant.bodyMedium,
                color: colors.textTertiary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInFlightSection(ThemeColors colors) {
    final inFlightStats = _stats!['inFlight'] as Map<String, dynamic>;
    final requests = inFlightStats['requests'] as List<dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'In-Flight Requests',
          variant: AppTextVariant.titleMedium,
          color: colors.textPrimary,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildStatCard(
          colors: colors,
          title: 'Active Requests',
          items: [
            _StatItem(
              label: 'Count',
              value: '${inFlightStats['count']}',
              color: AppColors.infoBase,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (requests.isNotEmpty) ...[
          AppText(
            'Current Requests',
            variant: AppTextVariant.labelLarge,
            color: colors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.sm),
          ...requests.map((request) => _buildInFlightRequest(request, colors)),
        ] else
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Center(
              child: AppText(
                'No in-flight requests',
                variant: AppTextVariant.bodyMedium,
                color: colors.textTertiary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionsSection(ThemeColors colors) {
    final perfUtils = ref.read(performanceUtilsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'Cache Management',
          variant: AppTextVariant.titleMedium,
          color: colors.textPrimary,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildActionButton(
          label: 'Clear All Caches',
          icon: Icons.delete_sweep,
          color: context.colors.error,
          onPressed: () {
            perfUtils.clearAllCaches();
            _refreshStats();
            _showSnackBar('All caches cleared');
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildActionButton(
          label: 'Clear Wallet Cache',
          icon: Icons.account_balance_wallet,
          color: AppColors.warningBase,
          onPressed: () {
            perfUtils.clearWalletCache();
            _refreshStats();
            _showSnackBar('Wallet cache cleared');
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildActionButton(
          label: 'Clear Transaction Cache',
          icon: Icons.receipt,
          color: AppColors.warningBase,
          onPressed: () {
            perfUtils.clearTransactionCache();
            _refreshStats();
            _showSnackBar('Transaction cache cleared');
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildActionButton(
          label: 'Clear Referral Cache',
          icon: Icons.people,
          color: AppColors.warningBase,
          onPressed: () {
            perfUtils.clearReferralCache();
            _refreshStats();
            _showSnackBar('Referral cache cleared');
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildActionButton(
          label: 'Clear In-Flight Requests',
          icon: Icons.cancel,
          color: context.colors.error,
          onPressed: () {
            perfUtils.clearInFlightRequests();
            _refreshStats();
            _showSnackBar('In-flight requests cleared');
          },
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required ThemeColors colors,
    required String title,
    required List<_StatItem> items,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.container,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            title,
            variant: AppTextVariant.labelMedium,
            color: colors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.map((item) {
              return Column(
                children: [
                  AppText(
                    item.value,
                    variant: AppTextVariant.headlineSmall,
                    color: item.color,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  AppText(
                    item.label,
                    variant: AppTextVariant.labelSmall,
                    color: colors.textTertiary,
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCacheEntry(dynamic entry, ThemeColors colors) {
    final isExpired = entry['isExpired'] as bool;
    final expiresIn = entry['expiresIn'] as int;
    final key = entry['key'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.container,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isExpired ? context.colors.error : context.colors.success,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isExpired ? Icons.warning : Icons.check_circle,
                color: isExpired ? context.colors.error : context.colors.success,
                size: 16,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: AppText(
                  key,
                  variant: AppTextVariant.bodySmall,
                  color: colors.textPrimary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          AppText(
            isExpired
                ? 'Expired'
                : 'Expires in ${_formatDuration(expiresIn)}',
            variant: AppTextVariant.labelSmall,
            color: colors.textTertiary,
          ),
        ],
      ),
    );
  }

  Widget _buildInFlightRequest(dynamic request, ThemeColors colors) {
    final age = request['age'] as int;
    final key = request['key'] as String;
    final isCompleted = request['isCompleted'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.container,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: isCompleted
                    ? Icon(Icons.check, color: context.colors.success, size: 16)
                    : CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.gold,
                      ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: AppText(
                  key,
                  variant: AppTextVariant.bodySmall,
                  color: colors.textPrimary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          AppText(
            'Duration: ${age}ms',
            variant: AppTextVariant.labelSmall,
            color: colors.textTertiary,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: color),
        label: AppText(
          label,
          variant: AppTextVariant.bodyMedium,
          color: color,
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.all(AppSpacing.md),
          side: BorderSide(color: color),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) {
      return '${seconds}s';
    } else if (seconds < 3600) {
      return '${(seconds / 60).floor()}m ${seconds % 60}s';
    } else {
      return '${(seconds / 3600).floor()}h ${((seconds % 3600) / 60).floor()}m';
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: context.colors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _StatItem {
  final String label;
  final String value;
  final Color color;

  _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });
}
