# Login Flow Implementation

## Overview
Complete login flow for existing/returning users in JoonaPay USDC Wallet mobile app.

## Implemented Files

### Models
**`/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/features/auth/models/login_state.dart`**
- `LoginState` - Manages login flow state
- `LoginStep` enum - phone → otp → pin → biometric → success
- `LoginRequest` - Phone number + country code
- Features: Remember device, PIN attempts tracking, lockout state

### Providers
**`/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/features/auth/providers/login_provider.dart`**
- `LoginNotifier` - State machine for login flow
- Features:
  - Load/save remembered phone number
  - OTP resend with 60s countdown
  - PIN verification with 3-attempt limit
  - 15-minute lockout after failed attempts
  - Biometric authentication support
  - Session management integration

### Views
**`/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/features/auth/views/login_phone_view.dart`**
- Phone number input screen
- Country code selector (+225, +221, +223, +226, +234)
- "Remember this device" checkbox
- Pre-fills remembered phone number
- "Create account" link to onboarding

**`/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/features/auth/views/login_otp_view.dart`**
- 6-digit OTP input with individual boxes
- Auto-advance to next box
- Resend code with countdown timer
- Auto-submit on complete
- Error handling with visual feedback

**`/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/features/auth/views/login_pin_view.dart`**
- 6-digit PIN entry using existing `PinPad` widget
- Biometric prompt (auto-show if enabled)
- "Forgot PIN?" link
- Attempts counter (X attempts remaining)
- Lockout screen after 3 failed attempts
- Reuses `PinDots` widget for visual feedback

## Routes
Updated `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/router/app_router.dart`:

```dart
// Login routes
GoRoute(path: '/login', ...) → LoginPhoneView
GoRoute(path: '/login/otp', ...) → LoginOtpView
GoRoute(path: '/login/pin', ...) → LoginPinView
```

- All routes added to public routes list for redirect logic
- Added imports for new views

## Localization
Added to `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/l10n/app_en.arb`:
- `auth_phoneInvalid` - Invalid phone error
- `login_welcomeBack` - Welcome message
- `login_enterPhone` - Subtitle
- `login_rememberPhone` - Remember checkbox
- `login_noAccount` / `login_createAccount` - Account prompts
- `login_verifyCode` - OTP title
- `login_codeSentTo` - OTP subtitle (with placeholders)
- `login_resendCode` / `login_resendIn` - Resend functionality
- `login_verifying` - Loading state
- `login_enterPin` / `login_pinSubtitle` - PIN screen
- `login_forgotPin` - Forgot PIN link
- `login_attemptsRemaining` - Plural attempts counter
- `login_accountLocked` / `login_lockedMessage` - Lockout screen
- `common_ok` / `common_continue` - Common buttons

French translations added to `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/l10n/app_fr.arb`

## Storage
Added to `StorageKeys` in `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/services/api/api_client.dart`:
- `rememberedPhone` - Stores "countryCode|phoneNumber" when "Remember this device" is checked

## Flow Diagram

```
┌─────────────────┐
│ LoginPhoneView  │
│ (Enter phone)   │
└────────┬────────┘
         │
         │ Submit phone → API call
         ▼
┌─────────────────┐
│  LoginOtpView   │
│ (Verify 6-digit)│
└────────┬────────┘
         │
         │ Verify OTP → API call
         ▼
┌─────────────────┐
│  LoginPinView   │
│ (Enter PIN or   │
│  Biometric)     │
└────────┬────────┘
         │
         │ Success → Store token
         ▼
┌─────────────────┐
│   Home View     │
└─────────────────┘
```

## Error Handling

### Phone Input
- Empty phone → "This field is required"
- Invalid format → "Please enter a valid phone number"
- Account not found → "Account not found. Please check your phone number or create a new account."

### OTP
- Invalid code → "Invalid code, try again"
- Auto-clear input after error
- Visual shake animation

### PIN
- Wrong PIN → "Incorrect PIN, X attempts remaining"
- 3 failed attempts → 15-minute lockout
- Lockout screen displays countdown
- "Forgot PIN?" link available

## Security Features
1. **Remember Device** - Encrypted phone storage with toggle
2. **PIN Lockout** - 3 attempts, 15-minute lock
3. **Biometric Fallback** - Auto-prompt if enabled
4. **Session Management** - Token storage in secure storage
5. **Device Registration** - TODO: Register device on successful login
6. **FCM Token Update** - TODO: Update FCM token on backend

## Mock Support
Works with existing mock infrastructure:
- Any phone number accepted for login
- Any 6-digit OTP accepted
- Any 6-digit PIN accepted (or "123456" specifically)

## Testing
```bash
# Generate localization files
cd /Users/macbook/JoonaPay/USDC-Wallet/mobile
flutter gen-l10n

# Run app
flutter run

# Test flow
1. Navigate to /login
2. Enter phone: +225 12345678
3. Check "Remember this device"
4. Submit → Navigate to OTP
5. Enter any 6 digits
6. Navigate to PIN
7. Enter any 6 digits
8. Navigate to /home
```

## Reused Components
- `AppButton` - Primary button with loading state
- `AppInput` - Phone number input
- `PinPad` - PIN entry keypad
- `PinDots` - Visual PIN dots
- `AppColors`, `AppTypography`, `AppSpacing` - Design tokens
- `BiometricService` - Biometric authentication
- `AuthService` - API calls
- `SessionService` - Session management

## Next Steps (TODOs in code)
1. Add device registration API call after successful PIN verification
2. Update FCM token on backend after login
3. Implement "Forgot PIN?" reset flow
4. Add biometric prompt auto-show logic refinement
5. Add PIN verification API endpoint integration (currently mocked)

## Accessibility
- Semantic labels on all inputs
- Proper focus management (auto-advance OTP boxes)
- Error messages announced to screen readers
- High contrast error states
- Touch targets meet minimum 48x48 size

## Performance
- Lazy widget creation
- Debounced API calls
- Efficient state updates with copyWith
- Minimal rebuilds with Riverpod
- Timer cleanup on dispose

## Files Modified
1. `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/router/app_router.dart` - Added login routes
2. `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/services/api/api_client.dart` - Added rememberedPhone storage key
3. `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/l10n/app_en.arb` - Added login strings
4. `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/l10n/app_fr.arb` - Added French translations

## Files Created
1. `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/features/auth/models/login_state.dart`
2. `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/features/auth/providers/login_provider.dart`
3. `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/features/auth/views/login_phone_view.dart`
4. `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/features/auth/views/login_otp_view.dart`
5. `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/features/auth/views/login_pin_view.dart`
