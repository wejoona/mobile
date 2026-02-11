import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Mixin for scroll-related behaviors (scroll to top, fab visibility, etc.).
mixin ScrollMixin<T extends StatefulWidget> on State<T> {
  late ScrollController scrollController;
  bool _showScrollToTop = false;

  bool get showScrollToTop => _showScrollToTop;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final show = scrollController.offset > 300;
    if (show != _showScrollToTop) {
      setState(() => _showScrollToTop = show);
    }
    onScroll();
  }

  /// Override for custom scroll behavior.
  void onScroll() {}

  /// Scroll to top with animation.
  void scrollToTop() {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  /// Whether user is scrolling down (for hiding bottom bars).
  bool get isScrollingDown {
    final position = scrollController.position;
    return position.userScrollDirection == ScrollDirection.reverse;
  }

  /// Whether near the bottom (for infinite scroll).
  bool get isNearBottom {
    if (!scrollController.hasClients) return false;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.offset;
    return currentScroll >= maxScroll * 0.9;
  }
}
