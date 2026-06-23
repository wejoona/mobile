import 'dart:async';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/core/l10n/app_strings.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/state/index.dart';
import 'package:usdc_wallet/features/payment_links/models/index.dart';
import 'package:usdc_wallet/features/qr_payment/widgets/branded_qr_image.dart';
import 'package:usdc_wallet/services/service_providers.dart';

class RequestMoneyView extends ConsumerStatefulWidget {
  const RequestMoneyView({super.key});

  @override
  ConsumerState<RequestMoneyView> createState() => _RequestMoneyViewState();
}

class _RequestMoneyViewState extends ConsumerState<RequestMoneyView> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String? _amountError;
  bool _showQr = false;
  bool _isGenerating = false;
  String? _requestLink;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final userState = ref.watch(userStateMachineProvider);

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          l10n.services_requestMoney,
          variant: AppTextVariant.titleLarge,
          color: colors.textPrimary,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => context.fsmPop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_showQr) ...[
              // Amount Input
              AppText(
                AppStrings.requestAmount,
                variant: AppTextVariant.labelMedium,
                color: colors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildAmountInput(colors),

              const SizedBox(height: AppSpacing.xxl),

              // Note (optional)
              AppText(
                'Add a Note (Optional)',
                variant: AppTextVariant.labelMedium,
                color: colors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppInput(
                controller: _noteController,
                hint: 'e.g., Lunch money, rent share...',
                maxLines: 2,
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // Generate Request Button
              AppButton(
                label: AppStrings.generateRequest,
                onPressed: _canGenerate() && !_isGenerating
                    ? _generateRequest
                    : null,
                variant: AppButtonVariant.primary,
                isLoading: _isGenerating,
                isFullWidth: true,
              ),
            ] else ...[
              // QR Code Display
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                      ),
                      child: BrandedQrImage(
                        data: _paymentLink,
                        size: 200,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Color(
                            0xFF1A1A1F,
                          ), // Always dark for visibility
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Color(
                            0xFF1A1A1F,
                          ), // Always dark for visibility
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    AppText(
                      'Request for \$${_amountController.text}',
                      variant: AppTextVariant.headlineSmall,
                      color: context.colors.gold,
                    ),
                    if (_noteController.text.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      AppText(
                        '"${_noteController.text}"',
                        variant: AppTextVariant.bodyMedium,
                        color: colors.textSecondary,
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    AppText(
                      'From: ${userState.phone ?? 'Your account'}',
                      variant: AppTextVariant.bodySmall,
                      color: colors.textTertiary,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // Share Options
              Row(
                children: [
                  Expanded(
                    child: _ShareButton(
                      icon: Icons.copy,
                      label: AppStrings.copyLink,
                      onTap: () => unawaited(_copyLink()),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _ShareButton(
                      icon: Icons.share,
                      label: AppStrings.share,
                      onTap: () => unawaited(_shareRequest()),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _ShareButton(
                      icon: Icons.message,
                      label: 'SMS',
                      onTap: _sendSms,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xxl),

              // New Request Button
              AppButton(
                label: AppStrings.createNewRequest,
                onPressed: () {
                  setState(() {
                    _showQr = false;
                    _amountController.clear();
                    _noteController.clear();
                    _requestLink = null;
                  });
                },
                variant: AppButtonVariant.secondary,
                isFullWidth: true,
              ),
            ],

            const SizedBox(height: AppSpacing.xxl),

            // Info Card
            _buildInfoCard(colors),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInput(ThemeColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: context.colors.elevated,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(
          color: _amountError != null
              ? context.colors.error
              : context.colors.borderSubtle,
        ),
      ),
      child: Row(
        children: [
          AppText(
            '\$',
            variant: AppTextVariant.headlineMedium,
            color: colors.textTertiary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: AppInput(
              controller: _amountController,
              variant: AppInputVariant.amount,
              hint: '0.00',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              error: _amountError,
              onChanged: (_) {
                _validateAmount();
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(ThemeColors colors) {
    return AppCard(
      variant: AppCardVariant.subtle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: context.colors.info, size: 20),
              const SizedBox(width: AppSpacing.sm),
              AppText(
                AppStrings.howItWorks,
                variant: AppTextVariant.labelMedium,
                color: colors.textPrimary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildInfoStep('1', 'Generate a payment request with amount', colors),
          _buildInfoStep(
            '2',
            'Share the QR code or link with the payer',
            colors,
          ),
          _buildInfoStep('3', 'They scan/click to pay you directly', colors),
        ],
      ),
    );
  }

  Widget _buildInfoStep(String number, String text, ThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: context.colors.gold.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: AppText(
                number,
                variant: AppTextVariant.labelSmall,
                color: context.colors.gold,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: AppText(
              text,
              variant: AppTextVariant.bodySmall,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _validateAmount() {
    final amount = double.tryParse(_amountController.text) ?? 0;

    setState(() {
      if (_amountController.text.isEmpty) {
        _amountError = null;
      } else if (amount <= 0) {
        _amountError = 'Enter a valid amount';
      } else if (amount > 10000) {
        _amountError = 'Maximum request is \$10,000';
      } else {
        _amountError = null;
      }
    });
  }

  bool _canGenerate() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    return amount > 0 && amount <= 10000 && _amountError == null;
  }

  Future<void> _generateRequest() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;

    setState(() => _isGenerating = true);
    try {
      final service = ref.read(paymentLinksServiceProvider);
      final link = await service.createLink(
        CreateLinkRequest(
          amount: amount,
          currency: 'USDC',
          description: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
          expiryHours: 24 * 30,
        ),
      );
      if (!mounted) return;
      setState(() {
        _requestLink = link.url;
        _showQr = true;
      });
    } on Exception {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not create the payment request.'),
          backgroundColor: context.colors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  String get _paymentLink => _requestLink ?? '';

  Future<void> _copyLink() async {
    await Clipboard.setData(ClipboardData(text: _paymentLink));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.paymentLinks_copied),
        backgroundColor: context.colors.success,
      ),
    );
  }

  Future<void> _shareRequest() async {
    final amount = _amountController.text;
    final note = _noteController.text.isNotEmpty
        ? ' for "${_noteController.text}"'
        : '';

    await SharePlus.instance.share(
      ShareParams(
        text: 'Hey! Please send me \$$amount$note on Korido.\n\n$_paymentLink',
        title: 'Payment Request - \$$amount',
      ),
    );
  }

  void _sendSms() {
    // This would open SMS app with pre-filled message
    unawaited(_shareRequest());
  }
}

class _ShareButton extends StatelessWidget {
  const _ShareButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          color: colors.container,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: colors.borderSubtle),
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colors.elevated,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: context.colors.gold, size: 22),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              label,
              variant: AppTextVariant.labelSmall,
              color: colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
