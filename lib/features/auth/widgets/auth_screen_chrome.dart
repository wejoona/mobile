import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

class KoridoMark extends StatelessWidget {
  const KoridoMark({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isLight = !colors.isDark;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isLight ? AppColorsLight.gold500 : null,
        gradient: isLight
            ? null
            : LinearGradient(
                colors: colors.goldGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(size * 0.28),
        border: isLight
            ? Border.all(color: AppColorsLight.gold600.withValues(alpha: 0.18))
            : null,
        boxShadow: isLight ? AppShadows.lightGoldGlow : AppShadows.goldGlow,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AppText(
            'K',
            variant: AppTextVariant.headlineLarge,
            color: colors.onGold,
            style: AppTypography.headlineLarge.copyWith(
              fontSize: size * 0.5,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class AuthScreenHeader extends StatelessWidget {
  const AuthScreenHeader({
    super.key,
    required this.appName,
    required this.title,
    required this.subtitle,
    this.markSize = 56,
    this.titleVariant = AppTextVariant.titleLarge,
  });

  final String appName;
  final String title;
  final String subtitle;
  final double markSize;
  final AppTextVariant titleVariant;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      children: [
        KoridoMark(size: markSize),
        const SizedBox(height: AppSpacing.xl),
        AppText(
          appName,
          variant: AppTextVariant.headlineLarge,
          color: colors.textPrimary,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        AppText(
          title,
          variant: titleVariant,
          color: colors.textPrimary,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: AppText(
            subtitle,
            variant: AppTextVariant.bodyMedium,
            color: colors.textSecondary,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class AuthTopBar extends StatelessWidget {
  const AuthTopBar({super.key, this.onBack, this.trailing});

  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (onBack != null)
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: onBack,
                icon: Icon(Icons.arrow_back, color: colors.textPrimary),
              ),
            ),
          if (trailing != null)
            Align(alignment: Alignment.centerRight, child: trailing),
        ],
      ),
    );
  }
}
