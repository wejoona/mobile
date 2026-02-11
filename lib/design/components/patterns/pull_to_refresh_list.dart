import 'package:flutter/material.dart';

/// Generic pull-to-refresh list pattern.
///
/// Wraps a list with pull-to-refresh, empty state, and loading state handling.
class PullToRefreshList<T> extends StatelessWidget {
  const PullToRefreshList({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onRefresh,
    required this.emptyState,
    this.isLoading = false,
    this.loadingWidget,
    this.headerWidget,
    this.padding,
    this.separatorBuilder,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Future<void> Function() onRefresh;
  final Widget emptyState;
  final bool isLoading;
  final Widget? loadingWidget;
  final Widget? headerWidget;
  final EdgeInsets? padding;
  final Widget Function(BuildContext context, int index)? separatorBuilder;

  @override
  Widget build(BuildContext context) {
    if (isLoading && items.isEmpty) {
      return loadingWidget ?? const Center(child: CircularProgressIndicator());
    }

    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(child: emptyState),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: padding ?? const EdgeInsets.symmetric(vertical: 8),
        itemCount: items.length + (headerWidget != null ? 1 : 0),
        separatorBuilder: separatorBuilder ??
            (_, __) => const SizedBox(height: 0),
        itemBuilder: (context, index) {
          if (headerWidget != null && index == 0) return headerWidget!;
          final itemIndex = headerWidget != null ? index - 1 : index;
          return itemBuilder(context, items[itemIndex], itemIndex);
        },
      ),
    );
  }
}
