import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/providers/missing_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/design/tokens/colors.dart';
import 'package:usdc_wallet/design/tokens/spacing.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/features/insights/providers/insights_provider.dart';
import 'package:usdc_wallet/features/insights/widgets/top_recipients_chart.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

class TopRecipientsSection extends ConsumerWidget {
  const TopRecipientsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final recipientsAsync = ref.watch(topRecipientsProvider);

    return recipientsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
      data: (recipients) {
        if (recipients.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(AppSpacing.cardPaddingLarge),
          decoration: BoxDecoration(
            color: context.colors.container,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: context.colors.border,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    l10n.insights_top_recipients,
                    variant: AppTextVariant.titleMedium,
                    color: context.colors.textPrimary,
                  ),
                  TextButton(
                    onPressed: () => context.push('/insights/recipients'),
                    child: AppText(
                      'View All',
                      variant: AppTextVariant.bodySmall,
                      color: context.colors.gold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              TopRecipientsChart(recipients: recipients.take(5).toList()),
            ],
          ),
        );
      },
    );
  }
}
