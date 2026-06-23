import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/features/sub_business/models/sub_business.dart';
import 'package:usdc_wallet/features/sub_business/providers/sub_business_provider.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';
import 'package:usdc_wallet/utils/currency_utils.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

/// Screen showing details of a single sub-business
class SubBusinessDetailView extends ConsumerStatefulWidget {
  const SubBusinessDetailView({super.key, required this.subBusinessId});

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
      ref.read(subBusinessProvider.notifier).loadSubBusinesses();
      ref.read(subBusinessProvider.notifier).loadStaff(widget.subBusinessId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(subBusinessProvider);
    final subBusiness = _findSubBusiness(state);

    if (subBusiness == null) {
      return _buildUnavailableState(l10n, state);
    }

    final staff = state.staffBySubBusiness[widget.subBusinessId] ?? [];

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        title: AppText(subBusiness.name, variant: AppTextVariant.headlineSmall),
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
                  formatCurrency(subBusiness.balance, subBusiness.currency),
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
                  onPressed: () => context.fsmPush(
                    '/sub-businesses/transfer/${widget.subBusinessId}',
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppButton(
                  label: l10n.subBusiness_transactions,
                  icon: Icons.receipt_long,
                  variant: AppButtonVariant.secondary,
                  onPressed: null,
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
                onPressed: () => context.fsmPush(
                  '/sub-businesses/${widget.subBusinessId}/staff',
                ),
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
                      UserAvatar(
                        firstName: member.name.split(' ').first,
                        lastName: member.name.split(' ').length > 1
                            ? member.name.split(' ').last
                            : null,
                        size: 40,
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
              onPressed: () => context.fsmPush(
                '/sub-businesses/${widget.subBusinessId}/staff',
              ),
              variant: AppButtonVariant.secondary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUnavailableState(AppLocalizations l10n, SubBusinessState state) {
    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        title: AppText(
          l10n.subBusiness_title,
          variant: AppTextVariant.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: state.isLoading && state.subBusinesses.isEmpty
            ? CircularProgressIndicator(color: context.colors.gold)
            : Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.business_outlined,
                      size: 56,
                      color: context.colors.textSecondary,
                    ),
                    SizedBox(height: AppSpacing.md),
                    AppText(
                      l10n.subBusiness_emptyTitle,
                      variant: AppTextVariant.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    AppText(
                      state.error ?? l10n.subBusiness_emptyMessage,
                      variant: AppTextVariant.bodyMedium,
                      color: context.colors.textSecondary,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  SubBusiness? _findSubBusiness(SubBusinessState state) {
    for (final subBusiness in state.subBusinesses) {
      if (subBusiness.id == widget.subBusinessId) {
        return subBusiness;
      }
    }
    return null;
  }

  Widget _buildInfoSection(AppLocalizations l10n, SubBusiness subBusiness) {
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
            l10n.subBusiness_information,
            variant: AppTextVariant.headlineSmall,
          ),
          SizedBox(height: AppSpacing.md),
          _buildInfoRow(
            l10n.subBusiness_type,
            _getTypeLabel(subBusiness.type, l10n),
          ),
          if (subBusiness.description != null) ...[
            SizedBox(height: AppSpacing.sm),
            _buildInfoRow(
              l10n.subBusiness_description,
              subBusiness.description!,
            ),
          ],
          SizedBox(height: AppSpacing.sm),
          _buildInfoRow(
            l10n.subBusiness_created,
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
        Expanded(child: AppText(value, variant: AppTextVariant.bodyMedium)),
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
            onPressed: () => context.fsmPush(
              '/sub-businesses/${widget.subBusinessId}/staff',
            ),
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
              leading: const Icon(Icons.people),
              title: Text(l10n.subBusiness_manageStaff),
              onTap: () {
                Navigator.pop(ctx);
                context.fsmPush(
                  '/sub-businesses/${widget.subBusinessId}/staff',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
