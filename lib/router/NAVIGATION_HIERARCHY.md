# Navigation Hierarchy & Transition Map

## Visual Hierarchy

```
┌─────────────────────────────────────────────────────────────────┐
│                         SPLASH (/)                              │
│                     [No Transition]                             │
│                            ↓                                     │
│                      ONBOARDING                                 │
│                        [Fade]                                   │
│                            ↓                                     │
│                    LOGIN → OTP                                  │
│                        [Fade]                                   │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    MAIN APP (Authenticated)                     │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │            BOTTOM NAVIGATION TABS                       │  │
│  │            [Horizontal Slide ↔]                         │  │
│  │                                                         │  │
│  │  HOME ←→ TRANSACTIONS ←→ REFERRALS ←→ SETTINGS         │  │
│  │   │          │              │            │              │  │
│  └───┼──────────┼──────────────┼────────────┼──────────────┘  │
│      │          │              │            │                  │
│      ↓          ↓              │            ↓                  │
│   MODALS    DETAILS            │       SUB-PAGES              │
│   [Vert]    [Vert]             │         [Fade]               │
│                                │                               │
└────────────────────────────────┼───────────────────────────────┘
                                 │
                                 ↓
                            REWARDS FLOW
```

## Detailed Route Tree

### 1. PUBLIC ROUTES (Unauthenticated)

```
/ (Splash)
 └─ [No Transition]

/onboarding
 └─ [Fade]

/login
 └─ [Fade]
     └─ /otp
         └─ [Fade]
```

---

### 2. MAIN TABS (Bottom Navigation)

```
┌────────────────────────────────────────────────────────┐
│                   HORIZONTAL SLIDE                     │
├────────────────────────────────────────────────────────┤

/home (Wallet Dashboard)
 ├─ [Vertical Slide] → /send
 ├─ [Vertical Slide] → /receive
 ├─ [Vertical Slide] → /deposit
 │   └─ [Vertical Slide] → /deposit/instructions
 ├─ [Vertical Slide] → /withdraw
 ├─ [Vertical Slide] → /scan
 ├─ [Fade] → /services
 │   ├─ [Vertical Slide] → /airtime
 │   ├─ [Vertical Slide] → /bills
 │   ├─ [Fade] → /analytics
 │   ├─ [Fade] → /scheduled
 │   ├─ [Fade] → /recipients
 │   ├─ [Fade] → /converter
 │   └─ [Fade] → /savings
 ├─ [Vertical Slide] → /request
 ├─ [Vertical Slide] → /split
 ├─ [Fade] → /card
 └─ [Fade] → /budget

/transactions (Activity)
 ├─ [Vertical Slide] → /transactions/:id
 └─ [Vertical Slide] → /transactions/export

/referrals (Rewards)

/settings (Settings Main)
 ├─ [Fade] → /settings/profile
 ├─ [Fade] → /settings/pin
 ├─ [Fade] → /settings/kyc
 ├─ [Fade] → /settings/notifications
 ├─ [Fade] → /settings/security
 ├─ [Fade] → /settings/limits
 ├─ [Fade] → /settings/help
 └─ [Fade] → /settings/language

└────────────────────────────────────────────────────────┘
```

---

### 3. GLOBAL ROUTES (Accessible from Anywhere)

```
NOTIFICATIONS
/notifications
 └─ [Vertical Slide]

SUCCESS SCREENS
/transfer/success
 └─ [Scale + Fade]

MERCHANT PAY
/scan-to-pay
 └─ [Vertical Slide]
     └─ /payment-receipt
         └─ [Scale + Fade]

/merchant-dashboard
 └─ [Fade]
     ├─ /merchant-qr
     │   └─ [Vertical Slide]
     ├─ /create-payment-request
     │   └─ [Vertical Slide]
     └─ /merchant-transactions
         └─ [Fade]

BILL PAYMENTS
/bill-payments
 └─ [Vertical Slide]
     ├─ /bill-payments/form/:providerId
     │   └─ [Vertical Slide]
     ├─ /bill-payments/success/:paymentId
     │   └─ [Scale + Fade]
     └─ /bill-payments/history
         └─ [Fade]

ALERTS
/alerts
 └─ [Fade]
     ├─ /alerts/preferences
     │   └─ [Fade]
     └─ /alerts/:id
         └─ [Vertical Slide]
```

---

## Transition Matrix

| From → To | Same Tab | Different Tab | Modal | Detail | Settings | Success |
|-----------|----------|---------------|-------|--------|----------|---------|
| **Tab** | - | Horizontal | Vertical | Vertical | Fade | Scale+Fade |
| **Modal** | Pop | Pop+Horizontal | - | Vertical | Fade | Scale+Fade |
| **Detail** | Pop | Pop+Horizontal | Vertical | - | Fade | Scale+Fade |
| **Settings** | Pop+Horizontal | Pop+Horizontal | Vertical | Vertical | Fade | Scale+Fade |

---

## Navigation Patterns

### Pattern 1: Tab Navigation (Horizontal)
```
Home ←[Horizontal]→ Transactions ←[Horizontal]→ Settings
```

**User Experience:**
- Smooth lateral movement
- Feels like flipping through cards
- Maintains context

---

### Pattern 2: Action Modal (Vertical)
```
Home
  ↓ [Vertical Slide]
Send Money
  ↓ [Scale + Fade]
Success Screen
  ↓ [Pop]
Home
```

**User Experience:**
- Modal slides up from bottom
- Success animates with celebration
- Returns to home smoothly

---

### Pattern 3: Detail View (Vertical)
```
Transactions List
  ↓ [Vertical Slide]
Transaction Detail
  ↓ [Pop]
Transactions List
```

**User Experience:**
- Detail slides up over list
- Maintains list context underneath
- Easy to return with back button

---

### Pattern 4: Settings Flow (Fade)
```
Settings Main
  ↓ [Fade]
Profile Settings
  ↓ [Fade]
Edit Field
  ↓ [Pop]
Profile Settings
```

**User Experience:**
- Gentle transitions
- Feels like moving through pages
- No aggressive motion

---

### Pattern 5: Complex Flow
```
Home
  ↓ [Vertical Slide]
Services
  ↓ [Fade]
Bill Payments
  ↓ [Vertical Slide]
Payment Form
  ↓ [Scale + Fade]
Success
  ↓ [Pop All]
Home
```

**User Experience:**
- Contextual transitions at each step
- Vertical for actions
- Fade for navigation
- Celebration for success

---

## Deep Link Behavior

### Direct Navigation
When opening a deep link, the app uses the appropriate transition:

```
Deep Link: joonapay://send

Flow:
Splash [No Transition]
  ↓
Home [Fade if cold start]
  ↓
Send [Vertical Slide]
```

### Back Stack Construction
Deep links build proper navigation stack:

```
Deep Link: joonapay://transactions/123

Stack:
├─ Home (root)
├─ Transactions [Horizontal from Home]
└─ Transaction Detail [Vertical from Transactions]
```

---

## Gesture Navigation

### Back Gesture
iOS edge swipe and Android back button both trigger:
- Reverse of the entry transition
- Pop animation matches push animation
- Maintains visual consistency

### Swipe Between Tabs (Future)
```
┌─────┬─────┬─────┬─────┐
│ Home│Trans│Refer│Set  │  ← Swipe horizontally
└─────┴─────┴─────┴─────┘
```

---

## Accessibility

### Reduced Motion
When system reduced motion is enabled:
- All transitions → Fade (200ms)
- Or optionally → No transition (0ms)
- Maintains navigation logic

### Screen Reader
- Announces route changes
- Provides navigation context
- Describes modal presentations

---

## Performance Considerations

### Transition Cost
| Transition Type | Performance Cost | Notes |
|----------------|------------------|-------|
| Horizontal Slide | Low | Simple offset animation |
| Vertical Slide | Low | Offset + fade |
| Fade | Very Low | Opacity only |
| Scale + Fade | Low | Scale + opacity |

### Optimization Tips
1. Pre-render heavy screens before navigation
2. Use `const` constructors
3. Avoid rebuilds during transitions
4. Cache images and data

---

## State Management During Transitions

### State Persistence
```dart
// State persists during transitions
Home (State: Balance = $1000)
  ↓ [Vertical Slide]
Send (State: Input = $50)
  ↓ [Pop]
Home (State: Balance = $1000) ← Restored
```

### State Updates
```dart
// State updates trigger smooth rebuilds
Home (Balance = $1000)
  ↓ [Send $50]
  ↓ [Success]
  ↓ [Pop]
Home (Balance = $950) ← Updated with fade
```

---

## Testing Transitions

### Manual Test Cases
1. **Tab Navigation**
   - [ ] Switch between all 4 tabs
   - [ ] Verify horizontal slide direction
   - [ ] Check for smooth animation

2. **Modal Flows**
   - [ ] Open Send modal
   - [ ] Verify vertical slide from bottom
   - [ ] Test back button behavior

3. **Detail Views**
   - [ ] Open transaction detail
   - [ ] Verify slide animation
   - [ ] Check back stack

4. **Settings Navigation**
   - [ ] Navigate through settings
   - [ ] Verify fade transitions
   - [ ] Test deep navigation

5. **Success Screens**
   - [ ] Complete transfer
   - [ ] Verify scale + fade
   - [ ] Check celebration effect

### Automated Tests
```dart
testWidgets('Home to Transactions uses horizontal slide', (tester) async {
  // Setup
  await tester.pumpWidget(MyApp());

  // Navigate
  await tester.tap(find.text('Transactions'));
  await tester.pump();

  // Verify transition
  expect(find.byType(SlideTransition), findsOneWidget);

  // Complete animation
  await tester.pumpAndSettle();
});
```

---

## Troubleshooting Guide

### Issue: Wrong transition type
**Solution:** Check route path in `RouteTransitionHelper` extension

### Issue: Janky animations
**Solution:**
1. Run in profile mode
2. Check for expensive builds
3. Use performance overlay

### Issue: Back button not working
**Solution:** Verify route hierarchy and use proper navigation methods

### Issue: Deep links not animating
**Solution:** Ensure deep link handler uses proper navigation context

---

**Last Updated:** January 2026
