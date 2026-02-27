import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/cards/providers/create_card_provider.dart';
import 'package:usdc_wallet/core/l10n/app_strings.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';

/// Create card screen.
class CreateCardScreen extends ConsumerStatefulWidget {
  const CreateCardScreen({super.key});

  @override
  ConsumerState<CreateCardScreen> createState() => _CreateCardScreenState();
}

class _CreateCardScreenState extends ConsumerState<CreateCardScreen> {
  final _nicknameController = TextEditingController();

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createCardProvider);
    final notifier = ref.read(createCardProvider.notifier);

    ref.listen<CreateCardState>(createCardProvider, (_, next) {
      if (next.isComplete) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.cards_cardCreated)));
        Navigator.pop(context, true);
        notifier.reset();
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.cards_newCard)),
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AppLocalizations.of(context)!.cards_cardType, style: AppTypography.titleSmall),
            SizedBox(height: AppSpacing.md),

            Row(
              children: [
                Expanded(
                  child: _CardTypeOption(
                    icon: Icons.credit_card,
                    label: AppStrings.virtualCard,
                    subtitle: 'Instantanee, pour les achats en ligne',
                    selected: state.cardType == 'virtual',
                    onTap: () => notifier.setCardType('virtual'),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _CardTypeOption(
                    icon: Icons.credit_card_outlined,
                    label: AppStrings.physicalCard,
                    subtitle: 'Livraison en 5-7 jours',
                    selected: state.cardType == 'physical',
                    onTap: () => notifier.setCardType('physical'),
                  ),
                ),
              ],
            ),

            SizedBox(height: AppSpacing.lg),

            TextField(
              controller: _nicknameController,
              decoration: const InputDecoration(
                labelText: 'Surnom (optionnel)',
                hintText: 'Ex: Shopping, Voyage...',
                prefixIcon: Icon(Icons.label_outline),
              ),
              onChanged: notifier.setNickname,
            ),

            const Spacer(),

            if (state.error != null)
              Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(state.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),

            AppButton(
              label: AppLocalizations.of(context)!.cards_createCard,
              onPressed: !state.isLoading ? () => notifier.create() : null,
              isLoading: state.isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

class _CardTypeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _CardTypeOption({required this.icon, required this.label, required this.subtitle, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: selected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          color: selected ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2) : null,
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: selected ? Theme.of(context).colorScheme.primary : context.colors.textSecondary),
            SizedBox(height: AppSpacing.sm),
            Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: AppSpacing.xs),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
