# Animation Examples

Real-world examples of integrating animations into JoonaPay screens.

## 1. Enhanced Wallet Home Screen

```dart
// Before: Static balance card
class WalletHomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(walletProvider).balance;

    return Scaffold(
      body: Column(
        children: [
          _BalanceCard(balance: balance),
          _QuickActions(),
          _RecentTransactions(),
        ],
      ),
    );
  }
}

// After: With animations
import 'package:usdc_wallet/core/animations/index.dart';

class WalletHomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletProvider);

    return Scaffold(
      body: SafeArea(
        child: walletState.isLoading
            ? _buildSkeletonView()
            : _buildContent(context, walletState),
      ),
    );
  }

  Widget _buildSkeletonView() {
    return Column(
      children: [
        SkeletonBalanceCard(),
        SizedBox(height: AppSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (_) => SkeletonCircle(size: 60)),
        ),
        SizedBox(height: AppSpacing.lg),
        Expanded(
          child: ListView(
            children: List.generate(5, (_) => SkeletonTransactionItem()),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, WalletState state) {
    return CustomScrollView(
      slivers: [
        // Animated balance card
        SliverToBoxAdapter(
          child: FadeSlide(
            direction: SlideDirection.fromTop,
            duration: Duration(milliseconds: 500),
            child: _AnimatedBalanceCard(balance: state.balance),
          ),
        ),

        // Quick actions with stagger
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.screenPadding),
            child: StaggeredFadeSlide(
              direction: SlideDirection.fromBottom,
              itemDelay: Duration(milliseconds: 60),
              children: [
                _QuickActionButton(
                  icon: Icons.arrow_upward,
                  label: 'Send',
                  onTap: () => context.push('/send'),
                ),
                _QuickActionButton(
                  icon: Icons.arrow_downward,
                  label: 'Receive',
                  onTap: () => context.push('/receive'),
                ),
                _QuickActionButton(
                  icon: Icons.add,
                  label: 'Deposit',
                  onTap: () => context.push('/deposit'),
                ),
                _QuickActionButton(
                  icon: Icons.qr_code_scanner,
                  label: 'Scan',
                  onTap: () => context.push('/scan'),
                ),
              ],
            ),
          ),
        ),

        // Recent transactions
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return FadeSlide(
                  delay: Duration(milliseconds: 200 + (index * 50)),
                  child: _TransactionTile(state.transactions[index]),
                );
              },
              childCount: state.transactions.length,
            ),
          ),
        ),
      ],
    );
  }
}

class _AnimatedBalanceCard extends StatelessWidget {
  final double balance;

  const _AnimatedBalanceCard({required this.balance});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(AppSpacing.screenPadding),
      padding: EdgeInsets.all(AppSpacing.cardPaddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: AppColors.goldGradient),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold500.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'Available Balance',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textInverse.withOpacity(0.8),
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          AnimatedBalance(
            balance: balance,
            currency: 'USDC',
            showChangeIndicator: true,
            style: AppTypography.displayMedium.copyWith(
              color: AppColors.textInverse,
            ),
          ),
        ],
      ),
    );
  }
}
```

## 2. Transfer Success Screen

```dart
import 'package:usdc_wallet/core/animations/index.dart';

class TransferSuccessView extends StatefulWidget {
  final double amount;
  final String recipient;

  @override
  State<TransferSuccessView> createState() => _TransferSuccessViewState();
}

class _TransferSuccessViewState extends State<TransferSuccessView> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success checkmark with scale animation
              ScaleIn(
                scaleType: ScaleType.bounceIn,
                duration: Duration(milliseconds: 600),
                child: SuccessCheckmark(
                  size: 120,
                  color: AppColors.successText,
                ),
              ),

              SizedBox(height: AppSpacing.xxl),

              // Success message
              FadeSlide(
                delay: Duration(milliseconds: 400),
                direction: SlideDirection.fromBottom,
                child: AppText(
                  l10n.transfer_successTitle,
                  style: AppTypography.headlineMedium,
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: AppSpacing.md),

              // Amount
              FadeSlide(
                delay: Duration(milliseconds: 500),
                direction: SlideDirection.fromBottom,
                child: AnimatedBalance(
                  balance: widget.amount,
                  currency: 'USDC',
                  showChangeIndicator: false,
                  style: AppTypography.displayLarge.copyWith(
                    color: AppColors.gold500,
                  ),
                ),
              ),

              SizedBox(height: AppSpacing.lg),

              // Recipient info card
              FadeSlide(
                delay: Duration(milliseconds: 600),
                direction: SlideDirection.fromBottom,
                child: AppCard(
                  child: Row(
                    children: [
                      SkeletonCircle(size: 48), // Avatar
                      SizedBox(width: AppSpacing.md),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText('Sent to', style: AppTypography.bodySmall),
                          AppText(
                            widget.recipient,
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              Spacer(),

              // Action buttons
              FadeSlide(
                delay: Duration(milliseconds: 700),
                direction: SlideDirection.fromBottom,
                child: Column(
                  children: [
                    PopAnimation(
                      child: AppButton(
                        label: l10n.common_done,
                        onPressed: () => context.go('/home'),
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    TextButton(
                      onPressed: () => _shareReceipt(),
                      child: AppText(l10n.transfer_shareReceipt),
                    ),
                  ],
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

## 3. Login Screen with Error Shake

```dart
import 'package:usdc_wallet/core/animations/index.dart';

class LoginView extends ConsumerStatefulWidget {
  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _phoneController = TextEditingController();
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            children: [
              // Logo with fade slide
              FadeSlide(
                direction: SlideDirection.fromTop,
                child: Image.asset('assets/logo.png', height: 60),
              ),

              SizedBox(height: AppSpacing.xxl),

              // Title
              FadeSlide(
                delay: Duration(milliseconds: 100),
                child: AppText(
                  l10n.auth_loginTitle,
                  style: AppTypography.displaySmall,
                ),
              ),

              SizedBox(height: AppSpacing.xl),

              // Phone input with shake on error
              ShakeAnimation(
                trigger: _hasError,
                child: FadeSlide(
                  delay: Duration(milliseconds: 200),
                  child: AppInput(
                    controller: _phoneController,
                    label: l10n.auth_phoneNumber,
                    keyboardType: TextInputType.phone,
                    errorText: _hasError ? l10n.auth_invalidPhone : null,
                  ),
                ),
              ),

              Spacer(),

              // Submit button with pop animation
              FadeSlide(
                delay: Duration(milliseconds: 300),
                child: PopAnimation(
                  onPressed: authState.isLoading ? null : _handleLogin,
                  child: AppButton(
                    label: l10n.common_continue,
                    onPressed: _handleLogin,
                    isLoading: authState.isLoading,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    setState(() => _hasError = false);

    if (_phoneController.text.isEmpty) {
      setState(() => _hasError = true);
      return;
    }

    await ref.read(authProvider.notifier).login(_phoneController.text);
  }
}
```

## 4. Transaction List with Pull-to-Refresh

```dart
import 'package:usdc_wallet/core/animations/index.dart';

class TransactionsView extends ConsumerStatefulWidget {
  @override
  ConsumerState<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends ConsumerState<TransactionsView> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final transactionState = ref.watch(transactionProvider);

    return Scaffold(
      appBar: AppBar(
        title: AppText(l10n.transactions_title),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(transactionProvider.notifier).refresh(),
        child: transactionState.isLoading
            ? _buildSkeletonList()
            : _buildTransactionList(transactionState.transactions),
      ),
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) => SkeletonTransactionItem(),
    );
  }

  Widget _buildTransactionList(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return Center(
        child: FadeSlide(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleIn(
                scaleType: ScaleType.smooth,
                child: Icon(
                  Icons.receipt_long_outlined,
                  size: 80,
                  color: AppColors.textTertiary,
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              AppText(
                'No transactions yet',
                style: AppTypography.bodyLarge,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        return FadeSlide(
          delay: Duration(milliseconds: index * 30),
          direction: SlideDirection.fromBottom,
          offset: 10,
          child: _TransactionItem(
            transaction: transactions[index],
            onTap: () => _showDetails(transactions[index]),
          ),
        );
      },
    );
  }

  void _showDetails(Transaction transaction) {
    context.push('/transactions/${transaction.id}');
  }
}
```

## 5. Settings Screen with Expandable Sections

```dart
import 'package:usdc_wallet/core/animations/index.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String? _expandedSection;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: AppText(l10n.settings_title)),
      body: ListView(
        padding: EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          _buildSection(
            'account',
            l10n.settings_account,
            Icons.person_outline,
            [
              _SettingItem('Profile', Icons.edit),
              _SettingItem('KYC Status', Icons.verified_user),
              _SettingItem('Limits', Icons.trending_up),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          _buildSection(
            'security',
            l10n.settings_security,
            Icons.security,
            [
              _SettingItem('Change PIN', Icons.pin),
              _SettingItem('Biometrics', Icons.fingerprint),
              _SettingItem('Devices', Icons.devices),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          _buildSection(
            'preferences',
            l10n.settings_preferences,
            Icons.settings,
            [
              _SettingItem('Language', Icons.language),
              _SettingItem('Currency', Icons.attach_money),
              _SettingItem('Notifications', Icons.notifications),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    String id,
    String title,
    IconData icon,
    List<_SettingItem> items,
  ) {
    final isExpanded = _expandedSection == id;

    return AppCard(
      child: Column(
        children: [
          // Section header
          PopAnimation(
            onPressed: () {
              setState(() {
                _expandedSection = isExpanded ? null : id;
              });
            },
            child: Row(
              children: [
                Icon(icon, color: AppColors.gold500),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppText(
                    title,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                RotatingReveal(
                  isRevealed: isExpanded,
                  turns: 0.5,
                  child: Icon(
                    Icons.expand_more,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Expandable content
          ExpandableContent(
            isExpanded: isExpanded,
            child: Column(
              children: [
                SizedBox(height: AppSpacing.md),
                Divider(color: AppColors.borderDefault),
                ...items.map((item) => _buildSettingItem(item)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(_SettingItem item) {
    return PopAnimation(
      child: ListTile(
        leading: Icon(item.icon, size: 20, color: AppColors.textSecondary),
        title: AppText(item.title),
        trailing: Icon(
          Icons.chevron_right,
          color: AppColors.textTertiary,
        ),
        onTap: () {
          // Navigate to detail
        },
      ),
    );
  }
}

class _SettingItem {
  final String title;
  final IconData icon;

  _SettingItem(this.title, this.icon);
}
```

## 6. Notification Badge with Pulse

```dart
import 'package:usdc_wallet/core/animations/index.dart';

class NotificationBell extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(notificationProvider).unreadCount;

    return Stack(
      children: [
        IconButton(
          icon: Icon(Icons.notifications_outlined),
          onPressed: () => context.push('/notifications'),
        ),
        if (unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: PulseAnimation(
              minScale: 0.9,
              maxScale: 1.1,
              duration: Duration(milliseconds: 1200),
              child: GlowAnimation(
                glowColor: AppColors.error,
                glowRadius: 8,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: AnimatedCounter(
                    value: unreadCount,
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
```

## Performance Considerations

### DO:
```dart
// Use const where possible
const FadeSlide(
  child: MyConstWidget(),
)

// Dispose controllers
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}

// Use RepaintBoundary for complex animations
RepaintBoundary(
  child: ComplexAnimation(),
)
```

### DON'T:
```dart
// Don't create new instances on every build
Widget build(BuildContext context) {
  return FadeSlide(
    child: ExpensiveWidget(), // This recreates on every build
  );
}

// Don't nest too many animations
FadeSlide(
  child: ScaleIn(
    child: ShimmerEffect(
      child: RotatingReveal( // Too much!
        child: MyWidget(),
      ),
    ),
  ),
)
```

## Testing Animations

```dart
testWidgets('Balance updates with animation', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: AnimatedBalance(balance: 100.0),
    ),
  );

  expect(find.text('100.00'), findsOneWidget);

  // Update balance
  await tester.pumpWidget(
    MaterialApp(
      home: AnimatedBalance(balance: 200.0),
    ),
  );

  // Animation in progress
  await tester.pump(Duration(milliseconds: 300));

  // Animation complete
  await tester.pumpAndSettle();
  expect(find.text('200.00'), findsOneWidget);
});
```
