# Animation Integration Guide

Quick guide to add animations to existing JoonaPay screens.

## Already Integrated

The animation system is fully implemented at `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/core/animations/` with:

- **FadeSlide** - Entrance animations with fade + slide
- **ScaleIn** - Pop-in effects for success states
- **ShimmerEffect** - Skeleton loading states
- **AnimatedBalance** - Smooth balance number transitions
- **Micro-interactions** - Shake, glow, ripple, checkmark
- **SlideReveal** - Panel reveal animations
- **Page Transitions** - Already integrated with GoRouter

## Quick Checklist for New Screens

### 1. Add Skeleton Loading State

```dart
// Replace static loading indicators with shimmer
if (state.isLoading) {
  return Column(
    children: [
      SkeletonBalanceCard(),
      SizedBox(height: AppSpacing.lg),
      ...List.generate(5, (_) => SkeletonTransactionItem()),
    ],
  );
}
```

### 2. Add Entrance Animations

```dart
// Wrap hero elements with FadeSlide
FadeSlide(
  direction: SlideDirection.fromTop,
  child: BalanceCard(),
)

// Stagger list items
StaggeredFadeSlide(
  itemDelay: Duration(milliseconds: 80),
  children: transactions.map((tx) => TransactionTile(tx)).toList(),
)
```

### 3. Animate Balance Changes

```dart
// Replace static Text with AnimatedBalance
AnimatedBalance(
  balance: walletState.balance,
  currency: 'USDC',
  showChangeIndicator: true,
)
```

### 4. Add Button Micro-interactions

```dart
// Wrap action buttons with PopAnimation
PopAnimation(
  onPressed: _handleSend,
  child: AppButton(label: 'Send Money'),
)
```

### 5. Show Success States

```dart
// Use ScaleIn with SuccessCheckmark
ScaleIn(
  scaleType: ScaleType.bounceIn,
  child: SuccessCheckmark(size: 100),
)
```

### 6. Add Error Feedback

```dart
// Shake on validation error
ShakeAnimation(
  trigger: hasError,
  child: AppInput(
    controller: _amountController,
    error: errorMessage,
  ),
)
```

## Screen-by-Screen Guide

### Transaction List Screen

**Before:**
```dart
ListView.builder(
  itemBuilder: (context, index) {
    return TransactionTile(transactions[index]);
  },
)
```

**After:**
```dart
if (isLoading) {
  return ListView(
    children: List.generate(5, (_) => SkeletonTransactionItem()),
  );
}

return ListView.builder(
  itemBuilder: (context, index) {
    return FadeSlide(
      delay: Duration(milliseconds: index * 50),
      child: TransactionTile(transactions[index]),
    );
  },
)
```

### Send Money Screen

**Add to amount input:**
```dart
// Shake on invalid amount
ShakeAnimation(
  trigger: _hasError,
  child: AppInput(
    label: 'Amount',
    controller: _amountController,
  ),
)
```

**Add to submit button:**
```dart
PopAnimation(
  onPressed: _handleSend,
  child: GlowAnimation(
    continuous: false,
    child: AppButton(label: 'Send'),
  ),
)
```

### Success Screen

**Full example:**
```dart
class TransferSuccessView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleIn(
                scaleType: ScaleType.bounceIn,
                duration: Duration(milliseconds: 600),
                child: SuccessCheckmark(size: 120),
              ),
              SizedBox(height: AppSpacing.xxl),
              FadeSlide(
                delay: Duration(milliseconds: 400),
                child: AppText(
                  'Transfer Successful!',
                  style: AppTypography.headlineMedium,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              FadeSlide(
                delay: Duration(milliseconds: 500),
                child: AnimatedBalance(
                  balance: 1234.56,
                  currency: 'USDC',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## Performance Best Practices

### 1. Use Const Constructors
```dart
const FadeSlide(
  direction: SlideDirection.fromBottom,
  child: MyWidget(),  // MyWidget should also be const
)
```

### 2. Limit Nested Animations
```dart
// Good: Single combined animation
FadeSlide(child: MyWidget())

// Bad: Multiple nested animations
FadeTransition(
  child: SlideTransition(
    child: ScaleTransition(
      child: MyWidget(),
    ),
  ),
)
```

### 3. Dispose Controllers
```dart
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}
```

### 4. Use RepaintBoundary for Complex Animations
```dart
RepaintBoundary(
  child: ComplexAnimatedWidget(),
)
```

### 5. Respect Reduced Motion
```dart
final reducedMotion = MediaQuery.of(context).disableAnimations;

FadeSlide(
  duration: AnimationUtils.getAccessibleDuration(
    Duration(milliseconds: 400),
    reducedMotion,
  ),
  child: MyWidget(),
)
```

## Common Patterns

### Balance Card with Animation
```dart
class AnimatedBalanceCard extends StatelessWidget {
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
            AppText('Available Balance', style: AppTypography.bodySmall),
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

### Quick Actions with Stagger
```dart
class QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      _Action('Send', Icons.arrow_upward, () => context.push('/send')),
      _Action('Receive', Icons.arrow_downward, () => context.push('/receive')),
      _Action('Deposit', Icons.add, () => context.push('/deposit')),
      _Action('Scan', Icons.qr_code_scanner, () => context.push('/scan')),
    ];

    return StaggeredFadeSlide(
      itemDelay: Duration(milliseconds: 60),
      children: actions.map((action) =>
        PopAnimation(
          onPressed: action.onTap,
          child: _ActionButton(action),
        )
      ).toList(),
    );
  }
}
```

### Loading States
```dart
// List skeleton
class TransactionListSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        5,
        (_) => Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: SkeletonTransactionItem(),
        ),
      ),
    );
  }
}

// Card skeleton
class CardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SkeletonCard(
      height: 120,
      borderRadius: AppRadius.lg,
    );
  }
}
```

### Error States
```dart
class ErrorStateWithAnimation extends StatefulWidget {
  final String message;
  final VoidCallback onRetry;

  @override
  State<ErrorStateWithAnimation> createState() => _ErrorStateWithAnimationState();
}

class _ErrorStateWithAnimationState extends State<ErrorStateWithAnimation> {
  bool _shake = false;

  void _handleRetry() {
    setState(() => _shake = true);
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) setState(() => _shake = false);
      widget.onRetry();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShakeAnimation(
            trigger: _shake,
            child: Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.errorText,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          FadeSlide(
            child: AppText(widget.message),
          ),
          SizedBox(height: AppSpacing.xl),
          PopAnimation(
            onPressed: _handleRetry,
            child: AppButton(label: 'Retry'),
          ),
        ],
      ),
    );
  }
}
```

## Animation Timing Guidelines

| Animation Type | Duration | Curve |
|---------------|----------|-------|
| Micro-interaction | 150ms | easeInOut |
| Element transition | 300ms | easeOutCubic |
| Page transition | 400ms | fastOutSlowIn |
| Success animation | 600ms | elasticOut |
| Loading shimmer | 1500ms | easeInOut |

## Accessibility

Always check for reduced motion:

```dart
final disableAnimations = MediaQuery.of(context).disableAnimations;

if (disableAnimations) {
  return MyWidget(); // No animation
}

return FadeSlide(child: MyWidget()); // With animation
```

Or use the helper:

```dart
FadeSlide(
  duration: AnimationUtils.getAccessibleDuration(
    Duration(milliseconds: 400),
    MediaQuery.of(context).disableAnimations,
  ),
  curve: AnimationUtils.getAccessibleCurve(
    MediaQuery.of(context).disableAnimations,
  ),
  child: MyWidget(),
)
```

## Testing Animations

Use Flutter's built-in animation testing:

```dart
testWidgets('FadeSlide animates correctly', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: FadeSlide(
        child: Text('Test'),
      ),
    ),
  );

  // Initially invisible
  expect(find.text('Test'), findsNothing);

  // Pump animation
  await tester.pump(Duration(milliseconds: 200));

  // Should be partially visible
  final opacity = tester.widget<FadeTransition>(
    find.byType(FadeTransition),
  ).opacity.value;
  expect(opacity, greaterThan(0.0));
  expect(opacity, lessThan(1.0));

  // Complete animation
  await tester.pumpAndSettle();

  // Should be fully visible
  expect(find.text('Test'), findsOneWidget);
});
```

## Debugging

Enable slow animations in debug mode:

```dart
import 'package:flutter/scheduler.dart';

void main() {
  timeDilation = 2.0; // Slow down animations 2x
  runApp(MyApp());
}
```

## Next Steps

1. Review screens that need animation enhancements
2. Start with high-impact screens (home, transactions, success)
3. Add skeleton loading to all async data fetches
4. Test on physical devices for performance
5. Collect user feedback on animation feel

## Related Files

- `/lib/core/animations/index.dart` - Import all animations
- `/lib/router/page_transitions.dart` - Page-level transitions
- `/lib/core/animations/README.md` - Full animation documentation
- `/lib/core/animations/EXAMPLES.md` - Real-world examples
