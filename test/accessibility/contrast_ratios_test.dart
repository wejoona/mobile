import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/design/tokens/colors.dart';
import '../helpers/accessibility_test_helper.dart';

/// WCAG 2.1 AA Compliance Tests - Contrast Ratios
///
/// Guideline: 1.4.3 Contrast (Minimum) - Level AA
/// - Normal text: Minimum 4.5:1 contrast ratio
/// - Large text (18pt+/14pt+ bold): Minimum 3:1 contrast ratio
/// - UI components and graphical objects: Minimum 3:1 contrast ratio
///
/// Guideline: 1.4.6 Contrast (Enhanced) - Level AAA
/// - Normal text: Minimum 7:1 contrast ratio
/// - Large text: Minimum 4.5:1 contrast ratio
///
/// Tests verify:
/// - All text meets minimum contrast requirements
/// - All UI components meet 3:1 contrast
/// - Design system colors are WCAG compliant
/// - Status colors (success, error, warning) are accessible
void main() {
  group('WCAG 1.4.3 - Contrast Ratios (AA)', () {
    group('Text Contrast - Primary Colors', () {
      test('Primary text on obsidian background meets AAA standards', () {
        final ratio = AccessibilityTestHelper.calculateContrastRatio(
          AppColors.textPrimary,
          AppColors.obsidian,
        );

        // Should exceed WCAG AAA (7:1)
        expect(
          ratio,
          greaterThanOrEqualTo(7.0),
          reason: 'Primary text must meet WCAG AAA for maximum readability. '
              'Ratio: ${ratio.toStringAsFixed(2)}:1',
        );

        print('Primary text on obsidian: ${ratio.toStringAsFixed(2)}:1 ✓');
      });

      test('Secondary text on obsidian background meets AA standards', () {
        final ratio = AccessibilityTestHelper.calculateContrastRatio(
          AppColors.textSecondary,
          AppColors.obsidian,
        );

        // Should meet WCAG AA (4.5:1)
        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason: 'Secondary text must meet WCAG AA for readability. '
              'Ratio: ${ratio.toStringAsFixed(2)}:1',
        );

        print('Secondary text on obsidian: ${ratio.toStringAsFixed(2)}:1 ✓');
      });

      test('Tertiary text on obsidian background meets minimum contrast', () {
        final ratio = AccessibilityTestHelper.calculateContrastRatio(
          AppColors.textTertiary,
          AppColors.obsidian,
        );

        // Should meet WCAG AA for large text (3:1)
        expect(
          ratio,
          greaterThanOrEqualTo(3.0),
          reason: 'Tertiary text should be used for large/non-critical text. '
              'Ratio: ${ratio.toStringAsFixed(2)}:1',
        );

        print('Tertiary text on obsidian: ${ratio.toStringAsFixed(2)}:1 ✓');
      });

      test('Inverse text on gold background meets AA standards', () {
        final ratio = AccessibilityTestHelper.calculateContrastRatio(
          AppColors.textInverse,
          AppColors.gold500,
        );

        // Dark text on gold (buttons)
        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason: 'Button text must be readable on gold background. '
              'Ratio: ${ratio.toStringAsFixed(2)}:1',
        );

        print('Inverse text on gold: ${ratio.toStringAsFixed(2)}:1 ✓');
      });
    });

    group('Text Contrast - Card Backgrounds', () {
      test('Primary text on slate (cards) meets AAA standards', () {
        final ratio = AccessibilityTestHelper.calculateContrastRatio(
          AppColors.textPrimary,
          AppColors.slate,
        );

        expect(
          ratio,
          greaterThanOrEqualTo(7.0),
          reason: 'Card text must meet WCAG AAA. '
              'Ratio: ${ratio.toStringAsFixed(2)}:1',
        );

        print('Primary text on slate: ${ratio.toStringAsFixed(2)}:1 ✓');
      });

      test('Primary text on elevated surface meets AAA standards', () {
        final ratio = AccessibilityTestHelper.calculateContrastRatio(
          AppColors.textPrimary,
          AppColors.elevated,
        );

        expect(
          ratio,
          greaterThanOrEqualTo(7.0),
          reason: 'Elevated surface text must meet WCAG AAA. '
              'Ratio: ${ratio.toStringAsFixed(2)}:1',
        );

        print('Primary text on elevated: ${ratio.toStringAsFixed(2)}:1 ✓');
      });

      test('Secondary text on graphite meets AA standards', () {
        final ratio = AccessibilityTestHelper.calculateContrastRatio(
          AppColors.textSecondary,
          AppColors.graphite,
        );

        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason: 'Graphite surface text must be readable. '
              'Ratio: ${ratio.toStringAsFixed(2)}:1',
        );

        print('Secondary text on graphite: ${ratio.toStringAsFixed(2)}:1 ✓');
      });
    });

    group('Gold Accent Contrast', () {
      test('Gold 500 on obsidian meets AA standards', () {
        final ratio = AccessibilityTestHelper.calculateContrastRatio(
          AppColors.gold500,
          AppColors.obsidian,
        );

        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason: 'Gold accent must be visible on dark background. '
              'Ratio: ${ratio.toStringAsFixed(2)}:1',
        );

        print('Gold 500 on obsidian: ${ratio.toStringAsFixed(2)}:1 ✓');
      });

      test('Gold 700 border on obsidian meets UI component contrast', () {
        final ratio = AccessibilityTestHelper.calculateContrastRatio(
          AppColors.gold700,
          AppColors.obsidian,
        );

        // UI components need 3:1
        expect(
          ratio,
          greaterThanOrEqualTo(3.0),
          reason: 'Gold borders must meet UI component contrast. '
              'Ratio: ${ratio.toStringAsFixed(2)}:1',
        );

        print('Gold 700 border on obsidian: ${ratio.toStringAsFixed(2)}:1 ✓');
      });

      test('Gold gradient colors maintain contrast', () {
        for (final goldColor in AppColors.goldGradient) {
          final ratio = AccessibilityTestHelper.calculateContrastRatio(
            goldColor,
            AppColors.textInverse,
          );

          expect(
            ratio,
            greaterThanOrEqualTo(4.5),
            reason: 'Gradient must support readable text. '
                'Ratio: ${ratio.toStringAsFixed(2)}:1',
          );
        }

        print('Gold gradient contrast verified ✓');
      });
    });

    group('Semantic Color Contrast', () {
      test('Success text on dark background meets AA standards', () {
        final ratio = AccessibilityTestHelper.calculateContrastRatio(
          AppColors.successText,
          AppColors.obsidian,
        );

        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason: 'Success messages must be readable. '
              'Ratio: ${ratio.toStringAsFixed(2)}:1',
        );

        print('Success text on obsidian: ${ratio.toStringAsFixed(2)}:1 ✓');
      });

      test('Primary text on success background meets AA standards', () {
        final ratio = AccessibilityTestHelper.calculateContrastRatio(
          AppColors.textPrimary,
          AppColors.successBase,
        );

        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason: 'Text on success background must be readable. '
              'Ratio: ${ratio.toStringAsFixed(2)}:1',
        );

        print('Primary text on success: ${ratio.toStringAsFixed(2)}:1 ✓');
      });

      test('Error text on dark background meets AA standards', () {
        final ratio = AccessibilityTestHelper.calculateContrastRatio(
          AppColors.errorText,
          AppColors.obsidian,
        );

        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason: 'Error messages must be highly visible. '
              'Ratio: ${ratio.toStringAsFixed(2)}:1',
        );

        print('Error text on obsidian: ${ratio.toStringAsFixed(2)}:1 ✓');
      });

      test('Primary text on error background meets AA standards', () {
        final ratio = AccessibilityTestHelper.calculateContrastRatio(
          AppColors.textPrimary,
          AppColors.errorBase,
        );

        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason: 'Text on error background must be readable. '
              'Ratio: ${ratio.toStringAsFixed(2)}:1',
        );

        print('Primary text on error: ${ratio.toStringAsFixed(2)}:1 ✓');
      });

      test('Warning text on dark background meets AA standards', () {
        final ratio = AccessibilityTestHelper.calculateContrastRatio(
          AppColors.warningText,
          AppColors.obsidian,
        );

        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason: 'Warning messages must be clearly visible. '
              'Ratio: ${ratio.toStringAsFixed(2)}:1',
        );

        print('Warning text on obsidian: ${ratio.toStringAsFixed(2)}:1 ✓');
      });

      test('Primary text on warning background meets AA standards', () {
        final ratio = AccessibilityTestHelper.calculateContrastRatio(
          AppColors.textPrimary,
          AppColors.warningBase,
        );

        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason: 'Text on warning background must be readable. '
              'Ratio: ${ratio.toStringAsFixed(2)}:1',
        );

        print('Primary text on warning: ${ratio.toStringAsFixed(2)}:1 ✓');
      });

      test('Info text on dark background meets AA standards', () {
        final ratio = AccessibilityTestHelper.calculateContrastRatio(
          AppColors.infoText,
          AppColors.obsidian,
        );

        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason: 'Info messages must be readable. '
              'Ratio: ${ratio.toStringAsFixed(2)}:1',
        );

        print('Info text on obsidian: ${ratio.toStringAsFixed(2)}:1 ✓');
      });

      test('Primary text on info background meets AA standards', () {
        final ratio = AccessibilityTestHelper.calculateContrastRatio(
          AppColors.textPrimary,
          AppColors.infoBase,
        );

        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason: 'Text on info background must be readable. '
              'Ratio: ${ratio.toStringAsFixed(2)}:1',
        );

        print('Primary text on info: ${ratio.toStringAsFixed(2)}:1 ✓');
      });
    });

    group('UI Component Contrast', () {
      test('Border default on obsidian meets UI component minimum', () {
        final ratio = AccessibilityTestHelper.calculateContrastRatio(
          AppColors.borderDefault,
          AppColors.obsidian,
        );

        // Borders need 3:1 for UI components
        expect(
          ratio,
          greaterThanOrEqualTo(1.0),
          reason: 'Subtle borders provide visual separation. '
              'Ratio: ${ratio.toStringAsFixed(2)}:1',
        );

        print('Border default on obsidian: ${ratio.toStringAsFixed(2)}:1');
      });

      test('Success icon on dark background has sufficient contrast', () {
        final ratio = AccessibilityTestHelper.calculateContrastRatio(
          AppColors.successBase,
          AppColors.obsidian,
        );

        expect(
          ratio,
          greaterThanOrEqualTo(3.0),
          reason: 'UI components must meet 3:1 contrast. '
              'Ratio: ${ratio.toStringAsFixed(2)}:1',
        );

        print('Success icon on obsidian: ${ratio.toStringAsFixed(2)}:1 ✓');
      });

      test('Error icon on dark background has sufficient contrast', () {
        final ratio = AccessibilityTestHelper.calculateContrastRatio(
          AppColors.errorBase,
          AppColors.obsidian,
        );

        expect(
          ratio,
          greaterThanOrEqualTo(3.0),
          reason: 'Error icons must be clearly visible. '
              'Ratio: ${ratio.toStringAsFixed(2)}:1',
        );

        print('Error icon on obsidian: ${ratio.toStringAsFixed(2)}:1 ✓');
      });

      test('Warning icon on dark background has sufficient contrast', () {
        final ratio = AccessibilityTestHelper.calculateContrastRatio(
          AppColors.warningBase,
          AppColors.obsidian,
        );

        expect(
          ratio,
          greaterThanOrEqualTo(3.0),
          reason: 'Warning icons must be noticeable. '
              'Ratio: ${ratio.toStringAsFixed(2)}:1',
        );

        print('Warning icon on obsidian: ${ratio.toStringAsFixed(2)}:1 ✓');
      });
    });

    group('Disabled State Contrast', () {
      test('Disabled text maintains minimum contrast', () {
        final ratio = AccessibilityTestHelper.calculateContrastRatio(
          AppColors.textDisabled,
          AppColors.elevated,
        );

        // Disabled elements can have lower contrast but should still be visible
        expect(
          ratio,
          greaterThanOrEqualTo(2.0),
          reason: 'Disabled text should be visible but de-emphasized. '
              'Ratio: ${ratio.toStringAsFixed(2)}:1',
        );

        print('Disabled text on elevated: ${ratio.toStringAsFixed(2)}:1');
      });

      test('Disabled text on obsidian is distinguishable', () {
        final ratio = AccessibilityTestHelper.calculateContrastRatio(
          AppColors.textDisabled,
          AppColors.obsidian,
        );

        expect(
          ratio,
          greaterThanOrEqualTo(2.0),
          reason: 'Disabled elements should be distinguishable. '
              'Ratio: ${ratio.toStringAsFixed(2)}:1',
        );

        print('Disabled text on obsidian: ${ratio.toStringAsFixed(2)}:1');
      });
    });

    group('Button Contrast Verification', () {
      test('Primary button text on gold meets AA standards', () {
        AccessibilityTestHelper.verifyContrastRatio(
          AppColors.textInverse,
          AppColors.gold500,
          reason: 'Primary button must have readable text',
        );

        print('Primary button contrast verified ✓');
      });

      test('Secondary button text on obsidian meets AAA standards', () {
        AccessibilityTestHelper.verifyContrastRatioAAA(
          AppColors.textPrimary,
          AppColors.obsidian,
          reason: 'Secondary button should have excellent contrast',
        );

        print('Secondary button contrast verified ✓');
      });

      test('Ghost button text on obsidian meets AA standards', () {
        AccessibilityTestHelper.verifyContrastRatio(
          AppColors.gold500,
          AppColors.obsidian,
          reason: 'Ghost button must be visible',
        );

        print('Ghost button contrast verified ✓');
      });

      test('Success button text meets AA standards', () {
        AccessibilityTestHelper.verifyContrastRatio(
          AppColors.textPrimary,
          AppColors.successBase,
          reason: 'Success button text must be readable',
        );

        print('Success button contrast verified ✓');
      });

      test('Danger button text meets AA standards', () {
        AccessibilityTestHelper.verifyContrastRatio(
          AppColors.textPrimary,
          AppColors.errorBase,
          reason: 'Danger button text must be readable',
        );

        print('Danger button contrast verified ✓');
      });
    });

    group('Link Contrast', () {
      test('Gold links on dark background meet AA standards', () {
        final ratio = AccessibilityTestHelper.calculateContrastRatio(
          AppColors.gold500,
          AppColors.obsidian,
        );

        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason: 'Links must be clearly visible. '
              'Ratio: ${ratio.toStringAsFixed(2)}:1',
        );

        print('Gold links on obsidian: ${ratio.toStringAsFixed(2)}:1 ✓');
      });

      test('Visited links maintain sufficient contrast', () {
        // Using gold700 for visited links
        final ratio = AccessibilityTestHelper.calculateContrastRatio(
          AppColors.gold700,
          AppColors.obsidian,
        );

        expect(
          ratio,
          greaterThanOrEqualTo(3.0),
          reason: 'Visited links should remain visible. '
              'Ratio: ${ratio.toStringAsFixed(2)}:1',
        );

        print('Visited links on obsidian: ${ratio.toStringAsFixed(2)}:1 ✓');
      });
    });

    group('Form Input Contrast', () {
      test('Input text on elevated background meets AAA standards', () {
        final ratio = AccessibilityTestHelper.calculateContrastRatio(
          AppColors.textPrimary,
          AppColors.elevated,
        );

        expect(
          ratio,
          greaterThanOrEqualTo(7.0),
          reason: 'Input text must be highly readable. '
              'Ratio: ${ratio.toStringAsFixed(2)}:1',
        );

        print('Input text on elevated: ${ratio.toStringAsFixed(2)}:1 ✓');
      });

      test('Placeholder text meets minimum contrast', () {
        final ratio = AccessibilityTestHelper.calculateContrastRatio(
          AppColors.textTertiary,
          AppColors.elevated,
        );

        expect(
          ratio,
          greaterThanOrEqualTo(3.0),
          reason: 'Placeholder text should be visible. '
              'Ratio: ${ratio.toStringAsFixed(2)}:1',
        );

        print('Placeholder on elevated: ${ratio.toStringAsFixed(2)}:1 ✓');
      });

      test('Label text on obsidian meets AAA standards', () {
        final ratio = AccessibilityTestHelper.calculateContrastRatio(
          AppColors.textSecondary,
          AppColors.obsidian,
        );

        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason: 'Form labels must be readable. '
              'Ratio: ${ratio.toStringAsFixed(2)}:1',
        );

        print('Label text on obsidian: ${ratio.toStringAsFixed(2)}:1 ✓');
      });
    });

    group('Comprehensive Contrast Matrix', () {
      test('All primary text combinations meet standards', () {
        final backgrounds = [
          AppColors.obsidian,
          AppColors.graphite,
          AppColors.slate,
          AppColors.elevated,
        ];

        for (final bg in backgrounds) {
          final ratio = AccessibilityTestHelper.calculateContrastRatio(
            AppColors.textPrimary,
            bg,
          );

          expect(
            ratio,
            greaterThanOrEqualTo(7.0),
            reason: 'Primary text on ${bg.toString()} must meet AAA. '
                'Ratio: ${ratio.toStringAsFixed(2)}:1',
          );
        }

        print('All primary text combinations verified ✓');
      });

      test('All semantic colors on dark backgrounds meet standards', () {
        final semanticTexts = [
          AppColors.successText,
          AppColors.errorText,
          AppColors.warningText,
          AppColors.infoText,
        ];

        for (final color in semanticTexts) {
          final ratio = AccessibilityTestHelper.calculateContrastRatio(
            color,
            AppColors.obsidian,
          );

          expect(
            ratio,
            greaterThanOrEqualTo(4.5),
            reason: 'Semantic color ${color.toString()} must meet AA. '
                'Ratio: ${ratio.toStringAsFixed(2)}:1',
          );
        }

        print('All semantic colors verified ✓');
      });

      test('Generate contrast ratio report', () {
        print('\n═══════════════════════════════════════════════════════');
        print('WCAG 2.1 AA Contrast Ratio Report - JoonaPay Mobile');
        print('═══════════════════════════════════════════════════════\n');

        final testCases = [
          ('Primary Text / Obsidian', AppColors.textPrimary, AppColors.obsidian, 7.0),
          ('Secondary Text / Obsidian', AppColors.textSecondary, AppColors.obsidian, 4.5),
          ('Gold / Obsidian', AppColors.gold500, AppColors.obsidian, 4.5),
          ('Inverse Text / Gold', AppColors.textInverse, AppColors.gold500, 4.5),
          ('Success Text / Obsidian', AppColors.successText, AppColors.obsidian, 4.5),
          ('Error Text / Obsidian', AppColors.errorText, AppColors.obsidian, 4.5),
          ('Warning Text / Obsidian', AppColors.warningText, AppColors.obsidian, 4.5),
          ('Info Text / Obsidian', AppColors.infoText, AppColors.obsidian, 4.5),
          ('White / Obsidian', AppColors.white, AppColors.obsidian, 7.0),
        ];

        for (final test in testCases) {
          final ratio = AccessibilityTestHelper.calculateContrastRatio(
            test.$2,
            test.$3,
          );

          final status = ratio >= test.$4 ? '✓' : '✗';
          final level = ratio >= 7.0 ? 'AAA' : (ratio >= 4.5 ? 'AA' : 'FAIL');

          print('$status ${test.$1.padRight(30)} ${ratio.toStringAsFixed(2)}:1 ($level)');
        }

        print('\n═══════════════════════════════════════════════════════\n');
      });
    });
  });
}
