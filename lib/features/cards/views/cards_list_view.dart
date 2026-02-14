import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/cards/providers/cards_provider.dart';
import 'package:usdc_wallet/features/cards/widgets/card_visual.dart';
import 'package:usdc_wallet/features/cards/widgets/card_actions_row.dart';
import 'package:usdc_wallet/design/components/primitives/empty_state.dart';

/// Cards list screen with visual card display.
class CardsListView extends ConsumerWidget {
  const CardsListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(cardsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Cards')),
      body: cardsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (cards) {
          if (cards.isEmpty) {
            return EmptyState(
              icon: Icons.credit_card_rounded,
              title: 'No cards yet',
              subtitle: 'Request a virtual card to make online payments with your USDC balance',
              actionLabel: 'Request Card',
              onAction: () async {
                final actions = ref.read(cardActionsProvider);
                await actions.requestVirtual({});
                ref.invalidate(cardsProvider);
              },
            );
          }
          return PageView.builder(
            itemCount: cards.length,
            controller: PageController(viewportFraction: 0.92),
            itemBuilder: (_, index) {
              final card = cards[index];
              return Column(
                children: [
                  const SizedBox(height: 24),
                  CardVisual(card: card),
                  const SizedBox(height: 16),
                  CardActionsRow(
                    card: card,
                    onFreeze: () async {
                      final actions = ref.read(cardActionsProvider);
                      await actions.freeze(card.id);
                      ref.invalidate(cardsProvider);
                    },
                    onBlock: () async {
                      final actions = ref.read(cardActionsProvider);
                      await actions.block(card.id);
                      ref.invalidate(cardsProvider);
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
