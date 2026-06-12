import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/design/components/primitives/shimmer_loading.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/features/cards/providers/cards_provider.dart';
import 'package:usdc_wallet/features/cards/widgets/card_actions_row.dart';
import 'package:usdc_wallet/features/cards/widgets/card_empty_state.dart';
import 'package:usdc_wallet/features/cards/widgets/card_visual.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/services/feature_subscriptions/feature_subscription_service.dart';
import 'package:usdc_wallet/utils/context_extensions.dart';

/// Cards list screen with visual card display.
class CardsListView extends ConsumerWidget {
  const CardsListView({super.key});

  Widget _buildLoadingSkeleton() => const Center(
    child: Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShimmerLoading(width: 300, height: 190, borderRadius: 16),
          SizedBox(height: 24),
          ShimmerLoading(width: 200),
          SizedBox(height: 8),
          ShimmerLoading(width: 150, height: 14),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(cardsEnvelopeProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: context.colors.textPrimary,
          ),
          onPressed: () {
            final router = GoRouter.of(context);
            if (router.canPop()) {
              router.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: AppText(
          l10n.cards_myCards,
          variant: AppTextVariant.titleLarge,
          color: context.colors.textPrimary,
        ),
      ),
      body: cardsAsync.when(
        loading: _buildLoadingSkeleton,
        error: (e, _) => Center(
          child: AppText(
            l10n.cards_error(e.toString()),
            color: context.colors.textSecondary,
            textAlign: TextAlign.center,
          ),
        ),
        data: (envelope) {
          final cards = envelope.cards;
          if (cards.isEmpty) {
            return CardEmptyState(
              canCreateCard: envelope.canRequestCard,
              reason: envelope.featureReason ?? envelope.reason,
              onCreateCard: envelope.canRequestCard
                  ? () => context.push('/cards/request')
                  : null,
              onNotifyMe: envelope.canRequestCard
                  ? null
                  : () => _subscribeToCards(context, ref, l10n),
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
                      ref.invalidate(cardsEnvelopeProvider);
                    },
                    onBlock: () async {
                      final actions = ref.read(cardActionsProvider);
                      await actions.block(card.id);
                      ref.invalidate(cardsEnvelopeProvider);
                    },
                    onDetails: () => context.push('/cards/detail/${card.id}'),
                    onSettings: () =>
                        context.push('/cards/settings/${card.id}'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _subscribeToCards(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final authState = ref.read(authProvider);
    final user = authState.user;
    try {
      await ref
          .read(featureSubscriptionServiceProvider)
          .subscribe(
            FeatureSubscriptionRequest(
              featureKey: 'virtual_card',
              source: 'cards_screen',
              phone: user?.phone ?? authState.phone,
              email: user?.email,
              featureName: 'Korido virtual card',
              requestedFeature: 'virtual_card_launch',
              countryCode: user?.countryCode,
              locale: user?.preferredLocale,
              metadata: const {'surface': 'cards'},
            ),
          );
    } catch (e) {
      if (!context.mounted) return;
      context.showSnack(
        l10n.common_errorFormat(e.toString()),
        tone: AppSnackTone.error,
      );
      return;
    }

    if (!context.mounted) return;
    context.showSnack(l10n.cards_notifySuccess, tone: AppSnackTone.success);
  }
}
