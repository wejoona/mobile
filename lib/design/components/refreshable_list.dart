/// A pull-to-refresh list wrapper for consistent list views across the app.
library;

import 'package:flutter/material.dart';

/// Wraps a list of items with pull-to-refresh and optional pagination.
class RefreshableList<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Future<void> Function() onRefresh;
  final VoidCallback? onLoadMore;
  final bool hasMore;
  final bool isLoadingMore;
  final Widget? header;
  final Widget? emptyWidget;
  final EdgeInsetsGeometry padding;
  final Widget Function(BuildContext, int)? separatorBuilder;

  const RefreshableList({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onRefresh,
    this.onLoadMore,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.header,
    this.emptyWidget,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.separatorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty && emptyWidget != null) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: emptyWidget!,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification &&
              notification.metrics.extentAfter < 200 &&
              hasMore &&
              !isLoadingMore &&
              onLoadMore != null) {
            onLoadMore!();
          }
          return false;
        },
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: padding,
          itemCount: items.length + (header != null ? 1 : 0) + (isLoadingMore ? 1 : 0),
          separatorBuilder: separatorBuilder ??
              (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            if (header != null && index == 0) {
              return header!;
            }
            final itemIndex = header != null ? index - 1 : index;
            if (itemIndex >= items.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return itemBuilder(context, items[itemIndex], itemIndex);
          },
        ),
      ),
    );
  }
}
