import 'package:flutter/material.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

/// Predefined emoji categories for pots
class PotEmojis {
  static const travel = ['✈️', '🏖️', '🗼', '🌍', '🏝️'];
  static const shopping = ['🛍️', '👗', '👟', '👜', '💄'];
  static const tech = ['📱', '💻', '🎮', '🎧', '⌚'];
  static const home = ['🏠', '🛋️', '🚗', '🔑', '🏡'];
  static const events = ['🎂', '💒', '🎄', '🎁', '🎉'];
  static const general = ['💰', '🎯', '⭐', '💎', '🏆'];
  static const health = ['🏥', '💊', '🏋️', '🧘', '🚴'];
  static const education = ['📚', '🎓', '✏️', '📖', '🖊️'];

  static List<String> get all => [
    ...travel,
    ...shopping,
    ...tech,
    ...home,
    ...events,
    ...general,
    ...health,
    ...education,
  ];
}

/// Emoji picker widget for pot creation
class EmojiPicker extends StatelessWidget {
  const EmojiPicker({
    super.key,
    required this.selectedEmoji,
    required this.onEmojiSelected,
  });

  final String? selectedEmoji;
  final ValueChanged<String> onEmojiSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          l10n.savingsPots_chooseEmoji,
          variant: AppTextVariant.bodyMedium,
          color: context.colors.textSecondary,
        ),
        SizedBox(height: AppSpacing.sm),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: PotEmojis.all.length,
          itemBuilder: (context, index) {
            final emoji = PotEmojis.all[index];
            final isSelected = emoji == selectedEmoji;

            return GestureDetector(
              onTap: () => onEmojiSelected(emoji),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.colors.gold.withOpacity(0.2)
                      : context.colors.container,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(
                    color: isSelected ? context.colors.gold : Colors.transparent,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
