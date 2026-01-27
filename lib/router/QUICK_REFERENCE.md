# Navigation Transitions - Quick Reference

## When to Use Which Transition

### 🔹 Horizontal Slide (↔)
**Use for:** Same-level navigation, tab switching
```dart
GoRoute(
  path: '/home',
  pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
    state: state,
    child: const HomeView(),
  ),
)
```
**Examples:** `/home`, `/transactions`, `/settings`, `/referrals`

---

### 🔹 Vertical Slide (↑)
**Use for:** Modals, actions, details
```dart
GoRoute(
  path: '/send',
  pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
    state: state,
    child: const SendView(),
  ),
)
```
**Examples:** `/send`, `/receive`, `/deposit`, `/scan`, `/notifications`

---

### 🔹 Fade (⚡)
**Use for:** Auth flow, settings, services
```dart
GoRoute(
  path: '/settings/profile',
  pageBuilder: (context, state) => AppPageTransitions.fade(
    state: state,
    child: const ProfileView(),
  ),
)
```
**Examples:** `/login`, `/otp`, `/settings/*`, `/services`, `/analytics`

---

### 🔹 Scale + Fade (✨)
**Use for:** Success/confirmation screens
```dart
GoRoute(
  path: '/transfer/success',
  pageBuilder: (context, state) {
    Widget child = TransferSuccessView(...);
    return createSuccessTransition(state: state, child: child);
  },
)
```
**Examples:** `/transfer/success`, `/payment-receipt`, `/bill-payments/success/:id`

---

### 🔹 None (⚡)
**Use for:** Splash/initial screens
```dart
GoRoute(
  path: '/',
  pageBuilder: (context, state) => AppPageTransitions.none(
    state: state,
    child: const SplashView(),
  ),
)
```
**Examples:** `/` (splash only)

---

## Decision Tree

```
Is it a tab/peer screen?
├─ YES → Horizontal Slide
└─ NO
    └─ Is it a modal/action?
        ├─ YES → Vertical Slide
        └─ NO
            └─ Is it a success screen?
                ├─ YES → Scale + Fade
                └─ NO
                    └─ Is it auth/settings/service?
                        ├─ YES → Fade
                        └─ NO → Horizontal Slide (default)
```

---

## Navigation Methods

```dart
// Push a new route
context.push('/send');

// Go to route (replace current)
context.go('/home');

// Pop back
context.pop();

// Push with data
context.push('/transactions/123', extra: transactionObject);

// Replace named route
context.pushReplacement('/transfer/success');
```

---

## Timing Reference

| Transition | Duration | Curve |
|-----------|----------|-------|
| Horizontal | 280ms | fastOutSlowIn |
| Vertical | 280ms | fastOutSlowIn |
| Fade | 200ms | fastOutSlowIn |
| Scale+Fade | 280ms | fastOutSlowIn |

---

## Common Patterns

### Pattern 1: Tab to Modal
```dart
Home → (Vertical Slide) → Send Modal
```

### Pattern 2: Tab to Detail
```dart
Transactions → (Vertical Slide) → Transaction Detail
```

### Pattern 3: Settings Flow
```dart
Settings → (Fade) → Profile → (Fade) → Edit
```

### Pattern 4: Success Flow
```dart
Send → (Scale+Fade) → Success → (Pop) → Home
```

---

## Testing Transitions

```bash
# Run app
flutter run

# Profile mode (for performance testing)
flutter run --profile

# Analyze code
flutter analyze lib/router/

# Optional: Add demo route to test
GoRoute(
  path: '/transition-demo',
  builder: (context, state) => const TransitionDemoView(),
)
```

---

## Troubleshooting

**Problem:** Transitions not appearing
- ✓ Use `pageBuilder` not `builder`
- ✓ Import `page_transitions.dart`
- ✓ Test in profile mode

**Problem:** Janky animations
- ✓ Check DevTools performance overlay
- ✓ Avoid expensive builds during transitions
- ✓ Use `const` constructors

**Problem:** Wrong transition type
- ✓ Check route path in decision tree
- ✓ Verify pageBuilder implementation
- ✓ Test navigation flow

---

## Files to Reference

| File | Purpose |
|------|---------|
| `page_transitions.dart` | Core implementation |
| `app_router.dart` | Route definitions |
| `README.md` | Full documentation |
| `TRANSITIONS_GUIDE.md` | Detailed guide |
| `NAVIGATION_HIERARCHY.md` | Visual hierarchy |

---

## Quick Copy-Paste Templates

### Horizontal Slide Route
```dart
GoRoute(
  path: '/your-tab',
  pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
    state: state,
    child: const YourTabView(),
  ),
),
```

### Vertical Slide Route
```dart
GoRoute(
  path: '/your-modal',
  pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
    state: state,
    child: const YourModalView(),
  ),
),
```

### Fade Route
```dart
GoRoute(
  path: '/your-page',
  pageBuilder: (context, state) => AppPageTransitions.fade(
    state: state,
    child: const YourPageView(),
  ),
),
```

### Success Route
```dart
GoRoute(
  path: '/your-success',
  pageBuilder: (context, state) {
    Widget child = YourSuccessView(...);
    return createSuccessTransition(state: state, child: child);
  },
),
```

### Route with Data
```dart
GoRoute(
  path: '/detail/:id',
  pageBuilder: (context, state) {
    final data = state.extra as YourDataType?;
    Widget child = data != null
      ? YourDetailView(data: data)
      : const ErrorView();
    return AppPageTransitions.verticalSlide(state: state, child: child);
  },
),
```

---

**Last Updated:** January 2026
