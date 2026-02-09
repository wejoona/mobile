# Widget Catalog

A comprehensive design system showcase and component library for the JoonaPay mobile app.

## Overview

The Widget Catalog is a visual testing and documentation tool that displays all design system components with their variants, states, and usage examples. It serves as both a development reference and a quality assurance tool.

## Features

- **Complete Component Library**: All primitives (buttons, inputs, cards, etc.) with variants
- **Design Tokens**: Colors, typography, spacing, and shadows
- **Interactive Examples**: Live components with state management
- **Visual Testing**: Side-by-side comparison of component variants
- **Navigation**: Sidebar navigation for easy browsing

## Accessing the Catalog

### Via Navigation

```dart
context.push('/catalog');
```

### Direct URL

In development mode, navigate to the catalog directly:
```
/catalog
```

## Structure

```
lib/catalog/
├── widget_catalog_view.dart       # Main catalog screen with sidebar
├── index.dart                      # Barrel export file
└── sections/
    ├── button_catalog.dart         # AppButton variants
    ├── card_catalog.dart           # AppCard variants
    ├── input_catalog.dart          # AppInput variants
    ├── text_catalog.dart           # AppText variants
    ├── select_catalog.dart         # AppSelect variants
    ├── toggle_catalog.dart         # AppToggle variants
    ├── skeleton_catalog.dart       # AppSkeleton variants
    ├── color_catalog.dart          # Color palette
    ├── typography_catalog.dart     # Typography scale
    └── spacing_catalog.dart        # Spacing system
```

## Sections

### Design Tokens

#### Colors
- Gold palette (50-900)
- Background colors (obsidian, graphite, slate, elevated)
- Text hierarchy (primary, secondary, tertiary, disabled)
- Semantic colors (success, warning, error, info)
- Border and overlay colors

#### Typography
- Display styles (large, medium, small)
- Headline styles (large, medium, small)
- Title styles (large, medium, small)
- Body styles (large, medium, small)
- Label styles (large, medium, small)
- Special variants (balance, percentage, mono)

#### Spacing
- Spacing scale (xxs to xxl)
- Border radius (sm to full)
- Component spacing (screen, card, section)
- Shadows and elevation

### Primitives

#### AppButton
- **Variants**: Primary, Secondary, Ghost, Success, Danger
- **Sizes**: Small, Medium, Large
- **States**: Default, Loading, Disabled
- **With Icons**: Leading and trailing icons
- **Full Width**: Expandable buttons

#### AppCard
- **Variants**: Elevated, Gold Accent, Subtle, Glass
- **Interactive**: Tappable cards
- **Custom Spacing**: Padding and margin
- **Border Radius**: Small to extra large

#### AppInput
- **Variants**: Standard, Phone, PIN, Amount, Search
- **States**: Default, Error, Disabled, Read-only
- **Icons**: Prefix and suffix icons
- **Special Cases**: Password, multiline, phone with country code

#### AppText
- **Typography Variants**: All text styles
- **Colors**: Semantic color variants
- **Alignment**: Left, center, right
- **Overflow**: Ellipsis, multiline
- **Font Weight**: Light to bold

#### AppSelect
- **Basic**: Dropdown with label and hint
- **With Icons**: Items with icons and subtitles
- **States**: Default, Error, Disabled
- **Customization**: Prefix icon, checkmark toggle

#### AppToggle
- **Basic**: Simple on/off switch
- **Settings**: Toggle tiles with icon, title, subtitle
- **States**: On, Off, Disabled

#### AppSkeleton
- **Basic Shapes**: Rectangle, circle, text
- **Patterns**: List items, cards, transactions
- **Custom Layouts**: Compose complex skeletons
- **Animation**: Shimmer effect

## Usage Examples

### Viewing Button Variants

Navigate to "Primitives > AppButton" to see:
- All 5 button variants side-by-side
- 3 size options
- Loading and disabled states
- Buttons with icons
- Full-width buttons
- Haptic feedback examples

### Testing Colors

Navigate to "Design Tokens > Colors" to:
- Browse the complete gold palette
- View background color hierarchy
- See text color hierarchy
- Explore semantic colors
- Test border and overlay colors

### Checking Spacing

Navigate to "Design Tokens > Spacing" to:
- View the spacing scale with visual indicators
- See border radius options
- Test component spacing in real layouts
- Compare shadow and elevation levels

## Adding New Components

To add a new component to the catalog:

1. **Create Section File**
   ```dart
   // lib/catalog/sections/my_component_catalog.dart
   import 'package:flutter/material.dart';
   import '../../design/tokens/index.dart';
   import '../../design/components/primitives/index.dart';
   import '../widget_catalog_view.dart';

   class MyComponentCatalog extends StatelessWidget {
     const MyComponentCatalog({super.key});

     @override
     Widget build(BuildContext context) {
       return Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           CatalogSection(
             title: 'Variants',
             description: 'Different component styles',
             children: [
               DemoCard(
                 label: 'Default',
                 child: MyComponent(),
               ),
             ],
           ),
         ],
       );
     }
   }
   ```

2. **Export from index.dart**
   ```dart
   export 'sections/my_component_catalog.dart';
   ```

3. **Add to Catalog Navigation**
   Update `widget_catalog_view.dart`:
   ```dart
   _CatalogSection(
     title: 'Primitives',
     icon: Icons.widgets,
     subsections: [
       // ... existing subsections
       _CatalogSubsection(
         title: 'MyComponent',
         builder: (context) => const MyComponentCatalog(),
       ),
     ],
   ),
   ```

## Helper Widgets

### CatalogSection
Wraps a group of related demos with a title and description.

```dart
CatalogSection(
  title: 'Section Title',
  description: 'Optional description',
  children: [
    // Demo widgets
  ],
)
```

### DemoCard
Displays a single component demo with optional label.

```dart
DemoCard(
  label: 'Demo Label',
  child: YourComponent(),
  padding: EdgeInsets.all(AppSpacing.lg), // Optional
)
```

## Best Practices

1. **Comprehensive Coverage**: Show all variants, states, and edge cases
2. **Interactive Examples**: Include stateful examples where relevant
3. **Clear Labels**: Use descriptive labels for each demo
4. **Organized Groups**: Group related demos with CatalogSection
5. **Real-world Context**: Show components in realistic layouts
6. **Accessibility**: Test semantic labels and screen reader support

## Development Workflow

### Visual Regression Testing
Use the catalog to verify:
- Component appearance across variants
- State transitions (hover, focus, disabled)
- Responsive behavior
- Dark theme compatibility
- Accessibility features

### Design Review
Share the catalog with designers to:
- Verify implementation matches designs
- Test edge cases and states
- Validate spacing and typography
- Review color usage
- Ensure consistency

### Documentation
The catalog serves as living documentation:
- Always up-to-date with latest components
- Shows actual implementation (not screenshots)
- Demonstrates proper usage patterns
- Provides copy-paste examples

## Notes

- The catalog is available in all build modes (debug, profile, release)
- Components use actual design tokens and theme colors
- Interactive elements work as they would in the app
- Catalog does not require authentication to access
- Performance: Catalog uses lazy loading for sections

## Future Enhancements

Potential improvements:
- [ ] Component code view (show source code)
- [ ] Copy code button for examples
- [ ] Theme switcher (light/dark toggle)
- [ ] Search functionality
- [ ] Favorites/bookmarks
- [ ] Export as PDF or image
- [ ] Playground mode (edit props live)
- [ ] Accessibility audit panel
- [ ] Performance metrics

## Related Files

- `/lib/design/tokens/` - Design tokens (colors, typography, spacing)
- `/lib/design/components/primitives/` - Primitive components
- `/lib/router/app_router.dart` - Routing configuration
- `CUSTOM_COMPONENTS.md` - Component documentation

---

**Maintained by:** Design System Team
**Last Updated:** 2026-01-30
