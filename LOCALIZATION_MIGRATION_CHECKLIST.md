# Localization Migration Checklist

This document provides a checklist for migrating existing views to use the new i18n system.

## Status Overview

### ✅ Completed
- [x] Settings View (fully localized)
- [x] Language Selection View
- [x] Infrastructure (service, provider, ARB files)
- [x] Main app configuration

### 🔄 In Progress
- [ ] Other views (see priority list below)

### 📋 Not Started
- [ ] Error messages
- [ ] Toast/Snackbar messages
- [ ] API response messages

## Migration Priority

### Priority 1: Authentication Flow
**Impact:** First user experience, critical for onboarding

- [ ] **LoginView** (`lib/features/auth/views/login_view.dart`)
  - [ ] Title: "Welcome to JoonaPay"
  - [ ] Phone number label
  - [ ] Continue button
  - [ ] Error messages

- [ ] **OtpView** (`lib/features/auth/views/otp_view.dart`)
  - [ ] Title: "Enter OTP"
  - [ ] Subtitle: "We sent a code to..."
  - [ ] Verify button
  - [ ] Resend code

### Priority 2: Core Wallet Features
**Impact:** Primary app functionality

- [ ] **HomeView** (`lib/features/wallet/views/home_view.dart`)
  - [ ] Wallet section headers
  - [ ] Quick actions labels
  - [ ] Balance label

- [ ] **SendView** (`lib/features/wallet/views/send_view.dart`)
  - [ ] Title: "Send Money"
  - [ ] Amount label
  - [ ] Recipient label
  - [ ] Send button

- [ ] **ReceiveView** (`lib/features/wallet/views/receive_view.dart`)
  - [ ] Title: "Receive Money"
  - [ ] QR code instructions
  - [ ] Share button

- [ ] **DepositView** (`lib/features/wallet/views/deposit_view.dart`)
  - [ ] Title: "Deposit"
  - [ ] Instructions
  - [ ] Continue button

### Priority 3: Transactions
**Impact:** User history and tracking

- [ ] **TransactionsView** (`lib/features/transactions/views/transactions_view.dart`)
  - [ ] Title: "Transactions"
  - [ ] Filter labels
  - [ ] Empty state message

- [ ] **TransactionDetailView** (`lib/features/transactions/views/transaction_detail_view.dart`)
  - [ ] Status labels
  - [ ] Action buttons
  - [ ] Details labels

### Priority 4: Other Settings Views
**Impact:** User configuration

- [ ] **ProfileView** (`lib/features/settings/views/profile_view.dart`)
- [ ] **SecurityView** (`lib/features/settings/views/security_view.dart`)
- [ ] **KycView** (`lib/features/settings/views/kyc_view.dart`)
- [ ] **NotificationSettingsView** (`lib/features/settings/views/notification_settings_view.dart`)
- [ ] **LimitsView** (`lib/features/settings/views/limits_view.dart`)
- [ ] **HelpView** (`lib/features/settings/views/help_view.dart`)

### Priority 5: Additional Features
**Impact:** Enhanced functionality

- [ ] **ReferralsView**
- [ ] **BillPaymentsView**
- [ ] **MerchantPay views**
- [ ] **Alerts views**

## Migration Steps Per View

### 1. Import Localization
```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
```

### 2. Get Localizations Instance
```dart
final l10n = AppLocalizations.of(context)!;
```

### 3. Replace Hardcoded Strings

**Before:**
```dart
Text('Send Money')
```

**After:**
```dart
Text(l10n.wallet_sendMoney)
```

### 4. Add Missing Translation Keys

If key doesn't exist:

**In app_en.arb:**
```json
{
  "wallet_sendMoney": "Send Money",
  "@wallet_sendMoney": {
    "description": "Label for send money button"
  }
}
```

**In app_fr.arb:**
```json
{
  "wallet_sendMoney": "Envoyer de l'argent"
}
```

### 5. Test Both Languages
- Switch to French
- Navigate to view
- Verify all text is translated
- Check for layout issues (French text is longer)

## Translation Key Naming Convention

### Format
`{category}_{specificName}`

### Categories
- `navigation_` - Navigation labels
- `action_` - Buttons and actions
- `auth_` - Authentication
- `wallet_` - Wallet features
- `transaction_` - Transaction related
- `settings_` - Settings
- `error_` - Error messages
- `label_` - Form labels
- `title_` - Screen titles
- `message_` - User messages
- `status_` - Status indicators

### Examples
- ✅ `wallet_sendMoney` - Good
- ✅ `transaction_pending` - Good
- ❌ `sendMoney` - Missing category
- ❌ `SEND_MONEY` - Wrong case (use camelCase)

## Common Patterns

### Simple Text
```dart
// Before
AppText('Balance')

// After
AppText(l10n.wallet_balance)
```

### Button Labels
```dart
// Before
AppButton(label: 'Continue')

// After
AppButton(label: l10n.action_continue)
```

### AppBar Titles
```dart
// Before
appBar: AppBar(title: Text('Settings'))

// After
appBar: AppBar(title: Text(l10n.navigation_settings))
```

### Parameterized Text
```dart
// ARB file
{
  "greeting": "Hello, {name}!",
  "@greeting": {
    "placeholders": {
      "name": {"type": "String"}
    }
  }
}

// Usage
Text(l10n.greeting('John'))
```

### Conditional Text
```dart
// Before
Text(isActive ? 'Active' : 'Inactive')

// After
Text(isActive ? l10n.status_active : l10n.status_inactive)
```

## Checklist for Each View

- [ ] Import AppLocalizations
- [ ] Get l10n instance in build method
- [ ] Replace all visible strings
- [ ] Add missing keys to ARB files
- [ ] Test in English
- [ ] Test in French
- [ ] Check text overflow/wrapping
- [ ] Update any conditionals with localized strings
- [ ] Update any string constants
- [ ] Test error states
- [ ] Update tooltips and hints
- [ ] Update dialog messages

## Common Strings Inventory

### Already Available (58 keys)
See: `lib/l10n/app_en.arb` for complete list

### Needed for Priority 1 (Auth)
```
auth_welcome
auth_welcomeMessage
auth_enterPhoneNumber
auth_invalidPhoneNumber
auth_otpSent
auth_resendCode
auth_verifyingCode
auth_codeExpired
```

### Needed for Priority 2 (Wallet)
```
wallet_send
wallet_receive
wallet_deposit
wallet_withdraw
wallet_amount
wallet_recipient
wallet_selectRecipient
wallet_enterAmount
wallet_insufficientBalance
wallet_scanQr
wallet_shareQr
wallet_copyAddress
```

### Needed for Priority 3 (Transactions)
```
transaction_filter
transaction_all
transaction_incoming
transaction_outgoing
transaction_date
transaction_amount
transaction_status
transaction_details
transaction_id
transaction_fee
transaction_total
transaction_emptyState
```

## Testing Template

```dart
testWidgets('View displays localized text', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: YourView(),
      ),
    ),
  );

  // Test English (default)
  expect(find.text('Your English Text'), findsOneWidget);

  // Switch to French
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('fr'),
        home: YourView(),
      ),
    ),
  );

  // Test French
  expect(find.text('Votre Texte Français'), findsOneWidget);
});
```

## Layout Considerations

### Text Expansion
French text is typically 20-30% longer than English:
- "Settings" (8 chars) → "Paramètres" (10 chars) = +25%
- "Send Money" (10 chars) → "Envoyer de l'argent" (19 chars) = +90%

### Design Recommendations
1. **Use flexible layouts** - Avoid fixed widths
2. **Test with French** - Longest common language
3. **Allow text wrapping** - Use `maxLines` and `overflow`
4. **Increase spacing** - Give text room to breathe
5. **Responsive buttons** - Don't hardcode button widths

### Example
```dart
// Good: Flexible
Text(
  l10n.longText,
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
)

// Bad: Fixed
SizedBox(
  width: 100,
  child: Text(l10n.longText), // Will overflow
)
```

## Error Handling

### Missing Translation Key
**Error:** `NoSuchMethodError: The getter 'yourKey' was called on null`

**Solution:**
1. Add key to all ARB files
2. Run `flutter pub get`
3. Rebuild app

### Incorrect Parameter Type
**Error:** Type mismatch in placeholder

**Solution:**
1. Check ARB placeholder type matches usage
2. Cast parameter if needed

## Performance Notes

- ✅ Translations loaded once per locale
- ✅ No network calls (compiled in)
- ✅ Minimal memory overhead
- ✅ Hot reload works
- ⚠️ Adding keys requires rebuild

## Resources

### Documentation
- `/lib/services/localization/README.md` - Full i18n guide
- `/mobile/I18N_IMPLEMENTATION_SUMMARY.md` - Implementation details
- `/lib/features/settings/views/LANGUAGE_FEATURE_GUIDE.md` - Feature guide

### Files to Reference
- `lib/l10n/app_en.arb` - English translations
- `lib/l10n/app_fr.arb` - French translations
- `lib/features/settings/views/settings_view.dart` - Example migration

### Flutter Documentation
- https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization
- https://docs.flutter.dev/tools/arb

## Contribution Guidelines

### Adding New Translations
1. Add to English ARB first (source of truth)
2. Include `@key` metadata with description
3. Add to all other language ARBs
4. Use descriptive, namespaced keys
5. Include example in metadata if using placeholders

### Translation Quality
- Native speaker review preferred
- Context-appropriate translations
- Consistent terminology across app
- Respect cultural nuances

## Progress Tracking

### Completion Metrics
- Total views in app: ~40
- Views localized: 2 (5%)
- Translation keys: 58
- Languages: 2

### Goal
- Target: 100% view coverage
- Timeline: Progressive migration
- Priority: Critical user paths first

## Support

### Questions?
- Check `/lib/services/localization/README.md`
- Review Settings View implementation
- Run tests: `flutter test test/services/localization/`

### Issues?
- Missing key? Add to ARB files
- Layout issue? Adjust constraints
- Wrong translation? Update ARB file

## Summary

This migration is a progressive enhancement. Each view migrated improves the user experience for French-speaking users. Follow the priority order, test thoroughly, and maintain the high-quality standards established in the Settings View migration.
