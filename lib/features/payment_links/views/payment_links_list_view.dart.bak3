import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../models/index.dart';
import '../providers/payment_links_provider.dart';
import '../widgets/payment_link_card.dart';

class PaymentLinksListView extends ConsumerStatefulWidget {
  const PaymentLinksListView({super.key});

  @override
  ConsumerState<PaymentLinksListView> createState() => _PaymentLinksListViewState();
}

class _PaymentLinksListViewState extends ConsumerState<PaymentLinksListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paymentLinksProvider.notifier).loadLinks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(paymentLinksProvider);

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: AppText(
          l10n.paymentLinks_title,
          variant: AppTextVariant.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => context.push('/payment-links/create'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(paymentLinksProvider.notifier).loadLinks(),
        color: AppColors.gold500,
        backgroundColor: AppColors.graphite,
        child: state.isLoading && state.links.isEmpty
            ? _buildLoading()
            : state.links.isEmpty
                ? _buildEmpty(l10n)
                : _buildContent(context, l10n, state),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/payment-links/create'),
        backgroundColor: AppColors.gold500,
        foregroundColor: AppColors.obsidian,
        icon: const Icon(Icons.add),
        label: AppText(
          l10n.paymentLinks_createNew,
          variant: AppTextVariant.labelLarge,
          color: AppColors.obsidian,
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.gold500,
      ),
    );
  }

  Widget _buildEmpty(AppLocalizations l10n) {
    return ListView(
      padding: EdgeInsets.all(AppSpacing.xl),
      children: [
        SizedBox(height: AppSpacing.xxl),
        Icon(
          Icons.link_off,
          size: 80,
          color: AppColors.textSecondary.withOpacity(0.3),
        ),
        SizedBox(height: AppSpacing.lg),
        AppText(
          l10n.paymentLinks_emptyTitle,
          variant: AppTextVariant.headlineMedium,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.sm),
        AppText(
          l10n.paymentLinks_emptyDescription,
          variant: AppTextVariant.bodyLarge,
          color: AppColors.textSecondary,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.xl),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: AppButton(
            label: l10n.paymentLinks_createFirst,
            icon: Icons.add,
            onPressed: () => context.push('/payment-links/create'),
            isFullWidth: true,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations l10n, PaymentLinksState state) {
    return ListView(
      padding: EdgeInsets.all(AppSpacing.md),
      children: [
        // Stats Cards
        _buildStatsCards(l10n, state),
        SizedBox(height: AppSpacing.lg),

        // Filter Chips
        _buildFilterChips(l10n, state),
        SizedBox(height: AppSpacing.md),

        // Links List
        ...state.filteredLinks.map((link) {
          return Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.md),
            child: PaymentLinkCard(
              link: link,
              onTap: () => context.push('/payment-links/detail/${link.id}'),
            ),
          );
        }).toList(),

        if (state.filteredLinks.isEmpty) ...[
          SizedBox(height: AppSpacing.xl),
          Center(
            child: AppText(
              l10n.paymentLinks_noLinksWithFilter,
              variant: AppTextVariant.bodyLarge,
              color: AppColors.textSecondary,
            ),
          ),
        ],

        SizedBox(height: 80), // Space for FAB
      ],
    );
  }

  Widget _buildStatsCards(AppLocalizations l10n, PaymentLinksState state) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: l10n.paymentLinks_activeLinks,
            value: state.activeLinksCount.toString(),
            icon: Icons.link,
            color: AppColors.gold500,
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: _StatCard(
            label: l10n.paymentLinks_paidLinks,
            value: state.paidLinksCount.toString(),
            icon: Icons.check_circle,
            color: AppColors.successBase,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips(AppLocalizations l10n, PaymentLinksState state) {
    final filters = [
      (null, l10n.paymentLinks_filterAll),
      (PaymentLinkStatus.pending, l10n.paymentLinks_filterPending),
      (PaymentLinkStatus.viewed, l10n.paymentLinks_filterViewed),
      (PaymentLinkStatus.paid, l10n.paymentLinks_filterPaid),
      (PaymentLinkStatus.expired, l10n.paymentLinks_filterExpired),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final status = filter.$1;
          final label = filter.$2;
          final isSelected = state.filterStatus == status;

          return Padding(
            padding: EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              label: AppText(
                label,
                variant: AppTextVariant.bodyMedium,
                color: isSelected ? AppColors.obsidian : AppColors.textPrimary,
              ),
              selected: isSelected,
              onSelected: (selected) {
                ref.read(paymentLinksProvider.notifier).setFilter(status);
              },
              backgroundColor: AppColors.slate,
              selectedColor: AppColors.gold500,
              checkmarkColor: AppColors.obsidian,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.slate,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              AppText(
                value,
                variant: AppTextVariant.headlineLarge,
                color: color,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          AppText(
            label,
            variant: AppTextVariant.bodySmall,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
