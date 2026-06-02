import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

void main() {
  group('BrandColorCalculator', () {
    test('derives light logo gold from the dark identity gold', () {
      final calculated = BrandColorCalculator.deriveLightIdentityGold(
        darkIdentityGold: AppColors.gold500,
        darkCanvas: AppColors.obsidian,
        lightCanvas: AppColorsLight.canvas,
      );

      expect(calculated, AppColorsLight.logoGold);
      expect(
        BrandColorCalculator.contrastRatio(calculated, AppColorsLight.canvas),
        closeTo(2.13, 0.04),
      );
      expect(BrandColorCalculator.toHex(calculated), '#C1A44A');

      // The calculated color sits between the two failed manual attempts:
      // gold300 was too yellow, while gold500 was too dark/orange.
      expect(
        BrandColorCalculator.contrastRatio(calculated, AppColorsLight.canvas),
        greaterThan(
          BrandColorCalculator.contrastRatio(
            AppColorsLight.gold300,
            AppColorsLight.canvas,
          ),
        ),
      );
      expect(
        BrandColorCalculator.contrastRatio(calculated, AppColorsLight.canvas),
        lessThan(
          BrandColorCalculator.contrastRatio(
            AppColorsLight.gold500,
            AppColorsLight.canvas,
          ),
        ),
      );
      expect(BrandColorCalculator.toHex(calculated), isNot('#F0CD68'));
      expect(BrandColorCalculator.toHex(calculated), isNot('#C08A25'));
    });

    test(
      'derives a light logo material ramp from the calculated base gold',
      () {
        final ramp = BrandColorCalculator.deriveLightIdentityGoldRamp(
          baseGold: AppColorsLight.logoGold,
        );

        expect(ramp.map(BrandColorCalculator.toHex), [
          '#CAB351',
          '#C1A44A',
          '#AD9635',
        ]);
        expect(ramp[1], AppColorsLight.logoGold);
      },
    );
  });
}
