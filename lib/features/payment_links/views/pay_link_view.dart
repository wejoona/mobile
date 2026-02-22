import 'package:usdc_wallet/utils/currency_utils.dart';
import 'package:usdc_wallet/services/service_providers.dart';
import 'package:usdc_wallet/core/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/state/wallet_state_machine.dart';
import 'package:usdc_wallet/features/wallet/providers/wallet_provider.dart';
import 'package:usdc_wallet/features/payment_links/models/index.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

/// Screen for paying via a received payment link
/// Shows link details and allows user to complete payment
class PayLinkView extends ConsumerStatefulWidget {
  const PayLinkView({
    super.key,
    required this.linkCode,
  });

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
        exchangeRateProvider(const ExchangeRateParams(
          sourceCurrency: 'USD',
          targetCurrency: 'XOF',
          amount: 1.0,
        )).future,
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

    // Check balance
    if (usdcBalance < _link!.amount) {
      _showErrorDialog(
        l10n.common_error,
        l10n.paymentLinks_insufficientBalance,
      );
      return;
    }

    // Confirm payment
    final confirmed = await _showConfirmDialog();
    if (confirmed != true) return;

    setState(() => _isProcessing = true);

    try {
      final service = ref.read(paymentLinksServiceProvider);
      final result = await service.payLink(widget.linkCode);

      if (mounted) {
        // Show success and navigate to receipt
        context.go('/send/result', extra: {
          'success': true,
          'amount': _link!.amount,
          'recipient': _link!.recipientName,
          'transactionId': result.transactionId,
          'note': _link!.description,
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        _showErrorDialog(
          l10n.common_error,
          e.toString(),
        );
      }
    }
  }

  Future<bool?> _showConfirmDialog() {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.container,
        title: AppText(
          l10n.action_confirm,
          variant: AppTextVariant.headlineSmall,
        ),
        content: AppText(
          l10n.paymentLinks_payAmount(
            '\$${Formatters.formatCurrency(_link!.amount)}',
          ),
          variant: AppTextVariant.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: AppText(
              l10n.action_cancel,
              color: context.colors.textSecondary,
            ),
          ),
          AppButton(
            label: l10n.action_confirm,
            onPressed: () => Navigator.pop(context, true),
            size: AppButtonSize.small,
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.container,
        title: AppText(
          title,
          variant: AppTextVariant.headlineSmall,
        ),
        content: AppText(
          message,
          variant: AppTextVariant.bodyLarge,
        ),
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
    return Center(
      child: CircularProgressIndicator(
        color: context.colors.gold,
      ),
    );
  }

  Widget _buildError(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: context.colors.error,
            ),
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
              onPressed: () => context.pop(),
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
            Icon(
              Icons.schedule,
              size: 80,
              color: context.colors.textSecondary,
            ),
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
              onPressed: () => context.pop(),
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
                      _link!.paidByName ?? _link!.paidByPhone ?? l10n.common_unknown,
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
              onPressed: () => context.pop(),
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
            Icon(
              Icons.block,
              size: 80,
              color: context.colors.error,
            ),
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
              onPressed: () => context.pop(),
              variant: AppButtonVariant.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentForm(AppLocalizations l10n) {
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
                        '\$${Formatters.formatCurrency(_link!.amount)}',
                        variant: AppTextVariant.displaySmall,
                        color: context.colors.gold,
                        fontWeight: FontWeight.bold,
                      ),
                      SizedBox(height: AppSpacing.xs),
                      AppText(
                        _xofRate != null
                            ? formatXof(_link!.amount * _xofRate!)
                            : '${_link!.currency}',
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
                          CircleAvatar(
                            backgroundColor: context.colors.gold.withValues(alpha:0.2),
                            child: Icon(
                              Icons.person_outline,
                              color: context.colors.gold,
                            ),
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
                        Divider(color: context.colors.textSecondary.withValues(alpha:0.1)),
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
                    color: context.colors.container.withValues(alpha:0.5),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: context.colors.textSecondary.withValues(alpha:0.1),
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
                            '\$${Formatters.formatCurrency(usdcBalance)}',
                            variant: AppTextVariant.bodyLarge,
                            fontWeight: FontWeight.w600,
                            color: usdcBalance >= _link!.amount
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
                '\$${Formatters.formatCurrency(_link!.amount)}',
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
