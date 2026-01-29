import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../providers/deposit_provider.dart';
import '../models/deposit_response.dart';

/// Deposit Status Screen
class DepositStatusScreen extends ConsumerWidget {
  const DepositStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final depositState = ref.watch(depositProvider);

    if (depositState.response == null) {
      return Scaffold(
        backgroundColor: colors.canvas,
        body: Center(
          child: CircularProgressIndicator(color: colors.gold),
        ),
      );
    }

    final response = depositState.response!;

    return Scaffold(
      backgroundColor: colors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Status Animation/Icon
              _buildStatusIcon(response.status, colors),

              const SizedBox(height: AppSpacing.xl),

              // Status Title
              AppText(
                _getStatusTitle(response.status, l10n),
                variant: AppTextVariant.displaySmall,
                color: colors.textPrimary,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.md),

              // Status Message
              AppText(
                _getStatusMessage(response.status, l10n),
                variant: AppTextVariant.bodyLarge,
                color: colors.textSecondary,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Amount Card (if completed)
              if (response.status == DepositStatus.completed)
                _buildAmountCard(response, colors, l10n),

              const Spacer(),

              // Action Buttons
              if (response.status == DepositStatus.completed)
                AppButton(
                  label: l10n.action_done,
                  onPressed: () {
                    ref.read(depositProvider.notifier).reset();
                    context.go('/home');
                  },
                  isFullWidth: true,
                )
              else if (response.status == DepositStatus.failed)
                Column(
                  children: [
                    AppButton(
                      label: l10n.action_retry,
                      onPressed: () {
                        ref.read(depositProvider.notifier).reset();
                        context.go('/deposit/amount');
                      },
                      isFullWidth: true,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppButton(
                      label: l10n.action_cancel,
                      onPressed: () {
                        ref.read(depositProvider.notifier).reset();
                        context.go('/home');
                      },
                      variant: AppButtonVariant.secondary,
                      isFullWidth: true,
                    ),
                  ],
                )
              else
                AppButton(
                  label: l10n.deposit_backToHome,
                  onPressed: () {
                    ref.read(depositProvider.notifier).reset();
                    context.go('/home');
                  },
                  variant: AppButtonVariant.secondary,
                  isFullWidth: true,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(DepositStatus status, ThemeColors colors) {
    switch (status) {
      case DepositStatus.pending:
        return SizedBox(
          width: 120,
          height: 120,
          child: CircularProgressIndicator(
            color: colors.gold,
            strokeWidth: 6,
          ),
        );

      case DepositStatus.completed:
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.successBase.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle,
            color: AppColors.successBase,
            size: 80,
          ),
        );

      case DepositStatus.failed:
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.errorBase.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.error,
            color: AppColors.errorBase,
            size: 80,
          ),
        );

      case DepositStatus.expired:
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.warningBase.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.access_time,
            color: AppColors.warningBase,
            size: 80,
          ),
        );
    }
  }

  Widget _buildAmountCard(DepositResponse response, ThemeColors colors, AppLocalizations l10n) {
    return AppCard(
      variant: AppCardVariant.elevated,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                l10n.deposit_deposited,
                variant: AppTextVariant.labelMedium,
                color: colors.textSecondary,
              ),
              AppText(
                '${response.amount.toStringAsFixed(0)} XOF',
                variant: AppTextVariant.bodyLarge,
                color: colors.textPrimary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(color: colors.borderSubtle, height: 1),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                l10n.deposit_received,
                variant: AppTextVariant.labelMedium,
                color: colors.textSecondary,
              ),
              AppText(
                '\$${response.convertedAmount?.toStringAsFixed(2) ?? '0.00'}',
                variant: AppTextVariant.titleLarge,
                color: colors.gold,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getStatusTitle(DepositStatus status, AppLocalizations l10n) {
    switch (status) {
      case DepositStatus.pending:
        return l10n.deposit_processing;
      case DepositStatus.completed:
        return l10n.deposit_success;
      case DepositStatus.failed:
        return l10n.deposit_failed;
      case DepositStatus.expired:
        return l10n.deposit_expired;
    }
  }

  String _getStatusMessage(DepositStatus status, AppLocalizations l10n) {
    switch (status) {
      case DepositStatus.pending:
        return l10n.deposit_processingMessage;
      case DepositStatus.completed:
        return l10n.deposit_successMessage;
      case DepositStatus.failed:
        return l10n.deposit_failedMessage;
      case DepositStatus.expired:
        return l10n.deposit_expiredMessage;
    }
  }
}
