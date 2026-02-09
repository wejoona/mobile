# Orientation Helper

Utilities for building layouts that adapt to device orientation (portrait/landscape).

## Features

- Detect portrait/landscape orientation
- Get orientation-specific values (padding, spacing, columns, etc.)
- Automatic grid column calculations
- Constrained content width in landscape
- Pre-built widgets for common patterns

## Usage

### Basic Orientation Detection

```dart
import 'package:usdc_wallet/core/orientation/orientation_helper.dart';

// Check orientation
if (OrientationHelper.isLandscape(context)) {
  // Build landscape layout
}

// Get orientation-specific value
final spacing = OrientationHelper.value(
  context,
  portrait: 16.0,
  landscape: 12.0,
);
```

### Orientation-Aware Layouts

```dart
// Use OrientationLayoutBuilder for different layouts
OrientationLayoutBuilder(
  portrait: _buildPortraitLayout(),
  landscape: _buildLandscapeLayout(),
)

// Or use isLandscape check with existing responsive utilities
final isLandscape = OrientationHelper.isLandscape(context);

return isLandscape
    ? _buildLandscapeLayout()
    : ResponsiveBuilder(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
      );
```

### Adaptive Padding

```dart
// Get orientation-aware padding
Padding(
  padding: OrientationHelper.padding(
    context,
    portrait: const EdgeInsets.all(16.0),
    landscape: const EdgeInsets.symmetric(
      horizontal: 32.0,
      vertical: 12.0,
    ),
  ),
  child: content,
)

// Or use OrientationSafePadding widget
OrientationSafePadding(
  portraitPadding: EdgeInsets.all(16.0),
  landscapePadding: EdgeInsets.symmetric(
    horizontal: 32.0,
    vertical: 12.0,
  ),
  child: content,
)
```

### Grid Columns

```dart
// Get optimal column count based on orientation and device type
final columns = OrientationHelper.columns(
  context,
  portraitMobile: 1,
  landscapeMobile: 2,
  portraitTablet: 2,
  landscapeTablet: 3,
);

// Or use gridCrossAxisCount for GridView
GridView.count(
  crossAxisCount: OrientationHelper.gridCrossAxisCount(
    context,
    portraitMobile: 2,
    landscapeMobile: 3,
    portraitTablet: 3,
    landscapeTablet: 4,
  ),
  children: items,
)
```

### Switch Layout Direction

```dart
// Automatically switch between Column (portrait) and Row (landscape)
OrientationSwitchLayout(
  spacing: 16.0,
  children: [
    Widget1(),
    Widget2(),
    Widget3(),
  ],
)
```

### Constrained Content Width

```dart
// Prevent content from stretching too wide in landscape
OrientationScrollView(
  padding: EdgeInsets.all(16.0),
  child: Column(
    children: [
      // Content automatically constrained in landscape
    ],
  ),
)

// Or get max width directly
final maxWidth = OrientationHelper.maxContentWidth(context);
```

### Adaptive Grid

```dart
// Grid that adapts columns based on orientation
OrientationAdaptiveGrid(
  portraitColumns: 2,
  landscapeColumns: 3,
  spacing: 16.0,
  runSpacing: 16.0,
  children: [
    Item1(),
    Item2(),
    Item3(),
  ],
)
```

## Best Practices

### 1. Combine with Responsive Layout

Use both responsive (screen size) and orientation helpers together:

```dart
Widget build(BuildContext context) {
  final isLandscape = OrientationHelper.isLandscape(context);
  final isTablet = ResponsiveLayout.isTabletOrLarger(context);

  if (isLandscape && isTablet) {
    return _buildTabletLandscapeLayout(); // 3-column
  } else if (isLandscape) {
    return _buildMobileLandscapeLayout(); // 2-column
  } else if (isTablet) {
    return _buildTabletPortraitLayout(); // 2-column
  } else {
    return _buildMobilePortraitLayout(); // 1-column
  }
}
```

### 2. Reduce Spacing in Landscape

Landscape has less vertical space, so use more compact spacing:

```dart
padding: OrientationHelper.padding(
  context,
  portrait: EdgeInsets.all(24.0),
  landscape: EdgeInsets.symmetric(
    horizontal: 32.0,  // More horizontal space
    vertical: 12.0,    // Less vertical space
  ),
)
```

### 3. Use Horizontal Layouts in Landscape

Take advantage of horizontal space:

```dart
OrientationLayoutBuilder(
  portrait: Column(children: items),
  landscape: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: items.map((item) => Expanded(child: item)).toList(),
  ),
)
```

### 4. Grid vs List Based on Orientation

```dart
final shouldUseGrid = OrientationHelper.shouldUseTwoColumns(context);

if (shouldUseGrid) {
  return GridView.count(
    crossAxisCount: OrientationHelper.gridCrossAxisCount(context),
    children: items,
  );
} else {
  return ListView(children: items);
}
```

## Real-World Examples

### Wallet Home Screen

```dart
// Landscape: Balance & actions on left, transactions on right
Widget _buildLandscapeLayout() {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        flex: 2,
        child: Column(
          children: [
            _buildBalanceCard(),
            _buildQuickActions(),
          ],
        ),
      ),
      const SizedBox(width: 24),
      Expanded(
        flex: 3,
        child: _buildTransactionList(),
      ),
    ],
  );
}
```

### Settings Screen

```dart
// Landscape: Three-column grid layout
Widget _buildLandscapeLayout() {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(child: _buildSecuritySettings()),
      SizedBox(width: 16),
      Expanded(child: _buildPreferences()),
      SizedBox(width: 16),
      Expanded(child: _buildAccountSettings()),
    ],
  );
}
```

### Transaction List

```dart
// Landscape: More columns in grid view
final gridColumns = OrientationHelper.value(
  context,
  portrait: 2,
  landscape: 3,
);

AdaptiveGrid(
  tabletColumns: gridColumns,
  spacing: 12.0,
  children: transactions.map(_buildCard).toList(),
)
```

## Performance Tips

1. **Cache orientation checks** if used multiple times in the same build
2. **Use const constructors** for padding/spacing values
3. **Avoid rebuilding** entire tree on orientation change - only affected widgets

## Accessibility

- Landscape layouts should maintain logical reading order
- Ensure all interactive elements remain accessible
- Test with TalkBack/VoiceOver in both orientations
- Maintain minimum touch target sizes (44x44 dp)

## Testing

```dart
testWidgets('should adapt to landscape', (tester) async {
  // Set landscape orientation
  tester.binding.window.physicalSizeTestValue = Size(800, 600);
  tester.binding.window.devicePixelRatioTestValue = 1.0;

  await tester.pumpWidget(MyApp());

  expect(OrientationHelper.isLandscape(tester.element(find.byType(MyApp))), true);

  // Reset
  tester.binding.window.clearPhysicalSizeTestValue();
  tester.binding.window.clearDevicePixelRatioTestValue();
});
```
