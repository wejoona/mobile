import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

class WalletBalanceInfoPill extends StatelessWidget {
  const WalletBalanceInfoPill({
    required ThemeColors colors,
    required IconData icon,
    required String label,
    required Color color,
    super.key,
  }) : _colors = colors,
       _icon = icon,
       _label = label,
       _color = color;

  final ThemeColors _colors;
  final IconData _icon;
  final String _label;
  final Color _color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.xs,
    ),
    decoration: BoxDecoration(
      color: Color.alphaBlend(
        _color.withValues(alpha: _colors.isDark ? 0.16 : 0.14),
        _colors.container,
      ),
      borderRadius: BorderRadius.circular(AppRadius.full),
      border: Border.all(
        color: _color.withValues(alpha: _colors.isDark ? 0.20 : 0.26),
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(_icon, size: 14, color: _color.withValues(alpha: 0.82)),
        const SizedBox(width: AppSpacing.xs),
        AppText(
          _label,
          variant: AppTextVariant.labelMedium,
          color: _colors.isDark ? _colors.textSecondary : _colors.textPrimary,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

class WalletLoadingCard extends StatelessWidget {
  const WalletLoadingCard({
    required ThemeColors colors,
    required String label,
    super.key,
  }) : _colors = colors,
       _label = label;

  final ThemeColors _colors;
  final String _label;

  @override
  Widget build(BuildContext context) => AppCard(
    variant: _colors.isDark ? AppCardVariant.flat : AppCardVariant.elevated,
    backgroundColor: _colors.isDark
        ? null
        : Color.alphaBlend(
            _colors.gold.withValues(alpha: 0.04),
            _colors.container,
          ),
    child: Column(
      children: [
        CircularProgressIndicator(color: _colors.gold, strokeWidth: 2),
        const SizedBox(height: AppSpacing.md),
        AppText(_label, color: _colors.textSecondary),
      ],
    ),
  );
}

class WalletCreatingState extends StatelessWidget {
  const WalletCreatingState({required ThemeColors colors, super.key})
    : _colors = colors;

  final ThemeColors _colors;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_colors.gold, _colors.gold.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              color: _colors.onGold,
              size: 36,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          CircularProgressIndicator(color: _colors.gold, strokeWidth: 2),
          const SizedBox(height: AppSpacing.lg),
          AppText(
            l10n.wallet_settingUp,
            variant: AppTextVariant.titleMedium,
            color: _colors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.xs),
          AppText(l10n.wallet_setupMoment, color: _colors.textSecondary),
        ],
      ),
    );
  }
}

class WalletErrorCard extends StatelessWidget {
  const WalletErrorCard({
    required ThemeColors colors,
    required String error,
    required String retryLabel,
    VoidCallback? onRetry,
    super.key,
  }) : _colors = colors,
       _error = error,
       _retryLabel = retryLabel,
       _onRetry = onRetry;

  final ThemeColors _colors;
  final String _error;
  final String _retryLabel;
  final VoidCallback? _onRetry;

  @override
  Widget build(BuildContext context) => AppCard(
    variant: _colors.isDark ? AppCardVariant.flat : AppCardVariant.elevated,
    backgroundColor: _colors.isDark
        ? null
        : Color.alphaBlend(
            _colors.error.withValues(alpha: 0.04),
            _colors.container,
          ),
    child: Center(
      child: Column(
        children: [
          Icon(Icons.error_outline, color: _colors.error, size: 48),
          const SizedBox(height: AppSpacing.md),
          AppText(
            _error,
            color: _colors.textSecondary,
            textAlign: TextAlign.center,
          ),
          if (_onRetry != null) ...[
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: _retryLabel,
              onPressed: _onRetry,
              variant: AppButtonVariant.secondary,
              size: AppButtonSize.small,
            ),
          ],
        ],
      ),
    ),
  );
}

class WalletHiddenBalance extends StatelessWidget {
  const WalletHiddenBalance({required ThemeColors colors, super.key})
    : _colors = colors;

  final ThemeColors _colors;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.visibility_off_rounded, size: 32, color: _colors.gold),
      const SizedBox(width: AppSpacing.md),
      AmountText.fromText(
        r'$••••••',
        size: AmountTextSize.display,
        color: _colors.gold,
      ),
    ],
  );
}
