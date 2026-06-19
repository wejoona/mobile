import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/components/composed/pin_confirmation_sheet.dart';
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
import 'package:usdc_wallet/services/pin/pin_service.dart';
import 'package:usdc_wallet/utils/context_extensions.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

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
          onPressed: () => context.fsmSafePop(),
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
                  ? () => context.fsmPush('/cards/request')
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
                      final pinToken = await _requestPinToken(
                        context,
                        ref,
                        title: l10n.send_verifyPin,
                        subtitle: card.isFrozen
                            ? l10n.cards_unfreezeConfirmation
                            : l10n.cards_freezeConfirmation,
                      );
                      if (pinToken == null || !context.mounted) {
                        return;
                      }

                      final actions = ref.read(cardActionsProvider);
                      if (card.isFrozen) {
                        await actions.unfreezeCard(card.id, pinToken: pinToken);
                      } else {
                        await actions.freezeCard(card.id, pinToken: pinToken);
                      }
                      ref.invalidate(cardsEnvelopeProvider);
                    },
                    onBlock: () async {
                      await _confirmBlockCard(context, ref, l10n, card.id);
                    },
                    onDetails: () =>
                        context.fsmPush('/cards/detail/${card.id}'),
                    onSettings: () =>
                        context.fsmPush('/cards/settings/${card.id}'),
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

  Future<void> _confirmBlockCard(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    String cardId,
  ) async {
    final colors = context.colors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.container,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
        ),
        title: AppText(
          l10n.cards_blockCard,
          variant: AppTextVariant.titleMedium,
          color: colors.error,
        ),
        content: AppText(
          l10n.cards_blockCardConfirmation,
          variant: AppTextVariant.bodyMedium,
          color: colors.textSecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: AppText(
              l10n.action_cancel,
              variant: AppTextVariant.labelLarge,
              color: colors.textSecondary,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: AppText(
              l10n.action_confirm,
              variant: AppTextVariant.labelLarge,
              color: colors.error,
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      final pinToken = await _requestPinToken(
        context,
        ref,
        title: l10n.send_verifyPin,
        subtitle: l10n.cards_blockCardConfirmation,
      );
      if (pinToken == null || !context.mounted) {
        return;
      }

      await ref
          .read(cardActionsProvider)
          .cancelCard(cardId, pinToken: pinToken);
      ref.invalidate(cardsEnvelopeProvider);
      ref.invalidate(cardsProvider);
      if (!context.mounted) {
        return;
      }
      context.showSnack(l10n.cards_cardBlocked, tone: AppSnackTone.error);
    } catch (_) {
      if (!context.mounted) return;
      context.showSnack(l10n.cards_blockError, tone: AppSnackTone.error);
    }
  }

  Future<String?> _requestPinToken(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    String? subtitle,
  }) async {
    String? pinToken;
    final result = await PinConfirmationSheet.show(
      context: context,
      title: title,
      subtitle: subtitle,
      onConfirm: (pin) async {
        final verification = await ref
            .read(pinServiceProvider)
            .verifyPinWithBackend(pin);
        if (verification.success && verification.pinToken != null) {
          pinToken = verification.pinToken;
          return true;
        }
        return false;
      },
    );

    if (result == PinConfirmationResult.success) return pinToken;
    return null;
  }
}
