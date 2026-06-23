import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/payment_links/providers/payment_links_provider.dart';
import 'package:usdc_wallet/features/payment_links/widgets/share_link_sheet.dart';
import 'package:usdc_wallet/features/qr_payment/widgets/branded_qr_image.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

class LinkCreatedView extends ConsumerWidget {
  const LinkCreatedView({required this.linkId, super.key});

  final String linkId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final linkAsync = ref.watch(paymentLinkByIdProvider(linkId));

    return linkAsync.when(
      loading: () => Scaffold(
        backgroundColor: context.colors.canvas,
        appBar: AppBar(
          title: AppText(
            l10n.paymentLinks_linkCreated,
            variant: AppTextVariant.headlineSmall,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.fsmGo('/payment-links'),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        backgroundColor: context.colors.canvas,
        appBar: AppBar(
          title: AppText(
            l10n.paymentLinks_linkCreated,
            variant: AppTextVariant.headlineSmall,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.fsmGo('/payment-links'),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: AppText(
              l10n.common_errorFormat(error.toString()),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      data: (link) => Scaffold(
        backgroundColor: context.colors.canvas,
        appBar: AppBar(
          title: AppText(
            l10n.paymentLinks_linkCreated,
            variant: AppTextVariant.headlineSmall,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.fsmGo('/payment-links'),
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              // Success Icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: context.colors.success.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: context.colors.success,
                    size: 48,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Title
              AppText(
                l10n.paymentLinks_linkReadyTitle,
                variant: AppTextVariant.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppText(
                l10n.paymentLinks_linkReadyDescription,
                variant: AppTextVariant.bodyLarge,
                color: context.colors.textSecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),

              // QR Code
              Center(
                child: AppCard(
                  variant: AppCardVariant.flat,
                  backgroundColor: Colors.white,
                  borderColor: context.colors.borderSubtle,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: BrandedQrImage(data: link.url, size: 200),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Amount Card
              MoneySummaryCard(
                title: l10n.paymentLinks_requestedAmount,
                icon: Icons.payments_outlined,
                description: link.description,
                lines: [
                  MoneySummaryLine(
                    label: l10n.paymentLinks_requestedAmount,
                    amount: link.amount,
                    currencyCode: link.currency,
                    isTotal: true,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Link Code
              InfoCallout(
                icon: Icons.link,
                title: link.shortCode,
                body: link.url,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Share Button
              AppButton(
                label: l10n.paymentLinks_shareLink,
                icon: Icons.share,
                onPressed: () => ShareLinkSheet.show(context, link),
                isFullWidth: true,
              ),
              const SizedBox(height: AppSpacing.sm),

              // View Details Button
              AppButton(
                label: l10n.paymentLinks_viewDetails,
                variant: AppButtonVariant.secondary,
                onPressed: () => context.fsmGo('/payment-links/${link.id}'),
                isFullWidth: true,
              ),
              const SizedBox(height: AppSpacing.sm),

              // Done Button
              AppButton(
                label: l10n.common_done,
                variant: AppButtonVariant.ghost,
                onPressed: () => context.fsmGo('/payment-links'),
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('linkId', linkId));
  }
}
