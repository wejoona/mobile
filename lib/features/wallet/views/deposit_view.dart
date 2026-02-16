import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/core/l10n/app_strings.dart';
import 'package:usdc_wallet/router/navigation_extensions.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/domain/entities/index.dart';
import 'package:usdc_wallet/state/index.dart';
import 'package:usdc_wallet/features/wallet/providers/wallet_provider.dart';

/// Payment method universe/category
enum PaymentUniverse {
  mobileMoney,
  bankTransfer,
  card,
  crypto,
}

extension PaymentUniverseExt on PaymentUniverse {
  String get label {
    switch (this) {
      case PaymentUniverse.mobileMoney:
        return 'Mobile Money';
      case PaymentUniverse.bankTransfer:
        return 'Bank Transfer';
      case PaymentUniverse.card:
        return 'Credit/Debit Card';
      case PaymentUniverse.crypto:
        return 'Crypto';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentUniverse.mobileMoney:
        return Icons.phone_android;
      case PaymentUniverse.bankTransfer:
        return Icons.account_balance;
      case PaymentUniverse.card:
        return Icons.credit_card;
      case PaymentUniverse.crypto:
        return Icons.currency_bitcoin;
    }
  }

  Color get color {
    switch (this) {
      case PaymentUniverse.mobileMoney:
        return const Color(0xFFFF6B00);
      case PaymentUniverse.bankTransfer:
        return const Color(0xFF2196F3);
      case PaymentUniverse.card:
        return const Color(0xFF9C27B0);
      case PaymentUniverse.crypto:
        return const Color(0xFFF7931A);
    }
  }
}

class DepositView extends ConsumerStatefulWidget {
  const DepositView({super.key});

  @override
  ConsumerState<DepositView> createState() => _DepositViewState();
}

class _DepositViewState extends ConsumerState<DepositView> {
  final _amountController = TextEditingController();
  String _selectedCurrency = 'XOF';
  String? _selectedChannelId;
  PaymentUniverse? _expandedUniverse;

  // Validation state
  String? _amountError;
  double _minAmount = 500;
  double _maxAmount = 5000000;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final channelsAsync = ref.watch(depositChannelsProvider(_selectedCurrency));
    final depositState = ref.watch(depositProvider);

    ref.listen(depositProvider, (prev, next) {
      if (next.response != null) {
        // Refresh wallet and transactions via FSM after deposit initiated
        ref.read(walletStateMachineProvider.notifier).refresh();
        ref.read(transactionStateMachineProvider.notifier).refresh();
        context.push('/deposit/instructions', extra: next.response);
      } else if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: context.colors.error,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const AppText(
          AppStrings.depositFunds,
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.safePop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount Input Card
            _buildAmountCard(colors),

            const SizedBox(height: AppSpacing.xxl),

            // Payment Methods by Universe
            AppText(
              AppStrings.selectPaymentMethod,
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.md),

            channelsAsync.when(
              data: (channels) => _buildGroupedChannels(channels, colors),
              loading: () => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: CircularProgressIndicator(color: colors.gold),
                ),
              ),
              error: (err, _) => Center(
                child: AppText(
                  err.toString(),
                  variant: AppTextVariant.bodyMedium,
                  color: context.colors.errorText,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            // Continue Button
            AppButton(
              label: AppStrings.continueLabel,
              onPressed: _canSubmit() ? () => _submit() : null,
              variant: AppButtonVariant.primary,
              isFullWidth: true,
              isLoading: depositState.isLoading,
            ),

            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard(ThemeColors colors) {
    return AppCard(
      variant: AppCardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            AppStrings.amountToDeposit,
            variant: AppTextVariant.cardLabel,
            color: colors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Currency selector
              GestureDetector(
                onTap: () => _showCurrencyPicker(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: colors.elevated,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    children: [
                      AppText(
                        _selectedCurrency,
                        variant: AppTextVariant.titleMedium,
                        color: colors.textPrimary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: colors.textTertiary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Amount input
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AppInput(
                      controller: _amountController,
                      variant: AppInputVariant.amount,
                      hint: '0.00',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      error: _amountError,
                      onChanged: (_) => _validateAmount(),
                    ),
                    if (_amountError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: AppText(
                          _amountError!,
                          variant: AppTextVariant.bodySmall,
                          color: context.colors.error,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          // Amount hints
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              AppText(
                'Min: ${_formatAmount(_minAmount)}',
                variant: AppTextVariant.bodySmall,
                color: colors.textTertiary,
              ),
              const Spacer(),
              AppText(
                'Max: ${_formatAmount(_maxAmount)}',
                variant: AppTextVariant.bodySmall,
                color: colors.textTertiary,
              ),
            ],
          ),

          // Quick amount buttons
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _QuickAmountButton(
                amount: 5000,
                currency: _selectedCurrency,
                onTap: () => _setAmount(5000),
                colors: colors,
              ),
              const SizedBox(width: AppSpacing.sm),
              _QuickAmountButton(
                amount: 10000,
                currency: _selectedCurrency,
                onTap: () => _setAmount(10000),
                colors: colors,
              ),
              const SizedBox(width: AppSpacing.sm),
              _QuickAmountButton(
                amount: 25000,
                currency: _selectedCurrency,
                onTap: () => _setAmount(25000),
                colors: colors,
              ),
              const SizedBox(width: AppSpacing.sm),
              _QuickAmountButton(
                amount: 50000,
                currency: _selectedCurrency,
                onTap: () => _setAmount(50000),
                colors: colors,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedChannels(List<DepositChannel> channels, ThemeColors colors) {
    // Group channels by type/universe
    final grouped = <PaymentUniverse, List<DepositChannel>>{};

    for (final channel in channels) {
      final universe = _getUniverse(channel.type);
      grouped.putIfAbsent(universe, () => []).add(channel);
    }

    // If no channels, show mock data for demo
    if (grouped.isEmpty) {
      grouped[PaymentUniverse.mobileMoney] = [];
      grouped[PaymentUniverse.bankTransfer] = [];
      grouped[PaymentUniverse.card] = [];
    }

    return Column(
      children: PaymentUniverse.values.map((universe) {
        final universeChannels = grouped[universe] ?? [];
        final isExpanded = _expandedUniverse == universe;

        return _PaymentUniverseSection(
          universe: universe,
          channels: universeChannels,
          isExpanded: isExpanded,
          selectedChannelId: _selectedChannelId,
          colors: colors,
          onToggle: () {
            setState(() {
              _expandedUniverse = isExpanded ? null : universe;
            });
          },
          onChannelSelected: (channelId) {
            setState(() {
              _selectedChannelId = channelId;
            });
          },
        );
      }).toList(),
    );
  }

  PaymentUniverse _getUniverse(String type) {
    switch (type.toLowerCase()) {
      case 'mobile_money':
      case 'momo':
      case 'orange_money':
      case 'mtn_momo':
      case 'wave':
        return PaymentUniverse.mobileMoney;
      case 'bank_transfer':
      case 'bank':
        return PaymentUniverse.bankTransfer;
      case 'card':
      case 'visa':
      case 'mastercard':
        return PaymentUniverse.card;
      case 'crypto':
      case 'usdc':
      case 'usdt':
        return PaymentUniverse.crypto;
      default:
        return PaymentUniverse.mobileMoney;
    }
  }

  void _validateAmount() {
    final amount = double.tryParse(_amountController.text) ?? 0;

    setState(() {
      if (_amountController.text.isEmpty) {
        _amountError = null;
      } else if (amount < _minAmount) {
        _amountError = 'Minimum amount is ${_formatAmount(_minAmount)}';
      } else if (amount > _maxAmount) {
        _amountError = 'Maximum amount is ${_formatAmount(_maxAmount)}';
      } else {
        _amountError = null;
      }
    });
  }

  void _setAmount(double amount) {
    _amountController.text = amount.toStringAsFixed(0);
    _validateAmount();
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M $_selectedCurrency';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K $_selectedCurrency';
    }
    return '${amount.toStringAsFixed(0)} $_selectedCurrency';
  }

  bool _canSubmit() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    return amount >= _minAmount &&
        amount <= _maxAmount &&
        _selectedChannelId != null &&
        _amountError == null;
  }

  void _submit() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    ref.read(depositProvider.notifier).initiateDeposit(
          amount: amount,
          sourceCurrency: _selectedCurrency,
          channelId: _selectedChannelId!,
        );
  }

  void _showCurrencyPicker() {
    final currencies = [
      ('XOF', 'CFA Franc', 'CI, SN, ML...'),
      ('NGN', 'Nigerian Naira', 'Nigeria'),
      ('GHS', 'Ghanaian Cedi', 'Ghana'),
    ];

    final colors = context.colors;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.container,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.lg),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.textTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          const AppText(
            'Select Currency',
            variant: AppTextVariant.titleMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          ...currencies.map((c) => ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.elevated,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Center(
                    child: AppText(
                      c.$1.substring(0, 2),
                      variant: AppTextVariant.labelMedium,
                      color: colors.gold,
                    ),
                  ),
                ),
                title: AppText(c.$2, variant: AppTextVariant.bodyLarge),
                subtitle: AppText(
                  c.$3,
                  variant: AppTextVariant.bodySmall,
                  color: colors.textTertiary,
                ),
                trailing: _selectedCurrency == c.$1
                    ? Icon(Icons.check, color: colors.gold)
                    : null,
                onTap: () {
                  setState(() {
                    _selectedCurrency = c.$1;
                    _selectedChannelId = null;
                    _updateLimitsForCurrency(c.$1);
                  });
                  Navigator.pop(context);
                },
              )),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  void _updateLimitsForCurrency(String currency) {
    switch (currency) {
      case 'XOF':
        _minAmount = 500;
        _maxAmount = 5000000;
        break;
      case 'NGN':
        _minAmount = 1000;
        _maxAmount = 10000000;
        break;
      case 'GHS':
        _minAmount = 10;
        _maxAmount = 50000;
        break;
    }
    _validateAmount();
  }
}

class _QuickAmountButton extends StatelessWidget {
  const _QuickAmountButton({
    required this.amount,
    required this.currency,
    required this.onTap,
    required this.colors,
  });

  final double amount;
  final String currency;
  final VoidCallback onTap;
  final ThemeColors colors;

  @override
  Widget build(BuildContext context) {
    String label;
    if (amount >= 1000) {
      label = '${(amount / 1000).toStringAsFixed(0)}K';
    } else {
      label = amount.toStringAsFixed(0);
    }

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: colors.elevated,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: colors.borderSubtle),
          ),
          child: Center(
            child: AppText(
              label,
              variant: AppTextVariant.labelMedium,
              color: colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentUniverseSection extends StatelessWidget {
  const _PaymentUniverseSection({
    required this.universe,
    required this.channels,
    required this.isExpanded,
    required this.selectedChannelId,
    required this.colors,
    required this.onToggle,
    required this.onChannelSelected,
  });

  final PaymentUniverse universe;
  final List<DepositChannel> channels;
  final bool isExpanded;
  final String? selectedChannelId;
  final ThemeColors colors;
  final VoidCallback onToggle;
  final ValueChanged<String> onChannelSelected;

  @override
  Widget build(BuildContext context) {
    final hasSelectedInUniverse =
        channels.any((c) => c.id == selectedChannelId);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.container,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: hasSelectedInUniverse
              ? colors.gold
              : colors.borderSubtle,
          width: hasSelectedInUniverse ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: universe.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      universe.icon,
                      color: universe.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          universe.label,
                          variant: AppTextVariant.bodyLarge,
                          color: colors.textPrimary,
                        ),
                        AppText(
                          _getProvidersList(),
                          variant: AppTextVariant.bodySmall,
                          color: colors.textTertiary,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: colors.textTertiary,
                  ),
                ],
              ),
            ),
          ),

          // Expanded channels
          if (isExpanded) ...[
            Divider(color: colors.borderSubtle, height: 1),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: channels.isEmpty
                  ? _buildMockChannels()
                  : Column(
                      children: channels
                          .map((channel) => _ChannelOption(
                                channel: channel,
                                isSelected: selectedChannelId == channel.id,
                                onTap: () => onChannelSelected(channel.id),
                                colors: colors,
                              ))
                          .toList(),
                    ),
            ),
          ],
        ],
      ),
    );
  }

  String _getProvidersList() {
    if (channels.isEmpty) {
      switch (universe) {
        case PaymentUniverse.mobileMoney:
          return 'Orange Money, MTN, Wave';
        case PaymentUniverse.bankTransfer:
          return 'Local bank transfers';
        case PaymentUniverse.card:
          return 'Visa, Mastercard';
        case PaymentUniverse.crypto:
          return 'USDC';
      }
    }
    return channels.map((c) => c.provider).take(3).join(', ');
  }

  Widget _buildMockChannels() {
    // Mock channels for demo
    final mockChannels = <Map<String, dynamic>>[];

    switch (universe) {
      case PaymentUniverse.mobileMoney:
        mockChannels.addAll([
          {'id': 'om_ci', 'name': 'Orange Money', 'fee': '1.5%'},
          {'id': 'mtn_ci', 'name': 'MTN Mobile Money', 'fee': '1.5%'},
          {'id': 'wave_ci', 'name': 'Wave', 'fee': '0%'},
        ]);
        break;
      case PaymentUniverse.bankTransfer:
        mockChannels.addAll([
          {'id': 'bank_ci', 'name': 'Bank Transfer', 'fee': '0%'},
        ]);
        break;
      case PaymentUniverse.card:
        mockChannels.addAll([
          {'id': 'card_visa', 'name': 'Visa/Mastercard', 'fee': '2.9%'},
        ]);
        break;
      case PaymentUniverse.crypto:
        mockChannels.addAll([
          {'id': 'crypto_usdc', 'name': 'USDC', 'fee': '0%'},
        ]);
        break;
    }

    return Column(
      children: mockChannels
          .map((m) => _MockChannelOption(
                id: m['id'] as String,
                name: m['name'] as String,
                fee: m['fee'] as String,
                isSelected: selectedChannelId == m['id'],
                onTap: () => onChannelSelected(m['id'] as String),
                colors: colors,
              ))
          .toList(),
    );
  }
}

class _ChannelOption extends StatelessWidget {
  const _ChannelOption({
    required this.channel,
    required this.isSelected,
    required this.onTap,
    required this.colors,
  });

  final DepositChannel channel;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? colors.gold.withValues(alpha: 0.1) : colors.elevated,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? colors.gold : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: AppText(
                channel.name,
                variant: AppTextVariant.bodyMedium,
                color: colors.textPrimary,
              ),
            ),
            AppText(
              '${channel.fee}% fee',
              variant: AppTextVariant.bodySmall,
              color: colors.textTertiary,
            ),
            if (isSelected) ...[
              const SizedBox(width: AppSpacing.sm),
              Icon(Icons.check_circle, color: colors.gold, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}

class _MockChannelOption extends StatelessWidget {
  const _MockChannelOption({
    required this.id,
    required this.name,
    required this.fee,
    required this.isSelected,
    required this.onTap,
    required this.colors,
  });

  final String id;
  final String name;
  final String fee;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? colors.gold.withValues(alpha: 0.1) : colors.elevated,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? colors.gold : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: AppText(
                name,
                variant: AppTextVariant.bodyMedium,
                color: colors.textPrimary,
              ),
            ),
            AppText(
              '$fee fee',
              variant: AppTextVariant.bodySmall,
              color: colors.textTertiary,
            ),
            if (isSelected) ...[
              const SizedBox(width: AppSpacing.sm),
              Icon(Icons.check_circle, color: colors.gold, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}
