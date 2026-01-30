# Onboarding Flow Documentation

## Overview

The JoonaPay mobile app features a comprehensive onboarding system designed to:
- Introduce new users to key features
- Build trust through transparency
- Reduce friction in the registration-to-first-transaction journey
- Provide contextual help and guidance

## User Journey

```
Splash Screen
    ↓
Onboarding Tutorial (4 screens) [if first time]
    ↓
Login / Registration
    ↓
OTP Verification
    ↓
PIN Setup
    ↓
Welcome Post-Login Screen [if new user]
    ↓
Home Dashboard
    ↓
First Deposit Prompt [if no balance]
    ↓
Guided Tooltips [optional]
    ↓
KYC Encouragement [after first deposit]
```

## Components

### 1. Enhanced Onboarding View
**File:** `lib/features/onboarding/views/enhanced_onboarding_view.dart`

**Features:**
- 4 beautifully animated screens
- Smooth page transitions
- Skip option
- Animated progress indicators
- Gradient-based icon backgrounds with glow effects
- Feature lists on each page

**Pages:**
1. **Your Money, Your Way**
   - Store, send, receive USDC
   - Features: Safe storage, instant sending, 24/7 access

2. **Lightning-Fast Transfers**
   - Instant transfers explained
   - Features: Internal transfers, Mobile Money support, real-time updates

3. **Easy Deposits & Withdrawals**
   - Mobile Money integration
   - Features: Multiple providers, low fees, anytime withdrawal

4. **Bank-Level Security**
   - Security features
   - Features: PIN/biometric, encryption, fraud monitoring

### 2. Welcome Post-Login Screen
**File:** `lib/features/onboarding/views/welcome_post_login_view.dart`

**Features:**
- Confetti animation on arrival
- Personalized greeting with user name
- Quick stats about the wallet
- Two CTAs: "Add Funds" and "Explore Dashboard"
- Elastic scale animations

**When Shown:**
- Immediately after successful registration
- Only shown once per user

### 3. First Deposit Prompt
**File:** `lib/features/onboarding/widgets/first_deposit_prompt.dart`

**Features:**
- Eye-catching gradient card
- Three key benefits listed
- Dismissible
- Tracked in onboarding progress
- Direct CTA to deposit flow

**When Shown:**
- On home screen when balance is zero
- Can be dismissed (won't show again)

### 4. Feature Tooltips
**File:** `lib/features/onboarding/widgets/feature_tooltip.dart`

**Features:**
- Overlay-based guidance
- Sequential tooltip support
- Skip and Next buttons
- Animated entrance
- Dark overlay for focus

**Usage:**
```dart
// Define tooltip sequence
final tooltips = TooltipSequence(tooltips: [
  FeatureTooltipData(
    title: 'Send Money',
    description: 'Tap here to send money to friends',
    alignment: Alignment.topCenter,
    offset: Offset(0, 100),
  ),
  // ... more tooltips
]);

// Show tooltip
if (mounted && showTooltip) {
  showDialog(
    context: context,
    builder: (context) => FeatureTooltip(
      title: tooltips.current.title,
      description: tooltips.current.description,
      alignment: tooltips.current.alignment,
      offset: tooltips.current.offset,
      onDismiss: () {
        tooltips.skip();
        Navigator.pop(context);
      },
      onNext: tooltips.hasNext ? () {
        tooltips.next();
        Navigator.pop(context);
        // Show next tooltip
      } : null,
    ),
  );
}
```

### 5. Contextual Help Screens

#### USDC Explainer
**File:** `lib/features/onboarding/views/help/usdc_explainer_view.dart`

**Sections:**
- What is USDC?
- Why use USDC? (4 benefits)
- How it works
- Safety information

**Access:**
- From home screen help menu
- Link in deposit flow
- Settings > Help

#### Deposits Guide
**File:** `lib/features/onboarding/views/help/deposits_guide_view.dart`

**Sections:**
- Step-by-step deposit process
- Supported Mobile Money providers
- Processing time information
- FAQ (minimum deposit, fees, failed deposits)

**Access:**
- From deposit screen
- Settings > Help

#### Fees Transparency
**File:** `lib/features/onboarding/views/help/fees_transparency_view.dart`

**Sections:**
- "No Hidden Fees" banner
- Complete fee breakdown
- Why we charge fees
- Comparison with traditional services

**Access:**
- From any transaction screen
- Settings > Help

## State Management

### Onboarding Progress Provider
**File:** `lib/features/onboarding/providers/onboarding_progress_provider.dart`

**Tracked State:**
- `hasSeenTutorial`: Boolean
- `hasCompletedFirstDeposit`: Boolean
- `hasCompletedFirstTransfer`: Boolean
- `hasSeenKycPrompt`: Boolean
- `hasSeenTooltips`: Boolean
- `dismissedPrompts`: Set of prompt IDs
- `firstLoginAt`: DateTime

**Methods:**
- `markTutorialCompleted()`
- `markFirstDepositCompleted()`
- `markFirstTransferCompleted()`
- `markKycPromptSeen()`
- `markTooltipsSeen()`
- `dismissPrompt(String promptId)`
- `setFirstLogin()`
- `resetProgress()`

**Computed Properties:**
- `isNewUser`: User registered within last 7 days
- `shouldShowDepositPrompt`: No deposit + prompt not dismissed
- `shouldShowKycPrompt`: Has deposit but hasn't seen KYC prompt
- `shouldShowTooltips`: Has deposit but hasn't seen tooltips

## Integration Points

### 1. Splash Screen
```dart
// Check if onboarding tutorial completed
final hasSeenOnboarding = await ref.read(
  onboardingProgressProvider.select((s) => s.hasSeenTutorial)
);

if (!hasSeenOnboarding) {
  context.go('/onboarding');
} else {
  context.go('/login');
}
```

### 2. After Successful Registration
```dart
// After OTP verification and PIN setup
if (isNewRegistration) {
  context.go('/welcome-post-login');
} else {
  context.go('/home');
}
```

### 3. Home Screen
```dart
// Show first deposit prompt
if (ref.watch(onboardingProgressProvider).shouldShowDepositPrompt) {
  FirstDepositPrompt()
}

// Show KYC prompt
if (ref.watch(onboardingProgressProvider).shouldShowKycPrompt) {
  KycPromptBanner()
}
```

### 4. After First Deposit
```dart
// Mark deposit completed
await ref.read(onboardingProgressProvider.notifier)
  .markFirstDepositCompleted();

// Show KYC encouragement
if (ref.read(onboardingProgressProvider).shouldShowKycPrompt) {
  _showKycDialog();
}
```

## Localization

All onboarding strings are fully localized in English and French:

### Key Strings:
- `onboarding_page{1-4}_title`
- `onboarding_page{1-4}_description`
- `onboarding_page{1-4}_feature{1-3}`
- `welcome_title(name)`
- `welcome_subtitle`
- `onboarding_deposit_prompt_*`
- `help_usdc_*`
- `help_deposits_*`
- `help_fees_*`

## Animations

### 1. Page Transitions
- **Type:** Fade + Slide
- **Duration:** 400ms
- **Curve:** easeOutCubic

### 2. Icon Entrance
- **Type:** Elastic scale
- **Duration:** 800ms
- **Curve:** elasticOut

### 3. Welcome Screen
- **Confetti:** 3 seconds, explosive blast
- **Scale:** Elastic, 1200ms
- **Fade:** 500ms ease-in

### 4. Tooltips
- **Scale:** 0.8 to 1.0
- **Opacity:** 0 to 1
- **Duration:** 400ms
- **Curve:** easeOutCubic

## Design Principles

### 1. Gradual Disclosure
- Show features progressively
- Don't overwhelm new users
- Contextual help when needed

### 2. Visual Hierarchy
- Clear CTAs with gradient buttons
- Contrast for important elements
- Consistent spacing and alignment

### 3. Trust Building
- Transparent fee breakdown
- Clear explanations of USDC
- Security features highlighted

### 4. West African Context
- Mobile Money front and center
- Local currency references (XOF)
- Cultural sensitivity in messaging

### 5. Performance
- Lazy loading of help screens
- Efficient state persistence
- Minimal re-renders

## Conversion Optimization

### Key Metrics to Track:
1. **Tutorial Completion Rate**
   - % of users who finish all 4 screens
   - Skip rate per screen

2. **Time to First Deposit**
   - Average time from registration to first deposit
   - Drop-off points

3. **Help Content Engagement**
   - Most viewed help articles
   - Time spent on help screens

4. **KYC Conversion**
   - % of users who complete KYC after prompt
   - Timing of KYC completion

5. **Feature Discovery**
   - Tooltip completion rate
   - Features used within first 7 days

### Optimization Strategies:

**A/B Testing Opportunities:**
- Number of onboarding screens (3 vs 4)
- Skip button placement
- CTA button copy
- Deposit prompt timing
- Incentive messaging

**Friction Reduction:**
- One-tap deposit from welcome screen
- Pre-filled phone number in deposit
- Progressive KYC (basic → full)
- Smart defaults based on country

**Engagement Hooks:**
- Welcome bonus for first deposit
- Referral reward mention
- Social proof (# of users)
- Local success stories

## Future Enhancements

### Planned Features:
1. **Interactive Tutorial**
   - Sandbox mode for trying features
   - Guided tour with actual UI elements

2. **Video Explainers**
   - Short videos for USDC, deposits, security
   - Localized in French and local languages

3. **Gamification**
   - Onboarding checklist with rewards
   - Achievement badges
   - Streak tracking

4. **Personalization**
   - Country-specific onboarding
   - Use case selection (personal/business)
   - Customized feature recommendations

5. **AI Assistant**
   - Chatbot for onboarding questions
   - Contextual help suggestions
   - Proactive assistance

### Technical Debt:
- Add analytics tracking to all screens
- Implement screenshot testing
- Add accessibility labels
- Optimize animation performance
- Add unit tests for providers

## Testing Checklist

### Manual Testing:
- [ ] Tutorial screens display correctly
- [ ] Skip button works on all screens
- [ ] Page indicator updates correctly
- [ ] Animations are smooth (60fps)
- [ ] Welcome screen shows confetti
- [ ] First deposit prompt appears
- [ ] Deposit prompt can be dismissed
- [ ] Tooltips overlay correctly
- [ ] Help screens load quickly
- [ ] All strings localized in FR
- [ ] Back navigation works
- [ ] State persists across app restarts

### Automated Testing:
- [ ] Unit tests for onboarding provider
- [ ] Widget tests for all views
- [ ] Integration tests for full flow
- [ ] Golden tests for UI consistency
- [ ] Performance profiling

## Accessibility

### Implemented:
- Semantic labels on all interactive elements
- High contrast ratios (WCAG AA)
- Large touch targets (44x44dp minimum)
- Screen reader support
- Reduced motion option (TODO)

### TODO:
- Voice over testing
- Dynamic type support
- Keyboard navigation
- Focus indicators
- Alternative text for all icons

## Support & Troubleshooting

### Common Issues:

**Tutorial not showing:**
- Check `onboarding_tutorial` SharedPreferences key
- Verify splash screen routing logic
- Clear app data to reset

**Progress not saving:**
- Check SharedPreferences write permissions
- Verify state mutations in provider
- Look for race conditions

**Animations janky:**
- Profile with Flutter DevTools
- Check for unnecessary rebuilds
- Optimize image sizes

**Strings not translated:**
- Run `flutter gen-l10n`
- Check ARB file syntax
- Verify locale selection

---

**Last Updated:** 2026-01-29
**Version:** 1.0.0
**Maintained By:** JoonaPay Engineering Team
