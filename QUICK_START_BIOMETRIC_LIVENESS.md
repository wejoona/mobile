# Quick Start: Biometric & Liveness Integration

## 5-Minute Integration Guide

### 1. Add Liveness Check to Any Feature

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/liveness/liveness_service.dart';
import '../features/liveness/widgets/liveness_check_widget.dart';

// Show liveness check dialog
Future<LivenessResult?> showLivenessCheck(
  BuildContext context,
  String purpose,
) async {
  return showDialog<LivenessResult>(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      child: LivenessCheckWidget(
        purpose: purpose, // 'kyc', 'recovery', 'withdrawal'
        onComplete: (result) => Navigator.pop(context, result),
        onCancel: () => Navigator.pop(context),
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
        },
      ),
    ),
  );
}

// Use it
final result = await showLivenessCheck(context, 'kyc');
if (result?.isLive == true) {
  print('Liveness verified: ${result!.sessionId}');
}
```

### 2. Add Biometric Security to Operations

```dart
import '../services/security/security_guard_service.dart';

class MyWidget extends ConsumerWidget {
  Future<void> performSensitiveOperation() async {
    final securityGuard = ref.read(securityGuardServiceProvider);

    try {
      // Option 1: Require biometric only
      await securityGuard.requireBiometric('Confirm sensitive action');

      // Option 2: Require liveness only
      final result = await securityGuard.requireLiveness('verification');

      // Option 3: Require both
      await securityGuard.requireBiometricAndLiveness('critical action');

      // Proceed with operation
      await doSensitiveOperation();

    } on BiometricAuthenticationFailedException catch (e) {
      showError('Biometric failed: $e');
    } on LivenessCheckFailedException catch (e) {
      showError('Liveness failed: $e');
    }
  }
}
```

### 3. Use Pre-Built Guards for Common Operations

```dart
final securityGuard = ref.read(securityGuardServiceProvider);

// External transfers (auto-tiered by amount)
await securityGuard.guardExternalTransfer(amount);
// < $100: no security
// $100-$500: biometric
// > $500: biometric + liveness

// PIN change
await securityGuard.guardPinChange();

// Add external recipient
await securityGuard.guardAddRecipient(isExternal: true);

// KYC selfie
await securityGuard.guardKycSelfie();

// Account recovery
await securityGuard.guardAccountRecovery();

// First withdrawal to new address
await securityGuard.guardFirstWithdrawal(
  recipientAddress: address,
  amount: amount,
);
```

### 4. Check Biometric Availability

```dart
final biometricService = ref.read(biometricServiceProvider);

// Check device support
final isSupported = await biometricService.isDeviceSupported();

// Check if user has it enabled
final isEnabled = await biometricService.isBiometricEnabled();

// Get biometric type (fingerprint, face, iris)
final type = await biometricService.getPrimaryBiometricType();

// Enable biometric
await biometricService.enableBiometric();

// Disable biometric
await biometricService.disableBiometric();
```

### 5. Provider Access

```dart
// All providers are available via Riverpod

// Biometric service
final biometricService = ref.read(biometricServiceProvider);

// Liveness service
final livenessService = ref.read(livenessServiceProvider);

// Security guard
final securityGuard = ref.read(securityGuardServiceProvider);

// Watch biometric availability
final biometricAvailable = ref.watch(biometricAvailableProvider);
biometricAvailable.when(
  data: (available) => Text(available ? 'Available' : 'Not available'),
  loading: () => CircularProgressIndicator(),
  error: (e, s) => Text('Error: $e'),
);

// Watch if biometric is enabled
final biometricEnabled = ref.watch(biometricEnabledProvider);
```

---

## Common Use Cases

### Use Case 1: High-Value Withdrawal

```dart
Future<void> processWithdrawal(double amount) async {
  final securityGuard = ref.read(securityGuardServiceProvider);

  try {
    // Automatically applies correct security level
    await securityGuard.guardExternalTransfer(amount);

    // If amount > $500, user already completed biometric + liveness
    // If amount $100-$500, user completed biometric
    // If amount < $100, no security check

    await _executeWithdrawal(amount);

  } on BiometricAuthenticationFailedException {
    showError('Please authenticate with biometric');
  } on LivenessCheckFailedException {
    showError('Liveness verification required');
  }
}
```

### Use Case 2: Account Recovery

```dart
Future<void> startAccountRecovery() async {
  final securityGuard = ref.read(securityGuardServiceProvider);

  try {
    // This triggers liveness check
    await securityGuard.guardAccountRecovery();

    // Show liveness check UI
    final result = await showLivenessCheck(context, 'recovery');

    if (result?.isLive == true) {
      // Send recovery request with liveness session ID
      await _sendRecoveryRequest(result!.sessionId);
    }

  } catch (e) {
    showError('Recovery failed: $e');
  }
}
```

### Use Case 3: Enable Biometric for User

```dart
Future<void> enableBiometricForUser() async {
  final biometricService = ref.read(biometricServiceProvider);

  // Check if device supports biometric
  final isSupported = await biometricService.isDeviceSupported();
  if (!isSupported) {
    showError('Biometric not supported on this device');
    return;
  }

  // Test biometric authentication
  final success = await biometricService.authenticate(
    reason: 'Verify your biometric',
  );

  if (success) {
    // Enable biometric for future use
    await biometricService.enableBiometric();
    showSuccess('Biometric enabled!');
  } else {
    showError('Biometric verification failed');
  }
}
```

### Use Case 4: Custom Liveness Flow

```dart
class CustomLivenessFlow extends ConsumerStatefulWidget {
  @override
  ConsumerState<CustomLivenessFlow> createState() => _CustomLivenessFlowState();
}

class _CustomLivenessFlowState extends ConsumerState<CustomLivenessFlow> {
  Future<void> _performCustomFlow() async {
    final livenessService = ref.read(livenessServiceProvider);

    // Step 1: Start session
    final session = await livenessService.startSession(
      purpose: 'custom',
    );

    print('Session started: ${session.sessionId}');
    print('Challenges: ${session.challenges.length}');

    // Step 2: Show liveness check widget
    final result = await showDialog<LivenessResult>(
      context: context,
      builder: (context) => Dialog(
        child: LivenessCheckWidget(
          purpose: 'custom',
          onComplete: (result) => Navigator.pop(context, result),
          onCancel: () => Navigator.pop(context),
        ),
      ),
    );

    // Step 3: Process result
    if (result?.isLive == true) {
      print('Liveness passed with confidence: ${result!.confidence}');
      await _processWithLiveness(result.sessionId);
    } else {
      print('Liveness failed: ${result?.failureReason}');
    }
  }

  Future<void> _processWithLiveness(String sessionId) async {
    // Send session ID to backend
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: _performCustomFlow,
          child: Text('Start Custom Liveness Flow'),
        ),
      ),
    );
  }
}
```

---

## Error Handling

```dart
// Comprehensive error handling example
Future<void> secureOperation() async {
  try {
    await securityGuard.guardExternalTransfer(1000);
    await performOperation();

  } on BiometricAuthenticationFailedException catch (e) {
    // User cancelled or biometric failed
    showSnackBar('Authentication required: $e');

  } on LivenessCheckFailedException catch (e) {
    // Liveness check failed or was cancelled
    showSnackBar('Identity verification required: $e');

  } on DioException catch (e) {
    // Network error
    showSnackBar('Network error: ${e.message}');

  } catch (e) {
    // Generic error
    showSnackBar('Operation failed: $e');
  }
}
```

---

## UI Components

### Biometric Button in Settings

```dart
ListTile(
  leading: Icon(Icons.fingerprint),
  title: Text('Biometric Authentication'),
  subtitle: Text(isEnabled ? 'Enabled' : 'Disabled'),
  trailing: Switch(
    value: isEnabled,
    onChanged: (value) async {
      if (value) {
        await enableBiometricForUser();
      } else {
        await biometricService.disableBiometric();
      }
    },
  ),
)
```

### Security Level Indicator

```dart
Widget buildSecurityIndicator(double amount) {
  if (amount >= SecurityGuardService.highValueTransferThreshold) {
    return Row(
      children: [
        Icon(Icons.security, color: Colors.red),
        Text('High Security: Biometric + Liveness'),
      ],
    );
  } else if (amount >= SecurityGuardService.externalTransferThreshold) {
    return Row(
      children: [
        Icon(Icons.fingerprint, color: Colors.orange),
        Text('Medium Security: Biometric'),
      ],
    );
  } else {
    return Row(
      children: [
        Icon(Icons.check, color: Colors.green),
        Text('Standard Security'),
      ],
    );
  }
}
```

---

## Testing

### Mock Providers for Testing

```dart
// Create mocks
class MockBiometricService extends Mock implements BiometricService {}
class MockLivenessService extends Mock implements LivenessService {}

// Override providers in tests
final container = ProviderContainer(
  overrides: [
    biometricServiceProvider.overrideWithValue(mockBiometric),
    livenessServiceProvider.overrideWithValue(mockLiveness),
  ],
);

// Test
when(() => mockBiometric.authenticate(reason: any(named: 'reason')))
    .thenAnswer((_) async => true);

final result = await container.read(securityGuardServiceProvider)
    .guardExternalTransfer(200);

expect(result, true);
```

---

## Debugging

### Enable Debug Logging

```dart
// In BiometricService
debugPrint('Biometric authentication started');
debugPrint('Biometric result: $success');

// In LivenessService
debugPrint('Liveness session started: $sessionId');
debugPrint('Challenge submitted: $challengeId');
debugPrint('Liveness result: isLive=$isLive, confidence=$confidence');
```

### Check Provider States

```dart
// In development mode
final biometricAvailable = ref.read(biometricAvailableProvider);
print('Biometric available: $biometricAvailable');

final biometricEnabled = ref.read(biometricEnabledProvider);
print('Biometric enabled: $biometricEnabled');
```

---

## Platform-Specific Configuration

### iOS (Info.plist)
```xml
<key>NSCameraUsageDescription</key>
<string>Camera access required for liveness verification</string>
<key>NSFaceIDUsageDescription</key>
<string>Face ID authentication for secure access</string>
```

### Android (AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
<uses-permission android:name="android.permission.USE_FINGERPRINT" />
```

---

## FAQ

**Q: Can users bypass biometric/liveness?**
A: No. If biometric is enabled, it's required for protected operations. Liveness is always required for KYC and high-value transfers.

**Q: What if device doesn't support biometric?**
A: App gracefully falls back to PIN/password. Check availability with `isDeviceSupported()`.

**Q: How long does liveness check take?**
A: Typically 6-8 seconds (3 challenges at 2 seconds each).

**Q: Can I customize security thresholds?**
A: Yes, modify constants in `SecurityGuardService`:
```dart
static const double externalTransferThreshold = 100.0;
static const double highValueTransferThreshold = 500.0;
```

**Q: How do I test on emulator?**
A: iOS Simulator supports Face ID simulation. Android emulator supports fingerprint simulation via adb.

---

## Next Steps

1. **Review Examples**: Check `/lib/features/liveness/liveness_usage_examples.dart`
2. **Read Full Documentation**: See `/BIOMETRIC_LIVENESS_IMPLEMENTATION.md`
3. **Test Integration**: Follow manual testing checklist in `/IMPLEMENTATION_SUMMARY.md`
4. **Backend Setup**: Implement liveness API endpoints (specs in full documentation)

---

## Support Files

- Full documentation: `/BIOMETRIC_LIVENESS_IMPLEMENTATION.md`
- Implementation summary: `/IMPLEMENTATION_SUMMARY.md`
- Usage examples: `/lib/features/liveness/liveness_usage_examples.dart`
- This guide: `/QUICK_START_BIOMETRIC_LIVENESS.md`
