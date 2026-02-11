import 'package:usdc_wallet/design/components/primitives/bottom_sheet_handle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/domain/entities/transaction_filter.dart';

/// Run 346: Transaction filter bottom sheet view
class TransactionFilterView extends ConsumerStatefulWidget {
  final TransactionFilter? initialFilter;
  final ValueChanged<TransactionFilter> onApply;

  const TransactionFilterView({
    super.key,
    this.initialFilter,
    required this.onApply,
  });

  @override
  ConsumerState<TransactionFilterView> createState() =>
      _TransactionFilterViewState();
}

class _TransactionFilterViewState extends ConsumerState<TransactionFilterView> {
  late TransactionFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter ?? const TransactionFilter();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: BottomSheetHandle()),
          const SizedBox(height: AppSpacing.lg),
          const AppText(
            'Filtrer les transactions',
            style: AppTextStyle.headingSmall,
          ),
          const SizedBox(height: AppSpacing.xxl),
          // Type filter
          const AppText('Type', style: AppTextStyle.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              _FilterChip(
                label: 'Tout',
                selected: _filter.type == null,
                onSelected: () => setState(() => _filter = _filter.copyWith(clearType: true)),
              ),
              _FilterChip(
                label: 'Envoi',
                selected: _filter.type == 'send',
                onSelected: () => setState(() => _filter = _filter.copyWith(type: 'send')),
              ),
              _FilterChip(
                label: 'Reception',
                selected: _filter.type == 'receive',
                onSelected: () => setState(() => _filter = _filter.copyWith(type: 'receive')),
              ),
              _FilterChip(
                label: 'Depot',
                selected: _filter.type == 'deposit',
                onSelected: () => setState(() => _filter = _filter.copyWith(type: 'deposit')),
              ),
              _FilterChip(
                label: 'Retrait',
                selected: _filter.type == 'withdraw',
                onSelected: () => setState(() => _filter = _filter.copyWith(type: 'withdraw')),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          // Status filter
          const AppText('Statut', style: AppTextStyle.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              _FilterChip(
                label: 'Tout',
                selected: _filter.status == null,
                onSelected: () => setState(() => _filter = _filter.copyWith(clearStatus: true)),
              ),
              _FilterChip(
                label: 'Complete',
                selected: _filter.status == 'completed',
                onSelected: () => setState(() => _filter = _filter.copyWith(status: 'completed')),
              ),
              _FilterChip(
                label: 'En attente',
                selected: _filter.status == 'pending',
                onSelected: () => setState(() => _filter = _filter.copyWith(status: 'pending')),
              ),
              _FilterChip(
                label: 'Echoue',
                selected: _filter.status == 'failed',
                onSelected: () => setState(() => _filter = _filter.copyWith(status: 'failed')),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxxl),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Reinitialiser',
                  variant: AppButtonVariant.ghost,
                  onPressed: () => setState(() => _filter = const TransactionFilter()),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppButton(
                  label: 'Appliquer',
                  variant: AppButtonVariant.primary,
                  onPressed: () {
                    widget.onApply(_filter);
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label ${selected ? "selectionne" : ""}',
      child: GestureDetector(
        onTap: onSelected,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: selected ? AppColors.gold.withOpacity(0.15) : AppColors.elevated,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.gold : Colors.transparent,
            ),
          ),
          child: AppText(
            label,
            style: AppTextStyle.labelMedium,
            color: selected ? AppColors.gold : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
