# Page Transitions Guide

## Overview
This guide documents the contextual navigation animations implemented in the JoonaPay USDC Wallet app. The transitions are designed to create a smooth, luxury experience that matches the app's design system.

## Transition Types

### 1. Horizontal Slide (Left/Right)
**Duration:** 280ms
**Curve:** `Curves.fastOutSlowIn`
**Use Case:** Same-level navigation

#### Routes:
- `/home` - Wallet home screen
- `/transactions` - Transaction history
- `/referrals` - Referrals/rewards screen
- `/settings` - Settings main screen

**Behavior:**
- Tabs slide horizontally when switching
- Creates a sense of lateral movement between peer screens
- Direction is left-to-right or right-to-left based on navigation order

---

### 2. Vertical Slide (Up from Bottom)
**Duration:** 280ms
**Curve:** `Curves.fastOutSlowIn`
**Use Case:** Modal screens and detail views

#### Routes:

**Action Modals:**
- `/send` - Send money
- `/receive` - Receive money
- `/deposit` - Deposit funds
- `/withdraw` - Withdraw funds
- `/scan` - Scan QR code
- `/scan-to-pay` - Merchant QR scan
- `/request` - Request money
- `/split` - Split bill
- `/airtime` - Buy airtime
- `/bills` - Pay bills
- `/bill-payments` - Bill payments list
- `/bill-payments/form/:providerId` - Bill payment form

**Detail Views:**
- `/transactions/:id` - Transaction detail
- `/notifications` - Notifications list
- `/deposit/instructions` - Deposit instructions
- `/alerts/:id` - Alert detail
- `/merchant-qr` - Merchant QR display
- `/create-payment-request` - Create payment request
- `/transactions/export` - Export transactions

**Behavior:**
- Pages slide up from the bottom like a modal
- Combined with fade for smoother appearance
- Gives users the feeling of opening an overlay or detail view

---

### 3. Fade Transition
**Duration:** 200ms
**Curve:** `Curves.fastOutSlowIn`
**Use Case:** Auth flows and settings sub-pages

#### Routes:

**Auth Flow:**
- `/login` - Login screen
- `/otp` - OTP verification
- `/onboarding` - Onboarding screens

**Settings Sub-pages:**
- `/settings/profile` - User profile
- `/settings/pin` - Change PIN
- `/settings/kyc` - KYC verification
- `/settings/notifications` - Notification settings
- `/settings/security` - Security settings
- `/settings/limits` - Transaction limits
- `/settings/help` - Help & support
- `/settings/language` - Language settings

**Service Screens:**
- `/services` - Services directory
- `/analytics` - Analytics dashboard
- `/scheduled` - Scheduled transfers
- `/recipients` - Saved recipients
- `/converter` - Currency converter
- `/savings` - Savings goals
- `/card` - Virtual card
- `/budget` - Budget tracker
- `/merchant-dashboard` - Merchant dashboard
- `/merchant-transactions` - Merchant transactions
- `/alerts` - Alerts list
- `/alerts/preferences` - Alert preferences
- `/bill-payments/history` - Bill payment history

**Behavior:**
- Simple cross-fade between screens
- Subtle and elegant
- Best for screens where spatial relationship isn't important

---

### 4. Scale + Fade (Success Screens)
**Duration:** 280ms
**Curve:** `Curves.fastOutSlowIn`
**Use Case:** Success/confirmation screens

#### Routes:
- `/transfer/success` - Transfer success
- `/payment-receipt` - Payment receipt
- `/bill-payments/success/:paymentId` - Bill payment success

**Behavior:**
- Scales from 92% to 100% while fading in
- Creates a "pop" effect that celebrates success
- Draws attention to important confirmation states

---

### 5. No Transition (Instant)
**Duration:** 0ms
**Use Case:** Initial routes

#### Routes:
- `/` - Splash screen

**Behavior:**
- No animation for immediate display
- Used only for initial app launch

---

## Implementation Details

### File Structure
```
lib/router/
├── app_router.dart           # Main router configuration
├── page_transitions.dart     # Transition implementations
└── TRANSITIONS_GUIDE.md      # This file
```

### Using Custom Transitions

Instead of using `builder`, routes use `pageBuilder` with custom transition pages:

```dart
GoRoute(
  path: '/send',
  pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
    state: state,
    child: const SendView(),
  ),
),
```

### Creating New Routes

When adding new routes, consider the navigation hierarchy:

1. **Is it a tab or same-level screen?** → Use `horizontalSlide`
2. **Is it a modal or action screen?** → Use `verticalSlide`
3. **Is it a settings sub-page?** → Use `fade`
4. **Is it a success/confirmation?** → Use `scaleAndFade`

Example:
```dart
GoRoute(
  path: '/new-feature',
  pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
    state: state,
    child: const NewFeatureView(),
  ),
),
```

### Extension Helper

The `RouteTransitionHelper` extension provides automatic transition selection:

```dart
extension RouteTransitionHelper on String {
  TransitionType get transitionType { ... }

  Page<dynamic> createTransitionPage({
    required GoRouterState state,
    required Widget child,
  }) { ... }
}
```

Usage:
```dart
'/send'.createTransitionPage(
  state: state,
  child: const SendView(),
)
```

---

## Animation Timing

| Transition Type | Duration | Curve |
|----------------|----------|-------|
| Horizontal Slide | 280ms | fastOutSlowIn |
| Vertical Slide | 280ms | fastOutSlowIn |
| Fade | 200ms | fastOutSlowIn |
| Scale + Fade | 280ms | fastOutSlowIn |
| None | 0ms | - |

---

## Design Principles

### 1. Contextual Awareness
Transitions reflect the relationship between screens:
- **Horizontal** = peer-to-peer navigation
- **Vertical** = parent-to-child or modal presentation
- **Fade** = context switch without spatial relationship

### 2. Consistency
All transitions use the same curve (`fastOutSlowIn`) for a cohesive feel.

### 3. Performance
Durations are optimized for:
- Smoothness (not too fast)
- Responsiveness (not too slow)
- Luxury feel (polished and refined)

### 4. Accessibility
- Transitions respect reduced motion preferences (can be added via `MediaQuery.of(context).disableAnimations`)
- Clear visual hierarchy helps users understand navigation structure

---

## Testing Transitions

To test transitions:

1. **Tab Navigation:** Switch between Home, Transactions, Referrals, and Settings
2. **Modal Actions:** Open Send, Receive, Deposit screens
3. **Detail Views:** Open transaction details from list
4. **Settings Flow:** Navigate through settings sub-pages
5. **Success Screens:** Complete a transfer to see success animation

---

## Future Enhancements

Potential improvements:
1. **Hero Animations:** For shared elements between screens (e.g., transaction cards)
2. **Gesture-based Transitions:** Swipe to go back
3. **Adaptive Transitions:** Different animations for tablet vs phone
4. **Reduced Motion Support:** Detect system accessibility settings

---

## Maintenance

When modifying transitions:

1. **Test on both iOS and Android** - Platform differences may affect perception
2. **Verify performance** - Run in profile mode to check for jank
3. **Update this guide** - Keep documentation in sync with code
4. **Get design approval** - Ensure changes align with brand guidelines

---

## Credits

Implemented for JoonaPay USDC Wallet
Design System: Luxury Gold Theme
Framework: Flutter 3.x + GoRouter 17.x
