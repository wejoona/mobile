# Deep Link Testing Checklist

## Pre-Testing Setup

### iOS Setup
- [ ] AASA file deployed to `https://app.joonapay.com/.well-known/apple-app-site-association`
- [ ] AASA file validated: https://branch.io/resources/aasa-validator/
- [ ] Associated Domains capability added in Xcode
- [ ] Domain added: `applinks:app.joonapay.com`
- [ ] App built with valid provisioning profile
- [ ] Testing on real device (not simulator for Universal Links)

### Android Setup
- [ ] assetlinks.json deployed to `https://app.joonapay.com/.well-known/assetlinks.json`
- [ ] assetlinks.json has correct SHA256 fingerprint
- [ ] AndroidManifest.xml has intent filters configured
- [ ] `android:autoVerify="true"` set on HTTPS intent filter
- [ ] App installed on device/emulator
- [ ] App Links verified: `adb shell pm get-app-links com.joonapay.wallet`

---

## Custom Scheme Tests (joonapay://)

### iOS Custom Scheme

#### From Safari
- [ ] Open Safari
- [ ] Type: `joonapay://wallet`
- [ ] Tap "Go"
- [ ] Dialog appears: "Open in JoonaPay?"
- [ ] Tap "Open"
- [ ] App opens to wallet screen

#### From Notes App
- [ ] Open Notes app
- [ ] Create new note
- [ ] Type: `joonapay://send?to=+2250701234567&amount=50.00`
- [ ] Link becomes blue/clickable
- [ ] Tap the link
- [ ] App opens to send screen with pre-filled data

#### From Messages
- [ ] Open Messages app
- [ ] Send yourself: `joonapay://receive?amount=100.00`
- [ ] Tap the link
- [ ] App opens to receive screen

### Android Custom Scheme

#### From Chrome
- [ ] Open Chrome browser
- [ ] Type in address bar: `joonapay://wallet`
- [ ] Tap "Go"
- [ ] App chooser appears or app opens directly
- [ ] Select JoonaPay
- [ ] App opens to wallet screen

#### From Gmail
- [ ] Send email to yourself with link: `joonapay://send?to=+2250701234567`
- [ ] Open email on device
- [ ] Tap the link
- [ ] App opens to send screen

#### From SMS
- [ ] Send SMS with link: `joonapay://kyc`
- [ ] Tap the link
- [ ] App opens to KYC screen

---

## Universal Links / App Links Tests (HTTPS)

### iOS Universal Links

#### From Safari (Device)
- [ ] Open Safari on iOS device (NOT simulator)
- [ ] Type: `https://app.joonapay.com/send?to=+2250701234567`
- [ ] Tap "Go"
- [ ] App should open DIRECTLY (no dialog)
- [ ] If opens in Safari, long-press link → "Open in JoonaPay" should appear

#### From Messages
- [ ] Send link: `https://app.joonapay.com/pay/ABCD1234`
- [ ] Tap link
- [ ] App opens directly

#### From Notes
- [ ] Type: `https://app.joonapay.com/transaction/550e8400-e29b-41d4-a716-446655440000`
- [ ] Tap link
- [ ] App opens directly

### Android App Links

#### From Chrome
- [ ] Type: `https://app.joonapay.com/send`
- [ ] App should open DIRECTLY (no app chooser)
- [ ] If shows chooser, App Links not verified

#### From Gmail
- [ ] Email link: `https://app.joonapay.com/kyc?tier=tier2`
- [ ] Tap link
- [ ] App opens directly

#### Verification Check
```bash
adb shell pm get-app-links com.joonapay.wallet
# Should show:
# com.joonapay.wallet:
#   ID: ...
#   Signatures: ...
#   Domain verification state:
#     app.joonapay.com: verified
```

---

## Deep Link Patterns Tests

### 1. Wallet & Home
- [ ] `joonapay://wallet` → Opens wallet home
- [ ] `joonapay://home` → Opens home screen
- [ ] Both redirect to `/login` if not authenticated

### 2. Send Money
- [ ] `joonapay://send` → Opens send flow (empty)
- [ ] `joonapay://send?to=+2250701234567` → Pre-fills phone number
- [ ] `joonapay://send?to=+2250701234567&amount=50.00` → Pre-fills phone + amount
- [ ] `joonapay://send?to=+2250701234567&amount=50.00&note=Coffee` → Pre-fills all
- [ ] Invalid phone number → Shows error, redirects to home
- [ ] Invalid amount (negative, zero, >1M) → Shows error

### 3. Receive Money
- [ ] `joonapay://receive` → Shows receive screen with user QR
- [ ] `joonapay://receive?amount=100.00` → QR encodes payment request

### 4. Transaction Detail
- [ ] `joonapay://transaction/550e8400-e29b-41d4-a716-446655440000` → Shows transaction
- [ ] Invalid UUID → Shows error
- [ ] Transaction not found → Shows error
- [ ] Transaction doesn't belong to user → Shows unauthorized error

### 5. KYC
- [ ] `joonapay://kyc` → Opens KYC status
- [ ] `joonapay://kyc?tier=tier2` → Opens upgrade flow for tier 2
- [ ] `joonapay://kyc/status` → Opens KYC status

### 6. Settings
- [ ] `joonapay://settings` → Opens settings home
- [ ] `joonapay://settings/profile` → Profile settings
- [ ] `joonapay://settings/security` → Security settings
- [ ] `joonapay://settings/pin` → Change PIN
- [ ] `joonapay://settings/notifications` → Notification settings
- [ ] `joonapay://settings/language` → Language settings
- [ ] `joonapay://settings/currency` → Currency settings
- [ ] `joonapay://settings/devices` → Device management
- [ ] `joonapay://settings/sessions` → Active sessions
- [ ] `joonapay://settings/limits` → Transaction limits
- [ ] `joonapay://settings/help` → Help center

### 7. Payment Link
- [ ] `joonapay://pay/ABCD1234` → Opens payment link screen
- [ ] `joonapay://payment-link/ABCD1234` → Same as above
- [ ] Invalid code → Shows error
- [ ] Expired link → Shows "link expired" error
- [ ] Link already paid → Shows appropriate message

### 8. Deposit & Withdraw
- [ ] `joonapay://deposit` → Opens deposit screen
- [ ] `joonapay://deposit?method=orange` → Pre-selects Orange Money
- [ ] `joonapay://deposit?method=mtn` → Pre-selects MTN
- [ ] `joonapay://withdraw` → Opens withdraw screen

### 9. Bills & Airtime
- [ ] `joonapay://bills` → Opens bill payments
- [ ] `joonapay://bills/cie-electricity` → Opens CIE Electricity payment
- [ ] `joonapay://airtime` → Opens airtime purchase

### 10. Scanner
- [ ] `joonapay://scan` → Opens QR scanner
- [ ] `joonapay://scan-to-pay` → Opens QR scanner for merchant payment

### 11. Referrals
- [ ] `joonapay://referrals` → Opens referral program
- [ ] `joonapay://referrals?code=JOHN2024` → Credits referrer, shows program

### 12. Notifications
- [ ] `joonapay://notifications` → Opens notification center
- [ ] `joonapay://notifications/{id}` → Opens specific notification

---

## State-Based Tests

### Cold Start (App Closed)
- [ ] Kill app completely
- [ ] Open deep link
- [ ] App launches and navigates to correct screen
- [ ] If auth required, redirects to login then back

### Background (App Running)
- [ ] App running in background
- [ ] Open deep link
- [ ] App comes to foreground
- [ ] Navigates to correct screen

### Foreground (App Active)
- [ ] App in foreground
- [ ] Open deep link
- [ ] Navigates to correct screen
- [ ] Doesn't reload app

### Not Authenticated
- [ ] User logged out
- [ ] Open protected deep link (e.g., `joonapay://send`)
- [ ] Redirects to login
- [ ] After login, redirects to original destination

### Authenticated
- [ ] User logged in
- [ ] Open deep link
- [ ] Navigates directly to destination

---

## Security Tests

### Input Validation
- [ ] Phone number validation: `joonapay://send?to=invalid` → Shows error
- [ ] Amount validation: `joonapay://send?amount=-50` → Shows error
- [ ] Amount validation: `joonapay://send?amount=9999999999` → Shows error
- [ ] UUID validation: `joonapay://transaction/invalid-uuid` → Shows error

### Authorization
- [ ] Transaction from another user → Shows "not found" or "unauthorized"
- [ ] Payment link for another merchant → Validates before showing

### Rate Limiting
- [ ] Open same deep link 20 times rapidly
- [ ] Should not crash app
- [ ] Should not cause infinite loops

### Malicious Links
- [ ] SQL injection attempt in parameters → Sanitized
- [ ] XSS attempt in note field → Escaped properly
- [ ] Extremely long parameter values → Truncated or rejected

---

## QR Code Tests

### Generate QR Codes
- [ ] Payment request QR generates correctly
- [ ] QR contains: `joonapay://send?to=...&amount=...`
- [ ] Scanning QR opens send flow

### Receive Money QR
- [ ] Receive screen shows QR with user's phone
- [ ] QR contains: `joonapay://send?to={userPhone}`
- [ ] Scanning QR opens send flow to user

### Payment Link QR
- [ ] Payment link QR generates with universal link
- [ ] QR contains: `https://app.joonapay.com/pay/ABCD1234`
- [ ] Scanning opens payment screen (or web if app not installed)

### QR Scanning
- [ ] Scan merchant QR code
- [ ] App opens payment confirmation
- [ ] Scan receive QR from another user
- [ ] App opens send flow to that user

---

## Error Handling Tests

### Network Errors
- [ ] Turn on Airplane Mode
- [ ] Open deep link requiring API call
- [ ] Shows appropriate offline error

### Invalid Destinations
- [ ] `joonapay://invalid-route` → Shows error, redirects to home
- [ ] `joonapay://` (empty path) → Redirects to home or login

### Missing Parameters
- [ ] `joonapay://transaction/` (no ID) → Shows error
- [ ] `joonapay://pay/` (no code) → Shows error

### Expired/Invalid Resources
- [ ] Expired payment link → Shows "link expired"
- [ ] Deleted transaction → Shows "transaction not found"

---

## Platform-Specific Tests

### iOS Only

#### Universal Links Specifics
- [ ] Long-press link in Safari → "Open in JoonaPay" appears
- [ ] Tap "Open in JoonaPay" → App opens
- [ ] In-app browser (e.g., Facebook) → Opens in app
- [ ] Delete and reinstall app → Universal Links still work

#### Handoff
- [ ] Open link on iPhone → Appears in Handoff on Mac
- [ ] Open link on iPad → Appears in Handoff on iPhone

### Android Only

#### App Links Specifics
- [ ] Chrome: Link opens app directly (no chooser)
- [ ] Gmail: Link opens app directly
- [ ] Default app setting: Settings → Apps → JoonaPay → "Open supported links" is enabled

#### Intent Chooser
- [ ] If multiple apps support scheme, chooser appears
- [ ] Select JoonaPay → App opens correctly

---

## Performance Tests

### Load Time
- [ ] Deep link from cold start → Measures time to screen
- [ ] Should be < 3 seconds

### Memory
- [ ] Open 10 deep links in sequence
- [ ] Memory usage remains stable
- [ ] No memory leaks

### Battery
- [ ] Deep link handling doesn't cause excessive battery drain

---

## Analytics Tests

### Tracking
- [ ] Deep link open event logged
- [ ] Event includes: path, source, campaign (UTM params)
- [ ] Event includes: timestamp, platform, app version

### Metrics
- [ ] Conversion tracking: Link opened → Action completed
- [ ] Popular paths tracked
- [ ] Failed attempts tracked

---

## Automation Tests

Run automated test script:

```bash
# iOS
./test_deep_links.sh ios

# Android
./test_deep_links.sh android
```

Check that all links:
- [ ] Open app without crash
- [ ] Navigate to correct screen
- [ ] Parse parameters correctly

---

## Production Checklist

### Before Launch
- [ ] All test cases above passed
- [ ] AASA file deployed to production domain
- [ ] assetlinks.json deployed to production domain
- [ ] SSL certificate valid on production domain
- [ ] Deep links tested on production build (not debug)
- [ ] Tested on multiple iOS versions (13+)
- [ ] Tested on multiple Android versions (6+)
- [ ] Tested on different device models

### Marketing Ready
- [ ] Deep link URL guide shared with marketing team
- [ ] QR code generation documented
- [ ] Email template examples created
- [ ] SMS template examples created
- [ ] Social media post examples created

### Support Ready
- [ ] Support team trained on deep linking
- [ ] Troubleshooting guide available
- [ ] Common issues documented
- [ ] FAQ updated

---

## Regression Testing

Run this checklist:
- [ ] After every app update
- [ ] After router changes
- [ ] After authentication system changes
- [ ] After backend API changes
- [ ] Monthly (minimum)

---

## Test Results

| Test Category | Pass/Fail | Notes | Date Tested |
|---------------|-----------|-------|-------------|
| Custom Scheme (iOS) | | | |
| Custom Scheme (Android) | | | |
| Universal Links (iOS) | | | |
| App Links (Android) | | | |
| All Deep Link Patterns | | | |
| State-Based Tests | | | |
| Security Tests | | | |
| QR Code Tests | | | |
| Error Handling | | | |
| Performance | | | |
| Analytics | | | |

---

**Testing Completed By:** _______________
**Date:** _______________
**App Version:** _______________
**Platform:** _______________
**Device:** _______________

---

**Last Updated:** 2026-01-29
