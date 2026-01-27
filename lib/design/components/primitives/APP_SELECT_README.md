# AppSelect Component

A luxury-themed dropdown/select component for the USDC Wallet Flutter app that matches the dark theme with gold accents.

## Overview

The `AppSelect` component provides a mobile-optimized dropdown menu with:
- Luxury dark theme styling
- Gold accent highlights
- Bottom sheet dropdown menu (better UX on mobile)
- Support for icons, subtitles, and customization
- Multiple states (idle, focused, error, disabled)
- Full accessibility support

## Features

### Visual States

1. **Default (Idle)**
   - Slate background (`AppColors.elevated`)
   - Subtle border (`AppColors.borderDefault`)
   - Tertiary text color for icons

2. **Focused**
   - Gold border highlight (`AppColors.gold500`)
   - 2px border width
   - Gold icon color
   - Gold label color

3. **Selected**
   - Shows selected value with label
   - Gold checkmark icon (optional)
   - Gold text for selected item in dropdown

4. **Error**
   - Red border (`AppColors.errorBase`)
   - Red error text below field
   - Error icon color

5. **Disabled**
   - Muted background (50% opacity)
   - Disabled text color
   - No interaction

### Dropdown Menu Styling

- Background: `AppColors.slate`
- Selected item: Gold text + checkmark
- Hover/tap: Material InkWell ripple
- Border radius: `AppRadius.xl` (rounded top)
- Bottom sheet modal for mobile UX
- Handle bar indicator at top

## Usage

### Basic Usage

```dart
String? _selectedCountry;

AppSelect<String>(
  label: 'Country',
  value: _selectedCountry,
  hint: 'Select your country',
  items: const [
    AppSelectItem(value: 'us', label: 'United States'),
    AppSelectItem(value: 'ci', label: 'Côte d\'Ivoire'),
    AppSelectItem(value: 'fr', label: 'France'),
  ],
  onChanged: (value) {
    setState(() => _selectedCountry = value);
  },
)
```

### With Icons

```dart
AppSelect<String>(
  label: 'Document Type',
  value: _selectedIdType,
  items: const [
    AppSelectItem(
      value: 'passport',
      label: 'Passport',
      icon: Icons.menu_book,
    ),
    AppSelectItem(
      value: 'national_id',
      label: 'National ID',
      icon: Icons.credit_card,
    ),
  ],
  onChanged: (value) => setState(() => _selectedIdType = value),
)
```

### With Subtitles

```dart
AppSelect<String>(
  label: 'Currency',
  value: _selectedCurrency,
  items: const [
    AppSelectItem(
      value: 'usd',
      label: 'US Dollar (USD)',
      subtitle: 'United States',
      icon: Icons.attach_money,
    ),
    AppSelectItem(
      value: 'xof',
      label: 'West African CFA Franc (XOF)',
      subtitle: 'West African nations',
      icon: Icons.attach_money,
    ),
  ],
  onChanged: (value) => setState(() => _selectedCurrency = value),
)
```

### With Prefix Icon

```dart
AppSelect<String>(
  label: 'Category',
  value: _selectedCategory,
  prefixIcon: Icons.category,
  items: const [
    AppSelectItem(value: 'food', label: 'Food & Drink'),
    AppSelectItem(value: 'transport', label: 'Transport'),
  ],
  onChanged: (value) => setState(() => _selectedCategory = value),
)
```

### With Error State

```dart
AppSelect<String>(
  label: 'Required Field',
  value: _selectedValue,
  error: 'This field is required',
  items: items,
  onChanged: (value) => setState(() => _selectedValue = value),
)
```

### With Helper Text

```dart
AppSelect<String>(
  label: 'Payment Method',
  value: _selectedMethod,
  helper: 'Select how you want to receive payments',
  items: items,
  onChanged: (value) => setState(() => _selectedMethod = value),
)
```

### Disabled State

```dart
AppSelect<String>(
  label: 'Disabled Select',
  value: null,
  enabled: false,
  items: items,
  onChanged: (_) {},
)
```

### Without Checkmarks

```dart
AppSelect<String>(
  label: 'Sort By',
  value: _sortBy,
  showCheckmark: false,
  items: const [
    AppSelectItem(value: 'date', label: 'Date', icon: Icons.calendar_today),
    AppSelectItem(value: 'amount', label: 'Amount', icon: Icons.attach_money),
  ],
  onChanged: (value) => setState(() => _sortBy = value),
)
```

## API Reference

### AppSelect Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `items` | `List<AppSelectItem<T>>` | required | List of selectable items |
| `value` | `T?` | required | Currently selected value |
| `onChanged` | `ValueChanged<T?>` | required | Callback when selection changes |
| `label` | `String?` | null | Label text above the field |
| `hint` | `String?` | null | Placeholder text when nothing selected |
| `error` | `String?` | null | Error message (shows red border) |
| `helper` | `String?` | null | Helper text below field |
| `enabled` | `bool` | true | Whether the select is interactive |
| `prefixIcon` | `IconData?` | null | Icon shown before text (overridden by item icon) |
| `showCheckmark` | `bool` | true | Show checkmark on selected item |

### AppSelectItem Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `value` | `T` | required | The value of this item |
| `label` | `String` | required | Display text |
| `icon` | `IconData?` | null | Optional icon |
| `subtitle` | `String?` | null | Optional subtitle text |
| `enabled` | `bool` | true | Whether item is selectable |

## Design System Integration

### Colors Used

- **Background**: `AppColors.elevated`
- **Border (idle)**: `AppColors.borderDefault`
- **Border (focused)**: `AppColors.gold500`
- **Border (error)**: `AppColors.errorBase`
- **Text**: `AppColors.textPrimary`
- **Hint text**: `AppColors.textTertiary`
- **Selected item**: `AppColors.gold500`
- **Checkmark**: `AppColors.gold500`
- **Dropdown background**: `AppColors.slate`

### Spacing

- Padding: `AppSpacing.lg` (16px)
- Label margin: `AppSpacing.sm` (8px)
- Icon gap: `AppSpacing.md` (12px)
- Border radius: `AppRadius.md` (8px)
- Dropdown radius: `AppRadius.xl` (16px)

### Typography

- Label: `AppTextVariant.labelMedium`
- Value: `AppTextVariant.bodyLarge`
- Subtitle: `AppTextVariant.bodySmall`
- Error: `AppTextVariant.bodySmall`

## Accessibility

- Full keyboard navigation support
- Proper semantic labels
- Screen reader compatible
- Touch target size: 48px minimum height
- Clear focus indicators
- Error states announced

## Examples

See `app_select_example.dart` for comprehensive usage examples including:
- Basic select with icons
- Select with prefix icon
- Select with subtitles
- Select without checkmarks
- Disabled state
- Error state
- Helper text

## Migration from DropdownButton

### Before (Standard Flutter Dropdown)

```dart
DropdownButton<String>(
  value: _selectedValue,
  items: const [
    DropdownMenuItem(value: 'option1', child: Text('Option 1')),
    DropdownMenuItem(value: 'option2', child: Text('Option 2')),
  ],
  onChanged: (value) => setState(() => _selectedValue = value),
)
```

### After (AppSelect)

```dart
AppSelect<String>(
  value: _selectedValue,
  items: const [
    AppSelectItem(value: 'option1', label: 'Option 1'),
    AppSelectItem(value: 'option2', label: 'Option 2'),
  ],
  onChanged: (value) => setState(() => _selectedValue = value),
)
```

## Benefits Over Standard DropdownButton

1. **Better Mobile UX**: Bottom sheet modal instead of native dropdown
2. **Consistent Styling**: Matches luxury dark theme automatically
3. **More Features**: Icons, subtitles, helper text, error states
4. **Gold Accents**: Automatic gold highlighting for selected items
5. **State Management**: Built-in focus and error state handling
6. **Accessibility**: Better keyboard and screen reader support

## Performance Considerations

- Uses `StatefulWidget` for internal state management
- Bottom sheet is lazily rendered only when opened
- List items use `ListView.builder` for efficient rendering
- Material `InkWell` for performant touch feedback

## Testing

```dart
testWidgets('AppSelect shows selected value', (tester) async {
  String? selectedValue;

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: AppSelect<String>(
          value: 'option1',
          items: const [
            AppSelectItem(value: 'option1', label: 'Option 1'),
            AppSelectItem(value: 'option2', label: 'Option 2'),
          ],
          onChanged: (value) => selectedValue = value,
        ),
      ),
    ),
  );

  expect(find.text('Option 1'), findsOneWidget);
});
```
