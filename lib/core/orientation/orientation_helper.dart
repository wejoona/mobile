import 'package:flutter/material.dart';

/// Orientation-aware layout utilities
///
/// Provides helpers for building layouts that adapt to both
/// portrait and landscape orientations, with special handling
/// for tablets in landscape mode.
///
/// Usage:
/// ```dart
/// OrientationBuilder(
///   portrait: _buildPortraitLayout(),
///   landscape: _buildLandscapeLayout(),
/// )
/// ```
class OrientationHelper {
  /// Check if device is in portrait mode
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Get orientation-specific value
  static T value<T>(
    BuildContext context, {
    required T portrait,
    required T landscape,
  }) {
    return isPortrait(context) ? portrait : landscape;
  }

  /// Get responsive columns based on orientation and screen size
  ///
  /// Returns optimal column count considering:
  /// - Screen orientation (portrait/landscape)
  /// - Device type (mobile/tablet)
  /// - Available screen width
  static int columns(BuildContext context, {
    int portraitMobile = 1,
    int landscapeMobile = 2,
    int portraitTablet = 2,
    int landscapeTablet = 3,
  }) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final isPortraitMode = isPortrait(context);

    if (isTablet) {
      return isPortraitMode ? portraitTablet : landscapeTablet;
    } else {
      return isPortraitMode ? portraitMobile : landscapeMobile;
    }
  }

  /// Get optimal spacing based on orientation
  /// More compact spacing in landscape to fit more content
  static double spacing(BuildContext context, {
    double portrait = 16.0,
    double landscape = 12.0,
  }) {
    return isPortrait(context) ? portrait : landscape;
  }

  /// Get optimal padding based on orientation
  static EdgeInsets padding(BuildContext context, {
    required EdgeInsets portrait,
    required EdgeInsets landscape,
  }) {
    return isPortrait(context) ? portrait : landscape;
  }

  /// Calculate content max width based on orientation and screen size
  ///
  /// Prevents content from stretching too wide in landscape mode
  static double? maxContentWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLandscapeMode = isLandscape(context);

    if (isLandscapeMode) {
      // In landscape, constrain width to maintain readability
      if (screenWidth >= 900) {
        return 1200; // Desktop/large tablet
      } else if (screenWidth >= 600) {
        return 800; // Tablet
      } else {
        return screenWidth * 0.95; // Mobile landscape
      }
    }

    // Portrait mode - full width on mobile, constrained on tablet
    if (screenWidth >= 600) {
      return 720; // Tablet portrait
    }

    return null; // Full width on mobile portrait
  }

  /// Get optimal aspect ratio for cards/containers based on orientation
  static double aspectRatio(BuildContext context, {
    double portrait = 1.5,
    double landscape = 2.5,
  }) {
    return isPortrait(context) ? portrait : landscape;
  }

  /// Check if should use single column layout
  ///
  /// Returns true for mobile portrait and false for most landscape scenarios
  static bool shouldUseSingleColumn(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return isPortrait(context) && screenWidth < 600;
  }

  /// Check if should use two column layout
  static bool shouldUseTwoColumns(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return isLandscape(context) || screenWidth >= 600;
  }

  /// Get optimal grid cross-axis count for orientation
  static int gridCrossAxisCount(BuildContext context, {
    int portraitMobile = 2,
    int landscapeMobile = 3,
    int portraitTablet = 3,
    int landscapeTablet = 4,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final isPortraitMode = isPortrait(context);

    if (isTablet) {
      return isPortraitMode ? portraitTablet : landscapeTablet;
    } else {
      return isPortraitMode ? portraitMobile : landscapeMobile;
    }
  }
}

/// Orientation-aware builder widget
///
/// Builds different layouts for portrait and landscape modes
/// Falls back to portrait layout if landscape is not provided
class OrientationLayoutBuilder extends StatelessWidget {
  const OrientationLayoutBuilder({
    super.key,
    required this.portrait,
    this.landscape,
  });

  final Widget portrait;
  final Widget? landscape;

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.landscape && landscape != null) {
          return landscape!;
        }
        return portrait;
      },
    );
  }
}

/// Adaptive grid that adjusts columns based on orientation
class OrientationAdaptiveGrid extends StatelessWidget {
  const OrientationAdaptiveGrid({
    super.key,
    required this.children,
    this.portraitColumns = 1,
    this.landscapeColumns = 2,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.childAspectRatio,
  });

  final List<Widget> children;
  final int portraitColumns;
  final int landscapeColumns;
  final double spacing;
  final double runSpacing;
  final double? childAspectRatio;

  @override
  Widget build(BuildContext context) {
    final columns = OrientationHelper.value(
      context,
      portrait: portraitColumns,
      landscape: landscapeColumns,
    );

    return GridView.count(
      crossAxisCount: columns,
      mainAxisSpacing: runSpacing,
      crossAxisSpacing: spacing,
      childAspectRatio: childAspectRatio ??
          OrientationHelper.aspectRatio(context, portrait: 1.0, landscape: 1.2),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
}

/// Horizontal/Vertical layout that switches based on orientation
///
/// Useful for forms and lists that should be horizontal in landscape
class OrientationSwitchLayout extends StatelessWidget {
  const OrientationSwitchLayout({
    super.key,
    required this.children,
    this.spacing = 16.0,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final List<Widget> children;
  final double spacing;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return OrientationLayoutBuilder(
      portrait: Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: _addSpacing(children, spacing, true),
      ),
      landscape: Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: _addSpacing(children, spacing, false),
      ),
    );
  }

  List<Widget> _addSpacing(List<Widget> children, double spacing, bool vertical) {
    if (children.isEmpty) return children;

    final List<Widget> spacedChildren = [];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(
          vertical
              ? SizedBox(height: spacing)
              : SizedBox(width: spacing),
        );
      }
    }
    return spacedChildren;
  }
}

/// Safe area padding that adapts to orientation
///
/// Provides more horizontal padding in landscape mode
class OrientationSafePadding extends StatelessWidget {
  const OrientationSafePadding({
    super.key,
    required this.child,
    this.portraitPadding = const EdgeInsets.all(16.0),
    this.landscapePadding = const EdgeInsets.symmetric(
      horizontal: 32.0,
      vertical: 12.0,
    ),
  });

  final Widget child;
  final EdgeInsets portraitPadding;
  final EdgeInsets landscapePadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: OrientationHelper.padding(
        context,
        portrait: portraitPadding,
        landscape: landscapePadding,
      ),
      child: child,
    );
  }
}

/// Scrollable content with orientation-aware constraints
///
/// Prevents content from stretching too wide in landscape
class OrientationScrollView extends StatelessWidget {
  const OrientationScrollView({
    super.key,
    required this.child,
    this.padding,
    this.physics,
  });

  final Widget child;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    final maxWidth = OrientationHelper.maxContentWidth(context);

    return SingleChildScrollView(
      padding: padding,
      physics: physics,
      child: maxWidth != null
          ? Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: child,
              ),
            )
          : child,
    );
  }
}
