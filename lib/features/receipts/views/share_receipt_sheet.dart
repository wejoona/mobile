import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/domain/entities/transaction.dart';
import 'package:usdc_wallet/features/receipts/models/receipt_format.dart';
import 'package:usdc_wallet/features/receipts/services/receipt_service.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

/// Bottom sheet for sharing transaction receipt
/// TODO: Replace hardcoded strings with AppLocalizations after running flutter gen-l10n
class ShareReceiptSheet extends ConsumerStatefulWidget {
  const ShareReceiptSheet({
    super.key,
    required this.transaction,
  });

  final Transaction transaction;

  @override
  ConsumerState<ShareReceiptSheet> createState() => _ShareReceiptSheetState();

  static Future<void> show(BuildContext context, Transaction transaction) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ShareReceiptSheet(transaction: transaction),
    );
  }
}

class _ShareReceiptSheetState extends ConsumerState<ShareReceiptSheet> {
  final _receiptService = ReceiptService();
  bool _isLoading = false;
  String? _loadingMessage;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: AppSpacing.md),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
              child: const AppText(
                'Share Receipt',
                variant: AppTextVariant.titleLarge,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Loading indicator
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(context.colors.gold),
                    ),
                    if (_loadingMessage != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      AppText(
                        _loadingMessage!,
                        variant: AppTextVariant.bodyMedium,
                        color: colors.textSecondary,
                      ),
                    ],
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: Column(
                  children: [
                    // WhatsApp - Primary option
                    _ShareOption(
                      icon: Icons.message,
                      iconColor: const Color(0xFF25D366), // WhatsApp green
                      label: 'Share via WhatsApp',
                      subtitle: 'Send receipt to WhatsApp contact',
                      isPrimary: true,
                      onTap: _shareViaWhatsApp,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Share as Image
                    _ShareOption(
                      icon: Icons.image,
                      iconColor: context.colors.info,
                      label: 'Share as Image',
                      subtitle: 'Share via any app',
                      onTap: () => _shareReceipt(ReceiptFormat.image),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Share as PDF
                    _ShareOption(
                      icon: Icons.picture_as_pdf,
                      iconColor: context.colors.error,
                      label: 'Share as PDF',
                      subtitle: 'Professional PDF document',
                      onTap: () => _shareReceipt(ReceiptFormat.pdf),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Save to Gallery
                    _ShareOption(
                      icon: Icons.download,
                      iconColor: context.colors.success,
                      label: 'Save to Gallery',
                      subtitle: 'Save receipt image to photos',
                      onTap: _saveToGallery,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Email
                    _ShareOption(
                      icon: Icons.email,
                      iconColor: colors.gold,
                      label: 'Email Receipt',
                      subtitle: 'Send via email',
                      onTap: _emailReceipt,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Copy Reference
                    _ShareOption(
                      icon: Icons.copy,
                      iconColor: colors.textSecondary,
                      label: 'Copy Reference Number',
                      subtitle: widget.transaction.reference,
                      onTap: _copyReference,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareViaWhatsApp() async {
    setState(() {
      _isLoading = true;
      _loadingMessage = 'Opening WhatsApp...';
    });

    try {
      final success = await _receiptService.shareViaWhatsApp(
        transaction: widget.transaction,
      );

      if (!mounted) return;

      if (success) {
        Navigator.pop(context);
      } else {
        _showError('WhatsApp is not installed');
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to share receipt');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingMessage = null;
        });
      }
    }
  }

  Future<void> _shareReceipt(ReceiptFormat format) async {
    setState(() {
      _isLoading = true;
      _loadingMessage = format == ReceiptFormat.image
          ? 'Generating image...'
          : 'Generating PDF...';
    });

    try {
      await _receiptService.shareReceipt(
        transaction: widget.transaction,
        format: format,
      );

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to share receipt');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingMessage = null;
        });
      }
    }
  }

  Future<void> _saveToGallery() async {
    setState(() {
      _isLoading = true;
      _loadingMessage = 'Generating image...';
    });

    try {
      final imageBytes = await _receiptService.generateReceiptImage(widget.transaction);
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'Korido_Receipt_$timestamp';

      final success = await _receiptService.saveToGallery(imageBytes, fileName);

      if (!mounted) return;

      if (success) {
        Navigator.pop(context);
        _showSuccess('Receipt saved to gallery');
      } else {
        _showError('Failed to save receipt');
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to save receipt');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingMessage = null;
        });
      }
    }
  }

  Future<void> _emailReceipt() async {
    // Show text field to enter email
    final email = await _showEmailDialog();
    if (email == null || email.isEmpty) return;

    setState(() {
      _isLoading = true;
      _loadingMessage = 'Opening email...';
    });

    try {
      final success = await _receiptService.shareViaEmail(
        transaction: widget.transaction,
        recipientEmail: email,
      );

      if (!mounted) return;

      if (success) {
        Navigator.pop(context);
      } else {
        _showError('Failed to open email app');
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to share receipt');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingMessage = null;
        });
      }
    }
  }

  Future<void> _copyReference() async {
    await Clipboard.setData(ClipboardData(text: widget.transaction.reference));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.receipts_referenceNumberCopied),
        backgroundColor: context.colors.success,
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.pop(context);
  }

  Future<String?> _showEmailDialog() async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.surface,
        title: AppText(AppLocalizations.of(context)!.receipts_enterEmailAddress, variant: AppTextVariant.titleMedium),
        content: AppInput(
          controller: controller,
          label: 'Email Address',
          keyboardType: TextInputType.emailAddress,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: AppText(AppLocalizations.of(context)!.action_cancel),
          ),
          AppButton(
            label: 'Continue',
            onPressed: () => Navigator.pop(context, controller.text),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: context.colors.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: context.colors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  const _ShareOption({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.isPrimary = false,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      variant: isPrimary ? AppCardVariant.elevated : AppCardVariant.subtle,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    label,
                    variant: AppTextVariant.bodyLarge,
                    color: colors.textPrimary,
                  ),
                  const SizedBox(height: 2),
                  AppText(
                    subtitle,
                    variant: AppTextVariant.bodySmall,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: colors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
