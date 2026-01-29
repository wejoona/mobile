import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../providers/payment_links_provider.dart';
import '../widgets/share_link_sheet.dart';

class LinkCreatedView extends ConsumerWidget {
  const LinkCreatedView({
    super.key,
    required this.linkId,
  });

  final String linkId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(paymentLinksProvider);
    final link = state.currentLink ?? state.links.firstWhere((l) => l.id == linkId);

    return Scaffold(
      backgroundColor: AppColors.obsidian,
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
                  color: AppColors.successBase.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: AppColors.successBase,
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
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),

            // QR Code
            Center(
              child: Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: QrImageView(
                  data: link.url,
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: AppColors.textPrimary,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.xl),

            // Amount Card
            Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.slate,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                children: [
                  AppText(
                    l10n.paymentLinks_requestedAmount,
                    variant: AppTextVariant.bodySmall,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: AppSpacing.xs),
                  AppText(
                    'CFA ${link.amount.toStringAsFixed(0)}',
                    variant: AppTextVariant.headlineLarge,
                    color: AppColors.gold500,
                  ),
                  if (link.description != null) ...[
                    SizedBox(height: AppSpacing.sm),
                    AppText(
                      link.description!,
                      variant: AppTextVariant.bodyMedium,
                      color: AppColors.textSecondary,
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
                color: AppColors.slate,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.link,
                        color: AppColors.gold500,
                        size: 20,
                      ),
                      SizedBox(width: AppSpacing.xs),
                      AppText(
                        link.shortCode,
                        variant: AppTextVariant.headlineSmall,
                        color: AppColors.gold500,
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.xs),
                  AppText(
                    link.url,
                    variant: AppTextVariant.bodySmall,
                    color: AppColors.textSecondary,
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
