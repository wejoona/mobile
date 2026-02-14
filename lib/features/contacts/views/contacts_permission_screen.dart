import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/contacts/providers/contacts_provider.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

/// Contacts Permission Screen
///
/// Explains why we need contacts and privacy assurances
class ContactsPermissionScreen extends ConsumerStatefulWidget {
  const ContactsPermissionScreen({super.key});

  @override
  ConsumerState<ContactsPermissionScreen> createState() =>
      _ContactsPermissionScreenState();
}

class _ContactsPermissionScreenState
    extends ConsumerState<ContactsPermissionScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.xl),

                      // Icon
                      Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: context.colors.gold.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.contacts,
                    size: 60,
                    color: context.colors.gold,
                  ),
                ),
              ),

              SizedBox(height: AppSpacing.xl),

              // Title
              AppText(
                l10n.contacts_permission_title,
                variant: AppTextVariant.headlineLarge,
                color: context.colors.textPrimary,
                textAlign: TextAlign.center,
              ),

              SizedBox(height: AppSpacing.md),

              // Subtitle
              AppText(
                l10n.contacts_permission_subtitle,
                variant: AppTextVariant.bodyLarge,
                color: context.colors.textSecondary,
                textAlign: TextAlign.center,
              ),

              SizedBox(height: AppSpacing.xxl),

              // Benefits
              _buildBenefit(
                context,
                l10n,
                Icons.people,
                l10n.contacts_permission_benefit1_title,
                l10n.contacts_permission_benefit1_desc,
              ),

              SizedBox(height: AppSpacing.md),

              _buildBenefit(
                context,
                l10n,
                Icons.lock,
                l10n.contacts_permission_benefit2_title,
                l10n.contacts_permission_benefit2_desc,
              ),

              SizedBox(height: AppSpacing.md),

              _buildBenefit(
                context,
                l10n,
                Icons.sync,
                l10n.contacts_permission_benefit3_title,
                l10n.contacts_permission_benefit3_desc,
              ),

                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ),

              // Allow button (fixed at bottom)
              AppButton(
                label: l10n.contacts_permission_allow,
                onPressed: _handleAllow,
                isLoading: _isLoading,
              ),

              SizedBox(height: AppSpacing.md),

              // Maybe later
              Center(
                child: TextButton(
                  onPressed: () => context.pop(),
                  child: AppText(
                    l10n.contacts_permission_later,
                    variant: AppTextVariant.bodyMedium,
                    color: context.colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefit(
    BuildContext context,
    AppLocalizations l10n,
    IconData icon,
    String title,
    String description,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: context.colors.elevated,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(
            icon,
            color: context.colors.gold,
            size: 20,
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                title,
                variant: AppTextVariant.bodyLarge,
                color: context.colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: AppSpacing.xs),
              AppText(
                description,
                variant: AppTextVariant.bodySmall,
                color: context.colors.textSecondary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleAllow() async {
    setState(() => _isLoading = true);

    try {
      final granted = await ref.read(contactsProvider.notifier).requestPermission();

      if (mounted) {
        if (granted) {
          context.go('/contacts/list');
        } else {
          // Show error dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: context.colors.container,
              title: AppText(
                AppLocalizations.of(context)!.contacts_permission_denied_title,
                variant: AppTextVariant.headlineSmall,
              ),
              content: AppText(
                AppLocalizations.of(context)!.contacts_permission_denied_message,
              ),
              actions: [
                AppButton(
                  label: AppLocalizations.of(context)!.action_cancel,
                  variant: AppButtonVariant.secondary,
                  size: AppButtonSize.small,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
