# Wallet Home Screen Implementation

## Overview
Enhanced wallet home screen with time-based greetings, balance hiding, 4 quick actions, KYC banner, and recent transactions.

## File Location
`/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/features/wallet/views/wallet_home_screen.dart`

## Features Implemented

### 1. Time-Based Greeting
```dart
String _getGreeting(AppLocalizations l10n) {
  final hour = DateTime.now().hour;
  if (hour >= 5 && hour < 12) return l10n.home_goodMorning;     // 5 AM - 12 PM
  if (hour >= 12 && hour < 17) return l10n.home_goodAfternoon; // 12 PM - 5 PM
  if (hour >= 17 && hour < 21) return l10n.home_goodEvening;   // 5 PM - 9 PM
  return l10n.home_goodNight;                                   // 9 PM - 5 AM
}
```

**Greetings:**
- Good morning (5:00-11:59)
- Good afternoon (12:00-16:59)
- Good evening (17:00-20:59)
- Good night (21:00-4:59)

### 2. Header Section
- **Greeting + User Name**: Time-based greeting with first name (if not phone)
- **Notification Bell**: Top right, navigates to `/notifications`
- **Settings Icon**: Top right, navigates to `/settings`

### 3. Balance Card
**Visual Design:**
- Gradient background with gold border glow
- Shadow effect with gold tint
- Responsive layout adapts to screen size

**Display Features:**
- **Primary Balance**: Large USDC amount with Playfair Display font
- **Hide/Show Toggle**: Eye icon to toggle balance visibility
- **Hidden State**: Shows `••••••` when hidden
- **USDC Badge**: Subtle badge showing currency type
- **Reference Currency**: Optional local currency equivalent (XOF)
- **Pending Balance**: Shows pending amount if > 0

**Animations:**
- Count-up animation on load (1.5s, easeOutCubic curve)
- Smooth transitions when toggling visibility

**Balance Formatting:**
- < 1,000: `$999.00`
- >= 1,000: `$1.2K`
- >= 1,000,000: `$1.2M`
- >= 1,000,000,000: `$1.2B`

**Persistence:**
- Balance visibility preference saved to SharedPreferences
- Restored on app restart

### 4. Quick Actions (4 Buttons)
Circular buttons in a row:

1. **Send** (`Icons.send_rounded`)
   - Navigate to `/send`

2. **Receive** (`Icons.qr_code_2_rounded`)
   - Navigate to `/receive`

3. **Deposit** (`Icons.add_circle_outline_rounded`)
   - Navigate to `/deposit`

4. **History** (`Icons.history_rounded`)
   - Navigate to `/transactions`

**Visual Design:**
- Gold gradient background on icon container
- Subtle shadow effect
- Responsive sizing
- Labels below icons

### 5. KYC Banner (Conditional)
**Display Conditions:**
- User is authenticated
- KYC status is NOT `verified`

**Visual Design:**
- Warning color background (yellow/amber)
- Warning icon (verified_user_outlined)
- Clear call-to-action

**Content:**
- Title: "Complete verification to unlock all features"
- Action: "Verify Now"
- Tap navigates to `/kyc`

**States:**
- `KycStatus.none` → Show banner
- `KycStatus.pending` → Show banner
- `KycStatus.rejected` → Show banner
- `KycStatus.verified` → Hide banner

### 6. Recent Transactions
**Display:**
- Section title: "Recent Activity"
- Shows last 3-5 transactions
- "See All" link navigates to `/transactions`

**Empty State:**
- Icon: receipt_long_outlined
- Title: "No Transactions Yet"
- Message: "Your recent transactions will appear here"

**Loading State:**
- Shows TransactionList with `isLoading: true`

**Error State:**
- Error icon and message
- Retry button (if applicable)

### 7. Pull-to-Refresh
- Refreshes wallet balance
- Refreshes transaction list
- Gold-colored indicator matching brand

### 8. Loading & Error States

**Loading State:**
- Shows card with CircularProgressIndicator
- Message: "Loading wallet..."

**Error State:**
- Error icon (error_outline)
- Error message from API
- Retry button triggers `walletStateMachine.refresh()`

**Create Wallet State:**
- Shows when `walletId` is empty
- Gold gradient icon
- "Activate Your Wallet" title
- Description explaining USDC wallet
- "Activate Wallet" button
- Creates wallet via POST `/wallet/create`

## State Management

### Providers Used
```dart
// Wallet state
final walletState = ref.watch(walletStateMachineProvider);

// Transaction state
final txState = ref.watch(transactionStateMachineProvider);

// User state
final userState = ref.watch(userStateMachineProvider);
final userName = ref.watch(userDisplayNameProvider);

// Currency display
final currencyState = ref.watch(currencyProvider);
```

### State Types
- `WalletStatus`: initial, loading, loaded, error, refreshing
- `AuthStatus`: initial, loading, authenticated, unauthenticated, otpSent, error
- `TransactionListStatus`: initial, loading, loaded, error
- `KycStatus`: none, pending, verified, rejected

## Localization

### English Strings (`app_en.arb`)
```json
"home_goodMorning": "Good morning"
"home_goodAfternoon": "Good afternoon"
"home_goodEvening": "Good evening"
"home_goodNight": "Good night"
"home_totalBalance": "Total Balance"
"home_hideBalance": "Hide balance"
"home_showBalance": "Show balance"
"home_quickAction_send": "Send"
"home_quickAction_receive": "Receive"
"home_quickAction_deposit": "Deposit"
"home_quickAction_history": "History"
"home_kycBanner_title": "Complete verification to unlock all features"
"home_kycBanner_action": "Verify Now"
"home_recentActivity": "Recent Activity"
"home_seeAll": "See All"
```

### French Strings (`app_fr.arb`)
```json
"home_goodMorning": "Bonjour"
"home_goodAfternoon": "Bon après-midi"
"home_goodEvening": "Bonsoir"
"home_goodNight": "Bonne nuit"
"home_totalBalance": "Solde total"
...
```

## API Endpoints Used

### GET /api/v1/wallet
Returns wallet balance and info:
```json
{
  "walletId": "uuid",
  "walletAddress": "0x...",
  "blockchain": "MATIC",
  "balances": [
    { "currency": "USD", "available": 1234.56, "pending": 0, "total": 1234.56 },
    { "currency": "USDC", "available": 1234.56, "pending": 0, "total": 1234.56 }
  ]
}
```

### GET /api/v1/wallet/transactions?limit=5
Returns recent transactions (limited to 5).

### GET /api/v1/user/profile
Returns user profile including KYC status:
```json
{
  "id": "uuid",
  "phone": "+225...",
  "firstName": "John",
  "lastName": "Doe",
  "kycStatus": "verified" | "pending" | "rejected" | "none"
}
```

### POST /api/v1/wallet/create
Creates a new wallet for the user.

## Navigation Routes

### Primary Routes
- `/home` - This screen (wallet home)
- `/send` - Send money flow
- `/receive` - Receive/QR code screen
- `/deposit` - Deposit funds screen
- `/transactions` - Transaction history
- `/kyc` - KYC verification flow
- `/settings` - Settings screen
- `/notifications` - Notifications screen

### Transaction Detail
- `/transactions/:id` - Single transaction detail

## Design System Usage

### Colors
```dart
AppColors.gold500          // Primary gold for balance
AppColors.obsidian         // Dark background
AppColors.textPrimary      // Main text
AppColors.textSecondary    // Labels
AppColors.textTertiary     // Hints
AppColors.warningBase      // KYC banner
AppColors.borderGold       // Card borders
```

### Typography
```dart
AppTextVariant.displayLarge     // Balance amount
AppTextVariant.headlineSmall    // User name
AppTextVariant.bodyMedium       // Greeting, labels
AppTextVariant.labelSmall       // Quick action labels
AppTextVariant.titleMedium      // Section titles
```

### Spacing
```dart
AppSpacing.screenPadding   // 20px - Screen edges
AppSpacing.cardPadding     // 20px - Card padding
AppSpacing.xxl             // 24px - Section gaps
AppSpacing.lg              // 16px - Large spacing
AppSpacing.md              // 12px - Medium spacing
AppSpacing.sm              // 8px - Small spacing
AppSpacing.xs              // 4px - Extra small
```

### Radius
```dart
AppRadius.xl               // 16px - Balance card
AppRadius.lg               // 12px - Quick actions
AppRadius.md               // 8px - Icon containers
AppRadius.full             // 9999 - Circular
```

## Performance Optimizations

### 1. Animation Controller
- Single controller for balance animation
- Proper disposal in `dispose()`
- 1.5s duration with easeOutCubic curve

### 2. Shared Preferences
- Async load on init
- Persists balance visibility preference
- No blocking operations

### 3. State Watching
- Only watches necessary providers
- Selective rebuilds on state changes

### 4. Pull-to-Refresh
- Parallel refresh of wallet and transactions
- Prevents duplicate requests

## Accessibility

### Features
- **Icon Tooltips**: All icon buttons have tooltips
- **Semantic Labels**: Proper text hierarchy
- **Touch Targets**: Minimum 48x48 for buttons
- **Color Contrast**: WCAG AA compliant
- **Screen Reader**: Proper text alternatives

### ARIA-like Patterns
```dart
IconButton(
  tooltip: 'Settings',
  // ...
)
```

## Testing Considerations

### Unit Tests
- Time-based greeting logic
- Balance formatting (K/M/B)
- Balance visibility toggle
- KYC banner display conditions

### Widget Tests
- Render with different states
- Pull-to-refresh interaction
- Quick action navigation
- Balance visibility toggle

### Integration Tests
- Full flow: load → display → refresh
- Navigation to all quick actions
- KYC banner interaction
- Transaction detail navigation

## Mock Data
Located in `/lib/mocks/services/wallet/`

```dart
// Mock balance
final mockBalance = WalletBalanceResponse(
  walletId: 'mock-wallet-id',
  walletAddress: '0x1234...5678',
  blockchain: 'MATIC',
  balances: [
    WalletBalance(currency: 'USD', available: 1234.56, pending: 0, total: 1234.56),
    WalletBalance(currency: 'USDC', available: 1234.56, pending: 0, total: 1234.56),
  ],
);
```

## Future Enhancements

### Potential Additions
1. **Balance Graphs**: Historical balance chart
2. **Quick Stats**: Daily spending, monthly income
3. **Promotions**: Feature announcement cards
4. **Shortcuts**: Customizable quick actions
5. **Insights**: AI-powered spending insights
6. **Goals**: Progress towards savings goals
7. **Rewards**: Loyalty points display

### A/B Test Opportunities
- Number of quick actions (3 vs 4 vs 5)
- Balance card style (gradient vs solid)
- KYC banner placement (top vs bottom)
- Transaction count (3 vs 5 vs 7)

## Related Files

### Views
- `/lib/features/wallet/views/home_view.dart` - Original home (can be replaced)
- `/lib/features/wallet/views/send_view.dart` - Send money
- `/lib/features/wallet/views/receive_view.dart` - Receive QR
- `/lib/features/wallet/views/deposit_view.dart` - Deposit funds

### Providers
- `/lib/features/wallet/providers/wallet_provider.dart` - Wallet operations
- `/lib/state/wallet_state_machine.dart` - Global wallet state
- `/lib/state/user_state_machine.dart` - Global user state
- `/lib/state/transaction_state_machine.dart` - Global transaction state

### Design System
- `/lib/design/tokens/colors.dart` - Color palette
- `/lib/design/tokens/typography.dart` - Text styles
- `/lib/design/tokens/spacing.dart` - Spacing scale
- `/lib/design/components/primitives/app_button.dart` - Button component
- `/lib/design/components/primitives/app_text.dart` - Text component
- `/lib/design/components/primitives/app_card.dart` - Card component
- `/lib/design/components/composed/transaction_list.dart` - Transaction list

### Localization
- `/lib/l10n/app_en.arb` - English strings
- `/lib/l10n/app_fr.arb` - French strings

## Usage

### In Router
```dart
GoRoute(
  path: '/home',
  pageBuilder: (context, state) => AppPageTransitions.fade(
    context,
    state,
    const WalletHomeScreen(),
  ),
),
```

### As Default Route
Set as the initial route after login:
```dart
if (userState.isAuthenticated) {
  return '/home';
}
```

## Commands

### Generate Localizations
```bash
cd /Users/macbook/JoonaPay/USDC-Wallet/mobile
flutter gen-l10n
```

### Run Tests
```bash
flutter test test/features/wallet/wallet_home_screen_test.dart
```

### Run App
```bash
flutter run
```

## Notes

### West African Context
- Currency reference: XOF (CFA Franc)
- Primary language: French (with English support)
- Mobile money integration ready
- Phone number formats: +225 XX XX XX XX (Côte d'Ivoire)

### Design Philosophy
- **Dark luxury**: Premium feel with dark backgrounds
- **Gold accents**: Achievement and value
- **Minimalist**: Focus on essential features
- **Responsive**: Adapts to all screen sizes
- **Accessible**: WCAG compliant
