import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:confetti/confetti.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../providers/savings_pots_provider.dart';
import '../models/pot_transaction.dart';
import '../widgets/add_to_pot_sheet.dart';
import '../widgets/withdraw_from_pot_sheet.dart';

/// Detail view for a single savings pot
class PotDetailView extends ConsumerStatefulWidget {
  const PotDetailView({super.key, required this.potId});

  final String potId;

  @override
  ConsumerState<PotDetailView> createState() => _PotDetailViewState();
}

class _PotDetailViewState extends ConsumerState<PotDetailView> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(savingsPotsProvider);
    final pot = state.selectedPot;

    if (pot == null) {
      return Scaffold(
        backgroundColor: AppColors.obsidian,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Show confetti if goal reached
    if (pot.isGoalReached && !_confettiController.state.toString().contains('playing')) {
      _confettiController.play();
    }

    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/savings-pots/edit/${pot.id}'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(l10n, pot.id),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.all(AppSpacing.md),
            children: [
              // Header with emoji and progress
              _buildHeader(pot, currencyFormat, l10n),
              SizedBox(height: AppSpacing.xl),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: l10n.savingsPots_addMoney,
                      onPressed: () => _showAddMoneySheet(context, l10n, pot.id),
                      variant: AppButtonVariant.primary,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton(
                      label: l10n.savingsPots_withdraw,
                      onPressed: () => _showWithdrawSheet(context, l10n, pot.id),
                      variant: AppButtonVariant.secondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.xl),

              // Transaction history
              _buildTransactionHistory(state, currencyFormat, l10n),
            ],
          ),

          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(dynamic pot, NumberFormat currencyFormat, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            pot.color.withOpacity(0.2),
            pot.color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          // Emoji with progress ring
          if (pot.targetAmount != null)
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: pot.progress,
                      strokeWidth: 6,
                      backgroundColor: pot.color.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(pot.color),
                    ),
                  ),
                  Text(
                    pot.emoji,
                    style: const TextStyle(fontSize: 56),
                  ),
                ],
              ),
            )
          else
            Text(
              pot.emoji,
              style: const TextStyle(fontSize: 80),
            ),
          SizedBox(height: AppSpacing.md),

          // Pot name
          AppText(
            pot.name,
            variant: AppTextVariant.headlineMedium,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.sm),

          // Current amount
          AppText(
            currencyFormat.format(pot.currentAmount),
            variant: AppTextVariant.displayMedium,
            color: pot.color,
            fontWeight: FontWeight.bold,
          ),

          // Goal progress
          if (pot.targetAmount != null) ...[
            SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: LinearProgressIndicator(
                value: pot.progress,
                minHeight: 8,
                backgroundColor: pot.color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(pot.color),
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            AppText(
              '${currencyFormat.format(pot.currentAmount)} of ${currencyFormat.format(pot.targetAmount)} (${(pot.progress! * 100).toStringAsFixed(0)}%)',
              variant: AppTextVariant.bodyMedium,
              color: AppColors.textSecondary,
            ),
            if (pot.isGoalReached)
              Padding(
                padding: EdgeInsets.only(top: AppSpacing.sm),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successBase.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.celebration, color: AppColors.successBase, size: 20),
                      SizedBox(width: AppSpacing.xs),
                      AppText(
                        l10n.savingsPots_goalReached,
                        variant: AppTextVariant.bodyMedium,
                        color: AppColors.successBase,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildTransactionHistory(
    SavingsPotsState state,
    NumberFormat currencyFormat,
    AppLocalizations l10n,
  ) {
    final transactions = state.selectedPotTransactions ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          l10n.savingsPots_transactionHistory,
          variant: AppTextVariant.headlineSmall,
        ),
        SizedBox(height: AppSpacing.md),
        if (transactions.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: AppText(
                l10n.savingsPots_noTransactions,
                variant: AppTextVariant.bodyMedium,
                color: AppColors.textSecondary,
              ),
            ),
          )
        else
          ...transactions.map((transaction) => _buildTransactionItem(
                transaction,
                currencyFormat,
                l10n,
              )),
      ],
    );
  }

  Widget _buildTransactionItem(
    PotTransaction transaction,
    NumberFormat currencyFormat,
    AppLocalizations l10n,
  ) {
    final isDeposit = transaction.type == PotTransactionType.deposit;
    final dateFormat = DateFormat.yMMMd();

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.slate,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (isDeposit ? AppColors.successBase : AppColors.warningBase)
                  .withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDeposit ? Icons.add : Icons.remove,
              color: isDeposit ? AppColors.successBase : AppColors.warningBase,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  isDeposit ? l10n.savingsPots_deposit : l10n.savingsPots_withdrawal,
                  variant: AppTextVariant.bodyMedium,
                  fontWeight: FontWeight.w600,
                ),
                AppText(
                  dateFormat.format(transaction.timestamp),
                  variant: AppTextVariant.bodySmall,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          AppText(
            '${isDeposit ? '+' : '-'}${currencyFormat.format(transaction.amount)}',
            variant: AppTextVariant.bodyLarge,
            color: isDeposit ? AppColors.successBase : AppColors.warningBase,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }

  Future<void> _showAddMoneySheet(BuildContext context, AppLocalizations l10n, String potId) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.slate,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) => AddToPotSheet(potId: potId),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.savingsPots_addSuccess),
          backgroundColor: AppColors.successBase,
        ),
      );
    }
  }

  Future<void> _showWithdrawSheet(BuildContext context, AppLocalizations l10n, String potId) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.slate,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) => WithdrawFromPotSheet(potId: potId),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.savingsPots_withdrawSuccess),
          backgroundColor: AppColors.successBase,
        ),
      );
    }
  }

  Future<void> _confirmDelete(AppLocalizations l10n, String potId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.slate,
        title: AppText(l10n.savingsPots_deleteTitle),
        content: AppText(l10n.savingsPots_deleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: AppText(l10n.action_cancel),
          ),
          AppButton(
            label: l10n.action_delete,
            onPressed: () => Navigator.pop(context, true),
            variant: AppButtonVariant.danger,
            size: AppButtonSize.small,
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await ref.read(savingsPotsProvider.notifier).deletePot(potId);
      if (success && mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.savingsPots_deleteSuccess),
            backgroundColor: AppColors.successBase,
          ),
        );
      }
    }
  }
}
