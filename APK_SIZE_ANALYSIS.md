# APK Size Optimization Report
## JoonaPay USDC Wallet Mobile App

**Generated:** 2026-01-30
**Analysis Date:** January 2026
**Flutter Version:** 3.38.8
**Target Platform:** Android

---

## Executive Summary

| Metric | Value | Status |
|--------|-------|--------|
| **Release APK (arm64-v8a)** | 35 MB | Good |
| **Release APK (armeabi-v7a)** | 32 MB | Good |
| **Release AAB** | 46 MB | Acceptable |
| **Uncompressed Size** | 80.5 MB | 2.3x compression ratio |
| **Dart Code** | 10.3 MB (572 files) | Requires optimization |
| **Mock Code** | 443 KB (29 files) | Should be tree-shaken |
| **Localization** | 524 KB (4 languages) | Well-optimized |
| **Dependencies** | 48 packages | Some unused/heavy |

**Overall Assessment:** App size is reasonable but has 20-30% optimization potential through dependency cleanup, asset optimization, and better tree-shaking.

---

## 1. Current Size Breakdown

### 1.1 APK Component Analysis (arm64-v8a)

| Component | Size | % of APK | Compressed | Notes |
|-----------|------|----------|------------|-------|
| **Native Libraries** | | | | |
| `libapp.so` (Dart AOT) | 14.8 MB | 42.3% | 18.4% compressed | Flutter app code |
| `libflutter.so` (Engine) | 11.1 MB | 31.7% | 11.0% compressed | Flutter framework |
| `libbarhopper_v3.so` | 4.9 MB | 14.0% | 4.7% compressed | ML Kit dependency |
| Other `.so` files | 44 KB | 0.1% | | Utilities |
| **Java/Kotlin** | | | | |
| `classes.dex` | 8.8 MB | 25.1% | 8.4% compressed | Android/plugin code |
| `classes2.dex` | 214 KB | 0.6% | | Additional classes |
| **ML Models** | | | | |
| Barcode scanner models | 880 KB | 2.5% | | QR/barcode detection |
| **Flutter Assets** | | | | |
| Material/Cupertino icons | 37 KB | 0.1% | | System fonts |
| Shaders | 39 KB | 0.1% | | Visual effects |
| NOTICES | 119 KB | 0.3% | | License files |
| **Resources** | | | | |
| Android resources | ~1 MB | ~3% | | Drawables, strings |

### 1.2 Architecture Comparison

| Architecture | APK Size | Use Case |
|-------------|----------|----------|
| arm64-v8a | 35 MB | Modern Android (64-bit) |
| armeabi-v7a | 32 MB | Older Android (32-bit) |
| x86_64 | 37 MB | Emulators only |

**Note:** Individual APKs are 24-29% smaller than the universal AAB due to ABI splitting.

### 1.3 Source Code Breakdown

| Category | Size | Files | Lines Est. | Notes |
|----------|------|-------|------------|-------|
| **Production Code** | 9.9 MB | 543 | ~150,000 | Feature implementations |
| **Mock Code** | 443 KB | 29 | ~7,000 | Debug-only, should tree-shake |
| **Test Code** | N/A | N/A | N/A | Not included in release |
| **Generated L10n** | ~200 KB | 4 | N/A | 4 languages (en, fr, ar, pt) |

---

## 2. Unused Asset Identification

### 2.1 Image Assets

**Current Status:** NO custom image assets found in `assets/` directory.

**Analysis:**
- App uses Google Fonts (downloaded at runtime)
- Icons from Material Icons and Cupertino Icons
- QR codes generated programmatically
- No bundled PNGs, JPGs, or SVGs in user-facing code

**Result:** No unused image assets to remove.

### 2.2 Unused Dependencies (High Confidence)

| Package | Size Impact | Usage | Recommendation |
|---------|-------------|-------|----------------|
| `flutter_svg` | ~200 KB | 0 imports found | **REMOVE** - No SVG usage detected |
| `confetti` | ~150 KB | 5 imports | Keep (used for success animations) |
| `flutter_widget_from_html_core` | ~300 KB | Low | Consider lightweight alternative |

### 2.3 Potentially Over-Engineered Dependencies

| Package | Size Impact | Usage Count | Notes |
|---------|-------------|-------------|-------|
| `google_fonts` | ~500 KB + runtime | 50 imports | Downloads fonts at runtime, consider bundling 1-2 fonts |
| `cached_network_image` | ~150 KB | 2 imports | Underutilized, consider standard Image.network |
| `pdf` | ~800 KB | 6 files | Heavy for receipt generation, consider alternatives |
| `fl_chart` | ~400 KB | 48 imports | Used extensively, keep |

### 2.4 ML Kit Barcode Models

**Current:** 880 KB bundled in APK

**Issue:** All 3 barcode models included:
- `barcode_ssd_mobilenet_v1_dmp25_quant.tflite` (390 KB)
- `oned_auto_regressor_mobile.tflite` (213 KB)
- `oned_feature_extractor_mobile.tflite` (277 KB)

**Recommendation:** Use dynamic model downloading for barcode scanning (saves ~880 KB initially).

---

## 3. Tree-Shaking Recommendations

### 3.1 Mock Code Elimination

**Issue:** 443 KB of mock code included in release builds.

**Current State:**
- 29 mock service files
- 86 `kDebugMode` checks in codebase
- Mock code should be tree-shaken in release builds

**Action Required:**
```dart
// Ensure mocks are conditionally imported
if (kDebugMode) {
  import 'mocks/mock_registry.dart';
}
```

**Expected Savings:** 400-450 KB

### 3.2 Unused Imports

**Analysis:** 38 unused imports detected via `flutter analyze`.

**Impact:** Minimal direct savings (<10 KB), but improves tree-shaking effectiveness.

**Action Required:**
```bash
flutter analyze --no-pub | grep "unused_import"
# Remove flagged imports
```

### 3.3 Firebase Optimization

**Current:** 4 Firebase packages included.

| Package | Usage | Notes |
|---------|-------|-------|
| `firebase_core` | 14 imports | Required base |
| `firebase_messaging` | High | Push notifications |
| `firebase_analytics` | Medium | User tracking |
| `firebase_crashlytics` | Medium | Error reporting |

**Recommendation:** Keep all (critical for production monitoring).

### 3.4 Icon Font Optimization

**Current:**
- Material Icons: 37 KB (full font)
- Cupertino Icons: <1 KB

**Issue:** Material Icons includes 1000+ icons, app likely uses <50.

**Action Required:**
```yaml
# In pubspec.yaml
flutter:
  uses-material-design: true
  fonts:
    - family: MaterialIcons
      fonts:
        - asset: fonts/MaterialIcons-Regular.otf
          # Use font subsetting tool to include only used icons
```

**Expected Savings:** 25-30 KB

### 3.5 Deferred Loading

**Current:** All features loaded at startup.

**Recommendation:** Implement deferred loading for large features:

```dart
// Example: Defer PDF generation
import 'package:pdf/pdf.dart' deferred as pdf;

Future<void> generateReceipt() async {
  await pdf.loadLibrary();
  // Generate receipt
}
```

**Targets for Deferred Loading:**
- PDF generation (800 KB)
- HTML rendering (300 KB)
- Camera/Image picker (combined 400 KB)

**Expected Savings:** 1-1.5 MB from initial load

---

## 4. Image Optimization Suggestions

### 4.1 App Icons

**Current:**
- Android: 5 density-specific PNGs (mipmap-*)
- iOS: 13 size-specific PNGs
- macOS: 6 sizes
- Web: 4 files

**Analysis:** Icons are platform-generated defaults.

**Recommendation:** Replace with optimized, branded icons using TinyPNG or ImageOptim.

**Expected Savings:** 50-100 KB across platforms

### 4.2 Splash Screens

**Current:**
- iOS: LaunchImage.png (3 densities)

**Recommendation:**
- Use native splash screen instead of image assets (Android 12+)
- Reduce iOS launch image size via ImageOptim

**Expected Savings:** 30-50 KB

### 4.3 Future Asset Guidelines

When adding image assets:

| Asset Type | Format | Max Size | Tool |
|------------|--------|----------|------|
| Icons | PNG | 50 KB | TinyPNG |
| Logos | SVG | 10 KB | SVGO |
| Photos | WebP | 100 KB | cwebp |
| Illustrations | PNG | 30 KB | ImageOptim |

**Avoid:**
- Uncompressed PNGs
- JPEGs for UI elements
- Oversized image dimensions
- Multiple density variants (use vector when possible)

---

## 5. Dependency Audit

### 5.1 High-Impact Dependencies

| Package | Estimated Size | Category | Priority |
|---------|----------------|----------|----------|
| `google_fonts` | 500 KB + runtime | UI | Medium - Bundle fonts |
| `pdf` | 800 KB | Features | High - Defer or replace |
| `flutter_widget_from_html_core` | 300 KB | Features | Medium - Consider alternatives |
| `camera` | 200 KB | Features | Low - Essential for KYC |
| `image_picker` | 150 KB | Features | Low - Essential for docs |
| `mobile_scanner` | Bundled models | Features | High - Dynamic download |
| `fl_chart` | 400 KB | Features | Low - Used extensively |

### 5.2 Dependencies to Remove

#### 5.2.1 flutter_svg (HIGH PRIORITY)

**Usage:** 0 imports found in codebase.

**Action:**
```yaml
# Remove from pubspec.yaml
# flutter_svg: ^2.2.3  # NOT USED
```

**Savings:** ~200 KB

**Note:** Already has SIZE OPTIMIZATION comment for shimmer removal.

#### 5.2.2 Consider Removing/Replacing

| Package | Replacement | Reason |
|---------|-------------|--------|
| `cached_network_image` | `Image.network` with custom cache | Only 2 uses, over-engineered |
| `flutter_widget_from_html_core` | Custom markdown or simple HTML | Heavy for terms/privacy display |

### 5.3 Dependencies to Optimize

#### 5.3.1 google_fonts

**Current:** Downloads fonts at runtime (network overhead).

**Recommendation:** Bundle 1-2 font families:

```yaml
flutter:
  fonts:
    - family: Inter
      fonts:
        - asset: fonts/Inter-Regular.ttf
        - asset: fonts/Inter-Bold.ttf
          weight: 700
```

**Trade-off:**
- Adds 200-300 KB to APK
- Removes runtime download
- Faster initial render
- Works offline

#### 5.3.2 mobile_scanner

**Current:** 880 KB ML models bundled.

**Recommendation:**
```yaml
# Configure dynamic model download
mobile_scanner:
  download_models_on_demand: true
```

**Savings:** 880 KB initial, downloads when QR feature used.

---

## 6. Build Configuration Optimizations

### 6.1 Current Optimizations (Already Enabled)

```gradle
// android/app/build.gradle.kts

✓ Code minification (minifyEnabled = true)
✓ Resource shrinking (shrinkResources = true)
✓ ProGuard optimization
✓ ABI splitting (split-per-abi)
✓ No debug symbols in release (debugSymbolLevel = NONE)
✓ META-INF exclusions
```

**Result:** Android build is well-optimized.

### 6.2 Additional Android Optimizations

#### 6.2.1 Enable R8 Full Mode

**Current:** R8 in default mode.

**Add to `android/gradle.properties`:**
```properties
android.enableR8.fullMode=true
```

**Expected Savings:** 5-10% DEX size reduction (400-800 KB)

#### 6.2.2 Compress Native Libraries

**Add to `build.gradle.kts`:**
```kotlin
buildTypes {
    release {
        // ... existing config
        packagingOptions {
            jniLibs {
                useLegacyPackaging = false  // Enable native lib compression
            }
        }
    }
}
```

**Expected Savings:** 2-3 MB (native libraries compress ~20%)

### 6.3 Flutter Build Flags

**Recommended build command:**
```bash
flutter build apk --release \
  --split-per-abi \
  --obfuscate \
  --split-debug-info=./debug-info \
  --tree-shake-icons \
  --target-platform android-arm64
```

**Flags explained:**
- `--split-per-abi`: Separate APKs per architecture (already enabled)
- `--obfuscate`: Dart code obfuscation (security + size)
- `--split-debug-info`: Separate debug symbols (reduces APK)
- `--tree-shake-icons`: Remove unused Material Icons
- `--target-platform`: Build only for 64-bit (Play Store default)

**Expected Savings:** 100-200 KB from icon tree-shaking

---

## 7. Localization Optimization

### 7.1 Current State

| Language | File Size | Status |
|----------|-----------|--------|
| English (en) | 261 KB | Complete (1053 strings) |
| French (fr) | 138 KB | Partial (220 strings) |
| Arabic (ar) | 88 KB | Partial |
| Portuguese (pt) | 37 KB | Partial |

**Total:** 524 KB for 4 languages

**Analysis:** Well-optimized. ARB files are text-based and compress well.

### 7.2 Recommendations

**No action needed.** Localization is efficient.

**Future:** Consider dynamic locale downloading if adding 10+ languages:
```yaml
# Only bundle English, download others on demand
flutter:
  generate: true
  deferred-locales:
    - fr
    - ar
    - pt
```

---

## 8. iOS Optimization Opportunities

**Note:** This analysis focused on Android. iOS optimizations differ.

### 8.1 iOS Size Check

```bash
# Build iOS and analyze size
flutter build ios --release
# Check .app bundle size in Xcode
```

### 8.2 iOS-Specific Optimizations

- Bitcode stripping (already enabled in modern Xcode)
- App thinning (automatic via App Store)
- Asset catalog optimization
- Dead code elimination (automatic)

**Expected iOS size:** 40-50 MB (similar to Android)

---

## 9. Action Plan (Prioritized)

### Phase 1: Quick Wins (1-2 hours, 2-3 MB savings)

| Action | Effort | Savings | Priority |
|--------|--------|---------|----------|
| 1. Remove `flutter_svg` package | 5 min | 200 KB | HIGH |
| 2. Fix 38 unused imports | 30 min | 10 KB | MEDIUM |
| 3. Enable R8 full mode | 2 min | 500 KB | HIGH |
| 4. Add `--tree-shake-icons` to build | 1 min | 150 KB | HIGH |
| 5. Optimize app icons with TinyPNG | 15 min | 75 KB | MEDIUM |
| 6. Enable native lib compression | 5 min | 2 MB | HIGH |

**Total Quick Wins: ~2.9 MB (8.3% reduction)**

### Phase 2: Medium Effort (1-2 days, 2-3 MB savings)

| Action | Effort | Savings | Priority |
|--------|--------|---------|----------|
| 7. Implement deferred PDF loading | 2 hours | 800 KB | HIGH |
| 8. Dynamic barcode model download | 3 hours | 880 KB | HIGH |
| 9. Replace `cached_network_image` | 1 hour | 100 KB | MEDIUM |
| 10. Bundle fonts instead of `google_fonts` | 2 hours | Net 0 (better UX) | LOW |
| 11. Verify mock tree-shaking | 1 hour | 400 KB | MEDIUM |

**Total Medium Effort: ~2.2 MB (6.3% reduction)**

### Phase 3: Long-Term (1 week, 3-5 MB savings)

| Action | Effort | Savings | Priority |
|--------|--------|---------|----------|
| 12. Replace `pdf` package with lighter alternative | 1 day | 600 KB | MEDIUM |
| 13. Replace HTML widget with custom renderer | 1 day | 200 KB | LOW |
| 14. Implement feature-based code splitting | 2 days | 1-2 MB | MEDIUM |
| 15. Audit and remove unused Firebase features | 1 day | 500 KB | LOW |

**Total Long-Term: ~3-5 MB (8.5-14% reduction)**

### Combined Potential

| Phase | Savings | New Size (arm64) | Reduction |
|-------|---------|------------------|-----------|
| Current | - | 35 MB | - |
| After Phase 1 | 2.9 MB | 32.1 MB | 8.3% |
| After Phase 2 | 2.2 MB | 29.9 MB | 14.6% |
| After Phase 3 | 3-5 MB | 25-27 MB | 22-29% |

**Target APK Size: 25-27 MB (23-29% reduction)**

---

## 10. Monitoring and Regression Prevention

### 10.1 Size Budget

Establish size budgets to prevent regression:

| Component | Budget | Current | Status |
|-----------|--------|---------|--------|
| Total APK (arm64) | 30 MB | 35 MB | Over by 5 MB |
| Native code | 20 MB | 26 MB | Over by 6 MB |
| DEX files | 8 MB | 9 MB | Over by 1 MB |
| Assets | 500 KB | 191 KB | Good |
| Resources | 2 MB | ~1 MB | Good |

### 10.2 CI/CD Integration

**Add to CI pipeline:**

```yaml
# .github/workflows/size-check.yml
- name: Build release APK
  run: flutter build apk --release --split-per-abi

- name: Check APK size
  run: |
    SIZE=$(stat -f%z build/app/outputs/apk/release/app-arm64-v8a-release.apk)
    LIMIT=31457280  # 30 MB in bytes
    if [ $SIZE -gt $LIMIT ]; then
      echo "APK size $SIZE exceeds limit $LIMIT"
      exit 1
    fi

- name: Comment size on PR
  run: |
    echo "APK size: $(ls -lh build/app/outputs/apk/release/app-arm64-v8a-release.apk | awk '{print $5}')"
```

### 10.3 Regular Audits

**Schedule:**
- Weekly: Check for new unused dependencies
- Monthly: Full dependency audit
- Per release: APK size regression check

**Tools:**
```bash
# Dependency analysis
flutter pub outdated
flutter pub deps --style=compact

# Unused code detection
dart analyze --no-pub

# APK analysis
flutter build apk --analyze-size
```

---

## 11. Additional Resources

### 11.1 Flutter Size Optimization Docs

- [Flutter Performance Best Practices](https://flutter.dev/docs/perf/best-practices)
- [Reducing App Size](https://flutter.dev/docs/deployment/android#reducing-app-size)
- [Code Splitting](https://flutter.dev/docs/perf/deferred-components)

### 11.2 Recommended Tools

| Tool | Purpose | Platform |
|------|---------|----------|
| `flutter build apk --analyze-size` | APK breakdown | Flutter CLI |
| [Bundle Explorer](https://bundleexplorer.firebaseapp.com/) | Visual APK analysis | Web |
| [TinyPNG](https://tinypng.com/) | Image compression | Web |
| [ImageOptim](https://imageoptim.com/) | Batch image optimization | macOS |
| [Android Studio APK Analyzer](https://developer.android.com/studio/build/apk-analyzer) | Detailed APK inspection | Android Studio |

### 11.3 Size Comparison

| App Category | Typical Size | JoonaPay |
|--------------|--------------|----------|
| Simple utility | 5-10 MB | - |
| Fintech app | 20-40 MB | 35 MB (good) |
| Social media | 50-100 MB | - |
| Gaming | 100-500 MB | - |

**Verdict:** JoonaPay is within expected range for a feature-rich fintech app, but has 20-30% optimization headroom.

---

## 12. Summary and Next Steps

### 12.1 Key Findings

1. **Current size is acceptable** (35 MB) but can be reduced by 8-12 MB (23-29%)
2. **Biggest opportunities:**
   - Native library compression: 2 MB
   - Remove `flutter_svg`: 200 KB
   - Dynamic ML model download: 880 KB
   - Deferred PDF loading: 800 KB
   - Tree-shake mock code: 400 KB
   - R8 full mode: 500 KB

3. **Well-optimized areas:**
   - Localization (524 KB for 4 languages)
   - Asset management (no bloated images)
   - ABI splitting enabled
   - ProGuard/R8 enabled

4. **Areas needing attention:**
   - 38 unused imports
   - Potentially unused `flutter_svg` package
   - Heavy dependencies (`pdf`, `google_fonts`)
   - Mock code in release builds

### 12.2 Immediate Actions (This Week)

1. Remove `flutter_svg` package
2. Enable R8 full mode
3. Add `--tree-shake-icons` to build script
4. Enable native library compression
5. Fix unused imports

**Expected result:** 32 MB APK (8% reduction)

### 12.3 Short-Term Goals (This Month)

1. Implement deferred loading for PDF generation
2. Configure dynamic barcode model download
3. Verify mock code tree-shaking
4. Optimize app icons

**Expected result:** 30 MB APK (14% reduction)

### 12.4 Long-Term Vision (Next Quarter)

1. Implement feature-based code splitting
2. Evaluate lighter alternatives for heavy dependencies
3. Establish size budgets in CI/CD
4. Regular monthly size audits

**Target:** 25-27 MB APK (23-29% reduction)

---

## Appendix A: Build Commands Reference

### Current Build (Recommended)
```bash
cd /Users/macbook/JoonaPay/USDC-Wallet/mobile
flutter build apk --release --split-per-abi
```

### Optimized Build (Phase 1)
```bash
flutter build apk --release \
  --split-per-abi \
  --tree-shake-icons \
  --obfuscate \
  --split-debug-info=./build/debug-info
```

### Size Analysis
```bash
flutter build apk --release --analyze-size
```

### App Bundle (Play Store)
```bash
flutter build appbundle --release
```

---

## Appendix B: Dependency Size Estimates

| Package | Estimated Impact | Used In |
|---------|------------------|---------|
| `dio` | 300 KB | All API calls |
| `flutter_riverpod` | 200 KB | State management |
| `go_router` | 150 KB | Navigation |
| `google_fonts` | 500 KB | Typography |
| `cached_network_image` | 150 KB | Image caching |
| `flutter_svg` | 200 KB | **UNUSED** |
| `qr_flutter` | 100 KB | QR generation |
| `mobile_scanner` | 100 KB + 880 KB models | QR scanning |
| `pdf` | 800 KB | Receipt generation |
| `fl_chart` | 400 KB | Analytics charts |
| `firebase_*` (4 packages) | 1.5 MB | Push, analytics, crashes |
| `camera` | 200 KB | KYC selfies |
| `image_picker` | 150 KB | Document upload |

**Note:** Estimates are approximate. Actual impact depends on tree-shaking and ProGuard optimization.

---

**Report Generated by:** Claude Code
**Contact:** JoonaPay Development Team
**Next Review:** February 2026
