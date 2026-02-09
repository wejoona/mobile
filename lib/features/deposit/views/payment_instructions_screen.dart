import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../providers/deposit_provider.dart';
import '../models/deposit_response.dart';

/// Payment Instructions Screen
class PaymentInstructionsScreen extends ConsumerStatefulWidget {
  const PaymentInstructionsScreen({super.key});

  @override
  ConsumerState<PaymentInstructionsScreen> createState() => _PaymentInstructionsScreenState();
}

class _PaymentInstructionsScreenState extends ConsumerState<PaymentInstructionsScreen> {
  Timer? _statusTimer;
  Timer? _countdownTimer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _startStatusPolling();
    _startCountdown();
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startStatusPolling() {
    // Poll status every 10 seconds
    _statusTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      ref.read(depositProvider.notifier).checkStatus();
    });
  }

  void _startCountdown() {
    final depositState = ref.read(depositProvider);
    if (depositState.response != null) {
      _remainingSeconds = depositState.response!.expiresAt
          .difference(DateTime.now())
          .inSeconds;

      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) {
          setState(() {
            _remainingSeconds--;
            if (_remainingSeconds <= 0) {
              _countdownTimer?.cancel();
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final depositState = ref.watch(depositProvider);

    // Navigate to status screen if completed
    ref.listen(depositProvider, (prev, next) {
      if (next.step == DepositFlowStep.completed) {
        context.go('/deposit/status');
      }
    });

    if (depositState.response == null) {
      return Scaffold(
        backgroundColor: colors.canvas,
        body: Center(
          child: CircularProgressIndicator(color: colors.gold),
        ),
      );
    }

    final response = depositState.response!;
    final instructions = response.paymentInstructions;

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          l10n.deposit_paymentInstructions,
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _handleClose(l10n),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Countdown Timer
                      _buildCountdownCard(colors, l10n),

                      const SizedBox(height: AppSpacing.xl),

                      // Amount Card
                      _buildAmountCard(instructions, colors, l10n),

                      const SizedBox(height: AppSpacing.xl),

                      // Reference Number
                      _buildReferenceCard(instructions, colors, l10n),

                      const SizedBox(height: AppSpacing.xl),

                      // Instructions
                      AppText(
                        l10n.deposit_howToPay,
                        variant: AppTextVariant.titleMedium,
                        color: colors.textPrimary,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      _buildInstructionsCard(instructions, colors, l10n),

                      const SizedBox(height: AppSpacing.xl),

                      // USSD Code (if available)
                      if (instructions.ussdCode != null)
                        _buildUssdCard(instructions, colors, l10n),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Action Buttons
              if (instructions.deepLink != null)
                AppButton(
                  label: l10n.deposit_openApp(instructions.provider),
                  onPressed: () => _launchDeepLink(instructions.deepLink!),
                  isFullWidth: true,
                  icon: Icons.open_in_new,
                ),

              const SizedBox(height: AppSpacing.sm),

              AppButton(
                label: l10n.deposit_completedPayment,
                onPressed: _handleCheckStatus,
                variant: AppButtonVariant.secondary,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownCard(ThemeColors colors, AppLocalizations l10n) {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    final isExpiringSoon = _remainingSeconds < 300; // Less than 5 minutes

    return AppCard(
      variant: AppCardVariant.elevated,
      child: Row(
        children: [
          Icon(
            Icons.timer_outlined,
            color: isExpiringSoon ? colors.warning : colors.textSecondary,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  l10n.deposit_expiresIn,
                  variant: AppTextVariant.labelMedium,
                  color: colors.textSecondary,
                ),
                AppText(
                  '$minutes:${seconds.toString().padLeft(2, '0')}',
                  variant: AppTextVariant.titleLarge,
                  color: isExpiringSoon ? colors.warning : colors.textPrimary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountCard(PaymentInstructions instructions, ThemeColors colors, AppLocalizations l10n) {
    return AppCard(
      variant: AppCardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            l10n.deposit_amountToPay,
            variant: AppTextVariant.labelMedium,
            color: colors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppText(
            '${instructions.amountToPay.toStringAsFixed(0)} ${instructions.currency}',
            variant: AppTextVariant.displaySmall,
            color: colors.gold,
          ),
          const SizedBox(height: AppSpacing.xs),
          AppText(
            l10n.deposit_via(instructions.provider),
            variant: AppTextVariant.bodySmall,
            color: colors.textTertiary,
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceCard(PaymentInstructions instructions, ThemeColors colors, AppLocalizations l10n) {
    return AppCard(
      variant: AppCardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                l10n.deposit_referenceNumber,
                variant: AppTextVariant.labelMedium,
                color: colors.textSecondary,
              ),
              GestureDetector(
                onTap: () => _copyToClipboard(instructions.referenceNumber, l10n),
                child: Row(
                  children: [
                    Icon(Icons.copy, color: colors.gold, size: 16),
                    const SizedBox(width: AppSpacing.xs),
                    AppText(
                      l10n.action_copy,
                      variant: AppTextVariant.labelSmall,
                      color: colors.gold,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colors.elevated,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Center(
              child: AppText(
                instructions.referenceNumber,
                variant: AppTextVariant.titleMedium,
                color: colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard(PaymentInstructions instructions, ThemeColors colors, AppLocalizations l10n) {
    final steps = instructions.instructions.split('\n');

    return AppCard(
      variant: AppCardVariant.subtle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          if (step.trim().isEmpty) return const SizedBox.shrink();

          return Padding(
            padding: EdgeInsets.only(
              bottom: index < steps.length - 1 ? AppSpacing.md : 0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: colors.gold.withValues(alpha: colors.isDark ? 0.2 : 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: AppText(
                      '${index + 1}',
                      variant: AppTextVariant.labelSmall,
                      color: colors.gold,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppText(
                    step.trim(),
                    variant: AppTextVariant.bodyMedium,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUssdCard(PaymentInstructions instructions, ThemeColors colors, AppLocalizations l10n) {
    return AppCard(
      variant: AppCardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            l10n.deposit_ussdCode,
            variant: AppTextVariant.labelMedium,
            color: colors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.sm),
          GestureDetector(
            onTap: () => _dialUssd(instructions.ussdCode!),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colors.gold.withValues(alpha: colors.isDark ? 0.1 : 0.08),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: colors.gold, width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.phone, color: colors.gold, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  AppText(
                    instructions.ussdCode!,
                    variant: AppTextVariant.titleMedium,
                    color: colors.gold,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text, AppLocalizations l10n) {
    Clipboard.setData(ClipboardData(text: text));
    final colors = context.colors;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.deposit_copied),
        backgroundColor: colors.success,
      ),
    );
  }

  Future<void> _launchDeepLink(String deepLink) async {
    final uri = Uri.parse(deepLink);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _dialUssd(String ussdCode) async {
    final uri = Uri.parse('tel:$ussdCode');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _handleCheckStatus() {
    ref.read(depositProvider.notifier).checkStatus();
    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Checking payment status...')),
    );
  }

  void _handleClose(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.container,
        title: AppText(
          l10n.deposit_cancelTitle,
          variant: AppTextVariant.titleMedium,
        ),
        content: AppText(
          l10n.deposit_cancelMessage,
          variant: AppTextVariant.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: AppText(l10n.action_cancel),
          ),
          AppButton(
            label: l10n.action_confirm,
            onPressed: () {
              Navigator.pop(context);
              context.go('/home');
            },
            size: AppButtonSize.small,
          ),
        ],
      ),
    );
  }
}
