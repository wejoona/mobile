import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../services/feature_flags/feature_flags_provider.dart';
import '../providers/cards_provider.dart';
import '../widgets/virtual_card_widget.dart';

/// Cards List View
///
/// Displays user's virtual cards
class CardsListView extends ConsumerStatefulWidget {
  const CardsListView({super.key});

  @override
  ConsumerState<CardsListView> createState() => _CardsListViewState();
}

class _CardsListViewState extends ConsumerState<CardsListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cardsProvider.notifier).loadCards();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final state = ref.watch(cardsProvider);
    final featureFlags = ref.watch(featureFlagsProvider);

    // Check feature flag
    if (!featureFlags.virtualCards) {
      return Scaffold(
        backgroundColor: colors.canvas,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: AppText(
            l10n.cards_title,
            variant: AppTextVariant.titleLarge,
            color: colors.textPrimary,
          ),
        ),
        body: Center(
          child: AppText(
            l10n.cards_featureDisabled,
            variant: AppTextVariant.bodyLarge,
            color: colors.textSecondary,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          l10n.cards_title,
          variant: AppTextVariant.titleLarge,
          color: colors.textPrimary,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(cardsProvider.notifier).loadCards(),
        child: state.isLoading && state.cards.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : state.cards.isEmpty
                ? _buildEmptyState(context, l10n, colors)
                : _buildCardsList(context, l10n, colors, state),
      ),
      floatingActionButton: state.canRequestCard
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/cards/request'),
              backgroundColor: colors.gold,
              label: AppText(
                l10n.cards_requestCard,
                variant: AppTextVariant.labelLarge,
                color: colors.textInverse,
              ),
              icon: Icon(
                Icons.add_card,
                color: colors.textInverse,
              ),
            )
          : null,
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    AppLocalizations l10n,
    ThemeColors colors,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.credit_card_outlined,
              size: 80,
              color: colors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppText(
              l10n.cards_noCards,
              variant: AppTextVariant.headlineSmall,
              color: colors.textPrimary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            AppText(
              l10n.cards_noCardsDescription,
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppButton(
              label: l10n.cards_requestCard,
              onPressed: () => context.push('/cards/request'),
              icon: Icons.add_card,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardsList(
    BuildContext context,
    AppLocalizations l10n,
    ThemeColors colors,
    CardsState state,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      itemCount: state.cards.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.lg),
      itemBuilder: (context, index) {
        final card = state.cards[index];
        return VirtualCardWidget(
          card: card,
          onTap: () {
            ref.read(cardsProvider.notifier).selectCard(card);
            context.push('/cards/detail/${card.id}');
          },
        );
      },
    );
  }
}
