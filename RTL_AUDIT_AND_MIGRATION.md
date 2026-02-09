# RTL (Right-to-Left) Language Support - Audit and Migration Guide

## Executive Summary

This document audits the JoonaPay mobile app for RTL language readiness (Arabic, Hebrew, etc.) and provides a migration roadmap. The app currently uses LTR-only patterns that need conversion to directional equivalents.

**Status:** 🟡 Partial RTL Support
- ✅ Flutter's built-in RTL support enabled
- ✅ Localization infrastructure ready (ARB files)
- ❌ Hardcoded LTR padding/alignment throughout codebase
- ❌ Icon directionality not handled
- ❌ Custom components need RTL adaptation

**Effort Estimate:** 40-60 hours for full RTL compliance

---

## Table of Contents

1. [RTL Support Utilities](#rtl-support-utilities)
2. [Critical Issues Found](#critical-issues-found)
3. [Screen-by-Screen Audit](#screen-by-screen-audit)
4. [Component-Level Changes](#component-level-changes)
5. [Migration Roadmap](#migration-roadmap)
6. [Testing Strategy](#testing-strategy)
7. [Arabic Localization Checklist](#arabic-localization-checklist)

---

## RTL Support Utilities

New utility file created: `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/core/rtl/rtl_support.dart`

### Key Features

```dart
// Detection
RTLSupport.isRTL(context) // Check if current locale is RTL
context.isRTL // Extension method

// Directional Padding
RTLSupport.paddingStart(16.0) // Left in LTR, right in RTL
RTLSupport.paddingEnd(16.0)   // Right in LTR, left in RTL

// Directional Alignment
RTLSupport.alignmentStart(context) // AlignmentDirectional.centerStart
context.alignStart // Extension method

// Icons
RTLSupport.arrowForward(context) // arrow_forward in LTR, arrow_back in RTL
RTLSupport.arrowBack(context)

// RTL-Aware Widgets
DirectionalRow() // Auto-reverses children in RTL
DirectionalListTile() // Swaps leading/trailing in RTL
DirectionalIconButton() // Uses directional icons
```

### Usage Example

```dart
// Before (LTR-only)
Container(
  padding: EdgeInsets.only(left: 16),
  alignment: Alignment.centerLeft,
  child: Row(
    children: [
      Icon(Icons.arrow_forward),
      Text('Continue'),
    ],
  ),
)

// After (RTL-compatible)
Container(
  padding: EdgeInsetsDirectional.only(start: 16),
  alignment: AlignmentDirectional.centerStart,
  child: DirectionalRow(
    children: [
      Icon(RTLSupport.arrowForward(context)),
      Text('Continue'),
    ],
  ),
)
```

---

## Critical Issues Found

### 1. Hardcoded Left/Right Padding

**Severity:** 🔴 High
**Files Affected:** ~200+ widgets across all features
**Impact:** Text and elements will be misaligned in RTL

**Examples:**

```dart
// ❌ ISSUE: login_view.dart (line 91)
padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding)

// ✅ FIX:
padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.screenPadding)

// ❌ ISSUE: confirm_screen.dart (line 50)
Row(
  children: [
    CircleAvatar(...),
    SizedBox(width: AppSpacing.md),
    Expanded(child: Column(...)),
  ],
)

// ✅ FIX:
DirectionalRow(
  children: [
    CircleAvatar(...),
    SizedBox(width: AppSpacing.md),
    Expanded(child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, // ❌ Also needs fixing
    )),
  ],
)
```

### 2. Non-Directional Alignment

**Severity:** 🔴 High
**Files Affected:** ~150+ widgets
**Impact:** Content aligned to wrong edge in RTL

**Examples:**

```dart
// ❌ ISSUE: transaction_detail_view.dart (line 99)
Row(
  mainAxisAlignment: MainAxisAlignment.center, // ✅ OK (centered)
  children: [...],
)

// ❌ ISSUE: confirm_screen.dart (line 61)
Column(
  crossAxisAlignment: CrossAxisAlignment.start, // ❌ Should be directional
  children: [...],
)

// ✅ FIX:
Column(
  crossAxisAlignment: context.isRTL
    ? CrossAxisAlignment.end
    : CrossAxisAlignment.start,
  // OR use helper:
  crossAxisAlignment: RTLSupport.crossAlignmentStart(context),
  children: [...],
)
```

### 3. Directional Icons Not Handled

**Severity:** 🟡 Medium
**Files Affected:** Navigation, back buttons, arrows (~80 instances)
**Impact:** Arrows point wrong direction in RTL

**Examples:**

```dart
// ❌ ISSUE: transaction_detail_view.dart (line 34)
leading: IconButton(
  icon: const Icon(Icons.arrow_back),
  onPressed: () => context.pop(),
),

// ✅ FIX:
leading: IconButton(
  icon: Icon(RTLSupport.arrowBack(context)),
  onPressed: () => context.pop(),
),

// ❌ ISSUE: List items with chevrons
trailing: Icon(Icons.chevron_right), // ❌ Always points right

// ✅ FIX:
trailing: Icon(
  context.isRTL ? Icons.chevron_left : Icons.chevron_right,
),
```

### 4. AppInput Component Not RTL-Ready

**Severity:** 🔴 High (Core Component)
**File:** `lib/design/components/primitives/app_input.dart`
**Impact:** All text fields will have incorrect alignment

**Required Changes:**

```dart
// In AppInput widget, replace:
// - TextAlign.left → TextAlign.start
// - Icon positioning logic for prefixIcon/suffixIcon
// - Padding EdgeInsets → EdgeInsetsDirectional
```

### 5. AppButton Icon Positioning

**Severity:** 🟡 Medium
**File:** `lib/design/components/primitives/app_button.dart`
**Impact:** Icons will be on wrong side of text in RTL

**Required Changes:**

```dart
enum IconPosition {
  left,  // ❌ Replace with 'start'
  right, // ❌ Replace with 'end'
}

// Update icon layout logic to use Row with Directionality
```

---

## Screen-by-Screen Audit

### Priority 1: Core Flows (Must Fix for Arabic Launch)

#### 1.1 Authentication Flow
| Screen | File | Issues | Effort |
|--------|------|--------|--------|
| Login | `auth/views/login_view.dart` | - Phone input alignment<br>- Country picker layout<br>- Form field padding | 3h |
| OTP | `auth/views/login_otp_view.dart` | - OTP digit alignment<br>- Resend button position | 2h |
| Onboarding | `onboarding/views/onboarding_view.dart` | - Text alignment<br>- Navigation arrows<br>- Skip button position | 2h |

**Total:** 7 hours

#### 1.2 Home & Wallet
| Screen | File | Issues | Effort |
|--------|------|--------|--------|
| Home | `wallet/views/home_view.dart` | - Balance card layout<br>- Quick action buttons<br>- Transaction list items | 4h |
| Transaction Detail | `transactions/views/transaction_detail_view.dart` | - Detail rows<br>- Icon alignment<br>- Share button | 2h |

**Total:** 6 hours

#### 1.3 Send Money Flow
| Screen | File | Issues | Effort |
|--------|------|--------|--------|
| Recipient Selection | `send/views/recipient_screen.dart` | - Contact list items<br>- Search input<br>- Recent recipients | 3h |
| Amount Entry | `send/views/amount_screen.dart` | - Numeric keypad (OK)<br>- Currency symbol position | 2h |
| Confirmation | `send/views/confirm_screen.dart` | - Summary card layout<br>- Row alignments<br>- Edit buttons | 3h |
| PIN Entry | `send/views/pin_verification_screen.dart` | - PIN dots (OK, centered)<br>- Header text | 1h |
| Result | `send/views/result_screen.dart` | - Success icon (OK)<br>- Receipt button | 1h |

**Total:** 10 hours

### Priority 2: Secondary Flows

#### 2.1 Settings
| Screen | File | Issues | Effort |
|--------|------|--------|--------|
| Settings List | `settings/views/settings_view.dart` | - ListTile layout<br>- Icons and chevrons<br>- Section headers | 3h |
| Profile | `settings/views/profile_view.dart` | - Avatar position<br>- Edit fields | 2h |
| Security | `settings/views/security_view.dart` | - Toggle switches<br>- List items | 2h |
| Language | `settings/views/language_view.dart` | - Radio buttons<br>- Check marks | 1h |

**Total:** 8 hours

#### 2.2 Additional Features
| Feature | Screens | Estimated Effort |
|---------|---------|------------------|
| Bill Payments | 4 screens | 5h |
| QR Payment | 3 screens | 4h |
| Recurring Transfers | 4 screens | 5h |
| Beneficiaries | 3 screens | 3h |
| Merchant Pay | 4 screens | 4h |
| Insights | 2 screens | 3h |

**Total:** 24 hours

---

## Component-Level Changes

### Core Design System Components

#### AppInput (CRITICAL)
**File:** `lib/design/components/primitives/app_input.dart`
**Status:** ❌ Not RTL-ready

**Required Changes:**
```dart
// Line ~150 (TextFormField)
TextFormField(
  textAlign: TextAlign.start, // ❌ Change from left
  // Add textDirection property:
  textDirection: TextDirection.ltr, // Force LTR for phone numbers
  // OR respect locale:
  // textDirection: Directionality.of(context),
)

// Line ~80 (Prefix/Suffix)
// Swap logic for RTL:
prefixIcon: isRtl ? suffixIcon : prefixIcon,
suffixIcon: isRtl ? prefixIcon : suffixIcon,
```

**Migration Checklist:**
- [ ] Add `textDirection` parameter
- [ ] Convert EdgeInsets to EdgeInsetsDirectional
- [ ] Handle prefix/suffix swap for RTL
- [ ] Test with Arabic locale

#### AppButton
**File:** `lib/design/components/primitives/app_button.dart`
**Status:** 🟡 Partially compatible

**Required Changes:**
```dart
// Line ~40: Change enum
enum IconPosition {
  start, // Was: left
  end,   // Was: right
}

// Line ~150: Update icon layout
Row(
  textDirection: RTLSupport.getTextDirection(context),
  mainAxisSize: MainAxisSize.min,
  children: iconPosition == IconPosition.start
    ? [Icon(...), SizedBox(width: 8), Text(...)]
    : [Text(...), SizedBox(width: 8), Icon(...)],
)
```

#### AppCard
**File:** `lib/design/components/primitives/app_card.dart`
**Status:** ✅ Likely OK (padding should be symmetric)

**Verification Needed:**
- Check if any directional padding is used internally
- Test with RTL locale

#### AppText
**File:** `lib/design/components/primitives/app_text.dart`
**Status:** ✅ Should auto-adapt with TextDirection

**Testing Required:**
- Verify text alignment in RTL
- Check textAlign parameter handling

### Composed Components

#### Transaction List Item
**Files:** Various `*_card.dart` widgets
**Issues:**
- Leading/trailing icons
- Amount alignment
- Date/time formatting

**Example Fix:**
```dart
// Before
ListTile(
  leading: Icon(Icons.payment),
  title: Text(transaction.description),
  trailing: Text('\$${amount}'),
)

// After
DirectionalListTile(
  leading: Icon(Icons.payment),
  title: Text(transaction.description),
  trailing: Text('\$${amount}'), // Will auto-swap in RTL
)
```

---

## Migration Roadmap

### Phase 1: Foundation (Week 1)
**Goal:** Core infrastructure and critical components

1. **Day 1-2: Add Arabic Localization**
   - [ ] Create `lib/l10n/app_ar.arb` with 1053 strings
   - [ ] Add Arabic to `supportedLocales` in main.dart
   - [ ] Test locale switching

2. **Day 3: Update Core Components**
   - [ ] Fix AppInput for RTL
   - [ ] Fix AppButton icon positioning
   - [ ] Update AppCard if needed
   - [ ] Test all components in RTL mode

3. **Day 4-5: Design Tokens & Utilities**
   - [ ] Audit AppSpacing usage
   - [ ] Create RTL-specific spacing helpers if needed
   - [ ] Document RTL patterns in CLAUDE.md

### Phase 2: Core Flows (Week 2)
**Goal:** Essential user journeys work in RTL

4. **Day 6-7: Authentication**
   - [ ] Login screen
   - [ ] OTP screen
   - [ ] Onboarding

5. **Day 8-9: Home & Wallet**
   - [ ] Home screen layout
   - [ ] Transaction list
   - [ ] Transaction detail

6. **Day 10: Send Money Flow**
   - [ ] All 5 screens
   - [ ] Test end-to-end flow

### Phase 3: Secondary Features (Week 3-4)
**Goal:** Complete RTL coverage

7. **Day 11-13: Settings & Profile**
   - [ ] All settings screens
   - [ ] Profile editing
   - [ ] Security settings

8. **Day 14-16: Remaining Features**
   - [ ] Bill payments
   - [ ] QR payments
   - [ ] Recurring transfers
   - [ ] Beneficiaries

9. **Day 17-18: Polish & Testing**
   - [ ] Visual QA in Arabic
   - [ ] Edge case testing
   - [ ] Performance check

### Phase 4: Launch Prep (Week 5)
**Goal:** Production-ready

10. **Day 19-20: Comprehensive Testing**
    - [ ] Device testing (iOS/Android)
    - [ ] Accessibility audit with screen reader
    - [ ] Native Arabic speaker review

11. **Day 21: Documentation**
    - [ ] Update CLAUDE.md with RTL patterns
    - [ ] Create Arabic style guide
    - [ ] Document known issues

---

## Testing Strategy

### Automated Tests

#### 1. RTL Detection Tests
```dart
// test/core/rtl/rtl_support_test.dart
testWidgets('detects Arabic as RTL', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: Locale('ar'),
      home: Builder(builder: (context) {
        expect(RTLSupport.isRTL(context), true);
        return Container();
      }),
    ),
  );
});
```

#### 2. Component RTL Tests
```dart
// test/design/components/app_button_rtl_test.dart
testWidgets('AppButton icon position in RTL', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: Locale('ar'),
      home: AppButton(
        label: 'Submit',
        icon: Icons.check,
        iconPosition: IconPosition.start,
      ),
    ),
  );

  // Verify icon is on the right in RTL
  final iconFinder = find.byIcon(Icons.check);
  final textFinder = find.text('Submit');

  final iconPosition = tester.getTopRight(iconFinder).dx;
  final textPosition = tester.getTopRight(textFinder).dx;

  expect(iconPosition > textPosition, true);
});
```

#### 3. Golden Image Tests
```dart
// test/golden/rtl_golden_test.dart
testWidgets('Login screen RTL golden', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: Locale('ar'),
      home: LoginView(),
    ),
  );

  await expectLater(
    find.byType(LoginView),
    matchesGoldenFile('golden/login_rtl.png'),
  );
});
```

### Manual Testing Checklist

#### Device Testing Matrix
| Device | OS | Language | Status |
|--------|----|---------| -------|
| iPhone 15 Pro | iOS 17 | Arabic | ⬜ |
| iPad Pro 11" | iOS 17 | Arabic | ⬜ |
| Samsung Galaxy S23 | Android 14 | Arabic | ⬜ |
| Pixel 8 | Android 14 | Arabic | ⬜ |

#### Visual QA Checklist

**Per Screen:**
- [ ] Text aligned to correct edge
- [ ] Padding/margins correct
- [ ] Icons in correct positions
- [ ] Arrows point correct direction
- [ ] Numbers display correctly (Arabic-Indic vs Western)
- [ ] Currency symbols positioned correctly
- [ ] Scrolling feels natural
- [ ] Animations flow correctly

**Specific Elements:**
- [ ] Navigation bar items
- [ ] Tab bars
- [ ] List items with icons
- [ ] Forms with labels
- [ ] Buttons with icons
- [ ] Cards with multiple columns
- [ ] Date/time pickers
- [ ] Tooltips and dialogs

### Accessibility Testing

**Screen Reader Test (TalkBack/VoiceOver):**
- [ ] Navigate login flow
- [ ] Complete send money flow
- [ ] Read transaction details
- [ ] Navigate settings

**Expected Behavior:**
- Elements announced in correct order (right-to-left)
- Actions make sense in context
- No directional confusion

---

## Arabic Localization Checklist

### 1. Translation Requirements

**String Count:** 1053 keys (from `app_en.arb`)

**Special Considerations:**

#### Number Formatting
```dart
// Arabic uses Eastern Arabic numerals (٠١٢٣٤٥٦٧٨٩)
// BUT financial apps often use Western (0123456789)

// Decision needed:
// Option A: Use Eastern Arabic (culturally preferred)
NumberFormat.decimalPattern('ar_SA').format(1234.56)
// Output: ١٬٢٣٤٫٥٦

// Option B: Use Western (clearer for finance)
NumberFormat.decimalPattern('en_US').format(1234.56)
// Output: 1,234.56 (but RTL aligned)

// Recommendation: Use Western for amounts, Eastern for UI counters
```

#### Currency Position
```dart
// Arabic: ١٥٠٫٠٠ د.إ (amount before currency)
// English: $150.00 (symbol before amount)

// In app_ar.arb:
"wallet_balance": "{amount} دولار أمريكي",
// vs English:
"wallet_balance": "${amount} USD"
```

#### Date Formatting
```dart
// Arabic calendar options:
// 1. Gregorian (recommended for financial app)
DateFormat.yMMMMd('ar').format(date)
// Output: ٣٠ يناير ٢٠٢٦

// 2. Hijri (Islamic calendar - optional)
// Requires arabic_calendar package
```

#### Pluralization
```dart
// Arabic has 6 plural forms (vs 2 in English)
// In app_ar.arb:
"transaction_count": "{count, plural, zero{لا توجد معاملات} one{معاملة واحدة} two{معاملتان} few{{count} معاملات} many{{count} معاملة} other{{count} معاملة}}",

// Flutter ICU handles this automatically
```

### 2. Translation Style Guide

**Financial Terms:**
| English | Arabic | Notes |
|---------|--------|-------|
| Wallet | المحفظة | Literal "wallet" |
| Balance | الرصيد | |
| Transfer | تحويل | |
| Send | إرسال | |
| Receive | استلام | |
| Transaction | معاملة | |
| Fee | رسوم | |
| USDC | USDC | Keep acronym |

**UI Terms:**
| English | Arabic | Notes |
|---------|--------|-------|
| Continue | متابعة | Not "استمر" (too formal) |
| Cancel | إلغاء | |
| Confirm | تأكيد | |
| Back | رجوع | |
| Next | التالي | |
| Done | تم | |

**Tone:**
- Use Modern Standard Arabic (MSA) for maximum reach
- Keep informal/conversational (not classical)
- Avoid gender-specific language where possible
- Use second person (أنت) for direct address

### 3. West African Context

**Special Considerations for MENA Users:**

- **Phone Numbers:** +966, +971, +974, +965, +968 (Saudi, UAE, Qatar, Kuwait, Oman)
- **Currency Display:** SAR, AED, QAR (not XOF for Arabic users)
- **Mobile Money:** Less common; focus on bank transfers
- **Names:** Use Arabic name format (اسم العائلة اسم الشخص)

**app_ar.arb Additions:**
```json
{
  "country_saudi_arabia": "المملكة العربية السعودية",
  "country_uae": "الإمارات العربية المتحدة",
  "currency_sar": "ريال سعودي",
  "currency_aed": "درهم إماراتي"
}
```

---

## Known Limitations & Workarounds

### 1. Third-Party Packages

| Package | RTL Support | Workaround |
|---------|-------------|------------|
| `mobile_scanner` | ✅ Full | None needed |
| `fl_chart` | 🟡 Partial | Manually reverse axis labels |
| `timeago` | ✅ Has Arabic | Enable via `setLocaleMessages` |
| `intl` | ✅ Full | Use `Intl.defaultLocale = 'ar'` |
| `flutter_contacts` | ✅ Full | None needed |

### 2. Custom Layouts

**Problem:** Complex layouts with absolute positioning
**Example:** QR code overlay, PIN dots

**Workaround:**
```dart
// Use LayoutBuilder to calculate positions
LayoutBuilder(
  builder: (context, constraints) {
    final isRtl = context.isRTL;
    final startPosition = isRtl
      ? constraints.maxWidth - 100
      : 0;

    return Positioned(
      left: isRtl ? null : startPosition,
      right: isRtl ? startPosition : null,
      child: ...,
    );
  },
)
```

### 3. Animations

**Problem:** Slide transitions assume LTR
**Example:** Page transitions, drawer opening

**Workaround:**
```dart
// In app_router.dart, add directional slide:
SlideTransition(
  position: Tween<Offset>(
    begin: Offset(context.isRTL ? -1.0 : 1.0, 0.0),
    end: Offset.zero,
  ).animate(animation),
  child: child,
)
```

---

## Quick Reference: Common Patterns

### Pattern 1: Replacing EdgeInsets

```dart
// ❌ BEFORE
EdgeInsets.only(left: 16)
EdgeInsets.only(right: 16)
EdgeInsets.symmetric(horizontal: 16)

// ✅ AFTER
EdgeInsetsDirectional.only(start: 16)
EdgeInsetsDirectional.only(end: 16)
EdgeInsetsDirectional.symmetric(horizontal: 16) // Auto-converts
```

### Pattern 2: Replacing Alignment

```dart
// ❌ BEFORE
Alignment.centerLeft
Alignment.centerRight
Alignment.topLeft

// ✅ AFTER
AlignmentDirectional.centerStart
AlignmentDirectional.centerEnd
AlignmentDirectional.topStart
```

### Pattern 3: Row/Column CrossAxisAlignment

```dart
// ❌ BEFORE
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
)

// ✅ AFTER
Column(
  crossAxisAlignment: RTLSupport.crossAlignmentStart(context),
)
// OR
Column(
  crossAxisAlignment: context.isRTL
    ? CrossAxisAlignment.end
    : CrossAxisAlignment.start,
)
```

### Pattern 4: Icons in Rows

```dart
// ❌ BEFORE
Row(
  children: [
    Icon(Icons.arrow_forward),
    SizedBox(width: 8),
    Text('Next'),
  ],
)

// ✅ AFTER
DirectionalRow(
  children: [
    Icon(RTLSupport.arrowForward(context)),
    SizedBox(width: 8),
    Text('Next'),
  ],
)
```

### Pattern 5: ListTile with Icons

```dart
// ❌ BEFORE
ListTile(
  leading: Icon(Icons.settings),
  trailing: Icon(Icons.chevron_right),
  title: Text('Settings'),
)

// ✅ AFTER
DirectionalListTile(
  leading: Icon(Icons.settings),
  trailing: Icon(context.isRTL ? Icons.chevron_left : Icons.chevron_right),
  title: Text('Settings'),
)
```

---

## Resources

### Documentation
- [Flutter RTL Guide](https://docs.flutter.dev/development/accessibility-and-localization/internationalization#bidirectional-support)
- [Material Design RTL](https://m2.material.io/design/usability/bidirectionality.html)
- [Arabic Typography Best Practices](https://fonts.google.com/knowledge/glossary/arabic)

### Tools
- **Locale Switcher Widget:** Add debug menu to switch locales
- **RTL Toggle:** Add settings option to force RTL in LTR languages
- **Visual Diff Tool:** Compare LTR vs RTL screenshots

### Contact
- **Arabic Translation:** Hire professional translator (Upwork, Fiverr)
- **Native Review:** Contract Arabic-speaking QA tester
- **RTL Expert:** Consult with MENA mobile dev community

---

## Appendix: File Priority List

### Critical (Week 1-2)
```
lib/design/components/primitives/app_input.dart
lib/design/components/primitives/app_button.dart
lib/features/auth/views/login_view.dart
lib/features/auth/views/login_otp_view.dart
lib/features/wallet/views/home_view.dart
lib/features/send/views/*.dart (5 files)
lib/features/transactions/views/transaction_detail_view.dart
```

### High Priority (Week 2-3)
```
lib/features/settings/views/*.dart (10 files)
lib/features/beneficiaries/views/*.dart
lib/features/qr_payment/views/*.dart
lib/design/components/composed/*.dart
```

### Medium Priority (Week 3-4)
```
lib/features/bill_payments/views/*.dart
lib/features/recurring_transfers/views/*.dart
lib/features/merchant_pay/views/*.dart
lib/features/insights/views/*.dart
```

### Low Priority (Week 4-5)
```
lib/features/referrals/views/*.dart
lib/features/savings_pots/views/*.dart
lib/features/debug/*.dart
```

---

## Next Steps

1. **Immediate (Today):**
   - [ ] Review this audit with team
   - [ ] Decide on Arabic launch timeline
   - [ ] Approve RTL utilities implementation

2. **Short-term (This Week):**
   - [ ] Create `app_ar.arb` template
   - [ ] Send for translation
   - [ ] Begin Phase 1 of migration

3. **Medium-term (This Month):**
   - [ ] Complete core flows migration
   - [ ] Hire Arabic QA tester
   - [ ] Set up RTL CI checks

4. **Long-term (Next Quarter):**
   - [ ] Full RTL coverage
   - [ ] Arabic market launch
   - [ ] Consider Hebrew, Persian support

---

**Document Version:** 1.0
**Last Updated:** 2026-01-30
**Author:** Claude Code (Anthropic)
**Review Status:** Pending team review
