# KYC Verification Flow Implementation

## Overview
Complete KYC (Know Your Customer) verification flow for the JoonaPay mobile app using Flutter, including document capture, selfie verification, and submission.

## Files Created

### Models
- `/lib/features/kyc/models/kyc_status.dart` - KYC status enum (pending, submitted, approved, rejected, additional_info_needed)
- `/lib/features/kyc/models/document_type.dart` - Document types (national ID, passport, driver's license)
- `/lib/features/kyc/models/kyc_document.dart` - Document model with image path and side
- `/lib/features/kyc/models/kyc_submission.dart` - Submission model containing documents and selfie
- `/lib/features/kyc/models/image_quality_result.dart` - Image quality check result

### Services
- `/lib/services/kyc/kyc_service.dart` - API service for KYC submission and status
- `/lib/services/kyc/image_quality_checker.dart` - Image quality validation (blur, glare, darkness detection)

### Providers
- `/lib/features/kyc/providers/kyc_provider.dart` - Riverpod state management for KYC flow

### Views
- `/lib/features/kyc/views/kyc_status_view.dart` - Main KYC status screen with different states
- `/lib/features/kyc/views/document_type_view.dart` - Document type selection
- `/lib/features/kyc/views/document_capture_view.dart` - Camera capture with document frame overlay
- `/lib/features/kyc/views/selfie_view.dart` - Selfie capture with face oval overlay
- `/lib/features/kyc/views/review_view.dart` - Review captured documents before submission
- `/lib/features/kyc/views/submitted_view.dart` - Success screen after submission

### Mocks
- `/lib/mocks/services/kyc/kyc_mock.dart` - Mock API responses for testing

### Routes
Added to `/lib/router/app_router.dart`:
- `/kyc` - KYC status screen
- `/kyc/document-type` - Document type selection
- `/kyc/document-capture` - Document camera capture
- `/kyc/selfie` - Selfie capture
- `/kyc/review` - Review documents
- `/kyc/submitted` - Submission success

## Translations Required

### English Translations (add to `lib/l10n/app_en.arb`)
All translation strings are in the file `kyc_translations.json` at the project root. Copy these entries into `app_en.arb` before the closing brace.

### French Translations (add to `lib/l10n/app_fr.arb`)
All French translation strings are in the file `kyc_translations_fr.json` at the project root. Copy these entries into `app_fr.arb` before the closing brace.

After adding translations, run:
```bash
cd mobile
flutter gen-l10n
```

## Dependencies

Add these to `pubspec.yaml` if not already present:

```yaml
dependencies:
  camera: ^0.10.5+5
  image: ^4.1.3
  path_provider: ^2.1.1
  path: ^1.8.3
```

Then run:
```bash
cd mobile
flutter pub get
```

## Features Implemented

### 1. Document Capture
- Camera preview with document frame overlay
- Quality checks: blur detection, glare detection, brightness check
- Front and back side capture for ID cards and driver's licenses
- Single page capture for passports
- Flash toggle
- Image compression before upload

### 2. Selfie Capture
- Front camera with face oval overlay
- Quality validation
- Liveness hints (basic guidance)

### 3. Document Review
- Thumbnail preview of all captured images
- Edit/retake capability for each document
- Clear labeling (front, back, selfie)

### 4. Status Tracking
- 5 states: pending, submitted, approved, rejected, additional_info_needed
- Rejection reason display
- Informational cards about security, timing, and requirements

### 5. Image Quality Validation
- **Blur Detection**: Laplacian variance check
- **Glare Detection**: Bright pixel percentage analysis
- **Darkness Check**: Average brightness threshold
- Automatic validation before acceptance

### 6. API Integration
- `POST /api/v1/user/kyc` - Submit documents (multipart form)
- `GET /api/v1/user/profile` - Get KYC status (includes kycStatus and kycRejectionReason)

### 7. Mock Support
- Mock KYC submission with 2-second delay
- Mock status polling
- Testable state changes (approve, reject, request additional info)

## Usage

### Start KYC Flow
```dart
// From settings or anywhere in the app
context.push('/kyc');
```

### Check KYC Status Programmatically
```dart
final kycState = ref.watch(kycProvider);
if (kycState.status.isApproved) {
  // User is verified
}
```

### Mock Testing
```dart
// Approve KYC
KycMockState.approve();

// Reject KYC
KycMockState.reject('Document not clear');

// Request additional info
KycMockState.requestAdditionalInfo('Need clearer photo');
```

## Design Details

### Color Scheme
- Uses existing JoonaPay design tokens (AppColors.gold500, AppColors.obsidian, etc.)
- Status-specific colors:
  - Pending: Gold
  - Submitted: Warning (amber)
  - Approved: Success (green)
  - Rejected: Error (red)

### Document Frame Overlay
- Animated border with corner markers
- Aspect ratio: 1.586 for ID cards, 0.707 for passports
- Darkened background outside frame
- Clear positioning guidance

### Face Oval Overlay
- Centered oval for face alignment
- Darkened background outside oval
- Golden border for premium feel

## Camera Permissions

Add to iOS `Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to capture your identity documents and selfie for verification</string>
```

Add to Android `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-feature android:name="android.hardware.camera" android:required="false"/>
```

## Accessibility

- Semantic labels on all interactive elements
- Clear guidance text for each step
- Error messages in user's language
- High contrast overlays for camera screens

## Performance Considerations

- Image compression to 85% JPEG quality
- Resize to max 1920px before upload
- Sampling for quality checks (every 5-10 pixels)
- Async image processing to avoid UI blocking

## Next Steps

1. **Add translations** to `app_en.arb` and `app_fr.arb` from the JSON files
2. **Run `flutter gen-l10n`** to generate localization classes
3. **Add camera dependencies** to `pubspec.yaml`
4. **Test on physical device** (camera doesn't work on simulator)
5. **Configure backend** to handle multipart form uploads
6. **Integrate with Yellow Card** KYC API for actual verification

## Testing Checklist

- [ ] All screens navigate correctly
- [ ] Document type selection works
- [ ] Camera captures front and back for ID/license
- [ ] Camera captures single page for passport
- [ ] Selfie capture works with front camera
- [ ] Quality checks reject bad images
- [ ] Review screen shows all images
- [ ] Edit buttons navigate back correctly
- [ ] Submit button uploads documents
- [ ] Status screen shows correct state
- [ ] Rejection reason displays
- [ ] Mock responses work correctly
- [ ] French translations display correctly
- [ ] Camera permissions requested
- [ ] Works on iOS and Android

## File Paths Summary

All files use absolute paths as required:

**Models:**
- `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/features/kyc/models/kyc_status.dart`
- `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/features/kyc/models/document_type.dart`
- `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/features/kyc/models/kyc_document.dart`
- `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/features/kyc/models/kyc_submission.dart`
- `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/features/kyc/models/image_quality_result.dart`

**Services:**
- `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/services/kyc/kyc_service.dart`
- `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/services/kyc/image_quality_checker.dart`

**Providers:**
- `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/features/kyc/providers/kyc_provider.dart`

**Views:**
- `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/features/kyc/views/kyc_status_view.dart`
- `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/features/kyc/views/document_type_view.dart`
- `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/features/kyc/views/document_capture_view.dart`
- `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/features/kyc/views/selfie_view.dart`
- `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/features/kyc/views/review_view.dart`
- `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/features/kyc/views/submitted_view.dart`

**Mocks:**
- `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/mocks/services/kyc/kyc_mock.dart`

**Translations:**
- `/Users/macbook/JoonaPay/USDC-Wallet/mobile/kyc_translations.json` (English)
- `/Users/macbook/JoonaPay/USDC-Wallet/mobile/kyc_translations_fr.json` (French)
