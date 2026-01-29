# Quick Build Commands Reference

## Production Builds

### 1. Play Store Release (Recommended)
```bash
flutter build appbundle --release
```
**Output:** `build/app/outputs/bundle/release/app-release.aab` (46 MB)
**Download size:** ~12-15 MB per device (Google Play optimizes automatically)

---

### 2. Direct APK Distribution (Split by Architecture)
```bash
flutter build apk --release --split-per-abi
```
**Outputs:**
- `app-armeabi-v7a-release.apk` (33.5 MB) - ARM 32-bit (older devices)
- `app-arm64-v8a-release.apk` (36.3 MB) - ARM 64-bit (95% of devices)
- `app-x86_64-release.apk` (38.8 MB) - Intel (rare, emulators only)

**Recommendation:** Distribute ARM64 APK for most users

---

### 3. Universal APK (Testing Only)
```bash
flutter build apk --release
```
**Output:** `app-release.apk` (~44 MB)
**Use case:** Testing on unknown devices, QA

---

## Analysis & Debugging

### Size Analysis
```bash
flutter build apk --release --target-platform android-arm64 --analyze-size
```
**Opens:** DevTools with size breakdown
**Shows:** Package sizes, AOT code, assets

### View Existing Analysis
```bash
dart devtools --appSizeBase=/Users/macbook/.flutter-devtools/apk-code-size-analysis_01.json
```

### Dependency Audit
```bash
flutter pub deps --style=tree
flutter pub outdated
```

---

## iOS Builds

### Release IPA
```bash
flutter build ipa --release
```
**Output:** `build/ios/archive/Runner.xcarchive`

### App Store Upload
```bash
flutter build ipa --release --export-method app-store
```

---

## Clean Builds

### Full Clean
```bash
flutter clean
flutter pub get
flutter build apk --release --split-per-abi
```

### Gradle Clean Only
```bash
cd android && ./gradlew clean && cd ..
flutter build apk --release --split-per-abi
```

---

## Development Builds

### Debug APK
```bash
flutter build apk --debug
```

### Profile APK (Performance Testing)
```bash
flutter build apk --profile
```

---

## Build Locations

### Android
```
build/app/outputs/
├── flutter-apk/          # APK files
│   ├── app-armeabi-v7a-release.apk
│   ├── app-arm64-v8a-release.apk
│   ├── app-x86_64-release.apk
│   └── app-release.apk
└── bundle/release/       # App Bundle
    └── app-release.aab
```

### iOS
```
build/ios/
├── archive/              # .xcarchive
├── ipa/                  # .ipa files
└── Release-iphoneos/     # .app bundle
```

---

## Signing (Production)

### Android Keystore Setup
Create `android/key.properties`:
```properties
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=upload
storeFile=<path-to-keystore.jks>
```

**NEVER commit this file to version control!**

### iOS Certificates
Managed via Xcode:
1. Open `ios/Runner.xcworkspace`
2. Runner → Signing & Capabilities
3. Select Team and provisioning profile

---

## CI/CD Commands

### GitHub Actions / Fastlane
```bash
# Install dependencies
flutter pub get

# Run tests
flutter test

# Build and sign
flutter build appbundle --release

# Upload to Play Console (requires Fastlane)
cd android && fastlane deploy
```

---

## Troubleshooting

### "Gradle task failed"
```bash
cd android && ./gradlew clean
cd .. && flutter clean
flutter pub get
flutter build apk --release --split-per-abi
```

### "Missing key.properties"
**For local testing:** Build will use debug signing (OK for testing)
**For production:** Create `android/key.properties` with keystore info

### "R8/ProGuard errors"
Check `/Users/macbook/JoonaPay/USDC-Wallet/mobile/android/app/proguard-rules.pro`
Add keep rules for problematic packages

### "Split APK conflicts with App Bundle"
This is expected. Build separately:
- For Play Store: `flutter build appbundle`
- For direct download: `flutter build apk --split-per-abi`

---

## Size Comparison

| Build Type | Size | Use Case |
|------------|------|----------|
| App Bundle | 46 MB → 12 MB download | Play Store (best) |
| ARM64 APK | 36.3 MB | Direct download (modern) |
| ARM32 APK | 33.5 MB | Direct download (old devices) |
| Universal APK | 44.8 MB | Testing/QA only |

---

## Quick Tips

1. **Always use App Bundle for Play Store** - Automatic size optimization
2. **Split APKs for sideloading** - Users get smaller files
3. **ARM64 covers 95% of devices** - Prioritize this
4. **Don't distribute universal APKs** - Unnecessarily large
5. **Clean builds if errors persist** - Gradle cache issues are common

---

*Working directory: /Users/macbook/JoonaPay/USDC-Wallet/mobile*
*Updated: 2026-01-29*
