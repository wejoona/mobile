# QR Payment - Usage Examples

## Table of Contents
1. [Basic QR Generation](#basic-qr-generation)
2. [Using QR Display Widget](#using-qr-display-widget)
3. [Parsing Scanned QR Codes](#parsing-scanned-qr-codes)
4. [Navigation Examples](#navigation-examples)
5. [Custom QR Implementations](#custom-qr-implementations)

## Basic QR Generation

### Generate Simple QR
```dart
import 'package:usdc_wallet/features/qr_payment/services/qr_code_service.dart';

final qrService = QrCodeService();

// Phone only
final qrData = qrService.generateReceiveQr(
  phone: '+22507123456',
);
// Result: {"type":"joonapay","version":1,"phone":"+22507123456"}
```

### Generate QR with Amount
```dart
final qrData = qrService.generateReceiveQr(
  phone: '+22507123456',
  amount: 50.00,
  currency: 'USD',
);
// Result: {"type":"joonapay","version":1,"phone":"+22507123456","amount":50.0,"currency":"USD"}
```

### Generate Complete QR
```dart
final qrData = qrService.generateReceiveQr(
  phone: '+22507123456',
  amount: 100.00,
  currency: 'USD',
  name: 'Jean Kouassi',
  reference: 'INVOICE-2024-001',
);
```

## Using QR Display Widget

### Simple QR Display
```dart
import 'package:usdc_wallet/features/qr_payment/widgets/qr_display.dart';

// In your widget build method:
QrDisplay(
  data: qrData,
  size: 200,
  title: 'Scan to Pay',
  subtitle: 'JoonaPay QR Code',
)
```

### QR with User Information
```dart
QrDisplayWithInfo(
  data: qrData,
  phone: '+22507123456',
  name: 'Jean Kouassi',
  amount: 50.00,
  currency: 'USD',
  size: 220,
)
```

### Custom Styled QR
```dart
QrDisplay(
  data: qrData,
  size: 180,
  backgroundColor: AppColors.charcoal,
  foregroundColor: AppColors.gold500,
  showBorder: true,
  padding: EdgeInsets.all(AppSpacing.xl),
  title: 'My Payment QR',
  footer: AppText(
    'Valid for 24 hours',
    variant: AppTextVariant.bodySmall,
    color: colors.textTertiary,
  ),
)
```

## Parsing Scanned QR Codes

### Parse and Validate
```dart
final qrService = QrCodeService();

// Check if valid
if (qrService.isValidQrData(scannedString)) {
  final data = qrService.parseQrData(scannedString);

  if (data != null) {
    print('Phone: ${data.phone}');
    print('Amount: ${data.amount}');
    print('Name: ${data.name}');
  }
}
```

### Handle Different Formats
```dart
final data = qrService.parseQrData(scannedString);

if (data != null) {
  // All formats are automatically converted to QrPaymentData
  switch (data.type) {
    case 'joonapay':
      // Standard JoonaPay QR
      navigateToSendView(data);
      break;
    default:
      // Unknown type
      showError('Unsupported QR type');
  }
}
```

### Extract and Use Data
```dart
void handleScannedQr(String scannedString) {
  final data = qrService.parseQrData(scannedString);

  if (data == null) {
    showSnackbar('Invalid QR code');
    return;
  }

  // Navigate to send view with prefilled data
  context.push('/send', extra: {
    'phone': data.phone,
    'amount': data.amount?.toString(),
    'reference': data.reference,
  });
}
```

## Navigation Examples

### From Home Screen
```dart
// Add to quick actions
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

### From Send View
```dart
// Add scan button to send view
AppButton(
  label: 'Scan QR Code',
  icon: Icons.qr_code_scanner,
  variant: AppButtonVariant.secondary,
  onPressed: () async {
    final result = await context.push('/qr/scan');
    if (result != null) {
      // Handle scanned result
    }
  },
),
```

### From Bottom Sheet
```dart
void showPaymentOptions(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) => Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.qr_code_scanner),
            title: Text('Scan QR Code'),
            onTap: () {
              Navigator.pop(context);
              context.push('/qr/scan');
            },
          ),
          ListTile(
            leading: Icon(Icons.qr_code),
            title: Text('Show My QR'),
            onTap: () {
              Navigator.pop(context);
              context.push('/qr/receive');
            },
          ),
        ],
      ),
    ),
  );
}
```

## Custom QR Implementations

### Merchant Static QR
```dart
class MerchantQrWidget extends ConsumerWidget {
  final String merchantId;
  final String merchantName;

  const MerchantQrWidget({
    required this.merchantId,
    required this.merchantName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qrService = QrCodeService();

    // Generate static QR for merchant
    final qrData = qrService.generateReceiveQr(
      phone: merchantId,
      name: merchantName,
      reference: 'MERCHANT-$merchantId',
    );

    return QrDisplayWithInfo(
      data: qrData,
      phone: qrService.formatPhone(merchantId),
      name: merchantName,
      size: 250,
    );
  }
}
```

### Invoice QR with Expiry
```dart
class InvoiceQrWidget extends StatelessWidget {
  final String invoiceNumber;
  final double amount;
  final DateTime expiryDate;

  const InvoiceQrWidget({
    required this.invoiceNumber,
    required this.amount,
    required this.expiryDate,
  });

  @override
  Widget build(BuildContext context) {
    final qrService = QrCodeService();
    final authState = ref.read(authProvider);

    final qrData = qrService.generateReceiveQr(
      phone: authState.phone ?? '',
      amount: amount,
      reference: invoiceNumber,
    );

    return Column(
      children: [
        QrDisplay(
          data: qrData,
          title: 'Invoice #$invoiceNumber',
          subtitle: '\$$amount USD',
        ),
        SizedBox(height: AppSpacing.md),
        AppText(
          'Expires: ${_formatDate(expiryDate)}',
          variant: AppTextVariant.bodySmall,
          color: AppColors.warningBase,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}
```

### Split Bill QR Generator
```dart
class SplitBillQrGenerator extends ConsumerWidget {
  final double totalAmount;
  final int numberOfPeople;

  const SplitBillQrGenerator({
    required this.totalAmount,
    required this.numberOfPeople,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final qrService = QrCodeService();

    final amountPerPerson = totalAmount / numberOfPeople;

    final qrData = qrService.generateReceiveQr(
      phone: authState.phone ?? '',
      amount: amountPerPerson,
      reference: 'SPLIT-BILL',
    );

    return Column(
      children: [
        AppCard(
          variant: AppCardVariant.elevated,
          child: Column(
            children: [
              AppText(
                'Split Bill',
                variant: AppTextVariant.titleMedium,
              ),
              SizedBox(height: AppSpacing.sm),
              AppText(
                'Total: \$$totalAmount',
                variant: AppTextVariant.bodyLarge,
              ),
              AppText(
                'Per person: \$${amountPerPerson.toStringAsFixed(2)}',
                variant: AppTextVariant.bodyMedium,
                color: context.colors.gold,
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        QrDisplay(
          data: qrData,
          size: 200,
          title: 'Scan to Pay Your Share',
        ),
      ],
    );
  }
}
```

### Request Money with QR
```dart
class RequestMoneyQrDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<RequestMoneyQrDialog> createState() => _RequestMoneyQrDialogState();
}

class _RequestMoneyQrDialogState extends ConsumerState<RequestMoneyQrDialog> {
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final qrService = QrCodeService();

    return Dialog(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              'Request Money',
              variant: AppTextVariant.titleLarge,
            ),
            SizedBox(height: AppSpacing.lg),

            AppInput(
              label: 'Amount',
              controller: _amountController,
              keyboardType: TextInputType.number,
              prefixText: '\$ ',
            ),
            SizedBox(height: AppSpacing.md),

            AppInput(
              label: 'Reference (Optional)',
              controller: _referenceController,
            ),
            SizedBox(height: AppSpacing.lg),

            if (_amountController.text.isNotEmpty)
              QrDisplay(
                data: qrService.generateReceiveQr(
                  phone: authState.phone ?? '',
                  amount: double.tryParse(_amountController.text),
                  reference: _referenceController.text.isEmpty
                      ? null
                      : _referenceController.text,
                ),
                size: 180,
              ),

            SizedBox(height: AppSpacing.lg),

            AppButton(
              label: 'Share QR',
              onPressed: () {
                // Share logic here
              },
              variant: AppButtonVariant.primary,
            ),
          ],
        ),
      ),
    );
  }
}
```

### Contact Card with QR
```dart
class ContactQrCard extends StatelessWidget {
  final String name;
  final String phone;
  final String? email;

  const ContactQrCard({
    required this.name,
    required this.phone,
    this.email,
  });

  @override
  Widget build(BuildContext context) {
    final qrService = QrCodeService();

    return AppCard(
      variant: AppCardVariant.elevated,
      child: Column(
        children: [
          // Profile section
          CircleAvatar(
            radius: 40,
            backgroundColor: context.colors.gold,
            child: Text(
              name[0].toUpperCase(),
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.textInverse,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md),

          AppText(name, variant: AppTextVariant.titleLarge),
          AppText(
            qrService.formatPhone(phone),
            variant: AppTextVariant.bodyMedium,
            color: context.colors.textSecondary,
          ),

          if (email != null) ...[
            SizedBox(height: AppSpacing.xs),
            AppText(
              email!,
              variant: AppTextVariant.bodySmall,
              color: context.colors.textTertiary,
            ),
          ],

          SizedBox(height: AppSpacing.xl),

          // QR Code
          QrDisplay(
            data: qrService.generateReceiveQr(phone: phone, name: name),
            size: 150,
            showBorder: false,
          ),

          SizedBox(height: AppSpacing.md),

          AppText(
            'Scan to send money',
            variant: AppTextVariant.labelSmall,
            color: context.colors.textTertiary,
          ),
        ],
      ),
    );
  }
}
```

## Utility Functions

### Copy QR Data to Clipboard
```dart
void copyQrToClipboard(String qrData) {
  Clipboard.setData(ClipboardData(text: qrData));

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('QR data copied to clipboard'),
      backgroundColor: AppColors.successBase,
    ),
  );
}
```

### Validate and Navigate
```dart
void handleQrScan(BuildContext context, String scannedData) {
  final qrService = QrCodeService();

  if (!qrService.isValidQrData(scannedData)) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invalid JoonaPay QR code'),
        backgroundColor: AppColors.errorBase,
      ),
    );
    return;
  }

  final data = qrService.parseQrData(scannedData)!;

  context.push('/send', extra: {
    'phone': data.phone,
    'amount': data.amount?.toString(),
    'reference': data.reference,
  });
}
```

### Format and Display
```dart
Widget buildQrInfo(QrPaymentData data) {
  final qrService = QrCodeService();

  return AppCard(
    variant: AppCardVariant.subtle,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Phone', qrService.formatPhone(data.phone)),
        if (data.name != null)
          _buildInfoRow('Name', data.name!),
        if (data.amount != null)
          _buildInfoRow('Amount', '\$${data.amount} ${data.currency ?? "USD"}'),
        if (data.reference != null)
          _buildInfoRow('Reference', data.reference!),
      ],
    ),
  );
}

Widget _buildInfoRow(String label, String value) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(label, variant: AppTextVariant.bodyMedium),
        AppText(value, variant: AppTextVariant.labelMedium),
      ],
    ),
  );
}
```

## Best Practices

1. **Always validate QR data** before processing
2. **Use the service layer** instead of parsing manually
3. **Handle null values** gracefully (amount, name, reference are optional)
4. **Format phone numbers** for display using `formatPhone()`
5. **Truncate long addresses** using `truncate()`
6. **Provide feedback** after QR actions (copy, share, save)
7. **Test with real devices** for camera and permissions

## Error Handling

```dart
try {
  final qrData = qrService.generateReceiveQr(phone: phone);
  // Use qrData
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Failed to generate QR: $e'),
      backgroundColor: AppColors.errorBase,
    ),
  );
}
```

```dart
final data = qrService.parseQrData(scannedString);

if (data == null) {
  // Invalid QR code
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Invalid QR Code'),
      content: Text('This is not a valid JoonaPay payment QR code.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK'),
        ),
      ],
    ),
  );
  return;
}

// Process valid data
processPaymentRequest(data);
```
