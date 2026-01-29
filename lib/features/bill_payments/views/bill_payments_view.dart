import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../services/bill_payments/bill_payments_service.dart';
import '../providers/bill_payments_provider.dart';
import '../widgets/category_selector.dart';
import '../widgets/provider_card.dart';

/// Main Bill Payments Screen
/// Shows categories and providers for bill payments
class BillPaymentsView extends ConsumerStatefulWidget {
  const BillPaymentsView({super.key});

  @override
  ConsumerState<BillPaymentsView> createState() => _BillPaymentsViewState();
}

class _BillPaymentsViewState extends ConsumerState<BillPaymentsView> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final selectedCategory = ref.watch(selectedBillCategoryProvider);
    final providersAsync = ref.watch(
      billProvidersProvider(BillProvidersParams(
        category: selectedCategory?.value,
      )),
    );

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const AppText(
          'Pay Bills',
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.push('/bill-payments/history'),
            tooltip: 'Payment History',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: _buildSearchBar(colors),
          ),

          // Categories
          providersAsync.when(
            data: (data) {
              final categories = data.availableCategories.map((cat) {
                final count = data.providers
                    .where((p) => p.category == cat)
                    .length;
                return CategoryInfo(
                  category: cat,
                  displayName: cat.displayName,
                  description: '',
                  icon: cat.icon,
                  providerCount: count,
                );
              }).toList();

              return CategorySelector(
                categories: categories,
                selectedCategory: selectedCategory,
                onCategorySelected: (category) {
                  ref.read(selectedBillCategoryProvider.notifier).select(category);
                },
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Section Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
            child: AppText(
              selectedCategory != null
                  ? '${selectedCategory.displayName} Providers'
                  : 'All Providers',
              variant: AppTextVariant.titleSmall,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Providers List
          Expanded(
            child: providersAsync.when(
              data: (data) {
                var providers = data.providers;

                // Filter by search
                if (_searchQuery.isNotEmpty) {
                  providers = providers
                      .where((p) =>
                          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          p.shortName.toLowerCase().contains(_searchQuery.toLowerCase()))
                      .toList();
                }

                if (providers.isEmpty) {
                  return _buildEmptyState(colors);
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                  ),
                  itemCount: providers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final provider = providers[index];
                    return ProviderCard(
                      provider: provider,
                      onTap: () => _onProviderSelected(provider),
                    );
                  },
                );
              },
              loading: () => Center(
                child: CircularProgressIndicator(color: colors.gold),
              ),
              error: (error, _) => _buildErrorState(colors, error.toString()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeColors colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.container,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.borderSubtle, width: 1),
      ),
      child: TextField(
        controller: _searchController,
        style: AppTypography.bodyMedium.copyWith(color: colors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search providers...',
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: colors.textTertiary,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: colors.textTertiary,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: colors.textTertiary),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: colors.container,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Icon(
              Icons.search_off,
              size: 48,
              color: colors.textTertiary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppText(
            'No Providers Found',
            variant: AppTextVariant.titleMedium,
            color: colors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
            child: AppText(
              _searchQuery.isNotEmpty
                  ? 'Try adjusting your search'
                  : 'No providers available for this category',
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeColors colors, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.errorBase.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.errorText,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppText(
            'Failed to Load Providers',
            variant: AppTextVariant.titleMedium,
            color: colors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
            child: AppText(
              error,
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton.icon(
            onPressed: () {
              ref.invalidate(billProvidersProvider);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.gold,
              foregroundColor: colors.canvas,
            ),
          ),
        ],
      ),
    );
  }

  void _onProviderSelected(BillProvider provider) {
    ref.read(selectedBillProviderProvider.notifier).select(provider);
    context.push('/bill-payments/pay/${provider.id}');
  }
}
