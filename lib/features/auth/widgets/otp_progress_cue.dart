import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/components/states/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

class OtpProgressCue extends StatelessWidget {
  const OtpProgressCue({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      liveRegion: true,
      label: label,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: colors.gold.withValues(alpha: colors.isDark ? 0.16 : 0.12),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: colors.gold.withValues(alpha: colors.isDark ? 0.34 : 0.24),
          ),
          boxShadow: colors.isDark ? AppShadows.goldGlow : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: colors.gold.withValues(
                  alpha: colors.isDark ? 0.18 : 0.14,
                ),
                shape: BoxShape.circle,
              ),
              child: LoadingIndicator.small(
                color: colors.gold,
                semanticLabel: label,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: AppText(label, color: colors.textPrimary)),
          ],
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('label', label));
  }
}
