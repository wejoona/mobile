import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/payment_links/providers/payment_links_provider.dart';
import 'package:usdc_wallet/features/payment_links/widgets/share_link_sheet.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

class LinkCreatedView extends ConsumerWidget {
  const LinkCreatedView({
    super.key,
    required this.linkId,
  });

  final String linkId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(paymentLinksStateProvider);
    final link = state.currentLink ?? state.links.firstWhere((l) => l.id == linkId);

    return Scaffold(
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
          onPressed: () => context.go('/payment-links'),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.md),
          children: [
            // Success Icon
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: context.colors.success.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: context.colors.success,
                  size: 48,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.lg),

            // Title
            AppText(
              l10n.paymentLinks_linkReadyTitle,
              variant: AppTextVariant.headlineMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
            AppText(
              l10n.paymentLinks_linkReadyDescription,
              variant: AppTextVariant.bodyLarge,
              color: context.colors.textSecondary,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),

            // QR Code
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

            // Amount Card
            Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.colors.container,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                children: [
                  AppText(
                    l10n.paymentLinks_requestedAmount,
                    variant: AppTextVariant.bodySmall,
                    color: context.colors.textSecondary,
                  ),
                  SizedBox(height: AppSpacing.xs),
                  AppText(
                    'CFA ${link.amount.toStringAsFixed(0)}',
                    variant: AppTextVariant.headlineLarge,
                    color: context.colors.gold,
                  ),
                  if (link.description != null) ...[
                    SizedBox(height: AppSpacing.sm),
                    AppText(
                      link.description!,
                      variant: AppTextVariant.bodyMedium,
                      color: context.colors.textSecondary,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: AppSpacing.lg),

            // Link Code
            Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.colors.container,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.link,
                        color: context.colors.gold,
                        size: 20,
                      ),
                      SizedBox(width: AppSpacing.xs),
                      AppText(
                        link.shortCode,
                        variant: AppTextVariant.headlineSmall,
                        color: context.colors.gold,
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.xs),
                  AppText(
                    link.url,
                    variant: AppTextVariant.bodySmall,
                    color: context.colors.textSecondary,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.xl),

            // Share Button
            AppButton(
              label: l10n.paymentLinks_shareLink,
              icon: Icons.share,
              onPressed: () => ShareLinkSheet.show(context, link),
              isFullWidth: true,
            ),
            SizedBox(height: AppSpacing.sm),

            // View Details Button
            AppButton(
              label: l10n.paymentLinks_viewDetails,
              variant: AppButtonVariant.secondary,
              onPressed: () => context.go('/payment-links/detail/${link.id}'),
              isFullWidth: true,
            ),
            SizedBox(height: AppSpacing.sm),

            // Done Button
            AppButton(
              label: l10n.common_done,
              variant: AppButtonVariant.ghost,
              onPressed: () => context.go('/payment-links'),
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}
