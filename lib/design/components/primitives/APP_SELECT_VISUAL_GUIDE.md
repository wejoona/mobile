# AppSelect Visual Guide

Visual reference for the AppSelect component states and styling.

## Component Anatomy

```
┌─────────────────────────────────────────┐
│ Label (labelMedium, textSecondary)     │
├─────────────────────────────────────────┤
│ ┌─────────────────────────────────────┐ │
│ │ [Icon] Selected Value        [▼]   │ │
│ └─────────────────────────────────────┘ │
│ Helper text (bodySmall, textSecondary)  │
└─────────────────────────────────────────┘
```

## States

### 1. Idle (Default)
```
Background: AppColors.elevated (#222228)
Border: 1px AppColors.borderDefault (10% white)
Label: AppColors.textSecondary (#9A9A9E)
Value: AppColors.textPrimary (#F5F5F0)
Icon: AppColors.textTertiary (#6B6B70)
```

Visual:
```
┌─────────────────────────────────────────┐
│ Country                                 │
├─────────────────────────────────────────┤
│ ┌─────────────────────────────────────┐ │
│ │ 🏳️  Select your country      ▼    │ │ ← Slate bg, subtle border
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

### 2. Focused
```
Background: AppColors.elevated (#222228)
Border: 2px AppColors.gold500 (#C9A962) ← GOLD HIGHLIGHT
Label: AppColors.gold500 (#C9A962) ← GOLD
Value: AppColors.textPrimary (#F5F5F0)
Icon: AppColors.gold500 (#C9A962) ← GOLD
```

Visual:
```
┌─────────────────────────────────────────┐
│ Country ⭐ (gold text)                  │
├═════════════════════════════════════════┤ ← Thicker gold border
│ ║ 🏳️  Select your country   ⭐▼    ║ │
│ ╚═════════════════════════════════════╝ │
└─────────────────────────────────────────┘
```

### 3. Selected with Value
```
Background: AppColors.elevated (#222228)
Border: 1px AppColors.borderDefault (10% white)
Label: AppColors.textSecondary (#9A9A9E)
Value: AppColors.textPrimary (#F5F5F0)
Icon: AppColors.textTertiary (#6B6B70)
```

Visual:
```
┌─────────────────────────────────────────┐
│ Country                                 │
├─────────────────────────────────────────┤
│ ┌─────────────────────────────────────┐ │
│ │ 🏳️  United States           ▼    │ │ ← Shows selected value
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

### 4. Error State
```
Background: AppColors.errorBase.withValues(alpha: 0.05) (5% red)
Border: 1px AppColors.errorBase (#8B2942) ← RED BORDER
Label: AppColors.errorText (#E57B8D) ← RED
Value: AppColors.textPrimary (#F5F5F0)
Icon: AppColors.errorBase (#8B2942) ← RED
Error Text: AppColors.errorText (#E57B8D)
```

Visual:
```
┌─────────────────────────────────────────┐
│ Country 🔴 (red text)                   │
├─────────────────────────────────────────┤
│ ┌─────────────────────────────────────┐ │ ← Red border
│ │ 🏳️  Select your country   🔴▼    │ │ ← Red tint
│ └─────────────────────────────────────┘ │
│ ⚠️ This field is required (red text)    │
└─────────────────────────────────────────┘
```

### 5. Disabled State
```
Background: AppColors.elevated.withValues(alpha: 0.5) (50% opacity)
Border: 1px AppColors.borderSubtle (6% white)
Label: AppColors.textDisabled (#4A4A4E)
Value: AppColors.textDisabled (#4A4A4E)
Icon: AppColors.textDisabled (#4A4A4E)
```

Visual:
```
┌─────────────────────────────────────────┐
│ Country (muted gray)                    │
├─────────────────────────────────────────┤
│ ┌─────────────────────────────────────┐ │
│ │ 🏳️  Not available         ▼      │ │ ← Muted colors
│ └─────────────────────────────────────┘ │ ← No interaction
└─────────────────────────────────────────┘
```

## Dropdown Menu (Bottom Sheet)

### Closed State
```
Bottom sheet hidden
```

### Open State
```
┌─────────────────────────────────────────┐
│                  ═══                     │ ← Handle bar (borderDefault)
│                                          │
│  Country                                 │ ← Title (titleMedium)
├──────────────────────────────────────────┤
│                                          │
│  ┌────────────────────────────────────┐ │
│  │ 🏳️  United States      ⭐✓       │ │ ← Selected (gold bg tint)
│  └────────────────────────────────────┘ │
│                                          │
│  ┌────────────────────────────────────┐ │
│  │ 🏳️  Côte d'Ivoire                 │ │ ← Unselected
│  └────────────────────────────────────┘ │
│                                          │
│  ┌────────────────────────────────────┐ │
│  │ 🏳️  France                         │ │
│  └────────────────────────────────────┘ │
│                                          │
└──────────────────────────────────────────┘

Background: AppColors.slate (#1A1A1F)
Selected item bg: AppColors.gold500.withValues(alpha: 0.1)
Selected text: AppColors.gold500 (#C9A962) ⭐
Checkmark: AppColors.gold500 (#C9A962) ⭐
Normal text: AppColors.textPrimary (#F5F5F0)
```

## Item with Subtitle

```
┌────────────────────────────────────────┐
│ 💰 US Dollar (USD)              ✓     │ ← Primary label (gold if selected)
│    United States                       │ ← Subtitle (textSecondary)
└────────────────────────────────────────┘

Label: AppTextVariant.bodyLarge
Subtitle: AppTextVariant.bodySmall (#9A9A9E)
```

## Item without Checkmark

```
┌────────────────────────────────────────┐
│ 📅 Today                               │ ← No checkmark
└────────────────────────────────────────┘

Used when showCheckmark: false
Still shows selection via gold text and background
```

## Color Palette Reference

### Dark Theme (Default)
- **Obsidian**: `#0A0A0C` - Main canvas
- **Slate**: `#1A1A1F` - Dropdown background
- **Elevated**: `#222228` - Input background
- **Gold500**: `#C9A962` - Primary accent ⭐
- **Text Primary**: `#F5F5F0` - Main text
- **Text Secondary**: `#9A9A9E` - Labels
- **Text Tertiary**: `#6B6B70` - Icons (idle)
- **Border Default**: `rgba(255,255,255,0.1)` - 10% white
- **Border Subtle**: `rgba(255,255,255,0.06)` - 6% white
- **Error Base**: `#8B2942` - Error border/icon
- **Error Text**: `#E57B8D` - Error message

### Spacing
- **lg**: 16px - Main padding
- **md**: 12px - Icon gap
- **sm**: 8px - Label margin
- **xs**: 4px - Small gaps

### Border Radius
- **md**: 8px - Input field
- **xl**: 16px - Dropdown top corners
- **sm**: 4px - Handle bar

## Interaction States

### Tap/Click
```
Input Field → Opens bottom sheet
├─ Shows handle bar
├─ Displays title (if label exists)
├─ Lists all items
└─ Scrollable if needed

Bottom Sheet Item → Selects value
├─ Updates input field
├─ Calls onChanged callback
├─ Closes bottom sheet
└─ Shows checkmark (if enabled)
```

### Focus Flow
```
1. Default: Subtle border, gray icons
2. Tap: Gold border, gold icons, gold label
3. Sheet opens: Slate background, gold selection
4. Select: Updates value, sheet closes
5. Returns to: Selected state (or default if cleared)
```

## Comparison with Standard DropdownButton

### Standard Flutter
```
┌─────────────────────────────────┐
│ Select ▼                         │ ← System dropdown
├─────────────────────────────────┤   (native styling)
│ Option 1                         │
│ Option 2                         │
└─────────────────────────────────┘
```

### AppSelect
```
┌─────────────────────────────────┐
│ Label (luxury styling)           │
├─────────────────────────────────┤
│ 🎯 Selected Value    ▼          │ ← Custom luxury style
├─────────────────────────────────┤   gold accents
│ Bottom sheet modal               │   better mobile UX
│ ┌─────────────────────────────┐ │
│ │ 🎯 Option 1        ⭐✓     │ │
│ │ 🎯 Option 2                │ │
│ └─────────────────────────────┘ │
└─────────────────────────────────┘
```

## Implementation Notes

### Minimum Touch Target
- Height: 48px (accessibility standard)
- Full width tappable area
- Large dropdown items for easy selection

### Animation
- Border width: instant (1px ↔ 2px)
- Border color: 150ms transition
- Bottom sheet: Material slide animation
- Ripple effect on item tap

### Safe Areas
- Bottom sheet respects device safe area
- No content behind notches
- Proper keyboard avoidance

## Usage Recommendations

✅ **Do:**
- Use for 3-20 options
- Include icons when meaningful
- Show subtitles for clarity
- Use error state for validation
- Keep labels concise

❌ **Don't:**
- Use for 2 options (use radio buttons)
- Use for 100+ options (use search)
- Overcrowd with icons
- Skip accessibility labels
- Ignore error states

## Accessibility

- **Screen Readers**: Announces label, value, and state
- **Keyboard**: Full navigation support
- **Touch Targets**: Minimum 48px
- **Color Contrast**: WCAG AA compliant
- **Focus Indicators**: Clear gold borders
