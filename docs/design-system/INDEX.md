# Design System Documentation Index

Complete documentation for the JoonaPay design system. Start with the README for an overview, or jump to specific topics below.

## Documentation Structure

```
design-system/
├── README.md              ← Start here (overview & quick start)
├── INDEX.md               ← This file (navigation guide)
│
├── Design Tokens
│   ├── colors.md          ← Color palette & usage
│   ├── typography.md      ← Type scale & fonts
│   └── spacing.md         ← Layout & spacing
│
├── Components
│   └── components.md      ← Component library & API reference
│
└── Reference
    ├── quick-reference.md ← Quick lookup & cheat sheet
    └── visual-guide.md    ← Visual reference guide
```

---

## Getting Started

### New to the Design System?

1. **[README.md](./README.md)** - Start here for philosophy, principles, and quick examples
2. **[visual-guide.md](./visual-guide.md)** - Browse visual examples and patterns
3. **[quick-reference.md](./quick-reference.md)** - Keep open for quick lookups

### Looking for Specific Information?

- **Colors?** → [colors.md](./colors.md)
- **Text styles?** → [typography.md](./typography.md)
- **Spacing/layout?** → [spacing.md](./spacing.md)
- **Components?** → [components.md](./components.md)

---

## Documentation by Topic

### Design Tokens

#### [colors.md](./colors.md) (409 lines)
Complete color system documentation.

**Contents:**
- Dark mode foundation colors
- Text hierarchy colors
- Gold accent system
- Semantic colors (success, error, warning, info)
- Borders & overlays
- Light mode palette
- Theme-aware usage
- Accessibility guidelines

**Key Sections:**
- Philosophy (70-20-5-5 rule)
- Backgrounds (obsidian, graphite, slate, elevated)
- Text (textPrimary, textSecondary, textTertiary)
- Gold (gold500 primary CTA color)
- Semantic states
- Best practices

---

#### [typography.md](./typography.md) (535 lines)
Typography system and font usage.

**Contents:**
- Three font families (Playfair Display, DM Sans, JetBrains Mono)
- Type scale (display, headline, title, body, label, mono)
- Special styles (balance, button, card label)
- Customization with copyWith()
- Responsive typography
- Accessibility (font scaling, contrast)

**Key Sections:**
- Display styles (72px, 48px, 36px)
- Headline styles (32px, 28px, 24px)
- Body styles (16px, 14px, 12px)
- Mono styles for numbers/codes
- Usage examples
- Best practices

---

#### [spacing.md](./spacing.md) (490 lines)
Layout, spacing, and sizing system.

**Contents:**
- 8pt grid system
- Spacing scale (xs to massive)
- Component-specific spacing
- Border radius scale
- Elevation scale
- Responsive spacing
- Common patterns

**Key Sections:**
- Core values (4, 8, 12, 16, 20, 24, 32, 40, 48)
- Component spacing (card, screen, section)
- Border radius (md for buttons, lg for cards)
- Usage examples
- Best practices

---

### Components

#### [components.md](./components.md) (1068 lines)
Complete component library with API reference.

**Contents:**
- Primitive components
  - AppButton (5 variants, 3 sizes)
  - AppInput (5 variants, 5 states)
  - AppText (15 typography variants)
  - AppCard (4 variants)
  - AppSelect (dropdown with bottom sheet)
  - AppToggle, AppSkeleton, AppRefreshIndicator
- Composed components
- Usage examples
- API reference
- Best practices

**Key Sections:**
- Component catalog
- Variant documentation
- Complete API reference
- Usage examples with code
- Accessibility features
- Composition patterns

---

### Reference Guides

#### [quick-reference.md](./quick-reference.md) (282 lines)
Quick lookup for common tokens and patterns.

**Contents:**
- Color quick reference
- Typography quick reference
- Spacing quick reference
- Component quick reference
- Common patterns (screen, form, list)
- Import statements
- Cheat sheet table
- Do's and don'ts

**Use for:**
- Fast lookups during development
- Copy-paste code snippets
- Remembering token names
- Quick pattern reference

---

#### [visual-guide.md](./visual-guide.md) (534 lines)
Visual reference with ASCII diagrams.

**Contents:**
- Color palette visualization
- Typography scale visual
- Spacing grid visual
- Border radius examples
- Component variant visuals
- Layout pattern diagrams
- Sizing charts
- Accessibility visuals

**Use for:**
- Understanding visual hierarchy
- Seeing components side-by-side
- Layout planning
- Design reviews

---

## Quick Navigation by Task

### I want to...

**Style text**
1. [typography.md](./typography.md) - Find the right text style
2. [colors.md](./colors.md#text-hierarchy) - Choose text color
3. [components.md#apptext](./components.md#apptext) - Use AppText component

**Choose colors**
1. [colors.md](./colors.md) - Browse color palette
2. [visual-guide.md#color-palette](./visual-guide.md#color-palette) - See colors visually
3. [quick-reference.md#colors](./quick-reference.md#colors) - Quick color lookup

**Add spacing**
1. [spacing.md](./spacing.md) - Learn spacing system
2. [quick-reference.md#spacing](./quick-reference.md#spacing) - Quick spacing lookup
3. [visual-guide.md#spacing-scale](./visual-guide.md#spacing-scale) - See spacing visually

**Use a button**
1. [components.md#appbutton](./components.md#appbutton) - Full button documentation
2. [quick-reference.md#button](./quick-reference.md#button) - Quick button example
3. [visual-guide.md#appbutton](./visual-guide.md#appbutton) - See button variants

**Create a form**
1. [components.md#appinput](./components.md#appinput) - Input documentation
2. [quick-reference.md#form](./quick-reference.md#form) - Form pattern
3. [visual-guide.md#form-layout](./visual-guide.md#form-layout) - See form layout

**Build a screen**
1. [README.md#basic-example](./README.md#basic-example) - Complete example
2. [quick-reference.md#screen-layout](./quick-reference.md#screen-layout) - Screen pattern
3. [visual-guide.md#screen-template](./visual-guide.md#screen-template) - See screen layout

**Check accessibility**
1. [colors.md#accessibility](./colors.md#accessibility) - Color contrast
2. [components.md#accessibility](./components.md#accessibility) - Component accessibility
3. [quick-reference.md#accessibility-checklist](./quick-reference.md#accessibility-checklist) - Checklist

---

## File Sizes & Scope

| File | Lines | Size | Depth | Best For |
|------|-------|------|-------|----------|
| **README.md** | 664 | 16KB | Overview | Starting point, principles, examples |
| **colors.md** | 409 | 9KB | Deep | Color reference, semantic usage |
| **typography.md** | 535 | 10KB | Deep | Text styles, font system |
| **spacing.md** | 490 | 10KB | Deep | Layout, spacing, sizing |
| **components.md** | 1068 | 21KB | Complete | Component API, usage examples |
| **quick-reference.md** | 282 | 6KB | Quick | Fast lookups, cheat sheet |
| **visual-guide.md** | 534 | 26KB | Visual | Visual reference, diagrams |

**Total:** ~3,982 lines, ~98KB of documentation

---

## Reading Paths

### Path 1: Quick Start (10 minutes)
1. README.md (overview)
2. quick-reference.md (common patterns)
3. Start coding with component library

### Path 2: Comprehensive (45 minutes)
1. README.md (philosophy & principles)
2. colors.md (color system)
3. typography.md (text styles)
4. spacing.md (layout system)
5. components.md (component library)

### Path 3: Visual Learner (20 minutes)
1. visual-guide.md (visual reference)
2. README.md (examples)
3. components.md (component examples)

### Path 4: Reference Only
Keep these open while coding:
- quick-reference.md (main reference)
- visual-guide.md (visual patterns)

---

## Print-Friendly Versions

For offline reading or printing:

1. **Executive Summary** - README.md
2. **Complete Reference** - All files in order:
   - README.md
   - colors.md
   - typography.md
   - spacing.md
   - components.md
   - quick-reference.md
   - visual-guide.md

---

## Updates & Maintenance

**Last Updated:** January 2026
**Version:** 1.0
**Maintained by:** JoonaPay Design Team

### Changelog
- 2026-01-30: Initial documentation created
  - Complete design token documentation
  - Full component library reference
  - Visual guides and quick references
  - Accessibility guidelines

---

## Contributing to Docs

When updating the design system, update relevant documentation:

1. **New color?** → Update colors.md and quick-reference.md
2. **New text style?** → Update typography.md and visual-guide.md
3. **New spacing?** → Update spacing.md and quick-reference.md
4. **New component?** → Update components.md (full docs), quick-reference.md (cheat sheet), visual-guide.md (visual)
5. **Breaking change?** → Update README.md and add migration guide

---

## External Resources

- [Source Code](../../lib/design/) - Actual implementation
- [Flutter Docs](https://docs.flutter.dev/)
- [Material Design](https://m3.material.io/)
- [WCAG Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)

---

**Need help?** Check the appropriate documentation file above, or refer to the component source code in `/lib/design/`.
