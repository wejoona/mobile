# Mobile App Dependency Security Audit Report

**Project:** JoonaPay USDC Wallet - Mobile App
**Audit Date:** 2026-01-30
**Auditor:** Security Audit (Automated)
**Flutter SDK:** ^3.10.7
**Dart SDK:** ^3.10.7

---

## Executive Summary

This report documents the security analysis of 46 direct dependencies and their transitive dependencies in the JoonaPay mobile application. The audit covers known vulnerabilities, security best practices, and recommendations for dependency management.

**Risk Distribution:**
| Severity | Count |
|----------|-------|
| Critical | 0 |
| High | 2 |
| Medium | 4 |
| Low | 6 |
| Informational | 5 |

---

## Critical Findings

No critical vulnerabilities identified in current dependency versions.

---

## High Severity Findings

### H-1: flutter_secure_storage (v10.0.0) - Platform-Specific Security Concerns

**Package:** `flutter_secure_storage: ^10.0.0`
**Locked Version:** 10.0.0
**OWASP Reference:** M9:2024 - Insecure Data Storage

**Description:**
The flutter_secure_storage package uses platform-specific secure storage (Keychain on iOS, EncryptedSharedPreferences on Android). However, default configurations may not use hardware-backed keystores on all Android devices.

**Risks:**
- On rooted/jailbroken devices, stored secrets may be extractable
- Android devices without hardware security modules store keys in software
- Web platform uses localStorage which is NOT secure

**Recommendations:**
1. Explicitly configure `AndroidOptions` to require hardware-backed storage:
   ```dart
   final storage = FlutterSecureStorage(
     aOptions: AndroidOptions(
       encryptedSharedPreferences: true,
       keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
       storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
     ),
   );
   ```
2. Implement root/jailbreak detection before storing sensitive data
3. Do not deploy to web platform with secure storage for sensitive data

---

### H-2: sms_autofill (v2.4.1) - SMS Interception Risks

**Package:** `sms_autofill: ^2.4.0`
**Locked Version:** 2.4.1
**OWASP Reference:** M3:2024 - Insecure Communication

**Description:**
SMS-based OTP is vulnerable to SIM-swapping attacks and SS7 protocol exploits. This package reads SMS messages which requires `READ_SMS` permission on Android, expanding the attack surface.

**Risks:**
- SIM-swapping attacks can intercept OTPs
- Malware with SMS permissions can read OTPs
- SS7 vulnerabilities enable remote SMS interception

**Recommendations:**
1. Implement time-based TOTP as an alternative authentication method
2. Support push-based authentication for high-risk transactions
3. Use the package only for convenience, not as sole authentication factor
4. Consider using SMS Retriever API (does not require SMS permission):
   ```dart
   // Prefer SmsRetriever over broad SMS permissions
   final smsRetriever = SmsRetrieverApi();
   ```

---

## Medium Severity Findings

### M-1: local_auth (v2.3.0) - Biometric Bypass Considerations

**Package:** `local_auth: ^2.3.0`
**Locked Version:** 2.3.0
**OWASP Reference:** M8:2024 - Security Misconfiguration

**Description:**
Biometric authentication can be bypassed on compromised devices. The package relies on OS-level biometric APIs which may be spoofed on rooted/jailbroken devices.

**Recommendations:**
1. Never use biometrics as sole authentication factor
2. Bind biometric authentication to cryptographic operations:
   ```dart
   final canCheck = await localAuth.canCheckBiometrics;
   final deviceSupportsSecureBiometrics = await localAuth.isDeviceSupported();
   // Require both checks
   ```
3. Implement device integrity checks before biometric prompts

---

### M-2: url_launcher (v6.3.0) - Deep Link Injection

**Package:** `url_launcher: ^6.3.0`
**Locked Version:** 6.3.2
**OWASP Reference:** M1:2024 - Improper Credential Usage

**Description:**
Opening arbitrary URLs can lead to phishing attacks if user-supplied URLs are not validated.

**Recommendations:**
1. Validate URL schemes before launching:
   ```dart
   bool isAllowedUrl(String url) {
     final uri = Uri.tryParse(url);
     if (uri == null) return false;
     return uri.scheme == 'https' || uri.scheme == 'mailto';
   }
   ```
2. Warn users before opening external links
3. Maintain allowlist of trusted domains

---

### M-3: dio (v5.9.0) - HTTP Security Configuration Required

**Package:** `dio: ^5.9.0`
**Locked Version:** 5.9.0
**OWASP Reference:** M5:2024 - Insecure Communication

**Description:**
HTTP client requires proper configuration for certificate pinning, TLS verification, and timeout handling.

**Recommendations:**
1. Implement certificate pinning:
   ```dart
   final dio = Dio();
   (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
     final client = HttpClient();
     client.badCertificateCallback = (cert, host, port) {
       return expectedFingerprint == sha256.convert(cert.der).toString();
     };
     return client;
   };
   ```
2. Set reasonable timeouts to prevent resource exhaustion:
   ```dart
   dio.options.connectTimeout = Duration(seconds: 10);
   dio.options.receiveTimeout = Duration(seconds: 30);
   ```
3. Disable redirects for sensitive endpoints

---

### M-4: firebase_messaging (v15.2.10) - Push Token Security

**Package:** `firebase_messaging: ^15.1.6`
**Locked Version:** 15.2.10
**OWASP Reference:** M9:2024 - Insecure Data Storage

**Description:**
FCM tokens should be treated as sensitive credentials. Token theft enables push notification spoofing.

**Recommendations:**
1. Store FCM tokens securely (not in SharedPreferences)
2. Rotate tokens periodically
3. Implement token validation on server side
4. Do not log FCM tokens

---

## Low Severity Findings

### L-1: shared_preferences (v2.5.4) - Unencrypted Storage

**Package:** `shared_preferences: ^2.5.3`
**Locked Version:** 2.5.4
**OWASP Reference:** M9:2024 - Insecure Data Storage

**Description:**
SharedPreferences stores data in plaintext XML on Android and plist on iOS.

**Recommendations:**
- Never store sensitive data (tokens, PII, financial data)
- Use only for non-sensitive preferences
- For sensitive data, use `flutter_secure_storage`

---

### L-2: image_picker (v1.2.1) - File Permission Scope

**Package:** `image_picker: ^1.0.7`
**Locked Version:** 1.2.1

**Description:**
Photo library access exposes potential privacy concerns and selected images may contain EXIF metadata.

**Recommendations:**
1. Strip EXIF data before upload
2. Request permissions only when needed
3. Clearly communicate why photo access is required

---

### L-3: flutter_contacts (v1.1.9+2) - PII Exposure

**Package:** `flutter_contacts: ^1.1.9+2`
**Locked Version:** 1.1.9+2

**Description:**
Contact access exposes user PII. Data must be handled according to privacy regulations.

**Recommendations:**
1. Minimize contact data accessed (name/phone only)
2. Do not upload full contact lists to server
3. Hash phone numbers for matching
4. Clear contact cache on logout

---

### L-4: mobile_scanner (v7.1.4) - QR Code Injection

**Package:** `mobile_scanner: ^7.0.0`
**Locked Version:** 7.1.4

**Description:**
QR codes can contain malicious URLs or commands.

**Recommendations:**
1. Validate QR content format before processing
2. Implement allowlist for expected QR prefixes
3. Sanitize all QR input before use

---

### L-5: cached_network_image (v3.4.1) - Cache Security

**Package:** `cached_network_image: ^3.4.1`
**Locked Version:** 3.4.1

**Description:**
Image cache may persist sensitive images to disk.

**Recommendations:**
1. Clear cache on logout for sensitive content
2. Do not cache images containing PII
3. Set appropriate cache expiration

---

### L-6: pdf (v3.11.3) - Generated Document Security

**Package:** `pdf: ^3.10.0`
**Locked Version:** 3.11.3

**Description:**
Generated PDFs containing transaction data should be handled securely.

**Recommendations:**
1. Do not store generated PDFs persistently
2. Clear temp files after sharing
3. Consider watermarking with user ID

---

## Informational Findings

### I-1: crypto (v3.0.7) - Adequate for Hashing

**Package:** `crypto: ^3.0.5`
**Locked Version:** 3.0.7

**Status:** ACCEPTABLE for SHA-256/SHA-512 hashing operations. Not suitable for encryption - use pointycastle for that.

---

### I-2: Firebase Suite - Third-Party Data Processing

**Packages:**
- `firebase_core: 3.15.2`
- `firebase_messaging: 15.2.10`
- `firebase_analytics: 11.6.0`
- `firebase_crashlytics: 4.3.10`

**Status:** Google processes telemetry data. Ensure GDPR/privacy compliance documentation is in place. Consider user consent for analytics.

---

### I-3: Transitive Dependencies Count

**Total Packages:** 243 (from pubspec.lock)
**Direct Dependencies:** 46
**Transitive Dependencies:** 197

**Note:** Large transitive dependency trees increase supply chain risk. Consider periodic audits of transitive dependencies.

---

### I-4: Outdated Dependencies Check

The following packages may have newer versions available (based on versions locked in pubspec.lock vs pubspec.yaml constraints):

| Package | Declared | Locked | Status |
|---------|----------|--------|--------|
| confetti | ^0.7.0 | 0.7.0 | Current |
| go_router | ^17.0.1 | 17.0.1 | Current |
| timeago | ^3.7.0 | 3.7.1 | Minor Update Available |

**Recommendation:** Run `flutter pub outdated` regularly and update dependencies with security patches.

---

### I-5: Dev Dependencies

**Package:** `flutter_lints: ^6.0.0`
**Locked Version:** 6.0.0

**Status:** Good - static analysis helps catch security issues early.

---

## Dependency Supply Chain Recommendations

### 1. Enable Dart Pub Verification
All packages are sourced from `https://pub.dev`. Verify package authenticity:
```yaml
# Check publisher verification status on pub.dev
```

### 2. Pin Exact Versions in Production
Consider pinning exact versions instead of caret ranges for production builds:
```yaml
dio: 5.9.0  # Instead of ^5.9.0
```

### 3. Regular Audit Schedule
- **Weekly:** Run `flutter pub outdated`
- **Monthly:** Review security advisories for all dependencies
- **Quarterly:** Full dependency audit
- **On Release:** Verify no new CVEs in locked versions

### 4. Automated Scanning Integration
Consider integrating:
- Dependabot or Renovate for automated updates
- SAST tools in CI/CD pipeline
- OSV (Open Source Vulnerabilities) database checks

---

## Android-Specific Security Considerations

### Required AndroidManifest Permissions Review

Based on dependencies, these permissions are likely required:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_CONTACTS" />
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
<uses-permission android:name="android.permission.RECEIVE_SMS" /> <!-- Review if needed -->
```

**Recommendation:** Audit AndroidManifest.xml to ensure only necessary permissions are declared.

---

## iOS-Specific Security Considerations

### Required Info.plist Keys Review

Based on dependencies:
```xml
<key>NSCameraUsageDescription</key>
<key>NSContactsUsageDescription</key>
<key>NSFaceIDUsageDescription</key>
<key>NSPhotoLibraryUsageDescription</key>
```

**Recommendation:** Provide clear, user-friendly descriptions for each permission.

---

## Action Items Summary

| Priority | Action | Owner | Due |
|----------|--------|-------|-----|
| High | Configure flutter_secure_storage with hardware-backed options | Dev Team | ASAP |
| High | Implement certificate pinning in Dio | Dev Team | Sprint |
| Medium | Add TOTP as alternative to SMS OTP | Product | Roadmap |
| Medium | Validate all URLs before launching | Dev Team | Sprint |
| Low | Strip EXIF from uploaded images | Dev Team | Sprint |
| Low | Implement contact data minimization | Dev Team | Sprint |

---

## References

- OWASP Mobile Top 10 2024: https://owasp.org/www-project-mobile-top-10/
- Flutter Security Best Practices: https://docs.flutter.dev/security
- Dart Package Security: https://dart.dev/tools/pub/security-advisories
- OSV Database: https://osv.dev/

---

*This report should be reviewed by the security team and updated as dependencies change.*
