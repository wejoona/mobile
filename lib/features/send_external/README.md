# External Transfer Feature

Send USDC to external wallet addresses (Coinbase, MetaMask, etc.) on Polygon or Ethereum networks.

## Overview

This feature enables users to send USDC from their JoonaPay wallet to any external wallet address. The crypto complexity is hidden - users only see USD amounts.

## Structure

```
lib/features/send_external/
├── models/
│   └── external_transfer_request.dart    # Request/response models, network enum
├── services/
│   └── external_transfer_service.dart    # Address validation, fee estimation
├── providers/
│   └── external_transfer_provider.dart   # State management
└── views/
    ├── address_input_screen.dart         # Step 1: Enter/scan address
    ├── external_amount_screen.dart       # Step 2: Amount & network selection
    ├── external_confirm_screen.dart      # Step 3: Review & confirm
    ├── external_result_screen.dart       # Step 4: Success/transaction details
    └── scan_address_qr_screen.dart       # QR scanner for addresses
```

## User Flow

1. **Address Input** (`/send-external`)
   - Enter wallet address manually
   - Paste from clipboard
   - Scan QR code
   - Real-time address validation
   - Network information

2. **Amount & Network** (`/send-external/amount`)
   - Enter USD amount
   - Select network (Polygon recommended, Ethereum)
   - View fee estimation
   - See total (amount + fee)

3. **Confirmation** (`/send-external/confirm`)
   - Review all details
   - Warning: irreversible transaction
   - Full address display (copyable)
   - Network, amount, fee breakdown

4. **Result** (`/send-external/result`)
   - Success confirmation
   - Transaction hash (copyable)
   - View on block explorer link
   - Share details

## Networks Supported

| Network  | Fee      | Time       | Status       |
|----------|----------|------------|--------------|
| Polygon  | ~$0.01   | 1-2 min    | Recommended  |
| Ethereum | ~$2-5    | 5-10 min   | Available    |

## Address Validation

- Must start with `0x`
- Must be 42 characters total
- Must contain only hex characters (0-9, a-f, A-F)
- Real-time validation feedback

## QR Code Support

Supports:
- Plain address: `0x1234...abcd`
- Ethereum URI: `ethereum:0x1234...abcd`

## API Endpoint

```
POST /api/v1/wallet/transfer/external
{
  "address": "0x...",
  "amount": 100.00,
  "network": "polygon"
}

Response:
{
  "transactionId": "ext_123",
  "txHash": "0xabc...",
  "status": "pending",
  "fee": 0.01,
  "network": "polygon"
}
```

## Mock Data

Mock service simulates:
- 3-second transfer delay
- Realistic transaction hashes
- Network-appropriate fees
- Pending status

## Localization

All strings in English (`app_en.arb`) and French (`app_fr.arb`):
- `sendExternal_*` keys

## Navigation

Routes:
- `/send-external` - Address input
- `/send-external/amount` - Amount & network
- `/send-external/confirm` - Confirmation
- `/send-external/result` - Result
- `/qr/scan-address` - QR scanner

## State Management

`ExternalTransferProvider` manages:
- Address validation
- Amount & network selection
- Fee estimation
- Transfer execution
- Result display

State persists across screens, resets after completion.

## Security Considerations

- Address validation prevents typos
- Warning message about irreversibility
- Full address displayed at confirmation
- Network clearly indicated
- Fee transparency

## Usage Example

```dart
// Navigate to external transfer flow
context.push('/send-external');

// Check provider state
final state = ref.watch(externalTransferProvider);

// Validate address
ref.read(externalTransferProvider.notifier).setAddress(address);

// Execute transfer
await ref.read(externalTransferProvider.notifier).executeTransfer();
```

## Testing

Mock mode enabled by default in debug:
- Test with any valid-format address
- Instant validation
- Simulated 3-second transfer
- Mock transaction hash generation

## Future Enhancements

- [ ] Address book for external addresses
- [ ] Recent external recipients
- [ ] More networks (BSC, Arbitrum)
- [ ] Gas price selection (fast/normal/slow)
- [ ] Transaction status tracking
- [ ] Push notification on completion
- [ ] ENS domain support
- [ ] Batch transfers
