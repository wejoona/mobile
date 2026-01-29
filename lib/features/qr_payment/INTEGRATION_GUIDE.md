# QR Payment Integration Guide

## Quick Start

The QR Payment feature is ready to use. Follow these steps to integrate it into your app.

## 1. Add Routes

Add these routes to `/lib/router/app_router.dart`:

```dart
import '../features/qr_payment/views/receive_qr_screen.dart';
import '../features/qr_payment/views/scan_qr_screen.dart';

// Inside routes list:
GoRoute(
  path: '/qr/receive',
  pageBuilder: (context, state) => AppPageTransitions.fade(
    context,
    state,
    const ReceiveQrScreen(),
  ),
),
GoRoute(
  path: '/qr/scan',
  pageBuilder: (context, state) => AppPageTransitions.fade(
    context,
    state,
    const ScanQrScreen(),
  ),
),
```

## 2. Update Quick Actions (Optional)

If you want to replace the existing `/scan` route with the new QR screens, update `home_view.dart`:

### Option A: Replace existing scan button
```dart
// In _buildQuickActions method:
Expanded(
  child: _QuickActionButton(
    icon: Icons.qr_code_scanner,
    label: 'Scan',
    onTap: () => context.push('/qr/scan'), // Changed from '/scan'
  ),
),
```

### Option B: Add receive QR button
```dart
// Update to 4 buttons instead of 3:
Widget _buildQuickActions(BuildContext context) {
  return Wrap(
    spacing: AppSpacing.md,
    runSpacing: AppSpacing.md,
    children: [
      SizedBox(
        width: (MediaQuery.of(context).size.width - 48 - 24) / 2,
        child: _QuickActionButton(
          icon: Icons.send,
          label: 'Send',
          onTap: () => context.push('/send'),
        ),
      ),
      SizedBox(
        width: (MediaQuery.of(context).size.width - 48 - 24) / 2,
        child: _QuickActionButton(
          icon: Icons.qr_code,
          label: 'Receive',
          onTap: () => context.push('/qr/receive'),
        ),
      ),
      SizedBox(
        width: (MediaQuery.of(context).size.width - 48 - 24) / 2,
        child: _QuickActionButton(
          icon: Icons.qr_code_scanner,
          label: 'Scan',
          onTap: () => context.push('/qr/scan'),
        ),
      ),
      SizedBox(
        width: (MediaQuery.of(context).size.width - 48 - 24) / 2,
        child: _QuickActionButton(
          icon: Icons.call_received,
          label: 'Request',
          onTap: () => context.push('/request-money'),
        ),
      ),
    ],
  );
}
```

## 3. Update Send View to Handle Prefilled Data

The scan screen navigates to `/send` with extra data. Update `send_view.dart` to handle this:

```dart
class SendView extends ConsumerStatefulWidget {
  const SendView({
    super.key,
    this.prefilledPhone,
    this.prefilledAmount,
    this.prefilledReference,
  });

  final String? prefilledPhone;
  final String? prefilledAmount;
  final String? prefilledReference;

  @override
  ConsumerState<SendView> createState() => _SendViewState();
}

class _SendViewState extends ConsumerState<SendView> {
  // ... existing code ...

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Prefill from QR scan
    if (widget.prefilledPhone != null) {
      _phoneController.text = widget.prefilledPhone!.replaceFirst('+225', '');
    }
    if (widget.prefilledAmount != null) {
      _amountController.text = widget.prefilledAmount!;
    }
    // Handle reference if your form has a reference field
  }
}
```

Update the route in `app_router.dart`:

```dart
GoRoute(
  path: '/send',
  pageBuilder: (context, state) {
    final extra = state.extra as Map<String, dynamic>?;
    return AppPageTransitions.slideLeft(
      context,
      state,
      SendView(
        prefilledPhone: extra?['phone'],
        prefilledAmount: extra?['amount'],
        prefilledReference: extra?['reference'],
      ),
    );
  },
),
```

## 4. Generate Localizations

After adding the localization strings, run:

```bash
cd mobile
flutter gen-l10n
```

## 5. Update Permissions

### Android
Verify `android/app/src/main/AndroidManifest.xml` has:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" android:required="false" />
```

### iOS
Verify `ios/Runner/Info.plist` has:
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to scan QR codes for payments</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to save QR codes</string>
```

## 6. Test the Feature

### Manual Testing

1. **Receive Flow:**
   - Navigate to home → tap "Receive" (or navigate to `/qr/receive`)
   - Verify QR code displays with phone number
   - Toggle amount input and verify QR updates
   - Test share and save to gallery
   - Verify screen brightness increases

2. **Scan Flow:**
   - Navigate to home → tap "Scan" (or navigate to `/qr/scan`)
   - Grant camera permission
   - Scan a test QR code (generate one from receive screen)
   - Verify parsed data displays correctly
   - Tap "Send Money" and verify navigation to send view with prefilled data
   - Test flash toggle
   - Test scan again functionality

### Generate Test QR

Use an online QR generator with this JSON:
```json
{
  "type": "joonapay",
  "version": 1,
  "phone": "+22507123456",
  "amount": 50.00,
  "currency": "USD",
  "name": "Test User"
}
```

## 7. Optional: Add to Services Screen

If you have a services screen, add QR payment shortcuts:

```dart
// In services_view.dart
ServiceItem(
  icon: Icons.qr_code,
  title: 'Receive via QR',
  description: 'Show your payment QR code',
  onTap: () => context.push('/qr/receive'),
),
ServiceItem(
  icon: Icons.qr_code_scanner,
  title: 'Scan to Pay',
  description: 'Scan QR code to send money',
  onTap: () => context.push('/qr/scan'),
),
```

## Troubleshooting

### Camera not working
- Check permissions in device settings
- Verify `permission_handler` is properly configured
- Check Android/iOS platform-specific setup

### QR not scanning
- Ensure good lighting
- Try using flash toggle
- Verify QR format is correct (JSON or legacy URL format)
- Check scanner overlay is not blocking QR code area

### Share/Save not working
- Verify storage permissions for Android 10+
- Check `image_gallery_saver_plus` configuration
- Verify `share_plus` is properly set up

### Brightness control not working
- This is optional and may not work on all devices
- The feature degrades gracefully if brightness control unavailable

## Performance Tips

1. **Scanner Performance:**
   - Scanner uses hardware acceleration
   - Overlay rendering is optimized
   - Consider pausing scanner when app is backgrounded

2. **QR Generation:**
   - QR data is cached in memory
   - Consider storing frequently used QR strings

3. **Image Capture:**
   - Screenshot capture runs on background thread
   - Gallery save is async to avoid UI blocking

## Accessibility

All screens include:
- Semantic labels for screen readers
- High contrast scanner overlay
- Haptic feedback on scan success
- Clear error messages
- Keyboard-navigable where applicable

## Next Steps

Consider these enhancements:
- Add QR expiry for time-limited payment requests
- Implement merchant mode with static QR codes
- Add QR code customization (colors, logo)
- Implement gallery import for scanning saved QR images
- Add QR analytics (track scans, payments)
