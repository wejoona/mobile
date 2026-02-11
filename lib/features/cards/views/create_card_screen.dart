import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/create_card_provider.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../design/theme/spacing.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Carte creee avec succes')));
        Navigator.pop(context, true);
        notifier.reset();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle carte')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Type de carte', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),

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
                const SizedBox(width: AppSpacing.md),
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

            const SizedBox(height: AppSpacing.lg),

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
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(state.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),

            FilledButton(
              onPressed: !state.isLoading ? () => notifier.create() : null,
              child: state.isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Creer la carte'),
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
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          color: selected ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2) : null,
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: selected ? Theme.of(context).colorScheme.primary : Colors.grey),
            const SizedBox(height: AppSpacing.sm),
            Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.xs),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
