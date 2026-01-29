import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../features/qr_payment/widgets/qr_display.dart';
import '../providers/merchant_provider.dart';
import '../services/merchant_service.dart';

/// Create Payment Request View
/// Allows merchants to create dynamic QR codes with specific amounts
class CreatePaymentRequestView extends ConsumerStatefulWidget {
  final MerchantResponse merchant;

  const CreatePaymentRequestView({
    super.key,
    required this.merchant,
  });

  static const String routeName = '/create-payment-request';

  @override
  ConsumerState<CreatePaymentRequestView> createState() =>
      _CreatePaymentRequestViewState();
}

class _CreatePaymentRequestViewState
    extends ConsumerState<CreatePaymentRequestView> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _referenceController = TextEditingController();
  Timer? _expirationTimer;
  int _remainingSeconds = 0;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _referenceController.dispose();
    _expirationTimer?.cancel();
    super.dispose();
  }

  double? get _amount => double.tryParse(_amountController.text);

  bool get _canCreate {
    final amount = _amount;
    return amount != null && amount > 0 && amount <= 10000;
  }

  void _createPaymentRequest() async {
    final amount = _amount;
    if (amount == null) return;

    final notifier = ref.read(paymentRequestProvider.notifier);
    final success = await notifier.createPaymentRequest(
      merchantId: widget.merchant.merchantId,
      amount: amount,
      description: _descriptionController.text.isNotEmpty
          ? _descriptionController.text
          : null,
      reference: _referenceController.text.isNotEmpty
          ? _referenceController.text
          : null,
    );

    if (success && mounted) {
      final state = ref.read(paymentRequestProvider);
      if (state.paymentRequest != null) {
        _startExpirationTimer(state.paymentRequest!.expiresInSeconds);
      }
    }
  }

  void _startExpirationTimer(int seconds) {
    _remainingSeconds = seconds;
    _expirationTimer?.cancel();
    _expirationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _remainingSeconds--;
          if (_remainingSeconds <= 0) {
            timer.cancel();
            ref.read(paymentRequestProvider.notifier).reset();
          }
        });
      }
    });
  }

  String _formatTimeRemaining() {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _shareQr() {
    final state = ref.read(paymentRequestProvider);
    if (state.paymentRequest == null) return;

    final pr = state.paymentRequest!;
    final text = '''
Payment Request from ${widget.merchant.displayName}

Amount: \$${pr.amount.toStringAsFixed(2)} USDC
${pr.description != null ? 'Description: ${pr.description}\n' : ''}
Scan the QR code or use this link to pay.

Powered by JoonaPay
''';
    Share.share(text);
  }

  void _newRequest() {
    _expirationTimer?.cancel();
    ref.read(paymentRequestProvider.notifier).reset();
    _amountController.clear();
    _descriptionController.clear();
    _referenceController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(paymentRequestProvider);

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: AppText('Request Payment', variant: AppTextVariant.titleMedium),
        backgroundColor: Colors.transparent,
        actions: [
          if (state.paymentRequest != null)
            IconButton(
              onPressed: _newRequest,
              icon: Icon(Icons.refresh, color: AppColors.gold500),
              tooltip: 'New Request',
            ),
        ],
      ),
      body: SafeArea(
        child: state.paymentRequest != null
            ? _buildQrDisplay(context, l10n, state.paymentRequest!)
            : _buildRequestForm(context, l10n, state),
      ),
    );
  }

  Widget _buildRequestForm(BuildContext context, AppLocalizations l10n, PaymentRequestState state) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Merchant info card
          AppCard(
            variant: AppCardVariant.elevated,
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.gold500.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.store,
                    color: AppColors.gold500,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        widget.merchant.displayName,
                        variant: AppTextVariant.bodyLarge,
                      ),
                      AppText(
                        'Creating payment request',
                        variant: AppTextVariant.bodySmall,
                        color: AppColors.silver,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.xl),

          // Amount input
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                'Amount (USDC)',
                variant: AppTextVariant.labelMedium,
              ),
              SizedBox(height: AppSpacing.xs),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.charcoal,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Text(
                      '\$ ',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gold500,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          hintStyle: TextStyle(color: AppColors.silver),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),

          // Description input
          AppText(
            'Description (optional)',
            variant: AppTextVariant.labelMedium,
          ),
          SizedBox(height: AppSpacing.xs),
          AppInput(
            controller: _descriptionController,
            hint: 'e.g., Coffee and croissant',
            maxLines: 2,
            maxLength: 200,
          ),
          SizedBox(height: AppSpacing.md),

          // Reference input
          AppText(
            'Reference (optional)',
            variant: AppTextVariant.labelMedium,
          ),
          SizedBox(height: AppSpacing.xs),
          AppInput(
            controller: _referenceController,
            hint: 'e.g., Order #123',
            maxLength: 50,
          ),
          SizedBox(height: AppSpacing.xl),

          // Error message
          if (state.error != null) ...[
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: AppColors.error, size: 20),
                  SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: AppText(
                      state.error!,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.md),
          ],

          // Create button
          AppButton(
            label: 'Generate QR Code',
            onPressed: _canCreate && !state.isLoading
                ? _createPaymentRequest
                : null,
            variant: AppButtonVariant.primary,
            isLoading: state.isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildQrDisplay(BuildContext context, AppLocalizations l10n, PaymentRequestResponse pr) {
    final isExpired = _remainingSeconds <= 0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          // QR Code Card
          AppCard(
            variant: AppCardVariant.elevated,
            padding: EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              children: [
                // Amount
                AppText(
                  '\$${pr.amount.toStringAsFixed(2)}',
                  variant: AppTextVariant.displayMedium,
                  color: AppColors.gold500,
                ),
                AppText(
                  'USDC',
                  variant: AppTextVariant.bodyMedium,
                  color: AppColors.silver,
                ),
                if (pr.description != null) ...[
                  SizedBox(height: AppSpacing.xs),
                  AppText(
                    pr.description!,
                    variant: AppTextVariant.bodyMedium,
                    color: AppColors.silver,
                    textAlign: TextAlign.center,
                  ),
                ],
                SizedBox(height: AppSpacing.lg),

                // QR Code or Expired state
                if (!isExpired)
                  QrDisplay(
                    data: pr.qrData,
                    size: 200,
                    showBorder: true,
                  )
                else
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppColors.charcoal,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.timer_off,
                          size: 48,
                          color: AppColors.silver,
                        ),
                        SizedBox(height: AppSpacing.sm),
                        AppText(
                          'Request Expired',
                          color: AppColors.silver,
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: AppSpacing.lg),

                // Timer
                if (!isExpired)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: _remainingSeconds < 60
                          ? AppColors.error.withValues(alpha: 0.1)
                          : AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(
                        color: _remainingSeconds < 60
                            ? AppColors.error.withValues(alpha: 0.3)
                            : AppColors.success.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer,
                          size: 18,
                          color: _remainingSeconds < 60
                              ? AppColors.error
                              : AppColors.success,
                        ),
                        SizedBox(width: AppSpacing.xs),
                        AppText(
                          'Expires in ${_formatTimeRemaining()}',
                          color: _remainingSeconds < 60
                              ? AppColors.error
                              : AppColors.success,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.lg),

          // Action buttons
          if (!isExpired)
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: l10n.action_share,
                    onPressed: _shareQr,
                    variant: AppButtonVariant.secondary,
                    icon: Icons.share,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppButton(
                    label: 'New Request',
                    onPressed: _newRequest,
                    variant: AppButtonVariant.primary,
                    icon: Icons.add,
                  ),
                ),
              ],
            )
          else
            AppButton(
              label: 'Create New Request',
              onPressed: _newRequest,
              variant: AppButtonVariant.primary,
              icon: Icons.refresh,
            ),

          SizedBox(height: AppSpacing.lg),

          // Instructions
          AppCard(
            variant: AppCardVariant.subtle,
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.gold500),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppText(
                    'Show this QR code to your customer. The payment will be credited automatically.',
                    variant: AppTextVariant.bodySmall,
                    color: AppColors.silver,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
