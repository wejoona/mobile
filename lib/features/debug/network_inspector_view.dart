import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

/// Run 343: Network inspector debug view for dev builds
class NetworkInspectorView extends ConsumerStatefulWidget {
  const NetworkInspectorView({super.key});

  @override
  ConsumerState<NetworkInspectorView> createState() =>
      _NetworkInspectorViewState();
}

class _NetworkInspectorViewState extends ConsumerState<NetworkInspectorView> {
  final List<_NetworkLog> _logs = [];
  bool _showOnlyErrors = false;

  List<_NetworkLog> get _filteredLogs => _showOnlyErrors
      ? _logs.where((l) => l.statusCode >= 400).toList()
      : _logs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        title: const AppText(
          'Network Inspector',
          style: AppTextStyle.headingSmall,
        ),
        backgroundColor: context.colors.surface,
        actions: [
          IconButton(
            icon: Icon(
              _showOnlyErrors ? Icons.error : Icons.error_outline,
              color: _showOnlyErrors ? context.colors.error : context.colors.textSecondary,
            ),
            onPressed: () => setState(() => _showOnlyErrors = !_showOnlyErrors),
            tooltip: 'Filtrer les erreurs',
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: context.colors.textSecondary),
            onPressed: () => setState(() => _logs.clear()),
            tooltip: 'Effacer les logs',
          ),
        ],
      ),
      body: _filteredLogs.isEmpty
          ? const Center(
              child: EmptyState(title: 'Aucune requete reseau capturee',
                icon: Icons.wifi_off,
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.sm),
              itemCount: _filteredLogs.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.xs),
              itemBuilder: (context, index) {
                final log = _filteredLogs[index];
                return _NetworkLogTile(log: log);
              },
            ),
    );
  }
}

class _NetworkLog {
  final String method;
  final String url;
  final int statusCode;
  final int durationMs;
  final DateTime timestamp;

  const _NetworkLog({
    required this.method,
    required this.url,
    required this.statusCode,
    required this.durationMs,
    required this.timestamp,
  });
}

class _NetworkLogTile extends StatelessWidget {
  final _NetworkLog log;

  const _NetworkLogTile({required this.log});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                StatusBadge(status: log.method),
                const SizedBox(width: AppSpacing.sm),
                StatusBadge(status: '${log.statusCode}'),
                const Spacer(),
                AppText(
                  '${log.durationMs}ms',
                  style: AppTextStyle.bodySmall,
                  color: context.colors.textTertiary,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              log.url,
              style: AppTextStyle.bodySmall,
              color: context.colors.textSecondary,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
