# Responsive Design Guide

This guide shows how to create adaptive layouts for mobile, tablet, and iPad in the JoonaPay app.

## Breakpoints

```dart
Mobile:  < 600px
Tablet:  600px - 900px
Desktop: > 900px (future-proofing)
```

## Quick Reference

### 1. Check Device Type

```dart
import '../../../design/utils/responsive_layout.dart';

// In build method
final isTablet = ResponsiveLayout.isTabletOrLarger(context);
final isMobile = ResponsiveLayout.isMobile(context);
```

### 2. Conditional Layouts

**Option A: Simple boolean check**
```dart
return isTablet
    ? _buildTabletLayout()
    : _buildMobileLayout();
```

**Option B: ResponsiveBuilder widget**
```dart
return ResponsiveBuilder(
  mobile: _MobileLayout(),
  tablet: _TabletLayout(),
);
```

### 3. Responsive Padding

```dart
padding: ResponsiveLayout.padding(
  context,
  mobile: const EdgeInsets.all(AppSpacing.screenPadding),
  tablet: const EdgeInsets.all(AppSpacing.xl),
)
```

### 4. Constrain Content Width

```dart
return ConstrainedContent(
  child: YourWidget(),
);
// Auto-constrains width on tablet/desktop
```

### 5. Responsive Columns

```dart
// Home View Pattern
return Row(
  children: [
    Expanded(flex: 2, child: LeftColumn()),
    SizedBox(width: AppSpacing.xxxl),
    Expanded(flex: 3, child: RightColumn()),
  ],
);
```

### 6. Two-Column Layout Helper

```dart
return TwoColumnLayout(
  left: YourLeftWidget(),
  right: YourRightWidget(),
  leftFlex: 2,
  rightFlex: 3,
);
// Automatically stacks vertically on mobile
```

### 7. Adaptive Grid

```dart
return AdaptiveGrid(
  mobileColumns: 1,
  tabletColumns: 2,
  desktopColumns: 3,
  spacing: AppSpacing.md,
  children: items.map((item) => ItemCard(item)).toList(),
);
```

## Common Patterns

### Pattern 1: Two-Column Dashboard (Home View)

**Mobile:** Vertical stack
**Tablet:** 40/60 split with balance on left, transactions on right

```dart
class HomeView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTablet = ResponsiveLayout.isTabletOrLarger(context);

    return Scaffold(
      body: ConstrainedContent(
        child: SingleChildScrollView(
          padding: ResponsiveLayout.padding(
            context,
            mobile: const EdgeInsets.all(AppSpacing.screenPadding),
            tablet: const EdgeInsets.all(AppSpacing.xl),
          ),
          child: isTablet
              ? _buildTabletLayout(context)
              : _buildMobileLayout(context),
        ),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: Balance & Actions (40%)
        Expanded(
          flex: 2,
          child: Column(
            children: [
              BalanceCard(),
              SizedBox(height: AppSpacing.xxl),
              QuickActions(),
            ],
          ),
        ),
        SizedBox(width: AppSpacing.xxxl),
        // Right: Transactions (60%)
        Expanded(
          flex: 3,
          child: TransactionsList(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        BalanceCard(),
        SizedBox(height: AppSpacing.xxl),
        QuickActions(),
        SizedBox(height: AppSpacing.xxl),
        TransactionsList(),
      ],
    );
  }
}
```

### Pattern 2: Settings Grid (Settings View)

**Mobile:** Vertical list
**Tablet:** Two-column grid

```dart
class SettingsView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ResponsiveBuilder(
      mobile: _buildMobileLayout(context),
      tablet: _buildTabletLayout(context),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              // Security section
              SectionHeader('Security'),
              SettingsTile(...),
              SettingsTile(...),
            ],
          ),
        ),
        SizedBox(width: AppSpacing.xxxl),
        Expanded(
          child: Column(
            children: [
              // Preferences section
              SectionHeader('Preferences'),
              SettingsTile(...),
              SettingsTile(...),
            ],
          ),
        ),
      ],
    );
  }
}
```

### Pattern 3: Transaction Cards Grid

**Mobile:** Vertical list
**Tablet:** 2-column grid for dense data

```dart
if (isTablet && transactions.length > 3)
  AdaptiveGrid(
    tabletColumns: 2,
    spacing: AppSpacing.md,
    children: transactions.map((tx) => TransactionCard(tx)).toList(),
  )
else
  ...transactions.map((tx) => TransactionRow(tx))
```

### Pattern 4: Responsive Buttons

**Mobile:** Icon + small label (vertical)
**Tablet:** Icon + large label (horizontal)

```dart
class QuickActionButton extends StatelessWidget {
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: isTablet
          ? Row(
              children: [
                Icon(icon),
                SizedBox(width: AppSpacing.md),
                Expanded(child: Text(label)),
                Icon(Icons.chevron_right),
              ],
            )
          : Column(
              children: [
                Icon(icon),
                SizedBox(height: AppSpacing.sm),
                Text(label),
              ],
            ),
    );
  }
}
```

## Screen-Specific Optimizations

### Home View
- **Mobile:** Vertical stack, compact quick actions
- **Tablet:** 2-column (40/60 split), vertical quick actions, transactions on right

### Transactions View
- **Mobile:** List view with groups
- **Tablet:** List view with optional 2-column card grid for dense groups

### Settings View
- **Mobile:** Vertical list of sections
- **Tablet:** 2-column grid (Security/Account | Preferences/Support)

### Send/Receive Views
- **Mobile:** Full-width forms
- **Tablet:** Centered 600px max-width with larger input fields

### Transaction Detail
- **Mobile:** Full screen
- **Tablet:** Centered modal (600px) or side-by-side master-detail

## Responsive Helpers

### Font Sizes
```dart
ResponsiveHelpers.fontSize(
  context,
  mobile: 14,
  tablet: 16,
)
```

### Icon Sizes
```dart
ResponsiveHelpers.iconSize(
  context,
  mobile: 20,
  tablet: 24,
)
```

### Dialog Width
```dart
Container(
  width: ResponsiveHelpers.dialogWidth(context),
  child: AlertDialog(...),
)
```

### Hide on Mobile
```dart
HideOnMobile(
  child: AdditionalInfo(),
)
```

### Show Only on Tablet
```dart
ShowOnlyTablet(
  child: SidePanel(),
)
```

## Best Practices

### 1. Always Use ConstrainedContent
```dart
// Good
ConstrainedContent(
  child: YourContent(),
)

// Bad - content stretches too wide on tablet
YourContent()
```

### 2. Responsive Padding
```dart
// Good
padding: ResponsiveLayout.padding(
  context,
  mobile: EdgeInsets.all(16),
  tablet: EdgeInsets.all(24),
)

// Bad - same padding on all devices
padding: EdgeInsets.all(16)
```

### 3. Test Landscape Mode
```dart
// iPads can rotate - test both orientations
final isLandscape = ResponsiveHelpers.isLandscape(context);
```

### 4. Flexible Layouts
```dart
// Good - adapts to available space
Expanded(flex: 2, child: Widget())

// Bad - fixed width on tablet
SizedBox(width: 300, child: Widget())
```

### 5. Minimum Touch Targets
```dart
// Ensure 48x48 minimum for touch targets
Container(
  constraints: BoxConstraints(
    minWidth: 48,
    minHeight: 48,
  ),
  child: IconButton(...),
)
```

## Testing Checklist

- [ ] Test on iPhone (375px width)
- [ ] Test on iPhone Plus (414px width)
- [ ] Test on iPad Mini (768px width)
- [ ] Test on iPad Pro (1024px width)
- [ ] Test portrait and landscape orientations
- [ ] Verify text doesn't overflow
- [ ] Check spacing is appropriate for screen size
- [ ] Ensure touch targets are 48x48 minimum
- [ ] Verify content is centered/constrained on large screens

## Common Screen Sizes

| Device | Width | Breakpoint |
|--------|-------|------------|
| iPhone SE | 375px | Mobile |
| iPhone 14 | 390px | Mobile |
| iPhone 14 Plus | 428px | Mobile |
| iPad Mini | 768px | Tablet |
| iPad Air | 820px | Tablet |
| iPad Pro 11" | 834px | Tablet |
| iPad Pro 12.9" | 1024px | Tablet |

## Performance Tips

1. **Avoid rebuilding entire screen** - use `isTablet` at widget level
2. **Cache layout calculations** - use `LayoutBuilder` sparingly
3. **Lazy load grids** - use `ListView.builder` with `AdaptiveGrid`
4. **Constrain images** - use `ConstrainedContent` to prevent oversized assets

## Migration Guide

### Before (Mobile-only)
```dart
class MyView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Widget1(),
            Widget2(),
          ],
        ),
      ),
    );
  }
}
```

### After (Responsive)
```dart
class MyView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTablet = ResponsiveLayout.isTabletOrLarger(context);

    return Scaffold(
      body: ConstrainedContent(
        child: Padding(
          padding: ResponsiveLayout.padding(
            context,
            mobile: EdgeInsets.all(16),
            tablet: EdgeInsets.all(24),
          ),
          child: isTablet
              ? Row(
                  children: [
                    Expanded(child: Widget1()),
                    SizedBox(width: 32),
                    Expanded(child: Widget2()),
                  ],
                )
              : Column(
                  children: [
                    Widget1(),
                    SizedBox(height: 16),
                    Widget2(),
                  ],
                ),
        ),
      ),
    );
  }
}
```

## Examples in Codebase

- **Home View**: `/features/wallet/views/home_view.dart`
- **Settings View**: `/features/settings/views/settings_view.dart`
- **Transactions View**: `/features/transactions/views/transactions_view.dart`
- **Responsive Utils**: `/design/utils/responsive_layout.dart`
- **Helpers**: `/design/utils/responsive_helpers.dart`
