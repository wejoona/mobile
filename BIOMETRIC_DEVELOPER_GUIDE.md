# Biometric Authentication Developer Guide

## Quick Reference

This guide shows developers how to use and extend the biometric authentication system in JoonaPay.

---

## Basic Usage

### 1. Check if Biometric is Available

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/biometric/biometric_service.dart';

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final biometricAvailable = ref.watch(biometricAvailableProvider);
    
    return biometricAvailable.when(
      data: (isAvailable) {
        if (isAvailable) {
          return Text('Biometric available');
        }
        return Text('Biometric not available');
      },
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Error checking biometric'),
    );
  }
}
```

### 2. Check if User Enabled Biometric

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final biometricEnabled = ref.watch(biometricEnabledProvider);
    
    return biometricEnabled.when(
      data: (isEnabled) {
        if (isEnabled) {
          return Text('User has enabled biometric');
        }
        return Text('User has not enabled biometric');
      },
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Error'),
    );
  }
}
```

### 3. Simple Biometric Authentication

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/biometric/biometric_service.dart';

class MyController extends StateNotifier<MyState> {
  MyController(this._ref) : super(MyState.initial());
  
  final Ref _ref;
  
  Future<void> authenticateUser() async {
    final biometricService = _ref.read(biometricServiceProvider);
    
    // Check if enabled
    final isEnabled = await biometricService.isBiometricEnabled();
    if (!isEnabled) {
      // Handle: biometric not enabled
      return;
    }
    
    // Authenticate
    final success = await biometricService.authenticate(
      reason: 'Confirm your identity',
    );
    
    if (success) {
      // User authenticated successfully
      state = state.copyWith(isAuthenticated: true);
    } else {
      // Authentication failed
      state = state.copyWith(error: 'Authentication failed');
    }
  }
}
```

---

## Advanced Usage

### 4. Guard a Sensitive Operation

```dart
import '../services/biometric/biometric_service.dart';

class MySensitiveFeature extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppButton(
      label: 'Delete Account',
      onPressed: () async {
        try {
          // Use BiometricGuard to protect this operation
          final biometricGuard = ref.read(biometricGuardProvider);
          
          await biometricGuard.confirmSensitiveAction(
            reason: 'Confirm account deletion',
          );
          
          // If we get here, user confirmed with biometric
          await _performAccountDeletion();
          
        } on BiometricRequiredException catch (e) {
          // User failed or cancelled biometric
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message)),
          );
        }
      },
    );
  }
  
  Future<void> _performAccountDeletion() async {
    // Actual deletion logic
  }
}
```

### 5. Custom Biometric Guard

```dart
import '../services/biometric/biometric_service.dart';

class CustomBiometricGuard {
  final BiometricService _biometricService;
  
  CustomBiometricGuard(this._biometricService);
  
  /// Guard for account settings changes
  Future<bool> guardAccountSettings() async {
    final isEnabled = await _biometricService.isBiometricEnabled();
    if (!isEnabled) {
      return true; // Allow if not using biometric
    }
    
    final success = await _biometricService.authenticateSensitive(
      reason: 'Confirm account settings change',
    );
    
    if (!success) {
      throw BiometricRequiredException('Biometric confirmation required');
    }
    
    return true;
  }
  
  /// Guard for large withdrawals (custom threshold)
  Future<bool> guardLargeWithdrawal(double amount) async {
    const threshold = 500.0; // Custom threshold
    
    if (amount < threshold) {
      return true; // No biometric needed for small amounts
    }
    
    final isEnabled = await _biometricService.isBiometricEnabled();
    if (!isEnabled) {
      return true;
    }
    
    final success = await _biometricService.authenticateSensitive(
      reason: 'Confirm withdrawal of \$${amount.toStringAsFixed(2)}',
    );
    
    if (!success) {
      throw BiometricRequiredException('Biometric confirmation required');
    }
    
    return true;
  }
}
```

### 6. Enable/Disable Biometric in Settings

```dart
class BiometricSettingsView extends ConsumerStatefulWidget {
  @override
  ConsumerState<BiometricSettingsView> createState() => 
      _BiometricSettingsViewState();
}

class _BiometricSettingsViewState extends ConsumerState<BiometricSettingsView> {
  bool _isLoading = false;
  
  Future<void> _toggleBiometric(bool enable) async {
    setState(() => _isLoading = true);
    
    try {
      final biometricService = ref.read(biometricServiceProvider);
      
      if (enable) {
        // First authenticate to verify user can use biometric
        final canAuthenticate = await biometricService.authenticate(
          reason: 'Enable biometric login',
        );
        
        if (!canAuthenticate) {
          _showError('Failed to authenticate with biometric');
          return;
        }
        
        // Enable biometric
        await biometricService.enableBiometric();
        _showSuccess('Biometric enabled');
        
      } else {
        // Disable biometric
        await biometricService.disableBiometric();
        _showSuccess('Biometric disabled');
      }
      
      // Refresh the provider
      ref.invalidate(biometricEnabledProvider);
      
    } catch (e) {
      _showError('Failed to update biometric setting');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: context.colors.success,
      ),
    );
  }
  
  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: context.colors.error,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final biometricEnabled = ref.watch(biometricEnabledProvider);
    final biometricAvailable = ref.watch(biometricAvailableProvider);
    final biometricType = ref.watch(primaryBiometricTypeProvider);
    
    return Scaffold(
      appBar: AppBar(title: Text('Biometric Settings')),
      body: biometricAvailable.when(
        data: (isAvailable) {
          if (!isAvailable) {
            return Center(
              child: Text('Biometric not available on this device'),
            );
          }
          
          return biometricEnabled.when(
            data: (isEnabled) => Column(
              children: [
                biometricType.when(
                  data: (type) => _buildBiometricInfo(type),
                  loading: () => SizedBox(),
                  error: (_, __) => SizedBox(),
                ),
                SwitchListTile(
                  title: Text('Enable Biometric Login'),
                  subtitle: Text('Use biometric to unlock and confirm actions'),
                  value: isEnabled,
                  onChanged: _isLoading ? null : _toggleBiometric,
                ),
              ],
            ),
            loading: () => Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error loading settings')),
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error checking biometric')),
      ),
    );
  }
  
  Widget _buildBiometricInfo(BiometricType type) {
    String label;
    IconData icon;
    
    switch (type) {
      case BiometricType.faceId:
        label = 'Face ID';
        icon = Icons.face;
        break;
      case BiometricType.fingerprint:
        label = 'Fingerprint';
        icon = Icons.fingerprint;
        break;
      case BiometricType.iris:
        label = 'Iris Scanner';
        icon = Icons.remove_red_eye;
        break;
      default:
        return SizedBox();
    }
    
    return ListTile(
      leading: Icon(icon),
      title: Text('Available: $label'),
    );
  }
}
```

---

## Testing

### 7. Mock Biometric for Testing

```dart
// test/mocks/mock_biometric_service.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import '../../lib/services/biometric/biometric_service.dart';

class MockBiometricService extends Mock implements BiometricService {}

void main() {
  group('Biometric Tests', () {
    late MockBiometricService mockBiometricService;
    
    setUp(() {
      mockBiometricService = MockBiometricService();
    });
    
    test('authenticate returns true when biometric succeeds', () async {
      // Arrange
      when(mockBiometricService.authenticate(reason: anyNamed('reason')))
          .thenAnswer((_) async => true);
      
      // Act
      final result = await mockBiometricService.authenticate(
        reason: 'Test authentication',
      );
      
      // Assert
      expect(result, true);
      verify(mockBiometricService.authenticate(
        reason: 'Test authentication',
      )).called(1);
    });
    
    test('authenticate returns false when biometric fails', () async {
      // Arrange
      when(mockBiometricService.authenticate(reason: anyNamed('reason')))
          .thenAnswer((_) async => false);
      
      // Act
      final result = await mockBiometricService.authenticate(
        reason: 'Test authentication',
      );
      
      // Assert
      expect(result, false);
    });
    
    test('isBiometricEnabled returns user preference', () async {
      // Arrange
      when(mockBiometricService.isBiometricEnabled())
          .thenAnswer((_) async => true);
      
      // Act
      final result = await mockBiometricService.isBiometricEnabled();
      
      // Assert
      expect(result, true);
    });
  });
}
```

---

## Common Patterns

### 8. Conditional Biometric in UI

```dart
class MyFeature extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final biometricAvailable = ref.watch(biometricAvailableProvider);
    final biometricEnabled = ref.watch(biometricEnabledProvider);
    
    return Column(
      children: [
        // Show biometric option only if available
        if (biometricAvailable.value == true)
          biometricEnabled.when(
            data: (isEnabled) => ListTile(
              leading: Icon(Icons.fingerprint),
              title: Text('Quick unlock'),
              trailing: Switch(
                value: isEnabled,
                onChanged: (value) => _toggleBiometric(ref, value),
              ),
            ),
            loading: () => SizedBox(),
            error: (_, __) => SizedBox(),
          ),
        
        // Other options
        ListTile(
          title: Text('PIN unlock'),
          trailing: Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}
```

### 9. Biometric with Fallback

```dart
Future<bool> authenticateWithFallback(WidgetRef ref) async {
  final biometricService = ref.read(biometricServiceProvider);
  
  // Try biometric first
  final isEnabled = await biometricService.isBiometricEnabled();
  if (isEnabled) {
    final biometricSuccess = await biometricService.authenticate(
      reason: 'Confirm your identity',
    );
    
    if (biometricSuccess) {
      return true;
    }
  }
  
  // Fallback to PIN
  final pinResult = await showPinDialog();
  return pinResult.success;
}
```

### 10. Error Handling

```dart
Future<void> performSensitiveAction(WidgetRef ref) async {
  try {
    final biometricGuard = ref.read(biometricGuardProvider);
    
    await biometricGuard.confirmSensitiveAction(
      reason: 'Confirm this action',
    );
    
    // Action confirmed
    await _doSensitiveAction();
    
  } on BiometricRequiredException catch (e) {
    // User failed biometric or cancelled
    _showError('Authentication required: ${e.message}');
    
  } on PlatformException catch (e) {
    // Platform-specific error
    if (e.code == 'NotAvailable') {
      _showError('Biometric not available');
    } else if (e.code == 'NotEnrolled') {
      _showError('No biometric enrolled. Please set up in Settings.');
    } else {
      _showError('Biometric authentication failed');
    }
    
  } catch (e) {
    // Generic error
    _showError('An error occurred');
  }
}
```

---

## Best Practices

### Do's

1. **Always check if biometric is enabled** before trying to authenticate
   ```dart
   final isEnabled = await biometricService.isBiometricEnabled();
   if (!isEnabled) {
     // Handle appropriately
   }
   ```

2. **Provide clear reasons** for biometric prompts
   ```dart
   await biometricService.authenticate(
     reason: 'Confirm transfer of $250.00 to John Doe',
   );
   ```

3. **Handle errors gracefully** with user-friendly messages
   ```dart
   try {
     await authenticate();
   } catch (e) {
     showUserFriendlyError(e);
   }
   ```

4. **Use `authenticateSensitive()` for critical operations**
   ```dart
   await biometricService.authenticateSensitive(
     reason: 'Confirm account deletion',
   );
   ```

5. **Respect user choice** - allow operations without biometric if disabled
   ```dart
   if (!isEnabled) {
     return true; // User chose not to use biometric
   }
   ```

### Don'ts

1. **Don't block users** if biometric fails - provide fallback options
   
2. **Don't require biometric** for low-security operations
   
3. **Don't spam users** with repeated biometric requests
   
4. **Don't store sensitive data** without additional encryption
   
5. **Don't assume biometric is available** - always check first

---

## Extending the System

### Add a New Protected Operation

```dart
// 1. Add to BiometricGuard class
class BiometricGuard {
  // ... existing code ...
  
  /// Guard for export private keys
  Future<bool> guardExportPrivateKey() async {
    return confirmSensitiveAction(
      reason: 'Confirm export of private key',
    );
  }
}

// 2. Use in your feature
class ExportKeyFeature extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppButton(
      label: 'Export Private Key',
      onPressed: () async {
        try {
          final biometricGuard = ref.read(biometricGuardProvider);
          await biometricGuard.guardExportPrivateKey();
          
          // Proceed with export
          await _exportPrivateKey();
          
        } on BiometricRequiredException catch (e) {
          _showError(e.message);
        }
      },
    );
  }
}
```

### Custom Threshold Logic

```dart
class BiometricGuard {
  /// Check if biometric required based on custom rules
  bool requiresConfirmation({
    required String operationType,
    double? amount,
    Map<String, dynamic>? metadata,
  }) {
    // Custom business logic
    switch (operationType) {
      case 'transfer':
        return amount != null && amount >= 100.0;
      
      case 'settings_change':
        return metadata?['critical'] == true;
      
      case 'export_data':
        return true; // Always require
      
      default:
        return false;
    }
  }
}
```

---

## Troubleshooting

### Issue: Biometric not working on Android

**Solution:** Check if user has enrolled biometric in device settings

```dart
final canCheck = await biometricService.canCheckBiometrics();
if (!canCheck) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Biometric Not Set Up'),
      content: Text('Please enroll your fingerprint/face in device settings'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK'),
        ),
      ],
    ),
  );
}
```

### Issue: Biometric prompt not showing

**Solution:** Ensure proper permissions in AndroidManifest.xml

```xml
<uses-permission android:name="android.permission.USE_BIOMETRIC"/>
```

And in Info.plist for iOS:

```xml
<key>NSFaceIDUsageDescription</key>
<string>We use Face ID to secure your account</string>
```

### Issue: Authentication fails silently

**Solution:** Check platform exception codes

```dart
try {
  await biometricService.authenticate(reason: 'Login');
} on PlatformException catch (e) {
  debugPrint('Biometric error code: ${e.code}');
  debugPrint('Biometric error message: ${e.message}');
}
```

---

## Additional Resources

### Related Files

- Biometric Service: `/lib/services/biometric/biometric_service.dart`
- Session Manager: `/lib/services/session/session_manager.dart`
- PIN Service: `/lib/services/pin/pin_service.dart`
- Change PIN View: `/lib/features/settings/views/change_pin_view.dart`

### Flutter Packages Used

- `local_auth: ^2.1.0` - Platform biometric authentication
- `flutter_secure_storage: ^9.0.0` - Secure storage for biometric preferences

### Documentation

- [Flutter Local Auth Plugin](https://pub.dev/packages/local_auth)
- [iOS Face ID/Touch ID](https://developer.apple.com/documentation/localauthentication)
- [Android BiometricPrompt](https://developer.android.com/training/sign-in/biometric-auth)

---

## Summary

The JoonaPay biometric system provides:

- ✅ Simple API for authentication
- ✅ Built-in guards for sensitive operations
- ✅ Graceful degradation when biometric disabled
- ✅ Support for multiple biometric types
- ✅ Clear error handling
- ✅ Easy to extend for custom operations

For questions or issues, refer to the implementation files or create an issue in the project repository.
