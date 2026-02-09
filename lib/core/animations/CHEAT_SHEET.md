# Animation Cheat Sheet

Quick reference for JoonaPay animations. Copy-paste ready code.

## Import

```dart
import 'package:usdc_wallet/core/animations/index.dart';
```

## Common Use Cases

### 1. Page Entrance - Hero Section

```dart
FadeSlide(
  direction: SlideDirection.fromTop,
  child: BalanceCard(),
)
```

### 2. List Items

```dart
FadeSlide(
  delay: Duration(milliseconds: index * 50),
  child: ListItem(),
)
```

### 3. Button Press

```dart
PopAnimation(
  onPressed: _handleTap,
  child: AppButton(label: 'Send'),
)
```

### 4. Balance Display

```dart
AnimatedBalance(
  balance: 1234.56,
  currency: 'USDC',
  showChangeIndicator: true,
)
```

### 5. Loading State

```dart
if (isLoading) {
  return SkeletonCard(height: 120);
}
return ActualCard();
```

### 6. Success Feedback

```dart
ScaleIn(
  scaleType: ScaleType.bounceIn,
  child: SuccessCheckmark(size: 100),
)
```

### 7. Error Shake

```dart
ShakeAnimation(
  trigger: hasError,
  child: TextField(),
)
```

### 8. Important Element

```dart
GlowAnimation(
  glowColor: AppColors.gold500,
  child: PromoCard(),
)
```

### 9. Staggered List

```dart
StaggeredFadeSlide(
  itemDelay: Duration(milliseconds: 80),
  children: [Item1(), Item2(), Item3()],
)
```

### 10. Progress Bar

```dart
AnimatedProgressBar(
  progress: 0.75,
  foregroundColor: AppColors.gold500,
)
```

## Skeleton Components

### Transaction List Loading
```dart
ListView(
  children: List.generate(5, (_) => SkeletonTransactionItem()),
)
```

### Balance Card Loading
```dart
SkeletonBalanceCard()
```

### Generic Card Loading
```dart
SkeletonCard(height: 100)
```

### Avatar Loading
```dart
SkeletonCircle(size: 48)
```

### Text Line Loading
```dart
SkeletonLine(height: 16, width: 120)
```

## Timing Quick Reference

| Use Case | Duration | Curve |
|----------|----------|-------|
| Button tap | 150ms | easeInOut |
| Card entrance | 400ms | easeOutCubic |
| Page transition | 300ms | fastOutSlowIn |
| Success animation | 600ms | elasticOut |
| Error shake | 500ms | elasticIn |
| Loading shimmer | 1500ms | easeInOut |

## Direction Options

```dart
SlideDirection.fromTop
SlideDirection.fromBottom
SlideDirection.fromLeft
SlideDirection.fromRight
```

## Scale Types

```dart
ScaleType.smooth      // Standard
ScaleType.bounceIn    // Elastic
ScaleType.spring      // Spring bounce
ScaleType.snap        // Back ease
```

## Common Patterns

### Loading → Content
```dart
if (isLoading) {
  return SkeletonCard();
}
return FadeSlide(child: Content());
```

### Error → Retry
```dart
if (hasError) {
  return ShakeAnimation(
    trigger: true,
    child: ErrorMessage(),
  );
}
```

### Empty State
```dart
ScaleIn(
  child: EmptyStateIllustration(),
)
```

### Pull to Refresh
```dart
RefreshIndicator(
  onRefresh: _refresh,
  child: ListView(...),
)
```

## Accessibility

```dart
final reducedMotion = MediaQuery.of(context).disableAnimations;

duration: AnimationUtils.getAccessibleDuration(
  Duration(milliseconds: 400),
  reducedMotion,
)
```

## Performance Tips

1. ✅ Use `const` constructors
2. ✅ Limit to ~10 animated items
3. ✅ Dispose controllers
4. ✅ Use `RepaintBoundary` for complex animations
5. ❌ Don't nest multiple animations
6. ❌ Don't animate offscreen items

## Testing Animations

```dart
// Slow down for debugging
import 'package:flutter/scheduler.dart';
timeDilation = 2.0; // 2x slower
```

## View Live Examples

Add to router:
```dart
GoRoute(
  path: '/animation-showcase',
  builder: (context, state) => const AnimationShowcase(),
)
```

Then navigate: `context.push('/animation-showcase')`

## File Locations

```
mobile/lib/core/animations/
├── index.dart                      # Import this
├── fade_slide.dart                 # Entrance animations
├── scale_in.dart                   # Scale animations
├── shimmer_effect.dart             # Loading states
├── balance_update_animation.dart   # Number animations
├── micro_interactions.dart         # Button effects
├── slide_reveal.dart               # Panel reveals
├── animation_utils.dart            # Helper functions
├── animation_showcase.dart         # Live examples
├── README.md                       # Full documentation
├── INTEGRATION_GUIDE.md            # Integration steps
├── PRACTICAL_EXAMPLE.md            # Real screen example
└── CHEAT_SHEET.md                  # This file
```

## Quick Debug

```dart
// Print animation value
AnimatedBuilder(
  animation: _controller,
  builder: (context, child) {
    print('Animation value: ${_controller.value}');
    return child!;
  },
  child: Widget(),
)
```

## Common Mistakes

### ❌ Wrong
```dart
// Don't create controller in build
final controller = AnimationController(...);
```

### ✅ Right
```dart
// Create in initState
late AnimationController _controller;

@override
void initState() {
  super.initState();
  _controller = AnimationController(...);
}
```

### ❌ Wrong
```dart
// Don't forget to dispose
// (Memory leak!)
```

### ✅ Right
```dart
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}
```

### ❌ Wrong
```dart
// Don't animate everything
ListView.builder(
  itemCount: 1000,
  itemBuilder: (i) => FadeSlide(child: Item(i)),
)
```

### ✅ Right
```dart
// Only animate visible items
ListView.builder(
  itemCount: 1000,
  itemBuilder: (i) {
    if (i < 10) {
      return FadeSlide(child: Item(i));
    }
    return Item(i);
  },
)
```

## Copy-Paste Templates

### Complete Screen Template
```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
          ? _buildSkeleton()
          : _buildContent(),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Column(
      children: [
        SkeletonCard(),
        ...List.generate(5, (_) => SkeletonTransactionItem()),
      ],
    );
  }

  Widget _buildContent() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: FadeSlide(
            child: HeroCard(),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => FadeSlide(
              delay: Duration(milliseconds: index * 50),
              child: ListItem(index),
            ),
          ),
        ),
      ],
    );
  }
}
```

### Success Screen Template
```dart
class SuccessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleIn(
              scaleType: ScaleType.bounceIn,
              child: SuccessCheckmark(size: 100),
            ),
            SizedBox(height: AppSpacing.xxl),
            FadeSlide(
              delay: Duration(milliseconds: 400),
              child: AppText('Success!'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Button with Feedback Template
```dart
PopAnimation(
  onPressed: () async {
    // Your action
    await _handleSubmit();

    // Show success
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Done!')),
    );
  },
  child: AppButton(label: 'Submit'),
)
```

## Need Help?

- 📖 Read `/lib/core/animations/README.md`
- 🎯 See `/lib/core/animations/EXAMPLES.md`
- 🔧 Check `/lib/core/animations/PRACTICAL_EXAMPLE.md`
- 🎨 Run `/lib/core/animations/animation_showcase.dart`
