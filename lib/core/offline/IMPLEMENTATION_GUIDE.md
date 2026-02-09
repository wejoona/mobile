# Offline-First Implementation Guide

## Overview

This module adds comprehensive offline-first capabilities to the JoonaPay mobile app:

1. **Visual Connectivity Indicators** - Banner, indicators, and badges
2. **Automatic Retry Logic** - Smart retry with multiple strategies
3. **Seamless Integration** - Works with existing connectivity and offline services

## Files Created

```
/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/core/offline/
├── offline_banner.dart              # Banner widget + indicators
├── retry_service.dart               # Retry logic + auto queue
├── index.dart                       # Exports
├── README.md                        # Comprehensive documentation
├── example_integration.dart         # Integration examples
└── IMPLEMENTATION_GUIDE.md          # This file
```

## Quick Start

### Step 1: Add Offline Banner to Main Screens

```dart
import 'package:usdc_wallet/core/offline/index.dart';

// In your wallet/home screen:
class HomeView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        children: [
          const OfflineBanner(), // Add this
          Expanded(child: YourContent()),
        ],
      ),
    );
  }
}
```

**Add to these screens:**
- `/lib/features/wallet/views/wallet_view.dart`
- `/lib/features/transactions/views/transactions_view.dart`
- `/lib/features/transfers/views/send_view.dart`
- `/lib/features/settings/views/settings_view.dart`

### Step 2: Add Retry Logic to API Calls

```dart
import 'package:usdc_wallet/core/offline/index.dart';

// In your provider/notifier:
class WalletNotifier extends Notifier<WalletState> {
  Future<void> loadBalance() async {
    try {
      // Simple: Add .withRetry()
      final balance = await sdk.wallet.getBalance().withRetry(ref);

      state = state.copyWith(balance: balance);
    } catch (e) {
      // Handle error or load from cache
    }
  }
}
```

**Add to these services:**
- Wallet balance loading
- Transaction list fetching
- Beneficiary loading
- Transfer submission
- Any critical API calls

### Step 3: Add Offline Indicators (Optional)

```dart
// In AppBar:
AppBar(
  title: Text('Wallet'),
  actions: [
    const OfflineIndicator(), // Compact indicator
    // ... other actions
  ],
)

// In transaction list items:
ListTile(
  title: Row(
    children: [
      Text('Transfer'),
      if (isPending) const OfflineBadge(), // Show "Queued"
    ],
  ),
)
```

## Integration Points

### 1. Existing Connectivity Service

The offline banner already integrates with:
- `/lib/services/connectivity/connectivity_provider.dart`
- `/lib/services/connectivity/connectivity_service.dart`

**No changes needed** - It watches `connectivityProvider` automatically.

### 2. Existing Offline Manager

Retry service works alongside:
- `/lib/services/offline/offline_mode_manager.dart`
- `/lib/services/offline/offline_cache_service.dart`
- `/lib/services/offline/pending_transfer_queue.dart`

**Recommended pattern:**
```dart
Future<void> loadData() async {
  try {
    // Try with retry
    final data = await api.getData().withRetry(ref);
    await offlineManager.updateCache(data);
  } catch (e) {
    // Fall back to cache
    final cached = await offlineManager.getCached();
    if (cached != null) {
      state = state.copyWith(data: cached.data, isCached: true);
    }
  }
}
```

### 3. SDK Integration

Add retry to SDK calls in:
- `/lib/services/sdk/usdc_wallet_sdk.dart`

```dart
// Option A: Wrap SDK calls in providers
class WalletNotifier {
  Future<void> load() async {
    final balance = await sdk.wallet.getBalance().withRetry(ref);
  }
}

// Option B: Add retry inside SDK (more invasive)
class WalletApi {
  Future<Balance> getBalance() async {
    // Return future that can be retried
    return _dio.get('/wallet/balance').then(...);
  }
}
```

## Localization

**Already added to:**
- `/lib/l10n/app_en.arb` (lines 9655-9678)
- `/lib/l10n/app_fr.arb` (lines 2943-2946)

**Strings:**
- `offline_banner_title`: "You're offline" / "Vous êtes hors ligne"
- `offline_banner_last_sync`: "Last synced {time}" / "Dernière synchro {time}"
- `offline_banner_syncing`: "Syncing..." / "Synchronisation..."
- `offline_banner_reconnected`: "Back online!" / "De retour en ligne!"

**Run to regenerate:**
```bash
flutter gen-l10n
```

## Testing

### Manual Testing

1. **Test offline banner:**
   - Run app
   - Enable airplane mode
   - Banner should appear with "You're offline"
   - Disable airplane mode
   - Banner should show "Back online!" for 3 seconds

2. **Test retry logic:**
   ```dart
   // Add temporary logging
   final result = await retryService.execute(
     operation: () async {
       print('Attempt ${DateTime.now()}');
       return await api.call();
     },
     config: RetryConfig.api,
   );
   print('Success: ${result.success}, Attempts: ${result.attempts}');
   ```

3. **Test with network throttling:**
   - iOS: Settings > Developer > Network Link Conditioner
   - Android: Chrome DevTools network throttling

### Automated Testing

```dart
// test/offline_banner_test.dart
testWidgets('shows offline banner when offline', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        connectivityProvider.overrideWith((ref) =>
          ConnectivityNotifier()..state = ConnectivityState(isOnline: false)
        ),
      ],
      child: MaterialApp(home: OfflineBanner()),
    ),
  );

  expect(find.text("You're offline"), findsOneWidget);
});

// test/retry_service_test.dart
test('retries on failure', () async {
  int attempts = 0;
  final result = await retryService.execute(
    operation: () async {
      attempts++;
      if (attempts < 3) throw Exception('Fail');
      return 'Success';
    },
    config: RetryConfig(maxAttempts: 3, strategy: RetryStrategy.immediate),
  );

  expect(result.success, true);
  expect(result.attempts, 3);
});
```

## Performance Considerations

### Banner Performance
- **Minimal overhead**: Only renders when state changes
- **Animated**: Uses `AnimatedSize` for smooth transitions
- **Conditional**: `SizedBox.shrink()` when not needed

### Retry Performance
- **Non-blocking**: Uses async/await properly
- **Exponential backoff**: Prevents API hammering
- **Smart delays**: Waits for connectivity before retrying
- **Cancellable**: Can be interrupted

### Memory Usage
- **Small footprint**: Services are singletons
- **No memory leaks**: Proper disposal of streams
- **Efficient**: Uses Riverpod's automatic cleanup

## Accessibility

- **Semantics**: Banner has semantic labels
- **Screen readers**: Announces connectivity changes
- **High contrast**: Colors meet WCAG AA standards
- **Clear text**: 14px minimum font size

## Common Issues & Solutions

### Issue: Banner doesn't show

**Solution:** Ensure connectivity provider is initialized
```dart
// In main.dart
runApp(
  ProviderScope(
    child: MyApp(),
  ),
);
```

### Issue: Retry not working

**Solution:** Check connectivity provider is available
```dart
// Ensure you have ref access
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Now can use ref.read(retryServiceProvider)
  }
}
```

### Issue: Banner overlapping content

**Solution:** Use Column layout
```dart
Scaffold(
  body: Column(
    children: [
      const OfflineBanner(), // Takes only needed space
      Expanded(child: Content()), // Takes remaining space
    ],
  ),
)
```

### Issue: Too many retry attempts

**Solution:** Adjust retry config
```dart
// Reduce attempts for non-critical operations
final result = await operation().withRetry(
  ref,
  config: RetryConfig(
    maxAttempts: 2, // Instead of default 3
    strategy: RetryStrategy.immediate,
  ),
);
```

## Migration Path

### Phase 1: Banner (Quick Win)
1. Add `OfflineBanner` to 3-4 main screens
2. Test offline/online transitions
3. Deploy to staging

### Phase 2: Retry Logic (Medium)
1. Add retry to critical operations (transfers, balance)
2. Monitor retry success rates
3. Adjust configs based on data

### Phase 3: Full Integration (Long-term)
1. Add retry to all API calls
2. Add offline indicators throughout UI
3. Use auto retry queue for background sync

## Monitoring & Analytics

**Track these metrics:**
- Retry success rate by operation type
- Average attempts before success
- Offline session duration
- Pending operations count

**Add analytics:**
```dart
final result = await retryService.execute(
  operation: () => api.call(),
  config: RetryConfig.api,
);

// Log result
analytics.logEvent(
  name: 'api_retry',
  parameters: {
    'operation': 'get_balance',
    'success': result.success,
    'attempts': result.attempts,
  },
);
```

## Next Steps

1. **Immediate (Today):**
   - Add `OfflineBanner` to wallet view
   - Test with airplane mode

2. **This Week:**
   - Add retry to balance loading
   - Add retry to transaction loading
   - Add `OfflineIndicator` to AppBar

3. **This Sprint:**
   - Add retry to all critical operations
   - Add offline badges to pending items
   - Write automated tests

4. **Future:**
   - Analytics integration
   - Push notifications for pending operations
   - User-configurable retry settings

## Questions?

See:
- `README.md` - Comprehensive documentation
- `example_integration.dart` - Real-world examples
- Existing services in `/lib/services/connectivity/` and `/lib/services/offline/`

## File Locations Reference

```
Offline Module:
  /lib/core/offline/offline_banner.dart
  /lib/core/offline/retry_service.dart
  /lib/core/offline/index.dart

Existing Services (Already working):
  /lib/services/connectivity/connectivity_provider.dart
  /lib/services/connectivity/connectivity_service.dart
  /lib/services/offline/offline_mode_manager.dart
  /lib/services/offline/offline_cache_service.dart
  /lib/services/offline/pending_transfer_queue.dart

Localization:
  /lib/l10n/app_en.arb (lines 9655-9678)
  /lib/l10n/app_fr.arb (lines 2943-2946)

Design System:
  /lib/design/tokens/colors.dart
  /lib/design/tokens/spacing.dart
  /lib/design/components/primitives/
```
