# Flutter PIN Service

Secure PIN management for Flutter applications with PBKDF2 hashing, brute-force protection, and weak PIN detection.

## Features

- **Secure Hashing** - PBKDF2-HMAC-SHA256 with 100,000 iterations
- **Brute-Force Protection** - Configurable lockout after failed attempts
- **Weak PIN Detection** - Rejects common patterns (1234, 0000, etc.)
- **Secure Storage** - Uses flutter_secure_storage for encrypted storage
- **PIN Tokens** - Store and manage verification tokens for sensitive operations

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_pin_service:
    path: packages/flutter_pin_service
```

Or if published:

```yaml
dependencies:
  flutter_pin_service: ^1.0.0
```

## Quick Start

```dart
import 'package:flutter_pin_service/flutter_pin_service.dart';

final pinService = PinService();

// Set a PIN
final setResult = await pinService.setPin('1234');
if (setResult.success) {
  print('PIN set successfully');
} else {
  print('Error: ${setResult.message}');
}

// Verify PIN
final result = await pinService.verifyPin('1234');
if (result.success) {
  print('PIN verified!');
} else if (result.isLocked) {
  print('Locked for ${result.lockRemainingSeconds} seconds');
} else {
  print('Wrong PIN. ${result.remainingAttempts} attempts remaining');
}
```

## Usage

### Setting a PIN

```dart
final pinService = PinService();

// Set a new PIN
final result = await pinService.setPin('5678');

if (result.success) {
  // PIN stored securely
} else {
  // Handle error
  switch (result.error) {
    case SetPinError.validationFailed:
      print('Invalid PIN: ${result.message}');
      break;
    case SetPinError.storageError:
      print('Storage error: ${result.message}');
      break;
  }
}
```

### Verifying a PIN

```dart
final result = await pinService.verifyPin(userInput);

if (result.success) {
  // Proceed with action
  navigateToHome();
} else if (result.isLocked) {
  // Show lockout message
  showLockoutDialog(result.lockRemainingSeconds!);
} else {
  // Show error with remaining attempts
  showError(result.message!);
}
```

### Changing a PIN

```dart
final result = await pinService.changePin(
  currentPin,
  newPin,
);

if (result.success) {
  showSuccess('PIN changed successfully');
} else {
  switch (result.error) {
    case ChangePinError.currentPinWrong:
      showError('Current PIN is incorrect');
      break;
    case ChangePinError.newPinInvalid:
      showError('New PIN is invalid: ${result.message}');
      break;
  }
}
```

### PIN Tokens for Sensitive Operations

```dart
// After successful PIN verification on backend
final response = await api.verifyPin(pinService.getTransmissionHash(pin));

// Store the token
await pinService.storePinToken(
  response.token,
  expiresIn: Duration(minutes: 5),
);

// Later, check if token is still valid
if (await pinService.hasValidPinToken()) {
  final token = await pinService.getPinToken();
  await api.transfer(amount, recipientId, pinToken: token);
}

// Clear token after use
await pinService.clearPinToken();
```

### Backend Integration

```dart
// Get hashed PIN for transmission
final hashedPin = pinService.getTransmissionHash(pin);

// Send to backend
final response = await api.post('/verify-pin', {
  'pin': hashedPin,
});
```

## Configuration

### Basic Settings

```dart
// Set PIN length (default: 4)
PinConfig.pinLength = 6;

// Set max attempts before lockout (default: 5)
PinConfig.maxAttempts = 3;

// Set lockout duration (default: 15 minutes)
PinConfig.lockoutDuration = Duration(minutes: 30);
```

### Security Settings

```dart
// PBKDF2 iterations for local hashing (default: 100,000)
// Higher = more secure but slower
PinConfig.pbkdf2Iterations = 200000;

// PBKDF2 iterations for transmission (default: 10,000)
// Lower since backend will re-hash
PinConfig.pbkdf2TransmissionIterations = 10000;

// IMPORTANT: Change the transmission salt for your app!
PinConfig.transmissionSalt = 'your_unique_app_salt_v1';
```

### Weak PIN Settings

```dart
// Reject weak PINs (default: true)
PinConfig.rejectWeakPins = true;

// Add custom weak PINs to reject
PinConfig.customWeakPins = ['4444', '1379'];
```

## PIN Validation

### Validate Before Setting

```dart
final validation = PinValidator.validate(userInput);

if (!validation.isValid) {
  showError(validation.message!);
  return;
}

// PIN is valid, proceed to set
await pinService.setPin(userInput);
```

### Check PIN Strength

```dart
final score = PinValidator.getStrengthScore(pin);
final label = PinValidator.getStrengthLabel(pin);

print('Strength: $label ($score/100)');
// Output: "Strength: Strong (85/100)"
```

### Weak PIN Detection

The validator rejects:
- Repeated digits: 0000, 1111, 2222
- Sequential patterns: 1234, 4321, 9876
- Common PINs: 1234, 0000, 1111
- Year patterns: 1990-2025
- Repeated pairs: 1212, 2323

## Security Best Practices

### 1. Change the Transmission Salt

```dart
// CRITICAL: Use a unique salt for your app
PinConfig.transmissionSalt = 'myapp_client_pin_hash_v1';
```

### 2. Backend Re-Hashing

The backend should always re-hash the received PIN with its own salt:

```python
# Backend (Python example)
import hashlib
import os

def store_pin(user_id: str, client_hashed_pin: str):
    # Generate server-side salt
    salt = os.urandom(32)

    # Re-hash with PBKDF2
    final_hash = hashlib.pbkdf2_hmac(
        'sha256',
        client_hashed_pin.encode(),
        salt,
        100000,  # High iteration count
        dklen=32
    )

    # Store both salt and hash
    db.store(user_id, salt, final_hash)
```

### 3. Secure the Lockout

```dart
// Consider longer lockouts for financial apps
PinConfig.maxAttempts = 3;
PinConfig.lockoutDuration = Duration(minutes: 30);

// Or exponential backoff
// 1st lockout: 1 min, 2nd: 5 min, 3rd: 30 min, etc.
```

### 4. Clear on Logout

```dart
Future<void> logout() async {
  await pinService.clearPin();  // Removes all PIN data
  await authService.logout();
}
```

### 5. Verify Before Sensitive Actions

```dart
Future<void> transferMoney(double amount) async {
  // Always verify PIN before transfers
  final result = await pinService.verifyPin(enteredPin);
  if (!result.success) {
    throw PinVerificationException(result.message);
  }

  // PIN verified, proceed with transfer
  await api.transfer(amount);
}
```

## API Reference

### PinService

| Method | Description |
|--------|-------------|
| `hasPin()` | Check if PIN is set |
| `setPin(pin)` | Set a new PIN |
| `verifyPin(pin)` | Verify entered PIN |
| `changePin(current, new)` | Change PIN |
| `clearPin()` | Remove all PIN data |
| `getRemainingAttempts()` | Get attempts before lockout |
| `isLocked()` | Check if locked |
| `getLockRemainingSeconds()` | Get lockout time remaining |
| `getTransmissionHash(pin)` | Get hash for backend |
| `storePinToken(token)` | Store verification token |
| `getPinToken()` | Get stored token |
| `hasValidPinToken()` | Check if token is valid |
| `clearPinToken()` | Remove token |

### PinValidator

| Method | Description |
|--------|-------------|
| `validate(pin)` | Validate PIN format and strength |
| `getStrengthScore(pin)` | Get strength score (0-100) |
| `getStrengthLabel(pin)` | Get strength label |

### PinHasher

| Method | Description |
|--------|-------------|
| `hashPin(pin, salt)` | Hash PIN with salt |
| `hashPinForTransmission(pin)` | Hash for backend |
| `generateSalt()` | Generate random salt |
| `verifyPin(pin, hash, salt)` | Verify PIN against hash |

## Testing

```dart
void main() {
  group('PinService', () {
    late PinService pinService;

    setUp(() {
      pinService = PinService();
    });

    test('should set and verify PIN', () async {
      await pinService.setPin('1234');

      final result = await pinService.verifyPin('1234');
      expect(result.success, true);
    });

    test('should lock after max attempts', () async {
      PinConfig.maxAttempts = 3;
      await pinService.setPin('1234');

      for (var i = 0; i < 3; i++) {
        await pinService.verifyPin('0000');
      }

      final result = await pinService.verifyPin('1234');
      expect(result.isLocked, true);
    });

    test('should reject weak PINs', () async {
      final result = await pinService.setPin('0000');
      expect(result.success, false);
      expect(result.error, SetPinError.validationFailed);
    });
  });
}
```

## License

MIT License - see LICENSE file for details.
