import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/payment_links/models/index.dart';
import 'package:usdc_wallet/features/payment_links/providers/payment_links_provider.dart';
import 'package:usdc_wallet/features/payment_links/widgets/share_link_sheet.dart';
import 'package:usdc_wallet/features/qr_payment/widgets/branded_qr_image.dart';
import 'package:usdc_wallet/utils/currency_utils.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

class LinkDetailView extends ConsumerStatefulWidget {
  const LinkDetailView({super.key, required this.linkId});

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
    final linkAsync = ref.watch(paymentLinkByIdProvider(widget.linkId));

    PaymentLink? link;
    for (final candidate in state.links) {
      if (candidate.id == widget.linkId) {
        link = candidate;
        break;
      }
    }
    link ??= linkAsync.value;

    final resolvedLink = link;
    if (resolvedLink == null) {
      return Scaffold(
        backgroundColor: context.colors.canvas,
        appBar: AppBar(
          title: AppText(
            l10n.paymentLinks_linkDetails,
            variant: AppTextVariant.headlineSmall,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: linkAsync.hasError
              ? AppText(
                  linkAsync.error.toString(),
                  variant: AppTextVariant.bodyMedium,
                  color: context.colors.error,
                  textAlign: TextAlign.center,
                )
              : const CircularProgressIndicator(),
        ),
      );
    }

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
          if (resolvedLink.isActive)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _handleRefresh(resolvedLink.id),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _handleRefresh(resolvedLink.id),
        color: context.colors.gold,
        backgroundColor: context.colors.container,
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.md),
          children: [
            // Status Badge
            Center(child: _buildStatusBadge(resolvedLink.status, l10n)),
            SizedBox(height: AppSpacing.lg),

            // QR Code (only for active links)
            if (resolvedLink.isActive) ...[
              Center(
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: BrandedQrImage(data: resolvedLink.url, size: 200.0),
                ),
              ),
              SizedBox(height: AppSpacing.xl),
            ],

            // Amount Card
            _buildInfoCard(
              l10n.paymentLinks_amount,
              formatCurrency(resolvedLink.amount, resolvedLink.currency),
              Icons.payments,
              context.colors.gold,
            ),
            SizedBox(height: AppSpacing.md),

            // Description
            if (resolvedLink.description != null)
              _buildInfoCard(
                l10n.paymentLinks_description,
                resolvedLink.description!,
                Icons.description,
                context.colors.info,
              ),
            if (resolvedLink.description != null)
              SizedBox(height: AppSpacing.md),

            // Link Code
            _buildInfoCard(
              l10n.paymentLinks_linkCode,
              resolvedLink.shortCode,
              Icons.link,
              context.colors.gold,
            ),
            SizedBox(height: AppSpacing.md),

            // Link URL
            _buildInfoCard(
              l10n.paymentLinks_linkUrl,
              resolvedLink.url,
              Icons.language,
              context.colors.info,
            ),
            SizedBox(height: AppSpacing.md),

            // View Count
            _buildInfoCard(
              l10n.paymentLinks_viewCount,
              resolvedLink.viewCount.toString(),
              Icons.visibility,
              context.colors.textSecondary,
            ),
            SizedBox(height: AppSpacing.md),

            // Created Date
            _buildInfoCard(
              l10n.paymentLinks_created,
              _formatDateTime(resolvedLink.createdAt),
              Icons.calendar_today,
              context.colors.textSecondary,
            ),
            SizedBox(height: AppSpacing.md),

            // Expires Date
            _buildInfoCard(
              l10n.paymentLinks_expires,
              _formatDateTime(resolvedLink.expiresAt),
              Icons.schedule,
              _isExpiringSoon(resolvedLink)
                  ? context.colors.warning
                  : context.colors.textSecondary,
            ),
            SizedBox(height: AppSpacing.md),

            // Paid Information (if paid)
            if (resolvedLink.isPaid) ...[
              _buildInfoCard(
                l10n.paymentLinks_paidBy,
                resolvedLink.paidByName ??
                    resolvedLink.paidByPhone ??
                    'Unknown',
                Icons.person,
                context.colors.success,
              ),
              SizedBox(height: AppSpacing.md),
              _buildInfoCard(
                l10n.paymentLinks_paidAt,
                _formatDateTime(resolvedLink.paidAt!),
                Icons.check_circle,
                context.colors.success,
              ),
              SizedBox(height: AppSpacing.md),
            ],

            SizedBox(height: AppSpacing.xl),

            // Actions
            if (resolvedLink.isActive) ...[
              AppButton(
                label: l10n.paymentLinks_shareLink,
                icon: Icons.share,
                onPressed: () => ShareLinkSheet.show(context, resolvedLink),
                isFullWidth: true,
              ),
              SizedBox(height: AppSpacing.sm),
              AppButton(
                label: l10n.paymentLinks_cancelLink,
                variant: AppButtonVariant.danger,
                icon: Icons.cancel,
                onPressed: () => _handleCancel(resolvedLink.id),
                isFullWidth: true,
              ),
            ],

            if (resolvedLink.isPaid) ...[
              AppButton(
                label: l10n.paymentLinks_viewTransaction,
                variant: AppButtonVariant.secondary,
                icon: Icons.receipt_long,
                onPressed: () {
                  if (resolvedLink.transactionId != null) {
                    context.fsmPush(
                      '/transactions/${resolvedLink.transactionId}',
                    );
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

  Widget _buildInfoCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
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
                AppText(value, variant: AppTextVariant.bodyLarge),
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
    try {
      await ref.read(paymentLinkActionsProvider).refreshLink(id);
      ref.invalidate(paymentLinkByIdProvider(id));
      ref.invalidate(paymentLinksProvider);
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  void _invalidateLinkState(String id) {
    ref.invalidate(paymentLinkByIdProvider(id));
    ref.invalidate(paymentLinksProvider);
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
      bool success = true;
      try {
        await ref.read(paymentLinkActionsProvider).cancelLink(id);
      } catch (_) {
        success = false;
      }
      if (mounted) {
        if (success) {
          _invalidateLinkState(id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: AppText(l10n.paymentLinks_linkCancelled),
              backgroundColor: context.colors.success,
            ),
          );
          context.fsmPop();
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
