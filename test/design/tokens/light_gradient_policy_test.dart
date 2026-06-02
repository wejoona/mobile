import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/design/theme/app_theme.dart';
import 'package:usdc_wallet/design/theme/theme_extensions.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

void main() {
  group('Light gradient policy', () {
    testWidgets('uses quiet solid gold for ordinary light theme gradients', (
      tester,
    ) async {
      late List<Color> themeColorsGradient;
      late LinearGradient extensionGradient;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(
            builder: (context) {
              themeColorsGradient = context.colors.goldGradient;
              extensionGradient = context.appGradients.goldGradient;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(themeColorsGradient, [
        AppColorsLight.logoGold,
        AppColorsLight.logoGold,
      ]);
      expect(extensionGradient.colors, [
        AppColorsLight.logoGold,
        AppColorsLight.logoGold,
      ]);
    });
  });
}
