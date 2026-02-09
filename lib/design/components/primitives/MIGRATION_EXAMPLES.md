# AppText Migration Examples

## Before and After Comparison

### Example 1: Error Message

**Before (Hardcoded Color)**
```dart
AppText(
  'Invalid email address',
  variant: AppTextVariant.bodyMedium,
  color: AppColors.errorText, // ❌ Only works in dark theme
)
```

**After (Theme-Aware)**
```dart
AppText(
  'Invalid email address',
  semanticColor: AppTextColor.error, // ✅ Works in both themes
)
```

### Example 2: Page Title

**Before**
```dart
Text(
  'Settings',
  style: AppTypography.headlineLarge, // ❌ Had hardcoded color
)
```

**After**
```dart
AppText(
  'Settings',
  variant: AppTextVariant.headlineLarge, // ✅ Color adapts to theme
)
```

### Example 3: Success Message

**Before**
```dart
Text(
  'Payment sent successfully',
  style: TextStyle(
    fontSize: 14,
    color: Theme.of(context).brightness == Brightness.dark
        ? AppColors.successText
        : AppColorsLight.successText, // ❌ Verbose, repetitive
  ),
)
```

**After**
```dart
AppText(
  'Payment sent successfully',
  semanticColor: AppTextColor.success, // ✅ Clean, semantic
)
```

### Example 4: Label with Secondary Color

**Before**
```dart
AppText(
  'Email Address',
  variant: AppTextVariant.labelMedium,
  color: AppColors.textSecondary, // ❌ Won't work in light theme
)
```

**After (Option 1 - Explicit)**
```dart
AppText(
  'Email Address',
  variant: AppTextVariant.labelMedium,
  semanticColor: AppTextColor.secondary, // ✅ Theme-aware
)
```

**After (Option 2 - Implicit)**
```dart
AppText(
  'Email Address',
  variant: AppTextVariant.labelMedium, // ✅ Uses secondary by default
)
```

### Example 5: Text on Colored Background

**Before**
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: AppColors.goldGradient,
    ),
  ),
  child: AppText(
    'Premium Feature',
    color: AppColors.textInverse, // ❌ Won't adapt
  ),
)
```

**After**
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: context.isDarkMode
          ? AppColors.goldGradient
          : AppColorsLight.goldGradient,
    ),
  ),
  child: AppText(
    'Premium Feature',
    semanticColor: AppTextColor.inverse, // ✅ Adapts to theme
  ),
)
```

### Example 6: Disabled State

**Before**
```dart
AppText(
  'Coming Soon',
  color: AppColors.textDisabled, // ❌ Dark theme only
)
```

**After**
```dart
AppText(
  'Coming Soon',
  semanticColor: AppTextColor.disabled, // ✅ Theme-aware
)
```

### Example 7: Balance Display

**Before**
```dart
Text(
  '\$12,345.67',
  style: AppTypography.balanceDisplay.copyWith(
    color: AppColors.textPrimary, // ❌ Hardcoded
  ),
)
```

**After**
```dart
AppText(
  '\$12,345.67',
  variant: AppTextVariant.balance, // ✅ Auto primary color
)
```

### Example 8: Link Text

**Before**
```dart
GestureDetector(
  onTap: () => _showHelp(),
  child: AppText(
    'Learn more',
    color: AppColors.gold500, // ❌ Same gold in both themes
  ),
)
```

**After**
```dart
GestureDetector(
  onTap: () => _showHelp(),
  child: AppText(
    'Learn more',
    semanticColor: AppTextColor.link, // ✅ Darker gold in light theme
  ),
)
```

### Example 9: Warning Message

**Before**
```dart
Row(
  children: [
    Icon(Icons.warning, color: AppColors.warningBase),
    SizedBox(width: 8),
    AppText(
      'Low balance',
      color: AppColors.warningText, // ❌ Dark theme only
    ),
  ],
)
```

**After**
```dart
Row(
  children: [
    Icon(
      Icons.warning,
      color: context.isDarkMode
          ? AppColors.warningBase
          : AppColorsLight.warningBase,
    ),
    SizedBox(width: 8),
    AppText(
      'Low balance',
      semanticColor: AppTextColor.warning, // ✅ Theme-aware
    ),
  ],
)
```

### Example 10: Info Text

**Before**
```dart
Container(
  padding: EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: AppColors.infoBase.withOpacity(0.1),
    borderRadius: BorderRadius.circular(8),
  ),
  child: AppText(
    'Transactions may take up to 2 minutes',
    color: AppColors.infoText, // ❌ Won't adapt
  ),
)
```

**After**
```dart
Container(
  padding: EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: (context.isDarkMode
            ? AppColors.infoBase
            : AppColorsLight.infoBase)
        .withOpacity(0.1),
    borderRadius: BorderRadius.circular(8),
  ),
  child: AppText(
    'Transactions may take up to 2 minutes',
    semanticColor: AppTextColor.info, // ✅ Theme-aware
  ),
)
```

## Migration Checklist

When updating existing code:

- [ ] Replace `color: AppColors.*` with `semanticColor: AppTextColor.*`
- [ ] Remove `color` parameter if variant default is appropriate
- [ ] Use `inverse` semantic color for text on colored backgrounds
- [ ] Replace plain `Text` widgets with `AppText`
- [ ] Update custom styled text to use semantic colors
- [ ] Test in both light and dark themes
- [ ] Verify contrast ratios meet WCAG AA standards
- [ ] Add semantic labels for amounts and percentages

## Common Mistakes to Avoid

### ❌ DON'T: Mix hardcoded colors with AppText
```dart
AppText(
  'Error',
  color: AppColors.errorText, // Won't work in light theme
)
```

### ✅ DO: Use semantic colors
```dart
AppText(
  'Error',
  semanticColor: AppTextColor.error, // Works in both themes
)
```

### ❌ DON'T: Use context.appColors directly
```dart
AppText(
  'Title',
  color: context.appColors.textPrimary, // Harder to maintain
)
```

### ✅ DO: Use semantic color or let variant decide
```dart
AppText(
  'Title',
  variant: AppTextVariant.titleLarge, // Uses primary by default
)
```

### ❌ DON'T: Manually check theme brightness
```dart
AppText(
  'Text',
  color: Theme.of(context).brightness == Brightness.dark
      ? AppColors.textPrimary
      : AppColorsLight.textPrimary,
)
```

### ✅ DO: Use semantic colors
```dart
AppText(
  'Text',
  semanticColor: AppTextColor.primary,
)
```

### ❌ DON'T: Specify both semanticColor and color unnecessarily
```dart
AppText(
  'Text',
  semanticColor: AppTextColor.primary,
  color: Colors.red, // color wins, semanticColor ignored
)
```

### ✅ DO: Use one or the other
```dart
// Theme-aware
AppText('Text', semanticColor: AppTextColor.primary)

// Custom (when needed)
AppText('Text', color: Colors.red)
```

## Search and Replace Patterns

### Find instances to update:
```regex
AppText\([^)]*color:\s*AppColors\.(textPrimary|textSecondary|textTertiary|errorText|successText|warningText|infoText)
```

### Pattern 1: Text colors
```dart
// Find:
color: AppColors.textPrimary

// Replace:
semanticColor: AppTextColor.primary
```

### Pattern 2: Semantic colors
```dart
// Find:
color: AppColors.errorText

// Replace:
semanticColor: AppTextColor.error
```

### Pattern 3: Success text
```dart
// Find:
color: AppColors.successText

// Replace:
semanticColor: AppTextColor.success
```

## Testing After Migration

```dart
// Create a test widget that shows both themes
class ThemeComparisonTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(
              appBar: AppBar(title: Text('Dark Theme')),
              body: YourWidgetHere(),
            ),
          ),
        ),
        Expanded(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              appBar: AppBar(title: Text('Light Theme')),
              body: YourWidgetHere(),
            ),
          ),
        ),
      ],
    );
  }
}
```

## Automated Migration Script

For large codebases, consider creating a script:

```bash
#!/bin/bash
# migrate_apptext.sh

# Backup files first
git add -A
git commit -m "Before AppText migration"

# Replace common patterns
find lib -name "*.dart" -type f -exec sed -i '' \
  's/color: AppColors\.textPrimary/semanticColor: AppTextColor.primary/g' {} \;

find lib -name "*.dart" -type f -exec sed -i '' \
  's/color: AppColors\.errorText/semanticColor: AppTextColor.error/g' {} \;

find lib -name "*.dart" -type f -exec sed -i '' \
  's/color: AppColors\.successText/semanticColor: AppTextColor.success/g' {} \;

# Format files
flutter format lib

# Run tests
flutter test
```

**Warning:** Always review automated changes manually before committing!
