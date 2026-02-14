import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

/// Tooltip overlay for guiding users through features
class FeatureTooltip extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onDismiss;
  final VoidCallback? onNext;
  final Alignment alignment;
  final Offset offset;

  const FeatureTooltip({
    super.key,
    required this.title,
    required this.description,
    required this.onDismiss,
    this.onNext,
    this.alignment = Alignment.bottomCenter,
    this.offset = Offset.zero,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Positioned.fill(
      child: GestureDetector(
        onTap: onDismiss,
        child: Container(
          color: Colors.black.withValues(alpha: 0.7),
          child: Align(
            alignment: alignment,
            child: Transform.translate(
              offset: offset,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.8 + (0.2 * value),
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 320),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: colors.elevated,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: colors.gold.withValues(alpha: 0.3),
                        width: 2,
                      ),
                      boxShadow: AppShadows.goldGlow,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: context.colors.goldGradient,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.lightbulb_rounded,
                                color: colors.textInverse,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: AppText(
                                title,
                                variant: AppTextVariant.titleMedium,
                                color: colors.textPrimary,
                              ),
                            ),
                            GestureDetector(
                              onTap: onDismiss,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  color: colors.textSecondary,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppText(
                          description,
                          variant: AppTextVariant.bodyMedium,
                          color: colors.textSecondary,
                        ),
                        if (onNext != null) ...[
                          const SizedBox(height: AppSpacing.lg),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: onDismiss,
                                child: AppText(
                                  'Skip',
                                  variant: AppTextVariant.labelMedium,
                                  color: colors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              AppButton(
                                label: 'Next',
                                onPressed: onNext,
                                size: AppButtonSize.small,
                                variant: AppButtonVariant.primary,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tooltip manager for showing sequential tooltips
class TooltipSequence {
  final List<FeatureTooltipData> tooltips;
  int _currentIndex = 0;

  TooltipSequence({required this.tooltips});

  bool get hasNext => _currentIndex < tooltips.length - 1;
  bool get isComplete => _currentIndex >= tooltips.length;
  FeatureTooltipData get current => tooltips[_currentIndex];

  void next() {
    if (hasNext) {
      _currentIndex++;
    }
  }

  void skip() {
    _currentIndex = tooltips.length;
  }

  void reset() {
    _currentIndex = 0;
  }
}

class FeatureTooltipData {
  final String title;
  final String description;
  final Alignment alignment;
  final Offset offset;

  const FeatureTooltipData({
    required this.title,
    required this.description,
    this.alignment = Alignment.bottomCenter,
    this.offset = Offset.zero,
  });
}
