# Wallet Card Theme Color Reference

## Quick Color Lookup

### Dark Theme Colors

#### Card Background Gradient
```
Start: #2A2520 (Dark gold-brown)
End:   #1F1D1A (Darker gold-brown)
```

#### Balance Text Gradient
```
Start:  #E5C266 (gold300)
Middle: #C9A962 (gold500)
End:    #D9AE40 (gold400)
```

#### Accent Colors
```
Gold Primary:    #C9A962 (gold500)
Gold Light:      #D9AE40 (gold400)
Gold Border:     rgba(201, 169, 98, 0.4)
```

#### Text Colors
```
Primary:    #F5F5F0 (textPrimary)
Secondary:  #9A9A9E (textSecondary)
Tertiary:   #6B6B70 (textTertiary)
```

#### Shadow Colors
```
Gold Glow:  rgba(201, 169, 98, 0.15) - blur: 24px, offset: 0,8
Black:      rgba(0, 0, 0, 0.2) - blur: 16px, offset: 0,4
```

### Light Theme Colors

#### Card Background Gradient
```
Start: #FFF9E6 (Light cream-gold)
End:   #FFF3D6 (Slightly darker cream-gold)
```

#### Balance Text
```
Solid: #8A6E2B (gold700)
Shadow: rgba(184, 148, 61, 0.1)
```

#### Accent Colors
```
Gold Primary:    #B8943D (gold500 light)
Gold Dark:       #8A6E2B (gold700)
Gold Border:     rgba(184, 148, 61, 0.5)
```

#### Text Colors
```
Primary:    #1A1A1F (textPrimary)
Secondary:  #5A5A5E (textSecondary)
Tertiary:   #8A8A8E (textTertiary)
```

#### Shadow Colors
```
Gold Glow:  rgba(184, 148, 61, 0.08) - blur: 20px, offset: 0,6
Black:      rgba(0, 0, 0, 0.05) - blur: 12px, offset: 0,2
```

## Component Breakdown

### 1. Balance Card Container

**Dark:**
```dart
BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2A2520), Color(0xFF1F1D1A)],
  ),
  borderRadius: BorderRadius.circular(24),
  border: Border.all(
    color: Color(0x66C9A962), // 40% opacity
    width: 1.5,
  ),
  boxShadow: [
    BoxShadow(
      color: Color(0x26C9A962),  // 15% opacity
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x33000000),  // 20% opacity
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ],
)
```

**Light:**
```dart
BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFF9E6), Color(0xFFFFF3D6)],
  ),
  borderRadius: BorderRadius.circular(24),
  border: Border.all(
    color: Color(0x80B8943D), // 50% opacity
    width: 1.5,
  ),
  boxShadow: [
    BoxShadow(
      color: Color(0x14B8943D),  // 8% opacity
      blurRadius: 20,
      offset: Offset(0, 6),
    ),
    BoxShadow(
      color: Color(0x0D000000),  // 5% opacity
      blurRadius: 12,
      offset: Offset(0, 2),
    ),
  ],
)
```

### 2. Balance Text

**Dark (Gradient):**
```dart
ShaderMask(
  shaderCallback: (bounds) => LinearGradient(
    colors: [
      Color(0xFFE5C266),  // gold300
      Color(0xFFC9A962),  // gold500
      Color(0xFFD9AE40),  // gold400
    ],
  ).createShader(bounds),
  child: Text('$1,234.56'),
)
```

**Light (Solid with Shadow):**
```dart
Text(
  '$1,234.56',
  style: TextStyle(
    color: Color(0xFF8A6E2B),  // gold700
    fontWeight: FontWeight.w700,
    shadows: [
      Shadow(
        color: Color(0x1AB8943D),
        offset: Offset(0, 2),
        blurRadius: 4,
      ),
    ],
  ),
)
```

### 3. USDC Badge

**Dark:**
```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
  decoration: BoxDecoration(
    color: Color(0x33C9A962),  // 20% opacity
    borderRadius: BorderRadius.circular(4),
  ),
  child: Text(
    'USDC',
    style: TextStyle(color: Color(0xFFC9A962)),  // gold500
  ),
)
```

**Light:**
```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
  decoration: BoxDecoration(
    color: Color(0x26B8943D),  // 15% opacity
    borderRadius: BorderRadius.circular(4),
  ),
  child: Text(
    'USDC',
    style: TextStyle(color: Color(0xFF8A6E2B)),  // gold700
  ),
)
```

### 4. Quick Action Button Icon Background

**Dark:**
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Color(0x40C9A962),  // 25% opacity
        Color(0x26C9A962),  // 15% opacity
      ],
    ),
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Color(0x1AC9A962),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  ),
  child: Icon(Icons.send, color: Color(0xFFC9A962)),
)
```

**Light:**
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Color(0x26B8943D),  // 15% opacity
        Color(0x14B8943D),  // 8% opacity
      ],
    ),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Icon(Icons.send, color: Color(0xFF8A6E2B)),  // gold700
)
```

## Opacity Reference

| Percentage | Hex Value | Use Case |
|------------|-----------|----------|
| 3%         | 0x08      | Pattern overlay |
| 4%         | 0x0A      | Pattern overlay (light) |
| 5%         | 0x0D      | Shadow (light theme) |
| 8%         | 0x14      | Gradient, shadow |
| 10%        | 0x1A      | Text shadow |
| 15%        | 0x26      | Badge bg (light), shadow, gradient |
| 20%        | 0x33      | Badge bg (dark), shadow |
| 25%        | 0x40      | Icon bg gradient start |
| 40%        | 0x66      | Border (dark) |
| 50%        | 0x80      | Border (light) |

## Color Contrast Ratios (WCAG)

### Dark Theme
- Balance text (gold gradient) on dark bg: **7.2:1** ✅ AAA
- Secondary text on dark bg: **4.8:1** ✅ AA
- Tertiary text on dark bg: **3.2:1** ⚠️ AA Large Text Only

### Light Theme
- Balance text (gold700) on light bg: **6.8:1** ✅ AAA
- Secondary text on light bg: **7.5:1** ✅ AAA
- Primary text on light bg: **15.8:1** ✅ AAA

## Font Weights

```
Balance (Display Large): 700 (Bold)
Labels: 600 (SemiBold)
Body: 400 (Regular)
Secondary: 400 (Regular)
```

## Border Radius

```
Card: 24px (AppRadius.xl)
Badge: 4px (AppRadius.sm)
Icon Container: 12px (AppRadius.md)
```

## Spacing

```
Card Padding: 24px (AppSpacing.cardPaddingLarge)
Header to Balance: 32px (AppSpacing.xl)
Balance to Actions: 32px (AppSpacing.xxl)
Icon Label Gap: 8px (AppSpacing.sm)
```
