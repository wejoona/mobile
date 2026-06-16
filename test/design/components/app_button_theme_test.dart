import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/design/components/primitives/app_button.dart';
import 'package:usdc_wallet/design/theme/app_theme.dart';
import 'package:usdc_wallet/design/tokens/colors.dart';

void main() {
  group('AppButton theme contract', () {
    testWidgets('light primary button uses warm white text and icon', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: AppButton(
                label: 'Stay Logged In',
                icon: Icons.verified_user_rounded,
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Stay Logged In'));
      final icon = tester.widget<Icon>(
        find.byIcon(Icons.verified_user_rounded),
      );

      expect(text.style?.color, AppColorsLight.textOnGold);
      expect(icon.color, AppColorsLight.textOnGold);
    });
  });
}
