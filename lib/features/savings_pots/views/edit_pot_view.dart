import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/domain/entities/savings_pot.dart';
import 'package:usdc_wallet/features/savings_pots/providers/savings_pots_provider.dart';
import 'package:usdc_wallet/features/savings_pots/widgets/emoji_picker.dart';
import 'package:usdc_wallet/features/savings_pots/widgets/color_picker.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

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
  bool _prefilled = false;

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(savingsPotsStateProvider);
    final colors = context.colors;
    final pot = _findPot(state.pots, widget.potId);

    if (state.isLoading && pot == null) {
      return Scaffold(
        backgroundColor: colors.canvas,
        appBar: AppBar(
          title: AppText(
            l10n.savingsPots_editTitle,
            variant: AppTextVariant.headlineSmall,
          ),
          backgroundColor: Colors.transparent,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (pot == null) {
      return Scaffold(
        backgroundColor: colors.canvas,
        appBar: AppBar(
          title: AppText(
            l10n.savingsPots_editTitle,
            variant: AppTextVariant.headlineSmall,
          ),
          backgroundColor: Colors.transparent,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: AppText(
              l10n.savingsPots_error('Pot not found'),
              variant: AppTextVariant.bodyLarge,
              color: colors.textSecondary,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    _prefillOnce(pot);

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

  SavingsPot? _findPot(List<SavingsPot> pots, String potId) {
    for (final pot in pots) {
      if (pot.id == potId) {
        return pot;
      }
    }
    return null;
  }

  void _prefillOnce(SavingsPot pot) {
    if (_prefilled) {
      return;
    }

    _prefilled = true;
    _nameController.text = pot.name;
    _selectedEmoji = pot.emoji;
    _selectedColor = pot.color;
    _targetController.text = pot.targetAmount.toStringAsFixed(2);
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    final targetAmount = _targetController.text.isEmpty
        ? null
        : double.tryParse(_targetController.text);

    final success = await ref
        .read(savingsPotsActionsProvider)
        .updatePot(
          id: widget.potId,
          name: _nameController.text,
          emoji: _selectedEmoji,
          color: _selectedColor != null
              ? '#${_selectedColor!.toARGB32().toRadixString(16).padLeft(8, '0')}'
              : null,
          targetAmount: targetAmount,
        );

    if (success && mounted) {
      context.fsmPop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.savingsPots_updateSuccess,
          ),
          backgroundColor: context.colors.success,
        ),
      );
    }
  }
}
