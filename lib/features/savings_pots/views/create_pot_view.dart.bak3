import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../providers/savings_pots_provider.dart';
import '../widgets/emoji_picker.dart';
import '../widgets/color_picker.dart';

/// Screen for creating a new savings pot
class CreatePotView extends ConsumerStatefulWidget {
  const CreatePotView({super.key});

  @override
  ConsumerState<CreatePotView> createState() => _CreatePotViewState();
}

class _CreatePotViewState extends ConsumerState<CreatePotView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();

  String? _selectedEmoji;
  Color? _selectedColor;

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(savingsPotsProvider);

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: AppText(
          l10n.savingsPots_createTitle,
          variant: AppTextVariant.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.md),
          children: [
            // Pot name input
            AppInput(
              label: l10n.savingsPots_nameLabel,
              controller: _nameController,
              hint: l10n.savingsPots_nameHint,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return l10n.savingsPots_nameRequired;
                }
                return null;
              },
            ),
            SizedBox(height: AppSpacing.lg),

            // Emoji picker
            EmojiPicker(
              selectedEmoji: _selectedEmoji,
              onEmojiSelected: (emoji) {
                setState(() => _selectedEmoji = emoji);
              },
            ),
            SizedBox(height: AppSpacing.lg),

            // Color picker
            ColorPicker(
              selectedColor: _selectedColor,
              onColorSelected: (color) {
                setState(() => _selectedColor = color);
              },
            ),
            SizedBox(height: AppSpacing.lg),

            // Target amount (optional)
            AppInput(
              label: l10n.savingsPots_targetLabel,
              controller: _targetController,
              hint: l10n.savingsPots_targetHint,
              keyboardType: TextInputType.number,
              prefix: const Text('\$ '),
            ),
            SizedBox(height: AppSpacing.xs),
            AppText(
              l10n.savingsPots_targetOptional,
              variant: AppTextVariant.bodySmall,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: AppSpacing.xl),

            // Create button
            AppButton(
              label: l10n.savingsPots_createButton,
              onPressed: _handleCreate,
              isLoading: state.isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedEmoji == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.savingsPots_emojiRequired),
          backgroundColor: AppColors.errorBase,
        ),
      );
      return;
    }

    if (_selectedColor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.savingsPots_colorRequired),
          backgroundColor: AppColors.errorBase,
        ),
      );
      return;
    }

    final targetAmount = _targetController.text.isEmpty
        ? null
        : double.tryParse(_targetController.text);

    final success = await ref.read(savingsPotsProvider.notifier).createPot(
          name: _nameController.text,
          emoji: _selectedEmoji!,
          color: _selectedColor!,
          targetAmount: targetAmount,
        );

    if (success && mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.savingsPots_createSuccess),
          backgroundColor: AppColors.successBase,
        ),
      );
    }
  }
}
