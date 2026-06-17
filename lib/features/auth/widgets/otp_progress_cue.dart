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
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: colors.isDark
              ? colors.surface
              : colors.container.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: colors.gold.withValues(alpha: colors.isDark ? 0.34 : 0.24),
          ),
          boxShadow: colors.isDark
              ? AppShadows.goldGlow
              : AppShadows.lightGoldGlow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: colors.gold.withValues(
                  alpha: colors.isDark ? 0.20 : 0.16,
                ),
                shape: BoxShape.circle,
                boxShadow: colors.isDark
                    ? AppShadows.goldGlow
                    : AppShadows.lightGoldGlow,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  LoadingIndicator.large(
                    color: colors.gold,
                    strokeWidth: 3,
                    semanticLabel: label,
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: colors.canvas.withValues(
                        alpha: colors.isDark ? 0.92 : 0.96,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: colors.gold,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppText(
              label,
              variant: AppTextVariant.titleSmall,
              color: colors.textPrimary,
              fontWeight: FontWeight.w800,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            AppText(
              _isFrench(label)
                  ? 'Nous vérifions votre session et préparons votre espace.'
                  : 'We are verifying your session and preparing your wallet.',
              variant: AppTextVariant.bodySmall,
              color: colors.textSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Container(
                  width: index == 0 ? 28 : 8,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: index == 0
                        ? colors.gold
                        : colors.gold.withValues(alpha: 0.28),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isFrench(String value) =>
      value.contains('accepté') || value.contains('Sécurisation');

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('label', label));
  }
}

class OtpVerificationOverlay extends StatelessWidget {
  const OtpVerificationOverlay({
    required this.visible,
    required this.label,
    super.key,
  });

  final bool visible;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        child: ColoredBox(
          color: colors.scrim.withValues(alpha: colors.isDark ? 0.78 : 0.62),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: OtpProgressCue(label: label),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<bool>('visible', visible))
      ..add(StringProperty('label', label));
  }
}
