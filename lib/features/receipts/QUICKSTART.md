# Receipt Sharing - Quick Start

## Installation

From the `mobile/` directory:

```bash
./RECEIPT_SETUP.sh
```

This script will:
1. Merge localization strings into main .arb files
2. Clean up temporary files
3. Install dependencies (`pdf` package)
4. Generate localizations
5. Run code analysis

## Basic Usage

### Show Share Sheet (Recommended)

```dart
import 'package:usdc_wallet/features/receipts/views/share_receipt_sheet.dart';

// In your widget
IconButton(
  icon: Icon(Icons.share),
  onPressed: () => ShareReceiptSheet.show(context, transaction),
)
```

### Direct WhatsApp Share

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/receipts/providers/receipt_service_provider.dart';

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.read(receiptServiceProvider);

    return ElevatedButton(
      onPressed: () async {
        await service.shareViaWhatsApp(transaction: transaction);
      },
      child: Text('Share on WhatsApp'),
    );
  }
}
```

## Testing

1. **Run the app:**
   ```bash
   flutter run
   ```

2. **Navigate to transaction detail:**
   - Home → Transactions → Select any transaction

3. **Test share options:**
   - Tap share icon in app bar
   - Try each sharing method:
     - WhatsApp (requires WhatsApp installed)
     - Share as Image
     - Share as PDF
     - Save to Gallery
     - Email
     - Copy Reference

## What You Get

### Receipt Template

Professional receipt with:
- ✅ JoonaPay branding
- ✅ Status badge (Success/Pending/Failed)
- ✅ Amount breakdown (amount + fee = total)
- ✅ Recipient details (phone/address)
- ✅ Transaction metadata (date, reference, type)
- ✅ QR code for verification
- ✅ Scannable at 2x resolution

### Sharing Options

1. **WhatsApp** (Primary - highlighted)
   - Direct deep link
   - Pre-filled message in user's language
   - Critical for West African market

2. **Share as Image**
   - PNG format
   - System share sheet
   - Works with any app

3. **Share as PDF**
   - Professional PDF document
   - Smaller file size
   - Better for email/printing

4. **Save to Gallery**
   - Saves PNG to device photos
   - Shows success toast
   - Handles permissions automatically

5. **Email**
   - Opens default email client
   - Pre-filled subject and body
   - Attach receipt manually

6. **Copy Reference**
   - Quick copy transaction reference
   - Shows success toast

### Localization

Full bilingual support:
- English ✅
- French ✅

Strings auto-generated from .arb files.

## File Locations

```
mobile/lib/features/receipts/
├── models/
│   ├── receipt_data.dart          # Receipt data model
│   ├── receipt_format.dart        # Format enum
│   └── index.dart
├── services/
│   └── receipt_service.dart       # Core service
├── widgets/
│   └── receipt_widget.dart        # Visual template
├── views/
│   └── share_receipt_sheet.dart   # Share options UI
├── providers/
│   └── receipt_service_provider.dart
├── README.md                       # Full documentation
├── INTEGRATION_GUIDE.md            # Integration examples
├── QUICKSTART.md                   # This file
└── FILES_CREATED.md                # Complete file list
```

## Common Issues

### WhatsApp not opening

```dart
// Check if WhatsApp is installed
final success = await service.shareViaWhatsApp(transaction: transaction);
if (!success) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('WhatsApp not installed')),
  );
}
```

### Save to gallery fails

Check permissions in `AndroidManifest.xml` (Android) and `Info.plist` (iOS).

### PDF generation is slow

PDF generation can take 2-3 seconds. The share sheet shows loading indicator automatically.

### Localization not working

Run `flutter gen-l10n` after setup script.

## Next Steps

1. **Integrate into more screens:**
   - See `INTEGRATION_GUIDE.md` for examples
   - Add to send success, bill payment success, etc.

2. **Customize receipt template:**
   - Edit `receipt_widget.dart`
   - Adjust colors, layout, branding

3. **Add tests:**
   - Create `test/features/receipts/` directory
   - Test service methods
   - Test widget rendering

4. **Monitor usage:**
   - Track which share methods users prefer
   - Optimize based on analytics

## Support

- Feature docs: `README.md`
- Integration guide: `INTEGRATION_GUIDE.md`
- File listing: `FILES_CREATED.md`

## West African Optimization

This feature is optimized for West African markets:

✅ **WhatsApp Priority** - Most popular sharing method
✅ **Proof of Payment** - Professional receipts required
✅ **Bilingual** - French + English support
✅ **Mobile-First** - Optimized for mobile sharing
✅ **Offline** - Works without network connection
✅ **Low Data** - Efficient file sizes (PNG ~150KB, PDF ~75KB)
