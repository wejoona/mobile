# Receipt Sharing Integration Guide

How to integrate receipt sharing into various screens.

## 1. Transaction Detail Screen ✅ DONE

Already integrated in `/lib/features/transactions/views/transaction_detail_view.dart`

```dart
import '../../receipts/views/share_receipt_sheet.dart';

// In AppBar actions
IconButton(
  icon: const Icon(Icons.share),
  onPressed: () => ShareReceiptSheet.show(context, transaction),
),
```

## 2. Send Success Screen (TODO)

Add share button to send confirmation screen:

```dart
// In lib/features/send/views/send_success_view.dart

import '../../../features/receipts/views/share_receipt_sheet.dart';

// After success message, add button
AppButton(
  label: l10n.receipt_shareReceipt,
  onPressed: () => ShareReceiptSheet.show(context, transaction),
  variant: AppButtonVariant.secondary,
  icon: Icons.share,
  isFullWidth: true,
),
```

## 3. Bill Payment Success Screen (TODO)

Similar to send success:

```dart
// In lib/features/bill_payments/views/bill_payment_success_view.dart

import '../../../features/receipts/views/share_receipt_sheet.dart';

AppButton(
  label: l10n.receipt_shareReceipt,
  onPressed: () => ShareReceiptSheet.show(context, transaction),
  variant: AppButtonVariant.secondary,
  icon: Icons.share,
  isFullWidth: true,
),
```

## 4. Transaction List Long-Press (TODO)

Add context menu to transaction list items:

```dart
// In lib/features/transactions/widgets/transaction_list_item.dart

import '../../../features/receipts/views/share_receipt_sheet.dart';

GestureDetector(
  onLongPress: () => _showTransactionMenu(context, transaction),
  child: TransactionListItem(...),
)

void _showTransactionMenu(BuildContext context, Transaction transaction) {
  showModalBottomSheet(
    context: context,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Icon(Icons.info),
          title: Text('View Details'),
          onTap: () {
            Navigator.pop(context);
            context.push('/transaction/${transaction.id}');
          },
        ),
        ListTile(
          leading: Icon(Icons.share),
          title: Text('Share Receipt'),
          onTap: () {
            Navigator.pop(context);
            ShareReceiptSheet.show(context, transaction);
          },
        ),
      ],
    ),
  );
}
```

## 5. Merchant Payment Success (TODO)

For merchant QR payments:

```dart
// In lib/features/merchant_pay/views/payment_success_view.dart

AppButton(
  label: l10n.receipt_shareReceipt,
  onPressed: () => ShareReceiptSheet.show(context, transaction),
  variant: AppButtonVariant.secondary,
  icon: Icons.share,
)
```

## Direct Service Usage

If you need more control, use the service directly:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../receipts/providers/receipt_service_provider.dart';

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receiptService = ref.read(receiptServiceProvider);

    return AppButton(
      label: 'Share on WhatsApp',
      onPressed: () async {
        final success = await receiptService.shareViaWhatsApp(
          transaction: transaction,
        );

        if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('WhatsApp not installed')),
          );
        }
      },
    );
  }
}
```

## Customizing Share Message

```dart
await receiptService.shareReceipt(
  transaction: transaction,
  format: ReceiptFormat.image,
  customMessage: 'Here is proof of my payment - ${transaction.reference}',
);
```

## Sharing to Specific WhatsApp Contact

```dart
await receiptService.shareViaWhatsApp(
  transaction: transaction,
  phoneNumber: '+225XXXXXXXX', // Include country code
);
```

## Error Handling

```dart
try {
  await receiptService.shareReceipt(
    transaction: transaction,
    format: ReceiptFormat.pdf,
  );
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Failed to share receipt: $e'),
      backgroundColor: AppColors.errorBase,
    ),
  );
}
```

## Loading States

The ShareReceiptSheet handles loading states automatically, but if using service directly:

```dart
bool _isGenerating = false;

Future<void> _generateReceipt() async {
  setState(() => _isGenerating = true);

  try {
    final pdfBytes = await receiptService.generateReceiptPdf(transaction);
    // Handle PDF bytes
  } finally {
    setState(() => _isGenerating = false);
  }
}
```

## Testing Integration

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockReceiptService extends Mock implements ReceiptService {}

void main() {
  testWidgets('shows share receipt sheet', (tester) async {
    final mockService = MockReceiptService();

    when(() => mockService.shareViaWhatsApp(
      transaction: any(named: 'transaction'),
    )).thenAnswer((_) async => true);

    await tester.pumpWidget(MyApp(receiptService: mockService));
    await tester.tap(find.byIcon(Icons.share));
    await tester.pumpAndSettle();

    expect(find.text('Share Receipt'), findsOneWidget);
  });
}
```

## Performance Tips

1. **Don't generate receipts on widget build** - Only generate when user initiates sharing
2. **Use loading indicators** - Receipt generation can take 1-2 seconds
3. **Handle errors gracefully** - Show user-friendly messages
4. **Clean up temp files** - The service does this automatically, but be aware

## Accessibility

Ensure buttons have semantic labels:

```dart
Semantics(
  label: 'Share transaction receipt',
  child: IconButton(
    icon: Icon(Icons.share),
    onPressed: () => ShareReceiptSheet.show(context, transaction),
  ),
)
```
