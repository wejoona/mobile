import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../tokens/colors.dart';

/// Custom pull-to-refresh indicator with JoonaPay styling.
/// Provides haptic feedback and uses brand colors.
class AppRefreshIndicator extends StatelessWidget {
  const AppRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.displacement = 40.0,
    this.edgeOffset = 0.0,
    this.notificationPredicate = defaultScrollNotificationPredicate,
  });

  /// The widget below this widget in the tree.
  final Widget child;

  /// Called when the user has pulled down far enough to trigger a refresh.
  final Future<void> Function() onRefresh;

  /// The distance from the child's top or bottom edge to where the refresh
  /// indicator will settle.
  final double displacement;

  /// The offset where the refresh indicator starts appearing.
  final double edgeOffset;

  /// A check that specifies whether a scroll notification should be
  /// handled by this widget.
  final bool Function(ScrollNotification) notificationPredicate;

  Future<void> _handleRefresh() async {
    // Provide haptic feedback when refresh starts
    HapticFeedback.mediumImpact();
    await onRefresh();
    // Provide subtle feedback when refresh completes
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      displacement: displacement,
      edgeOffset: edgeOffset,
      notificationPredicate: notificationPredicate,
      backgroundColor: AppColors.slate,
      color: AppColors.gold500,
      strokeWidth: 2.5,
      child: child,
    );
  }
}

/// A simpler variant that wraps a ListView or CustomScrollView.
class AppRefreshableList extends StatelessWidget {
  const AppRefreshableList({
    super.key,
    required this.onRefresh,
    required this.itemCount,
    required this.itemBuilder,
    this.separatorBuilder,
    this.header,
    this.footer,
    this.padding,
    this.physics,
    this.emptyWidget,
    this.loadingWidget,
    this.isLoading = false,
  });

  /// Called when the user pulls to refresh.
  final Future<void> Function() onRefresh;

  /// Number of items in the list.
  final int itemCount;

  /// Builds each item in the list.
  final Widget Function(BuildContext, int) itemBuilder;

  /// Optional separator between items.
  final Widget Function(BuildContext, int)? separatorBuilder;

  /// Optional header widget above the list.
  final Widget? header;

  /// Optional footer widget below the list.
  final Widget? footer;

  /// Padding around the list content.
  final EdgeInsetsGeometry? padding;

  /// Custom scroll physics.
  final ScrollPhysics? physics;

  /// Widget to show when list is empty.
  final Widget? emptyWidget;

  /// Widget to show while loading.
  final Widget? loadingWidget;

  /// Whether the list is in loading state.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading && loadingWidget != null) {
      return loadingWidget!;
    }

    if (itemCount == 0 && emptyWidget != null && !isLoading) {
      return AppRefreshIndicator(
        onRefresh: onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: emptyWidget!,
            ),
          ],
        ),
      );
    }

    return AppRefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: padding,
        physics: physics ?? const AlwaysScrollableScrollPhysics(),
        itemCount: _calculateItemCount(),
        itemBuilder: (context, index) => _buildItem(context, index),
      ),
    );
  }

  int _calculateItemCount() {
    int count = itemCount;
    if (header != null) count++;
    if (footer != null) count++;
    if (separatorBuilder != null && itemCount > 1) {
      count += itemCount - 1;
    }
    return count;
  }

  Widget _buildItem(BuildContext context, int index) {
    int adjustedIndex = index;

    // Header
    if (header != null) {
      if (index == 0) return header!;
      adjustedIndex--;
    }

    // Footer
    final footerIndex = _calculateItemCount() - 1;
    if (footer != null && index == footerIndex) {
      return footer!;
    }

    // Items with separators
    if (separatorBuilder != null && itemCount > 1) {
      final itemIndex = adjustedIndex ~/ 2;
      if (adjustedIndex.isEven) {
        return itemBuilder(context, itemIndex);
      } else {
        return separatorBuilder!(context, itemIndex);
      }
    }

    // Items without separators
    return itemBuilder(context, adjustedIndex);
  }
}
