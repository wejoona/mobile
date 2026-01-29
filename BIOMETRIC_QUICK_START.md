# Biometric Feature - Quick Start Guide

## Quick Access

### Navigate to Biometric Settings
```dart
context.push('/settings/biometric');
```

### Start Enrollment
```dart
final result = await context.push<bool>('/settings/biometric/enrollment');
if (result == true) {
  // User enrolled successfully
}
```

## Check Biometric Status

### Is Biometric Enabled?
```dart
final biometricEnabled = ref.watch(biometricEnabledProvider);
biometricEnabled.when(
  data: (enabled) => enabled ? 'Enabled' : 'Disabled',
  loading: () => 'Loading...',
  error: (e, s) => 'Error',
);
```

### Get Biometric Type
```dart
final biometricType = ref.watch(primaryBiometricTypeProvider);
biometricType.when(
  data: (type) {
    switch (type) {
      case BiometricType.faceId: return 'Face ID';
      case BiometricType.fingerprint: return 'Fingerprint';
      case BiometricType.iris: return 'Iris';
      case BiometricType.none: return 'None';
    }
  },
  loading: () => 'Detecting...',
  error: (e, s) => 'Unknown',
);
```

## Authenticate

### Simple Authentication
```dart
final service = ref.read(biometricServiceProvider);
final authenticated = await service.authenticate(
  reason: 'Unlock your wallet',
);

if (authenticated) {
  // Success
} else {
  // Failed or cancelled
}
```

### Sensitive Action Authentication
```dart
final service = ref.read(biometricServiceProvider);
final authenticated = await service.authenticateSensitive(
  reason: 'Confirm high-value transaction',
);
```

## Check Settings

### Get All Settings
```dart
final settings = ref.watch(biometricSettingsProvider);

print('Enabled: ${settings.isBiometricEnabled}');
print('App Unlock: ${settings.requireForAppUnlock}');
print('Transactions: ${settings.requireForTransactions}');
print('Sensitive: ${settings.requireForSensitiveSettings}');
print('View Balance: ${settings.requireForViewBalance}');
print('Timeout: ${settings.biometricTimeoutMinutes} min');
print('Threshold: \$${settings.highValueThreshold}');
```

### Check if Required for Action
```dart
final notifier = ref.read(biometricSettingsProvider.notifier);

if (notifier.isRequiredFor(BiometricAction.appUnlock)) {
  // Require biometric for app unlock
}

if (notifier.isRequiredFor(BiometricAction.transaction)) {
  // Require biometric for transactions
}

if (notifier.isRequiredFor(BiometricAction.sensitiveSettings)) {
  // Require biometric for sensitive settings
}

if (notifier.isRequiredFor(BiometricAction.viewBalance)) {
  // Require biometric to view balance
}
```

### Check if Required for Amount
```dart
final notifier = ref.read(biometricSettingsProvider.notifier);
final transferAmount = 1500.0;

if (notifier.isRequiredForAmount(transferAmount)) {
  // This is a high-value transaction
  // Require biometric + PIN
}
```

## Update Settings

### Enable/Disable Biometric
```dart
final notifier = ref.read(biometricSettingsProvider.notifier);
await notifier.setBiometricEnabled(true);
ref.invalidate(biometricEnabledProvider); // Refresh UI
```

### Toggle Use Cases
```dart
final notifier = ref.read(biometricSettingsProvider.notifier);

await notifier.setRequireForAppUnlock(true);
await notifier.setRequireForTransactions(true);
await notifier.setRequireForSensitiveSettings(true);
await notifier.setRequireForViewBalance(false);
```

### Set Timeout
```dart
final notifier = ref.read(biometricSettingsProvider.notifier);

// 0 = immediate, 5 = 5 min, 15 = 15 min, 30 = 30 min
await notifier.setBiometricTimeout(5);
```

### Set High-Value Threshold
```dart
final notifier = ref.read(biometricSettingsProvider.notifier);

// Amount in USD
await notifier.setHighValueThreshold(1000.0);
```

## Device Change Detection

### Check on App Start
```dart
class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBiometricChange();
    });
  }

  Future<void> _checkBiometricChange() async {
    final service = ref.read(biometricServiceProvider);
    final result = await service.handleBiometricChange();

    if (result.requiresReEnrollment) {
      // Show dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.biometric_change_detected_title),
          content: Text(l10n.biometric_change_detected_message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.action_cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.push('/settings/biometric/enrollment');
              },
              child: Text(l10n.biometric_settings_reenroll_title),
            ),
          ],
        ),
      );
    }
  }
}
```

### Manual Hash Update
```dart
final service = ref.read(biometricServiceProvider);
await service.updateBiometricHash();
```

## Timeout Management

### Check Timeout
```dart
final service = ref.read(biometricServiceProvider);
final settings = ref.read(biometricSettingsProvider);

final hasTimedOut = await service.hasBiometricTimedOut(
  settings.biometricTimeoutMinutes,
);

if (hasTimedOut) {
  // Require re-authentication
  final authenticated = await service.authenticate(
    reason: 'Session expired',
  );

  if (authenticated) {
    await service.updateLastBiometricCheck();
  }
}
```

### Update Last Check
```dart
final service = ref.read(biometricServiceProvider);
await service.updateLastBiometricCheck();
```

## Common Patterns

### Transaction Flow with Biometric
```dart
Future<void> _handleTransaction(double amount) async {
  final settings = ref.read(biometricSettingsProvider);
  final service = ref.read(biometricServiceProvider);

  // Check if biometric is required
  if (settings.requireForTransactions) {
    // Check if high-value (requires biometric + PIN)
    if (settings.isRequiredForAmount(amount)) {
      // High-value: Require both
      final biometricAuth = await service.authenticateSensitive(
        reason: 'Confirm transfer of \$${amount.toStringAsFixed(2)}',
      );

      if (!biometricAuth) {
        _showError('Biometric authentication required');
        return;
      }

      final pinAuth = await _verifyPin();
      if (!pinAuth) {
        _showError('PIN verification required');
        return;
      }
    } else {
      // Normal transaction: Biometric only
      final biometricAuth = await service.authenticate(
        reason: 'Confirm transfer',
      );

      if (!biometricAuth) {
        _showError('Authentication required');
        return;
      }
    }
  }

  // Proceed with transaction
  await _executeTransaction(amount);
}
```

### App Unlock Flow
```dart
class AppLockWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<AppLockWidget> createState() => _AppLockWidgetState();
}

class _AppLockWidgetState extends ConsumerState<AppLockWidget>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAppUnlock();
    }
  }

  Future<void> _checkAppUnlock() async {
    final settings = ref.read(biometricSettingsProvider);

    if (!settings.requireForAppUnlock) return;

    final service = ref.read(biometricServiceProvider);

    // Check timeout
    final hasTimedOut = await service.hasBiometricTimedOut(
      settings.biometricTimeoutMinutes,
    );

    if (hasTimedOut) {
      final authenticated = await service.authenticate(
        reason: 'Unlock JoonaPay',
      );

      if (authenticated) {
        await service.updateLastBiometricCheck();
      } else {
        // Lock app or show PIN screen
        _lockApp();
      }
    }
  }

  void _lockApp() {
    // Navigate to PIN screen or show lock overlay
  }
}
```

### Sensitive Settings Access
```dart
Future<void> _openSensitiveSettings() async {
  final settings = ref.read(biometricSettingsProvider);

  if (settings.requireForSensitiveSettings && settings.isBiometricEnabled) {
    final service = ref.read(biometricServiceProvider);
    final authenticated = await service.authenticateSensitive(
      reason: 'Access security settings',
    );

    if (!authenticated) {
      _showError('Authentication required');
      return;
    }
  }

  // Open settings
  context.push('/settings/pin');
}
```

### View Balance with Biometric
```dart
class BalanceWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<BalanceWidget> createState() => _BalanceWidgetState();
}

class _BalanceWidgetState extends ConsumerState<BalanceWidget> {
  bool _balanceVisible = false;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(biometricSettingsProvider);
    final balance = ref.watch(walletBalanceProvider);

    if (settings.requireForViewBalance && !_balanceVisible) {
      return InkWell(
        onTap: _revealBalance,
        child: Row(
          children: [
            Icon(Icons.visibility_off),
            SizedBox(width: 8),
            Text('Tap to view balance'),
          ],
        ),
      );
    }

    return Text('\$${balance.toStringAsFixed(2)}');
  }

  Future<void> _revealBalance() async {
    final service = ref.read(biometricServiceProvider);
    final authenticated = await service.authenticate(
      reason: 'View wallet balance',
    );

    if (authenticated) {
      setState(() => _balanceVisible = true);
    }
  }
}
```

## Error Handling

### Handle Biometric Errors
```dart
try {
  final service = ref.read(biometricServiceProvider);
  final authenticated = await service.authenticate(
    reason: 'Authenticate',
  );

  if (!authenticated) {
    // User cancelled or failed
    _showError(l10n.biometric_error_failed);
  }
} on PlatformException catch (e) {
  switch (e.code) {
    case 'NotAvailable':
      _showError(l10n.biometric_error_hardware_unavailable);
      break;
    case 'NotEnrolled':
      _showError(l10n.biometric_error_not_enrolled);
      break;
    case 'LockedOut':
    case 'PermanentlyLockedOut':
      _showError(l10n.biometric_error_lockout);
      break;
    default:
      _showError(l10n.biometric_enrollment_error_generic);
  }
}
```

## Localization

All strings are available in both English and French:

### Enrollment Flow
- `biometric_enrollment_title`
- `biometric_enrollment_subtitle`
- `biometric_enrollment_enable`
- `biometric_enrollment_skip`
- `biometric_enrollment_benefit_fast_title`
- `biometric_enrollment_benefit_fast_desc`
- `biometric_enrollment_benefit_secure_title`
- `biometric_enrollment_benefit_secure_desc`
- `biometric_enrollment_benefit_convenient_title`
- `biometric_enrollment_benefit_convenient_desc`
- `biometric_enrollment_success_title`
- `biometric_enrollment_success_message`

### Settings
- `biometric_settings_title`
- `biometric_settings_app_unlock_title`
- `biometric_settings_transactions_title`
- `biometric_settings_sensitive_title`
- `biometric_settings_view_balance_title`
- `biometric_settings_timeout_title`
- `biometric_settings_high_value_title`

### Errors
- `biometric_error_lockout`
- `biometric_error_not_enrolled`
- `biometric_error_hardware_unavailable`
- `biometric_change_detected_title`
- `biometric_change_detected_message`

### Types
- `biometric_type_face_id`
- `biometric_type_fingerprint`
- `biometric_type_iris`

## Testing

### Mock Biometric Service
```dart
class MockBiometricService extends BiometricService {
  bool shouldAuthenticate = true;
  BiometricType mockType = BiometricType.fingerprint;

  @override
  Future<bool> authenticate({String? reason, bool sensitiveAction = false}) async {
    await Future.delayed(Duration(milliseconds: 500));
    return shouldAuthenticate;
  }

  @override
  Future<BiometricType> getPrimaryBiometricType() async {
    return mockType;
  }
}
```

### Unit Test Example
```dart
void main() {
  group('BiometricSettingsNotifier', () {
    test('should update timeout setting', () async {
      final container = ProviderContainer();
      final notifier = container.read(biometricSettingsProvider.notifier);

      await notifier.setBiometricTimeout(15);

      final state = container.read(biometricSettingsProvider);
      expect(state.biometricTimeoutMinutes, equals(15));
    });

    test('should check if required for high-value amount', () {
      final container = ProviderContainer();
      final notifier = container.read(biometricSettingsProvider.notifier);

      notifier.setBiometricEnabled(true);
      notifier.setRequireForTransactions(true);
      notifier.setHighValueThreshold(1000.0);

      expect(notifier.isRequiredForAmount(1500.0), isTrue);
      expect(notifier.isRequiredForAmount(500.0), isFalse);
    });
  });
}
```

## Support

For issues or questions:
1. Check the full documentation in `BIOMETRIC_ENHANCEMENT_SUMMARY.md`
2. Review error handling patterns above
3. Check localization strings in `lib/l10n/app_en.arb` and `app_fr.arb`
4. Refer to the design system in `lib/design/`
