/// RTL-Compatible UI Examples
///
/// This file demonstrates how to build RTL-ready widgets for JoonaPay.
/// Use these as templates when creating new screens.

import 'package:flutter/material.dart';
import '../rtl_support.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';

// ═══════════════════════════════════════════════════════════════════════════
// EXAMPLE 1: Simple List Item with Icon and Chevron
// ═══════════════════════════════════════════════════════════════════════════

class RTLListItemExample extends StatelessWidget {
  const RTLListItemExample({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return DirectionalListTile(
      leading: Icon(icon, color: context.colors.gold),
      title: AppText(title, variant: AppTextVariant.bodyLarge),
      trailing: Icon(
        context.isRTL ? Icons.chevron_left : Icons.chevron_right,
        color: context.colors.textSecondary,
      ),
      onTap: onTap,
      contentPadding: EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// EXAMPLE 2: Transaction Row (Amount + Details)
// ═══════════════════════════════════════════════════════════════════════════

class RTLTransactionRowExample extends StatelessWidget {
  const RTLTransactionRowExample({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isPositive,
  });

  final String title;
  final String subtitle;
  final double amount;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsetsDirectional.all(AppSpacing.md),
      child: DirectionalRow(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side (or right in RTL): Transaction details
          Expanded(
            child: Column(
              crossAxisAlignment: context.isRTL
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  variant: AppTextVariant.bodyLarge,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: AppSpacing.xs),
                AppText(
                  subtitle,
                  variant: AppTextVariant.bodySmall,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.md),
          // Right side (or left in RTL): Amount
          AppText(
            '${isPositive ? '+' : '-'}\$${amount.toStringAsFixed(2)}',
            variant: AppTextVariant.bodyLarge,
            fontWeight: FontWeight.w700,
            color: isPositive ? AppColors.successBase : colors.textPrimary,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// EXAMPLE 3: Form with Label and Input
// ═══════════════════════════════════════════════════════════════════════════

class RTLFormFieldExample extends StatelessWidget {
  const RTLFormFieldExample({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.keyboardType,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: context.isRTL
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        AppText(
          label,
          variant: AppTextVariant.labelMedium,
          color: context.colors.textSecondary,
        ),
        SizedBox(height: AppSpacing.sm),
        AppInput(
          controller: controller,
          hint: hint,
          keyboardType: keyboardType,
          // AppInput should handle RTL internally
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// EXAMPLE 4: Card with Icon and Action Button
// ═══════════════════════════════════════════════════════════════════════════

class RTLActionCardExample extends StatelessWidget {
  const RTLActionCardExample({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.actionLabel,
    this.onAction,
  });

  final String title;
  final String description;
  final IconData icon;
  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      variant: AppCardVariant.elevated,
      padding: EdgeInsetsDirectional.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: context.isRTL
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          DirectionalRow(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.gold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: colors.gold),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: context.isRTL
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    AppText(
                      title,
                      variant: AppTextVariant.titleMedium,
                    ),
                    SizedBox(height: AppSpacing.xs),
                    AppText(
                      description,
                      variant: AppTextVariant.bodySmall,
                      color: colors.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          Align(
            alignment: context.alignEnd,
            child: AppButton(
              label: actionLabel,
              onPressed: onAction,
              variant: AppButtonVariant.secondary,
              size: AppButtonSize.small,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// EXAMPLE 5: Header with Back Button
// ═══════════════════════════════════════════════════════════════════════════

class RTLHeaderExample extends StatelessWidget {
  const RTLHeaderExample({
    super.key,
    required this.title,
    this.onBack,
    this.actions,
  });

  final String title;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.all(AppSpacing.md),
      child: DirectionalRow(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button (auto-positions based on direction)
          IconButton(
            icon: Icon(RTLSupport.arrowBack(context)),
            onPressed: onBack,
            color: context.colors.textPrimary,
          ),
          // Title
          Expanded(
            child: AppText(
              title,
              variant: AppTextVariant.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
          // Actions (or placeholder to maintain centering)
          if (actions != null && actions!.isNotEmpty)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: actions!,
            )
          else
            SizedBox(width: 48), // Match back button width
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// EXAMPLE 6: Two-Column Layout (Responsive)
// ═══════════════════════════════════════════════════════════════════════════

class RTLTwoColumnExample extends StatelessWidget {
  const RTLTwoColumnExample({
    super.key,
    required this.leftChild,
    required this.rightChild,
  });

  final Widget leftChild;
  final Widget rightChild;

  @override
  Widget build(BuildContext context) {
    return DirectionalRow(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // In RTL, these will be reversed automatically
        Expanded(child: leftChild),
        SizedBox(width: AppSpacing.lg),
        Expanded(child: rightChild),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// EXAMPLE 7: Detail Row (Label: Value)
// ═══════════════════════════════════════════════════════════════════════════

class RTLDetailRowExample extends StatelessWidget {
  const RTLDetailRowExample({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsetsDirectional.symmetric(
        vertical: AppSpacing.sm,
      ),
      child: DirectionalRow(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            label,
            variant: AppTextVariant.bodyMedium,
            color: colors.textSecondary,
          ),
          AppText(
            value,
            variant: AppTextVariant.bodyMedium,
            fontWeight: FontWeight.w600,
            color: valueColor ?? colors.textPrimary,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// EXAMPLE 8: Search Bar with Icon
// ═══════════════════════════════════════════════════════════════════════════

class RTLSearchBarExample extends StatelessWidget {
  const RTLSearchBarExample({
    super.key,
    this.controller,
    this.hint = 'Search...',
    this.onChanged,
  });

  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return AppInput(
      controller: controller,
      hint: hint,
      variant: AppInputVariant.search,
      prefixIcon: Icons.search,
      onChanged: onChanged,
      // Icon position will be handled by AppInput
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// EXAMPLE 9: Status Badge (Positioned)
// ═══════════════════════════════════════════════════════════════════════════

class RTLStatusBadgeExample extends StatelessWidget {
  const RTLStatusBadgeExample({
    super.key,
    required this.child,
    this.showBadge = false,
  });

  final Widget child;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (showBadge)
          PositionedDirectional(
            top: 0,
            end: 0, // Will be right in LTR, left in RTL
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.errorBase,
                shape: BoxShape.circle,
                border: Border.all(
                  color: context.colors.canvas,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// EXAMPLE 10: Complete Screen Template
// ═══════════════════════════════════════════════════════════════════════════

class RTLScreenTemplate extends StatelessWidget {
  const RTLScreenTemplate({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(RTLSupport.arrowBack(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: AppText(
          'RTL Screen Example',
          variant: AppTextVariant.titleLarge,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsetsDirectional.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: context.isRTL
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              // Header text
              AppText(
                'Welcome',
                variant: AppTextVariant.displaySmall,
              ),
              SizedBox(height: AppSpacing.sm),
              AppText(
                'This screen demonstrates RTL-compatible layouts',
                variant: AppTextVariant.bodyMedium,
                color: colors.textSecondary,
              ),
              SizedBox(height: AppSpacing.xxl),

              // List items
              RTLListItemExample(
                icon: Icons.wallet,
                title: 'Wallet',
                onTap: () {},
              ),
              RTLListItemExample(
                icon: Icons.send,
                title: 'Send Money',
                onTap: () {},
              ),
              RTLListItemExample(
                icon: Icons.settings,
                title: 'Settings',
                onTap: () {},
              ),

              SizedBox(height: AppSpacing.xxl),

              // Transaction examples
              AppText(
                'Recent Transactions',
                variant: AppTextVariant.titleMedium,
              ),
              SizedBox(height: AppSpacing.md),
              RTLTransactionRowExample(
                title: 'Payment Received',
                subtitle: 'From: John Doe',
                amount: 150.00,
                isPositive: true,
              ),
              RTLTransactionRowExample(
                title: 'Transfer Sent',
                subtitle: 'To: Jane Smith',
                amount: 75.50,
                isPositive: false,
              ),

              SizedBox(height: AppSpacing.xxl),

              // Action card
              RTLActionCardExample(
                icon: Icons.card_giftcard,
                title: 'Invite Friends',
                description: 'Earn rewards when friends join',
                actionLabel: 'Invite Now',
                onAction: () {},
              ),

              SizedBox(height: AppSpacing.xxl),

              // Detail rows
              AppText(
                'Account Details',
                variant: AppTextVariant.titleMedium,
              ),
              SizedBox(height: AppSpacing.md),
              AppCard(
                variant: AppCardVariant.elevated,
                child: Column(
                  children: [
                    RTLDetailRowExample(
                      label: 'Account Number',
                      value: '1234567890',
                    ),
                    Divider(color: colors.borderSubtle),
                    RTLDetailRowExample(
                      label: 'Balance',
                      value: '\$1,234.56',
                      valueColor: AppColors.gold500,
                    ),
                    Divider(color: colors.borderSubtle),
                    RTLDetailRowExample(
                      label: 'Status',
                      value: 'Active',
                      valueColor: AppColors.successBase,
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppSpacing.xxl),

              // Bottom action button
              AppButton(
                label: 'Continue',
                onPressed: () {},
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// USAGE IN YOUR SCREENS
// ═══════════════════════════════════════════════════════════════════════════

/*

Import these utilities:

```dart
import 'package:usdc_wallet/core/rtl/rtl_support.dart';
```

Then use the extension methods and widgets:

```dart
class MyView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: context.isRTL
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start,
      children: [
        DirectionalRow(
          children: [
            Icon(RTLSupport.arrowForward(context)),
            Text('Next'),
          ],
        ),
      ],
    );
  }
}
```

*/
