# Navigation & Page Transitions

## Overview
This directory contains the routing and navigation configuration for the JoonaPay USDC Wallet Flutter app, featuring contextual page transitions that create a smooth, luxury user experience.

## Files

### `app_router.dart`
Main router configuration using GoRouter 17.x with custom page transitions.

**Key Features:**
- Bottom navigation shell with 4 main tabs
- Auth guards and feature flag integration
- Contextual transitions for all routes
- Deep linking support

### `page_transitions.dart`
Custom page transition implementations for different navigation contexts.

**Transition Types:**
1. **Horizontal Slide** (280ms) - Tab switching, same-level navigation
2. **Vertical Slide** (280ms) - Modals, actions, detail views
3. **Fade** (200ms) - Auth flows, settings sub-pages
4. **Scale + Fade** (280ms) - Success/confirmation screens
5. **No Transition** (0ms) - Splash/initial screens

### `transition_demo.dart`
Interactive demo screen to test and showcase all transition types.

**Usage:**
Add to router for testing:
```dart
GoRoute(
  path: '/transition-demo',
  builder: (context, state) => const TransitionDemoView(),
),
```

### `TRANSITIONS_GUIDE.md`
Comprehensive documentation covering:
- Route-to-transition mapping
- Implementation examples
- Design principles
- Testing guidelines
- Maintenance notes

## Quick Start

### Adding a New Route

1. **Determine the transition type** based on navigation hierarchy:
   - Tab/peer navigation → `horizontalSlide`
   - Modal/action → `verticalSlide`
   - Settings sub-page → `fade`
   - Success screen → `scaleAndFade`

2. **Add the route** to `app_router.dart`:
   ```dart
   GoRoute(
     path: '/your-route',
     pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
       state: state,
       child: const YourView(),
     ),
   ),
   ```

3. **Test the transition** by navigating to/from the route

### Navigation Examples

**Push a route:**
```dart
context.push('/send');
```

**Go to a route (replace):**
```dart
context.go('/home');
```

**Pop back:**
```dart
context.pop();
```

**Pass data:**
```dart
context.push('/transactions/123', extra: transactionObject);
```

## Route Structure

### Public Routes (No Auth Required)
- `/` - Splash screen
- `/onboarding` - Onboarding flow
- `/login` - Login screen
- `/otp` - OTP verification

### Main Tabs (Horizontal Slide)
- `/home` - Wallet dashboard
- `/transactions` - Transaction history
- `/referrals` - Rewards & referrals
- `/settings` - Settings main

### Action Modals (Vertical Slide)
- `/send` - Send money
- `/receive` - Receive money
- `/deposit` - Deposit funds
- `/withdraw` - Withdraw funds
- `/scan` - QR code scanner
- `/scan-to-pay` - Merchant payment
- `/request` - Request money
- `/split` - Split bill
- `/airtime` - Buy airtime
- `/bills` - Pay bills

### Detail Views (Vertical Slide)
- `/transactions/:id` - Transaction detail
- `/notifications` - Notifications list
- `/deposit/instructions` - Deposit instructions
- `/alerts/:id` - Alert detail

### Settings Sub-pages (Fade)
- `/settings/profile` - User profile
- `/settings/pin` - Change PIN
- `/settings/kyc` - KYC verification
- `/settings/notifications` - Notification settings
- `/settings/security` - Security settings
- `/settings/limits` - Transaction limits
- `/settings/help` - Help & support
- `/settings/language` - Language selection

### Service Screens (Fade)
- `/services` - Services directory
- `/analytics` - Analytics dashboard
- `/scheduled` - Scheduled transfers
- `/recipients` - Saved recipients
- `/converter` - Currency converter
- `/savings` - Savings goals
- `/card` - Virtual card
- `/budget` - Budget tracker

### Success Screens (Scale + Fade)
- `/transfer/success` - Transfer success
- `/payment-receipt` - Payment receipt
- `/bill-payments/success/:id` - Bill payment success

## Animation Specifications

### Durations
- **Slide transitions:** 280ms
- **Fade transitions:** 200ms

### Curves
- **All transitions:** `Curves.fastOutSlowIn`
  - Provides smooth, natural motion
  - Consistent with Material Design guidelines
  - Optimal for luxury feel

### Performance
- Tested on both iOS and Android
- Runs at 60fps on modern devices
- Uses hardware acceleration where available
- Minimal impact on app startup time

## Design Principles

### 1. Contextual Awareness
Transitions reflect the relationship between screens:
- **Horizontal** indicates lateral movement (tabs)
- **Vertical** indicates hierarchical depth (modals/details)
- **Fade** indicates context switches without spatial meaning

### 2. Consistency
- Same curve across all transitions
- Predictable timing
- Unified visual language

### 3. Subtlety
- Not too fast (jarring)
- Not too slow (laggy)
- Just right for a luxury fintech app

### 4. Performance
- Optimized durations
- Hardware-accelerated animations
- Minimal overhead

## Testing

### Manual Testing Checklist
- [ ] Switch between all 4 main tabs
- [ ] Open and close modal screens (Send, Receive, Deposit)
- [ ] Navigate through settings sub-pages
- [ ] Open transaction detail from list
- [ ] Complete a transfer to see success screen
- [ ] Test back navigation for all routes
- [ ] Verify deep links work with transitions

### Automated Testing
```bash
# Run all tests
flutter test

# Test specific router functionality
flutter test test/router_test.dart

# Run widget tests with transitions
flutter test test/widgets/
```

## Troubleshooting

### Transitions not showing
- Check that you're using `pageBuilder` not `builder`
- Verify the transition is properly wrapped in a transition widget
- Test in profile/release mode (debug mode may affect performance)

### Transitions feel janky
- Run in profile mode to check for frame drops
- Use DevTools performance overlay
- Check for expensive builds during transitions

### Back button behavior incorrect
- Verify route hierarchy in GoRouter
- Check for duplicate route definitions
- Ensure proper use of `context.push()` vs `context.go()`

## Performance Optimization

### Best Practices
1. Use `const` constructors where possible
2. Avoid expensive operations during transitions
3. Preload data before navigation if needed
4. Use lazy loading for heavy screens

### Monitoring
```dart
// Enable performance overlay in debug mode
MaterialApp(
  showPerformanceOverlay: true,
  // ...
);
```

## Future Enhancements

### Planned Features
1. **Hero Animations** - Shared element transitions
2. **Gesture-based Navigation** - Swipe to go back
3. **Adaptive Transitions** - Different animations for tablet
4. **Reduced Motion Support** - Respect system accessibility settings
5. **Custom Transitions** - Per-feature custom animations

### Accessibility
- Add reduced motion detection
- Provide alternative navigation cues
- Ensure keyboard navigation works with transitions

## Integration with App

### Dependencies
```yaml
dependencies:
  go_router: ^17.0.1
  flutter_riverpod: ^3.2.0
```

### Provider Setup
```dart
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    // ... router configuration
  );
});
```

### MaterialApp Configuration
```dart
MaterialApp.router(
  routerConfig: ref.watch(routerProvider),
  // ... other config
)
```

## Contributing

When adding new routes:
1. Choose appropriate transition type
2. Update this README with new routes
3. Update TRANSITIONS_GUIDE.md if needed
4. Test on both iOS and Android
5. Verify with design team

## Support

For questions or issues:
- Check TRANSITIONS_GUIDE.md for detailed examples
- Review existing route implementations
- Test with transition_demo.dart
- Consult the Flutter GoRouter documentation

---

**Last Updated:** January 2026
**Flutter Version:** 3.x
**GoRouter Version:** 17.x
