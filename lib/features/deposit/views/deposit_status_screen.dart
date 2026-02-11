import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/deposit/providers/deposit_provider.dart';
import 'package:usdc_wallet/features/deposit/models/deposit_response.dart';

/// Deposit Status Screen
///
/// Shows deposit result: success (green check, USDC amount), failed (red X, reason), processing (spinner)
/// "Done" button → navigates back to home
class DepositStatusScreen extends ConsumerWidget {
  const DepositStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final state = ref.watch(depositProvider);
    final response = state.response;

    final status = _getDepositStatus(state);

    return Scaffold(
      backgroundColor: colors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Status Icon
              _buildStatusIcon(status, colors),
              const SizedBox(height: AppSpacing.xl),

              // Title
              AppText(
                _getStatusTitle(status, l10n),
                variant: AppTextVariant.headlineMedium,
                color: colors.textPrimary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),

              // Subtitle/Description
              AppText(
                _getStatusSubtitle(status, state, l10n),
                variant: AppTextVariant.bodyMedium,
                color: colors.textSecondary,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.xl),

              // Amount Display (for success)
              if (status == _DepositStatus.completed && response != null) ...[
                AppCard(
                  variant: AppCardVariant.elevated,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                l10n.deposit_deposited,
                                variant: AppTextVariant.bodySmall,
                                color: colors.textSecondary,
                              ),
                              AppText(
                                '${(state.amountXOF ?? 0).toStringAsFixed(0)} XOF',
                                variant: AppTextVariant.titleMedium,
                                color: colors.textPrimary,
                              ),
                            ],
                          ),
                          Icon(
                            Icons.arrow_forward,
                            color: colors.textTertiary,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              AppText(
                                l10n.deposit_received,
                                variant: AppTextVariant.bodySmall,
                                color: colors.textSecondary,
                              ),
                              AppText(
                                '\$${(state.amountUSD ?? 0).toStringAsFixed(2)}',
                                variant: AppTextVariant.titleMedium,
                                color: colors.gold,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Divider(color: colors.borderSubtle, height: 1),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: colors.success,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: AppText(
                              l10n.deposit_balanceUpdated,
                              variant: AppTextVariant.bodyMedium,
                              color: colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],

              // Error Details (for failure)
              if (status == _DepositStatus.failed && state.error != null) ...[
                AppCard(
                  variant: AppCardVariant.elevated,
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: colors.error,
                        size: 24,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              l10n.deposit_errorReason(state.error ?? l10n.common_unknownError),
                              variant: AppTextVariant.bodyMedium,
                              color: colors.errorText,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],

              // Processing Details
              if (status == _DepositStatus.processing) ...[
                AppCard(
                  variant: AppCardVariant.elevated,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.gold,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AppText(
                          l10n.deposit_processingDesc,
                          variant: AppTextVariant.bodyMedium,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],

              const Spacer(),

              // Action Buttons
              Column(
                children: [
                  AppButton(
                    label: status == _DepositStatus.processing 
                        ? l10n.action_checkStatus 
                        : l10n.action_done,
                    onPressed: () => _handlePrimaryAction(status, ref, context),
                    isFullWidth: true,
                  ),

                  if (status == _DepositStatus.failed) ...[
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      label: l10n.action_tryAgain,
                      variant: AppButtonVariant.secondary,
                      onPressed: () => _handleTryAgain(ref, context),
                      isFullWidth: true,
                    ),
                  ],

                  if (status != _DepositStatus.completed) ...[
                    const SizedBox(height: AppSpacing.sm),
                    TextButton(
                      onPressed: () => _handleGoHome(ref, context),
                      child: AppText(
                        l10n.action_backToHome,
                        variant: AppTextVariant.labelMedium,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(_DepositStatus status, ThemeColors colors) {
    Color backgroundColor;
    Color iconColor;
    IconData iconData;

    switch (status) {
      case _DepositStatus.completed:
        backgroundColor = colors.success.withValues(alpha: 0.1);
        iconColor = colors.success;
        iconData = Icons.check_circle;
        break;
      case _DepositStatus.failed:
        backgroundColor = colors.error.withValues(alpha: 0.1);
        iconColor = colors.error;
        iconData = Icons.error;
        break;
      case _DepositStatus.processing:
        backgroundColor = colors.gold.withValues(alpha: 0.1);
        iconColor = colors.gold;
        iconData = Icons.schedule;
        break;
    }

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
      ),
      child: Icon(
        iconData,
        size: 64,
        color: iconColor,
      ),
    );
  }

  _DepositStatus _getDepositStatus(DepositState state) {
    if (state.step == DepositFlowStep.completed) {
      return _DepositStatus.completed;
    } else if (state.step == DepositFlowStep.failed) {
      return _DepositStatus.failed;
    } else {
      return _DepositStatus.processing;
    }
  }

  String _getStatusTitle(_DepositStatus status, AppLocalizations l10n) {
    switch (status) {
      case _DepositStatus.completed:
        return l10n.deposit_successTitle;
      case _DepositStatus.failed:
        return l10n.deposit_failedTitle;
      case _DepositStatus.processing:
        return l10n.deposit_processingTitle;
    }
  }

  String _getStatusSubtitle(
    _DepositStatus status, 
    DepositState state, 
    AppLocalizations l10n,
  ) {
    switch (status) {
      case _DepositStatus.completed:
        return l10n.deposit_successDesc;
      case _DepositStatus.failed:
        return l10n.deposit_failedDesc;
      case _DepositStatus.processing:
        return l10n.deposit_processingSubtitle;
    }
  }

  void _handlePrimaryAction(
    _DepositStatus status,
    WidgetRef ref,
    BuildContext context,
  ) {
    switch (status) {
      case _DepositStatus.completed:
        _handleGoHome(ref, context);
        break;
      case _DepositStatus.failed:
        _handleGoHome(ref, context);
        break;
      case _DepositStatus.processing:
        // Refresh the status
        ref.read(depositProvider.notifier).checkStatus();
        break;
    }
  }

  void _handleTryAgain(WidgetRef ref, BuildContext context) {
    ref.read(depositProvider.notifier).reset();
    context.go('/deposit/amount');
  }

  void _handleGoHome(WidgetRef ref, BuildContext context) {
    ref.read(depositProvider.notifier).reset();
    context.go('/home');
  }
}

enum _DepositStatus { completed, failed, processing }