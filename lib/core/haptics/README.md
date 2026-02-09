# Haptic Feedback System

Standardized haptic feedback patterns for consistent tactile responses across the JoonaPay app.

## Overview

The haptic system provides:
- **Consistent patterns** for common interactions (success, error, warning)
- **Financial context** feedback (payment start, confirmed, funds received)
- **User control** via settings toggle with persistent preferences
- **Platform-aware** feedback (iOS Taptic Engine, Android vibration)

## Quick Start

```dart
import '../../../core/haptics/index.dart';

// In a button callback
await hapticService.mediumTap();

// On successful payment
await hapticService.paymentConfirmed();

// On error
await hapticService.error();

// On toggle switch
await hapticService.toggle();
```

## Available Patterns

### Transaction Feedback

| Method | Use Case | Pattern |
|--------|----------|---------|
| `success()` | Transfer sent, payment completed, KYC approved | Medium + Light |
| `error()` | Failed transfer, invalid input, insufficient balance | Heavy + Medium + Heavy |
| `warning()` | Large amount warning, unusual activity | Medium + Medium |

### UI Interaction Feedback

| Method | Use Case | Pattern |
|--------|----------|---------|
| `selection()` | List item tap, option select, menu navigation | Selection click |
| `lightTap()` | Secondary buttons, navigation, tabs | Light impact |
| `mediumTap()` | Primary buttons, confirmations | Medium impact |
| `heavyTap()` | Destructive actions, critical buttons | Heavy impact |

### Contextual Feedback

| Method | Use Case | Pattern |
|--------|----------|---------|
| `toggle()` | Switch toggle, checkbox, feature flag | Light impact |
| `snap()` | Amount picker snap, date selector, carousel | Light impact |
| `longPress()` | Context menu trigger, quick actions | Heavy impact |
| `refresh()` | Pull-to-refresh trigger | Medium impact |

### Financial Context Feedback

| Method | Use Case | Pattern |
|--------|----------|---------|
| `paymentStart()` | Send money button press, bill payment start | Medium impact |
| `paymentConfirmed()` | PIN verified, transaction submitted | Same as success() |
| `fundsReceived()` | Incoming transfer notification | Light + Medium |
| `biometricPrompt()` | FaceID/TouchID prompt shown | Light impact |
| `pinDigit()` | Each PIN number tap | Selection click |
| `pinComplete()` | Final PIN digit entered | Light impact |

## Integration Examples

### Buttons (Already Integrated)

The `AppButton` component automatically provides haptic feedback based on variant:

```dart
AppButton(
  label: 'Send Money',
  variant: AppButtonVariant.primary,  // Medium tap
  onPressed: _handleSend,
  enableHaptics: true,  // Default
)

AppButton(
  label: 'Delete',
  variant: AppButtonVariant.danger,  // Heavy tap
  onPressed: _handleDelete,
)
```

### Toggles (Use AppToggle)

```dart
AppToggle(
  value: _isEnabled,
  onChanged: (value) => setState(() => _isEnabled = value),
  enableHaptics: true,  // Default
)

// Or use the tile variant with icon and labels
AppToggleTile(
  icon: Icons.notifications,
  title: 'Push Notifications',
  subtitle: 'Receive transaction alerts',
  value: _pushEnabled,
  onChanged: (value) => _updatePreference(value),
)
```

### Select/Dropdown (Already Integrated)

```dart
AppSelect<String>(
  items: [
    AppSelectItem(value: 'XOF', label: 'CFA Franc'),
    AppSelectItem(value: 'USD', label: 'US Dollar'),
  ],
  value: _currency,
  onChanged: (value) => setState(() => _currency = value),
  // Selection haptic fires automatically on item tap
)
```

### Refresh Indicator (Already Integrated)

```dart
AppRefreshIndicator(
  onRefresh: _loadTransactions,
  child: ListView(...),
  // Refresh haptics fire automatically
)
```

### Transaction Flows

```dart
class SendMoneyNotifier extends Notifier<SendMoneyState> {
  Future<bool> executeTransfer() async {
    // Validation error
    if (!isValid) {
      await hapticService.error();
      return false;
    }

    // Insufficient balance warning
    if (balance < amount) {
      await hapticService.warning();
      return false;
    }

    // Payment initiated
    await hapticService.paymentStart();

    try {
      final result = await transfersService.send(...);

      // Payment confirmed
      await hapticService.paymentConfirmed();
      return true;
    } catch (e) {
      // Transaction failed
      await hapticService.error();
      return false;
    }
  }
}
```

### PIN Entry (Already Integrated)

```dart
PinPad(
  onDigitPressed: (digit) {
    hapticService.pinDigit();  // Subtle feedback per digit
    _handleDigit(digit);
  },
  onComplete: (pin) {
    hapticService.pinComplete();  // Final digit feedback
    _verifyPin(pin);
  },
)
```

### Biometric Auth

```dart
final success = await biometricService.authenticate();
if (success) {
  await hapticService.success();
} else {
  await hapticService.error();
}
```

### List Item Selection

```dart
ListTile(
  title: Text('Recent Transaction'),
  onTap: () {
    hapticService.selection();
    _showTransactionDetail();
  },
)
```

### Long Press Actions

```dart
GestureDetector(
  onLongPress: () {
    hapticService.longPress();
    _showContextMenu();
  },
  child: TransactionCard(...),
)
```

## User Preferences

Users can disable haptics in Settings > Accessibility (or similar location).

### Implementing Settings Toggle

```dart
class SettingsView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hapticPrefs = ref.watch(hapticPreferencesProvider);

    return AppToggleTile(
      icon: Icons.vibration,
      title: 'Haptic Feedback',
      subtitle: 'Vibration for taps and notifications',
      value: hapticPrefs.isEnabled,
      onChanged: (value) {
        ref.read(hapticPreferencesProvider.notifier).toggle();
      },
    );
  }
}
```

### Checking Preference in Code

```dart
// The service automatically checks if haptics are enabled
// No need to check manually before calling
await hapticService.success();  // Only fires if enabled

// But you can check manually if needed
if (hapticService.isEnabled) {
  // Do something
}
```

## Best Practices

### Do's ✓

- **Use contextual patterns**: Match haptic intensity to action importance
- **Be consistent**: Same action = same haptic across the app
- **Respect user preference**: Haptics auto-disable when user opts out
- **Combine with visual/audio**: Haptics enhance, don't replace feedback
- **Use financial patterns**: Leverage specialized methods like `paymentConfirmed()`

### Don'ts ✗

- **Don't overuse**: Not every tap needs haptic feedback
- **Don't use random patterns**: Stick to defined methods
- **Don't call directly**: Use the service, not platform APIs
- **Don't mix intensities**: Light tap for primary button feels wrong
- **Don't assume always-on**: User may have disabled haptics

## Component Integration Checklist

When creating new interactive components:

- [ ] Import haptic service: `import '../../../core/haptics/haptic_service.dart';`
- [ ] Add `enableHaptics` parameter (default: `true`)
- [ ] Call appropriate haptic method in callback
- [ ] Check if already integrated (AppButton, AppToggle, AppSelect, etc.)

## Platform Differences

### iOS (Taptic Engine)
- `selectionClick()` - Subtle tick (selection)
- `lightImpact()` - Gentle tap
- `mediumImpact()` - Standard tap
- `heavyImpact()` - Strong tap

### Android (Vibration)
- Similar intensity levels via vibration motor
- Falls back to generic vibrate for unsupported patterns
- Custom patterns supported on Android only

## Performance Notes

- Haptic calls are non-blocking (async but don't await in UI callbacks)
- Negligible performance impact (<1ms overhead)
- Battery impact minimal (haptics are brief)
- Disabled haptics = zero overhead (early return)

## Troubleshooting

### Haptics not working?

1. **Check user preference**: Settings > Haptic Feedback toggle
2. **Check device settings**: System haptics may be disabled
3. **Simulator**: iOS Simulator doesn't support haptics (test on device)
4. **Android permissions**: No special permissions needed
5. **Verify calls**: Add `print()` to confirm method is called

### Testing Haptics

```dart
// Test all patterns
void _testHaptics() async {
  await hapticService.lightTap();
  await Future.delayed(Duration(milliseconds: 200));

  await hapticService.mediumTap();
  await Future.delayed(Duration(milliseconds: 200));

  await hapticService.heavyTap();
  await Future.delayed(Duration(milliseconds: 200));

  await hapticService.success();
  await Future.delayed(Duration(milliseconds: 500));

  await hapticService.error();
  await Future.delayed(Duration(milliseconds: 500));

  await hapticService.warning();
}
```

## Files

- `/lib/core/haptics/haptic_service.dart` - Core service with all patterns
- `/lib/core/haptics/haptic_preferences_provider.dart` - User preference state
- `/lib/core/haptics/haptic_service_example.dart` - Usage examples
- `/lib/core/haptics/index.dart` - Exports
- `/lib/design/components/primitives/app_toggle.dart` - Toggle with haptics

## Related Components

Components that already include haptic feedback:
- `AppButton` - Tap feedback by variant
- `AppToggle` - Toggle feedback
- `AppSelect` - Selection feedback
- `AppRefreshIndicator` - Refresh feedback
- `PinPad` - PIN entry feedback

## Future Enhancements

- [ ] Haptic intensity levels (light, medium, heavy) in settings
- [ ] Custom haptic patterns for branded feedback
- [ ] Haptic feedback for gesture navigation
- [ ] Accessibility: Sync with reduced motion preference
- [ ] Analytics: Track haptic usage patterns
