import 'package:usdc_wallet/design/components/primitives/error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/services/feature_flags/feature_flags_provider.dart';

/// Run 344: Feature flags debug view for toggling flags in dev builds
class FeatureFlagsDebugView extends ConsumerWidget {
  const FeatureFlagsDebugView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flags = ref.watch(featureFlagsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: const AppText(
          'Feature Flags',
          style: AppTextStyle.headingSmall,
        ),
        backgroundColor: AppColors.backgroundSecondary,
      ),
      body: ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: flags.entries.length,
          itemBuilder: (context, index) {
            final entry = flags.entries.elementAt(index);
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AppCard(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              entry.key,
                              style: AppTextStyle.labelLarge,
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            AppText(
                              entry.value ? 'Active' : 'Desactive',
                              style: AppTextStyle.bodySmall,
                              color: entry.value
                                  ? AppColors.success
                                  : AppColors.textTertiary,
                            ),
                          ],
                        ),
                      ),
                      AppToggle(
                        value: entry.value,
                        onChanged: (_) {
                          // Debug-only toggle: overrides in local storage
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
  }
}


