import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Run 380: App-wide preferences provider (language, theme, currency display)
class AppPreferences {
  final String locale;
  final String themeMode; // light, dark, system
  final String defaultCurrency;
  final bool showBalanceOnHome;
  final bool enableHaptics;
  final bool enableAnimations;
  final bool compactTransactionList;
  final int decimalPlaces;

  const AppPreferences({
    this.locale = 'fr',
    this.themeMode = 'dark',
    this.defaultCurrency = 'USDC',
    this.showBalanceOnHome = true,
    this.enableHaptics = true,
    this.enableAnimations = true,
    this.compactTransactionList = false,
    this.decimalPlaces = 2,
  });

  AppPreferences copyWith({
    String? locale,
    String? themeMode,
    String? defaultCurrency,
    bool? showBalanceOnHome,
    bool? enableHaptics,
    bool? enableAnimations,
    bool? compactTransactionList,
    int? decimalPlaces,
  }) => AppPreferences(
    locale: locale ?? this.locale,
    themeMode: themeMode ?? this.themeMode,
    defaultCurrency: defaultCurrency ?? this.defaultCurrency,
    showBalanceOnHome: showBalanceOnHome ?? this.showBalanceOnHome,
    enableHaptics: enableHaptics ?? this.enableHaptics,
    enableAnimations: enableAnimations ?? this.enableAnimations,
    compactTransactionList: compactTransactionList ?? this.compactTransactionList,
    decimalPlaces: decimalPlaces ?? this.decimalPlaces,
  );
}

class AppPreferencesNotifier extends StateNotifier<AppPreferences> {
  AppPreferencesNotifier() : super(const AppPreferences());

  void setLocale(String locale) => state = state.copyWith(locale: locale);
  void setThemeMode(String mode) => state = state.copyWith(themeMode: mode);
  void setDefaultCurrency(String currency) =>
      state = state.copyWith(defaultCurrency: currency);
  void toggleBalanceVisibility() =>
      state = state.copyWith(showBalanceOnHome: !state.showBalanceOnHome);
  void toggleHaptics() =>
      state = state.copyWith(enableHaptics: !state.enableHaptics);
  void toggleAnimations() =>
      state = state.copyWith(enableAnimations: !state.enableAnimations);
  void setCompactList(bool compact) =>
      state = state.copyWith(compactTransactionList: compact);
}

final appPreferencesProvider =
    StateNotifierProvider<AppPreferencesNotifier, AppPreferences>((ref) {
  return AppPreferencesNotifier();
});
