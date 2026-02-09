import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../providers/create_recurring_transfer_provider.dart';
import '../providers/recurring_transfers_provider.dart';
import '../widgets/frequency_picker.dart';
import '../widgets/end_condition_picker.dart';
import '../../../design/tokens/theme_colors.dart';

class CreateRecurringTransferView extends ConsumerStatefulWidget {
  const CreateRecurringTransferView({
    super.key,
    this.recipientPhone,
    this.recipientName,
    this.amount,
  });

  final String? recipientPhone;
  final String? recipientName;
  final double? amount;

  @override
  ConsumerState<CreateRecurringTransferView> createState() =>
      _CreateRecurringTransferViewState();
}

class _CreateRecurringTransferViewState
    extends ConsumerState<CreateRecurringTransferView> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.recipientPhone != null && widget.recipientName != null) {
      _phoneController.text = widget.recipientPhone!;
      _nameController.text = widget.recipientName!;
      if (widget.amount != null) {
        _amountController.text = widget.amount.toString();
      }
      Future.microtask(() {
        ref.read(createRecurringTransferProvider.notifier).loadFromExisting(
              widget.recipientPhone!,
              widget.recipientName!,
              amount: widget.amount,
            );
      });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final formState = ref.watch(createRecurringTransferProvider);

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        title: AppText(
          l10n.recurringTransfers_createTitle,
          variant: AppTextVariant.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(AppSpacing.md),
            children: [
              AppText(
                l10n.recurringTransfers_recipientSection,
                variant: AppTextVariant.headlineSmall,
              ),
              SizedBox(height: AppSpacing.md),
              AppInput(
                label: l10n.send_recipientPhone,
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone,
                validator: (v) => v?.isEmpty == true
                    ? l10n.validation_required
                    : null,
                onChanged: (v) => ref
                    .read(createRecurringTransferProvider.notifier)
                    .setRecipient(v, _nameController.text),
              ),
              SizedBox(height: AppSpacing.md),
              AppInput(
                label: l10n.send_enterRecipientName,
                controller: _nameController,
                prefixIcon: Icons.person,
                validator: (v) => v?.isEmpty == true
                    ? l10n.validation_required
                    : null,
                onChanged: (v) => ref
                    .read(createRecurringTransferProvider.notifier)
                    .setRecipient(_phoneController.text, v),
              ),
              SizedBox(height: AppSpacing.lg),
              AppText(
                l10n.recurringTransfers_amountSection,
                variant: AppTextVariant.headlineSmall,
              ),
              SizedBox(height: AppSpacing.md),
              AppInput(
                label: l10n.send_amount,
                controller: _amountController,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.payments,
                suffix: AppText(
                  formState.currency,
                  variant: AppTextVariant.bodyMedium,
                  color: context.colors.textSecondary,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (v) {
                  if (v?.isEmpty == true) return l10n.validation_required;
                  final amount = double.tryParse(v!);
                  if (amount == null || amount <= 0) {
                    return l10n.validation_invalidAmount;
                  }
                  return null;
                },
                onChanged: (v) {
                  final amount = double.tryParse(v);
                  if (amount != null) {
                    ref
                        .read(createRecurringTransferProvider.notifier)
                        .setAmount(amount);
                  }
                },
              ),
              SizedBox(height: AppSpacing.lg),
              AppText(
                l10n.recurringTransfers_scheduleSection,
                variant: AppTextVariant.headlineSmall,
              ),
              SizedBox(height: AppSpacing.md),
              FrequencyPicker(
                selected: formState.frequency,
                onChanged: (frequency) {
                  ref
                      .read(createRecurringTransferProvider.notifier)
                      .setFrequency(frequency);
                },
              ),
              SizedBox(height: AppSpacing.md),
              _buildStartDatePicker(l10n, formState),
              SizedBox(height: AppSpacing.md),
              EndConditionPicker(
                endCondition: formState.endCondition,
                endDate: formState.endDate,
                occurrences: formState.occurrences,
                onEndConditionChanged: (condition) {
                  ref
                      .read(createRecurringTransferProvider.notifier)
                      .setEndCondition(condition);
                },
                onEndDateChanged: (date) {
                  ref
                      .read(createRecurringTransferProvider.notifier)
                      .setEndDate(date);
                },
                onOccurrencesChanged: (count) {
                  ref
                      .read(createRecurringTransferProvider.notifier)
                      .setOccurrences(count);
                },
              ),
              SizedBox(height: AppSpacing.lg),
              AppInput(
                label: l10n.recurringTransfers_note,
                controller: _noteController,
                maxLines: 3,
                prefixIcon: Icons.note,
                hint: l10n.recurringTransfers_noteHint,
                onChanged: (v) => ref
                    .read(createRecurringTransferProvider.notifier)
                    .setNote(v.isEmpty ? null : v),
              ),
              SizedBox(height: AppSpacing.xl),
              AppButton(
                label: l10n.recurringTransfers_create,
                onPressed: formState.isValid ? _handleCreate : null,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartDatePicker(
    AppLocalizations l10n,
    CreateRecurringTransferFormState formState,
  ) {
    return Builder(
      builder: (context) => AppCard(
        variant: AppCardVariant.subtle,
        onTap: () => _selectStartDate(formState.startDate),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(Icons.calendar_today, color: context.colors.gold),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      l10n.recurringTransfers_startDate,
                      variant: AppTextVariant.bodySmall,
                      color: context.colors.textSecondary,
                    ),
                    SizedBox(height: AppSpacing.xs),
                    AppText(
                      _formatDate(formState.startDate),
                      variant: AppTextVariant.bodyMedium,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: context.colors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectStartDate(DateTime initialDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.gold500,
              surface: AppColors.slate,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      ref.read(createRecurringTransferProvider.notifier).setStartDate(date);
    }
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final formState = ref.read(createRecurringTransferProvider);
      final request = formState.toRequest();

      final transfer = await ref
          .read(recurringTransfersProvider.notifier)
          .createRecurringTransfer(request);

      if (!mounted) return;

      if (transfer != null) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AppText(l10n.recurringTransfers_createSuccess),
            backgroundColor: AppColors.successBase,
          ),
        );
        ref.read(createRecurringTransferProvider.notifier).reset();
        context.pop();
      } else {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AppText(l10n.recurringTransfers_createError),
            backgroundColor: AppColors.errorBase,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
