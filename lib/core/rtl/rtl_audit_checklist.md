# RTL Screen Audit Checklist

Use this checklist when auditing or creating screens for RTL compatibility.

## Screen: ________________________

**File:** `lib/features/______/views/______.dart`
**Audited by:** ________________
**Date:** ________________
**Status:** ⬜ Not Started | 🟡 In Progress | ✅ Complete

---

## 1. Padding & Margins

- [ ] No hardcoded `EdgeInsets.only(left: ...)`
- [ ] No hardcoded `EdgeInsets.only(right: ...)`
- [ ] All `EdgeInsets` converted to `EdgeInsetsDirectional`
- [ ] Symmetric padding uses `horizontal` or `vertical` (auto-converts)
- [ ] Complex padding uses `fromSTEB()` instead of `fromLTRB()`

**Notes:**
```
Found instances:
- Line ___:
- Line ___:
```

---

## 2. Alignment

- [ ] No `Alignment.centerLeft` (use `AlignmentDirectional.centerStart`)
- [ ] No `Alignment.centerRight` (use `AlignmentDirectional.centerEnd`)
- [ ] No `Alignment.topLeft` / `bottomLeft` (use Directional equivalents)
- [ ] All `Align` widgets use `AlignmentDirectional`
- [ ] All `Container(alignment: ...)` use directional alignment

**Notes:**
```
Found instances:
- Line ___:
- Line ___:
```

---

## 3. Row & Column Cross-Axis Alignment

- [ ] `Column` with `CrossAxisAlignment.start/end` checked
  - If directional, use `context.isRTL` conditional
- [ ] `Row` mainAxisAlignment verified for directionality
- [ ] Nested Rows/Columns reviewed
- [ ] Consider using `DirectionalRow` for icon+text patterns

**Notes:**
```
Found instances:
- Line ___:
- Line ___:
```

---

## 4. Icons

- [ ] Back arrows use `RTLSupport.arrowBack(context)`
- [ ] Forward arrows use `RTLSupport.arrowForward(context)`
- [ ] Chevrons (left/right) are conditionally swapped
- [ ] Icons in `ListTile` leading/trailing checked
- [ ] Directional icons (send, receive) reviewed

**Icon Inventory:**
```
Icons.arrow_back: Line ___
Icons.arrow_forward: Line ___
Icons.chevron_right: Line ___
Icons.chevron_left: Line ___
Other directional icons: ___
```

---

## 5. Text Alignment

- [ ] No `TextAlign.left` (use `TextAlign.start`)
- [ ] No `TextAlign.right` (use `TextAlign.end`)
- [ ] `AppText` widgets reviewed for alignment
- [ ] Form labels aligned correctly
- [ ] Centered text is OK (no change needed)

**Notes:**
```
Found instances:
- Line ___:
- Line ___:
```

---

## 6. Positioned Widgets

- [ ] All `Positioned` with `left` use conditional or `PositionedDirectional`
- [ ] All `Positioned` with `right` use conditional or `PositionedDirectional`
- [ ] Stack children reviewed for RTL
- [ ] Overlay positioning (badges, tooltips) checked

**Notes:**
```
Found instances:
- Line ___:
- Line ___:
```

---

## 7. ListTile & List Items

- [ ] `ListTile` with icons use `DirectionalListTile` or swapped manually
- [ ] Leading/trailing icons verified
- [ ] Custom list items use `DirectionalRow`
- [ ] Content padding is directional

**Notes:**
```
Found instances:
- Line ___:
- Line ___:
```

---

## 8. Forms & Inputs

- [ ] `AppInput` widgets checked (component should handle RTL)
- [ ] Phone number inputs force LTR direction
- [ ] Email/URL inputs force LTR direction
- [ ] Numeric inputs force LTR direction
- [ ] Form field labels aligned correctly

**Notes:**
```
Found instances:
- Line ___:
- Line ___:
```

---

## 9. Buttons

- [ ] `AppButton` with icons verified
- [ ] Icon position (`IconPosition.start/end`) used correctly
- [ ] Button text alignment is default (centered) - OK
- [ ] Custom buttons use `DirectionalRow` if needed

**Notes:**
```
Found instances:
- Line ___:
- Line ___:
```

---

## 10. Cards & Containers

- [ ] `AppCard` padding is directional
- [ ] Container decorations (borders) are symmetric or directional
- [ ] Multi-column cards use `DirectionalRow`
- [ ] Card content alignment verified

**Notes:**
```
Found instances:
- Line ___:
- Line ___:
```

---

## 11. Navigation & App Bar

- [ ] AppBar leading icon uses correct back arrow
- [ ] AppBar actions array (no change needed, auto-positions)
- [ ] AppBar title alignment is default (start) - verify
- [ ] Bottom navigation icons (no directionality)
- [ ] Drawer position (Flutter handles automatically)

**Notes:**
```
Found instances:
- Line ___:
- Line ___:
```

---

## 12. Animations & Transitions

- [ ] Slide animations respect direction
- [ ] Swipe gestures reviewed
- [ ] Page transitions checked
- [ ] Custom animations use directional offsets

**Notes:**
```
Found instances:
- Line ___:
- Line ___:
```

---

## 13. Third-Party Widgets

- [ ] External package widgets reviewed for RTL support
- [ ] Wrapped with `Directionality` if needed
- [ ] Fallback UI for unsupported RTL widgets

**Packages used:**
```
- Package: _______ | RTL Support: ✅ / ❌
- Package: _______ | RTL Support: ✅ / ❌
```

---

## 14. Visual Testing

- [ ] Tested in Arabic locale (`Locale('ar')`)
- [ ] Verified on iOS simulator
- [ ] Verified on Android emulator
- [ ] Screenshot comparison (LTR vs RTL)
- [ ] No overlapping text
- [ ] No cut-off content
- [ ] Scrolling feels natural

**Devices Tested:**
```
- ⬜ iPhone 15 Pro (iOS 17)
- ⬜ iPad Pro 11" (iOS 17)
- ⬜ Pixel 8 (Android 14)
- ⬜ Samsung Galaxy S23 (Android 14)
```

---

## 15. Accessibility

- [ ] Screen reader announces elements in correct order (RTL)
- [ ] TalkBack/VoiceOver tested
- [ ] Semantic labels make sense in RTL
- [ ] Focus order is logical

**Screen Reader Test:**
```
- ⬜ All interactive elements reachable
- ⬜ Announcement order is correct
- ⬜ Actions make sense in context
```

---

## Issues Found

| Line | Issue | Severity | Fixed? |
|------|-------|----------|--------|
| ___ | _____ | 🔴 High | ⬜ |
| ___ | _____ | 🟡 Medium | ⬜ |
| ___ | _____ | 🟢 Low | ⬜ |

---

## Migration Code Snippets

**Before:**
```dart
// Paste original code here
```

**After:**
```dart
// Paste fixed code here
```

---

## Sign-Off

**Developer:** ________________
**Reviewer:** ________________
**QA Tester:** ________________
**Date Completed:** ________________

**Final Status:** ⬜ RTL Ready | ⬜ Needs Revision | ⬜ Blocked

**Blocker Details:**
```
_______________________________________________
_______________________________________________
```

---

## Quick Reference

**Import Statement:**
```dart
import 'package:usdc_wallet/core/rtl/rtl_support.dart';
```

**Common Fixes:**
```dart
// Padding
EdgeInsets.only(left: 16) → EdgeInsetsDirectional.only(start: 16)

// Alignment
Alignment.centerLeft → AlignmentDirectional.centerStart

// Icons
Icons.arrow_forward → RTLSupport.arrowForward(context)

// Rows
Row(...) → DirectionalRow(...)
```
