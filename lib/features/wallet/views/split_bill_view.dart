import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';

class SplitBillView extends ConsumerStatefulWidget {
  const SplitBillView({super.key});

  @override
  ConsumerState<SplitBillView> createState() => _SplitBillViewState();
}

class _SplitBillViewState extends ConsumerState<SplitBillView> {
  final _totalController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<_Participant> _participants = [];
  bool _splitEqually = true;
  bool _includeMe = true;
  bool _isLoading = false;

  double get _totalAmount => double.tryParse(_totalController.text) ?? 0;
  int get _participantCount => _participants.length + (_includeMe ? 1 : 0);

  double get _myShare {
    if (!_includeMe) return 0;
    if (_splitEqually && _participantCount > 0) {
      return _totalAmount / _participantCount;
    }
    return _totalAmount - _participants.fold(0.0, (sum, p) => sum + p.amount);
  }

  @override
  void dispose() {
    _totalController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          l10n.services_splitBills,
          variant: AppTextVariant.titleLarge,
          color: colors.textPrimary,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              'Total Bill Amount',
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildAmountInput(colors),
            const SizedBox(height: AppSpacing.xl),
            AppInput(
              controller: _descriptionController,
              hint: 'e.g., Dinner at Restaurant',
              label: 'What\'s this for?',
              prefixIcon: Icons.receipt,
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildSplitOptions(colors),
            const SizedBox(height: AppSpacing.xl),
            _buildParticipantsHeader(l10n, colors),
            const SizedBox(height: AppSpacing.md),
            if (_includeMe) _buildMyShare(colors),
            ..._participants.asMap().entries.map((entry) =>
              _buildParticipantCard(entry.key, entry.value, colors)
            ),
            if (_participants.isEmpty && !_includeMe)
              _buildEmptyState(colors),
            const SizedBox(height: AppSpacing.xl),
            if (_totalAmount > 0 && _participantCount > 0)
              _buildSummary(colors),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: _isLoading ? 'Sending...' : 'Send Payment Requests',
              onPressed: _canSend() ? _sendRequests : null,
              variant: AppButtonVariant.primary,
              isFullWidth: true,
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildPendingSplits(colors),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInput(ThemeColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.charcoal,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(color: context.colors.borderSubtle),
      ),
      child: Row(
        children: [
          AppText(
            '\$',
            variant: AppTextVariant.headlineMedium,
            color: colors.textTertiary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: AppInput(
              controller: _totalController,
              variant: AppInputVariant.amount,
              hint: '0.00',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplitOptions(ThemeColors colors) {
    return AppCard(
      variant: AppCardVariant.subtle,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _splitEqually = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: _splitEqually ? context.colors.gold : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.view_module,
                          color: _splitEqually ? context.colors.canvas : colors.textSecondary,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        AppText(
                          'Split Equally',
                          variant: AppTextVariant.labelSmall,
                          color: _splitEqually ? context.colors.canvas : colors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _splitEqually = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: !_splitEqually ? context.colors.gold : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.tune,
                          color: !_splitEqually ? context.colors.canvas : colors.textSecondary,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        AppText(
                          'Custom Amounts',
                          variant: AppTextVariant.labelSmall,
                          color: !_splitEqually ? context.colors.canvas : colors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(color: context.colors.borderSubtle),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                'Include myself in the split',
                variant: AppTextVariant.bodyMedium,
                color: colors.textPrimary,
              ),
              Switch(
                value: _includeMe,
                onChanged: (value) => setState(() => _includeMe = value),
                activeColor: context.colors.gold,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsHeader(AppLocalizations l10n, ThemeColors colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          'Split With',
          variant: AppTextVariant.titleMedium,
          color: colors.textPrimary,
        ),
        TextButton.icon(
          onPressed: () => _addParticipant(l10n, colors),
          icon: Icon(Icons.add, color: context.colors.gold, size: 20),
          label: AppText(
            'Add Person',
            variant: AppTextVariant.labelMedium,
            color: context.colors.gold,
          ),
        ),
      ],
    );
  }

  Widget _buildMyShare(ThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        variant: AppCardVariant.subtle,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [context.colors.gold, context.colors.gold.withValues(alpha: 0.8)],
                ),
                borderRadius: BorderRadius.circular(AppSpacing.xxl),
              ),
              child: Icon(Icons.person, color: context.colors.canvas),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    'You',
                    variant: AppTextVariant.labelLarge,
                    color: colors.textPrimary,
                  ),
                  AppText(
                    'Your share',
                    variant: AppTextVariant.bodySmall,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ),
            AppText(
              '\$${_myShare.toStringAsFixed(2)}',
              variant: AppTextVariant.titleMedium,
              color: context.colors.gold,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantCard(int index, _Participant participant, ThemeColors colors) {
    final share = _splitEqually && _participantCount > 0
        ? _totalAmount / _participantCount
        : participant.amount;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Dismissible(
        key: Key(participant.phone),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: AppSpacing.md),
          decoration: BoxDecoration(
            color: context.colors.error,
            borderRadius: BorderRadius.circular(AppSpacing.md),
          ),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (_) {
          setState(() => _participants.removeAt(index));
        },
        child: AppCard(
          variant: AppCardVariant.subtle,
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: context.colors.elevated,
                  borderRadius: BorderRadius.circular(AppSpacing.xxl),
                ),
                child: Center(
                  child: AppText(
                    participant.name[0].toUpperCase(),
                    variant: AppTextVariant.titleMedium,
                    color: context.colors.gold,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      participant.name,
                      variant: AppTextVariant.labelLarge,
                      color: colors.textPrimary,
                    ),
                    AppText(
                      participant.phone,
                      variant: AppTextVariant.bodySmall,
                      color: colors.textSecondary,
                    ),
                  ],
                ),
              ),
              if (!_splitEqually)
                SizedBox(
                  width: 100,
                  child: AppInput(
                    variant: AppInputVariant.amount,
                    hint: '0.00',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      setState(() {
                        participant.amount = double.tryParse(value) ?? 0;
                      });
                    },
                  ),
                )
              else
                AppText(
                  '\$${share.toStringAsFixed(2)}',
                  variant: AppTextVariant.titleMedium,
                  color: colors.textPrimary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Icon(
              Icons.group_add,
              color: colors.textTertiary,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.md),
            AppText(
              'Add people to split with',
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(ThemeColors colors) {
    final totalAssigned = _participants.fold(0.0, (sum, p) {
      final share = _splitEqually ? _totalAmount / _participantCount : p.amount;
      return sum + share;
    }) + _myShare;

    final remaining = _totalAmount - totalAssigned;

    return AppCard(
      variant: AppCardVariant.elevated,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                'Total Bill',
                variant: AppTextVariant.bodyMedium,
                color: colors.textSecondary,
              ),
              AppText(
                '\$${_totalAmount.toStringAsFixed(2)}',
                variant: AppTextVariant.labelLarge,
                color: colors.textPrimary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                'Split among',
                variant: AppTextVariant.bodyMedium,
                color: colors.textSecondary,
              ),
              AppText(
                '$_participantCount people',
                variant: AppTextVariant.labelLarge,
                color: colors.textPrimary,
              ),
            ],
          ),
          if (!_splitEqually && remaining.abs() > 0.01) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  remaining > 0 ? 'Unassigned' : 'Over-assigned',
                  variant: AppTextVariant.bodyMedium,
                  color: remaining > 0 ? AppColors.warningBase : context.colors.error,
                ),
                AppText(
                  '\$${remaining.abs().toStringAsFixed(2)}',
                  variant: AppTextVariant.labelLarge,
                  color: remaining > 0 ? AppColors.warningBase : context.colors.error,
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Divider(color: context.colors.borderSubtle),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                'Requesting from others',
                variant: AppTextVariant.labelMedium,
                color: colors.textPrimary,
              ),
              AppText(
                '\$${(_totalAmount - _myShare).toStringAsFixed(2)}',
                variant: AppTextVariant.titleMedium,
                color: context.colors.gold,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPendingSplits(ThemeColors colors) {
    final pendingSplits = [
      _PendingSplit('Dinner', 120.00, 4, 2, DateTime.now().subtract(const Duration(days: 2))),
      _PendingSplit('Movie Night', 45.00, 3, 3, DateTime.now().subtract(const Duration(days: 5))),
    ];

    if (pendingSplits.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'Pending Splits',
          variant: AppTextVariant.titleMedium,
          color: colors.textPrimary,
        ),
        const SizedBox(height: AppSpacing.md),
        ...pendingSplits.map((split) => _buildPendingSplitItem(split, colors)),
      ],
    );
  }

  Widget _buildPendingSplitItem(_PendingSplit split, ThemeColors colors) {
    final isPaid = split.paidCount == split.totalCount;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        variant: AppCardVariant.subtle,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isPaid
                    ? context.colors.success.withValues(alpha: 0.1)
                    : AppColors.warningBase.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
              child: Icon(
                isPaid ? Icons.check_circle : Icons.pending,
                color: isPaid ? context.colors.success : AppColors.warningBase,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    split.description,
                    variant: AppTextVariant.labelMedium,
                    color: colors.textPrimary,
                  ),
                  AppText(
                    '${split.paidCount}/${split.totalCount} paid',
                    variant: AppTextVariant.bodySmall,
                    color: isPaid ? context.colors.success : colors.textSecondary,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AppText(
                  '\$${split.amount.toStringAsFixed(2)}',
                  variant: AppTextVariant.labelMedium,
                  color: colors.textPrimary,
                ),
                AppText(
                  _formatDate(split.date),
                  variant: AppTextVariant.bodySmall,
                  color: colors.textTertiary,
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(Icons.chevron_right, color: colors.textTertiary),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}';
  }

  void _addParticipant(AppLocalizations l10n, ThemeColors colors) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.charcoal,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.lg)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              'Add Person',
              variant: AppTextVariant.titleMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppInput(
              controller: nameController,
              hint: 'Enter name',
              label: 'Name',
              prefixIcon: Icons.person,
            ),
            const SizedBox(height: AppSpacing.md),
            AppInput(
              controller: phoneController,
              hint: 'Enter phone number',
              label: 'Phone Number',
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Add',
              onPressed: () {
                if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                  setState(() {
                    _participants.add(_Participant(
                      name: nameController.text,
                      phone: phoneController.text,
                      amount: 0,
                    ));
                  });
                  Navigator.pop(context);
                }
              },
              variant: AppButtonVariant.primary,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  bool _canSend() {
    return _totalAmount > 0 &&
           _participants.isNotEmpty &&
           _descriptionController.text.isNotEmpty;
  }

  Future<void> _sendRequests() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment requests sent to ${_participants.length} people'),
          backgroundColor: context.colors.success,
        ),
      );

      setState(() {
        _totalController.clear();
        _descriptionController.clear();
        _participants.clear();
      });
    }
  }
}

class _Participant {
  final String name;
  final String phone;
  double amount;

  _Participant({
    required this.name,
    required this.phone,
    required this.amount,
  });
}

class _PendingSplit {
  final String description;
  final double amount;
  final int totalCount;
  final int paidCount;
  final DateTime date;

  _PendingSplit(this.description, this.amount, this.totalCount, this.paidCount, this.date);
}
