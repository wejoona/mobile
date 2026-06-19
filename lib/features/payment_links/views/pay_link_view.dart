import 'package:usdc_wallet/utils/currency_utils.dart';
import 'package:usdc_wallet/services/service_providers.dart';
import 'package:usdc_wallet/services/pin/pin_service.dart';
import 'package:usdc_wallet/core/utils/idempotency.dart';
import 'package:usdc_wallet/core/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/components/composed/pin_confirmation_sheet.dart';
import 'package:usdc_wallet/features/payment_links/providers/payment_links_provider.dart';
import 'package:usdc_wallet/features/wallet/providers/balance_provider.dart';
import 'package:usdc_wallet/state/wallet_state_machine.dart';
import 'package:usdc_wallet/features/wallet/providers/wallet_provider.dart';
import 'package:usdc_wallet/features/payment_links/models/index.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

/// Screen for paying via a received payment link
/// Shows link details and allows user to complete payment
class PayLinkView extends ConsumerStatefulWidget {
  const PayLinkView({super.key, required this.linkCode});

  final String linkCode;

  @override
  ConsumerState<PayLinkView> createState() => _PayLinkViewState();
}

class _PayLinkViewState extends ConsumerState<PayLinkView> {
  bool _isProcessing = false;
  PaymentLink? _link;
  String? _error;
  double? _xofRate; // XOF per USD from API

  @override
  void initState() {
    super.initState();
    _loadLink();
    _loadExchangeRate();
  }

  Future<void> _loadLink() async {
    try {
      final service = ref.read(paymentLinksServiceProvider);
      final link = await service.getLinkByCode(widget.linkCode);
      if (mounted) {
        setState(() {
          _link = link;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _loadExchangeRate() async {
    try {
      final rateResult = await ref.read(
        exchangeRateProvider(
          const ExchangeRateParams(
            sourceCurrency: 'USD',
            targetCurrency: 'XOF',
            amount: 1.0,
          ),
        ).future,
      );
      if (mounted) {
        setState(() {
          _xofRate = rateResult.targetAmount;
        });
      }
    } catch (_) {
      // Fallback: rate will show as unavailable
    }
  }

  Future<void> _handlePayment() async {
    if (_link == null) return;

    final l10n = AppLocalizations.of(context)!;
    final usdcBalance = ref.read(usdcBalanceProvider);
    final payableUsdcAmount = _payableUsdcAmount;

    if (!_isUsdcSettledLink) {
      _showErrorDialog(
        l10n.common_error,
        'This payment link currency is not available yet. Ask the sender to create a USDC link.',
      );
      return;
    }

    if (payableUsdcAmount == null) {
      _showErrorDialog(
        l10n.common_error,
        'Exchange rate unavailable. Please try again.',
      );
      return;
    }

    // Check balance
    if (usdcBalance < payableUsdcAmount) {
      _showErrorDialog(
        l10n.common_error,
        l10n.paymentLinks_insufficientBalance,
      );
      return;
    }

    String? pinToken;
    final idempotencyKey = generateIdempotencyKey();
    final confirmation = await PinConfirmationSheet.show(
      context: context,
      title: l10n.action_confirm,
      subtitle: l10n.send_enterPinToConfirm,
      amount: payableUsdcAmount,
      recipient: _link!.recipientName,
      onConfirm: (pin) async {
        final verification = await ref
            .read(pinServiceProvider)
            .verifyPinWithBackend(pin);
        if (verification.success && verification.pinToken != null) {
          pinToken = verification.pinToken;
          return true;
        }
        return false;
      },
    );
    if (confirmation != PinConfirmationResult.success || pinToken == null) {
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final service = ref.read(paymentLinksServiceProvider);
      final result = await service.payLink(
        widget.linkCode,
        amount: payableUsdcAmount,
        pinToken: pinToken!,
        idempotencyKey: idempotencyKey,
      );

      if (mounted) {
        ref.invalidate(paymentLinksProvider);
        ref.invalidate(walletBalanceProvider);
        await ref.read(walletStateMachineProvider.notifier).refresh();
        if (!mounted) return;

        // Show success and navigate to receipt
        context.fsmGo(
          '/send/result',
          extra: {
            'success': true,
            'amount': payableUsdcAmount,
            'recipient': _link!.recipientName,
            'transactionId': result.transactionId,
            'note': _link!.description,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        _showErrorDialog(l10n.common_error, e.toString());
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.container,
        title: AppText(title, variant: AppTextVariant.headlineSmall),
        content: AppText(message, variant: AppTextVariant.bodyLarge),
        actions: [
          AppButton(
            label: AppLocalizations.of(context)!.common_ok,
            onPressed: () => Navigator.pop(context),
            size: AppButtonSize.small,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        title: AppText(
          l10n.paymentLinks_payTitle,
          variant: AppTextVariant.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _buildBody(l10n),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_error != null) {
      return _buildError(l10n);
    }

    if (_link == null) {
      return _buildLoading();
    }

    // Check link status
    if (_link!.isExpired) {
      return _buildExpired(l10n);
    }

    if (_link!.isPaid) {
      return _buildAlreadyPaid(l10n);
    }

    if (_link!.isCancelled) {
      return _buildCancelled(l10n);
    }

    return _buildPaymentForm(l10n);
  }

  Widget _buildLoading() {
    return Center(child: CircularProgressIndicator(color: context.colors.gold));
  }

  Widget _buildError(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: context.colors.error),
            SizedBox(height: AppSpacing.lg),
            AppText(
              l10n.paymentLinks_linkNotFoundTitle,
              variant: AppTextVariant.headlineMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
            AppText(
              l10n.paymentLinks_linkNotFoundMessage,
              variant: AppTextVariant.bodyLarge,
              color: context.colors.textSecondary,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),
            AppButton(
              label: l10n.common_close,
              onPressed: () => context.fsmPop(),
              variant: AppButtonVariant.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpired(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.schedule, size: 80, color: context.colors.textSecondary),
            SizedBox(height: AppSpacing.lg),
            AppText(
              l10n.paymentLinks_linkExpiredTitle,
              variant: AppTextVariant.headlineMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
            AppText(
              l10n.paymentLinks_linkExpiredMessage,
              variant: AppTextVariant.bodyLarge,
              color: context.colors.textSecondary,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),
            AppButton(
              label: l10n.common_close,
              onPressed: () => context.fsmPop(),
              variant: AppButtonVariant.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlreadyPaid(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: context.colors.success,
            ),
            SizedBox(height: AppSpacing.lg),
            AppText(
              l10n.paymentLinks_linkPaidTitle,
              variant: AppTextVariant.headlineMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
            AppText(
              l10n.paymentLinks_linkPaidMessage,
              variant: AppTextVariant.bodyLarge,
              color: context.colors.textSecondary,
              textAlign: TextAlign.center,
            ),
            if (_link!.paidAt != null) ...[
              SizedBox(height: AppSpacing.lg),
              AppCard(
                child: Column(
                  children: [
                    _buildInfoRow(
                      l10n.paymentLinks_paidBy,
                      _link!.paidByName ??
                          _link!.paidByPhone ??
                          l10n.common_unknown,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    _buildInfoRow(
                      l10n.paymentLinks_paidAt,
                      Formatters.formatDateTime(_link!.paidAt!),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: AppSpacing.xl),
            AppButton(
              label: l10n.common_close,
              onPressed: () => context.fsmPop(),
              variant: AppButtonVariant.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelled(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.block, size: 80, color: context.colors.error),
            SizedBox(height: AppSpacing.lg),
            AppText(
              l10n.paymentLinks_linkNotFoundTitle,
              variant: AppTextVariant.headlineMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
            AppText(
              l10n.paymentLinks_linkNotFoundMessage,
              variant: AppTextVariant.bodyLarge,
              color: context.colors.textSecondary,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),
            AppButton(
              label: l10n.common_close,
              onPressed: () => context.fsmPop(),
              variant: AppButtonVariant.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentForm(AppLocalizations l10n) {
    final payableUsdcAmount = _payableUsdcAmount;

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(AppSpacing.md),
              children: [
                // Amount Card
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        context.colors.gold.withValues(alpha: 0.1),
                        context.colors.gold.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(
                      color: context.colors.gold.withValues(alpha: 0.2),
                    ),
                  ),
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      AppText(
                        l10n.wallet_balance,
                        variant: AppTextVariant.bodyMedium,
                        color: context.colors.textSecondary,
                      ),
                      SizedBox(height: AppSpacing.xs),
                      AppText(
                        formatCurrency(_link!.amount, _link!.currency),
                        variant: AppTextVariant.displaySmall,
                        color: context.colors.gold,
                        fontWeight: FontWeight.bold,
                      ),
                      SizedBox(height: AppSpacing.xs),
                      AppText(
                        _paymentEstimateLabel,
                        variant: AppTextVariant.bodyMedium,
                        color: context.colors.textSecondary,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.lg),

                // Recipient Info
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          UserAvatar(
                            firstName: _link!.recipientName.split(' ').first,
                            lastName: _link!.recipientName.split(' ').length > 1
                                ? _link!.recipientName.split(' ').last
                                : null,
                            size: 40,
                          ),
                          SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  l10n.paymentLinks_payingTo,
                                  variant: AppTextVariant.bodySmall,
                                  color: context.colors.textSecondary,
                                ),
                                SizedBox(height: AppSpacing.xxs),
                                AppText(
                                  _link!.recipientName,
                                  variant: AppTextVariant.bodyLarge,
                                  fontWeight: FontWeight.w600,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (_link!.description != null) ...[
                        SizedBox(height: AppSpacing.md),
                        Divider(
                          color: context.colors.textSecondary.withValues(
                            alpha: 0.1,
                          ),
                        ),
                        SizedBox(height: AppSpacing.md),
                        AppText(
                          l10n.paymentLinks_paymentFor,
                          variant: AppTextVariant.bodySmall,
                          color: context.colors.textSecondary,
                        ),
                        SizedBox(height: AppSpacing.xs),
                        AppText(
                          _link!.description!,
                          variant: AppTextVariant.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.lg),

                // Link Info
                AppCard(
                  child: Column(
                    children: [
                      _buildInfoRow(
                        l10n.paymentLinks_linkCode,
                        _link!.shortCode,
                      ),
                      SizedBox(height: AppSpacing.sm),
                      _buildInfoRow(
                        l10n.paymentLinks_expires,
                        Formatters.formatDateTime(_link!.expiresAt),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.lg),

                // Current Balance
                Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: context.colors.container.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: context.colors.textSecondary.withValues(
                        alpha: 0.1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText(
                        l10n.wallet_balance,
                        variant: AppTextVariant.bodyMedium,
                        color: context.colors.textSecondary,
                      ),
                      Consumer(
                        builder: (context, ref, child) {
                          final usdcBalance = ref.watch(usdcBalanceProvider);
                          return AppText(
                            formatUsdc(usdcBalance),
                            variant: AppTextVariant.bodyLarge,
                            fontWeight: FontWeight.w600,
                            color:
                                payableUsdcAmount != null &&
                                    usdcBalance >= payableUsdcAmount
                                ? context.colors.success
                                : context.colors.error,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Pay Button
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: AppButton(
              label: l10n.paymentLinks_payAmount(
                formatCurrency(_link!.amount, _link!.currency),
              ),
              onPressed: _isProcessing ? null : _handlePayment,
              isLoading: _isProcessing,
              isFullWidth: true,
              icon: Icons.send,
            ),
          ),
        ],
      ),
    );
  }

  double? get _payableUsdcAmount {
    final link = _link;
    if (link == null) return null;

    switch (link.currency.toUpperCase()) {
      case 'USDC':
      case 'USD':
        return link.amount;
      case 'XOF':
      case 'XAF':
        final rate = _xofRate;
        return rate == null || rate <= 0 ? null : link.amount / rate;
      default:
        return null;
    }
  }

  bool get _isUsdcSettledLink {
    final currency = _link?.currency.toUpperCase();
    return currency == 'USDC' || currency == 'USD';
  }

  String get _paymentEstimateLabel {
    final link = _link;
    if (link == null) return '';
    final payableUsdcAmount = _payableUsdcAmount;

    switch (link.currency.toUpperCase()) {
      case 'USDC':
      case 'USD':
        return '≈ ${formatXof(link.amount * (_xofRate ?? 615))}';
      case 'XOF':
      case 'XAF':
        return payableUsdcAmount == null
            ? 'USDC estimate unavailable'
            : '≈ ${formatUsdc(payableUsdcAmount)}';
      default:
        return link.currency;
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          label,
          variant: AppTextVariant.bodyMedium,
          color: context.colors.textSecondary,
        ),
        AppText(
          value,
          variant: AppTextVariant.bodyMedium,
          fontWeight: FontWeight.w500,
        ),
      ],
    );
  }
}
