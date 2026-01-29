# PIN Feature Integration Checklist

## Prerequisites
- [x] All PIN files created
- [x] Localization strings added (English & French)
- [x] Mock API handlers registered
- [x] State management configured

## Integration Steps

### 1. Add Routes to Router
**File:** `/lib/router/app_router.dart`

- [ ] Add imports for PIN views
- [ ] Copy route definitions from `/lib/features/pin/ROUTES.dart`
- [ ] Verify routes are nested correctly in router tree

### 2. Regenerate Localization Files
```bash
cd mobile
flutter gen-l10n
```
- [ ] Run localization generation
- [ ] Verify no errors in output
- [ ] Check generated files in `.dart_tool/flutter_gen/`

### 3. Link PIN Setup to Onboarding
**File:** `/lib/features/onboarding/views/*_view.dart`

Add after user registration/login:
```dart
if (userNeedsPinSetup) {
  context.push('/pin/set');
}
```

- [ ] Add PIN check in onboarding flow
- [ ] Navigate to `/pin/set` for new users
- [ ] Skip if PIN already exists

### 4. Add Change PIN to Settings
**File:** `/lib/features/settings/views/security_settings_view.dart`

Add menu item:
```dart
ListTile(
  leading: Icon(Icons.lock_outline),
  title: Text(l10n.settings_changePin),
  subtitle: Text(l10n.settings_changePinDescription),
  onTap: () => context.push('/pin/change'),
)
```

- [ ] Add "Change PIN" option in security settings
- [ ] Test navigation to change PIN screen

### 5. Integrate PIN Verification in Transfers
**File:** `/lib/features/transfers/views/confirm_transfer_view.dart`

Before executing transfer:
```dart
final pinVerified = await context.push('/pin/enter?title=Verify PIN');
if (pinVerified == true) {
  // Execute transfer
}
```

- [ ] Add PIN verification before transfers
- [ ] Handle PIN verification result
- [ ] Show appropriate error if verification fails

### 6. Configure PIN Length
**File:** Already configured in `/lib/features/pin/providers/pin_provider.dart`

Verify PIN service is configured for 6-digit PINs:
```dart
PinConfig.pinLength = 6;
PinConfig.maxAttempts = 3;
PinConfig.lockoutDuration = Duration(minutes: 5);
```

- [x] PIN length set to 6
- [x] Max attempts set to 3
- [x] Lockout duration set to 5 minutes

### 7. Test All Flows

#### Set PIN Flow
- [ ] Navigate to `/pin/set`
- [ ] Try entering sequential PIN (123456) → should show error
- [ ] Try entering repeated PIN (111111) → should show error
- [ ] Enter valid PIN → navigate to confirmation
- [ ] Re-enter different PIN → should show error
- [ ] Re-enter same PIN → should save and navigate to home

#### Change PIN Flow
- [ ] Navigate to `/pin/change`
- [ ] Enter wrong current PIN → should show error
- [ ] Enter correct current PIN → proceed to new PIN
- [ ] Enter invalid new PIN → should show error
- [ ] Enter valid new PIN → proceed to confirmation
- [ ] Confirm new PIN → should save and show success

#### Reset PIN Flow
- [ ] Navigate to `/pin/reset`
- [ ] Request OTP → should show OTP input screen
- [ ] Enter wrong OTP → should show error
- [ ] Enter correct OTP (123456) → proceed to new PIN
- [ ] Set new PIN → should save and navigate to home

#### Lockout Flow
- [ ] Enter wrong PIN 3 times
- [ ] Should auto-navigate to locked screen
- [ ] Countdown should display correctly (MM:SS)
- [ ] Wait for countdown to complete
- [ ] Should unlock and allow retry

#### Enter PIN (Verification)
- [ ] Navigate with custom title
- [ ] Enter correct PIN → should return true
- [ ] Enter wrong PIN → should show error
- [ ] Check attempts counter decreases

### 8. Test Localization
- [ ] Switch app to French
- [ ] Verify all PIN screens show French text
- [ ] Verify error messages are in French
- [ ] Verify button labels are in French
- [ ] Switch back to English and verify

### 9. Test Backend Integration
**When backend is ready:**

- [ ] Verify `/api/v1/user/pin/set` endpoint works
- [ ] Verify `/api/v1/user/pin/change` endpoint works
- [ ] Verify `/api/v1/user/pin/verify` endpoint works
- [ ] Verify `/api/v1/user/pin/reset` endpoint works
- [ ] Test PIN sync across devices
- [ ] Test lockout tracking on backend

### 10. Test Edge Cases
- [ ] App backgrounded during PIN entry → should clear entered digits
- [ ] Network error during PIN save → should show error
- [ ] Multiple rapid taps on PIN pad → should debounce
- [ ] Rotate device during PIN entry → should maintain state
- [ ] Low memory warning → should not crash

### 11. Performance Testing
- [ ] PIN entry feels responsive (< 100ms tap to visual feedback)
- [ ] Animations are smooth (60fps)
- [ ] No jank during keyboard transitions
- [ ] Memory usage stable during long usage
- [ ] Battery drain acceptable

### 12. Accessibility Testing
- [ ] Screen reader announces PIN dots count
- [ ] All buttons have semantic labels
- [ ] Error messages are announced
- [ ] Color contrast meets WCAG AA
- [ ] Touch targets are at least 48x48

### 13. Security Audit
- [ ] PIN never logged to console
- [ ] PIN not visible in debugger
- [ ] PIN stored in secure storage only
- [ ] Transmission uses hashed values
- [ ] Lockout prevents brute force
- [ ] No timing attacks possible

## Optional Enhancements

### Biometric Integration
**Priority:** Medium
- [ ] Add biometric authentication option
- [ ] Store biometric preference
- [ ] Show fingerprint button on EnterPinView
- [ ] Handle biometric errors gracefully
- [ ] Allow PIN fallback always available

### PIN Strength Meter
**Priority:** Low
- [ ] Add visual strength indicator
- [ ] Show during PIN creation
- [ ] Suggest improvements for weak PINs
- [ ] Color-coded feedback

### Analytics
**Priority:** Medium
- [ ] Track PIN setup completion rate
- [ ] Track PIN change frequency
- [ ] Track lockout occurrences
- [ ] Track reset PIN usage

## Rollout Strategy

### Phase 1: Testing (Current)
- [ ] Internal testing with mocks
- [ ] QA testing all flows
- [ ] Fix any bugs found

### Phase 2: Beta
- [ ] Deploy to beta users
- [ ] Monitor lockout rates
- [ ] Gather user feedback
- [ ] Iterate on UX if needed

### Phase 3: Production
- [ ] Deploy to production
- [ ] Monitor error rates
- [ ] Monitor performance metrics
- [ ] Prepare support documentation

## Support Documentation Needed
- [ ] User guide: How to set/change PIN
- [ ] User guide: What to do if locked out
- [ ] Support article: Reset PIN via OTP
- [ ] FAQ: PIN requirements and security
- [ ] Admin guide: Handle locked accounts

## Rollback Plan
If critical issues found:
1. Temporarily disable PIN requirement
2. Allow biometric-only authentication
3. Fix issues in hotfix branch
4. Re-enable after testing

## Success Metrics
- [ ] > 95% PIN setup completion during onboarding
- [ ] < 1% lockout rate per month
- [ ] < 0.1% PIN reset requests per month
- [ ] Average PIN creation time < 30 seconds
- [ ] Zero PIN-related crashes

## Notes
- Mock OTP code is `123456` for testing
- Lockout duration is 5 minutes (configurable)
- PIN length is 6 digits (configurable)
- Max attempts is 3 (configurable)

## Team Sign-off
- [ ] Frontend Lead: ________________
- [ ] Backend Lead: ________________
- [ ] QA Lead: ________________
- [ ] Security Lead: ________________
- [ ] Product Manager: ________________

## Deployment Date
Target: ________________
Actual: ________________
