import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/security_settings_provider.dart';
import '../widgets/settings_section.dart';

/// Security settings screen.
class SecuritySettingsView extends ConsumerWidget {
  const SecuritySettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(securitySettingsProvider);
    final notifier = ref.read(securitySettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Security')),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          SettingsSection(
            title: 'Authentication',
            items: [
              SettingsToggle(
                leading: const Icon(Icons.fingerprint_rounded),
                title: 'Biometric Login',
                subtitle: 'Use Face ID or fingerprint to unlock',
                value: settings.biometricEnabled,
                onChanged: (v) => notifier.setBiometric(v),
              ),
              SettingsToggle(
                leading: const Icon(Icons.lock_clock_rounded),
                title: 'PIN on App Open',
                subtitle: 'Require PIN every time you open the app',
                value: settings.pinOnAppOpen,
                onChanged: (v) => notifier.setPinOnAppOpen(v),
              ),
              SettingsItem(
                leading: const Icon(Icons.timer_rounded),
                title: 'Auto-Lock',
                subtitle: 'After ${settings.autoLockMinutes} minutes of inactivity',
                onTap: () => _showAutoLockPicker(context, ref),
              ),
            ],
          ),
          SettingsSection(
            title: 'Privacy',
            items: [
              SettingsToggle(
                leading: const Icon(Icons.screenshot_rounded),
                title: 'Screenshot Protection',
                subtitle: 'Prevent screenshots in sensitive screens',
                value: settings.screenshotProtection,
                onChanged: (v) => notifier.setScreenshotProtection(v),
              ),
            ],
          ),
          SettingsSection(
            title: 'Alerts',
            items: [
              SettingsToggle(
                leading: const Icon(Icons.notifications_active_rounded),
                title: 'Transaction Alerts',
                subtitle: 'Get notified for every transaction',
                value: settings.transactionAlerts,
                onChanged: (v) => notifier.setTransactionAlerts(v),
              ),
            ],
          ),
          SettingsSection(
            title: 'Account',
            items: [
              SettingsItem(
                leading: const Icon(Icons.key_rounded),
                title: 'Change PIN',
                onTap: () {},
              ),
              SettingsItem(
                leading: const Icon(Icons.devices_rounded),
                title: 'Manage Devices',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAutoLockPicker(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Auto-Lock After'),
        children: [1, 2, 5, 10, 15, 30].map((minutes) {
          return SimpleDialogOption(
            onPressed: () {
              ref.read(securitySettingsProvider.notifier).setAutoLock(minutes);
              Navigator.pop(context);
            },
            child: Text('$minutes minutes'),
          );
        }).toList(),
      ),
    );
  }
}
