# User Onboarding Journey

## Visual Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          FIRST-TIME USER JOURNEY                        │
└─────────────────────────────────────────────────────────────────────────┘

                              ┌─────────────┐
                              │   SPLASH    │
                              │   SCREEN    │
                              └──────┬──────┘
                                     │
                       ┌─────────────┴─────────────┐
                       │                           │
                 [First Time]              [Returning User]
                       │                           │
              ┌────────▼────────┐         ┌────────▼────────┐
              │   ONBOARDING    │         │     LOGIN      │
              │    TUTORIAL     │         │     SCREEN     │
              │   (4 screens)   │         └────────┬────────┘
              └────────┬────────┘                  │
                       │                           │
              ┌────────▼─────────────────────────┬─┘
              │         LOGIN/REGISTER           │
              │  - Phone number entry            │
              │  - Country selection             │
              │  - Terms acceptance              │
              └────────┬─────────────────────────┘
                       │
              ┌────────▼────────┐
              │  OTP VERIFY     │
              │  - 6 digit code │
              │  - Auto-submit  │
              │  - Resend timer │
              └────────┬────────┘
                       │
              ┌────────▼────────┐
              │   PIN SETUP     │
              │  - Create PIN   │
              │  - Confirm PIN  │
              │  - Strength bar │
              └────────┬────────┘
                       │
                 [New User?]
                       │
        ┌──────────────┴──────────────┐
        │                             │
   [Yes - New]                   [No - Login]
        │                             │
 ┌──────▼──────┐              ┌──────▼──────┐
 │   WELCOME   │              │    HOME     │
 │   SCREEN    │              │  DASHBOARD  │
 │ - Confetti  │              └─────────────┘
 │ - Stats     │
 │ - 2 CTAs    │
 └──────┬──────┘
        │
 ┌──────▼──────┐
 │    HOME     │
 │  DASHBOARD  │
 └──────┬──────┘
        │
        │
┌───────▼──────────────────────────────────────────────────────────────┐
│                      POST-LOGIN EXPERIENCE                           │
└──────────────────────────────────────────────────────────────────────┘

        ┌─────────────┐
        │    HOME     │
        │  DASHBOARD  │
        └──────┬──────┘
               │
        [Has Balance?]
               │
    ┌──────────┴──────────┐
    │                     │
 [No]                  [Yes]
    │                     │
┌───▼──────────┐    ┌────▼─────────┐
│ FIRST DEPOSIT│    │   TOOLTIPS   │
│    PROMPT    │    │  (Optional)  │
│ - Benefits   │    │ - Send       │
│ - Dismiss    │    │ - Receive    │
│ - CTA        │    │ - Deposit    │
└───┬──────────┘    └────┬─────────┘
    │                    │
    │ [Add Funds]        │
    │                    │
┌───▼────────────────────▼───────────┐
│        DEPOSIT FLOW                │
│  1. Amount entry                   │
│  2. Provider selection             │
│  3. Payment instructions           │
│  4. Status tracking                │
└───┬────────────────────────────────┘
    │
    │ [Deposit Complete]
    │
┌───▼──────────┐
│  KYC PROMPT  │
│ - Why verify │
│ - Benefits   │
│ - Skip/Start │
└───┬──────────┘
    │
    │ [User Choice]
    │
┌───┴───────┐
│           │
[Skip]    [Start KYC]
│           │
│      ┌────▼────────┐
│      │  KYC FLOW   │
│      │ - Document  │
│      │ - Selfie    │
│      │ - Review    │
│      └────┬────────┘
│           │
└─────┬─────┘
      │
┌─────▼──────┐
│  ACTIVE    │
│   USER     │
└────────────┘
```

## User Personas & Journeys

### Persona 1: Amadou (First-Time User)
**Profile:** 28, small business owner in Abidjan, tech-savvy
**Goal:** Send money to suppliers quickly and cheaply

**Journey:**
1. Downloads app from friend's recommendation
2. Sees onboarding tutorial, swipes through all 4 screens
3. Registers with phone number +225 07 12 34 56 78
4. Verifies OTP
5. Creates PIN
6. Sees welcome screen with confetti
7. Clicks "Add Funds"
8. Deposits 50,000 XOF via Orange Money
9. Sees KYC prompt, clicks "Skip for Now"
10. Sends first payment to supplier
11. **Outcome:** Converted to active user within 30 minutes

**Friction Points:**
- Unsure about USDC → clicks "What is USDC?"
- Worried about fees → reads fee transparency page
- Hesitant about KYC → saves for later

### Persona 2: Fatou (Cautious User)
**Profile:** 42, teacher in Dakar, less tech-savvy
**Goal:** Receive remittances from family abroad

**Journey:**
1. Downloads app after family member sends link
2. Sees onboarding tutorial, reads every word
3. Registers with phone number
4. Struggles with OTP (checks SMS)
5. Creates PIN (tries weak PIN first)
6. Sees welcome screen, clicks "Explore Dashboard"
7. Dismisses first deposit prompt
8. Explores "What is USDC?" help page
9. Reads "How Deposits Work" guide
10. Gains confidence, adds first funds next day
11. **Outcome:** Converted after 24-hour consideration period

**Friction Points:**
- Needs reassurance about security
- Wants to understand everything before committing
- Asks support questions via help center

### Persona 3: Diallo (Returning Power User)
**Profile:** 35, freelancer in Bamako, early adopter
**Goal:** Manage multiple transactions efficiently

**Journey:**
1. Opens app after 2-day absence
2. Skips directly to login
3. Enters PIN (biometric enabled)
4. Lands on home dashboard
5. Checks balance
6. Initiates multiple transfers
7. **Outcome:** Frictionless re-engagement

**Experience:**
- No onboarding shown
- Familiar interface
- Quick access to core features

## Conversion Funnel Metrics

### Target Conversion Rates

```
100% - App Download
 90% - Onboarding Tutorial Started
 75% - Onboarding Tutorial Completed
 95% - Registration Started
 85% - OTP Verified
 80% - PIN Created
100% - Welcome Screen Viewed (new users)
 60% - First Deposit Initiated
 50% - First Deposit Completed
 20% - KYC Started (within 7 days)
 15% - KYC Completed (within 7 days)
 70% - Active User (1+ transaction/month)
```

### Key Drop-off Points

1. **Onboarding Tutorial → Registration: 20% drop**
   - Optimization: Reduce from 4 to 3 screens
   - Add "Get Started" CTA earlier

2. **Registration → OTP: 10% drop**
   - Optimization: Auto-read SMS
   - Better error messages
   - Phone number validation

3. **PIN Created → First Deposit: 40% drop**
   - Optimization: Stronger deposit prompt
   - Welcome screen CTA emphasis
   - Small incentive for first deposit

4. **First Deposit → KYC: 80% don't start**
   - Optimization: Defer KYC until needed
   - Show clear benefits
   - Progressive disclosure

## Contextual Help Triggers

### Automatic Triggers

| Trigger | Help Content | Timing |
|---------|-------------|--------|
| User views deposit screen first time | "How Deposits Work" guide | On screen load |
| User abandons deposit flow | Deposit prompt reappears | Next home visit |
| User balance > $100, no KYC | KYC benefit prompt | After 3rd transaction |
| User clicks fee amount | Fee transparency view | Immediate |
| User looks confused (3+ back taps) | Help center prompt | After 3rd back |
| First external transfer | "What is USDC?" link | During flow |

### Manual Access Points

| Location | Help Links |
|----------|-----------|
| Home screen | "What is USDC?", "How it Works" |
| Deposit screen | "Deposit Guide", "Fee Breakdown" |
| Send screen | "Transfer Types", "Fee Comparison" |
| Settings | Full help center, FAQs |
| Error states | Contextual troubleshooting |

## Emotional Journey Map

```
Excitement     │     ■■■■■                          ■■■■
               │       │                              │
Confidence     │ ■■■   │    ■■■■                 ■■■  │
               │   │   │      │                   │   │
Neutral        │───┼───┼──────┼──────────────────┼───┼────
               │   │   │      │    ■              │   │
Uncertainty    │   │   │      │  ■   ■            │   │
               │   │   │      │■       ■          │   │
Frustration    │   │   │      │         ■         │   │
               └───┴───┴──────┴──────────┴────────┴───┴────
               Download  OTP  Welcome  First    Active
                Tutorial       Screen  Deposit   Use

Key Moments:
■■■■■ Peak Excitement: Welcome screen with confetti
■■■■  High Confidence: After first successful transaction
■     Uncertainty: During deposit flow (first time)
■■    Slight Frustration: OTP delays
```

## Optimization Experiments

### Running/Planned A/B Tests

1. **Tutorial Length**
   - A: 4 screens (current)
   - B: 3 screens (condensed)
   - Metric: Registration completion rate

2. **Welcome Screen CTA**
   - A: "Add Funds" + "Explore Dashboard"
   - B: Single "Add Your First 5,000 XOF" CTA
   - Metric: First deposit rate

3. **Deposit Prompt Timing**
   - A: Immediate on home screen
   - B: After 2nd home screen visit
   - Metric: Dismissal rate vs conversion rate

4. **KYC Messaging**
   - A: "Verify Your Identity"
   - B: "Unlock Higher Limits"
   - Metric: KYC start rate

5. **Tooltip Sequence**
   - A: All features (5 tooltips)
   - B: Core features only (3 tooltips)
   - Metric: Completion rate + annoyance score

## Success Metrics Dashboard

### Real-Time Metrics
- Tutorial completion rate
- Registration success rate
- OTP delivery time
- Time to first deposit
- First deposit amount

### Weekly Metrics
- New user activations
- 7-day retention rate
- Average deposits per new user
- KYC completion rate
- Help content views

### Monthly Metrics
- Cohort retention (D1, D7, D30)
- Lifetime value by onboarding path
- Feature adoption rates
- Support ticket volume
- NPS by user segment

## Localization Considerations

### French (Primary)
- All onboarding content fully translated
- Cultural nuances respected
- Local examples (Amadou, Fatou, Diallo)
- Currency in XOF where relevant

### Future Languages
- Wolof (Senegal)
- Bambara (Mali)
- More West African languages

### Cultural Adaptations
- Mobile Money terminology
- Local payment habits
- Trust-building messaging
- Community-oriented language

---

**Version:** 1.0
**Last Updated:** 2026-01-29
**Owner:** Product & Engineering Teams
