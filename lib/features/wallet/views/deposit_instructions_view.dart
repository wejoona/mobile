import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/services/wallet/wallet_service.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

class DepositInstructionsView extends ConsumerWidget {
  const DepositInstructionsView({super.key, required this.response});

  final DepositResponse response;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const AppText(
          'Payment Instructions',
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          children: [
            // Status Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: context.colors.warning.withValues(alpha:0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.schedule,
                size: 40,
                color: context.colors.warning,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            AppText(
              'Pending Payment',
              variant: AppTextVariant.headlineSmall,
              color: colors.textPrimary,
            ),

            const SizedBox(height: AppSpacing.sm),

            AppText(
              'Complete the payment to add funds to your wallet',
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Amount Card
            AppCard(
              variant: AppCardVariant.elevated,
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                children: [
                  AppText(
                    'Amount to Pay',
                    variant: AppTextVariant.labelMedium,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppText(
                    '${_formatAmount(response.amount)} ${response.sourceCurrency}',
                    variant: AppTextVariant.displaySmall,
                    color: colors.gold,
                  ),
                  if (response.fee > 0) ...[
                    const SizedBox(height: AppSpacing.sm),
                    AppText(
                      'Includes ${_formatAmount(response.fee)} ${response.sourceCurrency} fee',
                      variant: AppTextVariant.bodySmall,
                      color: colors.textTertiary,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  AppText(
                    'You will receive ~\$${_formatAmount(response.estimatedAmount)}',
                    variant: AppTextVariant.bodyMedium,
                    color: context.colors.successText,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Payment Instructions
            AppCard(
              variant: AppCardVariant.elevated,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    'Payment Instructions',
                    variant: AppTextVariant.titleSmall,
                    color: colors.textPrimary,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Use payment instructions from response
                  AppText(
                    response.paymentInstructions.instructions,
                    variant: AppTextVariant.bodyMedium,
                    color: colors.textPrimary,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _InstructionStep(
                    number: '1',
                    text: 'Provider: ${response.paymentInstructions.provider}',
                    colors: colors,
                  ),
                  _InstructionStep(
                    number: '2',
                    text: 'Account: ${response.paymentInstructions.accountNumber}',
                    colors: colors,
                  ),
                  _InstructionStep(
                    number: '3',
                    text: 'Amount: ${_formatAmount(response.amount)} ${response.sourceCurrency}',
                    colors: colors,
                  ),
                  _InstructionStep(
                    number: '4',
                    text: 'Reference: ${response.paymentInstructions.reference}',
                    isLast: true,
                    colors: colors,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Reference Code
            AppCard(
              variant: AppCardVariant.elevated,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    'Payment Reference',
                    variant: AppTextVariant.labelMedium,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: colors.elevated,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Center(
                            child: AppText(
                              response.paymentInstructions.reference,
                              variant: AppTextVariant.titleMedium,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      IconButton(
                        onPressed: () => _copyToClipboard(context, response.paymentInstructions.reference),
                        icon: Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: colors.gold.withValues(alpha:0.1),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Icon(
                            Icons.copy,
                            color: colors.gold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Timer/Expiry
            AppCard(
              variant: AppCardVariant.subtle,
              child: Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    color: context.colors.warning,
                    size: 24,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          'Payment expires in',
                          variant: AppTextVariant.bodySmall,
                          color: colors.textSecondary,
                        ),
                        AppText(
                          _formatExpiry(response.expiresAt),
                          variant: AppTextVariant.titleSmall,
                          color: context.colors.warning,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            // Done Button
            AppButton(
              label: 'I\'ve Made the Payment',
              onPressed: () => context.go('/home'),
              variant: AppButtonVariant.primary,
              isFullWidth: true,
            ),

            const SizedBox(height: AppSpacing.md),

            AppButton(
              label: 'Cancel',
              onPressed: () => _showCancelDialog(context),
              variant: AppButtonVariant.secondary,
              isFullWidth: true,
            ),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.toInt().toString();
    }
    return amount.toStringAsFixed(2);
  }

  String _formatExpiry(DateTime expiresAt) {
    final diff = expiresAt.difference(DateTime.now());
    if (diff.isNegative) return 'Expired';
    if (diff.inHours > 0) {
      return '${diff.inHours}h ${diff.inMinutes % 60}m';
    }
    return '${diff.inMinutes}m ${diff.inSeconds % 60}s';
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied to clipboard'),
        backgroundColor: context.colors.success,
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final dialogColors = context.colors;
        return AlertDialog(
          backgroundColor: dialogColors.container,
          title: const AppText(
            'Cancel Payment?',
            variant: AppTextVariant.titleMedium,
          ),
          content: AppText(
            'Are you sure you want to cancel this deposit? You can always start a new one later.',
            variant: AppTextVariant.bodyMedium,
            color: dialogColors.textSecondary,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: AppText(
                'Keep',
                variant: AppTextVariant.labelLarge,
                color: dialogColors.gold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/home');
              },
              child: AppText(
                'Cancel',
                variant: AppTextVariant.labelLarge,
                color: dialogColors.textSecondary,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _InstructionStep extends StatelessWidget {
  const _InstructionStep({
    required this.number,
    required this.text,
    required this.colors,
    this.isLast = false,
  });

  final String number;
  final String text;
  final ThemeColors colors;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: colors.gold.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Center(
              child: AppText(
                number,
                variant: AppTextVariant.labelSmall,
                color: colors.gold,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: AppText(
              text,
              variant: AppTextVariant.bodyMedium,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
