import 'package:flutter/material.dart';
import '../../../design/tokens/index.dart';
import '../../../domain/enums/index.dart';

/// Filter chip row for transactions.
class TransactionFilterChips extends StatelessWidget {
  const TransactionFilterChips({
    super.key,
    this.selectedType,
    this.selectedStatus,
    required this.onTypeChanged,
    required this.onStatusChanged,
  });

  final TransactionType? selectedType;
  final TransactionStatus? selectedStatus;
  final ValueChanged<TransactionType?> onTypeChanged;
  final ValueChanged<TransactionStatus?> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          _buildChip(
            context,
            label: 'All',
            isSelected: selectedType == null,
            onTap: () => onTypeChanged(null),
          ),
          const SizedBox(width: 8),
          ...TransactionType.values.map((type) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: _buildChip(
                context,
                label: type.name,
                isSelected: selectedType == type,
                onTap: () => onTypeChanged(type),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? colors.primary : colors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
