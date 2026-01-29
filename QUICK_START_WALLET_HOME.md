# Quick Start: Wallet Home Screen Integration

## Prerequisites
- ✅ Localization files generated
- ✅ All dependencies installed
- ✅ Backend API running (or mocks enabled)

## Step 1: Add Dependencies (if needed)

Check `pubspec.yaml` for these dependencies:
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.4.0
  go_router: ^12.0.0
  shared_preferences: ^2.2.0
  flutter_localizations:
    sdk: flutter

dev_dependencies:
  flutter_gen: ^5.3.0
```

If missing, run:
```bash
cd /Users/macbook/JoonaPay/USDC-Wallet/mobile
flutter pub get
```

## Step 2: Verify Localization

Ensure localization files are generated:
```bash
cd /Users/macbook/JoonaPay/USDC-Wallet/mobile
flutter gen-l10n
```

Expected output:
```
Generating localizations...
  ✓ app_localizations.dart
  ✓ app_localizations_en.dart
  ✓ app_localizations_fr.dart
```

## Step 3: Add to Router

Open `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/router/app_router.dart`

Add the import:
```dart
import '../features/wallet/views/wallet_home_screen.dart';
```

Add the route:
```dart
GoRoute(
  path: '/home',
  pageBuilder: (context, state) => AppPageTransitions.fade(
    context,
    state,
    const WalletHomeScreen(),
  ),
),
```

## Step 4: Set as Default Route (Optional)

If you want this to be the main screen after login, update your router redirect:

```dart
redirect: (context, state) {
  // Get auth state
  final ref = ProviderScope.containerOf(context);
  final userState = ref.read(userStateMachineProvider);

  // If authenticated and at root, go to home
  if (userState.isAuthenticated && state.location == '/') {
    return '/home';
  }

  // If not authenticated, go to login
  if (!userState.isAuthenticated && !state.location.startsWith('/auth')) {
    return '/auth/login';
  }

  return null; // No redirect needed
},
```

## Step 5: Add to Bottom Navigation (Optional)

If using bottom navigation, update your shell route:

```dart
StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) {
    return ScaffoldWithNavBar(navigationShell: navigationShell);
  },
  branches: [
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => NoTransitionPage(
            child: WalletHomeScreen(),
          ),
        ),
      ],
    ),
    // ... other branches
  ],
)
```

Bottom navigation bar items:
```dart
BottomNavigationBar(
  items: [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: l10n.navigation_home,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.history),
      label: l10n.navigation_transactions,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.apps),
      label: l10n.navigation_services,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.settings),
      label: l10n.navigation_settings,
    ),
  ],
)
```

## Step 6: Test the Implementation

### Run the app:
```bash
cd /Users/macbook/JoonaPay/USDC-Wallet/mobile
flutter run
```

### Test Checklist:
- [ ] App launches successfully
- [ ] Greeting shows correct time-based message
- [ ] Balance displays correctly
- [ ] Eye icon toggles balance visibility
- [ ] Quick actions navigate correctly:
  - [ ] Send → `/send`
  - [ ] Receive → `/receive`
  - [ ] Deposit → `/deposit`
  - [ ] History → `/transactions`
- [ ] KYC banner shows (if not verified)
- [ ] Recent transactions display
- [ ] Pull-to-refresh works
- [ ] Notification bell navigates to `/notifications`
- [ ] Settings icon navigates to `/settings`

## Step 7: Test Different States

### Test Loading State
```dart
// In wallet_state_machine.dart, add delay:
await Future.delayed(Duration(seconds: 2));
```

### Test Error State
```dart
// In mock, throw error:
throw ApiException(message: 'Network error', statusCode: 500);
```

### Test Empty Wallet
```dart
// In mock, return empty wallet ID:
walletId: '',
```

### Test No Transactions
```dart
// In mock, return empty list:
transactions: [],
```

### Test Different KYC States
```dart
// Change KYC status in user mock:
kycStatus: KycStatus.none,     // Show banner
kycStatus: KycStatus.pending,  // Show banner
kycStatus: KycStatus.rejected, // Show banner
kycStatus: KycStatus.verified, // Hide banner
```

## Step 8: Test Localization

### Switch to French:
```dart
// In your app settings or device settings
Locale('fr')
```

Verify all strings are in French:
- ✓ Greeting: "Bonjour" / "Bon après-midi" / "Bonsoir" / "Bonne nuit"
- ✓ Balance: "Solde total"
- ✓ Quick actions: "Envoyer", "Recevoir", "Dépôt", "Historique"
- ✓ KYC banner: "Complétez la vérification..."

## Step 9: Test on Different Devices

### Small Phone (iPhone SE)
```bash
flutter run -d "iPhone SE"
```

### Standard Phone (iPhone 14)
```bash
flutter run -d "iPhone 14"
```

### Large Phone (iPhone 14 Pro Max)
```bash
flutter run -d "iPhone 14 Pro Max"
```

### Android
```bash
flutter run -d "Pixel 7"
```

## Step 10: Performance Testing

### Profile Mode
```bash
flutter run --profile
```

Check performance metrics:
- Frame rate should be 60 FPS
- No jank during animations
- Smooth pull-to-refresh

### Memory Profiling
```bash
flutter run --profile
# Open DevTools
# Monitor memory usage during:
# - Initial load
# - Balance animation
# - Pull-to-refresh
# - Navigation
```

## Troubleshooting

### Issue: Localization strings not found
**Solution:**
```bash
flutter gen-l10n
flutter clean
flutter pub get
flutter run
```

### Issue: State not updating
**Solution:**
Check that providers are properly watched:
```dart
// ✓ Correct
final walletState = ref.watch(walletStateMachineProvider);

// ✗ Wrong
final walletState = ref.read(walletStateMachineProvider);
```

### Issue: Animation not running
**Solution:**
Check that AnimationController is initialized in `initState`:
```dart
@override
void initState() {
  super.initState();
  _balanceAnimationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );
}
```

### Issue: SharedPreferences not working
**Solution:**
Ensure SharedPreferences is initialized in main:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance(); // Initialize
  runApp(MyApp());
}
```

### Issue: Navigation not working
**Solution:**
Ensure GoRouter context is available:
```dart
// Use context.push() not Navigator.push()
context.push('/send'); // ✓ Correct
Navigator.push(...);   // ✗ Wrong with GoRouter
```

### Issue: KYC banner not showing
**Solution:**
Check user state:
```dart
final userState = ref.watch(userStateMachineProvider);
print('Auth: ${userState.isAuthenticated}');
print('KYC: ${userState.kycStatus}');
```

### Issue: Balance not formatting correctly
**Solution:**
Check balance value type:
```dart
// Must be double
final balance = walletState.usdcBalance; // double
print(balance.runtimeType); // Should print: double
```

## Testing with Mock Data

### Enable Mocks
In `/lib/mocks/mock_config.dart`:
```dart
class MockConfig {
  static bool useMocks = true; // Enable mocks
}
```

### Test Different Balances
In `/lib/mocks/services/wallet/wallet_mock.dart`:
```dart
// Test K notation
available: 1234.56,

// Test M notation
available: 1234567.89,

// Test B notation
available: 1234567890.12,

// Test small amount
available: 142.85,
```

### Test Different User Names
In `/lib/mocks/services/user/user_mock.dart`:
```dart
// Test with name
firstName: 'Amadou',
lastName: 'Diallo',

// Test with phone only
firstName: null,
lastName: null,
phone: '+225 XX XX XX XX',
```

## Analytics Events (Optional)

Add analytics tracking:
```dart
// On screen view
analytics.logScreenView(
  screenName: 'wallet_home',
  screenClass: 'WalletHomeScreen',
);

// On balance toggle
analytics.logEvent(
  name: 'balance_visibility_toggle',
  parameters: {
    'hidden': _isBalanceHidden,
  },
);

// On quick action tap
analytics.logEvent(
  name: 'quick_action_tap',
  parameters: {
    'action': 'send', // or 'receive', 'deposit', 'history'
  },
);

// On KYC banner tap
analytics.logEvent(
  name: 'kyc_banner_tap',
  parameters: {
    'current_status': userState.kycStatus.name,
  },
);
```

## Next Steps

### Recommended
1. ✅ Add unit tests
2. ✅ Add widget tests
3. ✅ Add integration tests
4. ✅ Set up analytics
5. ✅ Add error logging (Sentry/Firebase Crashlytics)
6. ✅ Test on real devices
7. ✅ Collect user feedback

### Future Enhancements
1. ⏳ Add balance chart/graph
2. ⏳ Add spending insights
3. ⏳ Add promotional cards
4. ⏳ Add customizable quick actions
5. ⏳ Add savings goals preview
6. ⏳ Add rewards display

## Support

### Documentation
- **Implementation Guide**: `/mobile/lib/features/wallet/views/WALLET_HOME_IMPLEMENTATION.md`
- **Visual Preview**: `/mobile/lib/features/wallet/views/WALLET_HOME_PREVIEW.md`
- **This Guide**: `/mobile/QUICK_START_WALLET_HOME.md`

### Need Help?
1. Check the implementation guide for detailed info
2. Review the visual preview for UI reference
3. Test with mock data first
4. Check console logs for errors
5. Verify state provider values

## Verification Checklist

Before deploying to production:

- [ ] All localization strings translated
- [ ] All navigation routes working
- [ ] All API endpoints configured
- [ ] Pull-to-refresh functioning
- [ ] Balance visibility persistence working
- [ ] Animations smooth (60 FPS)
- [ ] No memory leaks
- [ ] Error states handled gracefully
- [ ] Loading states shown appropriately
- [ ] Accessibility features tested
- [ ] Different screen sizes tested
- [ ] Both iOS and Android tested
- [ ] Light and dark modes work (if applicable)
- [ ] Analytics events firing
- [ ] Error logging configured

## Success!

If all tests pass, you're ready to go! The Wallet Home Screen is now integrated and ready for users.

**Main Screen File:**
`/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/features/wallet/views/wallet_home_screen.dart`

**Localization Files:**
- `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/l10n/app_en.arb`
- `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/l10n/app_fr.arb`

Happy coding! 🚀
