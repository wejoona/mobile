# Animation System

Comprehensive animation library for JoonaPay mobile app with reusable, performant animation widgets.

## Overview

This animation system provides:
- **Smooth page transitions** - Already integrated with GoRouter
- **Micro-interactions** - Button presses, ripples, shakes
- **Balance updates** - Animated counters with visual feedback
- **Skeleton loading** - Shimmer effects for loading states
- **Reveal animations** - Slide, expand, rotate transitions

## Quick Start

```dart
import 'package:usdc_wallet/core/animations/index.dart';

// Fade and slide entrance
FadeSlide(
  child: MyWidget(),
  direction: SlideDirection.fromBottom,
)

// Scale in animation
ScaleIn(
  child: Icon(Icons.check_circle),
  scaleType: ScaleType.bounceIn,
)

// Skeleton loading
SkeletonCard(height: 100)
```

## Components

### 1. FadeSlide

Combined fade and slide animation for smooth element entrances.

```dart
// Basic usage
FadeSlide(
  child: Container(height: 100, color: Colors.blue),
  direction: SlideDirection.fromBottom,
)

// With custom duration and delay
FadeSlide(
  child: MyWidget(),
  direction: SlideDirection.fromLeft,
  duration: Duration(milliseconds: 600),
  delay: Duration(milliseconds: 200),
  curve: Curves.easeOutBack,
  offset: 30.0,
)

// Staggered list animation
StaggeredFadeSlide(
  children: [
    ListItem1(),
    ListItem2(),
    ListItem3(),
  ],
  itemDelay: Duration(milliseconds: 100),
)
```

**Parameters:**
- `direction` - SlideDirection.fromTop/fromBottom/fromLeft/fromRight
- `duration` - Animation duration (default: 400ms)
- `delay` - Delay before animation starts
- `curve` - Animation curve (default: easeOutCubic)
- `offset` - Distance to slide (default: 20.0)

### 2. ScaleIn

Scale animation with optional fade for pop-in effects.

```dart
// Success icon with bounce
ScaleIn(
  child: Icon(Icons.check_circle, size: 64),
  scaleType: ScaleType.bounceIn,
)

// Button pop effect
PopAnimation(
  child: AppButton(label: 'Press Me'),
  onPressed: () => print('Pressed!'),
)

// Continuous pulse
PulseAnimation(
  child: NotificationBadge(),
  minScale: 0.95,
  maxScale: 1.05,
)
```

**Scale Types:**
- `smooth` - Standard ease out
- `bounceIn` - Elastic bounce effect
- `spring` - Spring-like bounce
- `snap` - Back ease with overshoot

### 3. ShimmerEffect

Skeleton loading animations.

```dart
// Basic shimmer
ShimmerEffect(
  child: Container(
    height: 100,
    decoration: BoxDecoration(
      color: AppColors.slate,
      borderRadius: BorderRadius.circular(12),
    ),
  ),
)

// Pre-built components
SkeletonLine(height: 16, width: 120)
SkeletonCircle(size: 48)
SkeletonCard(height: 100)
SkeletonTransactionItem()
SkeletonBalanceCard()
```

**Shimmer Directions:**
- `leftToRight` - Horizontal shimmer (default)
- `topToBottom` - Vertical shimmer
- `diagonal` - Diagonal shimmer

### 4. Balance Animations

Animated balance displays with smooth number transitions.

```dart
// Animated balance with change indicator
AnimatedBalance(
  balance: 1234.56,
  currency: 'USDC',
  showChangeIndicator: true,
)

// Simple counter
AnimatedCounter(
  value: 42,
  prefix: '+',
  suffix: ' transactions',
)

// Progress bar
AnimatedProgressBar(
  progress: 0.75, // 0.0 to 1.0
  height: 8,
  foregroundColor: AppColors.gold500,
)
```

**Features:**
- Smooth number transitions
- Color-coded increase/decrease indicators
- Currency formatting with commas
- Configurable duration and style

### 5. Micro-Interactions

Small animations for user feedback.

```dart
// Shake for errors
ShakeAnimation(
  child: TextField(),
  trigger: hasError,
)

// Glow effect
GlowAnimation(
  child: Avatar(),
  glowColor: AppColors.gold500,
  continuous: true,
)

// Success checkmark
SuccessCheckmark(
  size: 80,
  color: AppColors.successText,
)

// Ripple effect
RippleEffect(
  child: Card(),
  onTap: () => print('Tapped!'),
)
```

### 6. Reveal Animations

Content reveal with slide, expand, rotate.

```dart
// Slide reveal
SlideReveal(
  isRevealed: showPanel,
  revealDirection: RevealDirection.fromRight,
  child: SidePanel(),
  onRevealComplete: () => print('Revealed!'),
)

// Expandable content
ExpandableContent(
  isExpanded: isExpanded,
  child: DetailSection(),
)

// Rotating reveal
RotatingReveal(
  isRevealed: showCard,
  turns: 0.25,
  child: Card(),
)
```

## Usage Examples

### Balance Card with Animations

```dart
class BalanceCard extends StatelessWidget {
  final double balance;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SkeletonBalanceCard();
    }

    return FadeSlide(
      direction: SlideDirection.fromTop,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.cardPaddingLarge),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: AppColors.goldGradient),
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText('Available Balance'),
            SizedBox(height: AppSpacing.sm),
            AnimatedBalance(
              balance: balance,
              currency: 'USDC',
              showChangeIndicator: true,
            ),
          ],
        ),
      ),
    );
  }
}
```

### Transaction List with Stagger

```dart
class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Column(
        children: List.generate(
          5,
          (_) => SkeletonTransactionItem(),
        ),
      );
    }

    return StaggeredFadeSlide(
      children: transactions.map((tx) => TransactionTile(tx)).toList(),
      itemDelay: Duration(milliseconds: 80),
    );
  }
}
```

### Success Screen

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
              delay: Duration(milliseconds: 300),
              child: AppText(
                'Transfer Successful!',
                style: AppTypography.headlineMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Button with Micro-interaction

```dart
class AnimatedActionButton extends StatelessWidget {
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return PopAnimation(
      onPressed: onPressed,
      child: GlowAnimation(
        continuous: false,
        child: AppButton(
          label: 'Send Money',
          onPressed: onPressed,
        ),
      ),
    );
  }
}
```

## Animation Guidelines

### Timing

- **Micro-interactions**: 150ms - Button presses, toggles
- **Element transitions**: 300ms - Cards, panels appearing
- **Page transitions**: 400ms - Screen navigation
- **Complex animations**: 600ms - Multi-step animations

### Curves

- **Standard**: `Curves.easeInOut` - Most UI transitions
- **Deceleration**: `Curves.easeOut` - Elements appearing
- **Acceleration**: `Curves.easeIn` - Elements disappearing
- **Emphasized**: `Curves.easeOutBack` - Important actions
- **Playful**: `Curves.bounceOut` - Success states

### Best Practices

1. **Respect reduced motion**: Check accessibility settings
2. **Stagger lists**: Use delays for sequential items
3. **Use appropriate timing**: Don't make users wait
4. **Combine animations**: Fade + slide is better than just slide
5. **Test on devices**: Animations may lag on low-end devices

### Accessibility

```dart
// Respect reduced motion preference
final reducedMotion = MediaQuery.of(context).disableAnimations;

FadeSlide(
  duration: AnimationUtils.getAccessibleDuration(
    Duration(milliseconds: 400),
    reducedMotion,
  ),
  curve: AnimationUtils.getAccessibleCurve(reducedMotion),
  child: MyWidget(),
)
```

## Performance Tips

1. **Use `const` constructors** where possible
2. **Avoid nested animations** - Keep it simple
3. **Dispose controllers** - Always call super.dispose()
4. **Use `RepaintBoundary`** for complex animations
5. **Profile animations** - Use Flutter DevTools

## Animation Catalog

| Animation | Use Case | Duration | Curve |
|-----------|----------|----------|-------|
| FadeSlide | Page entrance, list items | 400ms | easeOutCubic |
| ScaleIn | Success states, pop-ins | 400ms | bounceOut |
| ShimmerEffect | Loading states | 1500ms | easeInOut |
| AnimatedBalance | Balance updates | 600ms | easeOutCubic |
| ShakeAnimation | Error feedback | 500ms | elasticIn |
| PopAnimation | Button press | 150ms | easeInOut |
| SlideReveal | Panel reveals | 300ms | easeInOut |
| ExpandableContent | Accordion sections | 300ms | easeInOut |

## Contributing

When adding new animations:
1. Follow existing naming conventions
2. Add documentation with usage examples
3. Include accessibility considerations
4. Test on physical devices
5. Update this README

## Related Files

- `/lib/router/page_transitions.dart` - Page-level transitions
- `/lib/design/tokens/spacing.dart` - Animation timing constants
- `/lib/utils/reduced_motion_helper.dart` - Accessibility helpers
