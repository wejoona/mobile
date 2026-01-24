# JoonaPay Design System

## Graphical Charter & Design Rules

**Version:** 1.0
**Last Updated:** January 2026
**Platform:** Flutter Mobile (iOS & Android)

---

## 1. Design Philosophy

### Brand Essence
JoonaPay embodies **luxury fintech** - combining premium aesthetics with the functionality of a digital wallet. The design language communicates:

- **Trust** through dark, sophisticated tones
- **Wealth** through gold accents
- **Sophistication** through low saturation and refined typography
- **Modernity** through glassmorphism and subtle animations

### Design Principles
1. **Dark by Default** - Dark themes reduce eye strain and convey premium quality
2. **Gold as Accent** - Gold represents achievement and financial success (use sparingly - 5% of UI)
3. **Whitespace is Luxury** - Generous spacing elevates the experience
4. **Motion with Purpose** - Animations should be subtle and meaningful

---

## 2. Color System

### 2.1 Dark Foundations (70% of UI)

| Token | Hex | RGB | Usage |
|-------|-----|-----|-------|
| `obsidian` | `#0A0A0C` | 10, 10, 12 | Main canvas, deep background |
| `graphite` | `#111115` | 17, 17, 21 | Elevated surfaces, nav bars |
| `slate` | `#1A1A1F` | 26, 26, 31 | Cards, containers |
| `elevated` | `#222228` | 34, 34, 40 | Hover states, inputs |
| `glass` | `#1A1A1F` @ 85% | - | Glassmorphism overlays |

### 2.2 Text Hierarchy (20% of UI)

| Token | Hex | Opacity | Usage |
|-------|-----|---------|-------|
| `textPrimary` | `#F5F5F0` | 100% | High emphasis - headings, amounts |
| `textSecondary` | `#9A9A9E` | 100% | Medium emphasis - labels, descriptions |
| `textTertiary` | `#6B6B70` | 100% | Low emphasis - hints, placeholders |
| `textDisabled` | `#4A4A4E` | 100% | Disabled states |
| `textInverse` | `#0A0A0C` | 100% | On gold/light backgrounds |

### 2.3 Gold Accent System (5% of UI)

Use gold sparingly for maximum impact on CTAs and highlights.

| Token | Hex | Usage |
|-------|-----|-------|
| `gold50` | `#FDF8E7` | Lightest tint |
| `gold100` | `#F9EDCC` | Light backgrounds |
| `gold200` | `#F0D999` | Subtle accents |
| `gold300` | `#E5C266` | Secondary gold |
| `gold400` | `#D9AE40` | Bright gold |
| **`gold500`** | **`#C9A962`** | **Primary - CTAs, icons, highlights** |
| `gold600` | `#B89852` | Pressed/active state |
| `gold700` | `#9A7A3D` | Borders, outlines |
| `gold800` | `#7A5E2F` | Dark accent |
| `gold900` | `#5C4522` | Subtle gold |

#### Gold Gradient
```dart
LinearGradient(
  colors: [#C9A962, #E5C266, #C9A962],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)
```

### 2.4 Semantic Colors

#### Success (Emerald - Wealth & Growth)
| Token | Hex | Usage |
|-------|-----|-------|
| `successBase` | `#2D6A4F` | Success backgrounds |
| `successLight` | `#3D8B6E` | Hover state |
| `successDark` | `#1E4D38` | Pressed state |
| `successText` | `#7DD3A8` | Success text/icons |

#### Warning (Amber)
| Token | Hex | Usage |
|-------|-----|-------|
| `warningBase` | `#C9943A` | Warning backgrounds |
| `warningLight` | `#DAA84E` | Hover state |
| `warningDark` | `#A67828` | Pressed state |
| `warningText` | `#F0C674` | Warning text/icons |

#### Error (Crimson Velvet)
| Token | Hex | Usage |
|-------|-----|-------|
| `errorBase` | `#8B2942` | Error backgrounds |
| `errorLight` | `#A63D4E` | Hover state |
| `errorDark` | `#6D1F33` | Pressed state |
| `errorText` | `#E57B8D` | Error text/icons |

#### Info (Steel Blue)
| Token | Hex | Usage |
|-------|-----|-------|
| `infoBase` | `#4A6FA5` | Info backgrounds |
| `infoLight` | `#5B82B8` | Hover state |
| `infoDark` | `#3A5A89` | Pressed state |
| `infoText` | `#8BB4E0` | Info text/icons |

### 2.5 Borders & Dividers

| Token | Value | Usage |
|-------|-------|-------|
| `borderSubtle` | `#FFFFFF` @ 6% | Subtle separators |
| `borderDefault` | `#FFFFFF` @ 10% | Default borders |
| `borderStrong` | `#FFFFFF` @ 15% | Emphasized borders |
| `borderGold` | `#C9A962` @ 30% | Gold accent borders |
| `borderGoldStrong` | `#C9A962` @ 50% | Strong gold borders |

### 2.6 Overlays

| Token | Value | Usage |
|-------|-------|-------|
| `overlayLight` | `#FFFFFF` @ 5% | Subtle hover effect |
| `overlayMedium` | `#FFFFFF` @ 10% | Press states |
| `overlayDark` | `#000000` @ 50% | Dimming |
| `overlayScrim` | `#000000` @ 80% | Modal backgrounds |

---

## 3. Typography

### 3.1 Font Families

| Purpose | Font | Weight Range |
|---------|------|--------------|
| **Display** | Playfair Display | 600-700 |
| **Body** | DM Sans | 400-600 |
| **Monospace** | JetBrains Mono | 400-500 |

### 3.2 Type Scale

#### Display (Headlines, Balance Amounts)
| Style | Size | Weight | Letter Spacing |
|-------|------|--------|----------------|
| `displayLarge` | 72px | 700 | -2px |
| `displayMedium` | 48px | 700 | -1.5px |
| `displaySmall` | 36px | 600 | -1px |

#### Headlines
| Style | Size | Weight | Letter Spacing |
|-------|------|--------|----------------|
| `headlineLarge` | 32px | 600 | -0.5px |
| `headlineMedium` | 28px | 600 | -0.25px |
| `headlineSmall` | 24px | 600 | 0 |

#### Titles
| Style | Size | Weight | Letter Spacing |
|-------|------|--------|----------------|
| `titleLarge` | 22px | 600 | 0 |
| `titleMedium` | 18px | 500 | 0.15px |
| `titleSmall` | 16px | 500 | 0.1px |

#### Body
| Style | Size | Weight | Letter Spacing |
|-------|------|--------|----------------|
| `bodyLarge` | 16px | 400 | 0.5px |
| `bodyMedium` | 14px | 400 | 0.25px |
| `bodySmall` | 12px | 400 | 0.4px |

#### Labels
| Style | Size | Weight | Letter Spacing |
|-------|------|--------|----------------|
| `labelLarge` | 14px | 500 | 0.1px |
| `labelMedium` | 12px | 500 | 0.5px |
| `labelSmall` | 11px | 500 | 0.5px |

#### Monospace (Numbers, Codes)
| Style | Size | Weight | Letter Spacing |
|-------|------|--------|----------------|
| `monoLarge` | 24px | 500 | -0.5px |
| `monoMedium` | 16px | 400 | 0 |
| `monoSmall` | 12px | 400 | 0 |

#### Special Styles
| Style | Font | Size | Weight | Usage |
|-------|------|------|--------|-------|
| `balanceDisplay` | Playfair | 42px | 700 | Wallet balance |
| `percentageChange` | DM Sans | 14px | 500 | % change indicators |
| `button` | DM Sans | 16px | 600 | Button labels |
| `cardLabel` | DM Sans | 13px | 500 | Card section labels |

---

## 4. Spacing System

### 4.1 Base Scale (8pt Grid)

| Token | Value | Usage |
|-------|-------|-------|
| `xxs` | 2px | Minimal gaps |
| `xs` | 4px | Icon gaps, tight spacing |
| `sm` | 8px | Base unit, inline elements |
| `md` | 12px | Related elements |
| `lg` | 16px | Section gaps |
| `xl` | 20px | Component padding |
| `xxl` | 24px | Section spacing |
| `xxxl` | 32px | Large gaps |
| `huge` | 40px | Major sections |
| `massive` | 48px | Page sections |
| `giant` | 64px | Hero spacing |

### 4.2 Component Spacing

| Token | Value | Usage |
|-------|-------|-------|
| `cardPadding` | 20px | Default card internal padding |
| `cardPaddingLarge` | 24px | Large card padding |
| `sectionGap` | 24px | Between content sections |
| `screenPadding` | 20px | Screen edge padding |
| `listItemSpacing` | 12px | Between list items |
| `inputPadding` | 16px | Input field padding |
| `buttonPadding` | 16px | Button internal padding |
| `iconGap` | 12px | Icon to text spacing |

---

## 5. Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| `none` | 0 | Sharp corners |
| `xs` | 4px | Subtle rounding |
| `sm` | 6px | Small elements |
| `md` | 8px | Default (buttons, inputs) |
| `lg` | 12px | Cards |
| `xl` | 16px | Large cards |
| `xxl` | 20px | Modals, bottom sheets |
| `xxxl` | 24px | Hero elements |
| `full` | 9999px | Pills, avatars, circular |

---

## 6. Shadows & Elevation

### 6.1 Standard Shadows

```dart
// Small - subtle depth
BoxShadow(
  color: Colors.black @ 30%,
  blurRadius: 2,
  offset: Offset(0, 1),
)

// Medium - cards
BoxShadow(
  color: Colors.black @ 40%,
  blurRadius: 6,
  offset: Offset(0, 4),
  spreadRadius: -1,
)

// Large - modals
BoxShadow(
  color: Colors.black @ 50%,
  blurRadius: 15,
  offset: Offset(0, 10),
  spreadRadius: -3,
)

// XL - floating elements
BoxShadow(
  color: Colors.black @ 50%,
  blurRadius: 25,
  offset: Offset(0, 20),
  spreadRadius: -5,
)
```

### 6.2 Card Shadows

```dart
// Default card shadow
[
  BoxShadow(color: black @ 40%, blur: 32, offset: (0, 8)),
  BoxShadow(color: black @ 30%, blur: 8, offset: (0, 2)),
]

// Hover state
[
  BoxShadow(color: black @ 50%, blur: 48, offset: (0, 16)),
  BoxShadow(color: black @ 40%, blur: 12, offset: (0, 4)),
]
```

### 6.3 Glow Effects

```dart
// Gold glow (primary CTA)
BoxShadow(color: gold500 @ 30%, blurRadius: 20)

// Strong gold glow
BoxShadow(color: gold500 @ 40%, blurRadius: 40)

// Success glow
BoxShadow(color: successBase @ 30%, blurRadius: 20)

// Error glow
BoxShadow(color: errorBase @ 30%, blurRadius: 20)
```

---

## 7. Components

### 7.1 Buttons

#### Variants

| Variant | Background | Text | Border | Usage |
|---------|------------|------|--------|-------|
| `primary` | Gold gradient | `textInverse` | None | Main CTAs |
| `secondary` | Transparent | `textPrimary` | `borderDefault` | Secondary actions |
| `ghost` | Transparent | `gold500` | None | Tertiary actions |
| `success` | `successBase` | `textPrimary` | None | Confirmation |
| `danger` | `errorBase` | `textPrimary` | None | Destructive |

#### Sizes

| Size | Padding H | Padding V | Font Size |
|------|-----------|-----------|-----------|
| `small` | 12px | 8px | 13px |
| `medium` | 20px | 12px | 15px |
| `large` | 24px | 16px | 17px |

#### States
- **Disabled**: Background becomes `elevated`, text becomes `textDisabled`
- **Loading**: Show centered spinner, same color as text
- **Pressed**: Darker shade of variant color

### 7.2 Cards

#### Variants

| Variant | Background | Border | Shadow | Usage |
|---------|------------|--------|--------|-------|
| `elevated` | `slate` | `borderSubtle` | `card` | Default cards |
| `goldAccent` | `slate` | `borderGold` | `card` | Featured content |
| `subtle` | `graphite` | `borderSubtle` | None | Low emphasis |
| `glass` | `glass` (85%) | `borderSubtle` | `md` | Overlays |

#### Default Properties
- Border radius: 16px (`xl`)
- Padding: 20px
- Tap feedback: `overlayLight` splash

### 7.3 Inputs

#### Variants

| Variant | Keyboard | Alignment | Style |
|---------|----------|-----------|-------|
| `standard` | Text | Left | `bodyLarge` |
| `phone` | Phone | Left | `bodyLarge` |
| `pin` | Number | Center | `monoLarge` |
| `amount` | Decimal | Center | `monoLarge` |
| `search` | Text | Left | `bodyLarge` |

#### States
- **Default**: `borderDefault` border
- **Focused**: `gold500` border (2px)
- **Error**: `errorBase` border
- **Disabled**: Reduced opacity

#### Structure
- Fill color: `elevated`
- Border radius: 8px (`md`)
- Padding: 16px horizontal, 16px vertical
- Label: Above input, `labelMedium` style

### 7.4 Text Component

Use the `AppText` widget for consistent typography:

```dart
AppText(
  'Hello World',
  variant: AppTextVariant.titleLarge,
  color: AppColors.gold500, // Optional override
)
```

---

## 8. Layout Guidelines

### 8.1 Screen Structure

```
┌─────────────────────────────────────┐
│  Status Bar (system)                │
├─────────────────────────────────────┤
│  App Bar (obsidian, centered title) │ 56px
├─────────────────────────────────────┤
│                                     │
│  Content Area                       │
│  - Screen padding: 20px             │
│  - Section gap: 24px                │
│                                     │
├─────────────────────────────────────┤
│  Bottom Navigation (graphite)       │ 80px
└─────────────────────────────────────┘
```

### 8.2 Card Layouts

```
┌─────────────────────────────────────┐
│  Padding: 20-24px                   │
│  ┌───────────────────────────────┐  │
│  │ Header Row                    │  │
│  │ [Icon] [Title]      [Action]  │  │
│  └───────────────────────────────┘  │
│  Gap: 16px                          │
│  ┌───────────────────────────────┐  │
│  │ Primary Content               │  │
│  │ (Balance, main info)          │  │
│  └───────────────────────────────┘  │
│  Gap: 8px                           │
│  ┌───────────────────────────────┐  │
│  │ Secondary Info                │  │
│  └───────────────────────────────┘  │
│  Gap: 20px                          │
│  ┌───────────────────────────────┐  │
│  │ Action Button (full width)    │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
```

---

## 9. Animation Guidelines

### 9.1 Duration Scale

| Token | Duration | Usage |
|-------|----------|-------|
| `instant` | 100ms | Micro-interactions |
| `fast` | 150ms | Button states |
| `normal` | 200ms | Standard transitions |
| `slow` | 300ms | Page transitions |
| `slower` | 400ms | Complex animations |

### 9.2 Easing Curves

| Curve | Usage |
|-------|-------|
| `easeOut` | Elements entering |
| `easeIn` | Elements exiting |
| `easeInOut` | State changes |
| `spring` | Playful interactions |

### 9.3 Principles

1. **Subtlety**: Animations should enhance, not distract
2. **Performance**: Prefer opacity and transform over layout changes
3. **Consistency**: Use the same curves for similar interactions
4. **Purpose**: Every animation should have a clear purpose

---

## 10. Accessibility

### 10.1 Color Contrast

- Text on dark backgrounds: Minimum 4.5:1 ratio
- Large text (18px+): Minimum 3:1 ratio
- Interactive elements: Minimum 3:1 against adjacent colors

### 10.2 Touch Targets

- Minimum touch target: 44x44px
- Preferred touch target: 48x48px
- Spacing between targets: 8px minimum

### 10.3 Text Sizing

- Support dynamic type scaling
- Never use fixed pixel sizes for body text
- Test with 200% text scaling

---

## 11. Do's and Don'ts

### Do's
- Use gold accents sparingly (5% of UI)
- Maintain generous whitespace
- Use semantic colors for status
- Apply consistent border radius within components
- Use the 8pt spacing grid

### Don'ts
- Don't use pure black (#000000) - use obsidian
- Don't use pure white (#FFFFFF) for text - use ivory (textPrimary)
- Don't mix font families within a sentence
- Don't create custom colors outside the system
- Don't use shadows lighter than the specified values

---

## 12. Quick Reference

### Primary Actions
- Background: Gold gradient
- Text: `#0A0A0C` (textInverse)
- Glow: Gold @ 30%

### Cards
- Background: `#1A1A1F` (slate)
- Border: White @ 6%
- Radius: 16px
- Padding: 20px

### Inputs
- Background: `#222228` (elevated)
- Border: White @ 10%
- Focus: Gold 2px
- Radius: 8px

### Typography
- Headlines: Playfair Display
- Body: DM Sans
- Numbers: JetBrains Mono

---

*This design system ensures consistency across all JoonaPay interfaces while maintaining the premium, luxurious brand identity.*
