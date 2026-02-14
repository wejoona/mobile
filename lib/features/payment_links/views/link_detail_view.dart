import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/payment_links/models/index.dart';
import 'package:usdc_wallet/features/payment_links/providers/payment_links_provider.dart';
import 'package:usdc_wallet/features/payment_links/widgets/share_link_sheet.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

class LinkDetailView extends ConsumerStatefulWidget {
  const LinkDetailView({
    super.key,
    required this.linkId,
  });

  final String linkId;

  @override
  ConsumerState<LinkDetailView> createState() => _LinkDetailViewState();
}

class _LinkDetailViewState extends ConsumerState<LinkDetailView> {
  // ignore: unused_field
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paymentLinkActionsProvider).loadLink(widget.linkId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(paymentLinksStateProvider);
    final link = state.currentLink ??
        state.links.firstWhere(
          (l) => l.id == widget.linkId,
          orElse: () => throw Exception('Link not found'),
        );

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        title: AppText(
          l10n.paymentLinks_linkDetails,
          variant: AppTextVariant.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (link.isActive)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _handleRefresh(link.id),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _handleRefresh(link.id),
        color: context.colors.gold,
        backgroundColor: context.colors.container,
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.md),
          children: [
            // Status Badge
            Center(
              child: _buildStatusBadge(link.status, l10n),
            ),
            SizedBox(height: AppSpacing.lg),

            // QR Code (only for active links)
            if (link.isActive) ...[
              Center(
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: context.colors.textPrimary,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: QrImageView(
                    data: link.url,
                    version: QrVersions.auto,
                    size: 200.0,
                    backgroundColor: context.colors.textPrimary,
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.xl),
            ],

            // Amount Card
            _buildInfoCard(
              l10n.paymentLinks_amount,
              'CFA ${link.amount.toStringAsFixed(0)}',
              Icons.payments,
              context.colors.gold,
            ),
            SizedBox(height: AppSpacing.md),

            // Description
            if (link.description != null)
              _buildInfoCard(
                l10n.paymentLinks_description,
                link.description!,
                Icons.description,
                context.colors.info,
              ),
            if (link.description != null) SizedBox(height: AppSpacing.md),

            // Link Code
            _buildInfoCard(
              l10n.paymentLinks_linkCode,
              link.shortCode,
              Icons.link,
              context.colors.gold,
            ),
            SizedBox(height: AppSpacing.md),

            // Link URL
            _buildInfoCard(
              l10n.paymentLinks_linkUrl,
              link.url,
              Icons.language,
              context.colors.info,
            ),
            SizedBox(height: AppSpacing.md),

            // View Count
            _buildInfoCard(
              l10n.paymentLinks_viewCount,
              link.viewCount.toString(),
              Icons.visibility,
              context.colors.textSecondary,
            ),
            SizedBox(height: AppSpacing.md),

            // Created Date
            _buildInfoCard(
              l10n.paymentLinks_created,
              _formatDateTime(link.createdAt),
              Icons.calendar_today,
              context.colors.textSecondary,
            ),
            SizedBox(height: AppSpacing.md),

            // Expires Date
            _buildInfoCard(
              l10n.paymentLinks_expires,
              _formatDateTime(link.expiresAt),
              Icons.schedule,
              _isExpiringSoon(link) ? context.colors.warning : context.colors.textSecondary,
            ),
            SizedBox(height: AppSpacing.md),

            // Paid Information (if paid)
            if (link.isPaid) ...[
              _buildInfoCard(
                l10n.paymentLinks_paidBy,
                link.paidByName ?? link.paidByPhone ?? 'Unknown',
                Icons.person,
                context.colors.success,
              ),
              SizedBox(height: AppSpacing.md),
              _buildInfoCard(
                l10n.paymentLinks_paidAt,
                _formatDateTime(link.paidAt!),
                Icons.check_circle,
                context.colors.success,
              ),
              SizedBox(height: AppSpacing.md),
            ],

            SizedBox(height: AppSpacing.xl),

            // Actions
            if (link.isActive) ...[
              AppButton(
                label: l10n.paymentLinks_shareLink,
                icon: Icons.share,
                onPressed: () => ShareLinkSheet.show(context, link),
                isFullWidth: true,
              ),
              SizedBox(height: AppSpacing.sm),
              AppButton(
                label: l10n.paymentLinks_cancelLink,
                variant: AppButtonVariant.danger,
                icon: Icons.cancel,
                onPressed: () => _handleCancel(link.id),
                isFullWidth: true,
              ),
            ],

            if (link.isPaid) ...[
              AppButton(
                label: l10n.paymentLinks_viewTransaction,
                variant: AppButtonVariant.secondary,
                icon: Icons.receipt_long,
                onPressed: () {
                  if (link.transactionId != null) {
                    context.push('/transactions/${link.transactionId}');
                  }
                },
                isFullWidth: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(PaymentLinkStatus status, AppLocalizations l10n) {
    final locale = Localizations.localeOf(context);
    final isFrench = locale.languageCode == 'fr';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: _getStatusColor(status).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(status),
            color: _getStatusColor(status),
            size: 20,
          ),
          SizedBox(width: AppSpacing.xs),
          AppText(
            status.displayName(isFrench),
            variant: AppTextVariant.labelLarge,
            color: _getStatusColor(status),
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.container,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  label,
                  variant: AppTextVariant.bodySmall,
                  color: context.colors.textSecondary,
                ),
                SizedBox(height: AppSpacing.xs),
                AppText(
                  value,
                  variant: AppTextVariant.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(PaymentLinkStatus status) {
    switch (status) {
      case PaymentLinkStatus.pending:
        return context.colors.gold;
      case PaymentLinkStatus.viewed:
        return context.colors.info;
      case PaymentLinkStatus.paid:
        return context.colors.success;
      case PaymentLinkStatus.expired:
        return context.colors.textSecondary;
      case PaymentLinkStatus.cancelled:
        return context.colors.error;
    }
  }

  IconData _getStatusIcon(PaymentLinkStatus status) {
    switch (status) {
      case PaymentLinkStatus.pending:
        return Icons.hourglass_empty;
      case PaymentLinkStatus.viewed:
        return Icons.visibility;
      case PaymentLinkStatus.paid:
        return Icons.check_circle;
      case PaymentLinkStatus.expired:
        return Icons.access_time;
      case PaymentLinkStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _formatDateTime(DateTime date) {
    return DateFormat('MMM d, yyyy • h:mm a').format(date);
  }

  bool _isExpiringSoon(PaymentLink link) {
    final now = DateTime.now();
    final timeUntilExpiry = link.expiresAt.difference(now);
    return timeUntilExpiry.inHours < 6 && timeUntilExpiry.inHours > 0;
  }

  Future<void> _handleRefresh(String id) async {
    setState(() => _isRefreshing = true);
    await ref.read(paymentLinkActionsProvider).refreshLink(id);
    if (mounted) {
      setState(() => _isRefreshing = false);
    }
  }

  Future<void> _handleCancel(String id) async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.container,
        title: AppText(
          l10n.paymentLinks_cancelConfirmTitle,
          variant: AppTextVariant.headlineSmall,
        ),
        content: AppText(
          l10n.paymentLinks_cancelConfirmMessage,
          variant: AppTextVariant.bodyMedium,
          color: context.colors.textSecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: AppText(l10n.common_no),
          ),
          AppButton(
            label: l10n.common_yes,
            onPressed: () => Navigator.pop(context, true),
            size: AppButtonSize.small,
            variant: AppButtonVariant.danger,
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      bool success = true; try { await ref.read(paymentLinkActionsProvider).cancelLink(id); } catch (_) { success = false; }
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: AppText(l10n.paymentLinks_linkCancelled),
              backgroundColor: context.colors.success,
            ),
          );
          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: AppText(l10n.common_error),
              backgroundColor: context.colors.error,
            ),
          );
        }
      }
    }
  }
}
