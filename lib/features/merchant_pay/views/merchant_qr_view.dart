import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../features/qr_payment/widgets/qr_display.dart';
import '../services/merchant_service.dart';

/// Merchant QR View
/// Displays the merchant's static QR code for customers to scan
class MerchantQrView extends ConsumerStatefulWidget {
  final MerchantResponse merchant;

  const MerchantQrView({
    super.key,
    required this.merchant,
  });

  static const String routeName = '/merchant-qr';

  @override
  ConsumerState<MerchantQrView> createState() => _MerchantQrViewState();
}

class _MerchantQrViewState extends ConsumerState<MerchantQrView> {
  final _screenshotController = ScreenshotController();
  bool _isSharing = false;

  Future<void> _shareQr() async {
    setState(() => _isSharing = true);

    try {
      final image = await _screenshotController.capture();
      if (image == null) return;

      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/merchant_qr.png';
      final file = File(imagePath);
      await file.writeAsBytes(image);

      await Share.shareXFiles(
        [XFile(imagePath)],
        text: 'Pay ${widget.merchant.displayName} with JoonaPay',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share QR code')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  void _copyQrData() {
    final l10n = AppLocalizations.of(context)!;
    Clipboard.setData(ClipboardData(text: widget.merchant.qrCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('QR data copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: AppText('My QR Code', variant: AppTextVariant.titleMedium),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: _copyQrData,
            icon: Icon(Icons.copy, color: AppColors.gold500),
            tooltip: l10n.action_copy,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              // QR Code Card with Screenshot wrapper
              Screenshot(
                controller: _screenshotController,
                child: AppCard(
                  variant: AppCardVariant.elevated,
                  padding: EdgeInsets.all(AppSpacing.xxl),
                  child: Column(
                    children: [
                      // Logo/Icon
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.gold500.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getCategoryIcon(widget.merchant.category),
                          color: AppColors.gold500,
                          size: 30,
                        ),
                      ),
                      SizedBox(height: AppSpacing.md),

                      // Merchant name
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: AppText(
                              widget.merchant.displayName,
                              variant: AppTextVariant.titleLarge,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          if (widget.merchant.isVerified) ...[
                            SizedBox(width: AppSpacing.xs),
                            Icon(
                              Icons.verified,
                              color: AppColors.gold500,
                              size: 20,
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: AppSpacing.xs),
                      AppText(
                        _formatCategory(widget.merchant.category),
                        variant: AppTextVariant.bodyMedium,
                        color: AppColors.silver,
                      ),
                      SizedBox(height: AppSpacing.lg),

                      // QR Display using existing widget
                      QrDisplay(
                        data: widget.merchant.qrCode,
                        size: 220,
                        showBorder: true,
                      ),
                      SizedBox(height: AppSpacing.lg),

                      // Instructions
                      Container(
                        padding: EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.charcoal.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.silver,
                              size: 20,
                            ),
                            SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: AppText(
                                'Customers can scan this QR code to pay you',
                                variant: AppTextVariant.bodySmall,
                                color: AppColors.silver,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.xl),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: l10n.action_share,
                      onPressed: _isSharing ? null : _shareQr,
                      variant: AppButtonVariant.secondary,
                      icon: _isSharing ? null : Icons.share,
                      isLoading: _isSharing,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton(
                      label: 'Request Amount',
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          '/create-payment-request',
                          arguments: widget.merchant,
                        );
                      },
                      variant: AppButtonVariant.primary,
                      icon: Icons.add,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.lg),

              // Daily limit info
              AppCard(
                variant: AppCardVariant.outline,
                padding: EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Icon(Icons.account_balance_wallet, color: AppColors.gold500),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            'Daily Limit Remaining',
                            variant: AppTextVariant.labelMedium,
                            color: AppColors.gold500,
                          ),
                          AppText(
                            '\$${widget.merchant.remainingDailyLimit.toStringAsFixed(2)} of \$${widget.merchant.dailyLimit.toStringAsFixed(2)}',
                            variant: AppTextVariant.bodySmall,
                            color: AppColors.silver,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'restaurant':
        return Icons.restaurant;
      case 'retail':
        return Icons.store;
      case 'grocery':
        return Icons.shopping_cart;
      case 'transport':
        return Icons.directions_car;
      case 'services':
        return Icons.handyman;
      case 'healthcare':
        return Icons.local_hospital;
      case 'education':
        return Icons.school;
      case 'entertainment':
        return Icons.movie;
      default:
        return Icons.business;
    }
  }

  String _formatCategory(String category) {
    return category[0].toUpperCase() + category.substring(1);
  }
}
