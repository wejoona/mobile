import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';

class VirtualCardView extends ConsumerStatefulWidget {
  const VirtualCardView({super.key});

  @override
  ConsumerState<VirtualCardView> createState() => _VirtualCardViewState();
}

class _VirtualCardViewState extends ConsumerState<VirtualCardView>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  bool _showBack = false;
  bool _cardFrozen = false;
  bool _showDetails = false;

  final _card = _VirtualCard(
    cardNumber: '4532 •••• •••• 7821',
    fullCardNumber: '4532 8901 2345 7821',
    expiryDate: '12/27',
    cvv: '482',
    cardHolder: 'JOHN DOE',
    balance: 1250.00,
    spendLimit: 5000.00,
    spentThisMonth: 1847.50,
  );

  final List<_CardTransaction> _recentTransactions = [
    _CardTransaction('Amazon', -89.99, DateTime.now().subtract(const Duration(hours: 2)), 'Shopping'),
    _CardTransaction('Uber', -24.50, DateTime.now().subtract(const Duration(hours: 8)), 'Transport'),
    _CardTransaction('Netflix', -15.99, DateTime.now().subtract(const Duration(days: 1)), 'Entertainment'),
    _CardTransaction('Starbucks', -6.75, DateTime.now().subtract(const Duration(days: 2)), 'Food'),
    _CardTransaction('Apple Store', -299.00, DateTime.now().subtract(const Duration(days: 3)), 'Shopping'),
  ];

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_showBack) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() => _showBack = !_showBack);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const AppText(
          'Virtual Card',
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _cardFrozen ? Icons.ac_unit : Icons.settings,
              color: _cardFrozen ? AppColors.infoBase : null,
            ),
            onPressed: () => _showCardSettings(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card
            GestureDetector(
              onTap: _flipCard,
              child: AnimatedBuilder(
                animation: _flipController,
                builder: (context, child) {
                  final angle = _flipController.value * math.pi;
                  final transform = Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(angle);

                  return Transform(
                    alignment: Alignment.center,
                    transform: transform,
                    child: angle < math.pi / 2
                        ? _buildCardFront()
                        : Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()..rotateY(math.pi),
                            child: _buildCardBack(),
                          ),
                  );
                },
              ),
            ),

            const SizedBox(height: AppSpacing.md),
            Center(
              child: AppText(
                'Tap card to ${_showBack ? 'hide' : 'show'} details',
                variant: AppTextVariant.bodySmall,
                color: AppColors.textTertiary,
              ),
            ),

            if (_cardFrozen) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.infoBase.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.infoBase.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.ac_unit, color: AppColors.infoBase, size: 20),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppText(
                        'Card is frozen. Unfreeze to make transactions.',
                        variant: AppTextVariant.bodySmall,
                        color: AppColors.infoBase,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.xxl),

            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: _buildQuickAction(
                    icon: Icons.add,
                    label: 'Add Funds',
                    onTap: () => _showAddFunds(),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildQuickAction(
                    icon: _cardFrozen ? Icons.play_arrow : Icons.pause,
                    label: _cardFrozen ? 'Unfreeze' : 'Freeze',
                    onTap: () => _toggleFreeze(),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildQuickAction(
                    icon: Icons.copy,
                    label: 'Copy',
                    onTap: () => _copyCardDetails(),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildQuickAction(
                    icon: Icons.settings,
                    label: 'Settings',
                    onTap: () => _showCardSettings(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Spending Summary
            _buildSpendingSummary(),

            const SizedBox(height: AppSpacing.xxl),

            // Recent Transactions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppText(
                  'Recent Transactions',
                  variant: AppTextVariant.titleMedium,
                  color: AppColors.textPrimary,
                ),
                TextButton(
                  onPressed: () {},
                  child: const AppText(
                    'See All',
                    variant: AppTextVariant.labelMedium,
                    color: AppColors.gold500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ..._recentTransactions.map((tx) => _buildTransactionItem(tx)),

            const SizedBox(height: AppSpacing.xxl),

            // Card Benefits
            _buildBenefitsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildCardFront() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _cardFrozen
              ? [Colors.blueGrey.shade700, Colors.blueGrey.shade900]
              : [AppColors.gold500, AppColors.gold600, const Color(0xFF8B6914)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: (_cardFrozen ? Colors.blueGrey : AppColors.gold500).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText(
                'JoonaPay',
                variant: AppTextVariant.titleMedium,
                color: Colors.white,
              ),
              Row(
                children: [
                  if (_cardFrozen)
                    const Icon(Icons.ac_unit, color: Colors.white, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  const Icon(Icons.contactless, color: Colors.white, size: 24),
                ],
              ),
            ],
          ),
          const Spacer(),
          AppText(
            _showDetails ? _card.fullCardNumber : _card.cardNumber,
            variant: AppTextVariant.headlineSmall,
            color: Colors.white,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText(
                    'CARD HOLDER',
                    variant: AppTextVariant.labelSmall,
                    color: Colors.white70,
                  ),
                  AppText(
                    _card.cardHolder,
                    variant: AppTextVariant.labelMedium,
                    color: Colors.white,
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.xxl),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText(
                    'EXPIRES',
                    variant: AppTextVariant.labelSmall,
                    color: Colors.white70,
                  ),
                  AppText(
                    _card.expiryDate,
                    variant: AppTextVariant.labelMedium,
                    color: Colors.white,
                  ),
                ],
              ),
              const Spacer(),
              // Visa logo placeholder
              Container(
                width: 50,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Center(
                  child: AppText(
                    'VISA',
                    variant: AppTextVariant.labelMedium,
                    color: Color(0xFF1A1F71),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _cardFrozen
              ? [Colors.blueGrey.shade800, Colors.blueGrey.shade900]
              : [const Color(0xFF8B6914), AppColors.gold600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xl),
          Container(
            height: 40,
            color: Colors.black87,
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                          child: AppText(
                            _showDetails ? _card.cvv : '•••',
                            variant: AppTextVariant.labelLarge,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: AppText(
              'This card is issued by JoonaPay. Use responsibly.',
              variant: AppTextVariant.bodySmall,
              color: Colors.white70,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.slate,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.gold500, size: 24),
            const SizedBox(height: AppSpacing.xs),
            AppText(
              label,
              variant: AppTextVariant.labelSmall,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendingSummary() {
    final percentUsed = _card.spentThisMonth / _card.spendLimit;

    return AppCard(
      variant: AppCardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            'Monthly Spending',
            variant: AppTextVariant.labelMedium,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                '\$${_card.spentThisMonth.toStringAsFixed(2)}',
                variant: AppTextVariant.headlineSmall,
                color: AppColors.textPrimary,
              ),
              AppText(
                'of \$${_card.spendLimit.toStringAsFixed(0)} limit',
                variant: AppTextVariant.bodyMedium,
                color: AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xs),
            child: LinearProgressIndicator(
              value: percentUsed.clamp(0.0, 1.0),
              backgroundColor: AppColors.borderSubtle,
              valueColor: AlwaysStoppedAnimation<Color>(
                percentUsed > 0.8 ? AppColors.errorBase : AppColors.gold500,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                '\$${(_card.spendLimit - _card.spentThisMonth).toStringAsFixed(2)} remaining',
                variant: AppTextVariant.bodySmall,
                color: AppColors.textTertiary,
              ),
              AppText(
                '${(percentUsed * 100).toStringAsFixed(0)}% used',
                variant: AppTextVariant.bodySmall,
                color: percentUsed > 0.8 ? AppColors.warningBase : AppColors.textTertiary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(_CardTransaction tx) {
    final isNegative = tx.amount < 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        variant: AppCardVariant.subtle,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.elevated,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                _getCategoryIcon(tx.category),
                color: AppColors.gold500,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    tx.merchant,
                    variant: AppTextVariant.labelMedium,
                    color: AppColors.textPrimary,
                  ),
                  AppText(
                    tx.category,
                    variant: AppTextVariant.bodySmall,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AppText(
                  '${isNegative ? '-' : '+'}\$${tx.amount.abs().toStringAsFixed(2)}',
                  variant: AppTextVariant.labelMedium,
                  color: isNegative ? AppColors.textPrimary : AppColors.successBase,
                ),
                AppText(
                  _formatDate(tx.date),
                  variant: AppTextVariant.bodySmall,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitsCard() {
    return AppCard(
      variant: AppCardVariant.subtle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.star, color: AppColors.gold500, size: 20),
              SizedBox(width: AppSpacing.sm),
              AppText(
                'Card Benefits',
                variant: AppTextVariant.labelMedium,
                color: AppColors.textPrimary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildBenefitItem(Icons.lock, 'Instant freeze & unfreeze'),
          _buildBenefitItem(Icons.notifications, 'Real-time transaction alerts'),
          _buildBenefitItem(Icons.percent, '1% cashback on all purchases'),
          _buildBenefitItem(Icons.shield, 'Zero liability fraud protection'),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, color: AppColors.successBase, size: 16),
          const SizedBox(width: AppSpacing.sm),
          AppText(
            text,
            variant: AppTextVariant.bodySmall,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'shopping':
        return Icons.shopping_bag;
      case 'transport':
        return Icons.directions_car;
      case 'entertainment':
        return Icons.movie;
      case 'food':
        return Icons.restaurant;
      default:
        return Icons.receipt;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  void _showAddFunds() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.slate,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppText(
              'Add Funds to Card',
              variant: AppTextVariant.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xxl),
            const AppInput(
              hint: '\$0.00',
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppButton(
              label: 'Add Funds',
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Funds added to card'),
                    backgroundColor: AppColors.successBase,
                  ),
                );
              },
              variant: AppButtonVariant.primary,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  void _toggleFreeze() {
    setState(() => _cardFrozen = !_cardFrozen);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_cardFrozen ? 'Card frozen' : 'Card unfrozen'),
        backgroundColor: _cardFrozen ? AppColors.infoBase : AppColors.successBase,
      ),
    );
  }

  void _copyCardDetails() {
    Clipboard.setData(ClipboardData(text: _card.fullCardNumber.replaceAll(' ', '')));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Card number copied'),
        backgroundColor: AppColors.successBase,
      ),
    );
  }

  void _showCardSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.slate,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              'Card Settings',
              variant: AppTextVariant.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xxl),
            _buildSettingItem(
              Icons.attach_money,
              'Spending Limit',
              '\$${_card.spendLimit.toStringAsFixed(0)}/month',
              () {},
            ),
            _buildSettingItem(
              Icons.notifications,
              'Transaction Alerts',
              'Enabled',
              () {},
            ),
            _buildSettingItem(
              Icons.language,
              'Online Payments',
              'Enabled',
              () {},
            ),
            _buildSettingItem(
              Icons.contactless,
              'Contactless Payments',
              'Enabled',
              () {},
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Report Lost/Stolen',
              onPressed: () {
                Navigator.pop(context);
              },
              variant: AppButtonVariant.secondary,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, String value, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.gold500),
      title: AppText(title, variant: AppTextVariant.labelMedium),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(value, variant: AppTextVariant.bodySmall, color: AppColors.textSecondary),
          const Icon(Icons.chevron_right, color: AppColors.textTertiary),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _VirtualCard {
  final String cardNumber;
  final String fullCardNumber;
  final String expiryDate;
  final String cvv;
  final String cardHolder;
  final double balance;
  final double spendLimit;
  final double spentThisMonth;

  _VirtualCard({
    required this.cardNumber,
    required this.fullCardNumber,
    required this.expiryDate,
    required this.cvv,
    required this.cardHolder,
    required this.balance,
    required this.spendLimit,
    required this.spentThisMonth,
  });
}

class _CardTransaction {
  final String merchant;
  final double amount;
  final DateTime date;
  final String category;

  _CardTransaction(this.merchant, this.amount, this.date, this.category);
}
