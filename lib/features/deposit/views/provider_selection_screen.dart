import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../providers/deposit_provider.dart';
import '../models/mobile_money_provider.dart';

/// Provider Selection Screen
class ProviderSelectionScreen extends ConsumerStatefulWidget {
  const ProviderSelectionScreen({super.key});

  @override
  ConsumerState<ProviderSelectionScreen> createState() => _ProviderSelectionScreenState();
}

class _ProviderSelectionScreenState extends ConsumerState<ProviderSelectionScreen> {
  MobileMoneyProvider? _selectedProvider;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final depositState = ref.watch(depositProvider);

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          l10n.deposit_selectProvider,
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Amount Summary
                      _buildAmountSummary(depositState, colors, l10n),

                      const SizedBox(height: AppSpacing.xl),

                      AppText(
                        l10n.deposit_chooseProvider,
                        variant: AppTextVariant.titleMedium,
                        color: colors.textPrimary,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Provider Cards
                      ...MobileMoneyProvider.values.map((provider) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _ProviderCard(
                            provider: provider,
                            isSelected: _selectedProvider == provider,
                            onTap: () => setState(() => _selectedProvider = provider),
                            colors: colors,
                            l10n: l10n,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Continue Button
              AppButton(
                label: l10n.action_continue,
                onPressed: _selectedProvider != null ? _handleContinue : null,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountSummary(DepositState state, ThemeColors colors, AppLocalizations l10n) {
    return AppCard(
      variant: AppCardVariant.elevated,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                l10n.deposit_amountToPay,
                variant: AppTextVariant.labelMedium,
                color: colors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.xs),
              AppText(
                '${state.amountXOF.toStringAsFixed(0)} XOF',
                variant: AppTextVariant.titleLarge,
                color: colors.textPrimary,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppText(
                l10n.deposit_youWillReceive,
                variant: AppTextVariant.labelMedium,
                color: colors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.xs),
              AppText(
                '\$${state.amountUSD.toStringAsFixed(2)}',
                variant: AppTextVariant.titleLarge,
                color: colors.gold,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleContinue() {
    if (_selectedProvider == null) return;

    ref.read(depositProvider.notifier).setProvider(_selectedProvider!.id);
    ref.read(depositProvider.notifier).initiateDeposit();

    // Listen for response
    ref.listen(depositProvider, (prev, next) {
      if (next.response != null && next.error == null) {
        context.push('/deposit/instructions');
      } else if (next.error != null) {
        final errorColors = context.colors;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: errorColors.error,
          ),
        );
      }
    });
  }
}

class _ProviderCard extends StatelessWidget {
  const _ProviderCard({
    required this.provider,
    required this.isSelected,
    required this.onTap,
    required this.colors,
    required this.l10n,
  });

  final MobileMoneyProvider provider;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeColors colors;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        variant: AppCardVariant.elevated,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: isSelected
                ? Border.all(color: AppColors.gold500, width: 2)
                : null,
          ),
          child: Row(
            children: [
              // Provider Logo
              Container(
                width: 56,
                height: 56,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: _getProviderColor(provider).withValues(alpha: colors.isDark ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Center(
                  child: Icon(
                    _getProviderIcon(provider),
                    color: _getProviderColor(provider),
                    size: 32,
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.lg),

              // Provider Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      provider.name,
                      variant: AppTextVariant.bodyLarge,
                      color: colors.textPrimary,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    AppText(
                      provider.feePercentage == 0
                          ? l10n.deposit_noFee
                          : '${provider.feePercentage}% ${l10n.deposit_fee}',
                      variant: AppTextVariant.bodySmall,
                      color: provider.feePercentage == 0
                          ? colors.success
                          : colors.textTertiary,
                    ),
                  ],
                ),
              ),

              // Selection Indicator
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppColors.gold500,
                  size: 24,
                )
              else
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.borderSubtle, width: 2),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getProviderIcon(MobileMoneyProvider provider) {
    switch (provider) {
      case MobileMoneyProvider.orangeMoney:
        return Icons.phone_android;
      case MobileMoneyProvider.wave:
        return Icons.water_drop;
      case MobileMoneyProvider.mtnMomo:
        return Icons.signal_cellular_alt;
    }
  }

  Color _getProviderColor(MobileMoneyProvider provider) {
    switch (provider) {
      case MobileMoneyProvider.orangeMoney:
        return const Color(0xFFFF6600); // Orange
      case MobileMoneyProvider.wave:
        return const Color(0xFF00B8D4); // Blue (adjusted for better contrast)
      case MobileMoneyProvider.mtnMomo:
        return const Color(0xFFFFB300); // Yellow (adjusted for better contrast)
    }
  }
}
