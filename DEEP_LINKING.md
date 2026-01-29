# Deep Linking Documentation - JoonaPay Mobile

## Overview

JoonaPay supports deep linking via custom URL scheme (`joonapay://`) and Universal Links/App Links for seamless navigation from external sources like:
- Marketing emails
- SMS notifications
- QR codes
- Social media shares
- Push notifications
- Web fallback

---

## Supported Deep Link Patterns

### 1. Wallet & Home

```
joonapay://wallet
joonapay://home
```

**Behavior:** Opens wallet home screen showing balance and quick actions.

**Example Use Cases:**
- Push notification taps
- Email CTA buttons
- Quick access shortcuts

---

### 2. Send Money

```
joonapay://send
joonapay://send?to={phoneNumber}
joonapay://send?to={phoneNumber}&amount={amount}
joonapay://send?to={phoneNumber}&amount={amount}&note={note}
```

**Parameters:**
- `to` (optional): Recipient phone number (E.164 format: +225XXXXXXXX)
- `amount` (optional): Pre-filled amount in USDC
- `note` (optional): Pre-filled transaction note (URL encoded)

**Behavior:** Opens send flow, optionally pre-filling recipient and amount.

**Example Use Cases:**
- "Pay John" button in chat
- Request money response link
- Invoice payment link

**Example:**
```
joonapay://send?to=%2B2250701234567&amount=50.00&note=Coffee%20payment
```

---

### 3. Receive Money

```
joonapay://receive
joonapay://receive?amount={amount}
```

**Parameters:**
- `amount` (optional): Requested amount to display in QR code

**Behavior:** Shows receive screen with user's QR code. If amount specified, encodes payment request in QR.

**Example Use Cases:**
- "Show my QR" shortcut
- Payment request with specific amount
- In-person payment collection

**Example:**
```
joonapay://receive?amount=100.00
```

---

### 4. Transaction Detail

```
joonapay://transaction/{transactionId}
joonapay://transactions/{transactionId}
```

**Parameters:**
- `transactionId` (required): UUID of the transaction

**Behavior:** Opens transaction detail view for the specified transaction.

**Example Use Cases:**
- Push notification tap on transaction alert
- Email receipt link
- Transaction dispute link

**Example:**
```
joonapay://transaction/550e8400-e29b-41d4-a716-446655440000
```

**Security:** Must verify transaction belongs to authenticated user before displaying.

---

### 5. KYC Verification

```
joonapay://kyc
joonapay://kyc?tier={targetTier}
joonapay://kyc/status
```

**Parameters:**
- `tier` (optional): Target KYC tier (tier1, tier2, tier3)

**Behavior:** Opens KYC status or upgrade flow.

**Example Use Cases:**
- Limit increase prompt
- Compliance reminder notification
- Onboarding nudge

**Example:**
```
joonapay://kyc?tier=tier2
```

---

### 6. Settings

```
joonapay://settings
joonapay://settings/profile
joonapay://settings/security
joonapay://settings/pin
joonapay://settings/notifications
joonapay://settings/language
```

**Behavior:** Opens specific settings screen.

**Example Use Cases:**
- "Update profile" email link
- "Enable biometric" prompt
- Security alert action

---

### 7. Payment Link

```
joonapay://pay/{linkCode}
joonapay://payment-link/{linkCode}
```

**Parameters:**
- `linkCode` (required): Short code or UUID of the payment link

**Behavior:** Opens payment link view for customer to complete payment.

**Example Use Cases:**
- Merchant invoice link
- Social media payment request
- SMS payment link

**Example:**
```
joonapay://pay/ABCD1234
```

**Security:** Validates link exists, is active, and not expired before showing payment screen.

---

### 8. Deposit & Withdraw

```
joonapay://deposit
joonapay://deposit?method={provider}
joonapay://withdraw
```

**Parameters:**
- `method` (optional): Mobile money provider (orange, mtn, wave)

**Behavior:** Opens deposit/withdraw flow, optionally pre-selecting provider.

**Example:**
```
joonapay://deposit?method=orange
```

---

### 9. Bill Payments

```
joonapay://bills
joonapay://bills/{providerId}
joonapay://airtime
```

**Parameters:**
- `providerId` (optional): Specific bill provider ID

**Behavior:** Opens bill payment flow.

**Example:**
```
joonapay://bills/cie-electricity
```

---

### 10. Merchant QR Scan

```
joonapay://scan
joonapay://scan-to-pay
```

**Behavior:** Opens QR scanner for merchant payments.

**Example Use Cases:**
- Quick access to scanner
- In-store payment flow

---

### 11. Referrals

```
joonapay://referrals
joonapay://referrals?code={referralCode}
```

**Parameters:**
- `code` (optional): Referrer's code for attribution

**Behavior:** Opens referral program view, credits referrer if code provided.

**Example:**
```
joonapay://referrals?code=JOHN2024
```

---

### 12. Notifications

```
joonapay://notifications
joonapay://notifications/{notificationId}
```

**Parameters:**
- `notificationId` (optional): Specific notification to view

**Behavior:** Opens notification center.

---

## Universal Links (iOS)

### Domain Setup

JoonaPay uses the domain: `https://app.joonapay.com`

**URL Format:**
```
https://app.joonapay.com/send?to=+2250701234567
https://app.joonapay.com/pay/ABCD1234
https://app.joonapay.com/transaction/550e8400-e29b-41d4-a716-446655440000
```

### Apple App Site Association (AASA) File

**File:** `apple-app-site-association` (no extension)

**Location:** Host at `https://app.joonapay.com/.well-known/apple-app-site-association`

**Content:**
```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAM_ID.com.joonapay.wallet",
        "paths": [
          "/send",
          "/send/*",
          "/receive",
          "/transaction/*",
          "/transactions/*",
          "/kyc",
          "/kyc/*",
          "/settings",
          "/settings/*",
          "/pay/*",
          "/payment-link/*",
          "/deposit",
          "/deposit/*",
          "/withdraw",
          "/bills",
          "/bills/*",
          "/airtime",
          "/scan",
          "/scan-to-pay",
          "/referrals",
          "/notifications",
          "/notifications/*",
          "/home",
          "/wallet"
        ]
      }
    ]
  },
  "webcredentials": {
    "apps": [
      "TEAM_ID.com.joonapay.wallet"
    ]
  }
}
```

**Important:**
1. Replace `TEAM_ID` with your Apple Developer Team ID
2. Serve with `Content-Type: application/json`
3. Must be accessible via HTTPS
4. No redirects allowed
5. File must be at root of `.well-known` directory

### iOS Configuration

**File:** `ios/Runner/Info.plist`

Already configured with:
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

**Add Associated Domains Capability:**

In Xcode:
1. Select Runner target
2. Signing & Capabilities tab
3. Click "+ Capability"
4. Add "Associated Domains"
5. Add domain: `applinks:app.joonapay.com`

---

## App Links (Android)

### Domain Setup

Same domain: `https://app.joonapay.com`

### Digital Asset Links File

**File:** `assetlinks.json`

**Location:** Host at `https://app.joonapay.com/.well-known/assetlinks.json`

**Content:**
```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.joonapay.wallet",
      "sha256_cert_fingerprints": [
        "SHA256_FINGERPRINT_HERE"
      ]
    }
  }
]
```

**Get SHA256 Fingerprint:**

```bash
# For debug keystore
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# For release keystore
keytool -list -v -keystore /path/to/release.keystore -alias your-alias
```

Copy the SHA256 fingerprint (remove colons).

**Example:**
```json
"sha256_cert_fingerprints": [
  "14:6D:E9:83:C5:73:06:50:D8:EE:B9:95:2F:34:FC:64:16:A0:83:42:E6:1D:BE:A8:8A:04:96:B2:3F:CF:44:E5"
]
```

### Android Configuration

**File:** `android/app/src/main/AndroidManifest.xml`

Already configured with:
```xml
<!-- Deep Links: Custom scheme (joonapay://) -->
<intent-filter>
    <action android:name="android.intent.action.VIEW"/>
    <category android:name="android.intent.category.DEFAULT"/>
    <category android:name="android.intent.category.BROWSABLE"/>
    <data android:scheme="joonapay"/>
</intent-filter>

<!-- App Links: HTTPS scheme for web fallback -->
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

**Note:** `android:autoVerify="true"` enables automatic App Links verification.

---

## Router Implementation

### Deep Link Handler (Pseudo-code)

```dart
// lib/core/deep_linking/deep_link_handler.dart

class DeepLinkHandler {
  static Future<void> handleDeepLink(Uri uri, BuildContext context) async {
    // Validate authentication state
    final authState = context.read(authProvider);

    // Extract path and parameters
    final path = uri.path;
    final params = uri.queryParameters;

    // Route based on path
    switch (path) {
      case '/send':
        final to = params['to'];
        final amount = params['amount'];
        final note = params['note'];
        context.push('/send', extra: {
          'recipient': to,
          'amount': amount,
          'note': note,
        });
        break;

      case '/receive':
        final amount = params['amount'];
        context.push('/receive', extra: {'amount': amount});
        break;

      case '/transaction':
        final txId = path.split('/').last;
        await _validateAndShowTransaction(txId, context);
        break;

      case '/pay':
        final code = path.split('/').last;
        await _validateAndShowPaymentLink(code, context);
        break;

      case '/kyc':
        final tier = params['tier'];
        context.push('/kyc', extra: {'targetTier': tier});
        break;

      default:
        if (authState.isAuthenticated) {
          context.go('/home');
        } else {
          context.go('/login');
        }
    }
  }

  static Future<void> _validateAndShowTransaction(String id, BuildContext context) async {
    // Validate transaction belongs to user
    final sdk = context.read(sdkProvider);
    try {
      final tx = await sdk.transactions.getTransaction(id);
      context.push('/transactions/$id', extra: tx);
    } catch (e) {
      // Show error toast
      AppToast.show(context, 'Transaction not found');
      context.go('/home');
    }
  }

  static Future<void> _validateAndShowPaymentLink(String code, BuildContext context) async {
    // Validate payment link exists and is active
    final sdk = context.read(sdkProvider);
    try {
      final link = await sdk.paymentLinks.getByCode(code);
      if (link.isExpired) {
        AppToast.show(context, 'Payment link has expired');
        return;
      }
      context.push('/pay/$code', extra: link);
    } catch (e) {
      AppToast.show(context, 'Invalid payment link');
      context.go('/home');
    }
  }
}
```

### Integration in main.dart

```dart
// lib/main.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ProviderScope(
      child: MaterialApp.router(
        routerConfig: router,
      ),
    ),
  );
}
```

### GoRouter Configuration

Already configured in `lib/router/app_router.dart`. The router handles:
- Authentication state checking
- Feature flag validation
- Route guards
- Parameter extraction

**No additional configuration needed** - existing routes support deep linking out of the box.

---

## Testing Deep Links

### iOS Testing

#### Safari (Device)

1. Open Safari
2. Type in address bar: `joonapay://send?to=+2250701234567`
3. Tap "Open" when prompted

#### Safari (Universal Links)

1. Type: `https://app.joonapay.com/send?to=+2250701234567`
2. Should open app directly (if AASA configured)

#### Command Line (Simulator)

```bash
# Custom scheme
xcrun simctl openurl booted "joonapay://send?to=%2B2250701234567&amount=50.00"

# Universal Link
xcrun simctl openurl booted "https://app.joonapay.com/send?to=%2B2250701234567"
```

#### Notes App Test

1. Open Notes app
2. Type a deep link URL
3. Tap the link
4. App should open

### Android Testing

#### ADB Commands

```bash
# Custom scheme
adb shell am start -W -a android.intent.action.VIEW -d "joonapay://send?to=%2B2250701234567&amount=50.00" com.joonapay.wallet

# App Link
adb shell am start -W -a android.intent.action.VIEW -d "https://app.joonapay.com/send?to=%2B2250701234567" com.joonapay.wallet

# Test transaction detail
adb shell am start -W -a android.intent.action.VIEW -d "joonapay://transaction/550e8400-e29b-41d4-a716-446655440000" com.joonapay.wallet

# Test payment link
adb shell am start -W -a android.intent.action.VIEW -d "joonapay://pay/ABCD1234" com.joonapay.wallet

# Test KYC
adb shell am start -W -a android.intent.action.VIEW -d "joonapay://kyc?tier=tier2" com.joonapay.wallet

# Test settings
adb shell am start -W -a android.intent.action.VIEW -d "joonapay://settings/security" com.joonapay.wallet
```

#### Chrome Browser (Device)

1. Open Chrome
2. Type in address bar: `joonapay://send`
3. Tap "Open in app"

#### Verify App Links

```bash
# Check if app is verified for domain
adb shell pm get-app-links com.joonapay.wallet

# Reset app link verification
adb shell pm set-app-links --package com.joonapay.wallet 0 app.joonapay.com

# Verify domain
adb shell pm verify-app-links --re-verify com.joonapay.wallet
```

### Testing Checklist

- [ ] **Custom scheme works** (joonapay://)
- [ ] **Universal Links work** (iOS only)
- [ ] **App Links work** (Android only)
- [ ] **Parameters parsed correctly**
- [ ] **Authentication required for protected routes**
- [ ] **Invalid links show error gracefully**
- [ ] **Expired payment links rejected**
- [ ] **Transaction access validated**
- [ ] **Deep link from cold start**
- [ ] **Deep link from background**
- [ ] **Deep link from terminated state**
- [ ] **Web fallback works** (if app not installed)

---

## Security Considerations

### 1. Input Validation

**Always validate deep link parameters:**

```dart
// Validate phone number
if (phoneNumber != null && !RegExp(r'^\+[1-9]\d{1,14}$').hasMatch(phoneNumber)) {
  throw InvalidPhoneNumberException();
}

// Validate amount
if (amount != null) {
  final parsed = double.tryParse(amount);
  if (parsed == null || parsed <= 0 || parsed > 1000000) {
    throw InvalidAmountException();
  }
}

// Validate UUID
if (!RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')
    .hasMatch(transactionId)) {
  throw InvalidIdException();
}
```

### 2. Authentication Requirements

**Protected routes require authentication:**

- Transaction details
- Send money
- Deposit/Withdraw
- Settings
- Payment link payment

**Public routes (no auth):**
- Login
- Onboarding
- KYC information page

```dart
if (!authState.isAuthenticated && isProtectedRoute(path)) {
  // Save intended destination
  saveDeepLinkForLater(uri);
  // Redirect to login
  context.go('/login');
}
```

### 3. Sensitive Data Handling

**Never include in deep links:**
- PINs
- Passwords
- Full credit card numbers
- Social Security Numbers
- Private keys

**Safe to include:**
- Transaction IDs (validate ownership)
- Phone numbers
- Amounts
- Public codes/references

### 4. Authorization Checks

**Always verify ownership:**

```dart
// Transaction detail
final transaction = await sdk.transactions.getTransaction(id);
if (transaction.userId != currentUserId) {
  throw UnauthorizedException();
}

// Payment link
final link = await sdk.paymentLinks.get(code);
if (link.merchantId != currentUserId && link.payerId != currentUserId) {
  throw UnauthorizedException();
}
```

### 5. Rate Limiting

**Prevent abuse:**
- Limit deep link processing to 10/minute per user
- Log suspicious patterns (same link opened 100x)
- Block malicious domains in payment links

---

## QR Code Generation

### Payment Request QR

```dart
import 'package:qr_flutter/qr_flutter.dart';

class PaymentRequestQR extends StatelessWidget {
  final String phoneNumber;
  final double? amount;
  final String? note;

  String get qrData {
    final uri = Uri(
      scheme: 'joonapay',
      path: 'send',
      queryParameters: {
        'to': phoneNumber,
        if (amount != null) 'amount': amount.toString(),
        if (note != null) 'note': note,
      },
    );
    return uri.toString();
  }

  @override
  Widget build(BuildContext context) {
    return QrImageView(
      data: qrData,
      version: QrVersions.auto,
      size: 280,
      backgroundColor: Colors.white,
      errorCorrectionLevel: QrErrorCorrectLevel.M,
    );
  }
}
```

**Usage:**
```dart
PaymentRequestQR(
  phoneNumber: '+2250701234567',
  amount: 50.00,
  note: 'Lunch payment',
)
```

### Receive Money QR

```dart
class ReceiveMoneyQR extends ConsumerWidget {
  final double? requestedAmount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    final qrData = Uri(
      scheme: 'joonapay',
      path: 'send',
      queryParameters: {
        'to': user.phoneNumber,
        if (requestedAmount != null) 'amount': requestedAmount.toString(),
      },
    ).toString();

    return QrImageView(
      data: qrData,
      version: QrVersions.auto,
      size: 280,
      embeddedImage: const AssetImage('assets/logo.png'),
      embeddedImageStyle: QrEmbeddedImageStyle(
        size: const Size(60, 60),
      ),
    );
  }
}
```

### Payment Link QR

```dart
class PaymentLinkQR extends StatelessWidget {
  final String linkCode;

  String get qrData => 'joonapay://pay/$linkCode';

  // Or use universal link for better compatibility
  String get universalLinkData => 'https://app.joonapay.com/pay/$linkCode';

  @override
  Widget build(BuildContext context) {
    return QrImageView(
      data: universalLinkData, // Use universal link for web fallback
      version: QrVersions.auto,
      size: 280,
    );
  }
}
```

### QR Code Styling

```dart
QrImageView(
  data: qrData,
  version: QrVersions.auto,
  size: 280,
  // JoonaPay brand colors
  eyeStyle: const QrEyeStyle(
    eyeShape: QrEyeShape.square,
    color: Color(0xFFD4AF37), // Gold
  ),
  dataModuleStyle: const QrDataModuleStyle(
    dataModuleShape: QrDataModuleShape.square,
    color: Color(0xFF1C1C1E), // Obsidian
  ),
  embeddedImage: const AssetImage('assets/logo_qr.png'),
  embeddedImageStyle: QrEmbeddedImageStyle(
    size: const Size(60, 60),
  ),
)
```

---

## Dynamic Links Alternative (Optional)

### Firebase Dynamic Links (Deprecated)

Firebase Dynamic Links is being shut down. Do NOT use.

### Branch.io Alternative

**Benefits:**
- Cross-platform attribution
- Deferred deep linking (install then open link)
- Analytics and conversion tracking
- A/B testing for link destinations

**Setup:**
```yaml
# pubspec.yaml
dependencies:
  flutter_branch_sdk: ^7.0.0
```

**Configuration:**
```dart
// Initialize in main.dart
FlutterBranchSdk.init(
  enableLogging: false,
  disableTracking: false,
);

// Listen to deep links
StreamSubscription<Map>? streamSubscription;
streamSubscription = FlutterBranchSdk.listSession().listen((data) {
  if (data.containsKey('+clicked_branch_link')) {
    final deepLinkPath = data['~referring_link'];
    _handleBranchDeepLink(deepLinkPath);
  }
});
```

**Create Branch Link:**
```dart
final buo = BranchUniversalObject(
  canonicalIdentifier: 'payment/ABCD1234',
  title: 'Pay Invoice #123',
  contentDescription: 'Payment request for \$50.00',
  imageUrl: 'https://app.joonapay.com/og-image.png',
);

final lp = BranchLinkProperties(
  channel: 'sms',
  feature: 'payment_request',
);

final response = await FlutterBranchSdk.getShortUrl(
  buo: buo,
  linkProperties: lp,
);

final shortUrl = response.success; // https://joonapay.app.link/ABCD1234
```

**Note:** Branch.io requires account setup at https://branch.io

---

## Web Fallback

### Landing Page Template

When app is not installed, redirect to web page:

```html
<!DOCTYPE html>
<html>
<head>
  <title>JoonaPay - Download App</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta property="og:title" content="JoonaPay Payment">
  <meta property="og:description" content="Download JoonaPay to complete this payment">
  <meta property="og:image" content="https://app.joonapay.com/og-image.png">
</head>
<body>
  <div class="container">
    <h1>Download JoonaPay</h1>
    <p>Install the app to complete this payment</p>

    <div class="buttons">
      <a href="https://apps.apple.com/app/joonapay/id123456789">
        <img src="/app-store-badge.svg" alt="Download on App Store">
      </a>
      <a href="https://play.google.com/store/apps/details?id=com.joonapay.wallet">
        <img src="/google-play-badge.png" alt="Get it on Google Play">
      </a>
    </div>

    <script>
      // Try to open app, fallback to download
      const deepLink = 'joonapay://pay/ABCD1234';
      window.location.href = deepLink;

      setTimeout(() => {
        // If still on page after 2s, app not installed
        // Show download buttons
      }, 2000);
    </script>
  </div>
</body>
</html>
```

---

## Monitoring & Analytics

### Track Deep Link Opens

```dart
// Log deep link event
Analytics.logEvent(
  'deep_link_opened',
  parameters: {
    'path': uri.path,
    'source': uri.queryParameters['utm_source'] ?? 'unknown',
    'campaign': uri.queryParameters['utm_campaign'] ?? 'unknown',
  },
);
```

### Metrics to Monitor

- Deep link open rate
- Conversion rate (link opened → action completed)
- Most popular deep link paths
- Failed deep link attempts
- Authentication required rate
- Platform distribution (iOS vs Android)
- Universal Link vs Custom Scheme usage

---

## Troubleshooting

### iOS Issues

**Universal Links not working:**
1. Verify AASA file is accessible at `https://app.joonapay.com/.well-known/apple-app-site-association`
2. Check Team ID matches
3. Ensure no redirects on AASA URL
4. Verify Associated Domains capability added
5. Delete and reinstall app
6. Test on device (not simulator)

**Custom scheme not working:**
1. Check Info.plist has CFBundleURLSchemes
2. Verify scheme is lowercase
3. Restart app

### Android Issues

**App Links not working:**
1. Verify assetlinks.json accessible
2. Check SHA256 fingerprint matches
3. Ensure package name matches
4. Run verification command: `adb shell pm verify-app-links --re-verify com.joonapay.wallet`
5. Check intent filter has `android:autoVerify="true"`

**Custom scheme not working:**
1. Verify intent filter in AndroidManifest.xml
2. Check scheme is lowercase
3. Reinstall app

### General Issues

**Deep link not routing correctly:**
1. Check router configuration
2. Verify path matches exactly
3. Ensure authentication state is correct
4. Check feature flags if route is gated

**Parameters not parsing:**
1. URL encode special characters
2. Verify parameter names match
3. Check URI parsing logic

---

## Implementation Checklist

### Backend Requirements

- [ ] AASA file hosted at `/.well-known/apple-app-site-association`
- [ ] assetlinks.json hosted at `/.well-known/assetlinks.json`
- [ ] Both files return `Content-Type: application/json`
- [ ] No redirects on .well-known URLs
- [ ] HTTPS enabled on app.joonapay.com
- [ ] SSL certificate valid

### Mobile App

- [ ] Custom scheme registered (iOS Info.plist + Android Manifest)
- [ ] Universal Links configured (iOS Associated Domains)
- [ ] App Links configured (Android intent filter with autoVerify)
- [ ] Deep link handler implemented
- [ ] Input validation for all parameters
- [ ] Authentication checks on protected routes
- [ ] Authorization checks for user-specific content
- [ ] Error handling for invalid/expired links
- [ ] Analytics tracking for deep link opens
- [ ] QR code generation for payment requests
- [ ] QR code scanner for reading deep links

### Testing

- [ ] Test all deep link patterns on iOS
- [ ] Test all deep link patterns on Android
- [ ] Test from cold start
- [ ] Test from background
- [ ] Test from terminated state
- [ ] Test authentication flow
- [ ] Test invalid parameters
- [ ] Test expired links
- [ ] Test unauthorized access
- [ ] Test web fallback (app not installed)

### Documentation

- [ ] Internal developer guide (this file)
- [ ] Marketing team URL guide
- [ ] QR code generation guide
- [ ] Security review completed
- [ ] Privacy review completed

---

## Support & References

### Official Documentation

- [Apple Universal Links](https://developer.apple.com/ios/universal-links/)
- [Android App Links](https://developer.android.com/training/app-links)
- [Flutter Deep Linking](https://docs.flutter.dev/ui/navigation/deep-linking)
- [GoRouter Deep Linking](https://pub.dev/documentation/go_router/latest/topics/Deep%20linking-topic.html)

### Tools

- [Apple AASA Validator](https://branch.io/resources/aasa-validator/)
- [Android Asset Links Tester](https://developers.google.com/digital-asset-links/tools/generator)
- [QR Code Generator](https://www.qr-code-generator.com/)

---

**Last Updated:** 2026-01-29
**Version:** 1.0.0
**Author:** Claude Code (Anthropic)
