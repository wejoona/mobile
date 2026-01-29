# Virtual Cards Feature

This feature allows users to request and manage virtual debit cards for online purchases.

## Structure

```
lib/features/cards/
├── models/
│   └── virtual_card.dart         # Card and transaction models
├── views/
│   ├── cards_screen.dart         # Coming soon placeholder (legacy)
│   ├── cards_list_view.dart      # List of user's cards
│   ├── card_detail_view.dart     # Card details with CVV reveal
│   ├── request_card_view.dart    # Request new card (requires KYC Tier 2+)
│   ├── card_settings_view.dart   # Manage card limits, freeze/unfreeze
│   └── card_transactions_view.dart # Card transaction history
├── widgets/
│   └── virtual_card_widget.dart  # Card-like UI component
└── providers/
    └── cards_provider.dart       # State management
```

## Routes

- `/cards` - Cards list (bottom nav)
- `/cards/request` - Request new card
- `/cards/detail/:id` - Card details
- `/cards/settings/:id` - Card settings
- `/cards/transactions/:id` - Card transaction history

## Features

### Card Display
- Card-like UI with JoonaPay branding
- Masked card number: `**** **** **** 1234`
- Expiry date: `MM/YY`
- CVV with tap to reveal
- Freeze/active status indicator

### Request Card
- Requires KYC Level 2+ verification
- Cardholder name input
- Spending limit: $10 - $10,000
- Quick limit suggestions: $100, $500, $1000, $5000

### Card Management
- **Freeze/Unfreeze**: Instantly disable/enable card
- **Spending Limits**: View and update limits
- **Copy to Clipboard**: Card number, CVV, expiry
- **Block Card**: Permanently block (danger zone)

### Transactions
- View card purchase history
- Merchant name and category
- Transaction status (completed/pending/failed)
- Category icons for easy scanning

## State Management

Uses Riverpod with `CardsNotifier`:

```dart
final cardsProvider = NotifierProvider<CardsNotifier, CardsState>(
  CardsNotifier.new,
);
```

### State
- `isLoading`: Loading indicator
- `error`: Error message
- `cards`: List of virtual cards
- `selectedCard`: Current card being viewed
- `transactions`: Card transactions
- `canRequestCard`: Can request new card

### Actions
- `loadCards()`: Fetch user's cards
- `requestCard()`: Request new virtual card
- `freezeCard()`: Freeze card
- `unfreezeCard()`: Unfreeze card
- `updateSpendingLimit()`: Update card limit
- `loadCardTransactions()`: Fetch card transactions

## Mock Data

Mock implementation in `/lib/mocks/services/cards/cards_mock.dart`:

### Endpoints
- `GET /cards` - Get user's cards
- `POST /cards` - Request new card
- `GET /cards/:id` - Get card details
- `PUT /cards/:id/freeze` - Freeze card
- `PUT /cards/:id/unfreeze` - Unfreeze card
- `PUT /cards/:id/limit` - Update spending limit
- `GET /cards/:id/transactions` - Get card transactions

### Mock Features
- Generates random card numbers (starting with 4532)
- Generates random CVV (3 digits)
- Creates mock transactions for each card
- Validates spending limits ($10 - $10,000)
- Enforces 1 card per user limit

## Feature Flag

Controlled by `virtualCards` feature flag:

```dart
final featureFlags = ref.watch(featureFlagsProvider);
if (!featureFlags.virtualCards) {
  // Show feature disabled message
}
```

## Localization

All strings are localized in:
- `/lib/l10n/app_en.arb` (English)
- `/lib/l10n/app_fr.arb` (French)

Prefix: `cards_*`

## Security

- Requires authentication (all routes)
- KYC Level 2+ required to request cards
- CVV hidden by default (tap to reveal)
- Card number masked by default (tap to show full)
- PIN verification for sensitive operations (TODO)

## Usage Example

```dart
// Navigate to cards list
context.push('/cards');

// Request new card
context.push('/cards/request');

// View card details
ref.read(cardsProvider.notifier).selectCard(card);
context.push('/cards/detail/${card.id}');

// Freeze card
await ref.read(cardsProvider.notifier).freezeCard(cardId);
```

## TODOs

- [ ] Integrate with real API
- [ ] Add PIN verification for freeze/unfreeze
- [ ] Add card analytics (spending by merchant/category)
- [ ] Add virtual card issuance via API
- [ ] Add card delivery animations
- [ ] Add push notifications for transactions
- [ ] Add spending alerts when approaching limit
- [ ] Support multiple cards per user
- [ ] Add card themes/designs

## Testing

Run localization generator after any string changes:

```bash
cd mobile
flutter gen-l10n
```

## Dependencies

- `flutter_riverpod`: State management
- `go_router`: Navigation
- `flutter_localizations`: i18n support
