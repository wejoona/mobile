import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../services/feature_flags/feature_flags_provider.dart';
import '../../../services/feature_flags/feature_flags_extensions.dart';

/// Services page - centralized view of all available services
/// Reduces home page clutter and provides organized access to features
class ServicesView extends ConsumerWidget {
  const ServicesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final flags = ref.watch(featureFlagsProvider);

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: colors.canvas,
        elevation: 0,
        title: AppText(
          'Services',
          variant: AppTextVariant.headlineSmall,
          color: colors.textPrimary,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Core Services
              _buildSectionHeader('Core Services', colors),
              const SizedBox(height: AppSpacing.md),
              _buildServicesGrid(context, _getCoreServices(flags), colors),

              const SizedBox(height: AppSpacing.xxl),

              // Financial Services
              if (_getFinancialServices(flags).isNotEmpty) ...[
                _buildSectionHeader('Financial Services', colors),
                const SizedBox(height: AppSpacing.md),
                _buildServicesGrid(context, _getFinancialServices(flags), colors),
                const SizedBox(height: AppSpacing.xxl),
              ],

              // Bill Payments & Top-ups
              if (_getBillServices(flags).isNotEmpty) ...[
                _buildSectionHeader('Bills & Payments', colors),
                const SizedBox(height: AppSpacing.md),
                _buildServicesGrid(context, _getBillServices(flags), colors),
                const SizedBox(height: AppSpacing.xxl),
              ],

              // Analytics & Tools
              if (_getToolsServices(flags).isNotEmpty) ...[
                _buildSectionHeader('Tools & Analytics', colors),
                const SizedBox(height: AppSpacing.md),
                _buildServicesGrid(context, _getToolsServices(flags), colors),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeColors colors) {
    return AppText(
      title,
      variant: AppTextVariant.labelMedium,
      color: colors.textSecondary,
    );
  }

  Widget _buildServicesGrid(BuildContext context, List<ServiceItem> services, ThemeColors colors) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.1,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return _ServiceCard(
          icon: service.icon,
          title: service.title,
          description: service.description,
          onTap: () => context.push(service.route),
          colors: colors,
        );
      },
    );
  }

  List<ServiceItem> _getCoreServices(Map<String, bool> flags) {
    final services = <ServiceItem>[];

    if (flags.canSend) {
      services.add(ServiceItem(
        icon: Icons.send,
        title: 'Send Money',
        description: 'Transfer to any wallet',
        route: '/send',
      ));
    }

    if (flags.canReceive) {
      services.add(ServiceItem(
        icon: Icons.call_received,
        title: 'Receive Money',
        description: 'Get your wallet address',
        route: '/receive',
      ));
    }

    if (flags.canRequestMoney) {
      services.add(ServiceItem(
        icon: Icons.qr_code,
        title: 'Request Money',
        description: 'Create payment request',
        route: '/request',
      ));
    }

    services.add(ServiceItem(
      icon: Icons.qr_code_scanner,
      title: 'Scan QR',
      description: 'Scan to pay or receive',
      route: '/scan',
    ));

    if (flags.canUseSavedRecipients) {
      services.add(ServiceItem(
        icon: Icons.people_outline,
        title: 'Recipients',
        description: 'Manage saved contacts',
        route: '/recipients',
      ));
    }

    if (flags.canScheduleTransfers) {
      services.add(ServiceItem(
        icon: Icons.schedule,
        title: 'Scheduled Transfers',
        description: 'Manage recurring payments',
        route: '/scheduled',
      ));
    }

    return services;
  }

  List<ServiceItem> _getFinancialServices(Map<String, bool> flags) {
    final services = <ServiceItem>[];

    if (flags.canUseVirtualCards) {
      services.add(ServiceItem(
        icon: Icons.credit_card,
        title: 'Virtual Card',
        description: 'Online shopping card',
        route: '/card',
      ));
    }

    if (flags.canSetSavingsGoals) {
      services.add(ServiceItem(
        icon: Icons.savings,
        title: 'Savings Goals',
        description: 'Track your savings',
        route: '/savings',
      ));
    }

    if (flags.canUseBudget) {
      services.add(ServiceItem(
        icon: Icons.pie_chart,
        title: 'Budget',
        description: 'Manage spending limits',
        route: '/budget',
      ));
    }

    if (flags.canUseCurrencyConverter) {
      services.add(ServiceItem(
        icon: Icons.currency_exchange,
        title: 'Currency Converter',
        description: 'Convert currencies',
        route: '/converter',
      ));
    }

    return services;
  }

  List<ServiceItem> _getBillServices(Map<String, bool> flags) {
    final services = <ServiceItem>[];

    if (flags.canPayBills) {
      services.add(ServiceItem(
        icon: Icons.receipt_long,
        title: 'Bill Payments',
        description: 'Pay utility bills',
        route: '/bill-payments',
      ));
    }

    if (flags.canBuyAirtime) {
      services.add(ServiceItem(
        icon: Icons.phone_android,
        title: 'Buy Airtime',
        description: 'Mobile top-up',
        route: '/airtime',
      ));
    }

    if (flags.canSplitBills) {
      services.add(ServiceItem(
        icon: Icons.group,
        title: 'Split Bills',
        description: 'Share expenses',
        route: '/split',
      ));
    }

    return services;
  }

  List<ServiceItem> _getToolsServices(Map<String, bool> flags) {
    final services = <ServiceItem>[];

    if (flags.canViewAnalytics) {
      services.add(ServiceItem(
        icon: Icons.analytics_outlined,
        title: 'Analytics',
        description: 'View spending insights',
        route: '/analytics',
      ));
    }

    if (flags.canReferFriends) {
      services.add(ServiceItem(
        icon: Icons.card_giftcard,
        title: 'Referrals',
        description: 'Invite and earn',
        route: '/referrals',
      ));
    }

    return services;
  }
}

/// Service item data model
class ServiceItem {
  final IconData icon;
  final String title;
  final String description;
  final String route;

  const ServiceItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.route,
  });
}

/// Service card component
class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    required this.colors,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  final ThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: colors.container,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: colors.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colors.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                icon,
                color: colors.gold,
                size: 24,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Title
            AppText(
              title,
              variant: AppTextVariant.labelLarge,
              color: colors.textPrimary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xxs),
            // Description
            AppText(
              description,
              variant: AppTextVariant.bodySmall,
              color: colors.textTertiary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
