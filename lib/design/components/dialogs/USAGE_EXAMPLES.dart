// ignore_for_file: unused_element, unused_local_variable, undefined_named_parameter, undefined_identifier, avoid_dynamic_calls, avoid_print

/// Dialog & Bottom Sheet Usage Examples
///
/// This file demonstrates all dialog and bottom sheet patterns.
/// Copy these patterns into your code as needed.

import 'package:flutter/material.dart';
import '../../tokens/index.dart';
import '../primitives/index.dart';
import 'index.dart';

class DialogUsageExamples extends StatelessWidget {
  const DialogUsageExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dialog Examples')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          // ═══════════════════════════════════════════════════════════════════
          // CONFIRMATION DIALOGS
          // ═══════════════════════════════════════════════════════════════════
          const SectionHeader(title: 'Confirmation Dialogs'),

          ExampleButton(
            label: 'Delete Confirmation',
            onPressed: () => _showDeleteConfirmation(context),
          ),

          ExampleButton(
            label: 'Generic Confirmation',
            onPressed: () => _showGenericConfirmation(context),
          ),

          ExampleButton(
            label: 'Non-Destructive Confirmation',
            onPressed: () => _showNonDestructiveConfirmation(context),
          ),

          ExampleButton(
            label: 'Confirmation with Details',
            onPressed: () => _showConfirmationWithDetails(context),
          ),

          const SizedBox(height: AppSpacing.xl),

          // ═══════════════════════════════════════════════════════════════════
          // ALERT DIALOGS
          // ═══════════════════════════════════════════════════════════════════
          const SectionHeader(title: 'Alert Dialogs'),

          ExampleButton(
            label: 'Success Alert',
            onPressed: () => _showSuccessAlert(context),
          ),

          ExampleButton(
            label: 'Error Alert',
            onPressed: () => _showErrorAlert(context),
          ),

          ExampleButton(
            label: 'Warning Alert',
            onPressed: () => _showWarningAlert(context),
          ),

          ExampleButton(
            label: 'Info Alert',
            onPressed: () => _showInfoAlert(context),
          ),

          const SizedBox(height: AppSpacing.xl),

          // ═══════════════════════════════════════════════════════════════════
          // GENERIC DIALOGS
          // ═══════════════════════════════════════════════════════════════════
          const SectionHeader(title: 'Generic Dialogs'),

          ExampleButton(
            label: 'Custom Dialog',
            onPressed: () => _showCustomDialog(context),
          ),

          ExampleButton(
            label: 'Dialog with Custom Icon',
            onPressed: () => _showCustomIconDialog(context),
          ),

          const SizedBox(height: AppSpacing.xl),

          // ═══════════════════════════════════════════════════════════════════
          // BOTTOM SHEETS
          // ═══════════════════════════════════════════════════════════════════
          const SectionHeader(title: 'Bottom Sheets'),

          ExampleButton(
            label: 'Simple Bottom Sheet',
            onPressed: () => _showSimpleBottomSheet(context),
          ),

          ExampleButton(
            label: 'Scrollable Bottom Sheet',
            onPressed: () => _showScrollableBottomSheet(context),
          ),

          ExampleButton(
            label: 'Full-Screen Bottom Sheet',
            onPressed: () => _showFullScreenBottomSheet(context),
          ),

          ExampleButton(
            label: 'Bottom Sheet with Close Button',
            onPressed: () => _showBottomSheetWithCloseButton(context),
          ),

          ExampleButton(
            label: 'Selection Bottom Sheet',
            onPressed: () => _showSelectionBottomSheet(context),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CONFIRMATION DIALOGS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final confirmed = await context.showDeleteConfirmation(
      title: 'Delete Transaction',
      message: 'This will permanently delete the transaction. This action cannot be undone.',
    );

    if (confirmed) {
      // Perform delete action
      debugPrint('Transaction deleted');
    }
  }

  Future<void> _showGenericConfirmation(BuildContext context) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Confirm Transfer',
      message: 'Are you sure you want to send \$500 to John Doe?',
      confirmText: 'Send',
      cancelText: 'Cancel',
      isDestructive: false,
    );

    if (confirmed) {
      debugPrint('Transfer confirmed');
    }
  }

  Future<void> _showNonDestructiveConfirmation(BuildContext context) async {
    final confirmed = await context.showConfirmation(
      title: 'Logout',
      message: 'Are you sure you want to logout from your account?',
      confirmText: 'Logout',
      isDestructive: false,
      icon: Icons.logout,
    );

    if (confirmed) {
      debugPrint('User logged out');
    }
  }

  Future<void> _showConfirmationWithDetails(BuildContext context) async {
    final colors = context.colors;

    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Confirm Payment',
      message: 'Please review the payment details before confirming.',
      confirmText: 'Confirm',
      details: Column(
        children: [
          _DetailRow('Amount', '\$1,250.00', colors),
          const SizedBox(height: AppSpacing.sm),
          _DetailRow('Recipient', 'John Doe', colors),
          const SizedBox(height: AppSpacing.sm),
          _DetailRow('Fee', '\$2.50', colors),
          const Divider(height: AppSpacing.lg),
          _DetailRow('Total', '\$1,252.50', colors, bold: true),
        ],
      ),
    );

    if (confirmed) {
      debugPrint('Payment confirmed');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ALERT DIALOGS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _showSuccessAlert(BuildContext context) async {
    await context.showSuccessAlert(
      title: 'Transfer Complete',
      message: 'Your payment of \$500 has been sent successfully to John Doe.',
    );
  }

  Future<void> _showErrorAlert(BuildContext context) async {
    await context.showErrorAlert(
      title: 'Transfer Failed',
      message: 'Insufficient balance. Please add funds and try again.',
    );
  }

  Future<void> _showWarningAlert(BuildContext context) async {
    await context.showWarningAlert(
      title: 'Verification Required',
      message: 'Your account requires KYC verification to continue. Please complete the verification process.',
    );
  }

  Future<void> _showInfoAlert(BuildContext context) async {
    await context.showInfoAlert(
      title: 'Scheduled Maintenance',
      message: 'The system will be under maintenance from 2:00 AM to 4:00 AM UTC.',
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GENERIC DIALOGS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _showCustomDialog(BuildContext context) async {
    await AppDialog.show(
      context,
      title: 'Rate Our App',
      message: 'Are you enjoying JoonaPay? Please take a moment to rate us on the App Store.',
      buttonText: 'Rate Now',
      type: DialogType.info,
    );
  }

  Future<void> _showCustomIconDialog(BuildContext context) async {
    await AppDialog.show(
      context,
      title: 'New Feature',
      message: 'Check out our new virtual card feature! Create unlimited virtual cards for online shopping.',
      buttonText: 'Learn More',
      type: DialogType.info,
      icon: Icons.credit_card,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BOTTOM SHEETS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _showSimpleBottomSheet(BuildContext context) async {
    await context.showBottomSheet(
      title: 'Account Information',
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const AppText('Account Name'),
            subtitle: const AppText('John Doe'),
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const AppText('Email'),
            subtitle: const AppText('john@example.com'),
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: const AppText('Phone'),
            subtitle: const AppText('+1 234 567 8900'),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Close',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> _showScrollableBottomSheet(BuildContext context) async {
    await context.showScrollableBottomSheet(
      title: 'Transaction History',
      initialChildSize: 0.6,
      builder: (context) => Column(
        children: List.generate(
          20,
          (index) => ListTile(
            leading: CircleAvatar(
              backgroundColor: context.colors.gold.withValues(alpha: 0.1),
              child: Icon(Icons.arrow_upward, color: context.colors.gold),
            ),
            title: AppText('Transaction #${index + 1}'),
            subtitle: AppText('${DateTime.now().subtract(Duration(days: index))}'),
            trailing: AppText('\$${(index + 1) * 10}'),
          ),
        ),
      ),
    );
  }

  Future<void> _showFullScreenBottomSheet(BuildContext context) async {
    await context.showFullScreenBottomSheet(
      title: 'Edit Profile',
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          children: [
            const AppInput(
              label: 'Full Name',
              initialValue: 'John Doe',
            ),
            const SizedBox(height: AppSpacing.md),
            const AppInput(
              label: 'Email',
              initialValue: 'john@example.com',
            ),
            const SizedBox(height: AppSpacing.md),
            const AppInput(
              label: 'Phone',
              initialValue: '+1 234 567 8900',
            ),
            const Spacer(),
            AppButton(
              label: 'Save Changes',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showBottomSheetWithCloseButton(BuildContext context) async {
    await context.showBottomSheet(
      title: 'Filter Options',
      showCloseButton: true,
      child: Column(
        children: [
          CheckboxListTile(
            title: const AppText('Show completed'),
            value: true,
            onChanged: (value) {},
          ),
          CheckboxListTile(
            title: const AppText('Show pending'),
            value: false,
            onChanged: (value) {},
          ),
          CheckboxListTile(
            title: const AppText('Show failed'),
            value: false,
            onChanged: (value) {},
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Apply Filters',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> _showSelectionBottomSheet(BuildContext context) async {
    final selected = await AppBottomSheet.show<String>(
      context,
      title: 'Select Country',
      child: Column(
        children: [
          _SelectionTile(
            title: 'Côte d\'Ivoire',
            icon: Icons.flag,
            onTap: () => Navigator.pop(context, 'CI'),
          ),
          _SelectionTile(
            title: 'Senegal',
            icon: Icons.flag,
            onTap: () => Navigator.pop(context, 'SN'),
          ),
          _SelectionTile(
            title: 'Mali',
            icon: Icons.flag,
            onTap: () => Navigator.pop(context, 'ML'),
          ),
          _SelectionTile(
            title: 'Burkina Faso',
            icon: Icons.flag,
            onTap: () => Navigator.pop(context, 'BF'),
          ),
        ],
      ),
    );

    if (selected != null) {
      debugPrint('Selected country: $selected');
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HELPER WIDGETS
// ═══════════════════════════════════════════════════════════════════════════

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppText(
        title,
        variant: AppTextVariant.titleMedium,
        color: context.colors.gold,
      ),
    );
  }
}

class ExampleButton extends StatelessWidget {
  const ExampleButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppButton(
        label: label,
        onPressed: onPressed,
        variant: AppAppButtonVariant.secondary,
        size: AppButtonSize.medium,
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(
    this.label,
    this.value,
    this.colors, {
    this.bold = false,
  });

  final String label;
  final String value;
  final ThemeColors colors;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          label,
          variant: bold ? AppTextVariant.labelLarge : AppTextVariant.bodyMedium,
          color: colors.textSecondary,
        ),
        AppText(
          value,
          variant: bold ? AppTextVariant.titleMedium : AppTextVariant.bodyMedium,
          color: colors.textPrimary,
        ),
      ],
    );
  }
}

class _SelectionTile extends StatelessWidget {
  const _SelectionTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.md,
        ),
        child: Row(
          children: [
            Icon(icon, color: colors.gold),
            const SizedBox(width: AppSpacing.md),
            AppText(title, variant: AppTextVariant.bodyLarge),
            const Spacer(),
            Icon(Icons.chevron_right, color: colors.textTertiary),
          ],
        ),
      ),
    );
  }
}
