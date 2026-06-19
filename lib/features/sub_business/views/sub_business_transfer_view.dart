import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/sub_business/models/sub_business.dart';
import 'package:usdc_wallet/features/sub_business/providers/sub_business_provider.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/utils/currency_utils.dart';

class SubBusinessTransferView extends ConsumerStatefulWidget {
  const SubBusinessTransferView({super.key, required this.subBusinessId});

  final String subBusinessId;

  @override
  ConsumerState<SubBusinessTransferView> createState() =>
      _SubBusinessTransferViewState();
}

class _SubBusinessTransferViewState
    extends ConsumerState<SubBusinessTransferView> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String? _destinationId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(subBusinessProvider);
      if (state.subBusinesses.isEmpty) {
        ref.read(subBusinessProvider.notifier).loadSubBusinesses();
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(subBusinessProvider);
    final source = _findSource(state);
    final destinations = state.subBusinesses
        .where((subBusiness) => subBusiness.id != widget.subBusinessId)
        .toList();

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        title: AppText(
          l10n.subBusiness_transferTitle,
          variant: AppTextVariant.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: source == null
            ? _UnavailableTransferState(
                isLoading: state.isLoading,
                message: state.error ?? l10n.subBusiness_emptyMessage,
              )
            : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    _TransferPartyCard(
                      label: l10n.subBusiness_transferFrom,
                      subBusiness: source,
                    ),
                    SizedBox(height: AppSpacing.md),
                    if (destinations.isEmpty)
                      _NoDestinationCard(
                        message: l10n.subBusiness_noTransferDestination,
                      )
                    else
                      AppSelect<String>(
                        label: l10n.subBusiness_transferTo,
                        hint: l10n.subBusiness_chooseDestination,
                        value: _destinationId,
                        prefixIcon: Icons.account_tree_outlined,
                        items: destinations
                            .map(
                              (subBusiness) => AppSelectItem<String>(
                                value: subBusiness.id,
                                label: subBusiness.name,
                                subtitle: formatCurrency(
                                  subBusiness.balance,
                                  subBusiness.currency,
                                ),
                                icon: _iconForType(subBusiness.type),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() => _destinationId = value);
                        },
                      ),
                    SizedBox(height: AppSpacing.lg),
                    AppInput(
                      controller: _amountController,
                      label: l10n.common_amount,
                      hint: '0.00',
                      helper: l10n.subBusiness_transferAmountHelper,
                      prefix: Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.xs),
                        child: AppText(
                          source.currency,
                          variant: AppTextVariant.labelMedium,
                          color: context.colors.gold,
                        ),
                      ),
                      variant: AppInputVariant.amount,
                      validator: _validateAmount,
                    ),
                    SizedBox(height: AppSpacing.md),
                    AppInput(
                      controller: _noteController,
                      label: l10n.common_note,
                      hint: l10n.subBusiness_transferNoteHint,
                      maxLines: 2,
                    ),
                    SizedBox(height: AppSpacing.lg),
                    _TransferReviewCard(
                      source: source,
                      destination: _selectedDestination(destinations),
                      amount: _parsedAmount,
                    ),
                    SizedBox(height: AppSpacing.xl),
                    AppButton(
                      label: l10n.subBusiness_transferSubmit,
                      icon: Icons.arrow_forward_rounded,
                      iconPosition: IconPosition.right,
                      isFullWidth: true,
                      isLoading: _isSubmitting,
                      onPressed: destinations.isEmpty ? null : _submit,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  SubBusiness? _findSource(SubBusinessState state) {
    for (final subBusiness in state.subBusinesses) {
      if (subBusiness.id == widget.subBusinessId) return subBusiness;
    }
    return null;
  }

  SubBusiness? _selectedDestination(List<SubBusiness> destinations) {
    final selectedId = _destinationId;
    if (selectedId == null) return null;
    for (final subBusiness in destinations) {
      if (subBusiness.id == selectedId) return subBusiness;
    }
    return null;
  }

  double get _parsedAmount {
    return double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0;
  }

  String? _validateAmount(String? value) {
    final l10n = AppLocalizations.of(context)!;
    final amount = double.tryParse((value ?? '').replaceAll(',', '.'));
    if (amount == null || amount <= 0) return l10n.error_amountInvalid;
    final source = _findSource(ref.read(subBusinessProvider));
    if (source != null && source.balance > 0 && amount > source.balance) {
      return l10n.error_insufficientBalance;
    }
    return null;
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (_destinationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.subBusiness_chooseDestination),
          backgroundColor: context.colors.error,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final success = await ref
        .read(subBusinessProvider.notifier)
        .transferBetweenSubBusinesses(
          fromSubBusinessId: widget.subBusinessId,
          toSubBusinessId: _destinationId!,
          amount: _parsedAmount,
          note: _noteController.text,
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      await _showSuccessDialog(l10n);
      if (mounted) context.fsmPop();
      return;
    }

    final error =
        ref.read(subBusinessProvider).error ?? l10n.error_transferFailed;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error), backgroundColor: context.colors.error),
    );
  }

  Future<void> _showSuccessDialog(AppLocalizations l10n) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: context.colors.container,
          icon: Icon(Icons.check_circle_rounded, color: context.colors.success),
          title: AppText(
            l10n.subBusiness_transferSuccessTitle,
            variant: AppTextVariant.titleLarge,
            textAlign: TextAlign.center,
          ),
          content: AppText(
            l10n.subBusiness_transferSuccessMessage,
            variant: AppTextVariant.bodyMedium,
            color: context.colors.textSecondary,
            textAlign: TextAlign.center,
          ),
          actions: [
            AppButton(
              label: l10n.common_done,
              size: AppButtonSize.small,
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        );
      },
    );
  }
}

class _TransferPartyCard extends StatelessWidget {
  const _TransferPartyCard({required this.label, required this.subBusiness});

  final String label;
  final SubBusiness subBusiness;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.goldAccent,
      borderRadius: AppRadius.md,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.colors.goldSubtle,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              _iconForType(subBusiness.type),
              color: context.colors.gold,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  label,
                  variant: AppTextVariant.labelSmall,
                  color: context.colors.textSecondary,
                ),
                SizedBox(height: AppSpacing.xxs),
                AppText(
                  subBusiness.name,
                  variant: AppTextVariant.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.md),
          AmountText.fromText(
            formatCurrency(subBusiness.balance, subBusiness.currency),
            size: AmountTextSize.small,
            color: context.colors.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _NoDestinationCard extends StatelessWidget {
  const _NoDestinationCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.flat,
      borderRadius: AppRadius.md,
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: context.colors.gold),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: AppText(
              message,
              variant: AppTextVariant.bodyMedium,
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransferReviewCard extends StatelessWidget {
  const _TransferReviewCard({
    required this.source,
    required this.destination,
    required this.amount,
  });

  final SubBusiness source;
  final SubBusiness? destination;
  final double amount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppCard(
      variant: AppCardVariant.flat,
      borderRadius: AppRadius.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            l10n.subBusiness_transferReviewTitle,
            variant: AppTextVariant.titleMedium,
          ),
          SizedBox(height: AppSpacing.md),
          _ReviewRow(label: l10n.subBusiness_transferFrom, value: source.name),
          SizedBox(height: AppSpacing.sm),
          _ReviewRow(
            label: l10n.subBusiness_transferTo,
            value: destination?.name ?? l10n.subBusiness_chooseDestination,
          ),
          SizedBox(height: AppSpacing.sm),
          _ReviewRow(
            label: l10n.common_amount,
            value: amount > 0
                ? formatCurrency(amount, source.currency)
                : formatCurrency(0, source.currency),
            valueColor: context.colors.gold,
          ),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AppText(
            label,
            variant: AppTextVariant.bodySmall,
            color: context.colors.textSecondary,
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          flex: 2,
          child: AppText(
            value,
            variant: AppTextVariant.bodyMedium,
            color: valueColor,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

class _UnavailableTransferState extends StatelessWidget {
  const _UnavailableTransferState({
    required this.isLoading,
    required this.message,
  });

  final bool isLoading;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: isLoading
            ? CircularProgressIndicator(color: context.colors.gold)
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.account_tree_outlined,
                    size: 48,
                    color: context.colors.textSecondary,
                  ),
                  SizedBox(height: AppSpacing.md),
                  AppText(
                    message,
                    variant: AppTextVariant.bodyMedium,
                    color: context.colors.textSecondary,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
      ),
    );
  }
}

IconData _iconForType(SubBusinessType type) {
  switch (type) {
    case SubBusinessType.department:
      return Icons.business_center_outlined;
    case SubBusinessType.branch:
      return Icons.storefront_outlined;
    case SubBusinessType.subsidiary:
      return Icons.corporate_fare_outlined;
    case SubBusinessType.team:
      return Icons.groups_outlined;
  }
}
