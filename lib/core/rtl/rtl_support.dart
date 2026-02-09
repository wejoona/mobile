import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// RTL (Right-to-Left) Support Utilities
///
/// Provides helpers for building RTL-compatible layouts for languages like Arabic, Hebrew, Persian, Urdu.
/// These utilities ensure proper text direction, alignment, and layout mirroring.
///
/// Usage:
/// ```dart
/// // Check if current locale is RTL
/// final isRtl = RTLSupport.isRTL(context);
///
/// // Get directional padding
/// final padding = RTLSupport.paddingStart(16.0);
///
/// // Get directional alignment
/// final alignment = RTLSupport.alignmentStart(context);
/// ```

class RTLSupport {
  RTLSupport._();

  // ═══════════════════════════════════════════════════════════════════════════
  // RTL LANGUAGE DETECTION
  // ═══════════════════════════════════════════════════════════════════════════

  /// List of RTL language codes
  static const List<String> rtlLanguages = [
    'ar', // Arabic
    'he', // Hebrew
    'fa', // Persian (Farsi)
    'ur', // Urdu
    'yi', // Yiddish
    'arc', // Aramaic
  ];

  /// Check if a language code is RTL
  static bool isRTLLanguage(String languageCode) {
    return rtlLanguages.contains(languageCode.toLowerCase());
  }

  /// Check if current locale is RTL
  static bool isRTL(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return isRTLLanguage(locale.languageCode);
  }

  /// Get text direction for current locale
  static TextDirection getTextDirection(BuildContext context) {
    return isRTL(context) ? TextDirection.rtl : TextDirection.ltr;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DIRECTIONAL PADDING
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get padding from start edge (left in LTR, right in RTL)
  static EdgeInsetsDirectional paddingStart(double value) {
    return EdgeInsetsDirectional.only(start: value);
  }

  /// Get padding from end edge (right in LTR, left in RTL)
  static EdgeInsetsDirectional paddingEnd(double value) {
    return EdgeInsetsDirectional.only(end: value);
  }

  /// Get horizontal padding (start and end)
  static EdgeInsetsDirectional paddingHorizontal(double value) {
    return EdgeInsetsDirectional.only(start: value, end: value);
  }

  /// Get padding with start and end values
  static EdgeInsetsDirectional paddingStartEnd(double start, double end) {
    return EdgeInsetsDirectional.only(start: start, end: end);
  }

  /// Get full directional padding (top, start, end, bottom)
  static EdgeInsetsDirectional paddingAll({
    double top = 0,
    double start = 0,
    double end = 0,
    double bottom = 0,
  }) {
    return EdgeInsetsDirectional.only(
      top: top,
      start: start,
      end: end,
      bottom: bottom,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DIRECTIONAL ALIGNMENT
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get alignment for start edge (left in LTR, right in RTL)
  static AlignmentDirectional alignmentStart(BuildContext context) {
    return AlignmentDirectional.centerStart;
  }

  /// Get alignment for end edge (right in LTR, left in RTL)
  static AlignmentDirectional alignmentEnd(BuildContext context) {
    return AlignmentDirectional.centerEnd;
  }

  /// Get text alignment for start
  static TextAlign textAlignStart(BuildContext context) {
    return isRTL(context) ? TextAlign.right : TextAlign.left;
  }

  /// Get text alignment for end
  static TextAlign textAlignEnd(BuildContext context) {
    return isRTL(context) ? TextAlign.left : TextAlign.right;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DIRECTIONAL POSITIONING
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get Positioned widget for start edge
  static Positioned positionedStart({
    required double start,
    double? top,
    double? bottom,
    required Widget child,
  }) {
    return Positioned(
      left: start, // Will be mirrored automatically in RTL
      top: top,
      bottom: bottom,
      child: child,
    );
  }

  /// Get Positioned widget for end edge
  static Positioned positionedEnd({
    required double end,
    double? top,
    double? bottom,
    required Widget child,
  }) {
    return Positioned(
      right: end, // Will be mirrored automatically in RTL
      top: top,
      bottom: bottom,
      child: child,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ICON DIRECTION HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get directional icon (e.g., arrow_forward in LTR, arrow_back in RTL)
  static IconData getDirectionalIcon(
    BuildContext context, {
    required IconData ltrIcon,
    required IconData rtlIcon,
  }) {
    return isRTL(context) ? rtlIcon : ltrIcon;
  }

  /// Get arrow forward icon (respects directionality)
  static IconData arrowForward(BuildContext context) {
    return isRTL(context) ? Icons.arrow_back : Icons.arrow_forward;
  }

  /// Get arrow back icon (respects directionality)
  static IconData arrowBack(BuildContext context) {
    return isRTL(context) ? Icons.arrow_forward : Icons.arrow_back;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LAYOUT HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Wrap widget with Directionality to force text direction
  static Widget withTextDirection({
    required BuildContext context,
    required Widget child,
  }) {
    return Directionality(
      textDirection: getTextDirection(context),
      child: child,
    );
  }

  /// Get MainAxisAlignment for Row that respects directionality
  static MainAxisAlignment rowAlignmentStart(BuildContext context) {
    return isRTL(context)
        ? MainAxisAlignment.end
        : MainAxisAlignment.start;
  }

  /// Get MainAxisAlignment for Row that respects directionality
  static MainAxisAlignment rowAlignmentEnd(BuildContext context) {
    return isRTL(context)
        ? MainAxisAlignment.start
        : MainAxisAlignment.end;
  }

  /// Get CrossAxisAlignment that respects directionality
  static CrossAxisAlignment crossAlignmentStart(BuildContext context) {
    return isRTL(context)
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
  }

  /// Get CrossAxisAlignment that respects directionality
  static CrossAxisAlignment crossAlignmentEnd(BuildContext context) {
    return isRTL(context)
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.end;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// EXTENSION METHODS FOR CONVENIENCE
// ═══════════════════════════════════════════════════════════════════════════

extension BuildContextRTLExtension on BuildContext {
  /// Check if current locale is RTL
  bool get isRTL => RTLSupport.isRTL(this);

  /// Get text direction for current locale
  TextDirection get textDirection => RTLSupport.getTextDirection(this);

  /// Get alignment for start edge
  AlignmentDirectional get alignStart => RTLSupport.alignmentStart(this);

  /// Get alignment for end edge
  AlignmentDirectional get alignEnd => RTLSupport.alignmentEnd(this);

  /// Get text alignment for start
  TextAlign get textAlignStart => RTLSupport.textAlignStart(this);

  /// Get text alignment for end
  TextAlign get textAlignEnd => RTLSupport.textAlignEnd(this);
}

// ═══════════════════════════════════════════════════════════════════════════
// RTL-AWARE WIDGETS
// ═══════════════════════════════════════════════════════════════════════════

/// RTL-aware Row widget that reverses children in RTL mode
class DirectionalRow extends StatelessWidget {
  const DirectionalRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.textDirection,
  });

  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final TextDirection? textDirection;

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: textDirection ?? RTLSupport.getTextDirection(context),
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children,
    );
  }
}

/// RTL-aware ListTile with proper icon positioning
class DirectionalListTile extends StatelessWidget {
  const DirectionalListTile({
    super.key,
    this.leading,
    this.trailing,
    required this.title,
    this.subtitle,
    this.onTap,
    this.contentPadding,
  });

  final Widget? leading;
  final Widget? trailing;
  final Widget title;
  final Widget? subtitle;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    final isRtl = RTLSupport.isRTL(context);

    return ListTile(
      leading: isRtl ? trailing : leading,
      trailing: isRtl ? leading : trailing,
      title: title,
      subtitle: subtitle,
      onTap: onTap,
      contentPadding: contentPadding,
    );
  }
}

/// RTL-aware IconButton with directional icon
class DirectionalIconButton extends StatelessWidget {
  const DirectionalIconButton({
    super.key,
    required this.ltrIcon,
    required this.rtlIcon,
    required this.onPressed,
    this.color,
    this.tooltip,
  });

  final IconData ltrIcon;
  final IconData rtlIcon;
  final VoidCallback? onPressed;
  final Color? color;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final icon = RTLSupport.getDirectionalIcon(
      context,
      ltrIcon: ltrIcon,
      rtlIcon: rtlIcon,
    );

    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
      color: color,
      tooltip: tooltip,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// MIGRATION HELPERS
// ═══════════════════════════════════════════════════════════════════════════

/// Helper class for migrating existing code to RTL-compatible equivalents
class RTLMigrationGuide {
  RTLMigrationGuide._();

  /// Migration map: Old pattern -> RTL-compatible replacement
  static const Map<String, String> migrationMap = {
    // Padding
    'EdgeInsets.only(left: x)': 'EdgeInsetsDirectional.only(start: x)',
    'EdgeInsets.only(right: x)': 'EdgeInsetsDirectional.only(end: x)',
    'padding: const EdgeInsets.symmetric(horizontal: x)':
        'padding: const EdgeInsetsDirectional.only(start: x, end: x)',

    // Alignment
    'Alignment.centerLeft': 'AlignmentDirectional.centerStart',
    'Alignment.centerRight': 'AlignmentDirectional.centerEnd',
    'Alignment.topLeft': 'AlignmentDirectional.topStart',
    'Alignment.topRight': 'AlignmentDirectional.topEnd',
    'Alignment.bottomLeft': 'AlignmentDirectional.bottomStart',
    'Alignment.bottomRight': 'AlignmentDirectional.bottomEnd',

    // Text Alignment
    'TextAlign.left': 'RTLSupport.textAlignStart(context)',
    'TextAlign.right': 'RTLSupport.textAlignEnd(context)',

    // Icons
    'Icons.arrow_forward': 'RTLSupport.arrowForward(context)',
    'Icons.arrow_back': 'RTLSupport.arrowBack(context)',
  };

  /// Print migration suggestions for a given pattern
  static void printMigrationHelp(String pattern) {
    if (migrationMap.containsKey(pattern)) {
      print('RTL Migration: $pattern -> ${migrationMap[pattern]}');
    }
  }
}
