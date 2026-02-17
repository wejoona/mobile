import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/cards/providers/cards_provider.dart';
import 'package:usdc_wallet/features/cards/widgets/card_visual.dart';
import 'package:usdc_wallet/features/cards/widgets/card_actions_row.dart';
import 'package:usdc_wallet/features/cards/widgets/card_empty_state.dart';
import 'package:usdc_wallet/design/components/primitives/shimmer_loading.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

/// Cards list screen with visual card display.
class CardsListView extends ConsumerWidget {
  const CardsListView({super.key});

  Widget _buildLoadingSkeleton() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShimmerLoading(width: 300, height: 190, borderRadius: 16),
            const SizedBox(height: 24),
            ShimmerLoading(width: 200, height: 16),
            const SizedBox(height: 8),
            ShimmerLoading(width: 150, height: 14),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(cardsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.cards_myCards)),
      body: cardsAsync.when(
        loading: () => _buildLoadingSkeleton(),
        error: (e, _) => Center(child: Text(AppLocalizations.of(context)!.cards_error(e.toString()))),
        data: (cards) {
          if (cards.isEmpty) {
            return CardEmptyState(
              onCreateCard: () async {
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
