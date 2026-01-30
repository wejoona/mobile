# Screen Reader Testing Guide

> Comprehensive guide for testing JoonaPay Mobile with TalkBack and VoiceOver

## Overview

This guide provides step-by-step instructions for testing the JoonaPay Mobile app with screen readers to ensure WCAG 2.1 Level AA compliance.

---

## Table of Contents

1. [TalkBack (Android)](#talkback-android)
2. [VoiceOver (iOS)](#voiceover-ios)
3. [Test Scenarios](#test-scenarios)
4. [Common Issues](#common-issues)
5. [Reporting Issues](#reporting-issues)

---

## TalkBack (Android)

### Setup

#### Enable TalkBack

1. Open **Settings** > **Accessibility** > **TalkBack**
2. Toggle **Use TalkBack** to ON
3. Confirm activation in dialog
4. Complete the TalkBack tutorial (highly recommended)

#### Recommended Settings

- **Settings** > **Accessibility** > **TalkBack** > **Settings**
  - Enable **Speak element IDs** (for debugging)
  - Enable **Speak element types** (button, text field, etc.)
  - Set **Speech rate** to comfortable level
  - Enable **Verbosity** > **Speak roles**

### Essential Gestures

| Gesture | Action |
|---------|--------|
| Swipe right | Next item |
| Swipe left | Previous item |
| Double-tap | Activate/Click |
| Swipe down then right | Read from top |
| Swipe up then down | Read from current position |
| Two fingers swipe up/down | Scroll |
| Two fingers double-tap | Pause/Resume TalkBack |
| Swipe down then up | First item on screen |
| Swipe up then right | Last item on screen |

### Reading Controls

| Gesture | Action |
|---------|--------|
| Swipe down then left | Adjust reading granularity |
| When on text: Swipe right/left | Navigate by current granularity |

Granularity options:
- Characters
- Words
- Lines
- Paragraphs
- Default (entire element)

### Local Context Menu

**Activate:** Swipe up then right (or down then left)

Provides quick actions:
- Read from top
- Read from next item
- Spell last utterance
- Copy last utterance
- TalkBack settings

### Global Context Menu

**Activate:** Swipe down then right (or up then left)

Provides navigation:
- Headings
- Links
- Controls (buttons, checkboxes)

### Practice Mode

**Activate:** Three-finger triple-tap

Practice gestures without triggering actions. Useful for learning.

---

## VoiceOver (iOS)

### Setup

#### Enable VoiceOver

1. Open **Settings** > **Accessibility** > **VoiceOver**
2. Toggle **VoiceOver** to ON
3. Complete VoiceOver tutorial (highly recommended)

**Quick Toggle:**
- Triple-click Home button (if configured)
- Triple-click Side button (iPhone X+, if configured)

#### Recommended Settings

- **Settings** > **Accessibility** > **VoiceOver**
  - Set **Speaking Rate** to comfortable level
  - Enable **Speak Hints**
  - Enable **Pitch Change** (for emphasis)
  - Configure **Verbosity** > **Punctuation** to "Some"

### Essential Gestures

| Gesture | Action |
|---------|--------|
| Swipe right | Next item |
| Swipe left | Previous item |
| Double-tap | Activate/Click |
| Two-finger swipe down | Read all from top |
| Two-finger swipe up | Read all from current |
| Three-finger swipe up/down | Scroll |
| Two-finger double-tap | Magic Tap (play/pause) |
| Two-finger Z gesture | Back/Undo |
| Two-finger scrub (Z pattern) | Go back |

### Rotor

**Activate:** Two fingers on screen, rotate clockwise/counterclockwise

The rotor provides quick navigation options:
- Headings
- Links
- Form Controls
- Buttons
- Text Fields
- Containers
- Landmarks

**Use Rotor:**
1. Activate rotor (rotate two fingers)
2. Swipe up/down to select option (e.g., "Headings")
3. Swipe up/down to navigate between items of that type

### Reading Controls

| Gesture | Action |
|---------|--------|
| Swipe up/down (with Rotor set to "Characters") | Read by character |
| Swipe up/down (with Rotor set to "Words") | Read by word |
| Swipe up/down (with Rotor set to "Lines") | Read by line |

### Item Chooser

**Activate:** Two-finger triple-tap

Shows list of all elements on screen for quick selection.

### Practice Mode

**Activate:** Three-finger quadruple-tap

Practice gestures in safe environment.

---

## Test Scenarios

### 1. Login Flow

**Goal:** Verify user can complete login using screen reader only

#### Steps

1. **Launch App**
   - [ ] Splash screen announces app name: "JoonaPay"
   - [ ] Loading state announced: "Loading"

2. **Login Screen**
   - [ ] Screen title announced: "Login" or "Sign in"
   - [ ] Navigate to country selector
     - Expected: "Country, Côte d'Ivoire, button"
   - [ ] Activate country selector
     - Expected: Opens country picker
   - [ ] Navigate through countries
     - Expected: Each country announced with flag emoji and name
   - [ ] Select country
     - Expected: Returns to login, selection announced

3. **Phone Number Entry**
   - [ ] Navigate to phone input
     - Expected: "Phone number, text field, edit box"
   - [ ] Activate phone input
     - Expected: Keyboard opens, focus in field
   - [ ] Type phone number
     - Expected: Each digit announced as typed
   - [ ] Verify helper text announced
     - Expected: "Enter your mobile number" or similar

4. **Submit**
   - [ ] Navigate to continue button
     - Expected: "Continue, button, double tap to activate"
   - [ ] Activate button
     - Expected: Loading state announced
   - [ ] Wait for OTP screen
     - Expected: Screen change announced

5. **OTP Screen**
   - [ ] Screen title announced: "Enter OTP" or similar
   - [ ] Navigate to OTP inputs
     - Expected: "OTP digit 1 of 6, text field"
   - [ ] Enter OTP
     - Expected: Auto-advance to next field
   - [ ] Verify countdown announced
     - Expected: "Resend in 60 seconds" (updates)
   - [ ] Submit OTP
     - Expected: Success or error announced

#### Expected Announcements

| Element | Expected |
|---------|----------|
| Screen title | "Login" or "Sign in to JoonaPay" |
| Country selector | "Country, [Country Name], button, double tap to activate" |
| Phone input | "Phone number, text field, empty" |
| Helper text | "Enter your mobile number" |
| Continue button | "Continue, button, double tap to activate" |
| Continue button (disabled) | "Continue, button, dimmed" or "disabled" |
| Continue button (loading) | "Loading, please wait" |
| Error message | "Error: [error text]" |

### 2. Home / Wallet Screen

**Goal:** Verify user can navigate and understand wallet information

#### Steps

1. **Screen Load**
   - [ ] Screen title announced: "Home" or "Wallet"
   - [ ] Welcome message announced: "Welcome back, [Name]"

2. **Balance Card**
   - [ ] Navigate to balance
     - Expected: "Balance, 50,000 XOF" (full amount)
   - [ ] Toggle balance visibility (if feature exists)
     - Expected: State change announced: "Balance hidden" / "Balance visible"

3. **Quick Actions**
   - [ ] Navigate to Send button
     - Expected: "Send money, button"
   - [ ] Navigate to Receive button
     - Expected: "Receive money, button"
   - [ ] Navigate to Scan button
     - Expected: "Scan QR code, button"

4. **Recent Transactions**
   - [ ] Section heading announced: "Recent transactions"
   - [ ] Navigate to first transaction
     - Expected: "Transaction: Sent 5,000 XOF to Amadou Diallo, January 29, Pending"
   - [ ] Activate transaction
     - Expected: Opens transaction details

5. **Pull to Refresh**
   - [ ] Two-finger swipe down (or accessibility refresh gesture)
     - Expected: "Refreshing" announced
     - Expected: "Updated" or completion announced

#### Expected Announcements

| Element | Expected |
|---------|----------|
| Screen title | "Home" or "Wallet" |
| Welcome | "Welcome back, [Name]" |
| Balance | "Balance, 50,000 XOF" or "Balance hidden" |
| Balance toggle | "Show balance, button" / "Hide balance, button" |
| Send button | "Send money, button" |
| Transaction item | "[Type] [Amount] to/from [Name], [Date], [Status]" |

### 3. Send Money Flow

**Goal:** Verify user can complete money transfer

#### Steps

1. **Amount Entry**
   - [ ] Screen title announced: "Send money" or "Enter amount"
   - [ ] Navigate to amount input
     - Expected: "Amount, text field, XOF"
   - [ ] Enter amount
     - Expected: Amount announced with commas: "50,000"
   - [ ] Verify balance check
     - Expected: If exceeds, error announced immediately

2. **Recipient Selection**
   - [ ] Navigate to recipient field
     - Expected: "Recipient, button, none selected"
   - [ ] Activate recipient picker
     - Expected: Opens contact list
   - [ ] Navigate through contacts
     - Expected: Each contact announced with name and phone
   - [ ] Select recipient
     - Expected: Returns to form, selection announced

3. **Note (Optional)**
   - [ ] Navigate to note field
     - Expected: "Note, optional, text field"
   - [ ] Enter note
     - Expected: Characters announced

4. **Review**
   - [ ] Navigate to continue button
   - [ ] Activate to proceed to confirmation
   - [ ] Confirmation screen announces all details:
     - [ ] "You are sending"
     - [ ] Amount: "50,000 XOF"
     - [ ] To: "[Recipient name]"
     - [ ] Fee: "50 XOF"
     - [ ] Total: "50,050 XOF"

5. **Confirm**
   - [ ] Navigate to confirm button
     - Expected: "Confirm and send, button"
   - [ ] Activate
     - Expected: PIN prompt or success
   - [ ] Success screen
     - Expected: "Success! 50,000 XOF sent to [Name]"

#### Expected Announcements

| Element | Expected |
|---------|----------|
| Amount input | "Amount in XOF, text field, empty" |
| Amount entered | "50,000 XOF" (formatted with commas) |
| Recipient selector | "Recipient, button, [Name] selected" or "none selected" |
| Note field | "Note, optional, text field" |
| Confirm button | "Confirm and send, button" |
| Error | "Error: [message]" |
| Success | "Success! Transaction complete" |

### 4. Settings Flow

**Goal:** Verify settings are accessible and state changes announced

#### Steps

1. **Settings Screen**
   - [ ] Navigate to settings
     - Expected: Each section announced as heading

2. **Toggle Switches**
   - [ ] Navigate to toggle (e.g., "Biometric login")
     - Expected: "Biometric login, on, switch, double tap to toggle"
   - [ ] Activate toggle
     - Expected: State announced: "Off" or "On"

3. **Navigation Items**
   - [ ] Navigate to "Profile"
     - Expected: "Profile, button, double tap to open"
   - [ ] Activate
     - Expected: Screen change announced

4. **Logout**
   - [ ] Navigate to logout button
     - Expected: "Logout, button"
   - [ ] Activate
     - Expected: Confirmation dialog announced
   - [ ] Confirm logout
     - Expected: Returns to login, transition announced

#### Expected Announcements

| Element | Expected |
|---------|----------|
| Section heading | "Account settings, heading" |
| Toggle (on) | "[Label], on, switch, double tap to toggle" |
| Toggle (off) | "[Label], off, switch, double tap to toggle" |
| Navigation item | "[Label], button, double tap to open" |
| Logout | "Logout, button" |

### 5. Transaction History

**Goal:** Verify transaction list is navigable and filterable

#### Steps

1. **Transaction List**
   - [ ] Screen title: "Transactions" or "History"
   - [ ] Navigate through transactions
     - Expected: Each announced with full details
   - [ ] Verify chronological order maintained

2. **Filters**
   - [ ] Navigate to filter button
     - Expected: "Filter, button, [current filter]"
   - [ ] Activate filter
     - Expected: Filter options announced
   - [ ] Select filter (e.g., "Sent only")
     - Expected: Filter applied, list updated, announcement: "Showing sent transactions only"

3. **Search**
   - [ ] Navigate to search field
     - Expected: "Search transactions, text field"
   - [ ] Enter search query
     - Expected: Results update, count announced: "3 results found"

4. **Empty State**
   - [ ] Clear all filters/search to show empty state (if applicable)
     - Expected: "No transactions yet" or similar message

#### Expected Announcements

| Element | Expected |
|---------|----------|
| Transaction item | "Sent 5,000 XOF to Amadou Diallo, January 29, Pending, button" |
| Filter button | "Filter, button, showing all transactions" |
| Search field | "Search transactions, text field" |
| Search results | "3 results found" |
| Empty state | "No transactions found" or "No transactions yet" |

### 6. KYC / Verification Flow

**Goal:** Verify multi-step form is accessible

#### Steps

1. **Personal Information**
   - [ ] Screen title: "Verify your identity" or similar
   - [ ] Navigate through fields
     - Expected: Each label announced
   - [ ] Check required field indicators
     - Expected: "Required" announced with label
   - [ ] Fill in fields
     - Expected: Validation errors announced immediately

2. **Document Upload**
   - [ ] Navigate to upload button
     - Expected: "Upload ID document, button"
   - [ ] Activate
     - Expected: Photo picker announced
   - [ ] Select photo
     - Expected: Returns, upload progress announced
   - [ ] Upload complete
     - Expected: "Upload complete" or preview described

3. **Review and Submit**
   - [ ] Navigate through review screen
     - Expected: All entered data announced for verification
   - [ ] Navigate to submit button
   - [ ] Activate
     - Expected: Loading, then success/error

#### Expected Announcements

| Element | Expected |
|---------|----------|
| Text field | "[Label], required, text field" |
| Validation error | "Error: [message]" (e.g., "Invalid email address") |
| Upload button | "Upload ID document, button" |
| Upload progress | "Uploading, 50%" |
| Upload complete | "Upload complete, ID_document.jpg" |
| Submit button | "Submit for verification, button" |

---

## Common Issues

### Issue Checklist

Use this checklist to identify common accessibility problems:

#### Missing Labels

- [ ] Buttons with no text or semantic label
- [ ] Icons without descriptions
- [ ] Images without alt text
- [ ] Form fields without labels

**Example Issue:**
```
Finding: Icon button announces as "Button" only
Expected: "Send money, button"
```

#### Incorrect Reading Order

- [ ] Focus jumps erratically
- [ ] Reading order doesn't match visual order
- [ ] Related elements separated in focus order

**Example Issue:**
```
Finding: Error message read after continuing to next field
Expected: Error announced immediately after field label
```

#### State Changes Not Announced

- [ ] Toggle switches don't announce new state
- [ ] Loading states silent
- [ ] Error messages not announced
- [ ] Success confirmations silent

**Example Issue:**
```
Finding: Toggle switch changes visually but no announcement
Expected: "Notifications on" or "Notifications off"
```

#### Decorative Elements Not Excluded

- [ ] Decorative images read by screen reader
- [ ] Background images announced
- [ ] Separator lines announced

**Example Issue:**
```
Finding: Decorative logo announced as "Image, logo.png"
Expected: Logo should be hidden from screen reader (ExcludeSemantics)
```

#### Inadequate Context

- [ ] Buttons with vague labels ("OK", "Cancel" without context)
- [ ] Links with "Click here"
- [ ] Form fields with unclear purpose

**Example Issue:**
```
Finding: "Continue, button" on every screen
Expected: "Continue to OTP verification, button" (context-specific)
```

#### Keyboard Traps

- [ ] Cannot exit modal with gestures
- [ ] Focus stuck in component
- [ ] No way to dismiss overlay

**Example Issue:**
```
Finding: Bottom sheet cannot be dismissed with gestures
Expected: Swipe down or two-finger Z to dismiss
```

#### Insufficient Feedback

- [ ] Form submission with no confirmation
- [ ] Actions complete silently
- [ ] No indication of processing

**Example Issue:**
```
Finding: After tapping "Send", no feedback until completion
Expected: "Sending transaction, please wait" announced
```

---

## Reporting Issues

### Issue Template

When reporting accessibility issues, include:

```markdown
## Issue: [Brief description]

**Screen:** [Screen name / route]
**Component:** [Button / Input / Card / etc.]
**Screen Reader:** [TalkBack / VoiceOver]
**OS Version:** [Android 13 / iOS 17]

### Current Behavior
[What happens now - exact announcement]

### Expected Behavior
[What should happen - desired announcement]

### Steps to Reproduce
1. Enable TalkBack/VoiceOver
2. Navigate to [screen]
3. Swipe to [element]
4. Observe announcement

### Severity
- [ ] Critical - Blocks core functionality
- [ ] High - Confusing or difficult to use
- [ ] Medium - Suboptimal but functional
- [ ] Low - Minor improvement

### WCAG Guideline
[e.g., 4.1.2 Name, Role, Value]

### Screenshots / Recording
[Attach if helpful]
```

### Example Issue Report

```markdown
## Issue: Send button missing semantic label

**Screen:** Home / Wallet
**Component:** Send money button (top quick action)
**Screen Reader:** TalkBack
**OS Version:** Android 13

### Current Behavior
Button announces as "Button" only (generic)

### Expected Behavior
Should announce as "Send money, button, double tap to activate"

### Steps to Reproduce
1. Enable TalkBack
2. Navigate to Home screen
3. Swipe right to first quick action button
4. Listen to announcement

### Severity
- [x] High - Confusing or difficult to use

### WCAG Guideline
4.1.2 Name, Role, Value (Level A)

### Fix
Add semanticLabel to AppButton:
```dart
AppButton(
  label: 'Send',
  semanticLabel: 'Send money', // Add this
  icon: Icons.send,
  onPressed: () => context.push('/send'),
)
```
```

---

## Additional Resources

### Documentation

- [TalkBack User Guide](https://support.google.com/accessibility/android/answer/6283677)
- [VoiceOver User Guide](https://support.apple.com/guide/iphone/turn-on-and-practice-voiceover-iph3e2e415f/ios)
- [Flutter Accessibility](https://docs.flutter.dev/development/accessibility-and-localization/accessibility)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)

### Testing Tools

- **Accessibility Scanner (Android):** Automated checks for Android apps
- **Xcode Accessibility Inspector (iOS):** Inspect accessibility tree
- **Flutter Semantics Debugger:** Visual representation of semantic tree

### Training

- [Google's TalkBack Tutorial](https://www.youtube.com/watch?v=0Zpzl4EKCco)
- [Apple's VoiceOver Tutorial](https://www.apple.com/accessibility/resources/)
- [Web Accessibility by Google (Udacity)](https://www.udacity.com/course/web-accessibility--ud891)

---

## Quick Reference Cards

### TalkBack Gestures (Print-Friendly)

| Gesture | Action |
|---------|--------|
| Swipe right | Next |
| Swipe left | Previous |
| Double-tap | Activate |
| Swipe down then right | Read from top |
| Two fingers swipe up/down | Scroll |
| Swipe up then right | Local menu |
| Swipe down then left | Global menu |

### VoiceOver Gestures (Print-Friendly)

| Gesture | Action |
|---------|--------|
| Swipe right | Next |
| Swipe left | Previous |
| Double-tap | Activate |
| Two-finger swipe down | Read from top |
| Three-finger swipe up/down | Scroll |
| Two-finger rotate | Rotor |
| Two-finger triple-tap | Item chooser |

---

**Last Updated:** 2026-01-29

**Maintained by:** JoonaPay Accessibility Team
