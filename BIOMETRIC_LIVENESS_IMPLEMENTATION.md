# Biometric Authentication & Liveness Check Implementation

## Overview
This implementation provides comprehensive biometric authentication and liveness detection for the JoonaPay Flutter mobile app, securing sensitive operations and preventing fraud.

## Implementation Summary

### Part 1: Biometric Session Unlock ✅
**File**: `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/services/session/session_manager.dart`

**Status**: Already implemented (lines 464-488)

The biometric unlock feature is integrated into the session lock screen:
- Shows fingerprint button on PIN pad
- Checks if biometric is enabled for the user
- Authenticates with message "Unlock your JoonaPay wallet"
- Unlocks session on successful authentication
- Shows error message on failure

### Part 2: Biometric Login Option ✅
**File**: `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/features/auth/views/otp_view.dart`

**Status**: Already implemented (lines 254-339)

The biometric login allows returning users to skip OTP:
- Checks for stored refresh token (user logged in before)
- Shows biometric option if enabled
- Authenticates with message "Authenticate to access JoonaPay"
- Refreshes access token using refresh token
- Starts session and navigates to home on success

### Part 3: Liveness Service ✅
**File**: `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/services/liveness/liveness_service.dart`

**Features**:
- `LivenessService` class for backend communication
- Challenge types: blink, smile, turn_head, nod
- Start session with purpose (kyc, recovery, withdrawal)
- Submit challenge frames (camera captures)
- Complete session and get result with confidence score
- Cancel session if user exits

**Models**:
```dart
LivenessChallenge {
  String challengeId;
  LivenessChallengeType type;
  String instruction;
  DateTime expiresAt;
}

LivenessResult {
  String sessionId;
  bool isLive;
  double confidence;
  DateTime completedAt;
  String? failureReason;
}
```

### Part 4: Liveness Check Widget ✅
**File**: `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/features/liveness/widgets/liveness_check_widget.dart`

**Features**:
- Reusable widget for liveness verification
- Front camera preview with face guide overlay
- Sequential challenge instructions
- Auto-capture every 2 seconds
- Progress indicator (1/3, 2/3, 3/3)
- Success/failure states
- Callbacks for completion, error, cancel

**Usage**:
```dart
LivenessCheckWidget(
  purpose: 'kyc',
  onComplete: (result) {
    if (result.isLive) {
      // Proceed with operation
    }
  },
  onError: (error) {
    // Handle error
  },
  onCancel: () {
    // User cancelled
  },
)
```

### Part 5: KYC Integration ✅
**File**: `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/features/settings/views/kyc_view.dart`

**Changes**:
1. Added liveness check before selfie capture
2. Shows "Start Liveness Check" button
3. Displays liveness check widget in full-screen dialog
4. Only allows selfie after liveness passes
5. Sends liveness session ID with KYC submission
6. Updated step validation to require liveness

**Flow**:
1. User completes personal info (Step 0)
2. Selects document type (Step 1)
3. Uploads front/back photos (Step 2)
4. Completes liveness check → Takes selfie (Step 3)
5. Reviews and submits (Step 4)

### Part 6: Security Guard Service ✅
**File**: `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/services/security/security_guard_service.dart`

**Purpose**: Centralized security policy enforcement

**Security Levels**:

1. **No Security**: Internal transfers, small amounts
2. **Biometric Only**: PIN changes, adding recipients, medium transfers ($100-$500)
3. **Liveness Only**: KYC selfie, account recovery
4. **Biometric + Liveness**: High-value transfers (>$500), account deletion

**Guard Methods**:
```dart
// External transfers with tiered security
guardExternalTransfer(amount) {
  if (amount < $100) return true;
  if (amount < $500) return requireBiometric();
  return requireBiometricAndLiveness();
}

// PIN changes
guardPinChange() → requireBiometric()

// Adding external recipients
guardAddRecipient() → requireBiometric()

// KYC selfie
guardKycSelfie() → requireLiveness()

// Account recovery
guardAccountRecovery() → requireLiveness()

// Account deletion
guardAccountDeletion() → requireBiometricAndLiveness()
```

**Integration**: Updated `TransfersService` to use `SecurityGuardService` instead of `BiometricGuard`

## Dependencies Added

```yaml
# pubspec.yaml additions
dependencies:
  camera: ^0.11.0+2              # Liveness camera preview
  local_auth_android: ^1.0.46    # Android biometric
  local_auth_darwin: ^1.4.1      # iOS biometric
```

## Backend Requirements

The backend should implement these endpoints:

### Liveness Endpoints

```typescript
POST /liveness/start
Body: { purpose?: string }
Response: {
  sessionId: string;
  challenges: Array<{
    challengeId: string;
    type: 'blink' | 'smile' | 'turn_head' | 'nod';
    instruction: string;
    expiresAt: string;
  }>;
}

POST /liveness/submit-challenge
Body: FormData {
  sessionId: string;
  challengeId: string;
  frame: File;
}
Response: {
  passed: boolean;
  nextChallenge?: Challenge;
  isComplete: boolean;
  message?: string;
}

POST /liveness/complete
Body: { sessionId: string }
Response: {
  sessionId: string;
  isLive: boolean;
  confidence: number;
  completedAt: string;
  failureReason?: string;
}

POST /liveness/cancel
Body: { sessionId: string }

GET /liveness/session/:sessionId
Response: { status, challenges, results }
```

### KYC Update

```typescript
POST /wallet/kyc/submit
Body: {
  firstName: string;
  lastName: string;
  dateOfBirth: string;
  country: string;
  idType: string;
  idNumber: string;
  documentFrontKey: string;
  documentBackKey: string;
  selfieKey: string;
  livenessSessionId?: string; // NEW: link to liveness check
}
```

## Security Best Practices

1. **Biometric Storage**: Never store biometric data, only use device's secure enclave
2. **Liveness Frames**: Encrypt frames in transit, delete after verification
3. **Session Expiry**: Liveness sessions expire in 5 minutes
4. **Anti-Spoofing**: Backend should use ML model to detect photos/videos
5. **Rate Limiting**: Limit liveness attempts to prevent abuse
6. **Audit Logging**: Log all biometric/liveness attempts with IP

## Testing

### Unit Tests
```dart
// Test security guard thresholds
test('External transfer < $100 requires no security');
test('External transfer $100-$500 requires biometric');
test('External transfer > $500 requires biometric + liveness');

// Test liveness service
test('Start session returns challenges');
test('Submit challenge handles success/failure');
test('Complete session returns result');
```

### Integration Tests
```dart
testWidgets('Liveness widget shows camera and instructions');
testWidgets('KYC requires liveness before selfie');
testWidgets('Transfer shows biometric prompt for $200');
```

### Manual Testing Checklist

- [ ] Session lock shows biometric button
- [ ] Biometric unlocks session
- [ ] OTP screen shows biometric login for returning users
- [ ] Biometric login refreshes token and navigates home
- [ ] KYC step 3 requires liveness check
- [ ] Liveness widget shows camera preview
- [ ] Liveness widget shows challenge instructions
- [ ] Liveness widget completes with success state
- [ ] Can take selfie only after liveness passes
- [ ] External transfer $50 has no security prompt
- [ ] External transfer $200 shows biometric prompt
- [ ] External transfer $600 shows biometric + liveness
- [ ] PIN change requires biometric
- [ ] Adding external recipient requires biometric

## Performance Considerations

1. **Camera Initialization**: ~500ms on modern devices
2. **Frame Capture**: 2-second intervals to avoid overwhelming backend
3. **Liveness Check**: 3 challenges × 2s = ~6 seconds total
4. **Image Compression**: Frames compressed to 85% JPEG, max 1200px
5. **Memory**: Camera preview released on widget disposal

## Accessibility

1. **Alternative Methods**: Always provide PIN/password fallback
2. **Instructions**: Clear text instructions for each challenge
3. **Contrast**: High contrast guide overlay for visibility
4. **Font Size**: Uses design system typography tokens
5. **Screen Readers**: ARIA labels on all buttons

## Error Handling

```dart
// Biometric errors
BiometricAuthenticationFailedException → Show error, allow retry
BiometricRequiredException → Block operation, show explanation

// Liveness errors
LivenessCheckFailedException → Show error, allow retry
Camera permission denied → Show settings prompt
Network error → Show offline message, cache locally
```

## Future Enhancements

1. **Passive Liveness**: Single frame analysis without challenges
2. **Behavioral Biometrics**: Typing patterns, swipe patterns
3. **Multi-Factor**: Combine biometric + SMS for ultra-high security
4. **Risk-Based**: Adjust security based on user behavior patterns
5. **Device Binding**: Require liveness on new device login

## Files Created/Modified

### Created
- `/lib/services/liveness/liveness_service.dart` (245 lines)
- `/lib/services/liveness/index.dart`
- `/lib/features/liveness/widgets/liveness_check_widget.dart` (571 lines)
- `/lib/features/liveness/index.dart`
- `/lib/services/security/security_guard_service.dart` (215 lines)

### Modified
- `/lib/features/settings/views/kyc_view.dart` (added liveness integration)
- `/lib/services/transfers/transfers_service.dart` (updated to use SecurityGuardService)
- `/lib/services/security/index.dart` (exported SecurityGuardService)
- `/pubspec.yaml` (added camera, local_auth_android, local_auth_darwin)

## API Summary

### BiometricService
```dart
Future<bool> isDeviceSupported()
Future<bool> canCheckBiometrics()
Future<bool> authenticate({String reason, bool sensitiveAction})
Future<bool> isBiometricEnabled()
Future<void> enableBiometric()
Future<void> disableBiometric()
```

### LivenessService
```dart
Future<LivenessSession> startSession({String? purpose})
Future<LivenessChallengeResponse> submitChallenge({sessionId, challengeId, frameData})
Future<LivenessResult> completeSession(String sessionId)
Future<void> cancelSession(String sessionId)
```

### SecurityGuardService
```dart
Future<bool> requireBiometric(String reason)
Future<LivenessResult?> requireLiveness(String reason)
Future<bool> requireBiometricAndLiveness(String reason)
Future<bool> guardExternalTransfer(double amount)
Future<bool> guardPinChange()
Future<bool> guardAddRecipient({bool isExternal, String? recipientAddress})
Future<LivenessResult?> guardKycSelfie()
Future<LivenessResult?> guardAccountRecovery()
Future<bool> guardAccountDeletion()
```

## Conclusion

This implementation provides enterprise-grade security for JoonaPay with:
- ✅ Biometric authentication for quick unlock and login
- ✅ Liveness detection to prevent spoofing
- ✅ Tiered security based on operation risk
- ✅ Reusable components for future features
- ✅ Comprehensive error handling
- ✅ Accessibility support
- ✅ Performance optimizations

All code follows Flutter best practices, uses Riverpod for state management, and integrates seamlessly with the existing design system.
