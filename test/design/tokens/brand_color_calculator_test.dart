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
      expect(BrandColorCalculator.toHex(calculated), '#C6A84F');

      // The logo color remains calculated from the dark identity gold and is
      // intentionally separate from the brighter action gold.
      expect(
        BrandColorCalculator.contrastRatio(calculated, AppColorsLight.canvas),
        greaterThan(
          BrandColorCalculator.contrastRatio(
            AppColorsLight.gold300,
            AppColorsLight.canvas,
          ),
        ),
      );
      expect(BrandColorCalculator.toHex(calculated), isNot('#E0BE65'));
      expect(BrandColorCalculator.toHex(calculated), isNot('#D4AF37'));
      expect(calculated, isNot(AppColorsLight.gold500));
    });

    test(
      'derives a light logo material ramp from the calculated base gold',
      () {
        final ramp = BrandColorCalculator.deriveLightIdentityGoldRamp(
          baseGold: AppColorsLight.logoGold,
        );

        expect(ramp.map(BrandColorCalculator.toHex), [
          '#CFB756',
          '#C6A84F',
          '#B29A3A',
        ]);
        expect(ramp[1], AppColorsLight.logoGold);
      },
    );
  });
}
