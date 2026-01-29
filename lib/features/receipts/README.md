# Receipt Sharing Feature

Transaction receipt generation and sharing functionality for JoonaPay.

## Overview

This feature allows users to share transaction receipts in multiple formats (image, PDF) through various channels including WhatsApp, email, and system share sheet.

## Features

- **Multiple Formats**: Generate receipts as PNG images or PDF documents
- **WhatsApp Integration**: Direct sharing to WhatsApp with pre-filled message
- **System Share**: Share via any installed app using native share sheet
- **Save to Gallery**: Save receipt images to device photo gallery
- **Email**: Send receipts via email client
- **Copy Reference**: Quick copy transaction reference number

## Structure

```
receipts/
├── models/
│   ├── receipt_data.dart       # Receipt data model
│   └── receipt_format.dart     # Receipt format enum
├── services/
│   └── receipt_service.dart    # Receipt generation & sharing service
├── widgets/
│   └── receipt_widget.dart     # Receipt UI template
├── views/
│   └── share_receipt_sheet.dart # Share options bottom sheet
└── providers/
    └── receipt_service_provider.dart # Riverpod provider
```

## Usage

### Show Share Sheet

```dart
import 'package:usdc_wallet/features/receipts/views/share_receipt_sheet.dart';

// Show share options for a transaction
ShareReceiptSheet.show(context, transaction);
```

### Direct Service Usage

```dart
import 'package:usdc_wallet/features/receipts/services/receipt_service.dart';

final service = ReceiptService();

// Generate image
final imageBytes = await service.generateReceiptImage(transaction);

// Generate PDF
final pdfBytes = await service.generateReceiptPdf(transaction);

// Share via WhatsApp
await service.shareViaWhatsApp(transaction: transaction);

// Save to gallery
await service.saveToGallery(imageBytes, 'receipt_name');
```

## Receipt Template

The receipt includes:
- JoonaPay logo
- Transaction status badge (success/pending/failed)
- Amount, fee, and total
- Recipient information (if applicable)
- Transaction details (date, reference, type)
- QR code with transaction reference
- Footer with branding

## Localization

All strings are localized in:
- `lib/l10n/app_en_receipt.arb` (English)
- `lib/l10n/app_fr_receipt.arb` (French)

Run `flutter gen-l10n` after adding new strings.

## Integration Points

The share receipt functionality is integrated into:
1. **Transaction Detail Screen**: Share icon in app bar
2. **Send Success Screen**: "Share Receipt" button (TODO)
3. **Bill Payment Success Screen**: "Share Receipt" button (TODO)
4. **Transaction List**: Long-press menu (TODO)

## West African Context

WhatsApp is the **primary** sharing method in West Africa. The feature prioritizes WhatsApp sharing with:
- Prominent placement in share sheet
- Pre-filled professional message in French/English
- Direct deep link to WhatsApp app

## Dependencies

- `pdf: ^3.10.0` - PDF generation
- `share_plus: ^10.0.0` - System sharing
- `image_gallery_saver_plus: ^4.0.0` - Save to gallery
- `url_launcher: ^6.3.0` - WhatsApp deep link
- `qr_flutter: ^4.1.0` - QR code generation
- `path_provider: ^2.1.4` - Temporary file storage

## Testing

```bash
# Run all tests
flutter test test/features/receipts/

# Run specific test
flutter test test/features/receipts/services/receipt_service_test.dart
```

## Permissions

### Android (AndroidManifest.xml)

```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="28" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />
```

### iOS (Info.plist)

```xml
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Save receipt to photo gallery</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Access photos to save receipts</string>
```

## Performance Considerations

- Receipt images generated at 2x resolution for quality
- PDF generation is async and shows loading indicator
- Images cached in temporary directory, cleaned up by system
- QR codes generated on-demand

## Accessibility

- All buttons have semantic labels
- Loading states communicated to screen readers
- Success/error messages announced
- High contrast colors for status badges

## Future Enhancements

- [ ] Print receipt functionality
- [ ] Customizable receipt templates
- [ ] Batch receipt export
- [ ] Scheduled email receipts
- [ ] Receipt history/archive
