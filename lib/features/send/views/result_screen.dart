import 'package:usdc_wallet/core/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/beneficiaries/providers/beneficiaries_provider.dart';
import 'package:usdc_wallet/features/beneficiaries/models/beneficiary.dart';
import 'package:usdc_wallet/features/send/providers/send_provider.dart';
import 'package:usdc_wallet/core/haptics/haptic_service.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _showSaveOption = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();

    // Trigger haptic feedback based on result
    Future.microtask(() {
      _checkBeneficiaryStatus();
      _triggerResultHaptic();
    });
  }

  void _triggerResultHaptic() {
    final state = ref.read(sendMoneyProvider);
    final isSuccess = state.result != null && state.result!.status == 'completed';

    if (isSuccess) {
      hapticService.paymentConfirmed();
    } else {
      hapticService.error();
    }
  }

  Future<void> _checkBeneficiaryStatus() async {
    final state = ref.read(sendMoneyProvider);
    if (state.recipient != null && !state.recipient!.isBeneficiary) {
      setState(() => _showSaveOption = true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(sendMoneyProvider);
    final colors = context.colors;

    final isSuccess = state.result != null && state.result!.status == 'completed';

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              // Success/Error animation
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: (isSuccess ? colors.success : colors.error)
                        .withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSuccess ? Icons.check_circle : Icons.error,
                    size: 80,
                    color: isSuccess ? colors.success : colors.error,
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.xl),

              // Title
              AppText(
                isSuccess ? l10n.send_transferSuccess : l10n.send_transferFailed,
                variant: AppTextVariant.headlineMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.sm),

              // Subtitle
              if (isSuccess) ...[
                AppText(
                  l10n.send_transferSuccessMessage,
                  variant: AppTextVariant.bodyMedium,
                  color: colors.textSecondary,
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                AppText(
                  state.error ?? l10n.error_transferFailed,
                  variant: AppTextVariant.bodyMedium,
                  color: colors.error,
                  textAlign: TextAlign.center,
                ),
              ],
              SizedBox(height: AppSpacing.xl),

              // Transaction details card
              if (isSuccess && state.result != null) ...[
                AppCard(
                  child: Column(
                    children: [
                      // Amount
                      AppText(
                        '\$${Formatters.formatCurrency(state.result!.amount)}',
                        variant: AppTextVariant.headlineLarge,
                        color: colors.gold,
                      ),
                      SizedBox(height: AppSpacing.sm),
                      AppText(
                        l10n.send_sentTo,
                        variant: AppTextVariant.bodySmall,
                        color: colors.textSecondary,
                      ),
                      SizedBox(height: AppSpacing.xs),
                      AppText(
                        state.recipient?.name ?? state.recipient?.phoneNumber ?? '',
                        variant: AppTextVariant.bodyLarge,
                        fontWeight: FontWeight.w600,
                      ),
                      if (state.recipient?.name != null) ...[
                        SizedBox(height: AppSpacing.xs),
                        AppText(
                          state.recipient!.phoneNumber,
                          variant: AppTextVariant.bodySmall,
                          color: colors.textSecondary,
                        ),
                      ],
                      SizedBox(height: AppSpacing.md),

                      Divider(
                        color: colors.textSecondary.withValues(alpha: 0.2),
                      ),
                      SizedBox(height: AppSpacing.md),

                      // Reference
                      _buildDetailRow(
                        l10n.send_reference,
                        state.result!.reference,
                        colors,
                        canCopy: true,
                      ),
                      SizedBox(height: AppSpacing.sm),

                      // Date
                      _buildDetailRow(
                        l10n.send_date,
                        Formatters.formatDateTime(state.result!.createdAt),
                        colors,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.md),
              ],

              const Spacer(),

              // Action buttons
              if (isSuccess) ...[
                // Save as beneficiary option
                if (_showSaveOption)
                  AppButton(
                    label: l10n.send_saveAsBeneficiary,
                    variant: AppButtonVariant.secondary,
                    icon: Icons.bookmark_add_outlined,
                    onPressed: _handleSaveBeneficiary,
                    isFullWidth: true,
                  ),
                if (_showSaveOption) SizedBox(height: AppSpacing.sm),

                // Share receipt
                AppButton(
                  label: l10n.send_shareReceipt,
                  variant: AppButtonVariant.secondary,
                  icon: Icons.share_outlined,
                  onPressed: _handleShareReceipt,
                  isFullWidth: true,
                ),
                SizedBox(height: AppSpacing.sm),

                // Done button
                AppButton(
                  label: l10n.action_done,
                  onPressed: _handleDone,
                  isFullWidth: true,
                ),
              ] else ...[
                // Retry button
                AppButton(
                  label: l10n.action_retry,
                  onPressed: () => context.go('/send/confirm'),
                  isFullWidth: true,
                ),
                SizedBox(height: AppSpacing.sm),

                // Cancel button
                AppButton(
                  label: l10n.action_cancel,
                  variant: AppButtonVariant.secondary,
                  onPressed: _handleDone,
                  isFullWidth: true,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeColors colors, {bool canCopy = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          label,
          variant: AppTextVariant.bodyMedium,
          color: colors.textSecondary,
        ),
        Row(
          children: [
            AppText(
              value,
              variant: AppTextVariant.bodyMedium,
            ),
            if (canCopy) ...[
              SizedBox(width: AppSpacing.xs),
              InkWell(
                onTap: () => _copyToClipboard(value, colors),
                child: Icon(
                  Icons.copy,
                  size: 16,
                  color: colors.gold,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Future<void> _copyToClipboard(String text, ThemeColors colors) async {
    final l10n = AppLocalizations.of(context)!;
    hapticService.lightTap();
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.common_copiedToClipboard),
          backgroundColor: colors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleSaveBeneficiary() async {
    final state = ref.read(sendMoneyProvider);
    final colors = context.colors;
    if (state.recipient == null) return;

    // Navigate to add beneficiary screen or show dialog
    // For now, we'll add directly
    try {
      final request = CreateBeneficiaryRequest(
        name: state.recipient!.name ?? state.recipient!.phoneNumber,
        phoneE164: state.recipient!.phoneNumber,
        accountType: AccountType.joonapayUser,
      );

      await ref.read(beneficiariesProvider.notifier).createBeneficiary(request);

      setState(() => _showSaveOption = false);

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.send_beneficiarySaved),
            backgroundColor: colors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.common_genericError),
            backgroundColor: colors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleShareReceipt() async {
    final state = ref.read(sendMoneyProvider);
    if (state.result == null) return;

    final l10n = AppLocalizations.of(context)!;
    final text = '''
${l10n.send_transferReceipt}

${l10n.send_amount}: \$${Formatters.formatCurrency(state.result!.amount)}
${l10n.send_recipient}: ${state.recipient?.name ?? state.recipient?.phoneNumber}
${l10n.send_reference}: ${state.result!.reference}
${l10n.send_date}: ${Formatters.formatDateTime(state.result!.createdAt)}

${l10n.appName}
''';

    await SharePlus.instance.share(ShareParams(text: text));
  }

  void _handleDone() {
    // Reset the send state
    ref.read(sendMoneyProvider.notifier).reset();
    // Navigate to home
    context.go('/home');
  }
}
