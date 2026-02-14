import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/router/navigation_extensions.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/services/localization/language_provider.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

/// Language selection view for changing app language
class LanguageView extends ConsumerWidget {
  const LanguageView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final localeState = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!;

    final languages = [
      {'code': 'en', 'nativeName': 'English'},
      {'code': 'fr', 'nativeName': 'Français'},
    ];

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          l10n.language_changeLanguage,
          variant: AppTextVariant.titleLarge,
          color: colors.textPrimary,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.gold),
          onPressed: () => context.safePop(fallbackRoute: '/settings'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          AppText(
            l10n.language_selectLanguage,
            variant: AppTextVariant.bodyMedium,
            color: colors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.xl),
          ...languages.map((language) {
            final code = language['code']!;
            final nativeName = language['nativeName']!;
            final isSelected = localeState.locale.languageCode == code;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _LanguageTile(
                languageCode: code,
                nativeName: nativeName,
                displayName: code == 'en' ? l10n.language_english : l10n.language_french,
                isSelected: isSelected,
                isLoading: localeState.isLoading,
                onTap: () async {
                  if (!isSelected) {
                    await ref.read(localeProvider.notifier).changeLanguage(code);
                  }
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Language tile widget
class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.languageCode,
    required this.nativeName,
    required this.displayName,
    required this.isSelected,
    required this.isLoading,
    required this.onTap,
  });

  final String languageCode;
  final String nativeName;
  final String displayName;
  final bool isSelected;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      variant: isSelected ? AppCardVariant.goldAccent : AppCardVariant.elevated,
      onTap: isLoading ? null : onTap,
      child: Row(
        children: [
          // Language icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected
                  ? colors.gold.withOpacity(0.2)
                  : colors.container.withOpacity(0.5),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Center(
              child: AppText(
                _getLanguageFlag(languageCode),
                variant: AppTextVariant.headlineMedium,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),

          // Language names
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  nativeName,
                  variant: AppTextVariant.titleMedium,
                  color: isSelected ? colors.gold : colors.textPrimary,
                ),
                const SizedBox(height: AppSpacing.xxs),
                AppText(
                  displayName,
                  variant: AppTextVariant.bodySmall,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),

          // Selection indicator
          if (isSelected)
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: colors.gold,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                color: context.colors.textInverse,
                size: 16,
              ),
            )
          else
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                border: Border.all(
                  color: colors.textTertiary,
                  width: 2,
                ),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  String _getLanguageFlag(String code) {
    switch (code) {
      case 'en':
        return '🇬🇧';
      case 'fr':
        return '🇫🇷';
      default:
        return '🌐';
    }
  }
}
