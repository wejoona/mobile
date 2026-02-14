import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/payment_links/models/index.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

class ShareLinkSheet extends StatelessWidget {
  const ShareLinkSheet({
    super.key,
    required this.link,
  });

  final PaymentLink link;

  static Future<void> show(BuildContext context, PaymentLink link) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.container,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) => ShareLinkSheet(link: link),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.colors.textSecondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: AppSpacing.md),

          // Title
          AppText(
            l10n.paymentLinks_shareLink,
            variant: AppTextVariant.headlineSmall,
          ),
          SizedBox(height: AppSpacing.lg),

          // Share options
          _ShareOption(
            icon: Icons.copy,
            label: l10n.paymentLinks_copyLink,
            onTap: () => _copyLink(context),
          ),
          SizedBox(height: AppSpacing.sm),
          _ShareOption(
            icon: Icons.chat,
            label: l10n.paymentLinks_shareWhatsApp,
            iconColor: const Color(0xFF25D366),
            onTap: () => _shareWhatsApp(context),
          ),
          SizedBox(height: AppSpacing.sm),
          _ShareOption(
            icon: Icons.message,
            label: l10n.paymentLinks_shareSMS,
            iconColor: context.colors.info,
            onTap: () => _shareSMS(context),
          ),
          SizedBox(height: AppSpacing.sm),
          _ShareOption(
            icon: Icons.share,
            label: l10n.paymentLinks_shareOther,
            onTap: () => _shareGeneric(context),
          ),

          SizedBox(height: AppSpacing.md),

          // Cancel button
          AppButton(
            label: l10n.common_cancel,
            variant: AppButtonVariant.ghost,
            onPressed: () => Navigator.pop(context),
            isFullWidth: true,
          ),
          SizedBox(height: AppSpacing.xs),
        ],
      ),
    );
  }

  Future<void> _copyLink(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: link.url));
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AppText(
            AppLocalizations.of(context)!.paymentLinks_linkCopied,
          ),
          backgroundColor: context.colors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _shareWhatsApp(BuildContext context) async {
    final message = _buildShareMessage();
    // WhatsApp deep link - will open WhatsApp if installed
    await Share.share(
      message,
      subject: AppLocalizations.of(context)!.paymentLinks_paymentRequest,
    );
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _shareSMS(BuildContext context) async {
    final message = _buildShareMessage();
    await Share.share(
      message,
      subject: AppLocalizations.of(context)!.paymentLinks_paymentRequest,
    );
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _shareGeneric(BuildContext context) async {
    final message = _buildShareMessage();
    await Share.share(
      message,
      subject: AppLocalizations.of(context)!.paymentLinks_paymentRequest,
    );
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  String _buildShareMessage() {
    final description = link.description != null && link.description!.isNotEmpty
        ? '\n\n${link.description}'
        : '';

    return '''
Payment Request from ${link.recipientName}

Amount: ${_formatAmount(link.amount, link.currency)}$description

Pay now: ${link.url}

Powered by JoonaPay
''';
  }

  String _formatAmount(double amount, String currency) {
    if (currency == 'XOF') {
      return 'CFA ${amount.toStringAsFixed(0)}';
    }
    return '\$${amount.toStringAsFixed(2)}';
  }
}

class _ShareOption extends StatelessWidget {
  const _ShareOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.colors.canvas,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: (iconColor ?? context.colors.gold).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                icon,
                color: iconColor ?? context.colors.gold,
                size: 24,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppText(
                label,
                variant: AppTextVariant.bodyLarge,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: context.colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
