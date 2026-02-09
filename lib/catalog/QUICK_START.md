# Widget Catalog - Quick Start

## Access the Catalog

### From Code
```dart
// Navigate to catalog
context.push('/catalog');

// Or use named navigation
GoRouter.of(context).push('/catalog');
```

### From Debug Menu
Add a menu item in your app's debug drawer or settings:
```dart
ListTile(
  leading: Icon(Icons.palette),
  title: Text('Widget Catalog'),
  onTap: () => context.push('/catalog'),
)
```

### Direct URL
In debug mode, you can access it directly:
```
/catalog
```

## What's Inside

### Design Tokens
- **Colors** - Full color palette with semantic meanings
- **Typography** - All text styles from display to labels
- **Spacing** - Spacing scale, radius, shadows

### Components
- **AppButton** - All button variants and states
- **AppCard** - Card styles and interactions
- **AppInput** - Input fields with variants
- **AppText** - Typography components
- **AppSelect** - Dropdown/picker components
- **AppToggle** - Switch components
- **AppSkeleton** - Loading placeholders

## Quick Examples

### Copy Button Code
Navigate to "Primitives > AppButton", find the variant you need, and copy:

```dart
AppButton(
  label: 'Send Money',
  onPressed: _handleSend,
  icon: Icons.send,
)
```

### Test Colors
Navigate to "Design Tokens > Colors" to see:
- Gold palette (gold500 is primary)
- Background hierarchy
- Text colors
- Semantic states

### Check Spacing
Navigate to "Design Tokens > Spacing" to find:
- Standard spacing values (xs, sm, md, lg, xl)
- Component padding constants
- Border radius options

## Tips

1. **Browse First** - Explore all sections to see what's available
2. **Test States** - Toggle loading/disabled states to see behavior
3. **Copy Patterns** - Use catalog examples as templates
4. **Check Accessibility** - All components have semantic labels
5. **Verify Theme** - All components support dark theme

## Navigation

- **Sidebar** - Click sections to navigate
- **Sections** - Organized by Design Tokens and Primitives
- **Back** - Use browser back or close button

## For Developers

### Adding Components
See `/lib/catalog/README.md` for full documentation on:
- Creating new catalog sections
- Using helper widgets (CatalogSection, DemoCard)
- Best practices

### File Structure
```
lib/catalog/
├── widget_catalog_view.dart    # Main screen
├── sections/                   # Individual catalogs
└── README.md                   # Full documentation
```

---

**Quick Access:** Add to your home screen or settings for easy access during development.
