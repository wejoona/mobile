import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/design/theme/theme_provider.dart';

void main() {
  test('default app theme is dark unless the user saved another choice', () {
    const state = ThemeState();

    expect(state.mode, AppThemeMode.dark);
    expect(state.isDark(Brightness.light), isTrue);
    expect(
      state.getSystemUiStyle(Brightness.light).statusBarBrightness,
      Brightness.dark,
    );
  });
}
