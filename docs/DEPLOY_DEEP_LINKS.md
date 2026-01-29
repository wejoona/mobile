# Deploy Deep Links - Setup Guide

## Backend Deployment

### 1. Apple App Site Association (iOS Universal Links)

**File:** `apple-app-site-association` (NO file extension)

**Location:** Host at both:
- `https://app.joonapay.com/.well-known/apple-app-site-association`
- `https://app.joonapay.com/apple-app-site-association` (fallback)

**Steps:**

1. Get your Apple Team ID:
   - Go to https://developer.apple.com/account
   - Sign in
   - Go to Membership
   - Copy your Team ID (10-character string)

2. Update the file:
   ```bash
   # Replace TEAM_ID with your actual Team ID
   sed -i '' 's/TEAM_ID/ABC1234XYZ/g' docs/apple-app-site-association
   ```

3. Upload to your server:
   ```bash
   # Example with nginx
   sudo mkdir -p /var/www/app.joonapay.com/.well-known
   sudo cp docs/apple-app-site-association /var/www/app.joonapay.com/.well-known/
   sudo cp docs/apple-app-site-association /var/www/app.joonapay.com/
   ```

4. Configure nginx:
   ```nginx
   # /etc/nginx/sites-available/app.joonapay.com
   server {
       listen 443 ssl http2;
       server_name app.joonapay.com;

       ssl_certificate /path/to/cert.pem;
       ssl_certificate_key /path/to/key.pem;

       root /var/www/app.joonapay.com;

       # AASA file
       location /.well-known/apple-app-site-association {
           default_type application/json;
           add_header Access-Control-Allow-Origin *;
           return 200 '{"applinks": {"apps": [], "details": [{"appID": "ABC1234XYZ.com.joonapay.wallet", "paths": ["/send", "/send/*", "/receive", "/transaction/*", "/transactions/*", "/kyc", "/kyc/*", "/settings", "/settings/*", "/pay/*", "/payment-link/*", "/deposit", "/deposit/*", "/withdraw", "/bills", "/bills/*", "/airtime", "/scan", "/scan-to-pay", "/referrals", "/notifications", "/notifications/*", "/home", "/wallet"]}]}, "webcredentials": {"apps": ["ABC1234XYZ.com.joonapay.wallet"]}}';
       }

       location /apple-app-site-association {
           default_type application/json;
           add_header Access-Control-Allow-Origin *;
           return 200 '{"applinks": {"apps": [], "details": [{"appID": "ABC1234XYZ.com.joonapay.wallet", "paths": ["/send", "/send/*", "/receive", "/transaction/*", "/transactions/*", "/kyc", "/kyc/*", "/settings", "/settings/*", "/pay/*", "/payment-link/*", "/deposit", "/deposit/*", "/withdraw", "/bills", "/bills/*", "/airtime", "/scan", "/scan-to-pay", "/referrals", "/notifications", "/notifications/*", "/home", "/wallet"]}]}, "webcredentials": {"apps": ["ABC1234XYZ.com.joonapay.wallet"]}}';
       }
   }
   ```

5. Test the file:
   ```bash
   curl -I https://app.joonapay.com/.well-known/apple-app-site-association
   # Should return:
   # HTTP/2 200
   # content-type: application/json
   ```

6. Validate with Apple:
   - Go to https://branch.io/resources/aasa-validator/
   - Enter: `https://app.joonapay.com`
   - Verify no errors

**Important:**
- NO redirects allowed
- Must be HTTPS
- Must return `Content-Type: application/json`
- File must be accessible without authentication

---

### 2. Digital Asset Links (Android App Links)

**File:** `assetlinks.json`

**Location:** `https://app.joonapay.com/.well-known/assetlinks.json`

**Steps:**

1. Get your SHA256 fingerprint:

   ```bash
   # For debug build (development)
   keytool -list -v -keystore ~/.android/debug.keystore \
     -alias androiddebugkey \
     -storepass android \
     -keypass android

   # For release build (production)
   keytool -list -v -keystore /path/to/release.keystore \
     -alias your-key-alias
   ```

   Copy the SHA256 fingerprint (example: `14:6D:E9:83:C5:73:06:50:D8:EE:B9:95:2F:34:FC:64:16:A0:83:42:E6:1D:BE:A8:8A:04:96:B2:3F:CF:44:E5`)

2. Update assetlinks.json:
   ```bash
   # Replace SHA256_FINGERPRINT_HERE with your fingerprint
   # KEEP the colons in the fingerprint
   ```

   Example:
   ```json
   [
     {
       "relation": ["delegate_permission/common.handle_all_urls"],
       "target": {
         "namespace": "android_app",
         "package_name": "com.joonapay.wallet",
         "sha256_cert_fingerprints": [
           "14:6D:E9:83:C5:73:06:50:D8:EE:B9:95:2F:34:FC:64:16:A0:83:42:E6:1D:BE:A8:8A:04:96:B2:3F:CF:44:E5"
         ]
       }
     }
   ]
   ```

3. Upload to server:
   ```bash
   sudo mkdir -p /var/www/app.joonapay.com/.well-known
   sudo cp docs/assetlinks.json /var/www/app.joonapay.com/.well-known/
   ```

4. Configure nginx:
   ```nginx
   location /.well-known/assetlinks.json {
       default_type application/json;
       add_header Access-Control-Allow-Origin *;
   }
   ```

5. Test the file:
   ```bash
   curl https://app.joonapay.com/.well-known/assetlinks.json
   # Should return the JSON with your fingerprint
   ```

6. Validate with Google:
   - Go to https://digitalassetlinks.googleapis.com/v1/statements:list?source.web.site=https://app.joonapay.com&relation=delegate_permission/common.handle_all_urls
   - Verify your app appears in the response

---

## iOS App Configuration

### 1. Add Associated Domains Capability

In Xcode:

1. Open `ios/Runner.xcworkspace`
2. Select the `Runner` target
3. Go to "Signing & Capabilities" tab
4. Click "+ Capability"
5. Search for "Associated Domains"
6. Add domain: `applinks:app.joonapay.com`

**OR** manually edit `ios/Runner/Runner.entitlements`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.associated-domains</key>
    <array>
        <string>applinks:app.joonapay.com</string>
    </array>
</dict>
</plist>
```

### 2. Verify Info.plist

Already configured in `ios/Runner/Info.plist`:

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

---

## Android App Configuration

### 1. Verify AndroidManifest.xml

Already configured in `android/app/src/main/AndroidManifest.xml`:

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

### 2. Verify Package Name

Ensure `android/app/build.gradle` has:

```gradle
android {
    defaultConfig {
        applicationId "com.joonapay.wallet"
    }
}
```

---

## Testing

### iOS Testing

1. **Safari (Device):**
   ```
   Open Safari → Type: joonapay://send → Tap "Open"
   ```

2. **Universal Links (Device):**
   ```
   Open Safari → Type: https://app.joonapay.com/send → Should open app
   ```

3. **Simulator:**
   ```bash
   xcrun simctl openurl booted "joonapay://send?to=%2B2250701234567"
   xcrun simctl openurl booted "https://app.joonapay.com/send"
   ```

4. **Notes App:**
   - Open Notes
   - Type: `joonapay://send`
   - Tap the link
   - App should open

### Android Testing

1. **ADB Custom Scheme:**
   ```bash
   adb shell am start -W -a android.intent.action.VIEW \
     -d "joonapay://send?to=%2B2250701234567&amount=50.00" \
     com.joonapay.wallet
   ```

2. **ADB App Link:**
   ```bash
   adb shell am start -W -a android.intent.action.VIEW \
     -d "https://app.joonapay.com/send?to=%2B2250701234567" \
     com.joonapay.wallet
   ```

3. **Verify App Links:**
   ```bash
   adb shell pm get-app-links com.joonapay.wallet
   # Should show: verified
   ```

4. **Re-verify if needed:**
   ```bash
   adb shell pm set-app-links --package com.joonapay.wallet 0 app.joonapay.com
   adb shell pm verify-app-links --re-verify com.joonapay.wallet
   ```

---

## Troubleshooting

### iOS Universal Links Not Working

**Problem:** Links open in Safari instead of app

**Solutions:**

1. Delete app and reinstall (Universal Links cache on install)
2. Verify AASA file accessible:
   ```bash
   curl -I https://app.joonapay.com/.well-known/apple-app-site-association
   ```
3. Check Team ID matches in AASA and Xcode
4. Ensure no redirects on AASA URL
5. Test on real device (simulator caching issues)
6. Verify Associated Domains capability added
7. Long-press link in Safari → "Open in JoonaPay" should appear

### Android App Links Not Working

**Problem:** Links open in browser instead of app

**Solutions:**

1. Verify assetlinks.json accessible:
   ```bash
   curl https://app.joonapay.com/.well-known/assetlinks.json
   ```
2. Check SHA256 fingerprint matches:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey
   ```
3. Clear app data and reinstall
4. Force re-verification:
   ```bash
   adb shell pm set-app-links --package com.joonapay.wallet 0 app.joonapay.com
   adb shell pm verify-app-links --re-verify com.joonapay.wallet
   ```
5. Check verification status:
   ```bash
   adb shell pm get-app-links com.joonapay.wallet
   ```

### Custom Scheme Not Working

**Problem:** `joonapay://` links don't open app

**iOS Solutions:**
1. Verify CFBundleURLSchemes in Info.plist
2. Ensure scheme is lowercase
3. Reinstall app

**Android Solutions:**
1. Verify intent-filter in AndroidManifest.xml
2. Check scheme is lowercase
3. Reinstall app

---

## Production Checklist

### Backend
- [ ] AASA file deployed to `/.well-known/apple-app-site-association`
- [ ] AASA file returns `Content-Type: application/json`
- [ ] AASA file accessible via HTTPS (no redirects)
- [ ] AASA file validated with https://branch.io/resources/aasa-validator/
- [ ] assetlinks.json deployed to `/.well-known/assetlinks.json`
- [ ] assetlinks.json has correct SHA256 fingerprint
- [ ] assetlinks.json validated via Google API
- [ ] Domain has valid SSL certificate

### iOS App
- [ ] Associated Domains capability added
- [ ] Domain added: `applinks:app.joonapay.com`
- [ ] CFBundleURLSchemes configured in Info.plist
- [ ] Tested on real device (not just simulator)
- [ ] Universal Links work from Safari
- [ ] Custom scheme works from Notes app

### Android App
- [ ] Intent filters configured in AndroidManifest.xml
- [ ] `android:autoVerify="true"` set
- [ ] Package name matches assetlinks.json
- [ ] SHA256 fingerprint matches release keystore
- [ ] Tested on real device
- [ ] App Links verified: `adb shell pm get-app-links`
- [ ] Custom scheme works from Chrome

### App Store / Play Store
- [ ] Associated Domains entitlement enabled (iOS)
- [ ] Privacy policy updated to mention deep linking
- [ ] App submission reviewed and approved
- [ ] Deep links tested in production build

---

## Maintenance

### Adding New Deep Link Paths

1. Update AASA file (iOS):
   ```json
   "paths": [
     "/existing/path",
     "/new/path/*"  // Add here
   ]
   ```

2. Re-deploy AASA file
3. Update `DeepLinkHandler` in `lib/core/deep_linking/deep_link_handler.dart`
4. No changes needed for Android (uses pathPrefix `/`)
5. Test new path on both platforms

### Monitoring

Track these metrics:
- Deep link open rate
- Failed deep link attempts
- Most popular paths
- Platform distribution (iOS/Android)
- Universal Link vs Custom Scheme usage

Use Firebase Analytics or your analytics platform.

---

**Last Updated:** 2026-01-29
