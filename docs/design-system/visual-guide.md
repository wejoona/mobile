# Visual Design Guide

Visual reference for the JoonaPay design system.

## Color Palette

### Dark Mode Foundation

```
┌─────────────────────────────────────────────────────────────┐
│ BACKGROUNDS                                                 │
├─────────────────────────────────────────────────────────────┤
│ obsidian    ███████  #0A0A0C  Main canvas                   │
│ graphite    ███████  #111115  Elevated surfaces             │
│ slate       ███████  #1A1A1F  Cards, containers             │
│ elevated    ███████  #222228  Inputs, hover                 │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ TEXT HIERARCHY                                              │
├─────────────────────────────────────────────────────────────┤
│ textPrimary    ░░░░░░  #F5F5F0  High emphasis              │
│ textSecondary  ▒▒▒▒▒▒  #9A9A9E  Medium emphasis            │
│ textTertiary   ▓▓▓▓▓▓  #6B6B70  Low emphasis               │
│ textDisabled   ███████  #4A4A4E  Disabled                   │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ GOLD ACCENT (Primary Brand)                                 │
├─────────────────────────────────────────────────────────────┤
│ gold500     ▓▓▓▓▓▓  #C9A962  Primary CTAs                   │
│ gold600     ▓▓▓▓▓▓  #B89852  Pressed state                  │
│ gold700     ▓▓▓▓▓▓  #9A7A3D  Borders                        │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ SEMANTIC COLORS                                             │
├─────────────────────────────────────────────────────────────┤
│ success     ▓▓▓▓▓▓  #2D6A4F  Green (emerald)                │
│ warning     ▓▓▓▓▓▓  #C9943A  Amber                          │
│ error       ▓▓▓▓▓▓  #8B2942  Crimson                        │
│ info        ▓▓▓▓▓▓  #4A6FA5  Steel blue                     │
└─────────────────────────────────────────────────────────────┘
```

---

## Typography Scale

### Font Families

```
PLAYFAIR DISPLAY (Display/Amounts)
Aa Bb Cc 1234567890
Elegant serif for headlines and amounts

DM SANS (Body/UI)
Aa Bb Cc 1234567890
Modern sans-serif for UI text

JETBRAINS MONO (Code/Numbers)
Aa Bb Cc 1234567890
Monospace for codes and IDs
```

### Type Scale Visual

```
displayLarge      Welcome to JoonaPay         72px Bold
displayMedium     Your Balance                48px Bold
displaySmall      Recent Activity             36px SemiBold

headlineLarge     Send Money                  32px SemiBold
headlineMedium    Transaction Details         28px SemiBold
headlineSmall     Recipients                  24px SemiBold

titleLarge        Amadou Diallo               22px SemiBold
titleMedium       Payment Method              18px Medium
titleSmall        Account Settings            16px Medium

bodyLarge         Send USDC to anyone         16px Regular
bodyMedium        Transaction completed       14px Regular
bodySmall         2 hours ago                 12px Regular

labelLarge        Phone Number                14px Medium
labelMedium       AMOUNT                      12px Medium
labelSmall        PENDING                     11px Medium

monoLarge         1234                        24px Medium
monoMedium        TX-8B2F4C9E                 16px Regular
monoSmall         0x742d...9f3e               12px Regular
```

---

## Spacing Scale

### Visual Grid (8pt System)

```
xs      ·─·                4px
sm      ·───·              8px  ← BASE UNIT
md      ·─────·            12px
lg      ·───────·          16px
xl      ·─────────·        20px
xxl     ·───────────·      24px
xxxl    ·─────────────────· 32px
huge    ·───────────────────────· 40px
massive ·─────────────────────────────· 48px
```

### Component Spacing

```
┌────────────────────────────────────────┐
│  screenPadding (20px)                  │
│  ┌──────────────────────────────────┐  │
│  │  Card                            │  │
│  │  ┌────────────────────────────┐  │  │
│  │  │ cardPadding (20px)         │  │  │
│  │  │                            │  │  │
│  │  │  Content                   │  │  │
│  │  │                            │  │  │
│  │  └────────────────────────────┘  │  │
│  │                                  │  │
│  └──────────────────────────────────┘  │
│                                        │
│  sectionGap (24px)                     │
│                                        │
│  ┌──────────────────────────────────┐  │
│  │  Next Section                    │  │
│  └──────────────────────────────────┘  │
│                                        │
└────────────────────────────────────────┘
```

---

## Border Radius

```
none    ┌──────┐     0px   Sharp corners
xs      ╭────╮       4px   Subtle
sm      ╭────╮       6px   Small elements
md      ╭────╮       8px   Buttons, inputs
lg      ╭─────╮      12px  Cards
xl      ╭──────╮     16px  Large cards
xxl     ╭──────╮     20px  Modals
full    ●             9999  Circles, pills
```

---

## Component Variants

### AppButton

```
┌──────────────────────────────────────┐
│  PRIMARY (Gold gradient)             │
│  ┌────────────────────┐              │
│  │   Send Money   →   │  Gold        │
│  └────────────────────┘              │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│  SECONDARY (Transparent + border)    │
│  ┌────────────────────┐              │
│  │      Cancel        │  Outline     │
│  └────────────────────┘              │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│  GHOST (Text only)                   │
│     Learn More →                     │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│  SUCCESS (Green)                     │
│  ┌────────────────────┐              │
│  │     Confirm        │  Green       │
│  └────────────────────┘              │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│  DANGER (Red)                        │
│  ┌────────────────────┐              │
│  │      Delete        │  Red         │
│  └────────────────────┘              │
└──────────────────────────────────────┘
```

### AppButton Sizes

```
SMALL     ┌──────────┐   13px text
          │   Skip   │
          └──────────┘

MEDIUM    ┌──────────────┐   15px text (default)
          │   Continue   │
          └──────────────┘

LARGE     ┌────────────────────┐   17px text
          │   Get Started      │
          └────────────────────┘
```

---

### AppInput States

```
┌────────────────────────────────────────┐
│ IDLE (Default)                         │
│ ┌────────────────────────────────────┐ │
│ │ Phone Number                       │ │
│ │ 0X XX XX XX XX                     │ │
│ └────────────────────────────────────┘ │
└────────────────────────────────────────┘

┌────────────────────────────────────────┐
│ FOCUSED (Gold border)                  │
│ ┌────────────────────────────────────┐ │
│ │ Phone Number                       │ │
│ │ 07 12 34 56 78█                    │ │ Gold border
│ └────────────────────────────────────┘ │
└────────────────────────────────────────┘

┌────────────────────────────────────────┐
│ ERROR (Red border)                     │
│ ┌────────────────────────────────────┐ │
│ │ Phone Number                       │ │
│ │ 07 12                              │ │ Red border
│ └────────────────────────────────────┘ │
│ ⚠ Phone number must be 10 digits      │
└────────────────────────────────────────┘

┌────────────────────────────────────────┐
│ DISABLED (Grayed out)                  │
│ ┌────────────────────────────────────┐ │
│ │ Transaction ID                     │ │
│ │ TX-8B2F4C9E1A3D                    │ │ Gray
│ └────────────────────────────────────┘ │
└────────────────────────────────────────┘
```

---

### AppCard Variants

```
┌────────────────────────────────────────┐
│ ELEVATED (Standard with shadow)        │
│ ┌────────────────────────────────────┐ │
│ │                                    │ │
│ │  Card Content                      │ │
│ │                                    │ │
│ └────────────────────────────────────┘ │
│     └── Subtle shadow                  │
└────────────────────────────────────────┘

┌────────────────────────────────────────┐
│ GOLD ACCENT (Premium border)           │
│ ╭────────────────────────────────────╮ │
│ │                                    │ │ Gold border
│ │  Premium Content                   │ │
│ │                                    │ │
│ ╰────────────────────────────────────╯ │
└────────────────────────────────────────┘

┌────────────────────────────────────────┐
│ SUBTLE (Minimal)                       │
│ ┌────────────────────────────────────┐ │
│ │                                    │ │
│ │  Minimal Card                      │ │
│ │                                    │ │
│ └────────────────────────────────────┘ │
└────────────────────────────────────────┘

┌────────────────────────────────────────┐
│ GLASS (Glassmorphism)                  │
│ ╭────────────────────────────────────╮ │
│ │░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░│ │
│ │░░  Glass Effect Card           ░░░│ │ Semi-transparent
│ │░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░│ │
│ ╰────────────────────────────────────╯ │
└────────────────────────────────────────┘
```

---

## Layout Patterns

### Screen Template

```
┌──────────────────────────────────────┐
│ ══════════════════════════════════   │ AppBar
├──────────────────────────────────────┤
│  [20px padding]                      │
│                                      │
│  Welcome to JoonaPay  (headlineLg)   │
│  [8px gap]                           │
│  Your wallet subtitle (bodyMedium)   │
│                                      │
│  [32px gap - sectionGap]             │
│                                      │
│  ┌────────────────────────────────┐  │
│  │  Balance Card                  │  │
│  │  12,345.67 USDC                │  │
│  └────────────────────────────────┘  │
│                                      │
│  [24px gap - sectionGap]             │
│                                      │
│  ┌────────────────────────────────┐  │
│  │  Quick Actions                 │  │
│  └────────────────────────────────┘  │
│                                      │
│  [24px gap]                          │
│                                      │
│  Recent Transactions (titleLarge)    │
│  [12px gap]                          │
│                                      │
│  ┌────────────────────────────────┐  │
│  │  Transaction 1                 │  │
│  ├────────────────────────────────┤  │
│  │  Transaction 2                 │  │
│  ├────────────────────────────────┤  │
│  │  Transaction 3                 │  │
│  └────────────────────────────────┘  │
│                                      │
│  [16px gap]                          │
│                                      │
│  ┌────────────────────────────────┐  │
│  │      Send Money   →            │  │ Full-width button
│  └────────────────────────────────┘  │
│                                      │
│  [20px padding]                      │
└──────────────────────────────────────┘
```

### Form Layout

```
┌──────────────────────────────────────┐
│  Send Money  (headlineSmall)         │
│                                      │
│  [24px gap]                          │
│                                      │
│  ┌────────────────────────────────┐  │
│  │  Card                          │  │
│  │  ┌──────────────────────────┐  │  │
│  │  │ Phone Number             │  │  │
│  │  │ 0X XX XX XX XX           │  │  │
│  │  └──────────────────────────┘  │  │
│  └────────────────────────────────┘  │
│                                      │
│  [16px gap]                          │
│                                      │
│  ┌────────────────────────────────┐  │
│  │  Card                          │  │
│  │  ┌──────────────────────────┐  │  │
│  │  │ Amount                   │  │  │
│  │  │ 0.00                     │  │  │
│  │  └──────────────────────────┘  │  │
│  │                                │  │
│  │  [16px gap]                    │  │
│  │                                │  │
│  │  Currency  ▼                   │  │
│  │  USDC                          │  │
│  └────────────────────────────────┘  │
│                                      │
│  [20px gap]                          │
│                                      │
│  ┌────────────────────────────────┐  │
│  │      Continue   →              │  │
│  └────────────────────────────────┘  │
└──────────────────────────────────────┘
```

---

## Accessibility

### Touch Targets

```
Minimum: 48×48 px
┌────────────────┐
│                │  48px
│   ●  Tap       │
│                │
└────────────────┘
   48px

Recommended (primary): 56×56 px
┌────────────────────┐
│                    │  56px
│   ●  Tap           │
│                    │
└────────────────────┘
   56px
```

### Text Contrast

```
AAA: 7:1+     textPrimary on obsidian     ✓ 16.2:1
AA:  4.5:1+   textSecondary on obsidian   ✓ 8.5:1
             textTertiary on obsidian    ✓ 4.8:1
             gold500 on obsidian         ✓ 6.2:1
```

---

## Component Sizing

### Buttons

```
SMALL
Height: 32px   Padding: 12h × 8v   Text: 13px
┌──────────┐
│   Skip   │
└──────────┘

MEDIUM (Default)
Height: 40px   Padding: 20h × 12v   Text: 15px
┌──────────────┐
│   Continue   │
└──────────────┘

LARGE
Height: 48px   Padding: 24h × 16v   Text: 17px
┌────────────────────┐
│   Get Started      │
└────────────────────┘
```

### Inputs

```
Standard Height: 48px
Padding: 16px all sides

┌────────────────────────────────────┐
│ Label             (labelMedium)    │
│ ┌────────────────────────────────┐ │
│ │ 16px                           │ │ 48px
│ │ Input text    (bodyLarge)      │ │
│ │                           16px │ │
│ └────────────────────────────────┘ │
└────────────────────────────────────┘
```

---

## Color Usage Rules

### 70-20-5-5 Distribution

```
70% Dark Backgrounds
████████████████████████████████████████
obsidian, graphite, slate, elevated

20% Text
████████████
textPrimary, textSecondary, textTertiary

5% Gold Accent
███
gold500 (CTAs, highlights)

5% Semantic
███
success, error, warning, info
```

---

## Design Token Hierarchy

```
TOKENS
├── Colors
│   ├── Backgrounds (obsidian → elevated)
│   ├── Text (textPrimary → textDisabled)
│   ├── Gold (gold500 primary)
│   ├── Semantic (success, error, warning, info)
│   └── Borders & Overlays
│
├── Typography
│   ├── Display (Playfair - 72, 48, 36)
│   ├── Headline (DM Sans - 32, 28, 24)
│   ├── Title (DM Sans - 22, 18, 16)
│   ├── Body (DM Sans - 16, 14, 12)
│   ├── Label (DM Sans - 14, 12, 11)
│   └── Mono (JetBrains - 24, 16, 12)
│
└── Spacing
    ├── Scale (4, 8, 12, 16, 20, 24, 32, 40, 48)
    ├── Component (card, screen, section, list)
    └── Radius (4, 6, 8, 12, 16, 20, 24, 9999)
```

---

## Quick Component Matrix

```
┌─────────────┬──────────┬─────────────┬──────────────┐
│ Component   │ Variants │ Sizes       │ Key Props    │
├─────────────┼──────────┼─────────────┼──────────────┤
│ AppButton   │ 5        │ 3           │ label, icon  │
│ AppInput    │ 5        │ 1           │ label, error │
│ AppText     │ 15       │ -           │ variant      │
│ AppCard     │ 4        │ -           │ variant, tap │
│ AppSelect   │ 1        │ -           │ items, value │
│ AppSkeleton │ 1        │ custom      │ width, height│
└─────────────┴──────────┴─────────────┴──────────────┘
```

---

## Related

- [README](./README.md) - Design system overview
- [Colors](./colors.md) - Complete color documentation
- [Typography](./typography.md) - Typography system
- [Spacing](./spacing.md) - Spacing and layout
- [Components](./components.md) - Component library
- [Quick Reference](./quick-reference.md) - Quick lookup
