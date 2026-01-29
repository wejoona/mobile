import 'package:flutter/material.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/app_text.dart';
import '../models/sub_business.dart';

/// Card widget displaying a staff member
class StaffMemberCard extends StatelessWidget {
  const StaffMemberCard({
    super.key,
    required this.staff,
    required this.onTap,
    this.isCurrentUser = false,
  });

  final StaffMember staff;
  final VoidCallback onTap;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.slate,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        padding: EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: _getRoleColor(staff.role).withOpacity(0.2),
              child: AppText(
                staff.name.substring(0, 1).toUpperCase(),
                variant: AppTextVariant.bodyLarge,
                color: _getRoleColor(staff.role),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: AppSpacing.md),

            // Name and phone
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AppText(
                        staff.name,
                        variant: AppTextVariant.bodyLarge,
                        fontWeight: FontWeight.w600,
                      ),
                      if (isCurrentUser) ...[
                        SizedBox(width: AppSpacing.xs),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.gold500.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: AppText(
                            'You',
                            variant: AppTextVariant.bodySmall,
                            color: AppColors.gold500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: AppSpacing.xxs),
                  AppText(
                    staff.phoneNumber,
                    variant: AppTextVariant.bodySmall,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),

            // Role badge
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: _getRoleColor(staff.role).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(
                  color: _getRoleColor(staff.role).withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getRoleIcon(staff.role),
                    size: 14,
                    color: _getRoleColor(staff.role),
                  ),
                  SizedBox(width: AppSpacing.xs),
                  AppText(
                    _getRoleLabel(staff.role),
                    variant: AppTextVariant.bodySmall,
                    color: _getRoleColor(staff.role),
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(StaffRole role) {
    switch (role) {
      case StaffRole.owner:
        return AppColors.gold500;
      case StaffRole.admin:
        return AppColors.success;
      case StaffRole.viewer:
        return AppColors.textSecondary;
    }
  }

  IconData _getRoleIcon(StaffRole role) {
    switch (role) {
      case StaffRole.owner:
        return Icons.star;
      case StaffRole.admin:
        return Icons.admin_panel_settings;
      case StaffRole.viewer:
        return Icons.visibility;
    }
  }

  String _getRoleLabel(StaffRole role) {
    switch (role) {
      case StaffRole.owner:
        return 'Owner';
      case StaffRole.admin:
        return 'Admin';
      case StaffRole.viewer:
        return 'Viewer';
    }
  }
}
