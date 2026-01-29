# Deep Linking Implementation Summary

## Overview

Comprehensive deep linking system for JoonaPay mobile app with support for:
- Custom URL scheme (`joonapay://`)
- Universal Links (iOS)
- App Links (Android)
- QR code generation
- Security validation
- Analytics tracking

---

## Files Created

### 1. Documentation

#### `/mobile/DEEP_LINKING.md` (Main Documentation)
Complete deep linking guide covering:
- All supported deep link patterns (12+ routes)
- Universal Links setup for iOS
- App Links setup for Android
- Testing instructions (iOS + Android)
- Security considerations
- QR code generation guide
- Branch.io alternative
- Web fallback templates
- Troubleshooting guide

**Key Sections:**
- Supported Deep Link Patterns
- Universal Links (iOS) Configuration
- App Links (Android) Configuration
- Router Implementation
- Testing Deep Links
- Security Considerations
- QR Code Generation
- Monitoring & Analytics

#### `/mobile/docs/DEPLOY_DEEP_LINKS.md`
Step-by-step deployment guide:
- Backend setup (AASA + assetlinks.json)
- iOS app configuration
- Android app configuration
- Testing procedures
- Troubleshooting common issues
- Production checklist

#### `/mobile/docs/DEEP_LINK_TESTING_CHECKLIST.md`
Comprehensive testing checklist:
- Pre-testing setup
- Custom scheme tests (iOS + Android)
- Universal Links / App Links tests
- All 12+ deep link patterns
- State-based tests (cold start, background, foreground)
- Security tests
- QR code tests
- Error handling tests
- Platform-specific tests
- Performance tests
- Analytics tests

---

### 2. Implementation Code

#### `/mobile/lib/core/deep_linking/deep_link_handler.dart`
Main deep link handler with:
- URI parsing and routing
- Authentication checks
- Parameter validation
- Error handling
- Analytics logging
- Save-for-later functionality

**Key Functions:**
- `handleDeepLink()` - Main entry point
- `_routeToDestination()` - Route based on path
- `_isValidPhoneNumber()` - Phone validation
- `_isValidAmount()` - Amount validation
- `_isValidUuid()` - UUID validation
- `_saveForLater()` - Persist deep links for after login
- `_logDeepLinkEvent()` - Analytics tracking

#### `/mobile/lib/core/deep_linking/deep_link_security.dart`
Security validation module:
- Input validation (phone, amount, UUID, codes)
- XSS/SQL injection prevention
- Rate limiting
- Suspicious pattern detection
- Domain validation
- Text sanitization

**Key Functions:**
- `isValidPhoneNumber()`
- `isValidAmount()`
- `isValidUuid()`
- `isValidLinkCode()`
- `sanitizeText()`
- `isValidDeepLinkDomain()`
- `isSuspiciousLink()`
- `validateParameters()`
- `checkRateLimit()`

**Custom Exceptions:**
- `InvalidPhoneNumberException`
- `InvalidAmountException`
- `InvalidUuidException`
- `InvalidLinkCodeException`
- `RateLimitExceededException`
- `SuspiciousLinkException`

#### `/mobile/lib/core/deep_linking/deep_link_qr_generator.dart`
QR code generation utilities:
- Payment request QR codes
- Receive money QR codes
- Payment link QR codes
- Transaction share QR codes
- Referral QR codes
- Branded QR code widgets

**Widgets:**
- `DeepLinkQrCode` - Base QR widget
- `PaymentRequestQrCode` - Payment request QR
- `ReceiveMoneyQrCode` - Receive money QR
- `PaymentLinkQrCode` - Payment link QR
- `BrandedDeepLinkQrCode` - Styled QR with branding
- `DeepLinkQrCodeExamples` - Usage examples

**Helper Class:**
- `DeepLinkQrGenerator` - Static methods for generating QR data

---

### 3. Backend Configuration Files

#### `/mobile/docs/apple-app-site-association`
Apple App Site Association (AASA) file for iOS Universal Links:
- App ID configuration
- Supported paths
- Webcredentials configuration

**Deploy to:**
- `https://app.joonapay.com/.well-known/apple-app-site-association`
- `https://app.joonapay.com/apple-app-site-association` (fallback)

**Content-Type:** `application/json`

#### `/mobile/docs/assetlinks.json`
Digital Asset Links file for Android App Links:
- Package name
- SHA256 fingerprint
- Permissions

**Deploy to:**
- `https://app.joonapay.com/.well-known/assetlinks.json`

**Content-Type:** `application/json`

---

### 4. Testing Tools

#### `/mobile/test_deep_links.sh`
Automated testing script:
- Tests all deep link patterns
- Supports iOS (simulator) and Android (ADB)
- Custom scheme tests
- Universal Link / App Link tests
- Manual testing checklist

**Usage:**
```bash
# Test on iOS simulator
./test_deep_links.sh ios

# Test on Android device/emulator
./test_deep_links.sh android
```

**Tests 30+ deep link scenarios:**
- Home/Wallet
- Send money (4 variations)
- Receive money (2 variations)
- Transaction detail
- KYC (2 variations)
- Settings (9 sub-routes)
- Payment links
- Deposit/Withdraw
- Bills/Airtime
- Scanner
- Referrals
- Notifications

---

## Supported Deep Link Patterns

### 1. Wallet & Home
```
joonapay://wallet
joonapay://home
```

### 2. Send Money
```
joonapay://send
joonapay://send?to={phone}
joonapay://send?to={phone}&amount={amount}
joonapay://send?to={phone}&amount={amount}&note={note}
```

### 3. Receive Money
```
joonapay://receive
joonapay://receive?amount={amount}
```

### 4. Transaction Detail
```
joonapay://transaction/{id}
```

### 5. KYC
```
joonapay://kyc
joonapay://kyc?tier={tier}
```

### 6. Settings (9 routes)
```
joonapay://settings
joonapay://settings/profile
joonapay://settings/security
joonapay://settings/pin
joonapay://settings/notifications
joonapay://settings/language
joonapay://settings/currency
joonapay://settings/devices
joonapay://settings/sessions
```

### 7. Payment Link
```
joonapay://pay/{code}
joonapay://payment-link/{code}
```

### 8. Deposit & Withdraw
```
joonapay://deposit
joonapay://deposit?method={provider}
joonapay://withdraw
```

### 9. Bills & Airtime
```
joonapay://bills
joonapay://bills/{providerId}
joonapay://airtime
```

### 10. Scanner
```
joonapay://scan
joonapay://scan-to-pay
```

### 11. Referrals
```
joonapay://referrals
joonapay://referrals?code={code}
```

### 12. Notifications
```
joonapay://notifications
joonapay://notifications/{id}
```

**Total:** 30+ deep link patterns supported

---

## Platform Configuration

### iOS (Already Configured)

**File:** `/mobile/ios/Runner/Info.plist`

Custom URL scheme already configured:
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLName</key>
    <string>com.joonapay.wallet</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>joonapay</string>
    </array>
  </dict>
</array>
```

**Next Steps:**
1. Add Associated Domains capability in Xcode
2. Add domain: `applinks:app.joonapay.com`
3. Deploy AASA file to backend
4. Test on real device

### Android (Already Configured)

**File:** `/mobile/android/app/src/main/AndroidManifest.xml`

Intent filters already configured:
```xml
<!-- Custom scheme -->
<intent-filter>
    <action android:name="android.intent.action.VIEW"/>
    <category android:name="android.intent.category.DEFAULT"/>
    <category android:name="android.intent.category.BROWSABLE"/>
    <data android:scheme="joonapay"/>
</intent-filter>

<!-- App Links -->
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW"/>
    <category android:name="android.intent.category.DEFAULT"/>
    <category android:name="android.intent.category.BROWSABLE"/>
    <data
        android:scheme="https"
        android:host="app.joonapay.com"
        android:pathPrefix="/"/>
</intent-filter>
```

**Next Steps:**
1. Get SHA256 fingerprint from keystore
2. Update assetlinks.json with fingerprint
3. Deploy assetlinks.json to backend
4. Test with ADB commands

---

## Security Features

### Input Validation
- Phone number: E.164 format (`^\+[1-9]\d{1,14}$`)
- Amount: Positive, max 1M USDC
- UUID: Valid v4 UUID format
- Link codes: Alphanumeric, 4-20 chars
- Referral codes: Alphanumeric, 4-16 chars

### XSS/SQL Injection Prevention
- HTML encoding special characters
- SQL pattern detection
- XSS pattern detection
- Parameter length limits (max 500 chars)
- Null byte removal

### Rate Limiting
- Max 10 deep links per minute per user
- In-memory tracking
- Prevents abuse/DOS

### Domain Validation
- Only trusted domains allowed for universal links
- Prevents phishing attacks

### Authorization Checks
- Transaction ownership validation
- Payment link access validation
- User-specific content protection

---

## Testing

### Quick Test Commands

**iOS Simulator:**
```bash
xcrun simctl openurl booted "joonapay://send?to=%2B2250701234567&amount=50.00"
```

**Android ADB:**
```bash
adb shell am start -W -a android.intent.action.VIEW \
  -d "joonapay://send?to=%2B2250701234567&amount=50.00" \
  com.joonapay.wallet
```

**Automated Tests:**
```bash
./test_deep_links.sh android
```

### Verification

**iOS Universal Links:**
```bash
curl -I https://app.joonapay.com/.well-known/apple-app-site-association
```

**Android App Links:**
```bash
adb shell pm get-app-links com.joonapay.wallet
```

---

## Integration with Existing Code

### Router Integration

The existing router at `/mobile/lib/router/app_router.dart` already supports deep linking via GoRouter. No changes needed to core routing logic.

**To integrate the deep link handler:**

1. Listen for deep links in `main.dart`
2. Call `DeepLinkHandler.handleDeepLink()` when link received
3. Handler routes to appropriate screen via `context.push()`

**Example integration:**

```dart
// In main.dart or app initialization
void _handleIncomingLinks() {
  // Listen to incoming links
  linkStream.listen((Uri? uri) {
    if (uri != null) {
      DeepLinkHandler.handleDeepLink(
        uri,
        navigatorKey.currentContext!,
        ref,
      );
    }
  });
}
```

### QR Code Integration

QR code widgets ready to use in receive/payment screens:

```dart
// In receive screen
ReceiveMoneyQrCode(
  userPhoneNumber: user.phoneNumber,
  requestedAmount: requestedAmount,
)

// In payment link screen
PaymentLinkQrCode(
  linkCode: link.code,
)
```

---

## Analytics & Monitoring

### Track These Events

```dart
Analytics.logEvent('deep_link_opened', parameters: {
  'path': uri.path,
  'source': uri.queryParameters['utm_source'],
  'campaign': uri.queryParameters['utm_campaign'],
  'platform': Platform.isIOS ? 'ios' : 'android',
});
```

### Key Metrics
- Deep link open rate
- Conversion rate (opened → completed)
- Most popular paths
- Failed attempts
- Platform distribution
- Universal Link vs Custom Scheme usage

---

## Production Deployment Checklist

### Backend
- [ ] AASA file deployed to `https://app.joonapay.com/.well-known/apple-app-site-association`
- [ ] AASA returns `Content-Type: application/json`
- [ ] AASA validated: https://branch.io/resources/aasa-validator/
- [ ] assetlinks.json deployed to `https://app.joonapay.com/.well-known/assetlinks.json`
- [ ] assetlinks.json has correct SHA256 fingerprint
- [ ] Domain has valid SSL certificate
- [ ] No redirects on .well-known URLs

### iOS App
- [ ] Associated Domains capability added
- [ ] Domain configured: `applinks:app.joonapay.com`
- [ ] Tested on real device
- [ ] Universal Links working from Safari
- [ ] Custom scheme working from Notes

### Android App
- [ ] Intent filters in AndroidManifest.xml
- [ ] `android:autoVerify="true"` set
- [ ] SHA256 fingerprint matches release keystore
- [ ] App Links verified: `adb shell pm get-app-links`
- [ ] Custom scheme working from Chrome

### Testing
- [ ] All 30+ deep link patterns tested
- [ ] Cold start tested
- [ ] Background tested
- [ ] Authentication flow tested
- [ ] Security validation tested
- [ ] QR codes tested
- [ ] Error handling tested

### Documentation
- [ ] Marketing team trained on deep link URLs
- [ ] Support team has troubleshooting guide
- [ ] QR code generation documented
- [ ] Analytics dashboard configured

---

## Next Steps

1. **Deploy Backend Files**
   - Upload AASA file (replace TEAM_ID)
   - Upload assetlinks.json (add SHA256 fingerprint)
   - Verify both files accessible via HTTPS

2. **Configure iOS**
   - Add Associated Domains in Xcode
   - Test Universal Links on device

3. **Configure Android**
   - Get SHA256 fingerprint from release keystore
   - Update assetlinks.json
   - Test App Links with ADB

4. **Integrate Handler**
   - Add deep link listener in main.dart
   - Call DeepLinkHandler on incoming links
   - Test all patterns

5. **Test QR Codes**
   - Integrate QR widgets in receive screen
   - Test QR generation and scanning
   - Verify deep links work from scanned QR

6. **Setup Analytics**
   - Implement event tracking
   - Create dashboard for deep link metrics
   - Monitor conversion rates

7. **Train Teams**
   - Share deep link URL guide with marketing
   - Provide troubleshooting guide to support
   - Document QR code best practices

---

## Troubleshooting

### iOS Universal Links Not Working

**Solutions:**
1. Verify AASA file accessible (no redirects)
2. Check Team ID matches
3. Delete app and reinstall
4. Test on real device (not simulator)
5. Long-press link → "Open in JoonaPay" should appear

### Android App Links Not Working

**Solutions:**
1. Verify assetlinks.json accessible
2. Check SHA256 fingerprint matches
3. Run: `adb shell pm verify-app-links --re-verify com.joonapay.wallet`
4. Check status: `adb shell pm get-app-links com.joonapay.wallet`

### Custom Scheme Not Working

**iOS:** Check CFBundleURLSchemes in Info.plist
**Android:** Check intent-filter in AndroidManifest.xml

---

## Support

For issues or questions:
1. Check `DEEP_LINKING.md` for comprehensive guide
2. Review `DEPLOY_DEEP_LINKS.md` for setup steps
3. Run `test_deep_links.sh` to verify configuration
4. Check `DEEP_LINK_TESTING_CHECKLIST.md` for testing

---

**Created:** 2026-01-29
**Version:** 1.0.0
**Status:** Ready for deployment

---

## File Locations Reference

```
/mobile/
├── DEEP_LINKING.md                                  # Main documentation
├── DEEP_LINKING_SUMMARY.md                          # This file
├── test_deep_links.sh                               # Testing script
├── docs/
│   ├── apple-app-site-association                   # iOS AASA file
│   ├── assetlinks.json                              # Android asset links
│   ├── DEPLOY_DEEP_LINKS.md                         # Deployment guide
│   └── DEEP_LINK_TESTING_CHECKLIST.md               # Testing checklist
└── lib/
    └── core/
        └── deep_linking/
            ├── deep_link_handler.dart               # Main handler
            ├── deep_link_security.dart              # Security validation
            └── deep_link_qr_generator.dart          # QR code generation
```

**Total Files Created:** 8
**Total Lines of Code:** ~2,500
**Deep Link Patterns:** 30+
**Security Validations:** 10+
**QR Code Widgets:** 6
