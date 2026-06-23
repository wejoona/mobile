// ignore_for_file: avoid_dynamic_calls
import 'package:usdc_wallet/core/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/send_external/providers/external_transfer_provider.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

class ExternalResultScreen extends ConsumerWidget {
  const ExternalResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(externalTransferProvider);
    final result = state.result;
    final hasTransactionHash = result?.txHash.isNotEmpty == true;
    final resultState = _externalResultState(result?.status ?? 'pending');
    final colors = context.colors;

    if (result == null) {
      // Navigate back if no result
      Future.microtask(() => context.fsmGo('/send-external'));
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: context.colors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(AppSpacing.lg),
                children: [
                  SizedBox(height: AppSpacing.xxl),

                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: _statusAccentColor(
                          colors,
                          resultState,
                        ).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _statusIcon(resultState),
                        color: _statusAccentColor(colors, resultState),
                        size: 60,
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.xl),

                  Center(
                    child: AppText(
                      _statusTitle(context, l10n, resultState),
                      variant: AppTextVariant.headlineMedium,
                      fontWeight: FontWeight.w600,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Center(
                    child: AppText(
                      _statusBody(context, l10n, resultState),
                      variant: AppTextVariant.bodyMedium,
                      color: context.colors.textSecondary,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xxl),

                  AppCard(
                    child: Column(
                      children: [
                        AppText(
                          resultState == _ExternalResultState.completed
                              ? l10n.sendExternal_amountSent
                              : _localizedExternalCopy(
                                  context,
                                  en: 'Amount',
                                  fr: 'Montant',
                                ),
                          variant: AppTextVariant.bodySmall,
                          color: context.colors.textSecondary,
                        ),
                        SizedBox(height: AppSpacing.xs),
                        AmountText.fromText(
                          '\$${Formatters.formatCurrency(state.amount!)}',
                          size: AmountTextSize.large,
                          color: context.colors.gold,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.xl),

                  // Transaction details
                  AppText(
                    l10n.sendExternal_transactionDetails,
                    variant: AppTextVariant.labelLarge,
                    color: context.colors.textSecondary,
                  ),
                  SizedBox(height: AppSpacing.lg),

                  if (hasTransactionHash) ...[
                    _buildDetailCard(
                      context,
                      l10n.sendExternal_transactionHash,
                      _truncateHash(result.txHash),
                      fullValue: result.txHash,
                      isCopyable: true,
                      icon: Icons.tag,
                    ),
                    SizedBox(height: AppSpacing.sm),
                  ],

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
                    valueWidget: AmountText.fromText(
                      '\$${Formatters.formatCurrency(result.fee)}',
                      size: AmountTextSize.small,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),

                  // Status
                  _buildDetailCard(
                    context,
                    l10n.sendExternal_status,
                    _getStatusDisplay(result.status, l10n),
                    icon: Icons.info_outline,
                    statusColor: _getStatusColor(context, result.status),
                  ),
                  SizedBox(height: AppSpacing.xxl),

                  if (hasTransactionHash)
                    AppButton(
                      label: l10n.sendExternal_viewOnExplorer,
                      variant: AppButtonVariant.secondary,
                      icon: Icons.open_in_new,
                      onPressed: () => _viewOnExplorer(
                        context,
                        result.txHash,
                        result.network.value,
                      ),
                    ),
                ],
              ),
            ),

            // Bottom actions
            Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  AppButton(
                    label: l10n.sendExternal_shareDetails,
                    variant: AppButtonVariant.secondary,
                    icon: Icons.share,
                    onPressed: () =>
                        _shareDetails(context, l10n, state, result),
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
    Widget? valueWidget,
  }) {
    return AppCard(
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: context.colors.gold, size: 20),
            SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  label,
                  variant: AppTextVariant.bodySmall,
                  color: context.colors.textSecondary,
                ),
                SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Expanded(
                      child:
                          valueWidget ??
                          AppText(
                            value,
                            variant: isCopyable
                                ? AppTextVariant.monoMedium
                                : AppTextVariant.bodyMedium,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                    ),
                    if (isCopyable) ...[
                      SizedBox(width: AppSpacing.xs),
                      GestureDetector(
                        onTap: () =>
                            _copyToClipboard(context, fullValue ?? value),
                        child: Icon(
                          Icons.copy,
                          size: 16,
                          color: context.colors.gold,
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

  Color _getStatusColor(BuildContext context, String status) {
    return _statusAccentColor(context.colors, _externalResultState(status));
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.sendExternal_hashCopied),
        backgroundColor: context.colors.success,
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
        content: Text(
          AppLocalizations.of(context)!.settings_openingUrl(explorerUrl),
        ),
        backgroundColor: context.colors.info,
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
    final lines = [
      l10n.sendExternal_transferSuccess,
      '',
      '${l10n.sendExternal_amount}: \$${Formatters.formatCurrency(state.amount!)}',
      '${l10n.sendExternal_network}: ${result.network.displayName}',
      if (result.txHash.isNotEmpty)
        '${l10n.sendExternal_transactionHash}: ${result.txHash}',
      '${l10n.sendExternal_status}: ${_getStatusDisplay(result.status, l10n)}',
    ];

    SharePlus.instance.share(ShareParams(text: lines.join('\n')));
  }

  void _handleDone(BuildContext context, WidgetRef ref) {
    // Reset state
    ref.read(externalTransferProvider.notifier).reset();
    // Navigate to home
    context.fsmGo('/home');
  }
}

enum _ExternalResultState { completed, pending, failed }

_ExternalResultState _externalResultState(String status) {
  switch (status.trim().toLowerCase()) {
    case 'completed':
    case 'success':
    case 'successful':
      return _ExternalResultState.completed;
    case 'failed':
    case 'rejected':
    case 'cancelled':
    case 'canceled':
    case 'expired':
      return _ExternalResultState.failed;
    default:
      return _ExternalResultState.pending;
  }
}

IconData _statusIcon(_ExternalResultState state) => switch (state) {
  _ExternalResultState.completed => Icons.check_circle,
  _ExternalResultState.pending => Icons.schedule_rounded,
  _ExternalResultState.failed => Icons.error_outline_rounded,
};

Color _statusAccentColor(ThemeColors colors, _ExternalResultState state) =>
    switch (state) {
      _ExternalResultState.completed => colors.success,
      _ExternalResultState.pending => colors.warningText,
      _ExternalResultState.failed => colors.error,
    };

String _statusTitle(
  BuildContext context,
  AppLocalizations l10n,
  _ExternalResultState state,
) => switch (state) {
  _ExternalResultState.completed => l10n.sendExternal_transferSuccess,
  _ExternalResultState.pending => _localizedExternalCopy(
    context,
    en: 'Transfer Pending',
    fr: 'Transfert en attente',
  ),
  _ExternalResultState.failed => _localizedExternalCopy(
    context,
    en: 'Transfer Failed',
    fr: 'Échec du transfert',
  ),
};

String _statusBody(
  BuildContext context,
  AppLocalizations l10n,
  _ExternalResultState state,
) => switch (state) {
  _ExternalResultState.completed => l10n.sendExternal_processingMessage,
  _ExternalResultState.pending => _localizedExternalCopy(
    context,
    en: 'Korido accepted the request. Wait for the final blockchain status before sending again.',
    fr: 'Korido a accepté la demande. Attendez le statut final sur la blockchain avant de renvoyer.',
  ),
  _ExternalResultState.failed => _localizedExternalCopy(
    context,
    en: 'No external transfer was completed. Check the details or contact support before retrying.',
    fr: 'Aucun transfert externe n’a été finalisé. Vérifiez les détails ou contactez le support avant de réessayer.',
  ),
};

String _localizedExternalCopy(
  BuildContext context, {
  required String en,
  required String fr,
}) {
  return Localizations.localeOf(context).languageCode == 'fr' ? fr : en;
}
