import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/domain/enums/index.dart';
import 'package:usdc_wallet/state/user_state_machine.dart';
import 'package:usdc_wallet/features/cards/providers/cards_provider.dart';

/// Request Card View
///
/// Request a new virtual card (requires KYC Tier 2+)
class RequestCardView extends ConsumerStatefulWidget {
  const RequestCardView({super.key});

  @override
  ConsumerState<RequestCardView> createState() => _RequestCardViewState();
}

class _RequestCardViewState extends ConsumerState<RequestCardView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _limitController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill cardholder name from user profile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userState = ref.read(userStateMachineProvider);
      if (userState.firstName != null) {
        _nameController.text = '${userState.firstName} ${userState.lastName ?? ''}'.trim();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final userState = ref.watch(userStateMachineProvider);

    // Check KYC level (tier 2+ = verified or higher)
    final canRequestCard = userState.kycStatus == KycStatus.verified;

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          l10n.cards_requestCard,
          variant: AppTextVariant.titleLarge,
          color: colors.textPrimary,
        ),
      ),
      body: !canRequestCard
          ? _buildKYCRequired(context, l10n, colors)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info card
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: colors.elevated,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: colors.gold,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: AppText(
                              l10n.cards_requestInfo,
                              variant: AppTextVariant.bodySmall,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // Cardholder name
                    AppText(
                      l10n.cards_cardholderName,
                      variant: AppTextVariant.labelLarge,
                      color: colors.textPrimary,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppInput(
                      label: l10n.cards_cardholderNameHint,
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.cards_nameRequired;
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Spending limit
                    AppText(
                      l10n.cards_spendingLimit,
                      variant: AppTextVariant.labelLarge,
                      color: colors.textPrimary,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppInput(
                      label: l10n.cards_spendingLimitHint,
                      controller: _limitController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.cards_limitRequired;
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return l10n.cards_limitInvalid;
                        }
                        if (amount < 10) {
                          return l10n.cards_limitTooLow;
                        }
                        if (amount > 10000) {
                          return l10n.cards_limitTooHigh;
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Limit suggestions
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [100, 500, 1000, 5000]
                          .map((amount) => _buildLimitChip(
                                context,
                                amount,
                                () => _limitController.text = amount.toString(),
                              ))
                          .toList(),
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // Features list
                    AppText(
                      l10n.cards_cardFeatures,
                      variant: AppTextVariant.titleMedium,
                      color: colors.textPrimary,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    _buildFeatureItem(
                      context,
                      icon: Icons.shopping_cart_outlined,
                      text: l10n.cards_featureOnlineShopping,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildFeatureItem(
                      context,
                      icon: Icons.security_outlined,
                      text: l10n.cards_featureSecure,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildFeatureItem(
                      context,
                      icon: Icons.ac_unit,
                      text: l10n.cards_featureFreeze,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildFeatureItem(
                      context,
                      icon: Icons.notifications_outlined,
                      text: l10n.cards_featureAlerts,
                    ),

                    const SizedBox(height: AppSpacing.xxxl),

                    // Submit button
                    AppButton(
                      label: l10n.cards_requestCardSubmit,
                      onPressed: _handleSubmit,
                      isLoading: _isSubmitting,
                      isFullWidth: true,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildKYCRequired(
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
              Icons.verified_user_outlined,
              size: 80,
              color: colors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppText(
              l10n.cards_kycRequired,
              variant: AppTextVariant.headlineSmall,
              color: colors.textPrimary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            AppText(
              l10n.cards_kycRequiredDescription,
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppButton(
              label: l10n.cards_completeKYC,
              onPressed: () => context.push('/kyc'),
              icon: Icons.arrow_forward,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitChip(
    BuildContext context,
    int amount,
    VoidCallback onPressed,
  ) {
    final colors = context.colors;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: colors.elevated,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: colors.border),
        ),
        child: AppText(
          '\$$amount',
          variant: AppTextVariant.labelMedium,
          color: colors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    final colors = context.colors;
    return Row(
      children: [
        Icon(icon, color: colors.gold, size: 20),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: AppText(
            text,
            variant: AppTextVariant.bodyMedium,
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final name = _nameController.text.trim();
      final limit = double.parse(_limitController.text);

      final success = await ref.read(cardsProvider.notifier).requestCard(
            cardholderName: name,
            spendingLimit: limit,
          );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.cards_requestSuccess),
            backgroundColor: context.colors.success,
          ),
        );
        context.pop();
      } else {
        final error = ref.read(cardsProvider).requestError;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? AppLocalizations.of(context)!.cards_requestFailed),
            backgroundColor: context.colors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: context.colors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
