/// DEPRECATED: Use the consolidated notification preferences provider from settings.
///
/// This file re-exports the settings notification preferences provider
/// to maintain backward compatibility. All notification preference logic
/// lives in `lib/features/settings/providers/notification_preferences_provider.dart`.
library;

export 'package:usdc_wallet/features/settings/providers/notification_preferences_provider.dart';

/// Legacy alias — prefer using `notificationPreferencesProvider` directly.
/// This provider name is kept for backward compatibility with screens
/// that imported `notificationPreferencesNotifierProvider`.
///
/// Migration: replace `notificationPreferencesNotifierProvider` with
/// `notificationPreferencesProvider` in consuming views.
