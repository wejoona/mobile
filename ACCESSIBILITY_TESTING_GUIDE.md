# Accessibility Testing Guide - JoonaPay Mobile

This guide helps developers test accessibility features in the JoonaPay mobile app.

## Quick Start

### iOS - VoiceOver Testing

1. **Enable VoiceOver:**
   - Settings → Accessibility → VoiceOver → ON
   - Or use Accessibility Shortcut (triple-click side button)

2. **Basic Gestures:**
   - **Swipe right:** Move to next element
   - **Swipe left:** Move to previous element
   - **Double-tap:** Activate element
   - **Three-finger swipe:** Scroll page
   - **Two-finger double-tap:** Start/stop action
   - **Rotor (two-finger rotate):** Change navigation mode

3. **Test Critical Flows:**
   ```
   Login Screen:
   1. Launch app with VoiceOver on
   2. Swipe through elements - should hear:
      "JoonaPay, heading"
      "Welcome back, text"
      "Selected country Ivory Coast, button"
      "Phone number, text field, enter 10 digits"
      "Continue, button, double tap to activate"
   3. Verify focus order is logical
   4. Test input by double-tapping phone field
   ```

---

### Android - TalkBack Testing

1. **Enable TalkBack:**
   - Settings → Accessibility → TalkBack → ON
   - Or use Volume key shortcut

2. **Basic Gestures:**
   - **Swipe right:** Move to next element
   - **Swipe left:** Move to previous element
   - **Double-tap:** Activate element
   - **Two-finger swipe:** Scroll page
   - **Swipe down then right:** Read from top

3. **Test Critical Flows:**
   ```
   Wallet Home:
   1. Open wallet with TalkBack on
   2. Swipe through elements - should hear:
      "Good morning, text"
      "Available balance: 1 thousand 234 dollars and 56 cents"
      "Hide balance, button, double tap to hide your balance"
      "Send money, button, double tap to send money"
   3. Test balance hiding/showing
   4. Verify transaction list is navigable
   ```

---

## Testing Checklist

### Login/Registration Flow

#### Country Selector
- [ ] Country button announces current selection
- [ ] Country list items announce name, code, currency
- [ ] Selected state is indicated
- [ ] Search field filters results
- [ ] Focus returns to country button after selection

**Expected Announcement:**
```
"Selected country: Ivory Coast, phone code plus 2 2 5, currency XOF, button"
```

#### Phone Number Input
- [ ] Input field announces label and hint
- [ ] Character counter updates as you type
- [ ] Validation status announced (valid/invalid)
- [ ] Error messages read aloud
- [ ] Success indicator announced

**Expected Announcements:**
```
// Empty:
"Phone number, text field, enter your phone number, 10 digits required"

// Typing:
"3 of 10 digits entered"

// Complete:
"Phone number: 0 7 1 2 3 4 5 6 7 8, valid, 10 of 10 digits entered"

// Invalid:
"Phone number: 0 7 1, invalid, 3 of 10 digits entered"
```

#### OTP Screen
- [ ] Auto-focus on first digit
- [ ] Each digit announced separately
- [ ] Progress announced (e.g., "3 of 6 digits entered")
- [ ] Resend timer announced
- [ ] Error messages read aloud

---

### Wallet Home Screen

#### Balance Display
- [ ] Balance amount formatted for clarity
- [ ] Hidden state announced clearly
- [ ] Toggle button labeled correctly
- [ ] Pending balance announced if present

**Expected Announcements:**
```
// Visible:
"Available balance: 1 thousand 234 dollars and 56 cents"

// Hidden:
"Balance hidden, double tap balance visibility icon to show"

// Toggle button:
"Hide balance, button, double tap to hide your balance"
"Show balance, button, double tap to show your balance"
```

#### Quick Actions
- [ ] All 4 buttons clearly labeled
- [ ] Action described in hint
- [ ] Button semantics present

**Expected Announcements:**
```
"Send money, button, double tap to send money to another user"
"Receive money, button, double tap to show your QR code"
"Deposit funds, button, double tap to add money to your wallet"
"Transaction history, button, double tap to view all transactions"
```

#### Transaction List
- [ ] Each transaction row is a button
- [ ] Transaction details fully described
- [ ] Date formatted clearly
- [ ] Amount direction (sent/received) clear
- [ ] Tap opens detail view

**Expected Announcement:**
```
"Transfer to John Doe, sent 25 dollars, yesterday at 3:45 PM, button"
```

---

### Send Money Flow

#### Tab Navigation
- [ ] Tab labels announced
- [ ] Current tab indicated
- [ ] Swipe to switch tabs works

**Expected Announcements:**
```
"To Phone, tab 1 of 2, selected"
"To Wallet, tab 2 of 2"
```

#### Contact Selection
- [ ] Recent contacts announced with status
- [ ] Selected state indicated
- [ ] JoonaPay user badge announced
- [ ] Clear button labeled

**Expected Announcements:**
```
"John Doe, Selected, JoonaPay user, button"
"Jane Smith, Not selected, button"
```

#### Amount Input
- [ ] Input labeled clearly
- [ ] Dollar amount formatted for screen reader
- [ ] Validation errors announced
- [ ] Quick amount buttons labeled

**Expected Announcements:**
```
// Empty:
"Enter amount in dollars, text field"

// With value:
"Amount: 25 dollars and 50 cents, text field"

// Error:
"Error: Insufficient balance, text field"

// Quick amounts:
"\$5, button, double tap to set amount to 5 dollars"
"\$10, button, double tap to set amount to 10 dollars"
"MAX, button, double tap to set amount to maximum available"
```

#### Wallet Address Input
- [ ] Address field labeled
- [ ] Long addresses abbreviated
- [ ] Validation errors announced
- [ ] QR scan button labeled

**Expected Announcements:**
```
// Empty:
"Enter recipient wallet address, text field"

// With address:
"Wallet address: 0 x 1 2 3 4 dot dot dot 5 6 7 8, text field"

// Error:
"Error: Invalid Ethereum address format, text field"

// QR button:
"Scan QR code, button, double tap to scan recipient QR code"
```

#### Confirmation
- [ ] Summary announced clearly
- [ ] PIN entry labeled
- [ ] Success/error messages announced
- [ ] Navigation happens after announcement

---

## Automated Testing

### Contrast Validation

Run in debug mode to see console warnings:

```dart
import 'package:flutter/material.dart';
import '../utils/accessibility_utils.dart';

void testContrast() {
  // This runs in debug mode only
  AccessibilityUtils.validateContrast(
    foreground: AppColors.textPrimary,
    background: AppColors.obsidian,
    componentName: 'Primary text on dark background',
  );
}
```

**Expected Output (if contrast is low):**
```
⚠️ ACCESSIBILITY WARNING: Primary text on dark background has insufficient contrast
   Foreground: Color(0xfff5f5f0)
   Background: Color(0xff0a0a0c)
   Contrast Ratio: 3.2:1
   Required: 4.5:1 (WCAG AA)
```

---

### Widget Testing

Example test for button semantics:

```dart
testWidgets('AppButton has proper semantics', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: AppButton(
          label: 'Send',
          semanticLabel: 'Send money to recipient',
          onPressed: () {},
        ),
      ),
    ),
  );

  // Find by semantic label
  final semantics = tester.getSemantics(find.byType(AppButton));

  expect(semantics.label, 'Send money to recipient');
  expect(semantics.isButton, true);
  expect(semantics.isEnabled, true);
  expect(semantics.hasAction(SemanticsAction.tap), true);
});
```

---

## Common Issues & Solutions

### Issue: "Button" announced twice
**Cause:** Both Semantics wrapper and child widget have button semantics
**Solution:** Use `excludeSemantics: true` on Semantics wrapper
```dart
Semantics(
  label: 'Send money',
  button: true,
  excludeSemantics: true,  // ← Add this
  child: AppButton(...),
)
```

---

### Issue: Decorative icons read aloud
**Cause:** Icons have default semantics
**Solution:** Wrap with `ExcludeSemantics`
```dart
ExcludeSemantics(
  child: Icon(Icons.arrow_forward),
)
```

---

### Issue: Complex data not clear
**Cause:** Raw formatting (e.g., "\$1,234.56" read as "dollar one comma...")
**Solution:** Use AccessibilityUtils formatters
```dart
AppText(
  '\$1,234.56',
  semanticLabel: AccessibilityUtils.formatCurrencyForScreenReader(1234.56),
  // Announces: "1 thousand 234 dollars and 56 cents"
)
```

---

### Issue: Dynamic content not announced
**Cause:** Screen reader doesn't detect changes
**Solution:** Use `AccessibilityUtils.announce()`
```dart
// When data loads
AccessibilityUtils.announce(context, 'Balance loaded');

// When error occurs
AccessibilityUtils.announceError(context, 'Failed to load transactions');
```

---

### Issue: Focus order is wrong
**Cause:** Widget tree order doesn't match visual order
**Solution:** Reorder widgets or use `FocusTraversalOrder`
```dart
FocusTraversalOrder(
  order: NumericFocusOrder(1.0),
  child: Widget1(),
),
FocusTraversalOrder(
  order: NumericFocusOrder(2.0),
  child: Widget2(),
),
```

---

## Testing Tools

### Accessibility Inspector (iOS)
1. Open Xcode
2. Run app in simulator
3. Window → Show Accessibility Inspector
4. Inspect elements to see labels, hints, traits

### Accessibility Scanner (Android)
1. Install from Play Store
2. Enable in Accessibility settings
3. Tap floating button to scan screen
4. Review suggestions

### Flutter DevTools
1. Run `flutter run` with DevTools enabled
2. Open DevTools in browser
3. Go to "Inspector" tab
4. Enable "Show Semantics Tree"
5. See semantics hierarchy

---

## Test Cases

### P0 - Critical (Must Pass)

| Test Case | Screen | Expected Result |
|-----------|--------|----------------|
| TC-001 | Login | All elements navigable with VoiceOver |
| TC-002 | Login | Phone input announces validation status |
| TC-003 | Wallet | Balance amount clearly announced |
| TC-004 | Wallet | Transaction rows fully described |
| TC-005 | Send | Amount input announces value |
| TC-006 | Send | Recipient selection works |
| TC-007 | All | Button labels describe action |
| TC-008 | All | Error messages announced |

### P1 - Important (Should Pass)

| Test Case | Screen | Expected Result |
|-----------|--------|----------------|
| TC-101 | Login | Country selector fully accessible |
| TC-102 | Wallet | Quick actions have hints |
| TC-103 | Send | Contact chips announce status |
| TC-104 | Send | Wallet address abbreviated |
| TC-105 | All | Decorative elements excluded |
| TC-106 | All | Loading states announced |

### P2 - Nice to Have

| Test Case | Screen | Expected Result |
|-----------|--------|----------------|
| TC-201 | Wallet | Reference currency announced |
| TC-202 | Send | Saved contacts searchable |
| TC-203 | All | Haptic feedback on actions |
| TC-204 | All | Sound effects optional |

---

## Manual Test Script

### Script 1: New User Registration (VoiceOver)

```
1. Enable VoiceOver
2. Launch app
3. Swipe right through onboarding screens
   ✓ Verify: Each screen content announced
4. Tap "Get Started"
5. Swipe to country selector
   ✓ Verify: "Selected country Ivory Coast, button"
6. Double-tap to open picker
7. Swipe through countries
   ✓ Verify: Name, code, currency announced
8. Double-tap to select
9. Swipe to phone input
   ✓ Verify: "Phone number, text field, enter 10 digits"
10. Double-tap to focus
11. Type phone number
    ✓ Verify: Progress announced
12. Swipe to Continue button
    ✓ Verify: "Continue, button" or "Create account, button"
13. Double-tap to submit
    ✓ Verify: OTP screen announced
```

### Script 2: Send Money (TalkBack)

```
1. Enable TalkBack
2. Open app to wallet home
3. Swipe to "Send money" button
   ✓ Verify: "Send money, button, double tap to send money"
4. Double-tap to open send screen
5. Swipe through recent contacts
   ✓ Verify: Name and status announced
6. Double-tap to select contact
   ✓ Verify: Selection confirmed
7. Swipe to amount input
   ✓ Verify: "Enter amount in dollars, text field"
8. Double-tap to focus
9. Type amount: 25.50
   ✓ Verify: "Amount: 25 dollars and 50 cents"
10. Swipe to Send button
    ✓ Verify: "Send, button, double tap to activate"
11. Double-tap to confirm
    ✓ Verify: PIN screen announced
```

---

## Performance Checklist

- [ ] VoiceOver gestures respond within 300ms
- [ ] TalkBack gestures respond within 300ms
- [ ] Focus changes are smooth (no lag)
- [ ] Announcements don't overlap
- [ ] Long labels don't cut off

---

## Reporting Issues

When reporting accessibility bugs, include:

1. **Screen reader:** VoiceOver or TalkBack
2. **OS version:** iOS 17.2 / Android 14
3. **Screen:** Login, Wallet Home, Send Money, etc.
4. **Element:** Button, Input, Text, etc.
5. **Expected:** What should be announced
6. **Actual:** What is announced
7. **Steps to reproduce:**
   ```
   1. Enable VoiceOver
   2. Navigate to X screen
   3. Swipe to Y element
   4. Observe announcement
   ```

---

## Resources

- [Apple VoiceOver Guide](https://support.apple.com/guide/iphone/turn-on-and-practice-voiceover-iph3e2e415f/ios)
- [Android TalkBack Guide](https://support.google.com/accessibility/android/answer/6283677)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Flutter Accessibility](https://docs.flutter.dev/development/accessibility-and-localization/accessibility)
- [Material Design Accessibility](https://m3.material.io/foundations/accessible-design)

---

**Last Updated:** 2024-01-29
**Version:** 1.0
