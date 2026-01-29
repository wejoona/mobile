# Widget Data Service

Service layer for sharing data between the main Flutter app and native home screen widgets.

## Overview

The Widget Data Service provides a secure, cross-platform way to store and retrieve data that widgets need to display. It handles the platform-specific differences between iOS (Keychain with App Groups) and Android (Encrypted SharedPreferences).

## Architecture

```
┌─────────────────────────────────────────┐
│  Flutter App                             │
│                                          │
│  WidgetUpdateManager                     │
│  ├─ Listens to state changes            │
│  ├─ Calls WidgetDataService             │
│  └─ Notifies native widgets             │
│          ↓                               │
│  WidgetDataService                       │
│  ├─ Stores data securely                │
│  └─ Platform-specific implementation     │
└─────────────────────────────────────────┘
            ↓
    ┌───────┴────────┐
    ↓                ↓
iOS Keychain    Android Encrypted
(App Groups)    SharedPreferences
```

## Components

### WidgetDataService

Core service for storing widget data.

**Key Methods:**

```dart
// Update balance
await widgetDataService.updateBalance(
  balance: 1234.56,
  currency: 'USD',
  userName: 'Amadou Diallo',
);

// Update last transaction
await widgetDataService.updateLastTransaction(
  type: 'send',
  amount: 50.0,
  currency: 'USD',
  status: 'completed',
  recipientName: 'Fatou Traore',
);

// Get current data
final data = await widgetDataService.getWidgetData();
print(data.formattedBalance); // "$1,234.56"

// Clear on logout
await widgetDataService.clearWidgetData();
```

### WidgetUpdateManager

Manages widget updates and method channel communication.

**Key Methods:**

```dart
final manager = ref.read(widgetUpdateManagerProvider);

// Update from current state
await manager.updateFromState(
  balance: walletState.usdcBalance,
  currency: 'USD',
  userName: userName,
);

// Update transaction info
await manager.updateLastTransaction(
  type: 'send',
  amount: 50.0,
  currency: 'USD',
  status: 'completed',
);

// Clear data
await manager.clearWidgetData();
```

### WidgetAutoUpdater

Automatically updates widgets when app state changes.

**Usage:**

```dart
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize auto-updater
    ref.watch(widgetAutoUpdaterProvider);

    return MaterialApp(...);
  }
}
```

## Data Storage

### iOS (Keychain with App Groups)

- **Storage**: iOS Keychain
- **App Group**: `group.com.joonapay.usdcwallet`
- **Accessibility**: `first_unlock` (available after first device unlock)
- **Security**: Encrypted by system, requires device passcode

**Configuration:**

1. Enable App Groups capability in Xcode
2. Add group identifier to both app and widget targets
3. WidgetDataService automatically uses correct group

### Android (Encrypted SharedPreferences)

- **Storage**: SharedPreferences
- **Name**: `FlutterSharedPreferences`
- **Encryption**: Enabled via `encryptedSharedPreferences: true`
- **Security**: AES-256 encryption using Android Keystore

**Configuration:**

1. SharedPreferences automatically created by Flutter
2. Encryption enabled in WidgetDataService constructor
3. Widget reads same SharedPreferences instance

## Data Schema

### Stored Keys

| Key | Type | Description |
|-----|------|-------------|
| `widget_balance` | Double | Current USDC balance |
| `widget_currency` | String | Currency code (USD, XOF) |
| `widget_last_updated` | String | ISO 8601 timestamp |
| `widget_user_name` | String | User display name |
| `widget_last_transaction` | JSON | Last transaction details |

### Last Transaction Schema

```json
{
  "type": "send",           // "send" or "receive"
  "amount": 50.0,
  "currency": "USD",
  "status": "completed",
  "recipientName": "Fatou Traore",
  "timestamp": "2026-01-29T12:00:00.000Z"
}
```

## Security Considerations

### Data Minimization

- Only store essential data for widget display
- No sensitive credentials or private keys
- No complete transaction history
- No wallet addresses or account numbers

### Encryption

- **iOS**: System-managed encryption via Keychain
- **Android**: AES-256 encryption via encrypted SharedPreferences
- All data encrypted at rest

### Access Control

- **iOS**: App Group limits access to app family only
- **Android**: Private mode SharedPreferences (MODE_PRIVATE)
- Data automatically cleared on app uninstall

### Logout Handling

```dart
// ALWAYS clear widget data on logout
await ref.read(widgetUpdateManagerProvider).clearWidgetData();
```

## Testing

### Unit Tests

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('WidgetDataService', () {
    late WidgetDataService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      service = WidgetDataService();
    });

    test('should store and retrieve balance', () async {
      await service.updateBalance(
        balance: 1234.56,
        currency: 'USD',
      );

      final data = await service.getWidgetData();
      expect(data?.balance, 1234.56);
      expect(data?.currency, 'USD');
    });

    test('should format balance correctly', () async {
      await service.updateBalance(
        balance: 1234.56,
        currency: 'USD',
      );

      final data = await service.getWidgetData();
      expect(data?.formattedBalance, '\$ 1234.56');
    });

    test('should format XOF balance', () async {
      await service.updateBalance(
        balance: 100000,
        currency: 'XOF',
      );

      final data = await service.getWidgetData();
      expect(data?.formattedBalance, 'XOF 100 000');
    });

    test('should clear data', () async {
      await service.updateBalance(balance: 100, currency: 'USD');
      await service.clearWidgetData();

      final data = await service.getWidgetData();
      expect(data, isNull);
    });
  });
}
```

### Integration Tests

```dart
// Test auto-updater integration
testWidgets('should update widget when wallet state changes', (tester) async {
  final container = ProviderContainer();

  // Initialize auto-updater
  container.read(widgetAutoUpdaterProvider);

  // Update wallet state
  final walletNotifier = container.read(walletStateMachineProvider.notifier);
  await walletNotifier.fetch();

  // Allow async updates to complete
  await tester.pumpAndSettle();

  // Verify widget data was updated
  final service = WidgetDataService();
  final data = await service.getWidgetData();
  expect(data, isNotNull);
});
```

## Troubleshooting

### iOS: Widget not updating

**Problem**: Widget shows old or empty data

**Solutions**:
1. Verify App Group is enabled for both targets
2. Check App Group ID matches in code: `group.com.joonapay.usdcwallet`
3. Force widget reload: Long press → Remove → Re-add widget
4. Check device logs for permission errors

### Android: Data not persisting

**Problem**: Widget data resets after app restart

**Solutions**:
1. Verify SharedPreferences name matches: `FlutterSharedPreferences`
2. Check encryption is enabled properly
3. Ensure widget provider has correct permissions in manifest
4. Check for storage permission issues

### Auto-updater not triggering

**Problem**: Widgets don't update when balance changes

**Solutions**:
1. Verify `widgetAutoUpdaterProvider` is watched in app widget
2. Check Riverpod listeners are set up correctly
3. Add debug logging to track state changes
4. Verify method channel is registered in native code

## Performance

### Update Frequency

- **Auto-updates**: On every wallet/user state change
- **Widget refresh**: Every 15 minutes (system-managed)
- **Manual updates**: On demand via `updateFromState()`

### Storage Impact

- **iOS Keychain**: ~1KB per entry
- **Android SharedPreferences**: ~1-2KB total
- Minimal storage footprint

### Battery Impact

- No continuous background processes
- Updates only when app is active or widget timeline expires
- Platform-managed refresh schedules

## Best Practices

1. **Always clear on logout**
   ```dart
   await widgetManager.clearWidgetData();
   ```

2. **Update on significant changes only**
   ```dart
   // Good: Update on balance change
   if (previous.usdcBalance != next.usdcBalance) {
     updateWidget();
   }

   // Bad: Update on every state change
   updateWidget(); // Too frequent
   ```

3. **Handle errors gracefully**
   ```dart
   try {
     await widgetManager.updateFromState(...);
   } catch (e) {
     // Log but don't crash
     print('Widget update failed: $e');
   }
   ```

4. **Use auto-updater for convenience**
   ```dart
   // Let auto-updater handle updates
   ref.watch(widgetAutoUpdaterProvider);

   // Manual updates only when needed
   await ref.read(widgetUpdateManagerProvider).updateFromState(...);
   ```

## Related Documentation

- [HOME_SCREEN_WIDGETS.md](../../HOME_SCREEN_WIDGETS.md) - Complete widget setup guide
- [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage)
- [SharedPreferences](https://pub.dev/packages/shared_preferences)
- [iOS App Groups](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_security_application-groups)
