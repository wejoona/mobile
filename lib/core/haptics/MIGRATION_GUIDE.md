# Haptic Feedback Migration Guide

Guide for updating existing components to use the standardized haptic system.

## Quick Reference: What to Update

### ✅ Already Integrated (No Action Needed)
- `AppButton` - All variants have haptics
- `PinPad` - PIN entry and biometric prompts
- `AppSelect` - Selection feedback
- `AppRefreshIndicator` - Refresh feedback
- `AppToggle` - New component with haptics

### 🔄 Need Updates
- Custom buttons using raw `GestureDetector` or `InkWell`
- Direct `Switch` widgets → Replace with `AppToggle`
- Transaction success/error flows
- Form validation errors
- List item selections
- Custom toggles/checkboxes

## Migration Steps

### 1. Replace Direct Switch Usage

**Before:**
```dart
Switch(
  value: _isEnabled,
  onChanged: (value) => setState(() => _isEnabled = value),
  activeColor: AppColors.gold500,
)
```

**After:**
```dart
import '../../../core/haptics/index.dart';

AppToggle(
  value: _isEnabled,
  onChanged: (value) => setState(() => _isEnabled = value),
)
```

**Or use the tile variant:**
```dart
AppToggleTile(
  icon: Icons.notifications,
  title: 'Push Notifications',
  subtitle: 'Get alerts for transactions',
  value: _isEnabled,
  onChanged: (value) => setState(() => _isEnabled = value),
)
```

### 2. Add Haptics to Transaction Flows

**Before:**
```dart
Future<bool> sendMoney() async {
  if (amount > balance) {
    setState(() => error = 'Insufficient balance');
    return false;
  }

  try {
    await transferService.send(amount);
    setState(() => success = true);
    return true;
  } catch (e) {
    setState(() => error = e.toString());
    return false;
  }
}
```

**After:**
```dart
import '../../../core/haptics/index.dart';

Future<bool> sendMoney() async {
  if (amount > balance) {
    await hapticService.warning();
    setState(() => error = 'Insufficient balance');
    return false;
  }

  await hapticService.paymentStart();

  try {
    await transferService.send(amount);
    await hapticService.paymentConfirmed();
    setState(() => success = true);
    return true;
  } catch (e) {
    await hapticService.error();
    setState(() => error = e.toString());
    return false;
  }
}
```

### 3. Add Haptics to Custom Buttons

**Before:**
```dart
GestureDetector(
  onTap: _handleAction,
  child: Container(
    decoration: BoxDecoration(
      color: AppColors.gold500,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text('Action'),
  ),
)
```

**After:**
```dart
import '../../../core/haptics/index.dart';

GestureDetector(
  onTap: () {
    hapticService.mediumTap();
    _handleAction();
  },
  child: Container(
    decoration: BoxDecoration(
      color: AppColors.gold500,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text('Action'),
  ),
)
```

**Or better, use AppButton:**
```dart
AppButton(
  label: 'Action',
  onPressed: _handleAction,
  // Haptics included automatically
)
```

### 4. Add Haptics to List Item Taps

**Before:**
```dart
ListTile(
  title: Text('Transaction #123'),
  onTap: () => _showDetail(transaction),
)
```

**After:**
```dart
import '../../../core/haptics/index.dart';

ListTile(
  title: Text('Transaction #123'),
  onTap: () {
    hapticService.selection();
    _showDetail(transaction);
  },
)
```

### 5. Add Haptics to Form Validation

**Before:**
```dart
void _validateForm() {
  if (_formKey.currentState!.validate()) {
    _submitForm();
  } else {
    // Validation failed
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please fix errors')),
    );
  }
}
```

**After:**
```dart
import '../../../core/haptics/index.dart';

void _validateForm() {
  if (_formKey.currentState!.validate()) {
    _submitForm();
  } else {
    hapticService.error();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please fix errors')),
    );
  }
}
```

### 6. Add Haptics to Pull-to-Refresh

**Before:**
```dart
RefreshIndicator(
  onRefresh: _loadData,
  child: ListView(...),
)
```

**After:**
```dart
AppRefreshIndicator(
  onRefresh: _loadData,
  child: ListView(...),
  // Haptics included automatically
)
```

### 7. Add Haptics to Biometric Auth

**Before:**
```dart
final authenticated = await biometricService.authenticate();
if (authenticated) {
  _proceedToApp();
} else {
  _showError();
}
```

**After:**
```dart
import '../../../core/haptics/index.dart';

final authenticated = await biometricService.authenticate();
if (authenticated) {
  await hapticService.success();
  _proceedToApp();
} else {
  await hapticService.error();
  _showError();
}
```

### 8. Add Haptics to Long Press

**Before:**
```dart
GestureDetector(
  onLongPress: () => _showContextMenu(),
  child: TransactionCard(...),
)
```

**After:**
```dart
import '../../../core/haptics/index.dart';

GestureDetector(
  onLongPress: () {
    hapticService.longPress();
    _showContextMenu();
  },
  child: TransactionCard(...),
)
```

## Pattern Selection Guide

Choose the appropriate haptic pattern for your interaction:

| Interaction Type | Pattern | Method |
|-----------------|---------|--------|
| Primary action button | Medium | `mediumTap()` |
| Secondary/ghost button | Light | `lightTap()` |
| Destructive action | Heavy | `heavyTap()` |
| List item selection | Selection | `selection()` |
| Toggle switch | Toggle | `toggle()` (auto in AppToggle) |
| Dropdown selection | Selection | `selection()` (auto in AppSelect) |
| Payment initiated | Payment | `paymentStart()` |
| Payment success | Success | `paymentConfirmed()` |
| Transaction success | Success | `success()` |
| Error/failure | Error | `error()` |
| Warning (e.g., low balance) | Warning | `warning()` |
| Incoming funds | Funds | `fundsReceived()` |
| PIN digit entered | PIN | `pinDigit()` |
| PIN complete | PIN Complete | `pinComplete()` |
| Biometric prompt | Biometric | `biometricPrompt()` |
| Long press | Long Press | `longPress()` |
| Pull to refresh | Refresh | `refresh()` (auto in AppRefreshIndicator) |
| Carousel snap | Snap | `snap()` |

## Testing Your Changes

### Manual Testing Checklist

- [ ] Test on physical device (haptics don't work in simulator)
- [ ] Test with haptics enabled in app settings
- [ ] Test with haptics disabled in app settings
- [ ] Verify haptic fires at correct time (not delayed)
- [ ] Verify correct pattern (matches action importance)
- [ ] Check no double-firing (e.g., button + selection)

### Common Issues

**Issue:** Haptics don't fire
- Check: User preference enabled
- Check: Testing on device (not simulator)
- Check: Import statement present
- Check: Method actually called (add debug print)

**Issue:** Haptics fire twice
- Check: Nested components both calling haptics
- Fix: Remove haptic from inner component

**Issue:** Wrong haptic pattern
- Check: Using correct method (e.g., `mediumTap()` for primary action)
- Fix: Refer to pattern selection guide above

## File-by-File Migration Priority

### High Priority (User-facing interactions)
1. ✅ `lib/features/settings/views/security_view.dart` - **DONE**
2. ✅ `lib/features/settings/views/notification_settings_view.dart` - **DONE**
3. ✅ `lib/features/send/providers/send_provider.dart` - **DONE**
4. `lib/features/auth/providers/login_provider.dart` - Add error/success haptics
5. `lib/features/wallet/views/*.dart` - Transaction interactions

### Medium Priority (Settings and preferences)
6. Any remaining settings screens with toggles
7. Profile edit screens
8. Preference management

### Low Priority (Nice to have)
9. Help/FAQ interactions
10. List scrolling/filtering
11. Tutorial interactions

## Example: Complete Migration of a Screen

**Before (security_view.dart toggle):**
```dart
Widget _buildToggleOption(...) {
  return Row(
    children: [
      Icon(icon, color: AppColors.gold500),
      Expanded(child: Text(title)),
      Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.gold500,
      ),
    ],
  );
}
```

**After:**
```dart
import '../../../core/haptics/index.dart';

Widget _buildToggleOption(...) {
  return AppToggleTile(
    icon: icon,
    title: title,
    subtitle: subtitle,
    value: value,
    onChanged: onChanged,
    // Haptics included automatically
  );
}
```

## Rollout Strategy

1. **Phase 1: Core Components** ✅ DONE
   - AppButton
   - AppToggle
   - AppSelect
   - AppRefreshIndicator

2. **Phase 2: Critical Flows** ✅ DONE
   - Payment/transfer success
   - Payment/transfer errors
   - Settings toggles

3. **Phase 3: Secondary Interactions** (Next)
   - List selections
   - Form validations
   - Auth flows

4. **Phase 4: Polish** (Future)
   - Long press menus
   - Carousel snaps
   - Custom gestures

## Questions?

- **Q: Do I need to check if haptics are enabled before calling?**
  - A: No, the service checks automatically and returns early if disabled.

- **Q: Should I await haptic calls?**
  - A: Optional. Await if you want to ensure it completes before proceeding, otherwise fire-and-forget is fine.

- **Q: What if a component already has haptics (like AppButton)?**
  - A: Don't add duplicate haptics. Use the component as-is.

- **Q: Can I create custom haptic patterns?**
  - A: Use existing patterns for consistency. If truly needed, propose addition to haptic service.

- **Q: How do I test on iOS Simulator?**
  - A: You can't. Haptics require physical device.
