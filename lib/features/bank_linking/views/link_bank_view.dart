/// Link Bank View
library;
import 'package:usdc_wallet/design/tokens/index.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/design/tokens/spacing.dart';
import 'package:usdc_wallet/design/tokens/typography.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/design/components/primitives/app_input.dart';
import 'package:usdc_wallet/design/components/primitives/app_button.dart';
import 'package:usdc_wallet/features/bank_linking/providers/bank_linking_provider.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

class LinkBankView extends ConsumerStatefulWidget {
  const LinkBankView({super.key});

  @override
  ConsumerState<LinkBankView> createState() => _LinkBankViewState();
}

class _LinkBankViewState extends ConsumerState<LinkBankView> {
  final _formKey = GlobalKey<FormState>();
  final _accountNumberController = TextEditingController();
  final _accountHolderNameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _accountNumberController.dispose();
    _accountHolderNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(bankLinkingProvider);
    final selectedBank = state.selectedBank;

    if (selectedBank == null) {
      // Should not happen, but handle it
      Future.microtask(() => context.pop());
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        title: AppText(
          l10n.bankLinking_linkAccount,
          style: AppTypography.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(AppSpacing.md),
                  children: [
                    // Selected bank display
                    _buildSelectedBankCard(selectedBank),
                    SizedBox(height: AppSpacing.xl),
                    // Form fields
                    AppText(
                      l10n.bankLinking_accountDetails,
                      style: AppTypography.headlineSmall,
                    ),
                    SizedBox(height: AppSpacing.md),
                    AppInput(
                      label: l10n.bankLinking_accountNumber,
                      controller: _accountNumberController,
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.bankLinking_accountNumberRequired;
                        }
                        return null;
                      },
                      hint: 'CI123456789012345',
                    ),
                    SizedBox(height: AppSpacing.md),
                    AppInput(
                      label: l10n.bankLinking_accountHolderName,
                      controller: _accountHolderNameController,
                      keyboardType: TextInputType.name,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.bankLinking_accountHolderNameRequired;
                        }
                        return null;
                      },
                      hint: 'Jean Kouassi',
                    ),
                    SizedBox(height: AppSpacing.lg),
                    // Info box
                    _buildInfoBox(l10n),
                  ],
                ),
              ),
              _buildBottomButton(l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedBankCard(bank) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.container,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: context.colors.elevated,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Center(
              child: AppText(
                bank.name.substring(0, 1),
                style: AppTypography.headlineSmall.copyWith(
                  color: context.colors.gold,
                ),
              ),
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  bank.name,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                AppText(
                  bank.country,
                  style: AppTypography.bodySmall.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.gold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: context.colors.gold.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: context.colors.gold,
            size: 20,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  l10n.bankLinking_verificationRequired,
                  style: AppTypography.bodySmall.copyWith(
                    color: context.colors.gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                AppText(
                  l10n.bankLinking_verificationDesc,
                  style: AppTypography.bodySmall.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
          top: BorderSide(
            color: context.colors.elevated,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: AppButton(
          label: l10n.common_continue,
          onPressed: _handleSubmit,
          isLoading: _isLoading,
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final success =
          await ref.read(bankLinkingProvider.notifier).linkBankAccount(
                accountNumber: _accountNumberController.text.trim(),
                accountHolderName: _accountHolderNameController.text.trim(),
              );

      if (!mounted) return;

      if (success) {
        // Navigate to verification
        context.push('/bank-linking/verify');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AppText(
              AppLocalizations.of(context)!.bankLinking_linkFailed,
              style: AppTypography.bodyMedium,
            ),
            backgroundColor: context.colors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
