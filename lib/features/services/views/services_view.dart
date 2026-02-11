import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/services/feature_flags/feature_flags_provider.dart';
import 'package:usdc_wallet/services/feature_flags/feature_flags_extensions.dart';

/// Services page - centralized view of all available services
/// Reduces home page clutter and provides organized access to features
class ServicesView extends ConsumerWidget {
  const ServicesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final flags = ref.watch(featureFlagsProvider);

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: colors.canvas,
        elevation: 0,
        title: AppText(
          l10n.services_title,
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
              _buildSectionHeader(l10n.services_coreServices, colors),
              const SizedBox(height: AppSpacing.md),
              _buildServicesGrid(context, _getCoreServices(flags, l10n), colors),

              const SizedBox(height: AppSpacing.xxl),

              // Financial Services
              if (_getFinancialServices(flags, l10n).isNotEmpty) ...[
                _buildSectionHeader(l10n.services_financialServices, colors),
                const SizedBox(height: AppSpacing.md),
                _buildServicesGrid(context, _getFinancialServices(flags, l10n), colors),
                const SizedBox(height: AppSpacing.xxl),
              ],

              // Bill Payments & Top-ups
              if (_getBillServices(flags, l10n).isNotEmpty) ...[
                _buildSectionHeader(l10n.services_billsPayments, colors),
                const SizedBox(height: AppSpacing.md),
                _buildServicesGrid(context, _getBillServices(flags, l10n), colors),
                const SizedBox(height: AppSpacing.xxl),
              ],

              // Analytics & Tools
              if (_getToolsServices(flags, l10n).isNotEmpty) ...[
                _buildSectionHeader(l10n.services_toolsAnalytics, colors),
                const SizedBox(height: AppSpacing.md),
                _buildServicesGrid(context, _getToolsServices(flags, l10n), colors),
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

  List<ServiceItem> _getCoreServices(Map<String, bool> flags, AppLocalizations l10n) {
    final services = <ServiceItem>[];

    if (flags.canSend) {
      services.add(ServiceItem(
        icon: Icons.send,
        title: l10n.services_sendMoney,
        description: l10n.services_sendMoneyDesc,
        route: '/send',
      ));
    }

    if (flags.canReceive) {
      services.add(ServiceItem(
        icon: Icons.call_received,
        title: l10n.services_receiveMoney,
        description: l10n.services_receiveMoneyDesc,
        route: '/receive',
      ));
    }

    if (flags.canRequestMoney) {
      services.add(ServiceItem(
        icon: Icons.qr_code,
        title: l10n.services_requestMoney,
        description: l10n.services_requestMoneyDesc,
        route: '/request',
      ));
    }

    services.add(ServiceItem(
      icon: Icons.qr_code_scanner,
      title: l10n.services_scanQr,
      description: l10n.services_scanQrDesc,
      route: '/scan',
    ));

    if (flags.canUseSavedRecipients) {
      services.add(ServiceItem(
        icon: Icons.people_outline,
        title: l10n.services_recipients,
        description: l10n.services_recipientsDesc,
        route: '/recipients',
      ));
    }

    if (flags.canScheduleTransfers) {
      services.add(ServiceItem(
        icon: Icons.schedule,
        title: l10n.services_scheduledTransfers,
        description: l10n.services_scheduledTransfersDesc,
        route: '/scheduled',
      ));
    }

    return services;
  }

  List<ServiceItem> _getFinancialServices(Map<String, bool> flags, AppLocalizations l10n) {
    final services = <ServiceItem>[];

    if (flags.canUseVirtualCards) {
      services.add(ServiceItem(
        icon: Icons.credit_card,
        title: l10n.services_virtualCard,
        description: l10n.services_virtualCardDesc,
        route: '/card',
      ));
    }

    if (flags.canSetSavingsGoals) {
      services.add(ServiceItem(
        icon: Icons.savings,
        title: l10n.services_savingsGoals,
        description: l10n.services_savingsGoalsDesc,
        route: '/savings',
      ));
    }

    if (flags.canUseBudget) {
      services.add(ServiceItem(
        icon: Icons.pie_chart,
        title: l10n.services_budget,
        description: l10n.services_budgetDesc,
        route: '/budget',
      ));
    }

    if (flags.canUseCurrencyConverter) {
      services.add(ServiceItem(
        icon: Icons.currency_exchange,
        title: l10n.services_currencyConverter,
        description: l10n.services_currencyConverterDesc,
        route: '/converter',
      ));
    }

    return services;
  }

  List<ServiceItem> _getBillServices(Map<String, bool> flags, AppLocalizations l10n) {
    final services = <ServiceItem>[];

    if (flags.canPayBills) {
      services.add(ServiceItem(
        icon: Icons.receipt_long,
        title: l10n.services_billPayments,
        description: l10n.services_billPaymentsDesc,
        route: '/bill-payments',
      ));
    }

    if (flags.canBuyAirtime) {
      services.add(ServiceItem(
        icon: Icons.phone_android,
        title: l10n.services_buyAirtime,
        description: l10n.services_buyAirtimeDesc,
        route: '/airtime',
      ));
    }

    if (flags.canSplitBills) {
      services.add(ServiceItem(
        icon: Icons.group,
        title: l10n.services_splitBills,
        description: l10n.services_splitBillsDesc,
        route: '/split',
      ));
    }

    return services;
  }

  List<ServiceItem> _getToolsServices(Map<String, bool> flags, AppLocalizations l10n) {
    final services = <ServiceItem>[];

    if (flags.canViewAnalytics) {
      services.add(ServiceItem(
        icon: Icons.analytics_outlined,
        title: l10n.services_analytics,
        description: l10n.services_analyticsDesc,
        route: '/analytics',
      ));
    }

    if (flags.canReferFriends) {
      services.add(ServiceItem(
        icon: Icons.card_giftcard,
        title: l10n.services_referrals,
        description: l10n.services_referralsDesc,
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
