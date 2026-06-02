import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/domain/entities/transaction.dart';
import 'package:usdc_wallet/domain/enums/index.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/utils/formatters.dart';

/// A single transaction list item with icon, title, subtitle, and amount.
class TransactionListItem extends StatelessWidget {
  const TransactionListItem({super.key, required this.transaction, this.onTap});

  final Transaction transaction;
  final VoidCallback? onTap;

  IconData get _icon {
    switch (transaction.type) {
      case TransactionType.deposit:
        return Icons.arrow_downward_rounded;
      case TransactionType.withdrawal:
        return Icons.arrow_upward_rounded;
      case TransactionType.transferInternal:
        return Icons.swap_horiz_rounded;
      case TransactionType.transferExternal:
        return Icons.open_in_new_rounded;
    }
  }

  Color _iconColor(BuildContext context) {
    final colors = context.colors;
    if (transaction.isCredit) return colors.success;
    if (transaction.isDebit) return colors.error;
    return colors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final amountPrefix = transaction.isCredit ? '+' : '-';

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: _iconColor(context).withValues(alpha: 0.1),
        child: Icon(_icon, color: _iconColor(context), size: 20),
      ),
      title: AppText(
        _title(l10n),
        variant: AppTextVariant.labelLarge,
        color: colors.textPrimary,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: AppText(
        _subtitle(l10n),
        variant: AppTextVariant.bodySmall,
        color: colors.textSecondary,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: AmountText.fromText(
        '$amountPrefix${formatCurrency(transaction.amount.abs(), transaction.currency)}',
        currencyCode: transaction.currency,
        size: AmountTextSize.small,
        color: transaction.isCredit ? colors.success : colors.textPrimary,
        semanticLabel:
            '${transaction.isCredit ? l10n.transactions_transferReceived : l10n.transactions_transferSent} ${formatCurrency(transaction.amount.abs(), transaction.currency)}',
      ),
    );
  }

  String _title(AppLocalizations l10n) {
    final description = transaction.description?.trim();
    final typeLabel = _typeLabel(l10n);

    if (description != null &&
        description.isNotEmpty &&
        description.toLowerCase() != typeLabel.toLowerCase()) {
      return description;
    }

    return typeLabel;
  }

  String _subtitle(AppLocalizations l10n) {
    return '${_sourceLabel(l10n)} • ${formatDate(transaction.createdAt)}';
  }

  String _typeLabel(AppLocalizations l10n) {
    switch (transaction.type) {
      case TransactionType.deposit:
        return l10n.transactions_deposit;
      case TransactionType.withdrawal:
        return l10n.transactions_withdrawal;
      case TransactionType.transferInternal:
        return transaction.isCredit
            ? l10n.transactions_transferReceived
            : l10n.transactions_transferSent;
      case TransactionType.transferExternal:
        return l10n.transactions_transferSent;
    }
  }

  String _sourceLabel(AppLocalizations l10n) {
    switch (transaction.type) {
      case TransactionType.deposit:
        return l10n.transactions_mobileMoneyDeposit;
      case TransactionType.withdrawal:
        return l10n.transactions_mobileMoneyWithdrawal;
      case TransactionType.transferInternal:
        return transaction.isCredit
            ? l10n.transactions_fromKoridoUser
            : l10n.transactions_transferSent;
      case TransactionType.transferExternal:
        return l10n.transactions_externalWallet;
    }
  }
}
