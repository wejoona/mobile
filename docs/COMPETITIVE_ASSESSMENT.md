# JoonaPay Competitive Assessment & Implementation Plan

Based on analysis of Wave Mobile Money, Coinbase, Apple Pay, and Google Pay.

## Executive Summary

| Feature Area | Wave | Coinbase | Apple/Google Pay | JoonaPay Status |
|-------------|------|----------|------------------|-----------------|
| Onboarding | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| Security | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| Send/Receive | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| Bill Pay | ⭐⭐⭐⭐⭐ | ❌ | ❌ | ❌ |
| QR Payments | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ |
| Agent Network | ⭐⭐⭐⭐⭐ | ❌ | ❌ | ❌ |
| Notifications | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ |
| Dashboard UX | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |

---

## 1. ONBOARDING & KYC

### Wave Approach
- **Phone-first registration** - Just phone number to start
- **QR cards for feature phones** - Works without smartphones
- **Agent-assisted onboarding** - 150,000+ agents help users sign up
- **Progressive KYC** - Basic features first, verify for higher limits

### Coinbase Approach
- **Tiered verification** - Basic → ID → Enhanced
- **Quick verification** - Typically completes in minutes
- **ID + Selfie scan** - Mobile-native verification
- **Withdrawal restrictions until verified**

### Apple/Google Pay Approach
- **Card-based onboarding** - Add existing card to start
- **Device Account Number** - Tokenization from start
- **Biometric requirement** - Face ID/Touch ID mandatory

### 🎯 JoonaPay Implementation

```
PRIORITY: HIGH

Current State:
- Phone + OTP registration ✓
- Basic KYC flow ✓

Gaps to Address:
1. [ ] Progressive KYC tiers (like Coinbase)
   - Tier 0: Phone only → $100/day limit
   - Tier 1: ID verification → $1,000/day limit
   - Tier 2: Enhanced (selfie + proof) → $10,000/day limit

2. [ ] Agent-assisted registration (like Wave)
   - Agent can register users via their app
   - QR code to link new user to agent

3. [ ] Faster verification feedback
   - Real-time ID scan validation
   - Instant selfie liveness detection
```

---

## 2. SECURITY

### Wave Approach
- **1 Wallet, 1 Device (1W1D)** - Wallet bound to single device
- **6-digit PIN** for transactions
- **Secret code** for recovery

### Coinbase Approach
- **Multiple 2FA methods** - Security keys > Authenticator > SMS
- **Withdrawal address whitelisting**
- **48-hour withdrawal delay for new addresses**
- **$255M crime insurance**
- **Vault with time-delayed withdrawals**

### Apple/Google Pay Approach
- **Tokenization** - Never exposes real card number
- **Biometric per transaction**
- **Secure Element** - Hardware-level encryption
- **Device-bound credentials**

### 🎯 JoonaPay Implementation

```
PRIORITY: CRITICAL

Current State:
- PIN protection ✓
- Biometric auth ✓
- Screenshot protection ✓
- Certificate pinning ✓

Gaps to Address:
1. [x] Withdrawal address whitelisting
   - Save trusted addresses
   - Require PIN for new addresses
   - 24-hour delay for large withdrawals to new addresses

2. [ ] Security keys support (like Coinbase)
   - Support hardware security keys via WebAuthn
   - Passkey support for iOS/Android

3. [ ] Vault feature (like Coinbase)
   - Time-locked savings
   - Require 48-hour notice for large withdrawals

4. [ ] Device binding (like Wave 1W1D)
   - One active device per account
   - Transfer requires verification
```

---

## 3. SEND & RECEIVE

### Wave Approach
- **Phone number transfers** - Send by phone number
- **QR code transfers** - Scan to pay
- **1% flat fee** - Simple pricing
- **Instant transfers** within network
- **Free deposits/withdrawals** at agents

### Coinbase Approach
- **Multiple networks** - ETH, Polygon, etc.
- **Username transfers** - Send to @username
- **ENS support** - Send to name.eth
- **Network fee estimates** before sending
- **Send max** button with fee calculation

### Apple/Google Pay Approach
- **Tap to Pay** - NFC payments
- **Instant notifications**
- **Transaction receipts**

### 🎯 JoonaPay Implementation

```
PRIORITY: HIGH

Current State:
- USDC transfers ✓
- Phone number lookup ✓
- QR code receive ✓

Gaps to Address:
1. [ ] Username/handle system (like Coinbase)
   - @username for easy transfers
   - Searchable within app

2. [ ] Contact favorites & recents
   - Quick access to frequent recipients
   - Recent transaction shortcuts

3. [ ] Send Max button
   - Calculate available after fees
   - One-tap to send maximum

4. [ ] Transfer scheduling
   - Recurring payments
   - Future-dated transfers

5. [ ] Request money feature
   - Send payment request link
   - QR code for requests
```

---

## 4. BILL PAYMENTS & AIRTIME

### Wave Approach
- **30+ internet providers** supported
- **Insurance payments**
- **Utility bills**
- **Airtime top-up** for all carriers
- **Zero fees** on bill payments

### 🎯 JoonaPay Implementation

```
PRIORITY: MEDIUM (Phase 2)

Current State:
- Not implemented

Implementation Plan:
1. [ ] Airtime top-up integration
   - Partner with mobile carriers in CI/US
   - Orange, MTN, Moov (CI)
   - Direct carrier API integration

2. [ ] Bill payment aggregator
   - Integrate with bill payment APIs
   - Electricity, water, internet
   - Start with CI utilities

3. [ ] Payment scheduling
   - Auto-pay recurring bills
   - Bill due date reminders
```

---

## 5. QR CODE PAYMENTS

### Wave Approach
- **Static QR** - Merchant displays QR
- **Dynamic QR** - Amount embedded
- **200,000+ merchant network**
- **Agent QR** for cash in/out

### 🎯 JoonaPay Implementation

```
PRIORITY: HIGH

Current State:
- Basic QR receive ✓
- QR scan to pay ✓

Gaps to Address:
1. [ ] Dynamic QR with amount
   - Generate QR with embedded amount
   - One-scan payment completion

2. [ ] Merchant QR standards
   - Support EMVCo QR format
   - Interoperability with other wallets

3. [ ] QR payment history
   - Save merchant from QR
   - Quick re-pay option
```

---

## 6. NOTIFICATIONS & ALERTS

### Coinbase Approach
- **Real-time price alerts** - Customizable thresholds
- **Transaction confirmations** - Instant push
- **Security alerts** - Login, withdrawal attempts
- **Watchlist alerts** - Price movements

### Apple/Google Pay Approach
- **Instant transaction notifications**
- **Receipt in notification**
- **Spending insights**

### 🎯 JoonaPay Implementation

```
PRIORITY: HIGH

Current State:
- Basic push notifications ✓
- Transaction alerts (partial)

Gaps to Address:
1. [ ] Rich notifications
   - Show amount in notification
   - Quick actions (view, share)

2. [ ] Price alerts (USDC/XOF rate)
   - Notify when rate is favorable
   - Custom threshold settings

3. [ ] Security notifications
   - New device login
   - Large transaction alerts
   - Failed login attempts

4. [ ] Weekly/monthly summaries
   - Spending breakdown
   - Savings progress
```

---

## 7. DASHBOARD & HOME SCREEN

### Best Practices from Research
- **Balance prominent** - Large, readable
- **Quick actions** - Send, Receive, Scan visible
- **Recent transactions** - No extra taps needed
- **Net worth visualization**
- **Spending summaries**

### 🎯 JoonaPay Implementation

```
PRIORITY: HIGH

Current State:
- Balance display ✓
- Quick actions ✓
- Transaction list ✓

Gaps to Address:
1. [ ] Balance breakdown
   - USDC balance
   - Local currency equivalent
   - Pending transactions

2. [ ] Smart shortcuts
   - "Pay [frequent contact] again"
   - "Your bill is due tomorrow"

3. [ ] Spending insights
   - Monthly comparison
   - Category breakdown
   - Savings goals progress

4. [ ] Transaction search & filter
   - Search by name, amount
   - Filter by date, type
```

---

## 8. AGENT/CASH NETWORK

### Wave Approach
- **150,000+ agents** across Africa
- **Free cash in/out**
- **Agent locator** in app
- **Agent training & support**
- **Commission-based model**

### 🎯 JoonaPay Implementation

```
PRIORITY: MEDIUM (Phase 2)

Current State:
- YellowCard integration (on/off-ramp)

Implementation Plan:
1. [ ] Agent locator
   - Map of nearby cash points
   - YellowCard agent locations
   - Operating hours

2. [ ] Cash code generation
   - Generate code to give agent
   - Time-limited for security
   - Works offline

3. [ ] Agent verification
   - Verify agent identity in app
   - Report suspicious agents
```

---

## 9. LEGAL & COMPLIANCE

### Coinbase Approach
- **Versioned documents** ✓
- **E-Sign consent** ✓
- **Per-jurisdiction terms**
- **Clear fee disclosure**

### 🎯 JoonaPay Implementation

```
PRIORITY: COMPLETE ✓

Implemented:
- [x] Versioned Terms of Service
- [x] Versioned Privacy Policy
- [x] API-driven legal docs
- [x] Consent tracking
- [x] Multi-locale (EN/FR)
```

---

## Implementation Roadmap

### Phase 1 (Current Sprint)
- [x] Country restrictions (USA, CI only)
- [x] Legal documents API
- [ ] Username/handle system
- [ ] Contact favorites
- [ ] Rich notifications
- [ ] Withdrawal address whitelisting

### Phase 2 (Next Sprint)
- [ ] Progressive KYC tiers
- [ ] Airtime top-up (CI)
- [ ] Bill payments (CI)
- [ ] Agent locator
- [ ] Price alerts

### Phase 3 (Future)
- [ ] Passkey/WebAuthn support
- [ ] Vault feature
- [ ] Recurring payments
- [ ] Spending insights
- [ ] Device binding (1W1D)

---

## Sources

- [Wave Mobile Money](https://www.wave.com/en/)
- [Wave Privacy Policy](https://www.wave.com/en/privacy/)
- [Coinbase Security](https://www.coinbase.com/security/login-security)
- [Coinbase KYC](https://www.coinbase.com/blog/know-your-customer-kyc-verification)
- [Apple Pay Security](https://support.apple.com/en-us/101554)
- [Mobile Wallet UX Design](https://mobbin.com/explore/mobile/screens/wallet-balance)
- [Fintech UX Best Practices](https://procreator.design/blog/best-fintech-ux-practices-for-mobile-apps/)
