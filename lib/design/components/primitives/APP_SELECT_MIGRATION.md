# AppSelect Migration Guide

Quick reference for migrating from `DropdownButton` to `AppSelect`.

## Quick Migration Steps

### Step 1: Add Import
```dart
// Add to top of file
import 'package:app/design/components/primitives/index.dart';
```

### Step 2: Replace DropdownButton
```dart
// Before
DropdownButton<String>(
  value: _selectedValue,
  items: items,
  onChanged: (value) => setState(() => _selectedValue = value),
)

// After
AppSelect<String>(
  value: _selectedValue,
  items: items,
  onChanged: (value) => setState(() => _selectedValue = value),
)
```

### Step 3: Convert Items
```dart
// Before
DropdownMenuItem<String>(
  value: 'option1',
  child: Text('Option 1'),
)

// After
AppSelectItem<String>(
  value: 'option1',
  label: 'Option 1',
)
```

## Common Patterns

### Pattern 1: Basic Dropdown

**Before:**
```dart
DropdownButton<String>(
  value: _selectedCountry,
  items: const [
    DropdownMenuItem(value: 'us', child: Text('United States')),
    DropdownMenuItem(value: 'fr', child: Text('France')),
  ],
  onChanged: (value) {
    setState(() => _selectedCountry = value);
  },
)
```

**After:**
```dart
AppSelect<String>(
  label: 'Country',
  value: _selectedCountry,
  hint: 'Select country',
  items: const [
    AppSelectItem(value: 'us', label: 'United States'),
    AppSelectItem(value: 'fr', label: 'France'),
  ],
  onChanged: (value) {
    setState(() => _selectedCountry = value);
  },
)
```

**Changes:**
- ✅ Added `label` parameter
- ✅ Added `hint` parameter
- ✅ Changed `DropdownMenuItem` → `AppSelectItem`
- ✅ Changed `child: Text()` → `label: String`

---

### Pattern 2: Dropdown with Custom Styling

**Before:**
```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 16),
  decoration: BoxDecoration(
    color: AppColors.slate,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: AppColors.borderSubtle),
  ),
  child: DropdownButton<String>(
    value: _selectedValue,
    isExpanded: true,
    underline: const SizedBox(),
    dropdownColor: AppColors.slate,
    style: TextStyle(color: AppColors.textPrimary),
    items: items,
    onChanged: (value) => setState(() => _selectedValue = value),
  ),
)
```

**After:**
```dart
AppSelect<String>(
  value: _selectedValue,
  items: items,
  onChanged: (value) => setState(() => _selectedValue = value),
)
```

**Changes:**
- ❌ Removed `Container` wrapper
- ❌ Removed custom padding
- ❌ Removed custom decoration
- ❌ Removed `underline` workaround
- ❌ Removed `dropdownColor` manual setting
- ❌ Removed `style` manual setting
- ✅ All styling handled automatically

**Lines of code:** 16 → 5 (69% reduction)

---

### Pattern 3: Dropdown with Label Above

**Before:**
```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      'ID Type',
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
      ),
    ),
    const SizedBox(height: 8),
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.slate,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: DropdownButton<String>(
        value: _selectedIdType,
        isExpanded: true,
        underline: const SizedBox(),
        items: items,
        onChanged: (value) => setState(() => _selectedIdType = value),
      ),
    ),
  ],
)
```

**After:**
```dart
AppSelect<String>(
  label: 'ID Type',
  value: _selectedIdType,
  items: items,
  onChanged: (value) => setState(() => _selectedIdType = value),
)
```

**Changes:**
- ❌ Removed `Column` wrapper
- ❌ Removed manual label `Text` widget
- ❌ Removed `SizedBox` spacing
- ❌ Removed `Container` styling wrapper
- ✅ Built-in `label` parameter handles everything

**Lines of code:** 24 → 5 (79% reduction)

---

### Pattern 4: Adding Icons

**Before:**
```dart
DropdownMenuItem<String>(
  value: 'option1',
  child: Row(
    children: [
      Icon(Icons.icon_name, size: 20),
      const SizedBox(width: 8),
      Text('Option 1'),
    ],
  ),
)
```

**After:**
```dart
AppSelectItem<String>(
  value: 'option1',
  label: 'Option 1',
  icon: Icons.icon_name,
)
```

**Changes:**
- ❌ Removed manual `Row` layout
- ❌ Removed manual `Icon` widget
- ❌ Removed `SizedBox` spacing
- ✅ Built-in `icon` parameter

---

### Pattern 5: Error State

**Before:**
```dart
Column(
  children: [
    Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: hasError ? Colors.red : AppColors.borderDefault,
        ),
      ),
      child: DropdownButton<String>(
        value: _selectedValue,
        items: items,
        onChanged: (value) => setState(() => _selectedValue = value),
      ),
    ),
    if (hasError)
      Text(
        'This field is required',
        style: TextStyle(color: Colors.red, fontSize: 12),
      ),
  ],
)
```

**After:**
```dart
AppSelect<String>(
  value: _selectedValue,
  error: hasError ? 'This field is required' : null,
  items: items,
  onChanged: (value) => setState(() => _selectedValue = value),
)
```

**Changes:**
- ❌ Removed `Column` wrapper
- ❌ Removed conditional border styling
- ❌ Removed conditional error text widget
- ✅ Built-in `error` parameter handles everything

---

### Pattern 6: Disabled State

**Before:**
```dart
DropdownButton<String>(
  value: _selectedValue,
  items: items,
  onChanged: isEnabled ? (value) => setState(() => _selectedValue = value) : null,
)
```

**After:**
```dart
AppSelect<String>(
  value: _selectedValue,
  enabled: isEnabled,
  items: items,
  onChanged: (value) => setState(() => _selectedValue = value),
)
```

**Changes:**
- ✅ Added `enabled` parameter
- ✅ Simplified `onChanged` (no conditional)
- ✅ Automatic visual disabled state

---

## Migration Checklist

Use this checklist when migrating a dropdown:

### Phase 1: Preparation
- [ ] Locate all `DropdownButton` instances in file
- [ ] Import design primitives: `import 'package:app/design/components/primitives/index.dart';`
- [ ] Note any custom styling or wrappers

### Phase 2: Basic Migration
- [ ] Replace `DropdownButton` → `AppSelect`
- [ ] Replace `DropdownMenuItem` → `AppSelectItem`
- [ ] Change `child: Text()` → `label: String`
- [ ] Add `hint` parameter if needed
- [ ] Test basic functionality

### Phase 3: Enhancement
- [ ] Remove styling wrappers (Container, padding, decoration)
- [ ] Convert manual label to `label` parameter
- [ ] Add `icon` to items if relevant
- [ ] Add `error` handling if needed
- [ ] Add `helper` text if needed
- [ ] Use `enabled` instead of conditional onChanged
- [ ] Remove manual focus/error styling

### Phase 4: Testing
- [ ] Test selection works correctly
- [ ] Test error state displays properly
- [ ] Test disabled state (if applicable)
- [ ] Test focus state (gold border)
- [ ] Test on mobile device (bottom sheet)
- [ ] Test accessibility (screen reader)

### Phase 5: Cleanup
- [ ] Remove unused imports (if any)
- [ ] Remove unused variables (styling-related)
- [ ] Format code (`flutter format`)
- [ ] Run analysis (`flutter analyze`)
- [ ] Commit changes

## Common Issues & Solutions

### Issue 1: Type Mismatch

**Error:**
```
The element type 'AppSelectItem<dynamic>' can't be assigned to the list type 'AppSelectItem<String>'.
```

**Solution:**
```dart
// Add explicit type to items list
items: const <AppSelectItem<String>>[
  AppSelectItem(value: 'option1', label: 'Option 1'),
]

// OR specify type on AppSelect
AppSelect<String>(...)
```

---

### Issue 2: OnChanged Not Called

**Error:** Selection not updating state

**Solution:**
```dart
// Make sure to call setState
onChanged: (value) {
  setState(() => _selectedValue = value);  // Don't forget setState!
}
```

---

### Issue 3: Items Not Showing Icons

**Problem:** Icons not visible in dropdown

**Solution:**
```dart
// Make sure to add icon to each item
AppSelectItem(
  value: 'option1',
  label: 'Option 1',
  icon: Icons.icon_name,  // Add this
)
```

---

### Issue 4: Custom Styling Not Applying

**Problem:** Trying to apply custom colors

**Solution:**
```dart
// Don't wrap in Container with custom styling
// AppSelect handles styling automatically
// If you need different colors, modify design tokens instead
```

---

## Benefits Summary

### Code Reduction
- **Average reduction:** 60-80% fewer lines
- **Container wrappers:** Eliminated
- **Manual styling:** Eliminated
- **Label management:** Built-in

### Improved UX
- **Mobile-optimized:** Bottom sheet instead of native dropdown
- **Consistent styling:** Automatic luxury theme
- **Better states:** Built-in error, disabled, focus states
- **Gold accents:** Automatic selection highlighting

### Developer Experience
- **Simpler API:** Less boilerplate
- **Type safe:** Generic type support
- **Declarative:** Clear, readable code
- **Maintainable:** Centralized styling

## Examples by File

### KYC View
**Location:** `lib/features/settings/views/kyc_view.dart`

**Changes:**
- ID Type dropdown → AppSelect with icons
- Reduced from ~30 lines → 12 lines
- Added icons for document types
- Automatic gold accent styling

### Filter Bottom Sheet
**Location:** `lib/features/transactions/widgets/filter_bottom_sheet.dart`

**Changes:**
- Sort dropdown → AppSelect with icons
- Removed container wrapper
- Added meaningful icons (calendar, money)
- Set `showCheckmark: false` for cleaner look

### Merchant Dashboard
**Location:** `lib/features/merchant_pay/views/merchant_dashboard_view.dart`

**Changes:**
- Period dropdown → AppSelect with icons
- Added period-specific icons
- Better visual hierarchy
- Consistent with app theme

## Next Steps

After migration:
1. Test thoroughly on device
2. Verify accessibility
3. Check different screen sizes
4. Review with team
5. Consider migrating remaining dropdowns

## Support

For questions or issues:
- See examples: `app_select_example.dart`
- Read docs: `APP_SELECT_README.md`
- Visual reference: `APP_SELECT_VISUAL_GUIDE.md`
- Component: `app_select.dart`
