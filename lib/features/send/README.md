# Send Money Feature

Internal transfer (send money) flow for JoonaPay USDC Wallet.

## Flow

```
RecipientScreen → AmountScreen → ConfirmScreen → PinVerificationScreen → ResultScreen
```

## Files

### Models (`models/`)
- `transfer_request.dart` - Transfer request DTOs and recipient info

### Providers (`providers/`)
- `send_provider.dart` - State management for send flow

### Views (`views/`)
- `recipient_screen.dart` - Select recipient (phone, contacts, beneficiaries)
- `amount_screen.dart` - Enter amount and optional note
- `confirm_screen.dart` - Review transfer details
- `pin_verification_screen.dart` - PIN/biometric verification
- `result_screen.dart` - Success/failure result with actions

### Widgets (`widgets/`)
- `recent_recipient_card.dart` - Display recent transfer recipients
- `pin_input_widget.dart` - 6-digit PIN input widget
- `contact_picker_bottom_sheet.dart` - Phone contacts picker
- `beneficiary_picker_bottom_sheet.dart` - Beneficiary picker

## Features

### Recipient Selection
- Manual phone number entry (+225 format)
- Select from phone contacts (permission handled)
- Select from saved beneficiaries
- Recent recipients list

### Amount Entry
- USD amount input with validation
- "MAX" button to use full balance
- Available balance display
- Optional note/memo field
- Fee calculation (currently $0 for internal)

### Confirmation
- Review all details before sending
- Edit buttons to go back to previous steps
- Fee breakdown if applicable

### PIN Verification
- 6-digit PIN entry
- Biometric option if available
- Error handling with retry

### Result
- Success animation
- Transaction details (amount, recipient, reference, date)
- Save as beneficiary option (if not already saved)
- Share receipt
- Copy reference number

## API Endpoint

```
POST /transfers/internal
Body: {
  "recipientPhone": "+225XXXXXXXXXX",
  "amount": 100.00,
  "note": "Optional memo"
}
```

## Localization

All strings are localized in:
- `lib/l10n/app_en.arb` (English)
- `lib/l10n/app_fr.arb` (French)

Keys prefixed with `send_*`

## Navigation Routes

```dart
/send          // RecipientScreen
/send/amount   // AmountScreen
/send/confirm  // ConfirmScreen
/send/pin      // PinVerificationScreen
/send/result   // ResultScreen
```

## Dependencies

- `permission_handler` - Contact permissions
- `flutter_contacts` - Access phone contacts
- `local_auth` - Biometric authentication
- `share_plus` - Share receipt functionality
- `flutter_pin_service` (package) - PIN hashing and verification

## Mocks

Mock data available in `lib/mocks/services/transfers/transfers_mock.dart`
- Registered in `MockRegistry`
- Simulates successful transfers
- Dev mode enabled by default

## Usage

```dart
// Navigate to send flow
context.push('/send');

// Or from quick action
AppButton(
  label: "Send Money",
  onPressed: () => context.push('/send'),
)
```

## State Management

Uses Riverpod with `SendMoneyNotifier`:
- Manages recipient, amount, note
- Validates phone format and balance
- Executes transfer via TransfersService
- Handles errors and loading states

## Testing

```bash
flutter test test/features/send/
```

## Future Enhancements

- Schedule transfers
- Recurring transfers
- Multi-currency support
- Split payments
- Request money (reverse flow)
