# Mobile Money Deposit Flow

This module implements the mobile money deposit (on-ramp) flow for the JoonaPay wallet.

## Overview

Users can deposit XOF (CFA Franc) via mobile money providers and receive USD in their wallet. The flow handles:
- Amount input with XOF/USD toggle
- Provider selection (Orange Money, Wave, MTN MoMo)
- Payment instructions with USSD/deep link support
- Status tracking with auto-polling

## File Structure

```
lib/features/deposit/
├── models/
│   ├── deposit_request.dart          # Request model for initiating deposit
│   ├── deposit_response.dart         # Response with payment instructions
│   ├── exchange_rate.dart            # XOF/USD exchange rate model
│   └── mobile_money_provider.dart    # Provider enum with metadata
├── providers/
│   └── deposit_provider.dart         # Riverpod state management
├── views/
│   ├── deposit_amount_screen.dart    # Step 1: Amount input
│   ├── provider_selection_screen.dart # Step 2: Provider selection
│   ├── payment_instructions_screen.dart # Step 3: Payment instructions
│   └── deposit_status_screen.dart    # Step 4: Status confirmation
└── README.md

lib/services/deposit/
└── deposit_service.dart              # API service

lib/mocks/services/deposit/
└── deposit_mock.dart                 # Mock data for development
```

## Flow Steps

### 1. Amount Input (`deposit_amount_screen.dart`)
- Toggle between XOF and USD
- Real-time conversion using exchange rate
- Quick amount buttons
- Min/max validation (500 - 5,000,000 XOF)

**Route:** `/deposit/amount`

### 2. Provider Selection (`provider_selection_screen.dart`)
- Choose from Orange Money, Wave, or MTN MoMo
- Display fees per provider
- Show amount summary

**Route:** `/deposit/provider`

### 3. Payment Instructions (`payment_instructions_screen.dart`)
- Display payment reference number
- Show provider-specific instructions
- USSD code (for Orange Money, MTN)
- Deep link to open provider app
- 30-minute countdown timer
- Auto-refresh status every 10 seconds

**Route:** `/deposit/instructions`

### 4. Status Confirmation (`deposit_status_screen.dart`)
- Pending → Completed animation
- Show deposited amount (XOF) and received amount (USD)
- Retry on failure

**Route:** `/deposit/status`

## State Management

Uses Riverpod with `DepositNotifier`:

```dart
final depositProvider = NotifierProvider<DepositNotifier, DepositState>(
  DepositNotifier.new,
);
```

**State:**
- `amountXOF` / `amountUSD` - Current amount
- `selectedProvider` - Chosen payment provider
- `step` - Current flow step
- `response` - Payment instructions from API
- `isLoading` / `error` - Loading and error states

## API Endpoints

### Initiate Deposit
```
POST /api/v1/wallet/deposit
Body: { amount, currency: 'XOF', provider: 'orange_money' }
Response: { depositId, paymentInstructions, expiresAt }
```

### Check Status
```
GET /api/v1/wallet/deposit/:id
Response: { status: 'pending'|'completed'|'failed', amount, convertedAmount }
```

### Get Exchange Rate
```
GET /api/v1/wallet/exchange-rate?from=XOF&to=USD
Response: { fromCurrency, toCurrency, rate, timestamp }
```

## Provider Details

### Orange Money
- **USSD:** `#144#`
- **Deep Link:** `orangemoney://`
- **Fee:** 1.5%

### Wave
- **Deep Link:** `wave://`
- **Fee:** 0% (no fee)

### MTN MoMo
- **USSD:** `*133#`
- **Deep Link:** `momo://`
- **Fee:** 1.5%

## Mock Data

Mock exchange rate: **1 USD = 600 XOF**

Mock payment flow simulates 3-second processing delay and returns payment instructions.

Status polling randomly returns 'completed' (80%) or 'pending' (20%) to simulate real behavior.

## Localization

All strings are localized in English and French:
- `lib/l10n/app_en.arb`
- `lib/l10n/app_fr.arb`

Prefixed with `deposit_*`

## Usage

From Home screen:
```dart
context.push('/deposit/amount');
```

The flow automatically manages navigation between steps using the `DepositNotifier` state.

## West African Context

- Primary currency: XOF (CFA Franc)
- Target countries: Côte d'Ivoire, Senegal, Mali
- Mobile money is the dominant payment method
- Orange Money has the largest market share

## Notes

- Payment sessions expire after 30 minutes
- Status polling occurs every 10 seconds while on instructions screen
- Deep links launch the provider's mobile app if installed
- USSD codes can be dialed directly from the app
- All amounts are shown in both XOF and USD for transparency
