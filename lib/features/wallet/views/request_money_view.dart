import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/state/index.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

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
          onPressed: () => context.pop(),
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
                'Request Amount',
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
                label: 'Generate Request',
                onPressed: _canGenerate() ? _generateRequest : null,
                variant: AppButtonVariant.primary,
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
                      child: QrImageView(
                        data: _generatePaymentLink(),
                        version: QrVersions.auto,
                        size: 200,
                        backgroundColor: Colors.white,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Color(0xFF1A1A1F), // Always dark for visibility
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Color(0xFF1A1A1F), // Always dark for visibility
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
                      label: 'Copy Link',
                      onTap: _copyLink,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _ShareButton(
                      icon: Icons.share,
                      label: 'Share',
                      onTap: _shareRequest,
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
                label: 'Create New Request',
                onPressed: () {
                  setState(() {
                    _showQr = false;
                    _amountController.clear();
                    _noteController.clear();
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
          color: _amountError != null ? context.colors.error : context.colors.borderSubtle,
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
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                'How it works',
                variant: AppTextVariant.labelMedium,
                color: colors.textPrimary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildInfoStep('1', 'Generate a payment request with amount', colors),
          _buildInfoStep('2', 'Share the QR code or link with the payer', colors),
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

  void _generateRequest() {
    setState(() => _showQr = true);
  }

  String _generatePaymentLink() {
    final userState = ref.read(userStateMachineProvider);
    final amount = _amountController.text;
    final note = _noteController.text;
    final phone = userState.phone ?? '';

    // Generate a payment deep link
    return 'joonapay://pay?to=$phone&amount=$amount&note=${Uri.encodeComponent(note)}';
  }

  void _copyLink() {
    final colors = context.colors;
    Clipboard.setData(ClipboardData(text: _generatePaymentLink()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Payment link copied!'),
        backgroundColor: context.colors.success,
      ),
    );
  }

  void _shareRequest() {
    final amount = _amountController.text;
    final note = _noteController.text.isNotEmpty ? ' for "${_noteController.text}"' : '';

    Share.share(
      'Hey! Please send me \$$amount$note on JoonaPay.\n\n${_generatePaymentLink()}',
      subject: 'Payment Request - \$$amount',
    );
  }

  void _sendSms() {
    // This would open SMS app with pre-filled message
    _shareRequest();
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
