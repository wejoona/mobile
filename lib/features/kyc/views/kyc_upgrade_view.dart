import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/design/tokens/colors.dart';
import 'package:usdc_wallet/design/tokens/spacing.dart';
import 'package:usdc_wallet/design/tokens/typography.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';
import 'package:usdc_wallet/design/components/primitives/app_button.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/design/components/primitives/app_card.dart';
import 'package:usdc_wallet/features/kyc/models/kyc_tier.dart';
import 'package:usdc_wallet/features/kyc/providers/kyc_provider.dart';

class KycUpgradeView extends ConsumerStatefulWidget {
  final KycTier currentTier;
  final KycTier targetTier;
  final String? reason;

  const KycUpgradeView({
    super.key,
    required this.currentTier,
    required this.targetTier,
    this.reason,
  });

  @override
  ConsumerState<KycUpgradeView> createState() => _KycUpgradeViewState();
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
    if (_selectedTierIndex == -1) _selectedTierIndex = 0;
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
          variant: AppTextVariant.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(AppSpacing.md),
                children: [
                  if (widget.reason != null) ...[
                    _buildReasonCard(l10n),
                    SizedBox(height: AppSpacing.lg),
                  ],
                  _buildCurrentTierCard(l10n),
                  SizedBox(height: AppSpacing.xxl),
                  AppText(
                    l10n.kyc_upgrade_selectTier,
                    variant: AppTextVariant.headlineSmall,
                  ),
                  SizedBox(height: AppSpacing.md),
                  AppText(
                    l10n.kyc_upgrade_selectTier_description,
                    variant: AppTextVariant.bodyMedium,
                    color: colors.textSecondary,
                  ),
                  SizedBox(height: AppSpacing.lg),
                  ..._buildTierCards(l10n),
                  SizedBox(height: AppSpacing.xxl),
                  _buildRequirementsList(l10n),
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
              color: colors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(Icons.info_outline, color: colors.warning),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  l10n.kyc_upgrade_reason_title,
                  variant: AppTextVariant.labelLarge,
                  color: colors.warningText,
                ),
                SizedBox(height: AppSpacing.xs),
                AppText(
                  widget.reason!,
                  variant: AppTextVariant.bodyMedium,
                ),
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
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: colors.gold.withOpacity(0.1),
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
          SizedBox(height: AppSpacing.sm),
          AppText(
            _formatLimit(currentBenefits.limits.dailyLimit, 'XOF'),
            variant: AppTextVariant.headlineMedium,
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
        padding: EdgeInsets.only(bottom: AppSpacing.md),
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
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: isSelected ? colors.gold : colors.textSecondary,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    AppText(
                      tier.name,
                      variant: AppTextVariant.headlineSmall,
                    ),
                    const Spacer(),
                    if (tier.tier == widget.targetTier)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: colors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: AppText(
                          l10n.kyc_upgrade_recommended,
                          variant: AppTextVariant.labelSmall,
                          color: colors.successText,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: AppSpacing.sm),
                AppText(
                  tier.description,
                  variant: AppTextVariant.bodyMedium,
                  color: colors.textSecondary,
                ),
                SizedBox(height: AppSpacing.md),
                _buildLimitRow(
                  Icons.today,
                  l10n.kyc_upgrade_dailyLimit,
                  _formatLimit(tier.limits.dailyLimit, 'XOF'),
                ),
                SizedBox(height: AppSpacing.xs),
                _buildLimitRow(
                  Icons.calendar_month,
                  l10n.kyc_upgrade_monthlyLimit,
                  _formatLimit(tier.limits.monthlyLimit, 'XOF'),
                ),
                SizedBox(height: AppSpacing.xs),
                _buildLimitRow(
                  Icons.swap_horiz,
                  l10n.kyc_upgrade_perTransaction,
                  _formatLimit(tier.limits.perTransactionLimit, 'XOF'),
                ),
                SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: tier.features
                      .take(4)
                      .map((feature) => _buildFeatureChip(feature))
                      .toList(),
                ),
                if (tier.features.length > 4) ...[
                  SizedBox(height: AppSpacing.xs),
                  AppText(
                    '+${tier.features.length - 4} ${l10n.kyc_upgrade_andMore}',
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
        SizedBox(width: AppSpacing.xs),
        AppText(
          label,
          variant: AppTextVariant.bodySmall,
          color: colors.textSecondary,
        ),
        const Spacer(),
        AppText(
          value,
          variant: AppTextVariant.labelMedium,
        ),
      ],
    );
  }

  Widget _buildFeatureChip(String feature) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.gold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: AppText(
        feature,
        variant: AppTextVariant.bodySmall,
        color: colors.gold,
      ),
    );
  }

  Widget _buildRequirementsList(AppLocalizations l10n) {
    final selectedTier = _availableTiers[_selectedTierIndex];
    final colors = context.colors;
    final requirements = <String>[];

    if (selectedTier.tier.level >= 1) {
      requirements.add(l10n.kyc_upgrade_requirement_idDocument);
      requirements.add(l10n.kyc_upgrade_requirement_selfie);
    }
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            l10n.kyc_upgrade_requirements_title,
            variant: AppTextVariant.headlineSmall,
          ),
          SizedBox(height: AppSpacing.md),
          ...requirements.map((req) => Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 20,
                      color: colors.gold,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppText(
                        req,
                        variant: AppTextVariant.bodyMedium,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, AppLocalizations l10n) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(color: colors.border),
        ),
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
            SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => context.pop(),
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
      context.push('/kyc/document-type');
    } else if (selectedTier.requiresAddressProof && !selectedTier.requiresVideoVerification) {
      // Tier 2 - Address verification
      context.push('/kyc/address');
    } else {
      // Tier 3 - Full verification
      context.push('/kyc/address');
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
    } else if (numAmount >= 1000) {
      return '${(numAmount / 1000).toStringAsFixed(0)}K $currency';
    }
    return '$numAmount $currency';
  }
}
