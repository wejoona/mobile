# Mobile SDK Service Endpoints - Updated

This document summarizes the updated backend endpoint paths for mobile SDK services.

## Updated Services

### 1. KYC Service (`/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/services/kyc/kyc_service.dart`)

**Updated Endpoints:**
- `POST /api/v1/kyc/submit` - Submit KYC documents
- `GET /api/v1/kyc/status` - Get KYC verification status
- `POST /api/v1/kyc/address` - Submit address verification
- `POST /api/v1/kyc/video` - Submit video verification
- `POST /api/v1/kyc/additional-documents` - Submit additional documents

**Backend Controller:** `/usdc-wallet/src/modules/kyc/application/controllers/kyc.controller.ts`

### 2. Deposit Service (`/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/services/deposit/deposit_service.dart`)

**Updated Endpoints:**
- `POST /wallet/deposit` - Initiate a deposit (mobile money to USDC)
- `GET /wallet/deposit/:depositId` - Get deposit status
- `GET /wallet/deposit/channels` - Get available deposit channels
- `GET /wallet/rate` - Get exchange rate quote

**Backend Controller:** `/usdc-wallet/src/modules/wallet/application/controllers/wallet.controller.ts`

### 3. Recurring Transfers Service (`/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/services/recurring_transfers/recurring_transfers_service.dart`)

**Endpoints (Already Correct):**
- `GET /recurring-transfers` - Get all recurring transfers
- `GET /recurring-transfers/:id` - Get single recurring transfer
- `POST /recurring-transfers` - Create recurring transfer
- `PATCH /recurring-transfers/:id` - Update recurring transfer
- `POST /recurring-transfers/:id/pause` - Pause recurring transfer
- `POST /recurring-transfers/:id/resume` - Resume recurring transfer
- `DELETE /recurring-transfers/:id` - Cancel recurring transfer
- `GET /recurring-transfers/:id/history` - Get execution history
- `GET /recurring-transfers/upcoming` - Get upcoming executions
- `GET /recurring-transfers/:id/next-dates` - Get next execution dates

**Backend Controller:** `/usdc-wallet/src/modules/recurring-transfers/application/controllers/recurring-transfer.controller.ts`

### 4. Bulk Payments Service (`/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/services/bulk_payments/bulk_payments_service.dart`)

**Endpoints (Already Correct):**
- `GET /bulk-payments/batches` - Get all batches
- `POST /bulk-payments/batches` - Submit new batch
- `GET /bulk-payments/batches/:id` - Get batch status
- `GET /bulk-payments/batches/:id/failed-report` - Download failed payments report

**Backend Controller:** `/usdc-wallet/src/modules/bulk-payments/application/controllers/bulk-payment.controller.ts`

### 5. Cards Service (`/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/services/cards/cards_service.dart`) **NEW**

**Endpoints:**
- `GET /api/v1/cards` - Get all cards
- `GET /api/v1/cards/:id` - Get single card
- `POST /api/v1/cards` - Create new card
- `PUT /api/v1/cards/:id/freeze` - Freeze card
- `PUT /api/v1/cards/:id/unfreeze` - Unfreeze card
- `PUT /api/v1/cards/:id/limit` - Update spending limit
- `DELETE /api/v1/cards/:id` - Cancel card

**Backend Controller:** `/usdc-wallet/src/modules/cards/application/controllers/card.controller.ts`

### 6. Bank Linking Service (`/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/services/bank_linking/bank_linking_service.dart`) **NEW**

**Endpoints:**
- `GET /api/v1/banks` - Get available banks
- `GET /api/v1/bank-accounts` - Get linked bank accounts
- `GET /api/v1/bank-accounts/:id` - Get single bank account
- `POST /api/v1/bank-accounts` - Link new bank account
- `POST /api/v1/bank-accounts/:id/verify` - Verify bank account with OTP
- `POST /api/v1/bank-accounts/:id/set-primary` - Set primary account
- `GET /api/v1/bank-accounts/:id/balance` - Get account balance
- `POST /api/v1/bank-accounts/:id/deposit` - Deposit from bank to wallet
- `POST /api/v1/bank-accounts/:id/withdraw` - Withdraw from wallet to bank
- `DELETE /api/v1/bank-accounts/:id` - Unlink bank account

**Backend Controller:** `/usdc-wallet/src/modules/bank-linking/application/controllers/bank-linking.controller.ts`

## Updated SDK

The main SDK file (`/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/services/sdk/usdc_wallet_sdk.dart`) has been updated to include all new services:

```dart
final sdk = ref.read(sdkProvider);

// KYC
await sdk.kyc.submitKyc(...);
final status = await sdk.kyc.getKycStatus();

// Deposits
final depositResponse = await sdk.deposits.initiateDeposit(...);
final channels = await sdk.deposits.getDepositChannels();

// Recurring Transfers
final recurring = await sdk.recurringTransfers.getRecurringTransfers();
await sdk.recurringTransfers.createRecurringTransfer(...);

// Bulk Payments
final batches = await sdk.bulkPayments.getBatches();
await sdk.bulkPayments.submitBatch(...);

// Cards
final cards = await sdk.cards.getCards();
await sdk.cards.createCard(...);
await sdk.cards.freezeCard(cardId);

// Bank Linking
final banks = await sdk.bankLinking.getBanks();
final accounts = await sdk.bankLinking.getLinkedAccounts();
await sdk.bankLinking.linkBankAccount(...);
await sdk.bankLinking.depositFromBank(...);
```

## Service Index

Updated `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/services/index.dart` to export all new services:

```dart
// Financial services
export 'deposit/deposit_service.dart';
export 'recurring_transfers/recurring_transfers_service.dart';
export 'bulk_payments/bulk_payments_service.dart';
export 'cards/cards_service.dart';
export 'bank_linking/bank_linking_service.dart';
export 'kyc/kyc_service.dart';
```

## Testing

All services have been analyzed and show no syntax errors. To test:

```bash
cd /Users/macbook/JoonaPay/USDC-Wallet/mobile
flutter analyze
flutter test
```

## Migration Notes

### KYC Service Changes

**Before:**
```dart
// Old paths
POST /user/kyc
GET /user/profile (for KYC status)
```

**After:**
```dart
// New paths - aligned with backend
POST /api/v1/kyc/submit
GET /api/v1/kyc/status
```

### Deposit Service Changes

**Before:**
```dart
// Old paths
POST /api/v1/wallet/deposit
GET /api/v1/wallet/exchange-rate?from=XOF&to=USD
```

**After:**
```dart
// New paths - aligned with backend
POST /wallet/deposit
GET /wallet/rate?sourceCurrency=XOF&targetCurrency=USD
GET /wallet/deposit/channels
```

## Next Steps

1. Update any UI code that directly calls service methods to ensure compatibility
2. Update mock services to match new endpoints
3. Test all flows end-to-end with backend
4. Update API documentation if needed

## Files Modified

1. `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/services/kyc/kyc_service.dart`
2. `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/services/deposit/deposit_service.dart`
3. `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/services/sdk/usdc_wallet_sdk.dart`
4. `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/services/index.dart`

## Files Created

1. `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/services/cards/cards_service.dart`
2. `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/services/bank_linking/bank_linking_service.dart`
