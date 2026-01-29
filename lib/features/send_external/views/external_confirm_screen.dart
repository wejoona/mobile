import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../utils/formatters.dart';
import '../providers/external_transfer_provider.dart';

class ExternalConfirmScreen extends ConsumerStatefulWidget {
  const ExternalConfirmScreen({super.key});

  @override
  ConsumerState<ExternalConfirmScreen> createState() => _ExternalConfirmScreenState();
}

class _ExternalConfirmScreenState extends ConsumerState<ExternalConfirmScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(externalTransferProvider);

    if (!state.canProceedToConfirm) {
      // Navigate back if invalid state
      Future.microtask(() => context.go('/send-external'));
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: AppText(
          l10n.sendExternal_confirmTransfer,
          variant: AppTextVariant.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(AppSpacing.md),
                children: [
                  // Warning card
                  Container(
                    padding: EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.warningBase.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.warningBase,
                          size: 24,
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                l10n.sendExternal_warningTitle,
                                variant: AppTextVariant.bodyMedium,
                                fontWeight: FontWeight.w600,
                                color: AppColors.warningBase,
                              ),
                              SizedBox(height: AppSpacing.xs),
                              AppText(
                                l10n.sendExternal_warningMessage,
                                variant: AppTextVariant.bodySmall,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.xl),

                  // Transfer summary
                  AppText(
                    l10n.sendExternal_transferSummary,
                    variant: AppTextVariant.labelLarge,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: AppSpacing.md),

                  // Recipient address
                  _buildDetailRow(
                    l10n.sendExternal_recipientAddress,
                    state.address!,
                    isCopyable: true,
                    isMonospace: true,
                  ),
                  Divider(
                    height: AppSpacing.lg * 2,
                    color: AppColors.textSecondary.withOpacity(0.2),
                  ),

                  // Network
                  _buildDetailRow(
                    l10n.sendExternal_network,
                    state.selectedNetwork.displayName,
                  ),
                  Divider(
                    height: AppSpacing.lg * 2,
                    color: AppColors.textSecondary.withOpacity(0.2),
                  ),

                  // Amount
                  _buildDetailRow(
                    l10n.sendExternal_amount,
                    '\$${Formatters.formatCurrency(state.amount!)}',
                    isHighlighted: true,
                  ),
                  Divider(
                    height: AppSpacing.lg * 2,
                    color: AppColors.textSecondary.withOpacity(0.2),
                  ),

                  // Network fee
                  _buildDetailRow(
                    l10n.sendExternal_networkFee,
                    '\$${Formatters.formatCurrency(state.estimatedFee)}',
                  ),
                  Divider(
                    height: AppSpacing.lg * 2,
                    color: AppColors.textSecondary.withOpacity(0.2),
                  ),

                  // Total
                  _buildDetailRow(
                    l10n.sendExternal_totalDeducted,
                    '\$${Formatters.formatCurrency(state.total)}',
                    isHighlighted: true,
                    isLarge: true,
                  ),
                  SizedBox(height: AppSpacing.xl),

                  // Estimated time
                  AppCard(
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          color: AppColors.gold500,
                          size: 20,
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                l10n.sendExternal_estimatedTime,
                                variant: AppTextVariant.bodySmall,
                                color: AppColors.textSecondary,
                              ),
                              AppText(
                                state.selectedNetwork.estimatedTime,
                                variant: AppTextVariant.bodyMedium,
                                fontWeight: FontWeight.w600,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Error message
            if (state.error != null)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.errorBase.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppColors.errorBase,
                        size: 20,
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: AppText(
                          state.error!,
                          variant: AppTextVariant.bodySmall,
                          color: AppColors.errorBase,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Bottom button
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: AppButton(
                label: l10n.sendExternal_confirmAndSend,
                onPressed: _handleConfirm,
                isLoading: _isLoading,
                isFullWidth: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isHighlighted = false,
    bool isLarge = false,
    bool isCopyable = false,
    bool isMonospace = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          label,
          variant: isLarge ? AppTextVariant.bodyLarge : AppTextVariant.bodyMedium,
          color: AppColors.textSecondary,
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: AppText(
                  value,
                  variant: isMonospace
                      ? (isLarge ? AppTextVariant.monoLarge : AppTextVariant.monoMedium)
                      : (isLarge ? AppTextVariant.bodyLarge : AppTextVariant.bodyMedium),
                  fontWeight: isHighlighted || isLarge ? FontWeight.w600 : FontWeight.normal,
                  color: isHighlighted ? AppColors.gold500 : AppColors.textPrimary,
                  textAlign: TextAlign.right,
                ),
              ),
              if (isCopyable) ...[
                SizedBox(width: AppSpacing.xs),
                GestureDetector(
                  onTap: () => _copyToClipboard(value),
                  child: Icon(
                    Icons.copy,
                    size: 16,
                    color: AppColors.gold500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.sendExternal_addressCopied),
        backgroundColor: AppColors.successBase,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleConfirm() async {
    setState(() => _isLoading = true);
    try {
      final success = await ref.read(externalTransferProvider.notifier).executeTransfer();

      if (mounted) {
        if (success) {
          context.go('/send-external/result');
        } else {
          // Error is already set in state and displayed
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
