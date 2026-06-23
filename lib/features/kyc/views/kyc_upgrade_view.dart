import 'dart:async';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/components/primitives/app_button.dart';
import 'package:usdc_wallet/design/components/primitives/app_card.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/design/tokens/spacing.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';
import 'package:usdc_wallet/features/kyc/models/kyc_tier.dart';
import 'package:usdc_wallet/features/kyc/providers/kyc_provider.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

class KycUpgradeView extends ConsumerStatefulWidget {
  const KycUpgradeView({
    required this.currentTier,
    required this.targetTier,
    super.key,
    this.reason,
  });

  final KycTier currentTier;
  final KycTier targetTier;
  final String? reason;

  @override
  ConsumerState<KycUpgradeView> createState() => _KycUpgradeViewState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<KycTier>('currentTier', currentTier))
      ..add(EnumProperty<KycTier>('targetTier', targetTier))
      ..add(StringProperty('reason', reason));
  }
}

class _KycUpgradeViewState extends ConsumerState<KycUpgradeView> {
  int _selectedTierIndex = 0;
  late List<TierBenefits> _availableTiers;

  @override
  void initState() {
    super.initState();
    _initializeTiers();
  }

  void _initializeTiers() {
    _availableTiers = [];

    // Add tiers higher than current
    if (widget.currentTier.level < 1) {
      _availableTiers.add(TierBenefits.tier1());
    }
    if (widget.currentTier.level < 2) {
      _availableTiers.add(TierBenefits.tier2());
    }
    if (widget.currentTier.level < 3) {
      _availableTiers.add(TierBenefits.tier3());
    }

    // Select target tier by default
    _selectedTierIndex = _availableTiers.indexWhere(
      (tier) => tier.tier == widget.targetTier,
    );
    if (_selectedTierIndex == -1) {
      _selectedTierIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        title: AppText(
          l10n.kyc_upgrade_title,
          variant: AppTextVariant.titleLarge,
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  if (widget.reason != null) ...[
                    _buildReasonCard(l10n),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  _buildCurrentTierCard(l10n),
                  const SizedBox(height: AppSpacing.xl),
                  AppText(
                    l10n.kyc_upgrade_selectTier,
                    variant: AppTextVariant.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  AppText(
                    l10n.kyc_upgrade_selectTier_description,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ..._buildTierCards(l10n),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildRequirementsList(l10n),
                  const SizedBox(height: AppSpacing.huge),
                ],
              ),
            ),
            _buildBottomBar(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonCard(AppLocalizations l10n) {
    final colors = context.colors;
    return AppCard(
      variant: AppCardVariant.elevated,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(Icons.info_outline, color: colors.warning),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  l10n.kyc_upgrade_reason_title,
                  variant: AppTextVariant.labelLarge,
                  color: colors.warningText,
                ),
                const SizedBox(height: AppSpacing.xs),
                AppText(widget.reason!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTierCard(AppLocalizations l10n) {
    final currentBenefits = _getTierBenefits(widget.currentTier);
    final colors = context.colors;

    return AppCard(
      variant: AppCardVariant.subtle,
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppText(
                l10n.kyc_upgrade_currentTier,
                variant: AppTextVariant.labelMedium,
                color: colors.textSecondary,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: colors.gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: AppText(
                  currentBenefits.name,
                  variant: AppTextVariant.labelSmall,
                  color: colors.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AppText(
            _formatLimit(currentBenefits.limits.dailyLimit, 'USDC'),
            variant: AppTextVariant.moneyMedium,
          ),
          AppText(
            l10n.kyc_upgrade_dailyLimit,
            variant: AppTextVariant.bodySmall,
            color: colors.textSecondary,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTierCards(AppLocalizations l10n) {
    final colors = context.colors;
    return _availableTiers.asMap().entries.map((entry) {
      final index = entry.key;
      final tier = entry.value;
      final isSelected = index == _selectedTierIndex;

      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: GestureDetector(
          onTap: () => setState(() => _selectedTierIndex = index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? colors.surface : Colors.transparent,
              border: Border.all(
                color: isSelected ? colors.gold : colors.border,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: isSelected ? colors.gold : colors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppText(
                        tier.name,
                        variant: AppTextVariant.titleLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (tier.tier == widget.targetTier) ...[
                      const SizedBox(width: AppSpacing.sm),
                      _buildRecommendedBadge(l10n),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                AppText(tier.description, color: colors.textSecondary),
                const SizedBox(height: AppSpacing.md),
                _buildLimitRow(
                  Icons.today,
                  l10n.kyc_upgrade_dailyLimit,
                  _formatLimit(tier.limits.dailyLimit, 'USDC'),
                ),
                const SizedBox(height: AppSpacing.xs),
                _buildLimitRow(
                  Icons.calendar_month,
                  l10n.kyc_upgrade_monthlyLimit,
                  _formatLimit(tier.limits.monthlyLimit, 'USDC'),
                ),
                const SizedBox(height: AppSpacing.xs),
                _buildLimitRow(
                  Icons.swap_horiz,
                  l10n.kyc_upgrade_perTransaction,
                  _formatLimit(tier.limits.perTransactionLimit, 'USDC'),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: tier.features
                      .take(3)
                      .map(_buildFeatureChip)
                      .toList(),
                ),
                if (tier.features.length > 3) ...[
                  const SizedBox(height: AppSpacing.xs),
                  AppText(
                    '+${tier.features.length - 3} ${l10n.kyc_upgrade_andMore}',
                    variant: AppTextVariant.bodySmall,
                    color: colors.textSecondary,
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildLimitRow(IconData icon, String label, String value) {
    final colors = context.colors;
    return Row(
      children: [
        Icon(icon, size: 16, color: colors.textSecondary),
        const SizedBox(width: AppSpacing.xs),
        AppText(
          label,
          variant: AppTextVariant.bodySmall,
          color: colors.textSecondary,
        ),
        const Spacer(),
        AppText(value, variant: AppTextVariant.labelMedium),
      ],
    );
  }

  Widget _buildFeatureChip(String feature) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs + 2,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.gold.withValues(alpha: colors.isDark ? 0.14 : 0.09),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: AppText(
        feature,
        variant: AppTextVariant.labelSmall,
        color: colors.gold,
      ),
    );
  }

  Widget _buildRecommendedBadge(AppLocalizations l10n) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.success.withValues(alpha: colors.isDark ? 0.12 : 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: AppText(
        l10n.kyc_upgrade_recommended,
        variant: AppTextVariant.labelSmall,
        color: colors.successText,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildRequirementsList(AppLocalizations l10n) {
    final selectedTier = _availableTiers[_selectedTierIndex];
    final colors = context.colors;
    final requirements = <String>[
      if (selectedTier.tier.level >= 1) ...[
        l10n.kyc_upgrade_requirement_idDocument,
        l10n.kyc_upgrade_requirement_selfie,
      ],
    ];

    if (selectedTier.requiresAddressProof) {
      requirements.add(l10n.kyc_upgrade_requirement_addressProof);
    }
    if (selectedTier.requiresVideoVerification) {
      requirements.add(l10n.kyc_upgrade_requirement_videoVerification);
    }
    if (selectedTier.requiresSourceOfFunds) {
      requirements.add(l10n.kyc_upgrade_requirement_sourceOfFunds);
    }

    return AppCard(
      variant: AppCardVariant.elevated,
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            l10n.kyc_upgrade_requirements_title,
            variant: AppTextVariant.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.md),
          ...requirements.map(
            (req) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 20,
                    color: colors.gold,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: AppText(req)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, AppLocalizations l10n) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton(
              label: l10n.kyc_upgrade_startVerification,
              onPressed: () => _handleStartUpgrade(context),
              isFullWidth: true,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => context.fsmPop(),
              child: AppText(
                l10n.common_maybeLater,
                variant: AppTextVariant.labelMedium,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleStartUpgrade(BuildContext context) {
    final selectedTier = _availableTiers[_selectedTierIndex];

    // Store target tier in provider
    ref.read(kycProvider.notifier).setTargetTier(selectedTier.tier);

    // Navigate based on requirements
    if (selectedTier.tier.level == 1) {
      // Standard KYC flow
      unawaited(context.fsmPush('/kyc/document-type'));
    } else if (selectedTier.requiresAddressProof &&
        !selectedTier.requiresVideoVerification) {
      // Tier 2 - Address verification
      unawaited(context.fsmPush('/kyc/address'));
    } else {
      // Tier 3 - Full verification
      unawaited(context.fsmPush('/kyc/address'));
    }
  }

  TierBenefits _getTierBenefits(KycTier tier) {
    switch (tier) {
      case KycTier.tier0:
        return TierBenefits.tier0();
      case KycTier.tier1:
        return TierBenefits.tier1();
      case KycTier.tier2:
        return TierBenefits.tier2();
      case KycTier.tier3:
        return TierBenefits.tier3();
    }
  }

  String _formatLimit(String amount, String currency) {
    final numAmount = int.tryParse(amount) ?? 0;
    if (numAmount >= 1000000) {
      return '${(numAmount / 1000000).toStringAsFixed(1)}M $currency';
    }
    if (numAmount >= 1000) {
      return '${(numAmount / 1000).toStringAsFixed(0)}K $currency';
    }
    return '$numAmount $currency';
  }
}
