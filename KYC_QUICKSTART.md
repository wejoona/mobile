# KYC Implementation - Quick Start

## Immediate Next Steps

### 1. Add Dependencies
Add to `pubspec.yaml`:
```yaml
dependencies:
  camera: ^0.10.5+5
  image: ^4.1.3
  path_provider: ^2.1.1
  path: ^1.8.3
```

Run:
```bash
cd /Users/macbook/JoonaPay/USDC-Wallet/mobile
flutter pub get
```

### 2. Add Translations

**English** - Copy content from `kyc_translations.json` into `lib/l10n/app_en.arb` before the closing `}`

**French** - Copy content from `kyc_translations_fr.json` into `lib/l10n/app_fr.arb` before the closing `}`

Then run:
```bash
flutter gen-l10n
```

### 3. Add Camera Permissions

**iOS** - Add to `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to capture your identity documents and selfie for verification</string>
```

**Android** - Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-feature android:name="android.hardware.camera" android:required="false"/>
```

### 4. Test the Flow

```bash
flutter run
```

Navigate to: Settings → KYC / Identity Verification

Or programmatically:
```dart
context.push('/kyc');
```

## Key Features

### Document Capture with Quality Checks
```dart
// Automatic quality validation
final qualityResult = await ImageQualityChecker.checkQuality(imagePath);

if (!qualityResult.isAcceptable) {
  // Shows user-friendly error:
  // - "Image is too blurry"
  // - "Too much glare detected"
  // - "Image is too dark"
}
```

### State Management
```dart
// Watch KYC state
final kycState = ref.watch(kycProvider);

// Check status
if (kycState.status.isApproved) {
  // User is verified
}

// Submit documents
await ref.read(kycProvider.notifier).submitKyc();
```

### Custom Camera Overlays
- **Document Frame**: Animated border with corner markers, proper aspect ratio
- **Face Oval**: Centered oval for selfie alignment
- **Quality Guidance**: Real-time instructions for better captures

### Mock Testing
```dart
// Simulate different KYC states
KycMockState.approve();
KycMockState.reject('Document not clear enough');
KycMockState.requestAdditionalInfo('Need passport instead of ID');
```

## Flow Diagram

```
KYC Status → Document Type Selection → Document Capture (Front)
    → Document Capture (Back, if applicable) → Selfie Capture
    → Review All Documents → Submit → Success
```

## API Endpoints

### Submit KYC
```
POST /api/v1/user/kyc
Content-Type: multipart/form-data

Form fields:
- documents: File[] (JPEG images)
- selfie: File (JPEG image)
- documentType: string ("national_id" | "passport" | "drivers_license")
```

### Get KYC Status
```
GET /api/v1/user/profile

Response includes:
{
  "kycStatus": "pending" | "submitted" | "approved" | "rejected" | "additional_info_needed",
  "kycRejectionReason": "string or null"
}
```

## File Structure

```
lib/features/kyc/
├── models/
│   ├── kyc_status.dart              # Status enum
│   ├── document_type.dart           # Document types
│   ├── kyc_document.dart            # Document model
│   ├── kyc_submission.dart          # Submission model
│   └── image_quality_result.dart    # Quality check result
├── providers/
│   └── kyc_provider.dart            # State management
└── views/
    ├── kyc_status_view.dart         # Main status screen
    ├── document_type_view.dart      # Type selection
    ├── document_capture_view.dart   # Camera capture
    ├── selfie_view.dart             # Selfie capture
    ├── review_view.dart             # Review screen
    └── submitted_view.dart          # Success screen

lib/services/kyc/
├── kyc_service.dart                 # API service
└── image_quality_checker.dart       # Quality validation

lib/mocks/services/kyc/
└── kyc_mock.dart                    # Mock responses
```

## Usage Examples

### Navigate to KYC from Settings
```dart
ListTile(
  title: Text(l10n.settings_kyc),
  trailing: Icon(Icons.chevron_right),
  onTap: () => context.push('/kyc'),
)
```

### Check if User is Verified
```dart
final kycProvider = ref.watch(kycProvider);
final isVerified = kycProvider.status.isApproved;

if (!isVerified) {
  // Show verification banner
  VerificationBanner(
    onTap: () => context.push('/kyc'),
  );
}
```

### Reset KYC Flow
```dart
ref.read(kycProvider.notifier).resetFlow();
```

## Troubleshooting

### Camera doesn't initialize
- Test on physical device (not simulator)
- Check camera permissions in system settings
- Verify permissions added to Info.plist/AndroidManifest.xml

### Translations not found
- Ensure strings added to both app_en.arb and app_fr.arb
- Run `flutter gen-l10n`
- Restart Flutter app

### Image quality always fails
- Adjust thresholds in `image_quality_checker.dart`
- Test in good lighting conditions
- Ensure camera focuses before capture

### Routes not found
- Verify all imports in `app_router.dart`
- Check route paths match navigation calls
- Restart app after adding routes

## West African Context

Document types supported:
- ✅ Ivorian National ID Card (front + back)
- ✅ ECOWAS Passport (single page)
- ✅ Driver's License (front + back)

Languages:
- 🇫🇷 French (primary)
- 🇬🇧 English (secondary)

All strings translated in both languages.
