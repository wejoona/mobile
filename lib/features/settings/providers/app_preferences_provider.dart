import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-level preferences (non-sensitive, stored in SharedPreferences).
class AppPreferences {
  final String locale;
  final bool isDarkMode;
  final bool showBalance;
  final bool hapticFeedback;
  final bool pushNotifications;
  final bool transactionAlerts;
  final bool marketingEmails;
  final String defaultCurrency;

  const AppPreferences({
    this.locale = 'fr',
    this.isDarkMode = false,
    this.showBalance = true,
    this.hapticFeedback = true,
    this.pushNotifications = true,
    this.transactionAlerts = true,
    this.marketingEmails = false,
    this.defaultCurrency = 'USDC',
  });

  AppPreferences copyWith({
    String? locale,
    bool? isDarkMode,
    bool? showBalance,
    bool? hapticFeedback,
    bool? pushNotifications,
    bool? transactionAlerts,
    bool? marketingEmails,
    String? defaultCurrency,
  }) => AppPreferences(
    locale: locale ?? this.locale,
    isDarkMode: isDarkMode ?? this.isDarkMode,
    showBalance: showBalance ?? this.showBalance,
    hapticFeedback: hapticFeedback ?? this.hapticFeedback,
    pushNotifications: pushNotifications ?? this.pushNotifications,
    transactionAlerts: transactionAlerts ?? this.transactionAlerts,
    marketingEmails: marketingEmails ?? this.marketingEmails,
    defaultCurrency: defaultCurrency ?? this.defaultCurrency,
  );
}

/// App preferences notifier — persists to SharedPreferences.
class AppPreferencesNotifier extends Notifier<AppPreferences> {
  static const _prefix = 'korido_pref_';

  @override
  AppPreferences build() {
    _load();
    return const AppPreferences();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = AppPreferences(
      locale: prefs.getString('${_prefix}locale') ?? 'fr',
      isDarkMode: prefs.getBool('${_prefix}darkMode') ?? false,
      showBalance: prefs.getBool('${_prefix}showBalance') ?? true,
      hapticFeedback: prefs.getBool('${_prefix}haptic') ?? true,
      pushNotifications: prefs.getBool('${_prefix}push') ?? true,
      transactionAlerts: prefs.getBool('${_prefix}txAlerts') ?? true,
      marketingEmails: prefs.getBool('${_prefix}marketing') ?? false,
      defaultCurrency: prefs.getString('${_prefix}currency') ?? 'USDC',
    );
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_prefix}locale', state.locale);
    await prefs.setBool('${_prefix}darkMode', state.isDarkMode);
    await prefs.setBool('${_prefix}showBalance', state.showBalance);
    await prefs.setBool('${_prefix}haptic', state.hapticFeedback);
    await prefs.setBool('${_prefix}push', state.pushNotifications);
    await prefs.setBool('${_prefix}txAlerts', state.transactionAlerts);
    await prefs.setBool('${_prefix}marketing', state.marketingEmails);
    await prefs.setString('${_prefix}currency', state.defaultCurrency);
  }

  Future<void> setLocale(String locale) async {
    state = state.copyWith(locale: locale);
    await _save();
  }

  Future<void> toggleDarkMode() async {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
    await _save();
  }

  Future<void> toggleBalanceVisibility() async {
    state = state.copyWith(showBalance: !state.showBalance);
    await _save();
  }

  Future<void> setHapticFeedback(bool enabled) async {
    state = state.copyWith(hapticFeedback: enabled);
    await _save();
  }

  Future<void> setPushNotifications(bool enabled) async {
    state = state.copyWith(pushNotifications: enabled);
    await _save();
  }

  Future<void> setTransactionAlerts(bool enabled) async {
    state = state.copyWith(transactionAlerts: enabled);
    await _save();
  }
}

final appPreferencesProvider = NotifierProvider<AppPreferencesNotifier, AppPreferences>(AppPreferencesNotifier.new);
