import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';
import 'package:usdc_wallet/design/tokens/spacing.dart';

/// Standardized scaffold for list-based screens.
///
/// Provides consistent patterns for:
/// - Pull-to-refresh
/// - Empty state
/// - Search bar (optional)
/// - Section headers
///
/// Usage:
/// ```dart
/// ListScaffold(
///   title: 'Transactions',
///   items: transactions,
///   itemBuilder: (tx) => TransactionRow(tx),
///   onRefresh: () => ref.refresh(transactionsProvider),
///   emptyIcon: Icons.receipt_long_outlined,
///   emptyTitle: 'No transactions yet',
///   emptySubtitle: 'Your transactions will appear here',
/// )
/// ```
class ListScaffold<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final Widget Function(T item) itemBuilder;
  final Future<void> Function()? onRefresh;
  final IconData emptyIcon;
  final String emptyTitle;
  final String? emptySubtitle;
  final Widget? header;
  final List<Widget>? actions;
  final bool showDividers;

  const ListScaffold({
    super.key,
    required this.title,
    required this.items,
    required this.itemBuilder,
    this.onRefresh,
    this.emptyIcon = Icons.inbox_outlined,
    this.emptyTitle = 'Nothing here yet',
    this.emptySubtitle,
    this.header,
    this.actions,
    this.showDividers = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final body = items.isEmpty
        ? _buildEmpty(colors)
        : _buildList(colors);

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      body: onRefresh != null
          ? RefreshIndicator(
              onRefresh: onRefresh!,
              color: colors.gold,
              child: body,
            )
          : body,
    );
  }

  Widget _buildEmpty(ThemeColors colors) {
    return ListView(
      // ListView needed for RefreshIndicator to work on empty state
      children: [
        SizedBox(height: 120),
        Center(
          child: Column(
            children: [
              Icon(emptyIcon, size: 56, color: colors.textTertiary),
              SizedBox(height: AppSpacing.lg),
              Text(
                emptyTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              if (emptySubtitle != null) ...[
                SizedBox(height: AppSpacing.xs),
                Text(
                  emptySubtitle!,
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildList(ThemeColors colors) {
    return ListView.builder(
      padding: EdgeInsets.only(top: header != null ? 0 : AppSpacing.md),
      itemCount: items.length + (header != null ? 1 : 0),
      itemBuilder: (context, index) {
        if (header != null && index == 0) return header!;
        final itemIndex = header != null ? index - 1 : index;
        final item = items[itemIndex];
        if (showDividers && itemIndex > 0) {
          return Column(
            children: [
              Divider(height: 1, color: colors.borderSubtle),
              itemBuilder(item),
            ],
          );
        }
        return itemBuilder(item);
      },
    );
  }
}
