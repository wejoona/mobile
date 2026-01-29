# Deep Link Quick Reference Card

## URL Patterns (Copy-Paste Ready)

### Send Money
```
joonapay://send
joonapay://send?to=+2250701234567
joonapay://send?to=+2250701234567&amount=50.00
joonapay://send?to=+2250701234567&amount=50.00&note=Payment
```

### Receive Money
```
joonapay://receive
joonapay://receive?amount=100.00
```

### Transaction
```
joonapay://transaction/550e8400-e29b-41d4-a716-446655440000
```

### KYC
```
joonapay://kyc
joonapay://kyc?tier=tier2
```

### Settings
```
joonapay://settings
joonapay://settings/profile
joonapay://settings/security
joonapay://settings/pin
```

### Payment Link
```
joonapay://pay/ABCD1234
https://app.joonapay.com/pay/ABCD1234
```

### Deposit/Withdraw
```
joonapay://deposit
joonapay://deposit?method=orange
joonapay://withdraw
```

### Bills & Airtime
```
joonapay://bills
joonapay://bills/cie-electricity
joonapay://airtime
```

### Other
```
joonapay://scan
joonapay://referrals?code=JOHN2024
joonapay://notifications
```

---

## Test Commands

### iOS Simulator
```bash
xcrun simctl openurl booted "joonapay://send?to=%2B2250701234567"
```

### Android ADB
```bash
adb shell am start -W -a android.intent.action.VIEW \
  -d "joonapay://send?to=%2B2250701234567" com.joonapay.wallet
```

### Run All Tests
```bash
./test_deep_links.sh android  # or ios
```

---

## Verification

### iOS Universal Links
```bash
curl -I https://app.joonapay.com/.well-known/apple-app-site-association
```

### Android App Links
```bash
adb shell pm get-app-links com.joonapay.wallet
```

---

## QR Code Generation

```dart
// Payment Request QR
PaymentRequestQrCode(
  phoneNumber: '+2250701234567',
  amount: 50.00,
)

// Receive Money QR
ReceiveMoneyQrCode(
  userPhoneNumber: user.phoneNumber,
  requestedAmount: 100.00,
)

// Payment Link QR
PaymentLinkQrCode(
  linkCode: 'ABCD1234',
)
```

---

## Security Validation

```dart
// Phone validation
DeepLinkSecurity.isValidPhoneNumber('+2250701234567') // true

// Amount validation
DeepLinkSecurity.isValidAmount('50.00') // true
DeepLinkSecurity.isValidAmount('-10') // false

// UUID validation
DeepLinkSecurity.isValidUuid('550e8400-e29b-41d4-a716-446655440000') // true
```

---

## Common Issues

| Problem | Solution |
|---------|----------|
| iOS Universal Links not working | Delete app, reinstall. Test on device (not simulator). |
| Android App Links not working | `adb shell pm verify-app-links --re-verify com.joonapay.wallet` |
| Custom scheme not opening | Check scheme is lowercase: `joonapay://` |
| Parameters not parsing | URL encode special chars: `%2B` for `+` |

---

## File Locations

- Main Docs: `/mobile/DEEP_LINKING.md`
- Deploy Guide: `/mobile/docs/DEPLOY_DEEP_LINKS.md`
- Testing Checklist: `/mobile/docs/DEEP_LINK_TESTING_CHECKLIST.md`
- Handler Code: `/mobile/lib/core/deep_linking/deep_link_handler.dart`
- QR Generator: `/mobile/lib/core/deep_linking/deep_link_qr_generator.dart`
- Security: `/mobile/lib/core/deep_linking/deep_link_security.dart`
- Test Script: `/mobile/test_deep_links.sh`
- AASA File: `/mobile/docs/apple-app-site-association`
- Asset Links: `/mobile/docs/assetlinks.json`

---

## Marketing Templates

### Email Link
```html
<a href="joonapay://send?to=+2250701234567&amount=50.00">
  Pay Now
</a>
```

### SMS Template
```
Pay your invoice: joonapay://pay/ABC123
```

### QR Code Caption
```
Scan with JoonaPay to pay 50.00 USDC
```

---

**Last Updated:** 2026-01-29
