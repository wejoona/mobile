# Practical Animation Example

Real-world example: Enhancing the Wallet Home Screen with animations.

## Current State Analysis

The wallet home screen at `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/features/wallet/views/wallet_home_screen.dart` already has:
- Basic balance animation controller
- Pull-to-refresh
- Loading states

## What We'll Add

1. Skeleton loading instead of generic spinner
2. Staggered entrance animations for UI elements
3. Smooth balance transitions with AnimatedBalance
4. Micro-interactions on quick action buttons
5. Enhanced success feedback

## Step 1: Add Import

```dart
// Add to top of wallet_home_screen.dart
import '../../../core/animations/index.dart';
```

## Step 2: Replace Loading State

### Before:
```dart
if (walletState.status == WalletStatus.initial) {
  return _buildLoadingCard(context, l10n, colors);
}
```

### After:
```dart
if (walletState.status == WalletStatus.initial || walletState.isLoading) {
  return Column(
    children: [
      SkeletonBalanceCard(),
      SizedBox(height: AppSpacing.lg),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            4,
            (_) => SkeletonCircle(size: 64),
          ),
        ),
      ),
      SizedBox(height: AppSpacing.lg),
      Expanded(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          children: List.generate(5, (_) => SkeletonTransactionItem()),
        ),
      ),
    ],
  );
}
```

## Step 3: Enhance Balance Display

### Before:
```dart
AnimatedBuilder(
  animation: _balanceAnimation,
  builder: (context, child) {
    final animatedValue = primaryBalance * _balanceAnimation.value;
    return Text(
      _formatBalance(animatedValue),
      style: AppTypography.displayMedium,
    );
  },
)
```

### After:
```dart
// Remove custom AnimationBuilder and use AnimatedBalance
AnimatedBalance(
  balance: primaryBalance,
  currency: 'USDC',
  style: AppTypography.displayMedium.copyWith(
    color: colors.textPrimary,
  ),
  showChangeIndicator: true,
  duration: Duration(milliseconds: 800),
)
```

## Step 4: Add Entrance Animation to Balance Card

### Wrap the entire balance card:
```dart
Widget _buildBalanceCard(...) {
  // ... existing checks ...

  return FadeSlide(
    direction: SlideDirection.fromTop,
    duration: Duration(milliseconds: 500),
    child: Container(
      decoration: BoxDecoration(
        // ... existing decoration ...
      ),
      child: Padding(
        // ... existing content ...
      ),
    ),
  );
}
```

## Step 5: Animate Quick Actions

### Before:
```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    _QuickActionButton(icon: Icons.send, label: 'Send', onTap: () => context.push('/send')),
    _QuickActionButton(icon: Icons.download, label: 'Receive', onTap: () => context.push('/receive')),
    _QuickActionButton(icon: Icons.add, label: 'Deposit', onTap: () => context.push('/deposit')),
    _QuickActionButton(icon: Icons.qr_code_scanner, label: 'Scan', onTap: () => context.push('/scan')),
  ],
)
```

### After:
```dart
StaggeredFadeSlide(
  direction: SlideDirection.fromBottom,
  itemDelay: Duration(milliseconds: 80),
  children: [
    PopAnimation(
      onPressed: () => context.push('/send'),
      child: _QuickActionButton(icon: Icons.send, label: 'Send'),
    ),
    PopAnimation(
      onPressed: () => context.push('/receive'),
      child: _QuickActionButton(icon: Icons.download, label: 'Receive'),
    ),
    PopAnimation(
      onPressed: () => context.push('/deposit'),
      child: _QuickActionButton(icon: Icons.add, label: 'Deposit'),
    ),
    PopAnimation(
      onPressed: () => context.push('/scan'),
      child: _QuickActionButton(icon: Icons.qr_code_scanner, label: 'Scan'),
    ),
  ],
)

// Update _QuickActionButton to not handle onTap (PopAnimation handles it)
Widget _QuickActionButton({
  required IconData icon,
  required String label,
}) {
  return Column(
    children: [
      Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: colors.container,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: colors.borderGold.withValues(alpha: 0.2),
          ),
        ),
        child: Icon(icon, color: colors.gold),
      ),
      SizedBox(height: AppSpacing.xs),
      AppText(label, variant: AppTextVariant.bodySmall),
    ],
  );
}
```

## Step 6: Animate Transaction List

### Before:
```dart
ListView.builder(
  itemCount: transactions.length,
  itemBuilder: (context, index) {
    return TransactionTile(transaction: transactions[index]);
  },
)
```

### After:
```dart
ListView.builder(
  itemCount: transactions.length,
  itemBuilder: (context, index) {
    return FadeSlide(
      direction: SlideDirection.fromBottom,
      delay: Duration(milliseconds: 100 + (index * 50)),
      child: TransactionTile(transaction: transactions[index]),
    );
  },
)
```

## Step 7: Enhance Header with Subtle Animation

```dart
Widget _buildHeader(...) {
  return FadeSlide(
    direction: SlideDirection.fromTop,
    duration: Duration(milliseconds: 400),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ... existing header content ...
      ],
    ),
  );
}
```

## Step 8: Add Glow to Important Buttons

For special promotions or important actions:

```dart
GlowAnimation(
  glowColor: AppColors.gold500,
  continuous: true,
  child: _PromotionButton(),
)
```

## Complete Enhanced Screen Structure

```dart
Widget _buildContent(...) {
  return CustomScrollView(
    slivers: [
      // Header with greeting - animated
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.screenPadding),
          child: _buildHeader(context, l10n, userName, colors),
        ),
      ),

      // Balance card - animated entrance
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: _buildBalanceCard(context, ref, walletState, l10n, colors),
        ),
      ),

      SizedBox(height: AppSpacing.lg),

      // Quick actions - staggered animation with pop effect
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: _buildQuickActions(context, l10n, colors),
        ),
      ),

      SizedBox(height: AppSpacing.lg),

      // Section header
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: FadeSlide(
            delay: Duration(milliseconds: 300),
            child: AppText(
              l10n.home_recentTransactions,
              variant: AppTextVariant.titleMedium,
            ),
          ),
        ),
      ),

      SizedBox(height: AppSpacing.md),

      // Transaction list - staggered entrance
      SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return FadeSlide(
                delay: Duration(milliseconds: 400 + (index * 50)),
                child: _TransactionTile(txState.transactions[index]),
              );
            },
            childCount: min(txState.transactions.length, 5),
          ),
        ),
      ),
    ],
  );
}
```

## Step 9: Error State with Animation

```dart
Widget _buildErrorCard(...) {
  return FadeSlide(
    child: Container(
      padding: EdgeInsets.all(AppSpacing.cardPaddingLarge),
      decoration: BoxDecoration(
        color: colors.container,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        children: [
          ShakeAnimation(
            trigger: true,
            child: Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.errorText,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          AppText(
            error,
            variant: AppTextVariant.bodyMedium,
            color: colors.textSecondary,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.lg),
          PopAnimation(
            onPressed: onRetry,
            child: AppButton(
              label: l10n.common_retry,
              type: ButtonType.secondary,
            ),
          ),
        ],
      ),
    ),
  );
}
```

## Step 10: Add Success Feedback

When a transaction completes, show animated feedback:

```dart
void _showTransactionSuccess() {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.xxl),
        decoration: BoxDecoration(
          color: AppColors.slate,
          borderRadius: BorderRadius.circular(AppRadius.xxl),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleIn(
              scaleType: ScaleType.bounceIn,
              duration: Duration(milliseconds: 600),
              child: SuccessCheckmark(size: 100),
            ),
            SizedBox(height: AppSpacing.lg),
            FadeSlide(
              delay: Duration(milliseconds: 400),
              child: AppText(
                'Transaction Successful!',
                variant: AppTextVariant.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
```

## Performance Considerations

### 1. Limit Animations on Low-End Devices

```dart
// At the top of build method
final shouldAnimate = !MediaQuery.of(context).disableAnimations;

// Use conditionally
if (shouldAnimate) {
  return FadeSlide(child: widget);
} else {
  return widget;
}
```

### 2. Use RepaintBoundary for Complex Sections

```dart
RepaintBoundary(
  child: _buildBalanceCard(...),
)
```

### 3. Limit Simultaneous Animations

Don't animate more than 10 items at once. For longer lists:

```dart
ListView.builder(
  itemBuilder: (context, index) {
    // Only animate first 10 items
    if (index < 10) {
      return FadeSlide(
        delay: Duration(milliseconds: index * 50),
        child: TransactionTile(...),
      );
    }
    return TransactionTile(...);
  },
)
```

## Testing the Animations

```dart
// In dev mode, slow down animations to verify timing
import 'package:flutter/scheduler.dart';

void main() {
  if (kDebugMode) {
    timeDilation = 2.0; // 2x slower for testing
  }
  runApp(MyApp());
}
```

## Before & After Comparison

### Before:
- Static elements appear instantly
- No loading feedback (just spinner)
- No interaction feedback
- Balance updates jump

### After:
- Smooth staggered entrance
- Skeleton loading shows structure
- Buttons respond with pop effect
- Balance smoothly animates to new value
- Success states feel rewarding

## Estimated Time to Implement

- Loading skeletons: 15 minutes
- Entrance animations: 20 minutes
- Balance animation: 10 minutes
- Button interactions: 15 minutes
- Error/success states: 20 minutes

**Total: ~1.5 hours for full enhancement**

## Next Screens to Enhance

Priority order:
1. ✅ Wallet Home (this example)
2. Transaction List View
3. Send Money Flow
4. Transaction Detail View
5. Success/Error Screens
6. Settings Screens

## Measuring Impact

Track these metrics before/after:
- User engagement time on home screen
- Pull-to-refresh usage
- Quick action tap rate
- Perceived performance (user surveys)

## Common Pitfalls to Avoid

1. **Too many animations** - Keep it subtle
2. **Too long durations** - 300-600ms is ideal
3. **Nested animations** - Combine when possible
4. **Ignoring reduced motion** - Always check accessibility
5. **Animating too many items** - Limit to visible content

## Related Files

- `/lib/core/animations/index.dart` - All animation widgets
- `/lib/core/animations/README.md` - Full documentation
- `/lib/core/animations/EXAMPLES.md` - More examples
- `/lib/router/page_transitions.dart` - Page transitions
