import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/action_chip_row.dart';
import 'package:usdc_wallet/domain/entities/transaction_filter.dart';

/// Filter bar for transaction list.
class TransactionFilterBar extends StatelessWidget {
  final TransactionFilter filter;
  final ValueChanged<TransactionFilter> onFilterChanged;

  const TransactionFilterBar({super.key, required this.filter, required this.onFilterChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ActionChipRow(
          selected: filter.type,
          onSelected: (type) {
            if (type == filter.type) {
              onFilterChanged(filter.copyWith(clearType: true));
            } else {
              onFilterChanged(filter.copyWith(type: type));
            }
          },
          items: const [
            ChipItem(id: 'deposit', label: 'Deposits', icon: Icons.arrow_downward_rounded),
            ChipItem(id: 'withdrawal', label: 'Withdrawals', icon: Icons.arrow_upward_rounded),
            ChipItem(id: 'transferInternal', label: 'Transfers', icon: Icons.swap_horiz_rounded),
            ChipItem(id: 'bill_payment', label: 'Bills', icon: Icons.receipt_long_rounded),
          ],
        ),
      ],
    );
  }
}
