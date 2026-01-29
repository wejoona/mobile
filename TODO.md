# JoonaPay Mobile App - Feature Roadmap

> Generated from Obsidian vault documentation analysis (2026-01-29)

## Architecture Context

### Database Schema Separation
The PostgreSQL database uses schema-based separation for domain isolation:

| Schema | Purpose | Tables |
|--------|---------|--------|
| `auth` | User authentication & security | `users`, `verifications`, `devices`, `sessions` |
| `wallet` | Core financial operations | `wallets`, `beneficiaries`, `transactions` |
| `merchant` | Merchant payment processing | merchant-specific tables |
| `payments` | Bill payments | bill payment records |
| `compliance` | AML, monitoring, alerts | compliance-related tables |
| `notifications` | Push notifications, preferences | notification settings |
| `referral` | Referral program | referral tracking |
| `social` | Contacts | contact syncing |
| `system` | Audit logs, feature flags, admin | `audit_logs`, `feature_flags` |

### Key Tables (Recently Implemented)

1. **auth.verifications** - OTP audit trail with multi-purpose verification
   - Supports: registration, login, pin_reset, phone_change, sensitive_action, two_factor
   - Status: pending → verified/expired/failed
   - Links to users via nullable user_id (for pre-registration flows)

2. **auth.devices** - Device trust management
   - Tracks: device_identifier, brand, model, os, platform, fcm_token
   - Trust status: is_trusted, trusted_at
   - Unique constraint: (user_id, device_identifier)

3. **auth.sessions** - Persistent session tracking
   - Links to: user_id, device_id
   - Stores: refresh_token_hash, ip_address, location
   - Supports: revocation with reason

4. **wallet.beneficiaries** - Saved recipients
   - Account types: joonapay_user, external_wallet, bank_account, mobile_money
   - Features: favorites, transfer_count, total_transferred tracking
   - Unique constraint: (wallet_id, phone_e164)

5. **system.feature_flags** - Controlled rollouts
   - Supports: percentage rollout, user whitelist/blacklist, country filter, platform filter
   - Semver version checking for min_app_version
   - Time windows: starts_at, ends_at

### Backend API Endpoints Available

```
# Devices
GET    /api/v1/devices              - List user's active devices
POST   /api/v1/devices/:id/trust    - Trust a device
DELETE /api/v1/devices/:id          - Revoke a device

# Sessions
GET    /api/v1/sessions             - List active sessions
DELETE /api/v1/sessions/:id         - Revoke a session
DELETE /api/v1/sessions             - Logout from all devices

# Beneficiaries
GET    /api/v1/beneficiaries        - List saved recipients (?favorites=true, ?recent=true)
POST   /api/v1/beneficiaries        - Add new beneficiary
PUT    /api/v1/beneficiaries/:id    - Update beneficiary
DELETE /api/v1/beneficiaries/:id    - Remove beneficiary
POST   /api/v1/beneficiaries/:id/favorite - Toggle favorite

# Feature Flags
GET    /api/v1/feature-flags/check/:key - Check if feature enabled for user
GET    /api/v1/feature-flags/me         - Get all flags for current context
```

### Tech Stack
- **Backend**: NestJS + TypeORM + PostgreSQL + Redis
- **Mobile**: Flutter + Riverpod
- **Crypto Infra**: Yellow Card API (handles custody, KYC, blockchain)
- **Ledger**: Blnk Finance (double-entry accounting)
- **Notifications**: Novu (planned)

### West African Context
- **Region**: Côte d'Ivoire (primary), Senegal, Mali
- **Currency**: XOF (CFA Franc), USD display (crypto hidden)
- **Mobile Money**: Orange Money, MTN MoMo, Wave
- **Language**: French (primary), English
- **Phone Format**: +225 XX XX XX XX XX

---

## Phase 1: Core USDC Wallet MVP (Sprints 1-2)

### 1.1 Phone Registration + OTP
- [ ] Phone input screen with country code picker (+225 default)
- [ ] OTP verification screen (6-digit code)
- [ ] Resend OTP with countdown timer
- [ ] Error handling for invalid/expired codes
- **API**: `POST /auth/register`, `POST /auth/verify-otp`
- **Backend table**: `auth.verifications`

### 1.2 KYC Flow
- [ ] KYC status indicator on home screen
- [ ] Document capture screen (camera integration)
- [ ] Real-time image quality feedback (blur/glare detection)
- [ ] Document type selection (passport, national ID, driver's license)
- [ ] Selfie capture with liveness detection guidance
- [ ] KYC pending/approved/rejected states
- **API**: `POST /user/kyc`, `GET /user/profile`
- **Provider**: Yellow Card handles actual KYC verification

### 1.3 USD Wallet View
- [ ] Balance display as "USD" (not USDC, no crypto terminology)
- [ ] Available vs pending balance
- [ ] Pull-to-refresh balance
- [ ] Balance history chart (optional)
- **API**: `GET /wallet`
- **Backend table**: `wallet.wallets`

### 1.4 Mobile Money Deposit (On-Ramp)
- [ ] Deposit amount input screen
- [ ] Mobile money provider selection (Orange Money, Wave, MTN)
- [ ] XOF → USD conversion preview with exchange rate
- [ ] Payment instructions display
- [ ] Deposit status tracking (pending → completed)
- **API**: `POST /wallet/deposit`, `GET /wallet/deposit/:id`
- **Provider**: Yellow Card on-ramp

### 1.5 Internal Transfer (Phone-to-Phone)
- [ ] Recipient phone input with validation
- [ ] Contact picker integration (phone contacts)
- [ ] Amount input with USD display
- [ ] Transfer confirmation screen
- [ ] PIN verification before sending
- [ ] Success/failure result screen
- **API**: `POST /wallet/transfer/internal`

### 1.6 External Transfer (Wallet Address)
- [ ] Recipient wallet address input
- [ ] QR code scanner for address
- [ ] Amount input
- [ ] Network fee preview
- [ ] Transfer confirmation
- **API**: `POST /wallet/transfer/external`

### 1.7 Transaction History
- [ ] Transaction list with infinite scroll
- [ ] Transaction type icons (deposit, send, receive)
- [ ] Status indicators (pending, completed, failed)
- [ ] Transaction detail screen
- [ ] Filter by type/date/status
- **API**: `GET /wallet/transactions`
- **Backend table**: `wallet.transactions`

---

## Phase 2: Security & Trust Layer (Sprints 3-4)

### 2.1 Device Management
- [ ] List of trusted devices screen
- [ ] Current device indicator
- [ ] Device details (brand, model, last login)
- [ ] Revoke device action with confirmation
- [ ] "Trust this device" flow after login
- **API**: `GET /devices`, `POST /devices/:id/trust`, `DELETE /devices/:id`
- **Backend table**: `auth.devices`

### 2.2 Active Sessions
- [ ] List of active sessions
- [ ] Session details (location, IP, last activity)
- [ ] Revoke individual session
- [ ] "Logout from all devices" action
- **API**: `GET /sessions`, `DELETE /sessions/:id`, `DELETE /sessions`
- **Backend table**: `auth.sessions`

### 2.3 Biometric Authentication
- [ ] Enable/disable biometric in settings
- [ ] Fingerprint/Face ID for app unlock
- [ ] Biometric for transaction confirmation
- [ ] Fallback to PIN
- **Package**: flutter_security_kit (already exists)
- **Feature flag**: `biometric_auth`

### 2.4 PIN Management
- [ ] Set PIN during onboarding
- [ ] Change PIN flow (verify old → set new)
- [ ] Reset PIN via OTP verification
- [ ] PIN lockout after failed attempts
- [ ] PIN strength indicator
- **Package**: flutter_pin_service (already exists)
- **Backend table**: `auth.users` (pin_hash, pin_attempts, pin_locked_until)

### 2.5 Beneficiary Management
- [ ] Saved beneficiaries list screen
- [ ] Add beneficiary form
- [ ] Edit beneficiary
- [ ] Delete beneficiary with confirmation
- [ ] Favorite/unfavorite toggle
- [ ] Search beneficiaries
- [ ] Recent beneficiaries section
- **API**: `GET /beneficiaries`, `POST /beneficiaries`, etc.
- **Backend table**: `wallet.beneficiaries`

---

## Phase 3: Payment Features (Sprints 5-6)

### 3.1 QR Code Payments
- [ ] Generate "Receive" QR code (with amount optional)
- [ ] QR code display screen (shareable)
- [ ] Scan QR to pay
- [ ] Camera permission handling
- [ ] Parse QR data and prefill transfer form
- **New module needed**

### 3.2 Payment Links
- [ ] Generate payment link for specific amount
- [ ] Copy link to clipboard
- [ ] Share via WhatsApp/SMS
- [ ] Payment link history
- [ ] Track link status (viewed, paid)
- **Backend needed**: Payment Link Service

### 3.3 Bill Payments
- [ ] Bill categories (utilities, airtime, internet)
- [ ] Biller search/selection
- [ ] Account number input
- [ ] Amount validation
- [ ] Payment confirmation
- [ ] Receipt generation
- **Feature flag**: `bill_payments`
- **Backend needed**: Bill Payments module

### 3.4 Recurring Transfers
- [ ] Schedule transfer UI
- [ ] Frequency selection (daily, weekly, monthly)
- [ ] Start/end date
- [ ] Manage scheduled transfers list
- [ ] Edit/cancel scheduled transfer
- **Backend needed**: Scheduled Transfers module

### 3.5 Transaction Receipts
- [ ] Generate receipt as image/PDF
- [ ] Share receipt via WhatsApp
- [ ] Email receipt
- [ ] Receipt history in transaction detail
- **Package**: pdf, share_plus

---

## Phase 4: Business Features (Sprints 7-8)

### 4.1 Business Account Mode
- [ ] Account type toggle (Personal/Business)
- [ ] Business profile setup
- [ ] Business verification (KYB)
- [ ] Switch between accounts
- **Backend needed**: Business account support

### 4.2 Sub-Business Management
- [ ] Create sub-business (department/branch)
- [ ] Sub-business wallet view
- [ ] Transfer between sub-businesses
- [ ] Role assignment for staff
- **Backend table**: Sub-business tables (planned)

### 4.3 Bulk Payments
- [ ] CSV file upload
- [ ] Preview payments list
- [ ] Batch approval workflow
- [ ] Batch status tracking
- [ ] Failed payments handling
- **Backend needed**: Bulk payment processing

### 4.4 Virtual Cards
- [ ] Request virtual card
- [ ] Card details display (masked)
- [ ] Copy card number/CVV
- [ ] Card spending limits
- [ ] Freeze/unfreeze card
- [ ] Card transactions list
- **Feature flag**: `virtual_cards` (to be added)
- **Provider**: Card issuing partner needed

### 4.5 Expense Management
- [ ] Receipt capture via camera
- [ ] OCR for receipt data extraction
- [ ] Expense categorization
- [ ] Expense reports generation
- [ ] Export to accounting
- **Backend needed**: Expense module

---

## Phase 5: Compliance & Advanced (Sprints 9+)

### 5.1 Transaction Limits
- [ ] Display daily/monthly limits
- [ ] Limit usage progress bar
- [ ] KYC tier upgrade prompt
- [ ] Limit reached messaging

### 5.2 Enhanced KYC Step-Up
- [ ] Prompt for additional docs when needed
- [ ] Video verification flow
- [ ] Address verification

### 5.3 Savings Pots
- [ ] Create savings pot with name/goal
- [ ] Transfer to/from pot
- [ ] Progress toward goal
- [ ] Pot withdrawal
- **Feature flag**: `savings_pots`

### 5.4 Spending Insights
- [ ] Spending by category chart
- [ ] Monthly spending trends
- [ ] Top recipients
- [ ] Spending alerts

### 5.5 Multi-Language Support
- [ ] French (primary)
- [ ] English
- [ ] Language picker in settings
- **Existing**: l10n already set up

### 5.6 Dark Mode
- [ ] System theme detection
- [ ] Manual toggle in settings
- [ ] Theme-aware components

### 5.7 Push Notifications
- [ ] Transaction notifications
- [ ] Security alerts
- [ ] Promotional notifications
- [ ] Notification preferences
- **Backend**: FCM token stored in `auth.devices`
- **Provider**: Novu (planned)

### 5.8 Bank Account Linking (NSIA Integration)
- [ ] Link bank account flow
- [ ] Bank balance display
- [ ] Direct deposit from bank
- [ ] Bank transfer withdrawal

---

## SDK Packages (Already Built)

| Package | Location | Purpose |
|---------|----------|---------|
| dio_performance_kit | mobile/packages/ | HTTP caching, request deduplication |
| flutter_security_kit | mobile/packages/ | Device security, attestation |
| flutter_pin_service | mobile/packages/ | PIN hashing, lockout logic |
| flutter_mock_api | mobile/packages/ | API mocking framework |

---

## Feature Flags to Implement

| Key | Name | Status |
|-----|------|--------|
| `two_factor_auth` | Two-Factor Authentication | false |
| `external_transfers` | External Wallet Transfers | true |
| `bill_payments` | Bill Payments | true |
| `savings_pots` | Savings Pots | false |
| `biometric_auth` | Biometric Authentication | true |
| `mobile_money_withdrawals` | Mobile Money Withdrawals | true |
| `virtual_cards` | Virtual Cards | false (to add) |
| `recurring_transfers` | Recurring Transfers | false (to add) |

---

## Notes

- **Yellow Card**: All crypto operations invisible to user. They see "USD", we use USDC behind the scenes.
- **Separate Entity**: USDC Wallet operates as separate legal entity from JoonaPay for regulatory clarity.
- **Primary Corridor**: Côte d'Ivoire → USA (Phase 1), CI → Europe (Phase 3)
- **WhatsApp Integration**: Critical for West African market - sharing receipts, payment links
