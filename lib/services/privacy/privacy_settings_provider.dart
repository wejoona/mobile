import 'package:flutter_riverpod/legacy.dart';

/// Paramètres de confidentialité
class PrivacySettings {
  final bool analyticsEnabled;
  final bool crashReportingEnabled;
  final bool marketingEnabled;
  final bool locationSharingEnabled;
  final bool biometricStorageEnabled;
  final bool transactionHistoryVisible;
  final bool balanceVisible;
  final Duration autoLockTimeout;
  final bool hideNotificationContent;

  const PrivacySettings({
    this.analyticsEnabled = true,
    this.crashReportingEnabled = true,
    this.marketingEnabled = false,
    this.locationSharingEnabled = false,
    this.biometricStorageEnabled = true,
    this.transactionHistoryVisible = true,
    this.balanceVisible = true,
    this.autoLockTimeout = const Duration(minutes: 5),
    this.hideNotificationContent = false,
  });

  PrivacySettings copyWith({
    bool? analyticsEnabled,
    bool? crashReportingEnabled,
    bool? marketingEnabled,
    bool? locationSharingEnabled,
    bool? biometricStorageEnabled,
    bool? transactionHistoryVisible,
    bool? balanceVisible,
    Duration? autoLockTimeout,
    bool? hideNotificationContent,
  }) => PrivacySettings(
    analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
    crashReportingEnabled: crashReportingEnabled ?? this.crashReportingEnabled,
    marketingEnabled: marketingEnabled ?? this.marketingEnabled,
    locationSharingEnabled: locationSharingEnabled ?? this.locationSharingEnabled,
    biometricStorageEnabled: biometricStorageEnabled ?? this.biometricStorageEnabled,
    transactionHistoryVisible: transactionHistoryVisible ?? this.transactionHistoryVisible,
    balanceVisible: balanceVisible ?? this.balanceVisible,
    autoLockTimeout: autoLockTimeout ?? this.autoLockTimeout,
    hideNotificationContent: hideNotificationContent ?? this.hideNotificationContent,
  );

  Map<String, dynamic> toJson() => {
    'analyticsEnabled': analyticsEnabled,
    'crashReportingEnabled': crashReportingEnabled,
    'marketingEnabled': marketingEnabled,
    'locationSharingEnabled': locationSharingEnabled,
    'biometricStorageEnabled': biometricStorageEnabled,
    'transactionHistoryVisible': transactionHistoryVisible,
    'balanceVisible': balanceVisible,
    'autoLockTimeoutMinutes': autoLockTimeout.inMinutes,
    'hideNotificationContent': hideNotificationContent,
  };

  factory PrivacySettings.fromJson(Map<String, dynamic> json) => PrivacySettings(
    analyticsEnabled: json['analyticsEnabled'] as bool? ?? true,
    crashReportingEnabled: json['crashReportingEnabled'] as bool? ?? true,
    marketingEnabled: json['marketingEnabled'] as bool? ?? false,
    locationSharingEnabled: json['locationSharingEnabled'] as bool? ?? false,
    biometricStorageEnabled: json['biometricStorageEnabled'] as bool? ?? true,
    transactionHistoryVisible: json['transactionHistoryVisible'] as bool? ?? true,
    balanceVisible: json['balanceVisible'] as bool? ?? true,
    autoLockTimeout: Duration(minutes: json['autoLockTimeoutMinutes'] as int? ?? 5),
    hideNotificationContent: json['hideNotificationContent'] as bool? ?? false,
  );
}

/// Fournisseur des paramètres de confidentialité
class PrivacySettingsNotifier extends StateNotifier<PrivacySettings> {
  PrivacySettingsNotifier() : super(const PrivacySettings());

  void updateAnalytics(bool enabled) =>
      state = state.copyWith(analyticsEnabled: enabled);
  void updateMarketing(bool enabled) =>
      state = state.copyWith(marketingEnabled: enabled);
  void updateLocationSharing(bool enabled) =>
      state = state.copyWith(locationSharingEnabled: enabled);
  void updateBalanceVisibility(bool visible) =>
      state = state.copyWith(balanceVisible: visible);
  void updateAutoLockTimeout(Duration timeout) =>
      state = state.copyWith(autoLockTimeout: timeout);
  void updateHideNotificationContent(bool hide) =>
      state = state.copyWith(hideNotificationContent: hide);
  void loadFromJson(Map<String, dynamic> json) =>
      state = PrivacySettings.fromJson(json);
}

final privacySettingsProvider =
    StateNotifierProvider<PrivacySettingsNotifier, PrivacySettings>((ref) {
  return PrivacySettingsNotifier();
});
