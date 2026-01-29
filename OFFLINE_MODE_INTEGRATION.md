# Offline Mode Integration Guide

## Files Created

### Core Services
1. `/lib/services/connectivity/connectivity_service.dart` - Network monitoring
2. `/lib/services/offline/offline_cache_service.dart` - Data caching
3. `/lib/services/offline/pending_transfer_queue.dart` - Transfer queue management
4. `/lib/services/offline/README.md` - Full documentation

### Providers
5. `/lib/features/offline/providers/offline_provider.dart` - State management

### UI Components
6. `/lib/design/components/primitives/offline_banner.dart` - Status indicators
7. `/lib/features/offline/views/pending_transfers_screen.dart` - Queue management screen
8. `/lib/features/send/views/offline_queue_dialog.dart` - Queue confirmation dialog

### Localization
9. Updated `/lib/l10n/app_en.arb` - English strings
10. Updated `/lib/l10n/app_fr.arb` - French strings

### Dependencies
11. Updated `/lib/pubspec.yaml` - Added `connectivity_plus: ^6.0.5`

### Integration
12. Updated `/lib/features/wallet/views/wallet_home_screen.dart` - Added offline banner

## Integration Steps

### 1. Install Dependencies
```bash
cd /Users/macbook/JoonaPay/USDC-Wallet/mobile
flutter pub get
flutter gen-l10n
```

### 2. Add Route for Pending Transfers

In `lib/router/app_router.dart`, add this route:

```dart
GoRoute(
  path: '/offline/pending-transfers',
  pageBuilder: (context, state) => AppPageTransitions.fade(
    context,
    state,
    const PendingTransfersScreen(),
  ),
),
```

Don't forget to import:
```dart
import '../features/offline/views/pending_transfers_screen.dart';
```

### 3. Integrate Offline Queueing in Send Flow

In `lib/features/send/views/confirm_screen.dart`, add offline handling:

```dart
import '../../offline/providers/offline_provider.dart';
import './offline_queue_dialog.dart';

// In the confirm button handler:
Future<void> _handleConfirm(BuildContext context, WidgetRef ref) async {
  final offlineState = ref.watch(offlineProvider);
  final state = ref.watch(sendMoneyProvider);

  // Check if offline
  if (!offlineState.isOnline) {
    // Queue the transfer
    await OfflineQueueDialog.show(
      context,
      ref,
      recipientName: state.recipient?.name,
      recipientPhone: state.recipient!.phoneNumber,
      amount: state.amount!,
      description: state.note,
    );

    // Navigate back to home
    if (context.mounted) {
      context.go('/');
    }
    return;
  }

  // Normal flow when online
  // ... existing code
}
```

### 4. Add Cache Population

After successful wallet/transaction fetch, cache the data:

```dart
// In wallet state machine after fetching balance:
final offlineNotifier = ref.read(offlineProvider.notifier);
await offlineNotifier.cacheWalletData(
  balance: walletData.balance,
  walletId: walletData.id,
);

// In transaction state machine after fetching transactions:
final cacheService = await ref.read(offlineCacheServiceFutureProvider.future);
await cacheService.cacheTransactions(transactions);
```

### 5. Initialize Services in main.dart

The services auto-initialize via providers, but you can listen to status:

```dart
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to connectivity status for debugging
    ref.listen(connectivityStatusProvider, (previous, next) {
      next.when(
        data: (status) => debugPrint('Connectivity: $status'),
        loading: () {},
        error: (_, __) {},
      );
    });

    return MaterialApp.router(...);
  }
}
```

## Usage Examples

### Show Offline Banner
Already integrated in `wallet_home_screen.dart`:
```dart
Column(
  children: [
    const OfflineStatusBanner(), // Shows offline/syncing status
    Expanded(child: YourContent()),
  ],
)
```

### Check Online Status
```dart
final isOnline = ref.watch(isOnlineProvider);

if (!isOnline) {
  // Show offline UI
} else {
  // Normal UI
}
```

### Access Pending Count
```dart
final offlineState = ref.watch(offlineProvider);
final pendingCount = offlineState.pendingTransferCount;

// Show badge
if (pendingCount > 0) {
  Badge(
    label: Text('$pendingCount'),
    child: Icon(Icons.cloud_queue),
  )
}
```

### Manual Sync
```dart
await ref.read(offlineProvider.notifier).manualSync();
```

### Access Cached Data
```dart
final cacheService = await ref.read(offlineCacheServiceFutureProvider.future);

// Get cached balance when offline
final balance = cacheService.getCachedBalance();
if (balance != null) {
  // Show cached balance with indicator
}
```

## Testing Checklist

- [ ] Install dependencies: `flutter pub get`
- [ ] Generate localizations: `flutter gen-l10n`
- [ ] Add pending transfers route
- [ ] Test going offline (airplane mode)
- [ ] Verify offline banner appears
- [ ] Queue a transfer while offline
- [ ] Verify transfer appears in pending screen
- [ ] Go back online
- [ ] Verify auto-sync triggers
- [ ] Verify transfer processes successfully
- [ ] Test failed transfer retry
- [ ] Test transfer cancellation
- [ ] Test cached data display
- [ ] Test French translations

## What Works Offline

✅ View cached balance
✅ View last 50 transactions
✅ View beneficiaries
✅ Queue P2P transfers
✅ View pending transfers

## What Requires Online

❌ Refresh balance
❌ Execute transfers
❌ Add beneficiaries
❌ KYC verification
❌ Deposits/withdrawals

## Performance Impact

- **Storage**: ~50KB for cached data (50 transactions + beneficiaries)
- **Memory**: Negligible (providers are lazy-loaded)
- **Battery**: Connectivity monitoring has minimal impact
- **Network**: No polling, event-driven sync only

## Security Notes

- No sensitive data (PINs, keys) cached
- All data cleared on logout
- Transfers require PIN verification even when queued
- Queue processed with full auth validation

## Troubleshooting

### Transfers not syncing
```dart
// Check connectivity status
final status = ref.read(connectivityStatusProvider);
print('Status: $status');

// Manually trigger sync
await ref.read(offlineProvider.notifier).manualSync();
```

### Cache not updating
```dart
// Clear cache
final cacheService = await ref.read(offlineCacheServiceFutureProvider.future);
await cacheService.clearCache();
```

### Queue stuck
```dart
// Get queue details
final queue = ref.read(offlineProvider.notifier).getPendingTransfers();
print('Queue: ${queue.length} items');

// Check individual statuses
for (final transfer in queue) {
  print('${transfer.id}: ${transfer.status}');
}
```

## Next Steps

After integration:

1. Test thoroughly in offline/online scenarios
2. Add analytics tracking for offline usage
3. Consider periodic background sync (when app in background)
4. Add network quality indicator (2G/3G/4G/WiFi)
5. Optimize cache size based on device storage
6. Add offline-first features (draft transfers, notes, etc.)

## Support

For questions or issues:
- Check `/lib/services/offline/README.md` for detailed docs
- Review test cases in `/test/services/offline/`
- Consult West African UX research for offline patterns
