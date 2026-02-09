# Wallet Home - Tablet Layout Example

## Mobile Layout (< 600px)

```
┌─────────────────────────────────┐
│  Good morning                   │
│  John Doe            [🔔] [⚙️]  │
│                                 │
│  ┌───────────────────────────┐  │
│  │   Total Balance           │  │
│  │   $1,234.56  USDC        │  │
│  │   ≈ 975,200 XOF          │  │
│  └───────────────────────────┘  │
│                                 │
│  [Send] [Receive] [Deposit] [History]
│                                 │
│  ⚠️ Complete KYC Verification   │
│                                 │
│  Recent Activity     [View All] │
│  ┌───────────────────────────┐  │
│  │ 📤 Sent to Alice  -$50.00│  │
│  │ 📥 Received      +$100.00│  │
│  │ 📤 Deposit       +$500.00│  │
│  └───────────────────────────┘  │
└─────────────────────────────────┘
```

## Tablet Layout (≥ 600px)

```
┌─────────────────────────────────────────────────────────────────┐
│  Good morning                                      [🔔] [⚙️]    │
│  John Doe                                                       │
│                                                                 │
│  ┌──────────────────────────────┐  ┌─────────────────────────┐ │
│  │   Total Balance              │  │  [Send]    [Receive]    │ │
│  │                              │  │                         │ │
│  │   $1,234.56  USDC           │  │                         │ │
│  │   ≈ 975,200 XOF             │  │  [Deposit]  [History]   │ │
│  │                              │  │                         │ │
│  └──────────────────────────────┘  └─────────────────────────┘ │
│                                                                 │
│  ⚠️ Complete KYC Verification to unlock full features          │
│                                                                 │
│  Recent Activity                                  [View All]    │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Today                                                   │  │
│  │  ┌────────────────────────────────────────────────────┐ │  │
│  │  │ 📤  Sent to Alice                        -$50.00   │ │  │
│  │  │     Mobile Money Transfer                          │ │  │
│  │  └────────────────────────────────────────────────────┘ │  │
│  │  ┌────────────────────────────────────────────────────┐ │  │
│  │  │ 📥  Received from Bob                   +$100.00   │ │  │
│  │  │     JoonaPay Transfer                              │ │  │
│  │  └────────────────────────────────────────────────────┘ │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## Key Differences

### Balance Card
- **Mobile:** Full width, centered balance
- **Tablet:** 60% width (left), larger padding, more spacious

### Quick Actions
- **Mobile:** 4 buttons in horizontal row, may feel cramped
- **Tablet:** 2x2 grid (right side), better touch targets, cleaner layout

### Spacing
- **Mobile:** 16px padding (AppSpacing.screenPadding)
- **Tablet:** 32px padding (AppSpacing.xl)

### Transactions
- **Mobile:** Compact list
- **Tablet:** Full width with better spacing, easier to scan

### Content Width
- **Mobile:** Uses full screen width
- **Tablet:** Constrained to max 720px, centered on screen

## Implementation Details

### Mobile Layout Code
```dart
Widget _buildMobileLayout() {
  return Column(
    children: [
      _buildHeader(),
      SizedBox(height: AppSpacing.xxl),
      _buildBalanceCard(),
      SizedBox(height: AppSpacing.xxl),
      _buildQuickActions(),  // Horizontal row
      SizedBox(height: AppSpacing.xxl),
      _buildTransactionList(),
    ],
  );
}
```

### Tablet Layout Code
```dart
Widget _buildTabletLayout() {
  return Column(
    children: [
      _buildHeader(),
      SizedBox(height: AppSpacing.xxl),

      // Two-column layout
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: _buildBalanceCard(),
          ),
          SizedBox(width: AppSpacing.xl),
          Expanded(
            flex: 2,
            child: _buildQuickActionsGrid(),  // 2x2 grid
          ),
        ],
      ),

      SizedBox(height: AppSpacing.xxl),
      _buildTransactionList(),  // Full width
    ],
  );
}
```

### Quick Actions Grid (Tablet)
```dart
Widget _buildQuickActionsGrid() {
  return Column(
    children: [
      Row(
        children: [
          Expanded(child: _QuickActionButton('Send', Icons.send)),
          SizedBox(width: AppSpacing.md),
          Expanded(child: _QuickActionButton('Receive', Icons.qr_code)),
        ],
      ),
      SizedBox(height: AppSpacing.md),
      Row(
        children: [
          Expanded(child: _QuickActionButton('Deposit', Icons.add_circle)),
          SizedBox(width: AppSpacing.md),
          Expanded(child: _QuickActionButton('History', Icons.history)),
        ],
      ),
    ],
  );
}
```

## Responsive Wrapper
```dart
ResponsiveBuilder(
  mobile: _buildMobileLayout(context, ref, ...),
  tablet: _buildTabletLayout(context, ref, ...),
)
```

## Benefits

1. **Better Space Utilization** - Horizontal space not wasted on tablets
2. **Improved Touch Targets** - Grid layout provides larger, easier-to-tap buttons
3. **Faster Navigation** - Key actions visible without scrolling
4. **Professional Look** - More polished, desktop-like experience
5. **Reduced Scrolling** - More content above the fold
6. **Better Readability** - Constrained width prevents text lines from being too long
