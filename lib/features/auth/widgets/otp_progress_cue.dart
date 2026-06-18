import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

class OtpProgressCue extends StatelessWidget {
  const OtpProgressCue({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final copy = _OtpCueCopy.fromLabel(label);

    return Semantics(
      liveRegion: true,
      label: copy.semanticLabel,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.xxl,
        ),
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
            SizedBox.square(
              dimension: 96,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      color: colors.goldSubtle.withValues(
                        alpha: colors.isDark ? 0.28 : 0.50,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: colors.isDark
                          ? AppShadows.goldGlow
                          : AppShadows.lightGoldGlow,
                    ),
                  ),
                  SizedBox.square(
                    dimension: 82,
                    child: CircularProgressIndicator(
                      color: colors.gold,
                      strokeWidth: 3.2,
                      strokeCap: StrokeCap.round,
                      backgroundColor: colors.gold.withValues(alpha: 0.14),
                      semanticsLabel: copy.semanticLabel,
                    ),
                  ),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: colors.isDark ? colors.canvas : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colors.gold.withValues(alpha: 0.24),
                      ),
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: colors.success,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppText(
              copy.title,
              variant: AppTextVariant.titleSmall,
              color: colors.textPrimary,
              fontWeight: FontWeight.w800,
              textAlign: TextAlign.center,
            ),
            if (copy.subtitle.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              AppText(
                copy.subtitle,
                variant: AppTextVariant.bodySmall,
                color: colors.textSecondary,
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _OtpStepDot(
                  width: 26,
                  color: colors.success,
                  icon: Icons.check_rounded,
                ),
                _OtpStepConnector(color: colors.gold),
                _OtpStepDot(width: 34, color: colors.gold),
                _OtpStepConnector(color: colors.gold.withValues(alpha: 0.24)),
                _OtpStepDot(
                  width: 10,
                  color: colors.gold.withValues(alpha: 0.24),
                ),
              ],
            ),
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

class _OtpCueCopy {
  const _OtpCueCopy({
    required this.title,
    required this.subtitle,
    required this.semanticLabel,
  });

  factory _OtpCueCopy.fromLabel(String label) {
    final trimmed = label.trim();
    final separator = trimmed.indexOf('.');
    final hasSplit = separator > 0 && separator < trimmed.length - 1;
    return _OtpCueCopy(
      title: hasSplit ? trimmed.substring(0, separator).trim() : trimmed,
      subtitle: hasSplit ? trimmed.substring(separator + 1).trim() : '',
      semanticLabel: trimmed,
    );
  }

  final String title;
  final String subtitle;
  final String semanticLabel;
}

class _OtpStepDot extends StatelessWidget {
  const _OtpStepDot({required this.width, required this.color, this.icon});

  final double width;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: width,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: icon == null ? null : Icon(icon, size: 9, color: Colors.white),
    );
  }
}

class _OtpStepConnector extends StatelessWidget {
  const _OtpStepConnector({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 18,
    height: 2,
    margin: const EdgeInsets.symmetric(horizontal: 4),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(AppRadius.full),
    ),
  );
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
