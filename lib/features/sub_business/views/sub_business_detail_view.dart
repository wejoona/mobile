import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/features/sub_business/providers/sub_business_provider.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';
import 'package:usdc_wallet/utils/currency_utils.dart';

/// Screen showing details of a single sub-business
class SubBusinessDetailView extends ConsumerStatefulWidget {
  const SubBusinessDetailView({
    super.key,
    required this.subBusinessId,
  });

  final String subBusinessId;

  @override
  ConsumerState<SubBusinessDetailView> createState() =>
      _SubBusinessDetailViewState();
}

class _SubBusinessDetailViewState extends ConsumerState<SubBusinessDetailView> {
  @override
  void initState() {
    super.initState();
    // Load staff members on mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(subBusinessProvider.notifier).loadStaff(widget.subBusinessId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(subBusinessProvider);
    final subBusiness = state.subBusinesses.firstWhere(
      (sb) => sb.id == widget.subBusinessId,
    );
    final staff = state.staffBySubBusiness[widget.subBusinessId] ?? [];

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        title: AppText(
          subBusiness.name,
          variant: AppTextVariant.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showOptionsMenu(context, l10n),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(AppSpacing.md),
        children: [
          // Balance card
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.colors.gold,
                  context.colors.gold.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  l10n.subBusiness_balance,
                  variant: AppTextVariant.bodyLarge,
                  color: context.colors.canvas,
                ),
                SizedBox(height: AppSpacing.xs),
                AppText(
                  formatXof(subBusiness.balance),
                  variant: AppTextVariant.displaySmall,
                  color: context.colors.canvas,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.lg),

          // Quick actions
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: l10n.subBusiness_transfer,
                  icon: Icons.swap_horiz,
                  variant: AppButtonVariant.secondary,
                  onPressed: () => context.push('/sub-businesses/transfer/${widget.subBusinessId}'),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppButton(
                  label: l10n.subBusiness_transactions,
                  icon: Icons.receipt_long,
                  variant: AppButtonVariant.secondary,
                  onPressed: () => _showTransactions(context),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),

          // Info section
          _buildInfoSection(l10n, subBusiness),
          SizedBox(height: AppSpacing.lg),

          // Staff section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                l10n.subBusiness_staff,
                variant: AppTextVariant.headlineSmall,
              ),
              AppButton(
                label: l10n.subBusiness_manageStaff,
                icon: Icons.people,
                variant: AppButtonVariant.ghost,
                size: AppButtonSize.small,
                onPressed: () => context.push('/sub-businesses/${widget.subBusinessId}/staff'),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),

          if (staff.isEmpty)
            _buildEmptyStaff(l10n)
          else
            ...staff.take(3).map((member) {
              return Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                child: Container(
                  decoration: BoxDecoration(
                    color: context.colors.container,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: context.colors.gold.withValues(alpha: 0.2),
                        child: AppText(
                          member.name.substring(0, 1).toUpperCase(),
                          variant: AppTextVariant.bodyLarge,
                          color: context.colors.gold,
                        ),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              member.name,
                              variant: AppTextVariant.bodyLarge,
                              fontWeight: FontWeight.w600,
                            ),
                            AppText(
                              _getRoleLabel(member.role, l10n),
                              variant: AppTextVariant.bodySmall,
                              color: context.colors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

          if (staff.length > 3) ...[
            SizedBox(height: AppSpacing.sm),
            AppButton(
              label: l10n.subBusiness_viewAllStaff,
              onPressed: () => context.push('/sub-businesses/${widget.subBusinessId}/staff'),
              variant: AppButtonVariant.secondary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoSection(l10n, subBusiness) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.container,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            // ignore: avoid_dynamic_calls
            l10n.subBusiness_information,
            variant: AppTextVariant.headlineSmall,
          ),
          SizedBox(height: AppSpacing.md),
          // ignore: avoid_dynamic_calls
          _buildInfoRow(l10n.subBusiness_type, _getTypeLabel(subBusiness.type, l10n)),
          // ignore: avoid_dynamic_calls
          if (subBusiness.description != null) ...[
            SizedBox(height: AppSpacing.sm),
            // ignore: avoid_dynamic_calls
            _buildInfoRow(l10n.subBusiness_description, subBusiness.description!),
          ],
          SizedBox(height: AppSpacing.sm),
          _buildInfoRow(
            // ignore: avoid_dynamic_calls
            l10n.subBusiness_created,
            // ignore: avoid_dynamic_calls
            DateFormat.yMMMd().format(subBusiness.createdAt),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: AppText(
            label,
            variant: AppTextVariant.bodySmall,
            color: context.colors.textSecondary,
          ),
        ),
        Expanded(
          child: AppText(
            value,
            variant: AppTextVariant.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyStaff(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.container,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      padding: EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Icon(
            Icons.people_outline,
            size: 48,
            color: context.colors.textSecondary,
          ),
          SizedBox(height: AppSpacing.sm),
          AppText(
            l10n.subBusiness_noStaff,
            variant: AppTextVariant.bodyMedium,
            color: context.colors.textSecondary,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.md),
          AppButton(
            label: l10n.subBusiness_addFirstStaff,
            onPressed: () => context.push('/sub-businesses/${widget.subBusinessId}/staff'),
            variant: AppButtonVariant.secondary,
            size: AppButtonSize.small,
          ),
        ],
      ),
    );
  }

  String _getTypeLabel(type, AppLocalizations l10n) {
    switch (type.toString().split('.').last) {
      case 'department':
        return l10n.subBusiness_typeDepartment;
      case 'branch':
        return l10n.subBusiness_typeBranch;
      case 'subsidiary':
        return l10n.subBusiness_typeSubsidiary;
      case 'team':
        return l10n.subBusiness_typeTeam;
      default:
        return type.toString();
    }
  }

  String _getRoleLabel(role, AppLocalizations l10n) {
    switch (role.toString().split('.').last) {
      case 'owner':
        return l10n.subBusiness_roleOwner;
      case 'admin':
        return l10n.subBusiness_roleAdmin;
      case 'viewer':
        return l10n.subBusiness_roleViewer;
      default:
        return role.toString();
    }
  }

  void _showOptionsMenu(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(l10n.action_edit),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/sub-businesses/${widget.subBusinessId}/edit');
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: Text(l10n.subBusiness_manageStaff),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/sub-businesses/${widget.subBusinessId}/staff');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactions(BuildContext context) {
    context.push('/sub-businesses/${widget.subBusinessId}/transactions');
  }
}
