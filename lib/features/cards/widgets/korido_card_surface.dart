import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/domain/entities/card.dart';

class KoridoCardSurface extends StatelessWidget {
  const KoridoCardSurface({
    super.key,
    required this.card,
    this.onTap,
    this.showDetails = false,
    this.margin,
  });

  final KoridoCard card;
  final VoidCallback? onTap;
  final bool showDetails;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      label:
          'Carte ${card.isVirtual ? "virtuelle" : "physique"} '
          'se terminant par ${card.lastFourDigits}',
      button: onTap != null,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: margin,
          child: AspectRatio(
            aspectRatio: 1.586,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _surfaceColors(colors),
                ),
                borderRadius: BorderRadius.circular(AppRadius.xxl),
                border: Border.all(
                  color: colors.gold.withValues(
                    alpha: card.isActive ? 0.26 : 0.12,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: colors.isDark ? 0.34 : 0.16,
                    ),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AppText(
                          'Korido',
                          variant: AppTextVariant.titleSmall,
                          color: colors.gold,
                          fontWeight: FontWeight.w700,
                        ),
                        const Spacer(),
                        StatusPill(
                          label: _typeLabel,
                          tone: StatusTone.brand,
                          compact: true,
                        ),
                      ],
                    ),
                    const Spacer(),
                    AppText(
                      showDetails
                          ? _formatCardNumber(card.maskedNumber)
                          : '•••• •••• •••• ${card.last4}',
                      variant: AppTextVariant.monoLarge,
                      color: colors.textInverse,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: _CardMeta(
                            label: 'Titulaire',
                            value: (card.nickname ?? 'Korido Card')
                                .toUpperCase(),
                            colors: colors,
                          ),
                        ),
                        _CardMeta(
                          label: 'Expire',
                          value: card.expiryDate,
                          alignEnd: true,
                          colors: colors,
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        _BrandMark(label: card.brand, colors: colors),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _surfaceColors(ThemeColors colors) {
    if (!card.isActive) {
      return colors.isDark
          ? [AppColors.slate, AppColors.graphite]
          : [
              Color.alphaBlend(
                colors.textPrimary.withValues(alpha: 0.42),
                colors.container,
              ),
              Color.alphaBlend(
                colors.textPrimary.withValues(alpha: 0.72),
                colors.surface,
              ),
            ];
    }

    final inkBase = colors.isDark ? AppColors.obsidian : AppColorsLight.textPrimary;
    final inkMid = colors.isDark
        ? const Color(0xFF131318)
        : const Color(0xFF2A2722);
    final inkDeep = colors.isDark ? AppColors.graphite : const Color(0xFF3D3830);

    return [
      Color.alphaBlend(
        colors.gold.withValues(alpha: colors.isDark ? 0.16 : 0.24),
        inkBase,
      ),
      inkMid,
      Color.alphaBlend(
        colors.gold.withValues(alpha: colors.isDark ? 0.08 : 0.14),
        inkDeep,
      ),
    ];
  }

  String get _typeLabel =>
      card.type == CardType.virtual ? 'Virtuelle' : 'Physique';

  String _formatCardNumber(String masked) {
    final clean = masked.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (var i = 0; i < clean.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(clean[i]);
    }
    return buffer.toString();
  }
}

class _CardMeta extends StatelessWidget {
  const _CardMeta({
    required this.label,
    required this.value,
    required this.colors,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final ThemeColors colors;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        AppText(
          label,
          variant: AppTextVariant.labelSmall,
          color: colors.textInverse.withValues(alpha: 0.68),
        ),
        const SizedBox(height: AppSpacing.xxs),
        AppText(
          value,
          variant: AppTextVariant.labelMedium,
          color: colors.textInverse,
          fontWeight: FontWeight.w700,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.label, required this.colors});

  final String label;
  final ThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return AppText(
      label.toUpperCase(),
      variant: AppTextVariant.labelLarge,
      color: colors.textInverse,
      fontWeight: FontWeight.w800,
    );
  }
}
