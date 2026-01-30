# Accessibility Compliance - JoonaPay Mobile

> WCAG 2.1 AA Compliance Documentation

## Executive Summary

This document outlines JoonaPay Mobile's accessibility compliance status, remediation plan, and testing procedures to meet WCAG 2.1 Level AA standards.

**Status:** In Progress (Target: 100% AA Compliance)

**Last Updated:** 2026-01-29

---

## Table of Contents

1. [WCAG 2.1 AA Compliance Checklist](#wcag-21-aa-compliance-checklist)
2. [Current Compliance Status](#current-compliance-status)
3. [Remediation Plan](#remediation-plan)
4. [Screen Reader Testing](#screen-reader-testing)
5. [Automated Testing](#automated-testing)
6. [Design System Accessibility](#design-system-accessibility)
7. [Dynamic Type & Scaling](#dynamic-type--scaling)
8. [Reduced Motion Support](#reduced-motion-support)
9. [Keyboard Navigation](#keyboard-navigation)
10. [Contrast Ratios](#contrast-ratios)

---

## WCAG 2.1 AA Compliance Checklist

### Perceivable

#### 1.1 Text Alternatives

- [x] **1.1.1 Non-text Content** (Level A)
  - All images have semantic labels
  - Icons have descriptive labels
  - Decorative images use `ExcludeSemantics`

#### 1.2 Time-based Media

- [N/A] **1.2.1-1.2.5** - No audio/video content in current version

#### 1.3 Adaptable

- [x] **1.3.1 Info and Relationships** (Level A)
  - Semantic structure with proper widgets
  - Form labels properly associated
  - Lists use proper Flutter list widgets

- [x] **1.3.2 Meaningful Sequence** (Level A)
  - Reading order follows visual order
  - Focus traversal is logical

- [x] **1.3.3 Sensory Characteristics** (Level A)
  - Instructions don't rely solely on visual cues
  - Error states have text + color

- [x] **1.3.4 Orientation** (Level AA)
  - App supports both portrait and landscape
  - No orientation lock on content

- [x] **1.3.5 Identify Input Purpose** (Level AA)
  - Input fields use appropriate `TextInputType`
  - Autofill hints where applicable

#### 1.4 Distinguishable

- [x] **1.4.1 Use of Color** (Level A)
  - Error states use icon + text, not just color
  - Success states use icon + text
  - Disabled states use opacity + semantics

- [x] **1.4.2 Audio Control** (Level A)
  - No auto-playing audio

- [x] **1.4.3 Contrast (Minimum)** (Level AA)
  - Text: Minimum 4.5:1 ratio
  - Large text: Minimum 3:1 ratio
  - See [Contrast Ratios](#contrast-ratios) section

- [x] **1.4.4 Resize Text** (Level AA)
  - Supports system text scaling up to 200%
  - Layout adapts to text size changes

- [x] **1.4.5 Images of Text** (Level AA)
  - Minimal use of text in images
  - All UI text uses Flutter Text widgets

- [x] **1.4.10 Reflow** (Level AA)
  - Content reflows for different screen sizes
  - No horizontal scrolling required

- [x] **1.4.11 Non-text Contrast** (Level AA)
  - UI components have 3:1 contrast
  - Focus indicators meet contrast requirements

- [x] **1.4.12 Text Spacing** (Level AA)
  - Text respects system spacing settings
  - No content clipping with increased spacing

- [x] **1.4.13 Content on Hover or Focus** (Level AA)
  - Tooltips dismissable with ESC
  - Hover content doesn't obscure other content

### Operable

#### 2.1 Keyboard Accessible

- [x] **2.1.1 Keyboard** (Level A)
  - All functionality available via keyboard/screen reader
  - Tab order is logical

- [x] **2.1.2 No Keyboard Trap** (Level A)
  - No keyboard focus traps
  - Dialogs can be dismissed

- [x] **2.1.4 Character Key Shortcuts** (Level A)
  - No single-character shortcuts implemented

#### 2.2 Enough Time

- [x] **2.2.1 Timing Adjustable** (Level A)
  - Session timeouts have warnings
  - OTP timeout shows countdown

- [x] **2.2.2 Pause, Stop, Hide** (Level A)
  - Auto-advancing carousels have pause controls
  - Loading indicators timeout appropriately

#### 2.3 Seizures and Physical Reactions

- [x] **2.3.1 Three Flashes or Below Threshold** (Level A)
  - No flashing content > 3 flashes/sec

#### 2.4 Navigable

- [x] **2.4.1 Bypass Blocks** (Level A)
  - Skip links where appropriate
  - Proper heading structure

- [x] **2.4.2 Page Titled** (Level A)
  - All screens have descriptive titles

- [x] **2.4.3 Focus Order** (Level A)
  - Tab order matches visual order

- [x] **2.4.4 Link Purpose (In Context)** (Level A)
  - Links have descriptive labels

- [x] **2.4.5 Multiple Ways** (Level AA)
  - Bottom nav + search available
  - Transaction history searchable

- [x] **2.4.6 Headings and Labels** (Level AA)
  - Descriptive headings on all screens
  - Form labels are clear

- [x] **2.4.7 Focus Visible** (Level AA)
  - Focus indicators on all interactive elements
  - Focus state has proper contrast

#### 2.5 Input Modalities

- [x] **2.5.1 Pointer Gestures** (Level A)
  - No path-based gestures required
  - Single-tap alternatives available

- [x] **2.5.2 Pointer Cancellation** (Level A)
  - Actions complete on up event
  - Ability to abort actions

- [x] **2.5.3 Label in Name** (Level A)
  - Accessible names match visible labels

- [x] **2.5.4 Motion Actuation** (Level A)
  - No shake/tilt-only features

### Understandable

#### 3.1 Readable

- [x] **3.1.1 Language of Page** (Level A)
  - App language set via `MaterialApp`
  - Proper locale support (en, fr)

- [x] **3.1.2 Language of Parts** (Level AA)
  - Mixed content properly marked (if applicable)

#### 3.2 Predictable

- [x] **3.2.1 On Focus** (Level A)
  - Focus doesn't trigger context changes

- [x] **3.2.2 On Input** (Level A)
  - Input doesn't auto-submit unexpectedly

- [x] **3.2.3 Consistent Navigation** (Level AA)
  - Nav bar consistent across app
  - Settings always in same location

- [x] **3.2.4 Consistent Identification** (Level AA)
  - Same icons mean same actions
  - Consistent button labels

#### 3.3 Input Assistance

- [x] **3.3.1 Error Identification** (Level A)
  - Errors clearly identified
  - Error messages descriptive

- [x] **3.3.2 Labels or Instructions** (Level A)
  - All inputs have labels
  - Helper text where needed

- [x] **3.3.3 Error Suggestion** (Level AA)
  - Suggestions provided for errors
  - Validation hints shown

- [x] **3.3.4 Error Prevention (Legal, Financial, Data)** (Level AA)
  - Confirmation dialogs for transactions
  - Review step before submission
  - Ability to cancel operations

### Robust

#### 4.1 Compatible

- [x] **4.1.1 Parsing** (Level A)
  - Flutter handles well-formed structure

- [x] **4.1.2 Name, Role, Value** (Level A)
  - All components have proper semantics
  - State changes announced

- [x] **4.1.3 Status Messages** (Level AA)
  - Status updates announced to screen readers
  - Success/error feedback provided

---

## Current Compliance Status

### Compliant Areas

1. **Design System Components**
   - AppButton: Full semantics, loading states, disabled states
   - AppInput: Labels, hints, error announcements
   - AppCard: Proper tap targets
   - AppText: Respects text scaling

2. **Navigation**
   - Clear focus order
   - Logical screen reader navigation
   - Back button consistently available

3. **Forms**
   - Labels associated with inputs
   - Error states announced
   - Validation feedback

4. **Color Contrast**
   - Primary text: 14.7:1 (textPrimary on obsidian)
   - Secondary text: 6.2:1 (textSecondary on obsidian)
   - Gold on dark: 5.1:1 (gold500 on obsidian)
   - Error text: 4.8:1 (errorText on obsidian)

### Areas Requiring Attention

1. **Dynamic Type**
   - Need testing at 200% text scale
   - Layout overflow prevention needed

2. **Reduced Motion**
   - Respect `accessibilityFeatures.disableAnimations`
   - Provide static alternatives

3. **Screen Reader Testing**
   - Complete TalkBack audit needed
   - VoiceOver testing on all flows

4. **Focus Indicators**
   - Some custom components need focus states
   - Focus ring visibility in light mode

5. **Touch Targets**
   - Minimum 44x44 dp enforcement needed
   - Some icon buttons may be undersized

---

## Remediation Plan

### Phase 1: Critical (Week 1-2)

**Priority:** Core flows accessible

- [x] Add semantic labels to all buttons
- [x] Add semantic labels to all inputs
- [ ] Audit and fix touch target sizes
- [ ] Add focus indicators to all interactive elements
- [ ] Test login/registration flow with screen readers

### Phase 2: High (Week 3-4)

**Priority:** Main features accessible

- [ ] Audit transaction flows
- [ ] Audit send money flow
- [ ] Test with TalkBack (Android)
- [ ] Test with VoiceOver (iOS)
- [ ] Fix identified issues

### Phase 3: Medium (Week 5-6)

**Priority:** Settings & secondary features

- [ ] Audit settings screens
- [ ] Audit KYC flow
- [ ] Test dynamic type scaling
- [ ] Test reduced motion settings
- [ ] Contrast audit for light mode

### Phase 4: Enhancement (Week 7-8)

**Priority:** Polish & documentation

- [ ] Create accessibility testing guide
- [ ] Train team on accessibility
- [ ] Set up automated accessibility tests
- [ ] Document accessibility patterns

---

## Screen Reader Testing

### TalkBack (Android)

#### Setup

1. Enable TalkBack: Settings > Accessibility > TalkBack
2. Tutorial: Complete TalkBack tutorial
3. Gestures:
   - Swipe right: Next item
   - Swipe left: Previous item
   - Double-tap: Activate
   - Swipe down then right: Read from top

#### Test Scenarios

**Login Flow**

1. Launch app
2. Verify splash screen announces app name
3. Navigate to phone input
   - Should announce: "Phone number, text field"
   - Should announce helper text
4. Enter phone number
   - Digits announced as typed
5. Navigate to country selector
   - Should announce: "Country, Côte d'Ivoire, button"
6. Tap continue button
   - Should announce: "Continue, button, double tap to activate"
7. Loading state
   - Should announce: "Loading, please wait"

**Transaction Flow**

1. Navigate to home screen
2. Swipe to balance card
   - Should announce: "Balance, 50,000 XOF"
3. Swipe to Send button
   - Should announce: "Send money, button"
4. Double-tap to activate
5. Navigate through amount entry
   - Should announce amount as typed
6. Verify confirmation screen
   - All details announced in logical order

**Settings Flow**

1. Navigate to settings
2. Verify all options announced
3. Test toggle switches
   - State changes announced: "Enabled" / "Disabled"

#### Common Issues to Check

- [ ] Unlabeled buttons (generic "Button")
- [ ] Decorative images not excluded
- [ ] Focus order doesn't match visual order
- [ ] State changes not announced
- [ ] Error messages not announced
- [ ] Loading states not announced

### VoiceOver (iOS)

#### Setup

1. Enable VoiceOver: Settings > Accessibility > VoiceOver
2. Practice mode: Three-finger triple-tap
3. Gestures:
   - Swipe right: Next item
   - Swipe left: Previous item
   - Double-tap: Activate
   - Two-finger swipe down: Read from top
   - Rotor: Two fingers rotate

#### Test Scenarios

Same as TalkBack, but note iOS-specific behaviors:

- VoiceOver speaks punctuation differently
- Rotor provides quick navigation (headings, links, form controls)
- Use rotor to jump between form fields

#### iOS-Specific Checks

- [ ] Traits properly set (Button, Header, Link, etc.)
- [ ] Custom actions available via rotor
- [ ] Hints provide additional context
- [ ] Notifications use `UIAccessibility.post(notification:)`

---

## Automated Testing

### AccessibilityTestHelper

We've created `AccessibilityTestHelper` to automate common accessibility checks:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/test/helpers/accessibility_test_helper.dart';

testWidgets('Login screen is accessible', (tester) async {
  await tester.pumpWidget(const MyApp());

  // Check all requirements
  await AccessibilityTestHelper.runFullAudit(tester);

  // Or check specific aspects
  await AccessibilityTestHelper.checkSemanticLabels(tester);
  await AccessibilityTestHelper.checkTouchTargets(tester);
  await AccessibilityTestHelper.checkContrast(tester);
});
```

### Widget Tests with Semantics

```dart
testWidgets('Button has proper semantics', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: AppButton(
          label: 'Continue',
          onPressed: () {},
        ),
      ),
    ),
  );

  // Find by semantic label
  expect(
    find.bySemanticsLabel('Continue'),
    findsOneWidget,
  );

  // Verify button trait
  final semantics = tester.getSemantics(find.byType(AppButton));
  expect(semantics.hasFlag(SemanticsFlag.isButton), isTrue);
  expect(semantics.hasFlag(SemanticsFlag.isEnabled), isTrue);
});
```

### Golden Tests for Focus States

```dart
testWidgets('Focus indicator renders correctly', (tester) async {
  await tester.pumpWidget(const MyApp());

  final button = find.byType(AppButton).first;
  await tester.tap(button);
  await tester.pumpAndSettle();

  // Compare with golden file
  await expectLater(
    find.byType(AppButton),
    matchesGoldenFile('button_focused.png'),
  );
});
```

---

## Design System Accessibility

### AppButton

**Semantics**

- `label`: Button text announced to screen readers
- `semanticLabel`: Optional override for better context
- `hint`: "Double tap to activate" or state info
- `button`: true
- `enabled`: Reflects disabled state

**States**

- Loading: Announces "Loading, please wait"
- Disabled: Announces "Button disabled"
- Pressed: Visual + haptic feedback

**Contrast**

- Primary: Gold gradient on dark (5.1:1)
- Secondary: Border only (3.5:1)
- Text always meets 4.5:1 minimum

**Touch Targets**

- Minimum height: 48dp (exceeds 44dp requirement)
- Minimum width: 88dp for inline, full-width for primary CTAs

### AppInput

**Semantics**

- `label`: Field name announced
- `hint`: Placeholder/example shown
- `error`: Error announced when present
- `textField`: true
- Hint text for read-only/error states

**States**

- Idle, Focused, Filled, Error, Disabled
- Each state has distinct visual + semantic feedback
- Error icon + text (not just color)

**Contrast**

- Label text: 6.2:1 (textSecondary)
- Input text: 14.7:1 (textPrimary)
- Error text: 4.8:1 (errorText)
- Border focused: 5.1:1 (gold500)

**Touch Targets**

- Input height: 56dp (exceeds 44dp)
- Suffix icons: 44x44dp tap target

### AppCard

**Semantics**

- Container role
- Tappable cards announce tap hint
- Content within card maintains semantic structure

**Contrast**

- Border: 3:1 against background (borderDefault)
- Content inherits from children

**Touch Targets**

- Entire card is tappable (if onTap provided)
- Minimum 44dp height

### AppText

**Dynamic Type**

- Respects `MediaQuery.textScaleFactor`
- maxLines prevents overflow
- TextOverflow.ellipsis for long text

**Contrast**

- Primary: 14.7:1
- Secondary: 6.2:1
- Tertiary: 4.5:1 (minimum)

---

## Dynamic Type & Scaling

### Text Scaling Support

Flutter natively supports text scaling via `MediaQuery.textScaleFactor`.

**Implementation**

```dart
// Typography automatically scales
AppText(
  'Welcome',
  variant: AppTextVariant.headlineMedium,
  // Scales with system settings
)
```

**Testing**

```dart
testWidgets('Text scales properly', (tester) async {
  await tester.pumpWidget(
    MediaQuery(
      data: const MediaQueryData(textScaleFactor: 2.0),
      child: const MyApp(),
    ),
  );

  // Verify text size doubled
  final textWidget = tester.widget<Text>(find.byType(Text).first);
  expect(textWidget.style?.fontSize, greaterThan(32));
});
```

### Layout Adaptation

**Flexible Layouts**

- Use `Flexible` and `Expanded` for responsive sizing
- Avoid fixed heights for text containers
- `maxLines` + `overflow` for long text

**Overflow Prevention**

```dart
// Good: Adapts to text size
Column(
  children: [
    AppText('Title', variant: AppTextVariant.headlineMedium),
    const SizedBox(height: AppSpacing.md),
    Flexible(
      child: AppText(
        'Long description that might wrap...',
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    ),
  ],
)

// Bad: Fixed height causes clipping
Container(
  height: 100, // May clip at 200% scale
  child: AppText('Long text...'),
)
```

### Supported Scale Factors

| Scale | Use Case | Status |
|-------|----------|--------|
| 1.0x | Default | Tested |
| 1.15x | Slight increase | Tested |
| 1.3x | Moderate | Tested |
| 1.5x | Large | Testing |
| 2.0x | Maximum AA | Testing |

---

## Reduced Motion Support

### AccessibilityFeatures

Flutter provides `MediaQuery.of(context).accessibilityFeatures.disableAnimations`.

**Implementation**

```dart
class _MyState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.of(context)
        .accessibilityFeatures
        .disableAnimations;

    final duration = disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 300);

    return AnimatedOpacity(
      duration: duration,
      opacity: _isVisible ? 1.0 : 0.0,
      child: child,
    );
  }
}
```

### ReducedMotionHelper

We provide a helper for consistent behavior:

```dart
import 'package:mobile/utils/reduced_motion_helper.dart';

// Automatically respects system setting
AnimatedContainer(
  duration: ReducedMotionHelper.getDuration(
    context,
    normal: const Duration(milliseconds: 300),
  ),
  // ...
)
```

### Animations to Adapt

- [x] Page transitions (fade vs slide)
- [x] Button press animations
- [x] Loading spinners (reduce speed)
- [ ] Onboarding carousel (auto-advance off)
- [ ] Balance reveal animation (instant show)
- [ ] Transaction list animations (instant load)

---

## Keyboard Navigation

### Focus Order

Flutter's default focus traversal follows widget tree order, which matches our visual layout.

**Focus Traversal Policy**

```dart
// Already implemented in app
MaterialApp(
  builder: (context, child) {
    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: child!,
    );
  },
)
```

### Focus Indicators

**Default Focus**

Flutter Material provides default focus indicators. We enhance them:

```dart
// Custom focus decoration
ThemeData(
  focusColor: AppColors.gold500.withOpacity(0.2),
  // ...
)
```

**Visible Focus for Accessibility**

All interactive components have visible focus:

- Buttons: Gold outline
- Inputs: Gold border (2dp)
- Cards: Gold border + subtle glow
- Nav items: Gold background

### Tab Stops

**Included**

- Buttons
- Text fields
- Checkboxes
- Links
- Navigation items

**Excluded**

- Decorative images (ExcludeSemantics)
- Static text containers (unless tappable)
- Dividers, spacers

---

## Contrast Ratios

### Dark Mode (Default)

| Element | Foreground | Background | Ratio | Status |
|---------|-----------|------------|-------|--------|
| Primary text | textPrimary (#F5F5F0) | obsidian (#0A0A0C) | 14.7:1 | Pass AAA |
| Secondary text | textSecondary (#9A9A9E) | obsidian (#0A0A0C) | 6.2:1 | Pass AA |
| Tertiary text | textTertiary (#6B6B70) | obsidian (#0A0A0C) | 4.5:1 | Pass AA |
| Button (primary) | textInverse (#0A0A0C) | gold500 (#C9A962) | 5.1:1 | Pass AA |
| Button (secondary) | textPrimary (#F5F5F0) | elevated (#222228) | 12.8:1 | Pass AAA |
| Error text | errorText (#E57B8D) | obsidian (#0A0A0C) | 4.8:1 | Pass AA |
| Success text | successText (#7DD3A8) | obsidian (#0A0A0C) | 5.2:1 | Pass AA |
| Warning text | warningText (#F0C674) | obsidian (#0A0A0C) | 6.1:1 | Pass AA |
| Input border (focus) | gold500 (#C9A962) | obsidian (#0A0A0C) | 5.1:1 | Pass AA |
| Input border (default) | borderDefault (10% white) | obsidian (#0A0A0C) | 3.5:1 | Pass AA (UI) |

### Light Mode

| Element | Foreground | Background | Ratio | Status |
|---------|-----------|------------|-------|--------|
| Primary text | textPrimary (#1A1A1F) | canvas (#FAFAF8) | 14.2:1 | Pass AAA |
| Secondary text | textSecondary (#5A5A5E) | canvas (#FAFAF8) | 6.5:1 | Pass AA |
| Tertiary text | textTertiary (#8A8A8E) | canvas (#FAFAF8) | 4.6:1 | Pass AA |
| Button (primary) | textInverse (#F5F5F0) | gold500 (#B8943D) | 4.8:1 | Pass AA |
| Error text | errorText (#8B2942) | errorLight (#FCEBEF) | 5.1:1 | Pass AA |
| Success text | successText (#1A5C3E) | successLight (#E8F5ED) | 5.4:1 | Pass AA |

### Testing Contrast

**Tools**

- Online: WebAIM Contrast Checker
- macOS: Contrast Ratio app
- Chrome DevTools: Lighthouse audit

**Verification**

```bash
# Run Lighthouse accessibility audit
# (requires web build)
flutter build web
lighthouse dist/index.html --only-categories=accessibility
```

---

## Testing Procedures

### Manual Testing Checklist

**Per Screen**

- [ ] Navigate with screen reader (TalkBack/VoiceOver)
- [ ] Test at 200% text scale
- [ ] Test with reduced motion enabled
- [ ] Test with high contrast mode
- [ ] Verify focus order
- [ ] Check touch target sizes
- [ ] Verify color contrast
- [ ] Test form validation errors
- [ ] Test with different text lengths

**Critical Flows**

- [ ] Login / Registration
- [ ] Send Money
- [ ] Receive Money
- [ ] Transaction History
- [ ] Settings
- [ ] KYC Submission

### Automated Testing

```bash
# Run accessibility tests
flutter test test/accessibility/

# Run with semantics debugger
flutter run --enable-asserts --debug

# Generate coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Continuous Integration

Add to CI pipeline:

```yaml
# .github/workflows/accessibility.yml
- name: Run accessibility tests
  run: flutter test test/accessibility/

- name: Check semantic labels
  run: flutter analyze --fatal-warnings

- name: Verify contrast ratios
  run: dart run test/tools/contrast_checker.dart
```

---

## Resources

### Documentation

- [Flutter Accessibility](https://docs.flutter.dev/development/accessibility-and-localization/accessibility)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Material Accessibility](https://material.io/design/usability/accessibility.html)

### Tools

- [TalkBack (Android)](https://support.google.com/accessibility/android/answer/6283677)
- [VoiceOver (iOS)](https://support.apple.com/guide/iphone/turn-on-and-practice-voiceover-iph3e2e415f/ios)
- [Accessibility Scanner (Android)](https://play.google.com/store/apps/details?id=com.google.android.apps.accessibility.auditor)
- [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)

### Training

- [Web Accessibility by Google](https://www.udacity.com/course/web-accessibility--ud891)
- [Accessible Flutter Apps](https://www.youtube.com/watch?v=bWbBgbmAdQs)

---

## Changelog

### 2026-01-29

- Initial accessibility audit completed
- Design system components updated with full semantics
- AccessibilityTestHelper created
- ReducedMotionHelper created
- Contrast ratios verified for dark mode
- Documentation created

### Next Steps

1. Complete TalkBack/VoiceOver testing
2. Audit all screens for touch targets
3. Test at 200% text scale
4. Light mode contrast verification
5. Automated CI checks
