import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/settings/providers/security_settings_provider.dart';
import 'package:usdc_wallet/features/settings/widgets/settings_section.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/spacing.dart';

/// Security settings screen.
class SecuritySettingsView extends ConsumerWidget {
  const SecuritySettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(securitySettingsProvider);
    final notifier = ref.read(securitySettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.security_title)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(securitySettingsProvider);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: AppSpacing.lg),
            SettingsSection(
              title: l10n.security_authentication,
              items: [
                SettingsToggle(
                  leading: const Icon(Icons.fingerprint_rounded),
                  title: l10n.security_biometricLogin,
                  subtitle: l10n.security_biometricSubtitle,
                  value: settings.biometricEnabled,
                  onChanged: (v) => notifier.setBiometric(v),
                ),
                SettingsToggle(
                  leading: const Icon(Icons.lock_clock_rounded),
                  title: l10n.security_pinOnAppOpen,
                  subtitle: l10n.security_pinOnAppOpenSubtitle,
                  value: settings.pinOnAppOpen,
                  onChanged: (v) => notifier.setPinOnAppOpen(v),
                ),
                SettingsItem(
                  leading: const Icon(Icons.timer_rounded),
                  title: l10n.security_autoLock,
                  subtitle: l10n.security_autoLockMinutes(settings.autoLockMinutes),
                  onTap: () => _showAutoLockPicker(context, ref),
                ),
              ],
            ),
            SettingsSection(
              title: l10n.security_privacy,
              items: [
                SettingsToggle(
                  leading: const Icon(Icons.screenshot_rounded),
                  title: l10n.security_screenshotProtection,
                  subtitle: l10n.security_screenshotProtectionSubtitle,
                  value: settings.screenshotProtection,
                  onChanged: (v) => notifier.setScreenshotProtection(v),
                ),
              ],
            ),
            SettingsSection(
              title: l10n.security_alerts,
              items: [
                SettingsToggle(
                  leading: const Icon(Icons.notifications_active_rounded),
                  title: l10n.security_transactionAlerts,
                  subtitle: l10n.security_transactionAlertsSubtitle,
                  value: settings.transactionAlerts,
                  onChanged: (v) => notifier.setTransactionAlerts(v),
                ),
              ],
            ),
            SettingsSection(
              title: l10n.security_account,
              items: [
                SettingsItem(
                  leading: const Icon(Icons.key_rounded),
                  title: l10n.security_changePin,
                  onTap: () {},
                ),
                SettingsItem(
                  leading: const Icon(Icons.devices_rounded),
                  title: l10n.security_manageDevices,
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAutoLockPicker(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.security_autoLockAfter),
        children: [1, 2, 5, 10, 15, 30].map((minutes) {
          return SimpleDialogOption(
            onPressed: () {
              ref.read(securitySettingsProvider.notifier).setAutoLock(minutes);
              Navigator.pop(context);
            },
            child: Text(l10n.security_minutesFormat(minutes)),
          );
        }).toList(),
      ),
    );
  }
}
