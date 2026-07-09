import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/design/components/states/empty_state.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/services/feature_flags/feature_coming_soon_config.dart';
import 'package:usdc_wallet/services/feature_subscriptions/feature_subscription_service.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';
import 'package:usdc_wallet/utils/context_extensions.dart';
import 'package:usdc_wallet/utils/user_facing_errors.dart';

/// Shown when a feature is disabled by remote flags instead of silently redirecting home.
class FeatureComingSoonView extends ConsumerStatefulWidget {
  const FeatureComingSoonView({required this.featureSlug, super.key});

  final String featureSlug;

  @override
  ConsumerState<FeatureComingSoonView> createState() =>
      _FeatureComingSoonViewState();
}

class _FeatureComingSoonViewState extends ConsumerState<FeatureComingSoonView> {
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final config = featureComingSoonConfigFor(widget.featureSlug, l10n);
    final subscription = config.subscription;

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        backgroundColor: context.colors.canvas,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: context.colors.textPrimary),
          onPressed: () => context.fsmSafePop(fallbackRoute: '/home'),
        ),
        title: AppText(
          config.title(l10n),
          variant: AppTextVariant.titleLarge,
          color: context.colors.textPrimary,
        ),
      ),
      body: SafeArea(
        child: EmptyState(
          icon: config.icon,
          title: config.title(l10n),
          description: config.description(l10n),
          action: subscription == null
              ? null
              : EmptyStateAction(
                  label: l10n.featureComingSoon_notifyMe,
                  onPressed: _isSubmitting
                      ? () {}
                      : () => _subscribe(context, l10n, subscription),
                ),
        ),
      ),
    );
  }

  Future<void> _subscribe(
    BuildContext context,
    AppLocalizations l10n,
    FeatureComingSoonSubscriptionFields subscription,
  ) async {
    setState(() => _isSubmitting = true);

    final authState = ref.read(authProvider);
    final user = authState.user;
    final slug = widget.featureSlug.trim();

    try {
      await ref.read(featureSubscriptionServiceProvider).subscribe(
            FeatureSubscriptionRequest(
              featureKey: subscription.featureKey,
              source: 'feature_coming_soon',
              phone: user?.phone ?? authState.phone,
              email: user?.email,
              featureName: subscription.featureName,
              requestedFeature: subscription.requestedFeature,
              countryCode: user?.countryCode,
              locale: user?.preferredLocale,
              metadata: {
                'surface': 'feature_coming_soon',
                if (slug.isNotEmpty) 'featureSlug': slug,
              },
            ),
          );
    } on Object catch (e) {
      if (!context.mounted) {
        return;
      }
      context.showSnack(
        l10n.common_errorFormat(UserFacingErrors.message(e)),
        tone: AppSnackTone.error,
      );
      return;
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }

    if (!context.mounted) {
      return;
    }
    context.showSnack(
      l10n.featureComingSoon_notifySuccess,
      tone: AppSnackTone.success,
    );
  }
}