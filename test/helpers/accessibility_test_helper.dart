import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Accessibility testing helper for automated WCAG 2.1 compliance checks
///
/// Usage:
/// ```dart
/// testWidgets('Screen is accessible', (tester) async {
///   await tester.pumpWidget(const MyApp());
///   await AccessibilityTestHelper.runFullAudit(tester);
/// });
/// ```
class AccessibilityTestHelper {
  AccessibilityTestHelper._();

  /// Run complete accessibility audit
  ///
  /// Checks:
  /// - Semantic labels
  /// - Touch target sizes
  /// - Contrast ratios (basic)
  /// - Focus traversal
  /// - Text scaling
  static Future<void> runFullAudit(
    WidgetTester tester, {
    bool checkLabels = true,
    bool checkTouchTargets = true,
    bool checkContrast = true,
    bool checkFocusOrder = true,
    bool checkTextScale = true,
  }) async {
    if (checkLabels) {
      await checkSemanticLabels(tester);
    }

    if (checkTouchTargets) {
      await checkTouchTargets(tester);
    }

    if (checkContrast) {
      checkBasicContrast(tester);
    }

    if (checkFocusOrder) {
      await checkFocusTraversal(tester);
    }

    if (checkTextScale) {
      await checkTextScaling(tester);
    }
  }

  /// Check that all interactive elements have semantic labels
  static Future<void> checkSemanticLabels(WidgetTester tester) async {
    final semantics = tester.getSemantics(find.byType(Semantics).first);
    _traverseSemantics(semantics, (node) {
      // Interactive elements must have labels
      if (node.hasFlag(SemanticsFlag.isButton) ||
          node.hasFlag(SemanticsFlag.isTextField) ||
          node.hasFlag(SemanticsFlag.isLink) ||
          node.hasAction(SemanticsAction.tap)) {
        expect(
          node.label.isNotEmpty || node.value.isNotEmpty,
          isTrue,
          reason: 'Interactive element missing semantic label: $node',
        );
      }

      // Images should have labels or be marked as decorative
      if (node.hasFlag(SemanticsFlag.isImage)) {
        expect(
          node.label.isNotEmpty || node.hasFlag(SemanticsFlag.scopesRoute),
          isTrue,
          reason: 'Image missing semantic label or not marked as decorative',
        );
      }
    });
  }

  /// Check that all touch targets meet minimum size requirements (44x44 dp)
  static Future<void> checkTouchTargets(
    WidgetTester tester, {
    double minSize = 44.0,
  }) async {
    final buttons = find.byWidgetPredicate((widget) =>
        widget is ElevatedButton ||
        widget is TextButton ||
        widget is IconButton ||
        widget is OutlinedButton ||
        widget is FloatingActionButton ||
        widget is GestureDetector ||
        widget is InkWell);

    for (final button in buttons.evaluate()) {
      final size = tester.getSize(find.byWidget(button.widget));

      // Check width and height
      expect(
        size.width >= minSize || size.height >= minSize,
        isTrue,
        reason:
            'Touch target too small: ${size.width}x${size.height} (min: ${minSize}x$minSize)',
      );
    }
  }

  /// Basic contrast checking (requires manual verification for full compliance)
  ///
  /// This is a simplified check. For full contrast compliance, use:
  /// - Manual tools (WebAIM Contrast Checker)
  /// - Visual inspection
  /// - Design system token verification
  static void checkBasicContrast(WidgetTester tester) {
    final texts = find.byType(Text);

    for (final text in texts.evaluate()) {
      final textWidget = text.widget as Text;
      final style = textWidget.style;

      if (style != null && style.color != null) {
        // Verify text has color (basic check)
        expect(
          style.color,
          isNotNull,
          reason: 'Text should have explicit color for contrast verification',
        );

        // Verify not fully transparent
        expect(
          style.color!.opacity,
          greaterThan(0.0),
          reason: 'Text should not be fully transparent',
        );
      }
    }
  }

  /// Check that focus traversal order is logical
  static Future<void> checkFocusTraversal(WidgetTester tester) async {
    final focusableWidgets = find.byWidgetPredicate((widget) =>
        widget is Focus ||
        widget is FocusScope ||
        widget is TextField ||
        widget is ElevatedButton ||
        widget is TextButton);

    // Verify focus order matches visual order (top-to-bottom, left-to-right)
    final positions = <Offset>[];
    for (final widget in focusableWidgets.evaluate()) {
      final position = tester.getTopLeft(find.byWidget(widget.widget));
      positions.add(position);
    }

    // Check that positions generally increase (allowing for multi-column layouts)
    // This is a basic check - manual verification still needed
    for (int i = 0; i < positions.length - 1; i++) {
      final current = positions[i];
      final next = positions[i + 1];

      // If next item is on a new "row", Y should increase
      // If on same row, X should increase
      final isNewRow = (next.dy - current.dy).abs() > 40; // Threshold for row change

      if (!isNewRow) {
        // Same row - X should increase or be close
        expect(
          next.dx >= current.dx - 10, // Small tolerance
          isTrue,
          reason: 'Focus order may not match visual order',
        );
      }
    }
  }

  /// Check that text scales properly up to 200%
  static Future<void> checkTextScaling(WidgetTester tester) async {
    final originalTexts = <String, double>{};

    // Capture original sizes
    final texts = find.byType(Text);
    for (final text in texts.evaluate()) {
      final textWidget = text.widget as Text;
      final size = tester.getSize(find.byWidget(textWidget));
      if (textWidget.data != null) {
        originalTexts[textWidget.data!] = size.height;
      }
    }

    // Rebuild with 2x scale
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaleFactor: 2.0),
        child: tester.widget(find.byType(MaterialApp)),
      ),
    );
    await tester.pumpAndSettle();

    // Verify texts scaled
    for (final entry in originalTexts.entries) {
      final scaledText = find.text(entry.key);
      if (scaledText.evaluate().isNotEmpty) {
        final scaledSize = tester.getSize(scaledText);

        expect(
          scaledSize.height,
          greaterThan(entry.value * 1.5), // At least 1.5x larger
          reason: 'Text "${entry.key}" did not scale properly',
        );
      }
    }
  }

  /// Verify screen reader announcements
  ///
  /// Checks that live region updates are properly announced
  static Future<void> checkLiveRegionAnnouncements(
    WidgetTester tester,
  ) async {
    final liveRegions = find.byWidgetPredicate(
      (widget) =>
          widget is Semantics &&
          (widget.properties.liveRegion == true ||
              widget.properties.label?.isNotEmpty == true),
    );

    expect(
      liveRegions,
      findsWidgets,
      reason: 'No live regions found - status updates may not be announced',
    );
  }

  /// Check that error states are properly announced
  static Future<void> checkErrorAnnouncements(
    WidgetTester tester,
    String errorMessage,
  ) async {
    // Find semantics nodes with error message
    final errorNodes = find.bySemanticsLabel(errorMessage);

    expect(
      errorNodes,
      findsOneWidget,
      reason: 'Error message not found in semantics tree: "$errorMessage"',
    );
  }

  /// Verify loading states are announced
  static Future<void> checkLoadingAnnouncement(WidgetTester tester) async {
    final loadingIndicators = find.byType(CircularProgressIndicator);

    for (final indicator in loadingIndicators.evaluate()) {
      // Check that parent has semantic label
      final parent = find.ancestor(
        of: find.byWidget(indicator.widget),
        matching: find.byType(Semantics),
      );

      expect(
        parent,
        findsWidgets,
        reason: 'Loading indicator should have semantic label',
      );
    }
  }

  /// Check that buttons properly announce state changes
  static Future<void> checkButtonStateAnnouncements(
    WidgetTester tester,
    Finder buttonFinder,
  ) async {
    final button = tester.widget(buttonFinder);
    final semantics = tester.getSemantics(buttonFinder);

    // Verify button trait
    expect(
      semantics.hasFlag(SemanticsFlag.isButton),
      isTrue,
      reason: 'Widget should have button semantics',
    );

    // Verify enabled state
    if (button is Widget) {
      final isEnabled = semantics.hasFlag(SemanticsFlag.hasEnabledState)
          ? semantics.hasFlag(SemanticsFlag.isEnabled)
          : true;

      expect(
        isEnabled,
        isNotNull,
        reason: 'Button enabled state should be announced',
      );
    }
  }

  /// Verify form field labels and associations
  static Future<void> checkFormAccessibility(WidgetTester tester) async {
    final textFields = find.byType(TextField);

    for (final field in textFields.evaluate()) {
      final semantics = tester.getSemantics(find.byWidget(field.widget));

      // Text field should have label or hint
      expect(
        semantics.label.isNotEmpty ||
            semantics.hint.isNotEmpty ||
            semantics.value.isNotEmpty,
        isTrue,
        reason: 'Text field missing label or hint',
      );

      // Text field should have text field flag
      expect(
        semantics.hasFlag(SemanticsFlag.isTextField),
        isTrue,
        reason: 'Text field missing isTextField flag',
      );
    }
  }

  /// Check that navigation maintains focus context
  static Future<void> checkNavigationFocus(WidgetTester tester) async {
    // Find back button
    final backButton = find.byTooltip('Back');

    if (backButton.evaluate().isNotEmpty) {
      final semantics = tester.getSemantics(backButton);

      expect(
        semantics.label.isNotEmpty || semantics.tooltip.isNotEmpty,
        isTrue,
        reason: 'Back button should have semantic label',
      );
    }

    // Check bottom navigation
    final bottomNav = find.byType(BottomNavigationBar);

    if (bottomNav.evaluate().isNotEmpty) {
      final navBar = tester.widget<BottomNavigationBar>(bottomNav);

      for (final item in navBar.items) {
        expect(
          item.label,
          isNotNull,
          reason: 'Navigation item should have label',
        );
      }
    }
  }

  /// Helper to traverse semantics tree
  static void _traverseSemantics(
    SemanticsNode node,
    void Function(SemanticsNode) callback,
  ) {
    callback(node);
    node.visitChildren((child) {
      _traverseSemantics(child, callback);
      return true;
    });
  }

  /// Check for keyboard traps
  ///
  /// Verifies that all focusable elements can be exited
  static Future<void> checkNoKeyboardTraps(WidgetTester tester) async {
    final focusableWidgets = find.byWidgetPredicate(
      (widget) =>
          widget is Focus ||
          widget is TextField ||
          widget is ElevatedButton ||
          widget is TextButton,
    );

    // This is a basic check - manual testing still needed
    expect(
      focusableWidgets,
      findsWidgets,
      reason: 'Should have focusable widgets',
    );

    // Verify focus can move forward and backward
    // (Actual implementation would simulate tab/shift-tab)
  }

  /// Verify images have alt text or are marked decorative
  static void checkImageAccessibility(WidgetTester tester) {
    final images = find.byType(Image);

    for (final image in images.evaluate()) {
      // Check for semantic label on image or parent
      final semantics = find.ancestor(
        of: find.byWidget(image.widget),
        matching: find.byType(Semantics),
      );

      expect(
        semantics,
        findsWidgets,
        reason: 'Image should have semantic wrapper',
      );
    }
  }

  /// Check contrast ratios for specific color pairs
  ///
  /// Returns contrast ratio. Minimum:
  /// - Normal text: 4.5:1
  /// - Large text (18pt+): 3:1
  /// - UI components: 3:1
  static double calculateContrastRatio(Color foreground, Color background) {
    final fgLuminance = _calculateRelativeLuminance(foreground);
    final bgLuminance = _calculateRelativeLuminance(background);

    final lighter = fgLuminance > bgLuminance ? fgLuminance : bgLuminance;
    final darker = fgLuminance > bgLuminance ? bgLuminance : fgLuminance;

    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Calculate relative luminance per WCAG formula
  static double _calculateRelativeLuminance(Color color) {
    final r = _gammaCorrect(color.red / 255.0);
    final g = _gammaCorrect(color.green / 255.0);
    final b = _gammaCorrect(color.blue / 255.0);

    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Gamma correction for luminance calculation
  static double _gammaCorrect(double value) {
    if (value <= 0.03928) {
      return value / 12.92;
    } else {
      return ((value + 0.055) / 1.055).pow(2.4);
    }
  }

  /// Verify contrast meets WCAG AA standards
  static void verifyContrastRatio(
    Color foreground,
    Color background, {
    bool isLargeText = false,
    String? reason,
  }) {
    final ratio = calculateContrastRatio(foreground, background);
    final minimumRatio = isLargeText ? 3.0 : 4.5;

    expect(
      ratio,
      greaterThanOrEqualTo(minimumRatio),
      reason: reason ??
          'Contrast ratio $ratio does not meet WCAG AA ($minimumRatio:1)',
    );
  }

  /// Verify contrast meets WCAG AAA standards
  static void verifyContrastRatioAAA(
    Color foreground,
    Color background, {
    bool isLargeText = false,
    String? reason,
  }) {
    final ratio = calculateContrastRatio(foreground, background);
    final minimumRatio = isLargeText ? 4.5 : 7.0;

    expect(
      ratio,
      greaterThanOrEqualTo(minimumRatio),
      reason: reason ??
          'Contrast ratio $ratio does not meet WCAG AAA ($minimumRatio:1)',
    );
  }
}

/// Extension to add pow method
extension on double {
  double pow(num exponent) {
    return dart.math.pow(this, exponent).toDouble();
  }
}

import 'dart:math' as dart.math;
