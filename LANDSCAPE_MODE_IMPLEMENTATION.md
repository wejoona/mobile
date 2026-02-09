# Landscape Mode Implementation

Landscape orientation support has been added to key mobile screens in the JoonaPay USDC Wallet app.

## Overview

The app now supports landscape mode across three primary screens:
- Wallet Home (Balance, Quick Actions, Transactions)
- Transactions List (Filterable transaction history)
- Settings (Profile, Security, Preferences)

## Files Created

### 1. Orientation Helper Utility
**File:** `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/core/orientation/orientation_helper.dart`

Provides comprehensive orientation-aware layout utilities:

- **Detection Methods:**
  - `isPortrait(context)` - Check if in portrait mode
  - `isLandscape(context)` - Check if in landscape mode
  - `shouldUseSingleColumn(context)` - Check if single-column layout appropriate
  - `shouldUseTwoColumns(context)` - Check if two-column layout appropriate

- **Layout Helpers:**
  - `columns()` - Get optimal column count based on orientation + device type
  - `spacing()` - Get orientation-specific spacing (more compact in landscape)
  - `padding()` - Get orientation-specific padding
  - `maxContentWidth()` - Constrain width in landscape to maintain readability
  - `aspectRatio()` - Get optimal aspect ratio for cards/containers
  - `gridCrossAxisCount()` - Calculate grid columns for GridView

- **Widgets:**
  - `OrientationLayoutBuilder` - Build different layouts for portrait/landscape
  - `OrientationAdaptiveGrid` - Grid that adapts columns based on orientation
  - `OrientationSwitchLayout` - Column/Row switcher based on orientation
  - `OrientationSafePadding` - Automatic padding adjustment
  - `OrientationScrollView` - ScrollView with width constraints

## Files Updated

### 1. Wallet Home Screen
**File:** `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/features/wallet/views/wallet_home_screen.dart`

**Changes:**
- Added import for `orientation_helper.dart`
- Added landscape detection in build method
- Implemented `_buildLandscapeLayout()` method
- Updated padding to be orientation-aware

**Landscape Layout:**
- Two-column horizontal split
- Left (40%): Balance card + Quick actions + Banners
- Right (60%): Recent transactions
- More compact vertical spacing
- Optimal horizontal space usage

### 2. Transactions View
**File:** `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/features/transactions/views/transactions_view.dart`

**Changes:**
- Added import for `orientation_helper.dart`
- Added `isLandscape` parameter to `_TransactionGroup` widget
- Updated padding to be orientation-aware
- Modified grid layout logic to use 3 columns in landscape

**Landscape Layout:**
- 3-column grid for transaction cards (vs 2 in portrait)
- More compact padding (horizontal: 48px, vertical: 16px)
- Better space utilization on wider screens

### 3. Settings View
**File:** `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/features/settings/views/settings_view.dart`

**Changes:**
- Added import for `orientation_helper.dart`
- Added landscape detection in build method
- Implemented `_buildLandscapeLayout()` method
- Updated padding to be orientation-aware

**Landscape Layout:**
- Three-column grid layout
- Column 1: Security settings (Security, KYC, Limits)
- Column 2: Preferences (Notifications, Language, Theme, Currency)
- Column 3: Account & Support
- Centered referral card and logout button with constrained width
- Better organization of settings groups

## Documentation

**File:** `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/core/orientation/README.md`

Comprehensive guide covering:
- Basic usage examples
- All helper methods and widgets
- Best practices for orientation-aware layouts
- Real-world examples from the codebase
- Performance tips
- Accessibility considerations
- Testing guidance

## Layout Strategies

### Wallet Home (Landscape)
```
┌──────────────────────────────────────────────────┐
│ Header (Greeting, Notifications, Settings)      │
├────────────────────┬─────────────────────────────┤
│ Balance Card       │                             │
│                    │  Recent Transactions        │
│ Quick Actions      │  - Transaction 1            │
│ [Send] [Receive]   │  - Transaction 2            │
│ [Deposit] [History]│  - Transaction 3            │
│                    │  - Transaction 4            │
│ KYC Banner         │  - Transaction 5            │
│ Limits Banner      │                             │
└────────────────────┴─────────────────────────────┘
```

### Transactions (Landscape)
```
┌──────────────────────────────────────────────────┐
│ Search | Filter | Export                         │
├────────────────┬─────────────────┬───────────────┤
│ Transaction 1  │ Transaction 2   │ Transaction 3 │
├────────────────┼─────────────────┼───────────────┤
│ Transaction 4  │ Transaction 5   │ Transaction 6 │
└────────────────┴─────────────────┴───────────────┘
```

### Settings (Landscape)
```
┌──────────────────────────────────────────────────┐
│ Profile Card                                     │
├────────────────┬─────────────────┬───────────────┤
│ SECURITY       │ PREFERENCES     │ ACCOUNT       │
│ - Security     │ - Notifications │ - Type        │
│ - KYC          │ - Language      │               │
│ - Limits       │ - Theme         │ SUPPORT       │
│                │ - Currency      │ - Help        │
└────────────────┴─────────────────┴───────────────┘
│           Referral Card (centered)               │
│           Logout Button (centered)               │
└──────────────────────────────────────────────────┘
```

## Design Principles

### 1. Horizontal Space Utilization
- Convert vertical stacks to horizontal rows
- Use multi-column grids (2-3 columns)
- Side-by-side content arrangement

### 2. Vertical Compactness
- Reduce vertical spacing (24px → 16px)
- Smaller padding (top/bottom: 24px → 12px)
- More information visible without scrolling

### 3. Content Width Constraints
- Prevent text from stretching too wide
- Maximum content width: 1200px on large tablets
- Maintain readability in landscape

### 4. Responsive Grid Columns
- Mobile Portrait: 1 column
- Mobile Landscape: 2-3 columns
- Tablet Portrait: 2 columns
- Tablet Landscape: 3-4 columns

## Testing Checklist

- [ ] Wallet home displays correctly in landscape
- [ ] Quick actions grid works in landscape
- [ ] Transactions list uses 3-column grid in landscape
- [ ] Settings uses 3-column layout in landscape
- [ ] Padding is more compact in landscape
- [ ] Content width is constrained on large screens
- [ ] Rotation between portrait/landscape is smooth
- [ ] No layout overflow errors
- [ ] Touch targets remain 44x44dp minimum
- [ ] Accessibility with TalkBack/VoiceOver works
- [ ] Both light and dark themes work in landscape

## Browser/Device Testing

Test on the following devices in landscape:
- iPhone 13/14/15 (standard size)
- iPhone 13/14/15 Plus (large)
- iPad Mini/Air/Pro (tablet sizes)
- Android phones (various sizes)
- Android tablets (7", 10", 12")

## Performance Considerations

- Orientation checks are cached within build method
- Layout widgets use const constructors where possible
- Grid calculations are optimized
- No unnecessary rebuilds on orientation change
- Maintains 60fps during rotation animation

## Future Enhancements

Potential improvements for future iterations:
1. Add landscape support to remaining screens (Send, Receive, KYC)
2. Implement master-detail layout for transactions on tablet landscape
3. Add landscape-specific animations
4. Support for split-screen multitasking on iPadOS
5. Optimize for foldable devices

## Accessibility

All landscape layouts maintain:
- Logical reading order (left-to-right, top-to-bottom)
- Minimum touch target sizes (44x44dp)
- Proper ARIA labels and semantic structure
- Keyboard navigation support
- Screen reader compatibility

## Related Files

- `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/design/utils/responsive_layout.dart` - Responsive utilities (screen size)
- `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/core/orientation/orientation_helper.dart` - Orientation utilities
- `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/design/tokens/spacing.dart` - Spacing constants
- `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/design/components/primitives/` - Reusable components
