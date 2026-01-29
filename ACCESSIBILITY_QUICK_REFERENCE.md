# Accessibility Quick Reference - JoonaPay

A quick cheat sheet for developers to implement accessibility correctly.

---

## Import Required Files

```dart
import '../utils/accessibility_utils.dart';
import '../utils/accessibility_enhancements.dart';
```

---

## Common Patterns

### 1. Button with Semantic Label

```dart
// ❌ Bad - No semantic label
AppButton(
  label: 'Send',
  onPressed: () {},
)

// ✅ Good - Clear semantic label
AppButton(
  label: 'Send',
  semanticLabel: 'Send money to recipient',
  onPressed: () {},
)

// ✅ Best - Using helper
Semantics(
  label: 'Send money',
  hint: AccessibilityUtils.buttonHint('send money to another user'),
  button: true,
  excludeSemantics: true,
  child: GestureDetector(...),
)
```

---

### 2. Currency Formatting

```dart
// ❌ Bad - Screen reader says "dollar one comma two three four..."
AppText('\$1,234.56')

// ✅ Good - Screen reader says "1 thousand 234 dollars and 56 cents"
AppText(
  '\$1,234.56',
  semanticLabel: AccessibilityUtils.formatCurrencyForScreenReader(1234.56),
)
```

---

### 3. Phone Number Formatting

```dart
// ❌ Bad - Screen reader says "plus two two five zero seven one..."
AppText('+2250712345678')

// ✅ Good - Screen reader says "phone number, country code plus 2 2 5..."
AppText(
  '+2250712345678',
  semanticLabel: AccessibilityUtils.formatPhoneForScreenReader('+2250712345678'),
)
```

---

### 4. Input Field

```dart
// ❌ Bad - No semantic information
AppInput(
  controller: _controller,
  hint: 'Enter amount',
)

// ✅ Good - Full semantic information
AppInput(
  controller: _controller,
  label: 'Amount',
  hint: 'Enter amount in USD',
  semanticLabel: 'Enter amount in dollars',
  error: _error,
)
```

---

### 5. Excluding Decorative Elements

```dart
// ❌ Bad - Icon announced as "arrow forward"
Icon(Icons.arrow_forward)

// ✅ Good - Icon excluded from semantics
ExcludeSemantics(
  child: Icon(Icons.arrow_forward),
)

// ✅ Also good - Using helper
Container(...).excludeFromSemantics()
```

---

### 6. Balance Display (Hidden/Shown)

```dart
// ✅ Good - Using helper
AccessibleWidget.balanceDisplay(
  child: BalanceCard(...),
  amount: 1234.56,
  isHidden: _isHidden,
)

// ✅ Or manually
Semantics(
  label: WalletAccessibility.balanceLabel(_balance, isHidden: _isHidden),
  child: ...,
)
```

---

### 7. Transaction Row

```dart
// ✅ Good - Using helper
AccessibleWidget.transactionRow(
  child: TransactionCard(...),
  title: 'Transfer to John',
  amount: 25.00,
  date: DateTime.now(),
  isIncoming: false,
  onTap: () => viewDetails(),
)

// ✅ Or manually
Semantics(
  label: WalletAccessibility.transactionLabel(
    title: 'Transfer to John',
    amount: 25.00,
    date: DateTime.now(),
    isIncoming: false,
  ),
  button: true,
  onTap: () => viewDetails(),
  excludeSemantics: true,
  child: ...,
)
```

---

### 8. Toggle Button (Show/Hide)

```dart
// ✅ Good
IconButton(
  icon: Icon(_isHidden ? Icons.visibility : Icons.visibility_off),
  onPressed: _toggle,
  // Wrap with Semantics:
)

Semantics(
  label: WalletAccessibility.balanceVisibilityLabel(_isHidden),
  hint: WalletAccessibility.balanceVisibilityHint(_isHidden),
  button: true,
  excludeSemantics: true,
  child: IconButton(...),
)
```

---

### 9. Icon Button with Label

```dart
// ❌ Bad - No label
IconButton(
  icon: Icon(Icons.notifications),
  onPressed: () {},
)

// ✅ Good
AccessibleWidget.iconButton(
  child: IconButton(...),
  label: 'Notifications',
  action: 'view notifications',
)

// ✅ With badge
Semantics(
  label: hasUnread ? 'Notifications, $count unread' : 'Notifications',
  hint: 'Double tap to view notifications',
  button: true,
  excludeSemantics: true,
  child: Stack(
    children: [
      Icon(Icons.notifications),
      if (hasUnread) Badge(...).excludeFromSemantics(),
    ],
  ),
)
```

---

### 10. Loading State

```dart
// ❌ Bad - No announcement
CircularProgressIndicator()

// ✅ Good
AccessibleLoadingState(message: 'Loading balance')

// ✅ Or manually
Semantics(
  label: 'Loading balance',
  liveRegion: true,
  child: Column(
    children: [
      CircularProgressIndicator().excludeFromSemantics(),
      AppText('Loading...').excludeFromSemantics(),
    ],
  ),
)
```

---

### 11. Error State

```dart
// ❌ Bad - Error not announced
Text('Error: Failed to load')

// ✅ Good
AccessibilityUtils.announceError(context, 'Failed to load balance');

// ✅ With retry button
Semantics(
  label: 'Error: Failed to load balance',
  liveRegion: true,
  container: true,
  child: Column(
    children: [
      Icon(Icons.error).excludeFromSemantics(),
      AppText('Failed to load').excludeFromSemantics(),
      AppButton(
        label: 'Retry',
        onPressed: _retry,
      ),
    ],
  ),
)
```

---

### 12. List Tile

```dart
// ❌ Bad - No semantic information
ListTile(
  leading: Icon(Icons.person),
  title: Text('John Doe'),
  subtitle: Text('+2250712345678'),
  onTap: () {},
)

// ✅ Good
AccessibleWidget.listTile(
  child: ListTile(...),
  title: 'John Doe',
  subtitle: 'JoonaPay user',
  onTap: () {},
)

// ✅ Or manually
Semantics(
  label: 'John Doe, JoonaPay user',
  button: true,
  onTap: () {},
  excludeSemantics: true,
  child: ListTile(...),
)
```

---

### 13. Selectable Item (Contact Chip)

```dart
// ✅ Good
Semantics(
  label: SendMoneyAccessibility.contactChipLabel(
    name: 'John Doe',
    isSelected: _isSelected,
    hasApp: true,
  ),
  hint: AccessibilityUtils.selectableHint(_isSelected),
  button: true,
  selected: _isSelected,
  excludeSemantics: true,
  child: ContactChip(...),
)
```

---

### 14. Live Announcements

```dart
// When data changes
AccessibilityUtils.announce(context, 'Balance updated');

// When action succeeds
AccessibilityUtils.announceSuccess(context, 'Transfer sent successfully');

// When error occurs
AccessibilityUtils.announceError(context, 'Insufficient balance');
```

---

### 15. Contrast Validation (Debug Mode)

```dart
@override
Widget build(BuildContext context) {
  // Validate in debug mode
  assert(() {
    AccessibilityUtils.validateContrast(
      foreground: AppColors.textPrimary,
      background: AppColors.obsidian,
      componentName: 'Balance card text',
    );
    return true;
  }());

  return Container(...);
}
```

---

## Helper Functions Reference

### AccessibilityUtils

| Method | Use Case | Example |
|--------|----------|---------|
| `formatCurrencyForScreenReader()` | Currency amounts | `formatCurrencyForScreenReader(1234.56)` → "1 thousand 234 dollars and 56 cents" |
| `formatPhoneForScreenReader()` | Phone numbers | `formatPhoneForScreenReader('+2250712345678')` → "phone number, country code plus 2 2 5..." |
| `formatWalletAddressForScreenReader()` | Crypto addresses | `formatWalletAddressForScreenReader('0x1234...5678')` → "wallet address 0 x 1 2 3 4..." |
| `formatDateForScreenReader()` | Dates | `formatDateForScreenReader(date)` → "yesterday at 3:45 PM" |
| `buttonHint()` | Button hints | `buttonHint('send money')` → "Double tap to send money" |
| `toggleHint()` | Toggle hints | `toggleHint(isOn)` → "Double tap to turn off" |
| `announce()` | Live announcements | `announce(context, 'Data loaded')` |
| `announceError()` | Error announcements | `announceError(context, 'Failed')` |

---

### WalletAccessibility

| Method | Use Case |
|--------|----------|
| `balanceLabel()` | Balance display |
| `transactionLabel()` | Transaction rows |
| `balanceVisibilityLabel()` | Show/hide toggle |
| `balanceVisibilityHint()` | Show/hide hint |

---

### SendMoneyAccessibility

| Method | Use Case |
|--------|----------|
| `contactChipLabel()` | Contact chips |
| `amountInputLabel()` | Amount field |
| `phoneInputLabel()` | Phone field |
| `walletAddressLabel()` | Address field |

---

### AuthAccessibility

| Method | Use Case |
|--------|----------|
| `countrySelectorLabel()` | Country picker |
| `phoneNumberInputLabel()` | Phone input |
| `otpInputLabel()` | OTP input |

---

## Testing Shortcuts

### iOS VoiceOver
- **Enable/Disable:** Triple-click side button
- **Next element:** Swipe right
- **Previous element:** Swipe left
- **Activate:** Double-tap
- **Read from top:** Two-finger swipe up

### Android TalkBack
- **Enable/Disable:** Volume up + down (hold 3 seconds)
- **Next element:** Swipe right
- **Previous element:** Swipe left
- **Activate:** Double-tap
- **Read from top:** Swipe down then right

---

## Common Mistakes to Avoid

| ❌ Mistake | ✅ Solution |
|-----------|-----------|
| Using raw currency format | Use `AccessibilityUtils.formatCurrencyForScreenReader()` |
| No semantic label on buttons | Always add `semanticLabel` or `Semantics` wrapper |
| Decorative icons read aloud | Wrap with `ExcludeSemantics` |
| Error messages not announced | Use `AccessibilityUtils.announceError()` |
| Loading states silent | Use `Semantics(liveRegion: true)` |
| Duplicate announcements | Use `excludeSemantics: true` on wrapper |
| Poor contrast | Use `AccessibilityUtils.validateContrast()` |
| Complex data unclear | Format for screen readers (currency, phone, etc.) |
| No button semantics | Use `Semantics(button: true)` |
| No hints on interactive elements | Add `hint` parameter |

---

## WCAG AA Requirements

| Requirement | Standard | Tool |
|-------------|----------|------|
| Text contrast | 4.5:1 (normal), 3:1 (large) | `AccessibilityUtils.contrastRatio()` |
| Interactive elements | 44x44 pt minimum | Use `AppButton` (min 48px) |
| Screen reader support | Full navigation | `Semantics` widgets |
| Focus indicators | Visible | AppInput gold border |
| Error identification | Clear messages | `AccessibilityUtils.announceError()` |

---

## Quick Checklist for Code Review

- [ ] All buttons have semantic labels
- [ ] All inputs have labels and hints
- [ ] Currency formatted for screen readers
- [ ] Phone numbers formatted for screen readers
- [ ] Decorative elements excluded from semantics
- [ ] Loading states announce to screen readers
- [ ] Error states announce to screen readers
- [ ] Focus order is logical
- [ ] Contrast ratios validated
- [ ] No duplicate announcements

---

## File Locations

| File | Purpose |
|------|---------|
| `lib/utils/accessibility_utils.dart` | Core utilities |
| `lib/utils/accessibility_enhancements.dart` | Screen-specific helpers |
| `lib/features/wallet/views/wallet_home_accessibility_example.dart` | Example implementations |
| `ACCESSIBILITY_AUDIT.md` | Full audit report |
| `ACCESSIBILITY_TESTING_GUIDE.md` | Testing procedures |

---

**Last Updated:** 2024-01-29
**Version:** 1.0
