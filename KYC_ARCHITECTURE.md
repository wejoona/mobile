# KYC Verification - Architecture Overview

## Component-First Architecture

### State Flow
```
User Action → Provider (Notifier) → State Update → UI Re-render
     ↓
API Service → Backend → Response → State Update → UI
```

### State Machine
```dart
class KycState {
  final KycStatus status;                    // Current verification status
  final String? rejectionReason;             // Why rejected (if applicable)
  final bool isLoading;                      // Loading state
  final String? error;                       // Error message
  final DocumentType? selectedDocumentType;  // User's choice
  final List<KycDocument> capturedDocuments; // Front/back images
  final String? selfiePath;                  // Selfie image
  final double uploadProgress;               // 0.0 to 1.0
}
```

## Component Hierarchy

### 1. KycStatusView (Entry Point)
**Purpose**: Show current KYC status and guide user

**States**:
- **Pending**: Shows "Start Verification" button
- **Submitted**: Shows "Under Review" with time estimate
- **Approved**: Shows success checkmark
- **Rejected**: Shows error with reason + "Try Again" button
- **Additional Info Needed**: Shows what's missing + restart button

**UI Elements**:
- Status icon (changes color/icon based on state)
- Title and description
- Info cards (security, timing, documents)
- Action button (conditional based on state)

### 2. DocumentTypeView
**Purpose**: Let user choose ID type

**Options**:
```dart
enum DocumentType {
  nationalId,      // Front + Back required
  passport,        // Single page only
  driversLicense   // Front + Back required
}
```

**UI Elements**:
- 3 selectable cards with icons
- Selection indicator (gold border + checkmark)
- Continue button (enabled when selected)

### 3. DocumentCaptureView
**Purpose**: Capture document with camera

**Features**:
- Live camera preview
- Document frame overlay (animated)
- Quality checks before acceptance
- Flash toggle
- Guidance text (top)
- Instructions (bottom)

**Quality Checks**:
```dart
class ImageQualityChecker {
  static Future<ImageQualityResult> checkQuality(String imagePath) async {
    // 1. Check brightness (too dark?)
    // 2. Check blur (Laplacian variance)
    // 3. Check glare (bright pixel percentage)
    return result;
  }
}
```

**Overlay Painter**:
```dart
class DocumentFramePainter extends CustomPainter {
  // Draws:
  // - Darkened background outside frame
  // - Animated border around document area
  // - Corner markers for alignment
}
```

### 4. SelfieView
**Purpose**: Capture user's face

**Features**:
- Front camera (automatic)
- Face oval overlay
- Liveness hints (text guidance)
- Quality validation

**Overlay Painter**:
```dart
class FaceOvalPainter extends CustomPainter {
  // Draws:
  // - Darkened background outside oval
  // - Animated oval border for face alignment
}
```

### 5. ReviewView
**Purpose**: Final check before submission

**UI Elements**:
- Document thumbnails with labels
- Selfie thumbnail
- Edit buttons (navigate back to recapture)
- Submit button (API call)

**Validation**:
```dart
bool get canSubmit => hasAllDocuments && hasSelfie;
```

### 6. SubmittedView
**Purpose**: Confirmation screen

**Features**:
- Success animation (scale + fade)
- Time estimate (1-2 hours)
- Info box with clock icon
- "Done" button → navigate home

## Data Flow Examples

### Happy Path
```
1. User taps "Start Verification" on KycStatusView
   → Navigate to DocumentTypeView

2. User selects "National ID Card"
   → Provider: selectDocumentType(DocumentType.nationalId)
   → Navigate to DocumentCaptureView

3. User captures front of ID
   → Quality check passes
   → Provider: addDocument(KycDocument(side: front, ...))
   → Stay on DocumentCaptureView (now capturing back)

4. User captures back of ID
   → Quality check passes
   → Provider: addDocument(KycDocument(side: back, ...))
   → Navigate to SelfieView

5. User captures selfie
   → Quality check passes
   → Provider: setSelfie(path)
   → Navigate to ReviewView

6. User reviews all images, taps "Submit"
   → Provider: submitKyc()
     → API: POST /api/v1/user/kyc (multipart form)
     → Success response
     → Provider: update status to 'submitted'
   → Navigate to SubmittedView

7. User taps "Done"
   → Navigate to /home
```

### Error Path: Image Quality Fails
```
1. User captures document
   → Quality check: ImageQualityChecker.checkQuality()
   → Result: isBlurry = true

2. Show SnackBar: "Image is too blurry. Please hold your device steady and try again."

3. User sees same camera screen (capturedImagePath = null)
   → Can retry capture
```

### Error Path: Network Failure
```
1. User taps "Submit" on ReviewView
   → Provider: submitKyc()
     → API call fails (network error)
     → Catch exception
     → Provider: set error state

2. Show SnackBar with error message

3. User can tap "Submit" again to retry
```

## Performance Optimizations

### 1. Image Compression
```dart
Future<Uint8List> compressImage(String imagePath) async {
  // 1. Decode image
  // 2. Resize if > 1920px
  // 3. Encode as JPEG at 85% quality
  // Result: ~200-500KB per image
}
```

### 2. Sampling for Quality Checks
```dart
// Check every 10th pixel instead of all pixels
for (int y = 0; y < image.height; y += 10) {
  for (int x = 0; x < image.width; x += 10) {
    // Process pixel
  }
}
```

### 3. Async Quality Checks
```dart
setState(() => _isCheckingQuality = true);
final result = await ImageQualityChecker.checkQuality(imagePath);
setState(() => _isCheckingQuality = false);
```

### 4. Provider State Management
```dart
// State is immutable, updates create new instances
state = state.copyWith(isLoading: true);

// Only changed fields trigger rebuilds
ref.watch(kycProvider.select((s) => s.status));
```

## Security Considerations

### 1. Local Storage
- Images saved to app documents directory
- Not accessible by other apps
- Deleted after successful upload (optional)

### 2. Network Transport
- Multipart form with HTTPS
- Bearer token authentication
- Images compressed (reduces attack surface)

### 3. Quality Checks Prevent
- Screenshot uploads (glare detection)
- Photocopy uploads (quality checks)
- Edited images (consistency checks)

## Accessibility Features

### 1. Semantic Labels
```dart
Semantics(
  label: l10n.kyc_capture_button,
  child: CaptureButton(),
)
```

### 2. High Contrast Overlays
- Dark background (70% opacity) outside frame/oval
- Gold borders for visibility
- Clear white text on dark backgrounds

### 3. Guidance Text
- Step-by-step instructions
- Error messages in user's language
- Visual + text feedback

## Responsive Design

### Mobile-First
- Portrait orientation enforced for camera
- Full-screen camera previews
- Bottom sheet controls (thumb-friendly)

### Tablet Support
- Same flow, larger frame/oval
- More padding for comfort
- Larger touch targets

## Testing Strategy

### Unit Tests
```dart
test('KycStatus.fromString converts correctly', () {
  expect(KycStatus.fromString('pending'), KycStatus.pending);
  expect(KycStatus.fromString('approved'), KycStatus.approved);
});

test('ImageQualityChecker detects dark images', () async {
  final result = await ImageQualityChecker.checkQuality(darkImagePath);
  expect(result.isTooDark, true);
});
```

### Widget Tests
```dart
testWidgets('KycStatusView shows correct UI for pending status', (tester) async {
  await tester.pumpWidget(MyApp());
  expect(find.text('Verify Your Identity'), findsOneWidget);
  expect(find.text('Start Verification'), findsOneWidget);
});
```

### Integration Tests
```dart
testWidgets('Complete KYC flow end-to-end', (tester) async {
  // 1. Navigate to KYC
  // 2. Select document type
  // 3. Mock camera captures
  // 4. Review documents
  // 5. Submit
  // 6. Verify success screen
});
```

### Mock Testing
```dart
setUp(() {
  KycMockState.reset();
});

test('Mock KYC submission updates status', () async {
  expect(KycMockState.kycStatus, 'pending');

  await sdk.kyc.submitKyc(...);

  expect(KycMockState.kycStatus, 'submitted');
});
```

## Extension Points

### Custom Quality Checks
```dart
// Add to ImageQualityChecker
static Future<bool> checkDocumentEdges(img.Image image) {
  // Use edge detection to ensure full document visible
}
```

### Additional Document Types
```dart
enum DocumentType {
  nationalId,
  passport,
  driversLicense,
  // Add new types here
  residencePermit,
  votersCard,
}
```

### Liveness Detection
```dart
// Future enhancement in SelfieView
static Future<bool> checkLiveness(List<String> imagePaths) {
  // Implement blink detection or head movement
}
```

## Dependencies Explained

### camera
- Access device cameras (front/back)
- Configure resolution, flash, focus
- Capture images as XFile

### image
- Decode/encode image formats
- Image manipulation (resize, compress)
- Quality analysis (brightness, blur)

### path_provider
- Get app documents directory
- Platform-agnostic file paths

### path
- Construct file paths
- Extract file extensions
