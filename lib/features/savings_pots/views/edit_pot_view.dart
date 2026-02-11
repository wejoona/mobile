import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/theme/theme_extensions.dart';
import 'package:usdc_wallet/features/savings_pots/providers/savings_pots_provider.dart';
import 'package:usdc_wallet/features/savings_pots/widgets/emoji_picker.dart';
import 'package:usdc_wallet/features/savings_pots/widgets/color_picker.dart';

/// Screen for editing an existing savings pot
class EditPotView extends ConsumerStatefulWidget {
  const EditPotView({super.key, required this.potId});

  final String potId;

  @override
  ConsumerState<EditPotView> createState() => _EditPotViewState();
}

class _EditPotViewState extends ConsumerState<EditPotView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();

  String? _selectedEmoji;
  Color? _selectedColor;

  @override
  void initState() {
    super.initState();
    // Pre-fill with current pot data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(savingsPotsProvider);
      final pot = state.pots.firstWhere((p) => p.id == widget.potId);

      _nameController.text = pot.name;
      _selectedEmoji = pot.emoji;
      _selectedColor = pot.color;
      if (pot.targetAmount != null) {
        _targetController.text = pot.targetAmount!.toStringAsFixed(2);
      }
    });
  }

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
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        title: AppText(
          l10n.savingsPots_editTitle,
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
              color: colors.textSecondary,
            ),
            SizedBox(height: AppSpacing.xl),

            // Update button
            AppButton(
              label: l10n.savingsPots_updateButton,
              onPressed: _handleUpdate,
              isLoading: state.isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    final targetAmount = _targetController.text.isEmpty
        ? null
        : double.tryParse(_targetController.text);

    final success = await ref.read(savingsPotsProvider.notifier).updatePot(
          id: widget.potId,
          name: _nameController.text,
          emoji: _selectedEmoji,
          color: _selectedColor,
          targetAmount: targetAmount,
        );

    if (success && mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.savingsPots_updateSuccess),
          backgroundColor: context.colors.success,
        ),
      );
    }
  }
}
