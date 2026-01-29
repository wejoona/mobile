import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../models/beneficiary.dart';
import '../providers/beneficiaries_provider.dart';

/// Beneficiary Detail View
///
/// Shows detailed information about a beneficiary
class BeneficiaryDetailView extends ConsumerWidget {
  const BeneficiaryDetailView({
    super.key,
    required this.beneficiaryId,
  });

  final String beneficiaryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(beneficiariesProvider);

    final beneficiary = state.beneficiaries.firstWhere(
      (b) => b.id == beneficiaryId,
      orElse: () => throw Exception('Beneficiary not found'),
    );

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: AppText(
          beneficiary.name,
          variant: AppTextVariant.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              beneficiary.isFavorite ? Icons.star : Icons.star_border,
              color: beneficiary.isFavorite ? AppColors.gold500 : AppColors.textSecondary,
            ),
            onPressed: () {
              ref.read(beneficiariesProvider.notifier).toggleFavorite(beneficiaryId);
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, ref, value, beneficiary, l10n),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: AppColors.textPrimary),
                    SizedBox(width: AppSpacing.sm),
                    AppText(l10n.beneficiaries_menuEdit),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: AppColors.errorBase),
                    SizedBox(width: AppSpacing.sm),
                    AppText(
                      l10n.beneficiaries_menuDelete,
                      color: AppColors.errorBase,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile section
              _buildProfileSection(context, beneficiary, l10n),
              SizedBox(height: AppSpacing.lg),

              // Account details
              _buildAccountDetailsSection(context, beneficiary, l10n),
              SizedBox(height: AppSpacing.lg),

              // Transfer statistics
              if (beneficiary.transferCount > 0)
                _buildStatisticsSection(context, beneficiary, l10n),

              SizedBox(height: AppSpacing.xl),

              // Action buttons
              AppButton(
                label: l10n.send_title,
                onPressed: () {
                  context.pop(beneficiary);
                  context.push('/send');
                },
                icon: Icons.send,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection(
    BuildContext context,
    Beneficiary beneficiary,
    AppLocalizations l10n,
  ) {
    return AppCard(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _getAccountTypeColor(beneficiary.accountType).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getAccountTypeIcon(beneficiary.accountType),
              size: 40,
              color: _getAccountTypeColor(beneficiary.accountType),
            ),
          ),
          SizedBox(height: AppSpacing.md),

          // Name
          AppText(
            beneficiary.name,
            variant: AppTextVariant.headlineMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.xs),

          // Account type badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: _getAccountTypeColor(beneficiary.accountType).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: AppText(
              _getAccountTypeLabel(beneficiary.accountType, l10n),
              variant: AppTextVariant.bodySmall,
              color: _getAccountTypeColor(beneficiary.accountType),
            ),
          ),

          // Verified badge
          if (beneficiary.isVerified) ...[
            SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified, size: 16, color: AppColors.successBase),
                SizedBox(width: AppSpacing.xs),
                AppText(
                  l10n.common_verified,
                  variant: AppTextVariant.bodySmall,
                  color: AppColors.successBase,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAccountDetailsSection(
    BuildContext context,
    Beneficiary beneficiary,
    AppLocalizations l10n,
  ) {
    return AppCard(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            l10n.beneficiaries_accountDetails,
            variant: AppTextVariant.bodyLarge,
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: AppSpacing.md),

          // Phone number (if available)
          if (beneficiary.phoneE164 != null)
            _buildDetailRow(
              l10n.beneficiaries_fieldPhone,
              beneficiary.phoneE164!,
              Icons.phone,
              copyable: true,
            ),

          // Account type specific fields
          ...switch (beneficiary.accountType) {
            AccountType.externalWallet => [
              if (beneficiary.beneficiaryWalletAddress != null)
                _buildDetailRow(
                  l10n.beneficiaries_fieldWalletAddress,
                  beneficiary.beneficiaryWalletAddress!,
                  Icons.account_balance_wallet,
                  copyable: true,
                ),
            ],
            AccountType.bankAccount => [
              if (beneficiary.bankCode != null)
                _buildDetailRow(
                  l10n.beneficiaries_fieldBankCode,
                  beneficiary.bankCode!,
                  Icons.account_balance,
                ),
              if (beneficiary.bankAccountNumber != null)
                _buildDetailRow(
                  l10n.beneficiaries_fieldBankAccount,
                  beneficiary.bankAccountNumber!,
                  Icons.numbers,
                  copyable: true,
                ),
            ],
            AccountType.mobileMoney => [
              if (beneficiary.mobileMoneyProvider != null)
                _buildDetailRow(
                  l10n.beneficiaries_fieldMobileMoneyProvider,
                  beneficiary.mobileMoneyProvider!,
                  Icons.phone_android,
                ),
            ],
            AccountType.joonapayUser => [],
          },
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(
    BuildContext context,
    Beneficiary beneficiary,
    AppLocalizations l10n,
  ) {
    return AppCard(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            l10n.beneficiaries_statistics,
            variant: AppTextVariant.bodyLarge,
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: AppSpacing.md),

          // Transfer count
          _buildStatRow(
            l10n.beneficiaries_totalTransfers,
            beneficiary.transferCount.toString(),
            Icons.repeat,
          ),

          // Total transferred
          _buildStatRow(
            l10n.beneficiaries_totalAmount,
            'XOF ${beneficiary.totalTransferred.toStringAsFixed(0)}',
            Icons.paid,
          ),

          // Last transfer
          if (beneficiary.lastTransferAt != null)
            _buildStatRow(
              l10n.beneficiaries_lastTransfer,
              _formatDate(beneficiary.lastTransferAt!),
              Icons.access_time,
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon, {
    bool copyable = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  label,
                  variant: AppTextVariant.bodySmall,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: AppSpacing.xs),
                AppText(
                  value,
                  variant: AppTextVariant.bodyMedium,
                ),
              ],
            ),
          ),
          if (copyable)
            IconButton(
              icon: Icon(Icons.copy, size: 20, color: AppColors.textSecondary),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.gold500),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: AppText(
              label,
              variant: AppTextVariant.bodyMedium,
            ),
          ),
          AppText(
            value,
            variant: AppTextVariant.bodyMedium,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }

  IconData _getAccountTypeIcon(AccountType type) {
    return switch (type) {
      AccountType.joonapayUser => Icons.person,
      AccountType.externalWallet => Icons.account_balance_wallet,
      AccountType.bankAccount => Icons.account_balance,
      AccountType.mobileMoney => Icons.phone_android,
    };
  }

  Color _getAccountTypeColor(AccountType type) {
    return switch (type) {
      AccountType.joonapayUser => AppColors.gold500,
      AccountType.externalWallet => AppColors.infoBase,
      AccountType.bankAccount => AppColors.successBase,
      AccountType.mobileMoney => AppColors.warningBase,
    };
  }

  String _getAccountTypeLabel(AccountType type, AppLocalizations l10n) {
    return switch (type) {
      AccountType.joonapayUser => l10n.beneficiaries_typeJoonapay,
      AccountType.externalWallet => l10n.beneficiaries_typeWallet,
      AccountType.bankAccount => l10n.beneficiaries_typeBank,
      AccountType.mobileMoney => l10n.beneficiaries_typeMobileMoney,
    };
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<void> _handleMenuAction(
    BuildContext context,
    WidgetRef ref,
    String action,
    Beneficiary beneficiary,
    AppLocalizations l10n,
  ) async {
    switch (action) {
      case 'edit':
        context.push('/beneficiaries/edit/${beneficiary.id}').then((_) {
          ref.read(beneficiariesProvider.notifier).loadBeneficiaries();
        });
        break;

      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.slate,
            title: AppText(
              l10n.beneficiaries_deleteTitle,
              variant: AppTextVariant.headlineSmall,
            ),
            content: AppText(
              l10n.beneficiaries_deleteMessage(beneficiary.name),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: AppText(l10n.common_cancel),
              ),
              AppButton(
                label: l10n.common_delete,
                onPressed: () => Navigator.pop(context, true),
                variant: AppButtonVariant.danger,
                size: AppButtonSize.small,
              ),
            ],
          ),
        );

        if (confirmed == true && context.mounted) {
          final success = await ref
              .read(beneficiariesProvider.notifier)
              .deleteBeneficiary(beneficiary.id);

          if (success && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: AppText(l10n.beneficiaries_deleteSuccess),
                backgroundColor: AppColors.successBase,
              ),
            );
            context.pop();
          }
        }
        break;
    }
  }
}
