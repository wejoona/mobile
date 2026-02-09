import 'package:flutter/material.dart';

/// Responsive breakpoints for adaptive layouts
class ResponsiveBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

/// Device type based on screen width
enum DeviceType {
  mobile,
  tablet,
  desktop;
}

/// Responsive layout utilities
class ResponsiveLayout {
  /// Get device type based on screen width
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= ResponsiveBreakpoints.desktop) {
      return DeviceType.desktop;
    } else if (width >= ResponsiveBreakpoints.tablet) {
      return DeviceType.tablet;
    }
    return DeviceType.mobile;
  }

  /// Check if current device is mobile
  static bool isMobile(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }

  /// Check if current device is tablet
  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  /// Check if current device is desktop
  static bool isDesktop(BuildContext context) {
    return getDeviceType(context) == DeviceType.desktop;
  }

  /// Check if current device is tablet or larger
  static bool isTabletOrLarger(BuildContext context) {
    final type = getDeviceType(context);
    return type == DeviceType.tablet || type == DeviceType.desktop;
  }

  /// Get responsive value based on device type
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.mobile:
        return mobile;
    }
  }

  /// Get responsive columns count
  static int columns(BuildContext context, {int mobile = 1, int tablet = 2, int desktop = 3}) {
    return value(context, mobile: mobile, tablet: tablet, desktop: desktop);
  }

  /// Get responsive padding
  static EdgeInsets padding(BuildContext context, {
    required EdgeInsets mobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
  }) {
    return value(context, mobile: mobile, tablet: tablet, desktop: desktop);
  }

  /// Get responsive max width for content
  static double? maxContentWidth(BuildContext context) {
    return value<double?>(
      context,
      mobile: null, // Full width on mobile
      tablet: 720,  // Constrained on tablet
      desktop: 1200, // Constrained on desktop
    );
  }
}

/// Responsive builder widget
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width >= ResponsiveBreakpoints.desktop && desktop != null) {
          return desktop!;
        } else if (width >= ResponsiveBreakpoints.tablet && tablet != null) {
          return tablet!;
        }
        return mobile;
      },
    );
  }
}

/// Grid layout that adapts to screen size
class AdaptiveGrid extends StatelessWidget {
  const AdaptiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
  });

  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveLayout.columns(
      context,
      mobile: mobileColumns,
      tablet: tabletColumns,
      desktop: desktopColumns,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: children.map((child) {
            return SizedBox(
              width: itemWidth,
              child: child,
            );
          }).toList(),
        );
      },
    );
  }
}

/// Two-column layout for tablet/desktop
class TwoColumnLayout extends StatelessWidget {
  const TwoColumnLayout({
    super.key,
    required this.left,
    required this.right,
    this.leftFlex = 1,
    this.rightFlex = 1,
    this.spacing = 24.0,
  });

  final Widget left;
  final Widget right;
  final int leftFlex;
  final int rightFlex;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: Column(
        children: [left, SizedBox(height: spacing), right],
      ),
      tablet: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: leftFlex, child: left),
          SizedBox(width: spacing),
          Expanded(flex: rightFlex, child: right),
        ],
      ),
    );
  }
}

/// Master-detail layout for tablet (side-by-side)
class MasterDetailLayout extends StatelessWidget {
  const MasterDetailLayout({
    super.key,
    required this.master,
    required this.detail,
    this.masterFlex = 2,
    this.detailFlex = 3,
  });

  final Widget master;
  final Widget detail;
  final int masterFlex;
  final int detailFlex;

  @override
  Widget build(BuildContext context) {
    if (ResponsiveLayout.isTabletOrLarger(context)) {
      return Row(
        children: [
          Expanded(flex: masterFlex, child: master),
          const VerticalDivider(width: 1),
          Expanded(flex: detailFlex, child: detail),
        ],
      );
    }
    return master;
  }
}

/// Constrain content width on larger screens
class ConstrainedContent extends StatelessWidget {
  const ConstrainedContent({
    super.key,
    required this.child,
    this.maxWidth,
  });

  final Widget child;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final width = maxWidth ?? ResponsiveLayout.maxContentWidth(context);

    if (width == null) {
      return child;
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: width),
        child: child,
      ),
    );
  }
}
