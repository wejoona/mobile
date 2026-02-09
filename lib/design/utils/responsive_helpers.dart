import 'package:flutter/material.dart';
import 'responsive_layout.dart';
import '../tokens/spacing.dart';

/// Additional responsive helpers for common UI patterns
class ResponsiveHelpers {
  /// Get responsive font size
  static double fontSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return ResponsiveLayout.value(
      context,
      mobile: mobile,
      tablet: tablet ?? mobile * 1.1,
      desktop: desktop ?? mobile * 1.2,
    );
  }

  /// Get responsive icon size
  static double iconSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return ResponsiveLayout.value(
      context,
      mobile: mobile,
      tablet: tablet ?? mobile * 1.15,
      desktop: desktop ?? mobile * 1.25,
    );
  }

  /// Get responsive grid cross axis count
  static int gridColumns(
    BuildContext context, {
    int mobile = 1,
    int tablet = 2,
    int desktop = 3,
  }) {
    return ResponsiveLayout.columns(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// Get responsive card width
  static double? cardWidth(BuildContext context) {
    return ResponsiveLayout.value<double?>(
      context,
      mobile: null, // Full width
      tablet: 400,
      desktop: 480,
    );
  }

  /// Get responsive dialog width
  static double dialogWidth(BuildContext context) {
    return ResponsiveLayout.value(
      context,
      mobile: MediaQuery.of(context).size.width * 0.9,
      tablet: 500,
      desktop: 600,
    );
  }

  /// Get responsive bottom sheet height
  static double bottomSheetHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return ResponsiveLayout.value(
      context,
      mobile: screenHeight * 0.7,
      tablet: screenHeight * 0.6,
      desktop: screenHeight * 0.5,
    );
  }

  /// Check if screen is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Get safe horizontal padding for content
  static EdgeInsets safeContentPadding(BuildContext context) {
    final deviceType = ResponsiveLayout.getDeviceType(context);
    final isLandscapeMode = isLandscape(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return EdgeInsets.symmetric(
          horizontal: isLandscapeMode ? AppSpacing.xl : AppSpacing.screenPadding,
          vertical: AppSpacing.screenPadding,
        );
      case DeviceType.tablet:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxxl,
          vertical: AppSpacing.xl,
        );
      case DeviceType.desktop:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxxl * 2,
          vertical: AppSpacing.xxl,
        );
    }
  }

  /// Get responsive aspect ratio for images/cards
  static double aspectRatio(
    BuildContext context, {
    double mobile = 16 / 9,
    double? tablet,
    double? desktop,
  }) {
    return ResponsiveLayout.value(
      context,
      mobile: mobile,
      tablet: tablet ?? mobile,
      desktop: desktop ?? tablet ?? mobile,
    );
  }

  /// Get number of columns for a staggered grid
  static int staggeredGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= ResponsiveBreakpoints.desktop) return 4;
    if (width >= ResponsiveBreakpoints.tablet) return 3;
    if (width >= 450) return 2;
    return 1;
  }

  /// Get responsive list tile height
  static double? listTileHeight(BuildContext context) {
    return ResponsiveLayout.value<double?>(
      context,
      mobile: null, // Auto
      tablet: 72,
      desktop: 80,
    );
  }

  /// Get responsive app bar height
  static double appBarHeight(BuildContext context) {
    return ResponsiveLayout.value(
      context,
      mobile: kToolbarHeight,
      tablet: kToolbarHeight + 8,
      desktop: kToolbarHeight + 16,
    );
  }

  /// Get responsive FAB size
  static double fabSize(BuildContext context) {
    return ResponsiveLayout.value(
      context,
      mobile: 56,
      tablet: 64,
      desktop: 72,
    );
  }

  /// Get responsive button height
  static double buttonHeight(BuildContext context) {
    return ResponsiveLayout.value(
      context,
      mobile: 48,
      tablet: 52,
      desktop: 56,
    );
  }

  /// Get responsive button min width
  static double buttonMinWidth(BuildContext context) {
    return ResponsiveLayout.value(
      context,
      mobile: 120,
      tablet: 140,
      desktop: 160,
    );
  }

  /// Get responsive modal max width
  static double modalMaxWidth(BuildContext context) {
    return ResponsiveLayout.value(
      context,
      mobile: double.infinity,
      tablet: 600,
      desktop: 800,
    );
  }
}

/// Responsive widget wrappers for common patterns
class ResponsiveContainer extends StatelessWidget {
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.mobileWidth,
    this.tabletWidth,
    this.desktopWidth,
  });

  final Widget child;
  final double? mobileWidth;
  final double? tabletWidth;
  final double? desktopWidth;

  @override
  Widget build(BuildContext context) {
    final width = ResponsiveLayout.value<double?>(
      context,
      mobile: mobileWidth,
      tablet: tabletWidth,
      desktop: desktopWidth,
    );

    if (width == null) return child;

    return SizedBox(
      width: width,
      child: child,
    );
  }
}

/// Responsive padding wrapper
class ResponsivePadding extends StatelessWidget {
  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobile = const EdgeInsets.all(AppSpacing.screenPadding),
    this.tablet,
    this.desktop,
  });

  final Widget child;
  final EdgeInsets mobile;
  final EdgeInsets? tablet;
  final EdgeInsets? desktop;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: ResponsiveLayout.padding(
        context,
        mobile: mobile,
        tablet: tablet,
        desktop: desktop,
      ),
      child: child,
    );
  }
}

/// Responsive gap (SizedBox) for spacing
class ResponsiveGap extends StatelessWidget {
  const ResponsiveGap({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.isHorizontal = false,
  });

  final double mobile;
  final double? tablet;
  final double? desktop;
  final bool isHorizontal;

  @override
  Widget build(BuildContext context) {
    final gap = ResponsiveLayout.value(
      context,
      mobile: mobile,
      tablet: tablet ?? mobile,
      desktop: desktop ?? tablet ?? mobile,
    );

    return SizedBox(
      width: isHorizontal ? gap : null,
      height: isHorizontal ? null : gap,
    );
  }
}

/// Conditional widget based on device type
class DeviceTypeBuilder extends StatelessWidget {
  const DeviceTypeBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
}

/// Visibility based on device type
class HideOnMobile extends StatelessWidget {
  const HideOnMobile({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout.isMobile(context)
        ? const SizedBox.shrink()
        : child;
  }
}

class ShowOnlyMobile extends StatelessWidget {
  const ShowOnlyMobile({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout.isMobile(context)
        ? child
        : const SizedBox.shrink();
  }
}

class HideOnTablet extends StatelessWidget {
  const HideOnTablet({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout.isTablet(context)
        ? const SizedBox.shrink()
        : child;
  }
}

class ShowOnlyTablet extends StatelessWidget {
  const ShowOnlyTablet({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout.isTablet(context)
        ? child
        : const SizedBox.shrink();
  }
}
