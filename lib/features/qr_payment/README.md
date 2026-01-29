# QR Payment Feature

## Overview

The QR Payment feature enables users to send and receive payments by scanning or sharing QR codes. This provides a convenient, merchant-friendly way to transfer money without manually entering phone numbers or wallet addresses.

## Structure

```
lib/features/qr_payment/
├── models/
│   └── qr_payment_data.dart      # QR data model with JSON encoding/decoding
├── services/
│   └── qr_code_service.dart      # QR generation and parsing service
├── views/
│   ├── receive_qr_screen.dart    # Display user's QR code for receiving
│   └── scan_qr_screen.dart       # Scan QR codes to send money
├── widgets/
│   └── qr_display.dart           # Reusable QR display components
└── README.md                      # This file
```

## Features

### Receive QR Screen
- Generate QR code with user's phone number
- Optional amount input (request specific amount)
- Display user name and phone in QR card
- Share QR code as image
- Save QR code to gallery
- Auto-increase screen brightness for better scanning
- Copy QR data to clipboard

### Scan QR Screen
- Camera-based QR scanning with overlay frame
- Camera permission handling
- Flash toggle for low-light scanning
- Parse multiple QR formats (JSON, legacy URL, plain phone)
- Display scanned payment details before sending
- Navigate to send view with prefilled data
- Error handling for invalid QR codes

## QR Data Format

### Primary Format (JSON)
```json
{
  "type": "joonapay",
  "version": 1,
  "phone": "+22507XXXXXXXX",
  "amount": 50.00,
  "currency": "USD",
  "name": "John Doe",
  "reference": "INV-001"
}
```

**Required Fields:**
- `phone`: Recipient's phone number (E.164 format)

**Optional Fields:**
- `amount`: Requested payment amount
- `currency`: Currency code (default: USD)
- `name`: Recipient's name
- `reference`: Payment reference/memo

### Legacy Formats (Backward Compatible)

1. **URL Format:**
   ```
   joonapay://pay?phone=+225xxx&amount=10&name=John
   ```

2. **Plain Phone:**
   ```
   +22507XXXXXXXX
   ```

## Usage

### Integration in Router

Add routes in `/lib/router/app_router.dart`:

```dart
GoRoute(
  path: '/qr/receive',
  pageBuilder: (context, state) => AppPageTransitions.fade(
    context, state, const ReceiveQrScreen(),
  ),
),
GoRoute(
  path: '/qr/scan',
  pageBuilder: (context, state) => AppPageTransitions.fade(
    context, state, const ScanQrScreen(),
  ),
),
```

### Navigation Examples

**From Home Screen:**
```dart
// Show receive QR
context.push('/qr/receive');

// Show scanner
context.push('/qr/scan');
```

**Quick Actions:**
```dart
_QuickActionButton(
  icon: Icons.qr_code,
  label: 'Receive',
  onTap: () => context.push('/qr/receive'),
),
_QuickActionButton(
  icon: Icons.qr_code_scanner,
  label: 'Scan',
  onTap: () => context.push('/qr/scan'),
),
```

### Using QR Service Directly

```dart
final qrService = QrCodeService();

// Generate QR data
final qrData = qrService.generateReceiveQr(
  phone: '+22507123456',
  amount: 50.00,
  currency: 'USD',
  name: 'John Doe',
);

// Parse scanned QR
final parsedData = qrService.parseQrData(scannedString);
if (parsedData != null) {
  print('Phone: ${parsedData.phone}');
  print('Amount: ${parsedData.amount}');
}

// Validate QR
if (qrService.isValidQrData(scannedString)) {
  // Valid JoonaPay QR code
}
```

### Using QR Display Widget

```dart
import '../widgets/qr_display.dart';

// Simple QR display
QrDisplay(
  data: qrData,
  size: 200,
  title: 'Scan to Pay',
  subtitle: 'JoonaPay QR Code',
)

// QR with user info
QrDisplayWithInfo(
  data: qrData,
  phone: '+22507123456',
  name: 'John Doe',
  amount: 50.00,
  currency: 'USD',
)
```

## Permissions Required

### Android (android/app/src/main/AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.CAMERA" />
```

### iOS (ios/Runner/Info.plist)
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to scan QR codes for payments</string>
```

## Dependencies

All dependencies are already in `pubspec.yaml`:
- `qr_flutter: ^4.1.0` - QR code generation
- `mobile_scanner: ^7.0.0` - QR code scanning
- `share_plus: ^10.0.0` - Share QR images
- `permission_handler: ^11.3.1` - Camera permissions
- `screenshot: ^3.0.0` - Capture QR as image
- `image_gallery_saver_plus: ^4.0.0` - Save to gallery
- `path_provider: ^2.1.4` - Temporary file storage

## Testing

### Manual Testing Checklist

**Receive QR:**
- [ ] QR code displays correctly
- [ ] Amount input updates QR data
- [ ] Share functionality works
- [ ] Save to gallery works
- [ ] Screen brightness increases
- [ ] Brightness restores on exit

**Scan QR:**
- [ ] Camera permission requested
- [ ] Scanner initializes correctly
- [ ] Flash toggle works
- [ ] Valid QR codes parsed correctly
- [ ] Invalid QR codes show error
- [ ] Scanned data prefills send form
- [ ] Works in low light with flash

### Test QR Codes

Generate test QR codes at: https://www.qr-code-generator.com/

**Test Data:**
```json
{"type":"joonapay","version":1,"phone":"+22507123456","amount":100,"currency":"USD","name":"Test User"}
```

## West African Context

- **Phone Format:** +225 XX XX XX XX (Côte d'Ivoire)
- **Use Case:** Popular for merchant payments, market vendors
- **Offline:** QR can be printed and displayed at shops
- **Low Connectivity:** QR scanning works offline, payment requires connection

## Performance Considerations

- Camera preview runs in separate isolate
- QR parsing is synchronous but fast (< 1ms)
- Image capture for sharing uses background thread
- Gallery save is async to avoid blocking UI

## Accessibility

- All buttons have semantic labels
- QR code has text alternative (phone number)
- High contrast scanner overlay
- Haptic feedback on successful scan
- Error messages are screen-reader friendly

## Future Enhancements

- [ ] Gallery import (scan from saved image)
- [ ] Batch QR generation (for merchants)
- [ ] Dynamic QR with expiry
- [ ] QR analytics (scan tracking)
- [ ] Multi-currency support in QR
- [ ] NFC fallback for unsupported devices
