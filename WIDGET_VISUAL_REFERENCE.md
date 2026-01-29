# Widget Visual Reference

Visual guide to JoonaPay home screen widgets across platforms.

## Widget Sizes

### iOS

#### Small Widget (2x2)
```
┌─────────────────────────┐
│ JoonaPay                │  ← Gold (#C9A962)
│                         │
│                         │
│                         │
│ $1,234.56              │  ← Bold, 18pt
│ Amadou Diallo          │  ← Secondary gray
└─────────────────────────┘

Size: ~158x158 points
Background: Gradient (obsidian → graphite)
Tap: Opens app (joonapay://home)
```

#### Medium Widget (4x2)
```
┌──────────────────────────────────────────────────────┐
│ JoonaPay                                     ┌─────┐ │
│                                              │  ↑  │ │ ← Send
│                                              │Send │ │
│                                              └─────┘ │
│ $1,234.56                                            │
│ Amadou Diallo                                ┌─────┐ │
│                                              │  ↓  │ │ ← Receive
│                                              │Recv │ │
└──────────────────────────────────────────────└─────┘─┘

Size: ~360x158 points
Left: Balance section
Right: Quick action buttons (80pt wide)
Buttons: Individual deep links
```

### Android

#### Small Widget (2x1)
```
┌────────────────────┐
│ JoonaPay           │  ← 11sp, gold
│                    │
│ $1,234.56         │  ← 18sp, bold
│ Your Balance      │  ← 10sp, gray
└────────────────────┘

Size: 110dp width minimum
Height: 40dp
targetCellWidth: 2
targetCellHeight: 1
```

#### Medium Widget (4x1)
```
┌──────────────────────────────────────────┐
│ JoonaPay                      ┌──┐ ┌──┐  │
│                               │↑ │ │↓ │  │
│ $1,234.56                     │  │ │  │  │
│ Amadou Diallo                 └──┘ └──┘  │
└──────────────────────────────────────────┘
                                 Send  Recv

Size: 250dp width minimum
Height: 110dp
targetCellWidth: 4
targetCellHeight: 1
```

## Color Palette

### Background
```
Gradient (135° diagonal):
┌─────────────────┐
│ #0A0A0C        │ ← Top-left (obsidian)
│        ↘       │
│         #111115│ ← Bottom-right (graphite)
└─────────────────┘
```

### Button Backgrounds
```
┌─────────┐
│ #1A1A1F │ ← Slate (solid color)
└─────────┘
Border radius: 8dp
```

### Text Colors
- **App Name**: #C9A962 (gold500)
- **Balance**: #F5F5F0 (textPrimary)
- **Label**: #9A9A9E (textSecondary)
- **Icons**: #C9A962 (gold500)

## Typography

### iOS
```
App name:     System 11pt, Semibold
Balance:      System 18-24pt, Bold
Label:        System 10-11pt, Regular
Button text:  System 9pt, Medium
```

### Android
```
App name:     sans-serif-medium 11sp
Balance:      sans-serif-black 18-24sp
Label:        sans-serif 10-11sp
Button text:  sans-serif-medium 9sp
```

## Icons

### Send Icon (Arrow Up)
```
    ╱│╲
   ╱ │ ╲
  ╱  │  ╲
     │
     │
     │
```
Color: Gold (#C9A962)
Size: 20dp/20pt

### Receive Icon (Arrow Down)
```
     │
     │
     │
  ╲  │  ╱
   ╲ │ ╱
    ╲│╱
```
Color: Gold (#C9A962)
Size: 20dp/20pt

## Spacing

### Widget Padding
```
┌────────────────────────┐
│ ←16dp→                 │
│ ↑                      │
│ 16dp                   │
│ ↓                      │
│        Content         │
│ ↑                      │
│ 16dp                   │
│ ↓                      │
└────────────────────────┘
```

### Element Spacing
```
JoonaPay
   ↕ 8dp
$1,234.56
   ↕ 2-4dp
Amadou Diallo
```

### Button Spacing
```
┌─────┐
│ Send│
└─────┘
  ↕ 8dp
┌─────┐
│ Recv│
└─────┘
```

## States

### Loading State
```
┌─────────────────────────┐
│ JoonaPay                │
│                         │
│ ─────                  │ ← Skeleton loader
│ ───                    │
└─────────────────────────┘
```

### Empty State (No Data)
```
┌─────────────────────────┐
│ JoonaPay                │
│                         │
│ $0.00                  │
│ Tap to open app        │
└─────────────────────────┘
```

### Error State
```
┌─────────────────────────┐
│ JoonaPay                │
│                         │
│ Unable to load         │
│ Tap to refresh         │
└─────────────────────────┘
```

## Platform-Specific Differences

### iOS
- **Corner Radius**: System-managed, larger (16pt)
- **Shadow**: System shadow (elevation 2)
- **Font**: San Francisco (system default)
- **Rendering**: SwiftUI (smooth, 60fps)
- **Update**: Timeline-based, system-optimized

### Android
- **Corner Radius**: 16dp (defined in XML)
- **Shadow**: None (flat design)
- **Font**: Roboto (system default)
- **Rendering**: RemoteViews (limited)
- **Update**: Broadcast-based, 15min throttle

## Accessibility

### Color Contrast
- Balance text: 15:1 (WCAG AAA)
- Labels: 7:1 (WCAG AA)
- Gold accent: 4.5:1 on dark (WCAG AA)

### Font Scaling
- Supports iOS Dynamic Type
- Android: scales with system font size
- Minimum size: 10sp/10pt

### VoiceOver/TalkBack
- Widget: "JoonaPay balance widget"
- Balance: "Balance: 1,234 dollars and 56 cents"
- Send button: "Send money"
- Receive button: "Receive money"

## Dark Mode

All widgets are designed for dark mode by default. Light mode could be added:

```
Light Mode Colors:
Background: #FAFAF8 → #F5F5F2 (gradient)
Text: #1A1A1F (primary), #5A5A5E (secondary)
Gold: #B8943D (slightly darker for contrast)
Buttons: #FFFFFF (white)
```

## Animation

### iOS (WidgetKit)
- Smooth transitions between timeline entries
- Spring animation on tap (system-provided)
- Fade in/out on update

### Android
- No animations (RemoteViews limitation)
- Instant updates
- Possible with App Widgets API 31+ (Android 12)

## Best Practices

### Do's
✅ Keep balance prominent
✅ Use consistent colors
✅ Maintain 16dp/pt padding
✅ Clear, readable text
✅ High contrast
✅ System fonts

### Don'ts
❌ Don't show sensitive data
❌ Don't use small fonts (<10sp/pt)
❌ Don't clutter with too much info
❌ Don't use low-contrast colors
❌ Don't add complex interactions
❌ Don't animate on Android (RemoteViews)

## Testing Checklist

### Visual Testing
- [ ] Colors match app design system
- [ ] Text is readable at all sizes
- [ ] Icons are clear and recognizable
- [ ] Spacing is consistent
- [ ] Alignment is correct
- [ ] No text truncation

### Responsive Testing
- [ ] Small screen (iPhone SE)
- [ ] Large screen (iPhone 15 Pro Max)
- [ ] Tablet (iPad)
- [ ] Various Android screen sizes
- [ ] Landscape orientation
- [ ] Font scaling (150%, 200%)

### Dark Mode Testing
- [ ] All text is readable
- [ ] Colors have sufficient contrast
- [ ] No "white flashes"
- [ ] Consistent with app theme

## Implementation Notes

### Currency Formatting

**USD:**
```dart
String.format("$%.2f", 1234.56)
// Result: "$1,234.56"
```

**XOF:**
```dart
NumberFormat.format(100000)
// Result: "XOF 100 000" (with spaces)
```

### Balance Display
- Maximum: $999,999.99
- Minimum: $0.00
- Fallback: Show $0.00 if null

### Update Timing
- App foreground: Immediate
- Background: Every 15 minutes
- Transaction complete: Immediate
- Login/Logout: Immediate

## Platform Preview Commands

### iOS
```bash
# Open widget gallery in simulator
xcrun simctl ui booted homescreen addWidget com.joonapay.usdcwallet.BalanceWidget

# Refresh widget
xcrun simctl ui booted refreshWidgets com.joonapay.usdcwallet.BalanceWidget
```

### Android
```bash
# List all widgets
adb shell dumpsys appwidget

# Force update
adb shell am broadcast -a com.joonapay.usdc_wallet.UPDATE_WIDGET
```

## Design Files

For designers:
- Figma template: Available on request
- Icon assets: res/drawable/ (Android), Assets.xcassets (iOS)
- Color tokens: lib/design/tokens/colors.dart

## References

- [iOS Human Interface Guidelines - Widgets](https://developer.apple.com/design/human-interface-guidelines/widgets)
- [Material Design - Widgets](https://m3.material.io/components/widgets)
- [JoonaPay Design System](lib/design/tokens/)
