import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../utils/formatters.dart';
import '../providers/external_transfer_provider.dart';

class ExternalResultScreen extends ConsumerWidget {
  const ExternalResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(externalTransferProvider);
    final result = state.result;

    if (result == null) {
      // Navigate back if no result
      Future.microtask(() => context.go('/send-external'));
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(AppSpacing.md),
                children: [
                  SizedBox(height: AppSpacing.xxl),

                  // Success animation/icon
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.successBase.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: AppColors.successBase,
                        size: 60,
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg),

                  // Success title
                  Center(
                    child: AppText(
                      l10n.sendExternal_transferSuccess,
                      variant: AppTextVariant.headlineMedium,
                      fontWeight: FontWeight.w600,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Center(
                    child: AppText(
                      l10n.sendExternal_processingMessage,
                      variant: AppTextVariant.bodyMedium,
                      color: AppColors.textSecondary,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xxl),

                  // Amount sent
                  AppCard(
                    child: Column(
                      children: [
                        AppText(
                          l10n.sendExternal_amountSent,
                          variant: AppTextVariant.bodySmall,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(height: AppSpacing.xs),
                        AppText(
                          '\$${Formatters.formatCurrency(state.amount!)}',
                          variant: AppTextVariant.headlineLarge,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gold500,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg),

                  // Transaction details
                  AppText(
                    l10n.sendExternal_transactionDetails,
                    variant: AppTextVariant.labelLarge,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: AppSpacing.md),

                  // Transaction hash
                  _buildDetailCard(
                    context,
                    l10n.sendExternal_transactionHash,
                    _truncateHash(result.txHash),
                    fullValue: result.txHash,
                    isCopyable: true,
                    icon: Icons.tag,
                  ),
                  SizedBox(height: AppSpacing.sm),

                  // Network
                  _buildDetailCard(
                    context,
                    l10n.sendExternal_network,
                    result.network.displayName,
                    icon: Icons.hub,
                  ),
                  SizedBox(height: AppSpacing.sm),

                  // Network fee
                  _buildDetailCard(
                    context,
                    l10n.sendExternal_networkFee,
                    '\$${Formatters.formatCurrency(result.fee)}',
                    icon: Icons.receipt_long,
                  ),
                  SizedBox(height: AppSpacing.sm),

                  // Status
                  _buildDetailCard(
                    context,
                    l10n.sendExternal_status,
                    _getStatusDisplay(result.status, l10n),
                    icon: Icons.info_outline,
                    statusColor: _getStatusColor(result.status),
                  ),
                  SizedBox(height: AppSpacing.xl),

                  // View on Explorer button (optional feature)
                  AppButton(
                    label: l10n.sendExternal_viewOnExplorer,
                    variant: AppButtonVariant.secondary,
                    icon: Icons.open_in_new,
                    onPressed: () => _viewOnExplorer(context, result.txHash, result.network.value),
                  ),
                ],
              ),
            ),

            // Bottom actions
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  AppButton(
                    label: l10n.sendExternal_shareDetails,
                    variant: AppButtonVariant.secondary,
                    icon: Icons.share,
                    onPressed: () => _shareDetails(context, l10n, state, result),
                    isFullWidth: true,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  AppButton(
                    label: l10n.action_done,
                    onPressed: () => _handleDone(context, ref),
                    isFullWidth: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(
    BuildContext context,
    String label,
    String value, {
    String? fullValue,
    bool isCopyable = false,
    IconData? icon,
    Color? statusColor,
  }) {
    return AppCard(
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppColors.gold500, size: 20),
            SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  label,
                  variant: AppTextVariant.bodySmall,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Expanded(
                      child: AppText(
                        value,
                        variant: isCopyable ? AppTextVariant.monoMedium : AppTextVariant.bodyMedium,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                    if (isCopyable) ...[
                      SizedBox(width: AppSpacing.xs),
                      GestureDetector(
                        onTap: () => _copyToClipboard(context, fullValue ?? value),
                        child: Icon(
                          Icons.copy,
                          size: 16,
                          color: AppColors.gold500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _truncateHash(String hash) {
    if (hash.length <= 20) return hash;
    return '${hash.substring(0, 10)}...${hash.substring(hash.length - 8)}';
  }

  String _getStatusDisplay(String status, AppLocalizations l10n) {
    switch (status.toLowerCase()) {
      case 'pending':
        return l10n.sendExternal_statusPending;
      case 'completed':
        return l10n.sendExternal_statusCompleted;
      case 'processing':
        return l10n.sendExternal_statusProcessing;
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'processing':
        return AppColors.warningBase;
      case 'completed':
        return AppColors.successBase;
      case 'failed':
        return AppColors.errorBase;
      default:
        return AppColors.textPrimary;
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.sendExternal_hashCopied),
        backgroundColor: AppColors.successBase,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _viewOnExplorer(BuildContext context, String txHash, String network) {
    // In production, open browser with appropriate explorer URL
    // Polygon: https://polygonscan.com/tx/{txHash}
    // Ethereum: https://etherscan.io/tx/{txHash}
    final explorerUrl = network == 'polygon'
        ? 'https://polygonscan.com/tx/$txHash'
        : 'https://etherscan.io/tx/$txHash';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Would open: $explorerUrl'),
        backgroundColor: AppColors.successBase,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _shareDetails(
    BuildContext context,
    AppLocalizations l10n,
    state,
    result,
  ) {
    final message = '''
${l10n.sendExternal_transferSuccess}

${l10n.sendExternal_amount}: \$${Formatters.formatCurrency(state.amount!)}
${l10n.sendExternal_network}: ${result.network.displayName}
${l10n.sendExternal_transactionHash}: ${result.txHash}
${l10n.sendExternal_status}: ${_getStatusDisplay(result.status, l10n)}
''';

    Share.share(message);
  }

  void _handleDone(BuildContext context, WidgetRef ref) {
    // Reset state
    ref.read(externalTransferProvider.notifier).reset();
    // Navigate to home
    context.go('/');
  }
}
