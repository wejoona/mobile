import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/features/sub_business/providers/sub_business_provider.dart';
import 'package:usdc_wallet/features/sub_business/models/sub_business.dart';
import 'package:usdc_wallet/features/sub_business/widgets/staff_member_card.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

/// Screen for managing staff members of a sub-business
class SubBusinessStaffView extends ConsumerStatefulWidget {
  const SubBusinessStaffView({
    super.key,
    required this.subBusinessId,
  });

  final String subBusinessId;

  @override
  ConsumerState<SubBusinessStaffView> createState() =>
      _SubBusinessStaffViewState();
}

class _SubBusinessStaffViewState extends ConsumerState<SubBusinessStaffView> {
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
    final __subBusiness = state.subBusinesses.firstWhere(
      (sb) => sb.id == widget.subBusinessId,
    );
    final staff = state.staffBySubBusiness[widget.subBusinessId] ?? [];

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        title: AppText(
          l10n.subBusiness_staffTitle,
          variant: AppTextVariant.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(subBusinessProvider.notifier).loadStaff(widget.subBusinessId),
        color: context.colors.gold,
        backgroundColor: context.colors.container,
        child: staff.isEmpty
            ? _buildEmptyState(l10n)
            : _buildStaffList(staff, l10n),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddStaffDialog(l10n),
        backgroundColor: context.colors.gold,
        child: Icon(Icons.person_add, color: context.colors.canvas),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: context.colors.textSecondary,
            ),
            SizedBox(height: AppSpacing.md),
            AppText(
              l10n.subBusiness_noStaffTitle,
              variant: AppTextVariant.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
            AppText(
              l10n.subBusiness_noStaffMessage,
              variant: AppTextVariant.bodyMedium,
              color: context.colors.textSecondary,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),
            AppButton(
              label: l10n.subBusiness_addFirstStaff,
              onPressed: () => _showAddStaffDialog(l10n),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffList(List<StaffMember> staff, AppLocalizations l10n) {
    return ListView(
      padding: EdgeInsets.all(AppSpacing.md),
      children: [
        // Info card
        Container(
          decoration: BoxDecoration(
            color: context.colors.container,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: context.colors.gold.withValues(alpha: 0.2),
            ),
          ),
          padding: EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: context.colors.gold,
                size: 20,
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppText(
                  l10n.subBusiness_staffInfo,
                  variant: AppTextVariant.bodySmall,
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.lg),

        // Staff list
        AppText(
          '${staff.length} ${staff.length == 1 ? l10n.subBusiness_member : l10n.subBusiness_members}',
          variant: AppTextVariant.headlineSmall,
        ),
        SizedBox(height: AppSpacing.md),

        // Group staff by role
        ...staff
            .where((s) => s.role == StaffRole.owner)
            .map((member) => _buildStaffCard(member, l10n)),
        ...staff
            .where((s) => s.role == StaffRole.admin)
            .map((member) => _buildStaffCard(member, l10n)),
        ...staff
            .where((s) => s.role == StaffRole.viewer)
            .map((member) => _buildStaffCard(member, l10n)),
      ],
    );
  }

  Widget _buildStaffCard(StaffMember member, AppLocalizations l10n) {
    final currentUserId = ref.read(authProvider).user?.id;
    final isCurrentUser = member.userId == currentUserId;
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: StaffMemberCard(
        staff: member,
        isCurrentUser: isCurrentUser,
        onTap: isCurrentUser ? () {} : () => _showStaffOptions(member, l10n),
      ),
    );
  }

  Future<void> _showAddStaffDialog(AppLocalizations l10n) async {
    final phoneController = TextEditingController();
    StaffRole selectedRole = StaffRole.viewer;

    final __result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: context.colors.container,
          title: AppText(
            l10n.subBusiness_addStaffTitle,
            variant: AppTextVariant.headlineSmall,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppInput(
                label: l10n.subBusiness_phoneLabel,
                controller: phoneController,
                keyboardType: TextInputType.phone,
                hint: '+225 XX XX XX XX',
              ),
              SizedBox(height: AppSpacing.md),
              AppText(
                l10n.subBusiness_roleLabel,
                variant: AppTextVariant.bodyMedium,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: AppSpacing.sm),
              ...StaffRole.values.map((role) {
                return RadioListTile<StaffRole>(
                  title: AppText(
                    _getRoleLabel(role, l10n),
                    variant: AppTextVariant.bodyMedium,
                  ),
                  subtitle: AppText(
                    _getRoleDescription(role, l10n),
                    variant: AppTextVariant.bodySmall,
                    color: context.colors.textSecondary,
                  ),
                  value: role,
                  groupValue: selectedRole,
                  onChanged: (value) {
                    setState(() => selectedRole = value!);
                  },
                  activeColor: context.colors.gold,
                );
              }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: AppText(l10n.action_cancel),
            ),
            AppButton(
              label: l10n.subBusiness_inviteButton,
              onPressed: () async {
                if (phoneController.text.isEmpty) return;
                Navigator.pop(context, true);
                final success = await ref.read(subBusinessProvider.notifier).addStaff(
                      subBusinessId: widget.subBusinessId,
                      phoneNumber: phoneController.text,
                      role: selectedRole,
                    );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? l10n.subBusiness_inviteSuccess
                            : l10n.error_generic,
                      ),
                      backgroundColor: success ? context.colors.success : context.colors.error,
                    ),
                  );
                }
              },
              size: AppButtonSize.small,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showStaffOptions(StaffMember member, AppLocalizations l10n) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.elevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.textSecondary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: AppSpacing.md),
            AppText(
              member.name,
              variant: AppTextVariant.headlineSmall,
            ),
            SizedBox(height: AppSpacing.md),
            ListTile(
              leading: Icon(Icons.swap_horiz, color: context.colors.gold),
              title: AppText(l10n.subBusiness_changeRole),
              onTap: () {
                Navigator.pop(context);
                _showChangeRoleDialog(member, l10n);
              },
            ),
            ListTile(
              leading: Icon(Icons.person_remove, color: context.colors.error),
              title: AppText(
                l10n.subBusiness_removeStaff,
                color: context.colors.error,
              ),
              onTap: () {
                Navigator.pop(context);
                _showRemoveStaffDialog(member, l10n);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showChangeRoleDialog(
    StaffMember member,
    AppLocalizations l10n,
  ) async {
    StaffRole selectedRole = member.role;

    final __result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: context.colors.container,
          title: AppText(
            l10n.subBusiness_changeRoleTitle,
            variant: AppTextVariant.headlineSmall,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: StaffRole.values.map((role) {
              return RadioListTile<StaffRole>(
                title: AppText(
                  _getRoleLabel(role, l10n),
                  variant: AppTextVariant.bodyMedium,
                ),
                subtitle: AppText(
                  _getRoleDescription(role, l10n),
                  variant: AppTextVariant.bodySmall,
                  color: context.colors.textSecondary,
                ),
                value: role,
                groupValue: selectedRole,
                onChanged: (value) {
                  setState(() => selectedRole = value!);
                },
                activeColor: context.colors.gold,
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: AppText(l10n.action_cancel),
            ),
            AppButton(
              label: l10n.action_save,
              onPressed: () async {
                Navigator.pop(context, true);
                final success = await ref
                    .read(subBusinessProvider.notifier)
                    .updateStaffRole(
                      subBusinessId: widget.subBusinessId,
                      staffId: member.id,
                      newRole: selectedRole,
                    );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? l10n.subBusiness_roleUpdateSuccess
                            : l10n.error_generic,
                      ),
                      backgroundColor: success ? context.colors.success : context.colors.error,
                    ),
                  );
                }
              },
              size: AppButtonSize.small,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRemoveStaffDialog(
    StaffMember member,
    AppLocalizations l10n,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.elevated,
        title: AppText(
          l10n.subBusiness_removeStaffTitle,
          variant: AppTextVariant.headlineSmall,
        ),
        content: AppText(
          l10n.subBusiness_removeStaffConfirm,
          variant: AppTextVariant.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: AppText(l10n.action_cancel),
          ),
          AppButton(
            label: l10n.subBusiness_removeButton,
            onPressed: () => Navigator.pop(context, true),
            variant: AppButtonVariant.danger,
            size: AppButtonSize.small,
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ref.read(subBusinessProvider.notifier).removeStaff(
            subBusinessId: widget.subBusinessId,
            staffId: member.id,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? l10n.subBusiness_removeSuccess : l10n.error_generic,
            ),
            backgroundColor: success ? context.colors.success : context.colors.error,
          ),
        );
      }
    }
  }

  String _getRoleLabel(StaffRole role, AppLocalizations l10n) {
    switch (role) {
      case StaffRole.owner:
        return l10n.subBusiness_roleOwner;
      case StaffRole.admin:
        return l10n.subBusiness_roleAdmin;
      case StaffRole.viewer:
        return l10n.subBusiness_roleViewer;
    }
  }

  String _getRoleDescription(StaffRole role, AppLocalizations l10n) {
    switch (role) {
      case StaffRole.owner:
        return l10n.subBusiness_roleOwnerDesc;
      case StaffRole.admin:
        return l10n.subBusiness_roleAdminDesc;
      case StaffRole.viewer:
        return l10n.subBusiness_roleViewerDesc;
    }
  }
}
