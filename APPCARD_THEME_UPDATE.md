# AppCard Theme Update Summary

## Overview
Updated the AppCard component to properly support light and dark themes with improved variants, shadow handling, and selection states.

## Files Modified

### 1. `/lib/design/components/primitives/app_card.dart`
**Status:** Updated

**Changes:**
- Added new card variants:
  - `flat` - No shadow, subtle border (best for dense layouts)
  - `elevated` - Shadow with no border (default variant)
  - `outlined` - Visible border, no shadow (good for forms)
  - `filled` - Solid background color (tinted gold when selected)
  - Kept existing: `goldAccent`, `glass`
  - Deprecated `subtle` (use `flat` instead)

- Added theme-aware properties:
  - `isSelected` - Boolean for selection state
  - `backgroundColor` - Override default background
  - `borderColor` - Override default border

- Improved theme adaptation:
  - Card backgrounds use `context.colors.container`
  - Borders adapt to theme with `context.colors.borderSubtle`
  - Shadows are lighter in light mode, stronger in dark mode
  - Selected cards show gold border and tinted background
  - Splash/highlight colors adapt to theme

- Selection state features:
  - Gold border (2px) when selected
  - Gold-tinted background for filled variant
  - Gold-tinted ripple effects
  - Works across all variants

### 2. `/lib/catalog/sections/card_catalog.dart`
**Status:** Updated

**Changes:**
- Added examples for all new card variants
- Added dedicated section for selection states
- Shows flat, elevated, outlined, and filled variants
- Demonstrates selected vs unselected states
- Updated descriptions to match new functionality

### 3. `/lib/design/tokens/shadows.dart`
**Status:** Updated

**Changes:**
- Added header documentation about theme adaptation
- Added light mode shadow variants:
  - `lightSm`, `lightMd`, `lightLg`, `lightXl`
  - `lightCard` - Optimized for light backgrounds
- Updated all shadow colors to use `withValues(alpha:)` instead of deprecated `withOpacity()`
- Light mode shadows use reduced opacity (0.05-0.14 vs 0.3-0.5) for better contrast

### 4. `/lib/design/components/primitives/app_card_examples.dart`
**Status:** New file created

**Purpose:** Comprehensive examples and documentation

**Content:**
- Full examples of all card variants
- Selection state demonstrations
- Interactive card examples
- Custom styling examples (semantic colors)
- Real-world patterns (payment methods, feature highlights)
- Code snippets for common use cases

## Theme Adaptations

### Dark Mode (Brightness.dark)
- Background: `AppColors.slate` (#1A1A1F)
- Borders: `AppColors.borderSubtle` (6% white)
- Shadows: Strong opacity (0.3-0.5) for depth
- Selected border: `AppColors.gold500` (#C9A962)

### Light Mode (Brightness.light)
- Background: `AppColorsLight.container` (#FFFFFF)
- Borders: `AppColorsLight.borderSubtle` (6% black)
- Shadows: Light opacity (0.04-0.12) for subtle elevation
- Selected border: `AppColorsLight.gold500` (#B8943D)

## Usage Examples

### Basic Card
```dart
AppCard(
  variant: AppCardVariant.elevated, // default
  child: Text('Card content'),
)
```

### Selectable Card
```dart
AppCard(
  variant: AppCardVariant.outlined,
  isSelected: isSelected,
  onTap: () => setState(() => isSelected = !isSelected),
  child: Row(
    children: [
      Icon(isSelected ? Icons.check_circle : Icons.circle_outlined),
      Text('Option'),
    ],
  ),
)
```

### Custom Semantic Card
```dart
AppCard(
  variant: AppCardVariant.outlined,
  backgroundColor: colors.successBg,
  borderColor: colors.success,
  child: Row(
    children: [
      Icon(Icons.check_circle, color: colors.success),
      Text('Success message'),
    ],
  ),
)
```

### Interactive Card
```dart
AppCard(
  variant: AppCardVariant.elevated,
  onTap: () => Navigator.push(...),
  child: Row(
    children: [
      Icon(Icons.settings),
      Expanded(child: Text('Settings')),
      Icon(Icons.chevron_right),
    ],
  ),
)
```

## Variant Guide

| Variant | Use Case | Shadow | Border |
|---------|----------|--------|--------|
| `flat` | Dense layouts, minimal emphasis | None | Subtle |
| `elevated` | Default cards, main content | Yes (theme-aware) | None |
| `outlined` | Form sections, grouped settings | None | Visible |
| `filled` | Selectable options, radio buttons | None | When selected |
| `goldAccent` | Premium content, featured items | Yes | Gold |
| `glass` | Over images/backgrounds | Light | Subtle |

## Performance Improvements

- Shadows are computed once based on theme
- Color calculations use theme context (no rebuilds)
- Ripple effects are theme-aware
- Border widths optimize for selected state (1px → 2px)

## Accessibility

- High contrast borders in both themes
- Selected state is visually distinct (color + thickness)
- Touch targets remain 44x44 minimum
- Ripple effects provide visual feedback
- Works with screen readers (semantic structure preserved)

## Migration Notes

### Breaking Changes
- None. All existing code continues to work.
- `subtle` variant deprecated but still functional (use `flat` instead)

### Recommended Updates
1. Replace `AppCardVariant.subtle` with `AppCardVariant.flat`
2. Use `isSelected` instead of custom border/background overrides
3. Let shadows auto-adapt to theme (remove custom BoxDecoration)

### Before
```dart
Container(
  decoration: BoxDecoration(
    color: colors.container,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: isSelected ? colors.gold : colors.border),
    boxShadow: AppShadows.card,
  ),
  child: content,
)
```

### After
```dart
AppCard(
  variant: AppCardVariant.outlined,
  isSelected: isSelected,
  child: content,
)
```

## Testing

### Manual Testing Checklist
- [ ] View cards in light mode
- [ ] View cards in dark mode
- [ ] Test selection state in both themes
- [ ] Verify ripple effects on tap
- [ ] Check shadows are appropriate for theme
- [ ] Test custom background/border colors
- [ ] Verify catalog displays correctly
- [ ] Test on web (hover states)
- [ ] Test on mobile (touch feedback)

### Visual Regression
- Review catalog in light mode
- Review catalog in dark mode
- Compare shadows between themes
- Verify gold accents are consistent

## Next Steps

1. Update existing cards throughout the app to use new variants
2. Add selection state to relevant UIs (payment methods, options)
3. Consider adding hover states for web/desktop
4. Document theme switching in design system guide

## References

- Component: `/lib/design/components/primitives/app_card.dart`
- Examples: `/lib/design/components/primitives/app_card_examples.dart`
- Catalog: `/lib/catalog/sections/card_catalog.dart`
- Shadows: `/lib/design/tokens/shadows.dart`
- Colors: `/lib/design/tokens/theme_colors.dart`
