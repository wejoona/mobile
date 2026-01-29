# Offline Mode Integration Checklist

## Prerequisites

- [x] Packages installed (`flutter pub get` completed)
- [x] L10n strings exist in app_en.arb and app_fr.arb
- [x] All offline service files created

## Step-by-Step Integration

### Phase 1: Basic Setup (15 minutes)

#### 1. Update Main App Scaffold
- [ ] Add `OfflineBanner` to main scaffold or root layout
- [ ] Test: Toggle airplane mode, verify banner appears

**File:** Your main scaffold/layout widget
```dart
// Add at top of body
Column(
  children: [
    const OfflineBanner(),
    Expanded(child: YourContent()),
  ],
)
```

#### 2. Initialize ConnectivityProvider
- [ ] ConnectivityProvider auto-initializes (no setup needed)
- [ ] Test: Check `ref.watch(isOnlineProvider)` returns correct status

**Verify in any screen:**
```dart
final isOnline = ref.watch(isOnlineProvider);
print('Online: $isOnline'); // Should print true when online
```

---

### Phase 2: Wallet Home Screen (30 minutes)

#### 3. Integrate Cached Balance Display
- [ ] Replace direct API call with OfflineModeManager
- [ ] Add OfflineIndicator when displaying cached data
- [ ] Add LastSyncIndicator below balance
- [ ] Handle stale data warning

**File:** `lib/features/wallet/views/wallet_home_view.dart` (or similar)

```dart
// Before:
final balance = await sdk.wallet.getBalance();

// After:
final manager = await ref.read(offlineModeManagerFutureProvider.future);
final balanceData = await manager.getBalance();

if (balanceData?.isCached == true) {
  // Show OfflineIndicator
}
```

#### 4. Update Balance After API Calls
- [ ] After successful balance fetch, update cache

```dart
final balance = await sdk.wallet.getBalance();
await manager.updateBalance(balance);
```

#### 5. Integrate Cached Transactions
- [ ] Replace transaction list with cached version
- [ ] Add OfflineIndicator when offline
- [ ] Update cache after fetching

**Similar pattern to balance above**

#### 6. Add Pending Transfers Section
- [ ] Add card showing pending transfer count
- [ ] Link to pending transfers screen
- [ ] Show OfflineStatusBadge

```dart
final pending = manager.getPendingTransfers();
if (pending.isNotEmpty) {
  // Show "X transfers pending" card
}
```

**Test:**
- [ ] View balance while online - no indicator
- [ ] Go offline - see cached balance with indicator
- [ ] See "Last synced: X ago" timestamp
- [ ] Pull to refresh shows "requires internet" when offline

---

### Phase 3: Send Money Flow (30 minutes)

#### 7. Add Offline Detection to Send Screen
- [ ] Check connectivity before sending
- [ ] Queue transfer if offline
- [ ] Send immediately if online

**File:** Your send money/transfer screen

```dart
final isOnline = ref.read(isOnlineProvider);

if (!isOnline) {
  final transferId = await manager.queueTransfer(
    recipientPhone: recipientPhone,
    recipientName: recipientName,
    amount: amount,
    description: description,
  );

  // Show success dialog
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.offline_transferQueued),
      content: Text(l10n.offline_transferQueuedDesc),
    ),
  );
} else {
  // Normal API call
  await sdk.transfers.send(...);
}
```

#### 8. Update Button Label Based on Connectivity
- [ ] Show "Queue Transfer" when offline
- [ ] Show "Send Now" when online

```dart
String getButtonLabel() {
  final isOnline = ref.watch(isOnlineProvider);
  return isOnline ? 'Send Now' : 'Queue Transfer';
}
```

#### 9. Add Offline Warning
- [ ] Show info box explaining transfer will be queued

```dart
if (!ref.watch(isOnlineProvider)) {
  // Show warning box
  Container(
    child: Text(l10n.offline_transferQueuedDesc),
  );
}
```

**Test:**
- [ ] Send money while online - goes through immediately
- [ ] Go offline, send money - gets queued
- [ ] See success dialog with "queued" message
- [ ] Button label changes to "Queue Transfer"

---

### Phase 4: Pending Transfers Screen (15 minutes)

#### 10. Add Route for Pending Transfers
- [ ] Add route in app_router.dart

**File:** `lib/router/app_router.dart`

```dart
GoRoute(
  path: '/pending-transfers',
  pageBuilder: (context, state) => AppPageTransitions.fade(
    context,
    state,
    const PendingTransfersView(),
  ),
),
```

#### 11. Add Navigation to Pending Screen
- [ ] Add in settings or wallet home
- [ ] Show badge with count

```dart
ListTile(
  title: Text('Pending Transfers'),
  trailing: const OfflineStatusBadge(),
  onTap: () => context.push('/pending-transfers'),
)
```

**Test:**
- [ ] Navigate to /pending-transfers
- [ ] See queued transfers
- [ ] Retry failed transfer
- [ ] Cancel pending transfer
- [ ] Go online - see auto-sync indicator

---

### Phase 5: Other Screens (20 minutes)

#### 12. Integrate Cached Beneficiaries
- [ ] Use manager.getBeneficiaries() in beneficiary list
- [ ] Show indicator when offline

**File:** Beneficiaries list screen

```dart
final beneficiariesData = await manager.getBeneficiaries();
if (beneficiariesData?.isCached == true) {
  // Show indicator
}
```

#### 13. Enable Offline QR Code Generation
- [ ] Cache wallet ID after login
- [ ] Generate QR from cached ID when offline

```dart
// After login
await manager.updateWalletId(walletId);

// In receive screen
final walletId = manager.getWalletIdForQR();
if (walletId != null) {
  // Generate QR code
}
```

**Test:**
- [ ] View beneficiaries offline - see cached list
- [ ] Generate receive QR offline - works

---

### Phase 6: Connectivity Listeners (15 minutes)

#### 14. Add Global Connectivity Listener
- [ ] Listen for online/offline transitions
- [ ] Show snackbar when going offline
- [ ] Show snackbar when back online

**File:** Your app root or main scaffold

```dart
@override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.listen<ConnectivityState>(
      connectivityProvider,
      (previous, next) {
        if (previous?.isOnline == true && next.isOnline == false) {
          // Went offline
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.offline_youreOffline),
              backgroundColor: AppColors.warning,
            ),
          );
        }

        if (previous?.isOnline == false && next.isOnline == true) {
          // Back online
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Back online, syncing...'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      },
    );
  });
}
```

**Test:**
- [ ] Go offline - see snackbar
- [ ] Go online - see "syncing" snackbar

---

### Phase 7: Polish & Error Handling (20 minutes)

#### 15. Add Pull-to-Refresh Handling
- [ ] Show message when pulling to refresh offline
- [ ] Actually refresh when online

```dart
Future<void> _onRefresh() async {
  final isOnline = ref.read(isOnlineProvider);

  if (!isOnline) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Refresh requires internet')),
    );
    return;
  }

  // Fetch fresh data
  // Update cache
}
```

#### 16. Handle Stale Data
- [ ] Show warning when data is > 5 minutes old
- [ ] Prompt user to refresh

```dart
if (balanceData.isStale) {
  // Show "Data may be outdated" warning
}
```

#### 17. Add Error States
- [ ] Handle no cached data available
- [ ] Handle cache load failures

```dart
if (balanceData == null) {
  // Show "No data available offline"
  // Prompt to connect
}
```

**Test:**
- [ ] Pull to refresh offline - see error
- [ ] Wait 6 minutes offline - see stale warning
- [ ] Clear app data, go offline - see "no cache" message

---

### Phase 8: Testing (30 minutes)

#### 18. Manual Testing Scenarios

**Offline Flow:**
- [ ] Start app while offline
- [ ] See cached balance and transactions
- [ ] See offline banner
- [ ] Dismiss banner, navigate, verify reappears
- [ ] Queue a transfer
- [ ] See transfer in pending list
- [ ] View beneficiaries (cached)
- [ ] Generate receive QR

**Online Flow:**
- [ ] Start app while online
- [ ] No offline indicators
- [ ] Send transfer - goes through
- [ ] Pull to refresh - works

**Transition Flow:**
- [ ] Start online
- [ ] Queue 2 transfers offline
- [ ] Go back online
- [ ] See syncing indicator
- [ ] Verify transfers process
- [ ] Check pending list is empty
- [ ] Verify snackbar shows success

**Error Flow:**
- [ ] Queue transfer with invalid phone
- [ ] Go online
- [ ] See transfer fail
- [ ] Retry failed transfer
- [ ] Cancel failed transfer

#### 19. Edge Cases
- [ ] Rapid online/offline toggling
- [ ] Multiple transfers queued
- [ ] App killed while syncing
- [ ] Cache full (unlikely but test)

---

### Phase 9: Analytics & Monitoring (15 minutes)

#### 20. Add Analytics Events
- [ ] Track offline mode usage
- [ ] Track queued transfers
- [ ] Track sync success/failure

```dart
analytics.logEvent('offline_transfer_queued', {
  'amount': amount,
  'recipient_type': 'phone',
});
```

#### 21. Add Error Logging
- [ ] Log sync failures
- [ ] Log cache errors

```dart
try {
  await processQueue();
} catch (e, stack) {
  logger.error('Queue processing failed', e, stack);
}
```

---

### Phase 10: Documentation (10 minutes)

#### 22. Update App Documentation
- [ ] Add offline mode to user guide
- [ ] Document developer patterns
- [ ] Update API integration docs

#### 23. Team Handoff
- [ ] Demo to team
- [ ] Share integration_example.dart
- [ ] Review error handling

---

## Final Verification

### Functionality
- [ ] All cached data displays correctly
- [ ] Offline banner appears/dismisses properly
- [ ] Transfers queue when offline
- [ ] Transfers auto-sync when online
- [ ] Manual retry works
- [ ] Cancel works
- [ ] All indicators show/hide correctly

### UX
- [ ] Clear visual feedback for offline state
- [ ] No confusion about queued vs sent transfers
- [ ] Proper error messages
- [ ] Smooth transitions
- [ ] No jarring UI changes

### Performance
- [ ] No lag when going offline
- [ ] Cache loads quickly
- [ ] No excessive memory usage
- [ ] Queue processing doesn't block UI

### Accessibility
- [ ] Screen reader announces offline state
- [ ] Color contrast sufficient
- [ ] Keyboard navigation works
- [ ] Text scales properly

### Localization
- [ ] French translations correct
- [ ] XOF currency formatting
- [ ] Phone number formatting

---

## Estimated Time

| Phase | Time |
|-------|------|
| 1. Basic Setup | 15 min |
| 2. Wallet Home | 30 min |
| 3. Send Money | 30 min |
| 4. Pending Screen | 15 min |
| 5. Other Screens | 20 min |
| 6. Listeners | 15 min |
| 7. Polish | 20 min |
| 8. Testing | 30 min |
| 9. Analytics | 15 min |
| 10. Documentation | 10 min |
| **Total** | **3-4 hours** |

---

## Rollout Strategy

### Week 1: Internal Testing
- [ ] Deploy to internal test build
- [ ] Test all scenarios
- [ ] Gather feedback
- [ ] Fix bugs

### Week 2: Beta Testing
- [ ] Deploy to beta testers
- [ ] Monitor analytics
- [ ] Collect feedback
- [ ] Iterate

### Week 3: Staged Rollout
- [ ] 10% of users
- [ ] Monitor metrics
- [ ] 50% of users
- [ ] Monitor metrics

### Week 4: Full Release
- [ ] 100% of users
- [ ] Monitor closely
- [ ] Quick hotfix capability

---

## Success Metrics

- [ ] Offline mode activation rate < 5% (most users online)
- [ ] Queue success rate > 95%
- [ ] Cache hit rate > 90%
- [ ] Average time to sync < 5 seconds
- [ ] User satisfaction score maintained

---

## Support Contacts

**For Technical Issues:**
- Check IMPLEMENTATION_SUMMARY.md
- Review integration_example.dart
- See offline_mode_readme.md

**For Questions:**
- Review this checklist
- Check existing implementation

---

## Sign-off

- [ ] Lead Developer Review
- [ ] QA Testing Complete
- [ ] Product Owner Approval
- [ ] Ready for Production

---

**Date Completed:** _______________
**Completed By:** _______________
**Notes:** _______________
