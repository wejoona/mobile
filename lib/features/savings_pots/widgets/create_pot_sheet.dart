import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/bottom_sheet_handle.dart';
import 'package:usdc_wallet/utils/form_validators.dart';
import 'package:usdc_wallet/utils/input_formatters.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';

/// Bottom sheet for creating a new savings pot.
class CreatePotSheet extends StatefulWidget {
  final Future<void> Function(String name, double target, DateTime? targetDate) onCreate;

  const CreatePotSheet({super.key, required this.onCreate});

  @override
  State<CreatePotSheet> createState() => _CreatePotSheetState();
}

class _CreatePotSheetState extends State<CreatePotSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _targetDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final amount = double.tryParse(_amountController.text);
      if (amount == null || amount <= 0) return;
      await widget.onCreate(
        _nameController.text.trim(),
        amount,
        _targetDate,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.common_errorFormat(e.toString())), backgroundColor: context.colors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final __theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BottomSheetHandle(title: 'New Savings Pot', onClose: () => Navigator.pop(context)),
          Padding(
            padding: EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xxl),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Pot Name', hintText: 'e.g. Vacation Fund'),
                    validator: (v) => FormValidators.required(v, fieldName: 'Name'),
                    textCapitalization: TextCapitalization.words,
                  ),
                  SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(labelText: 'Target Amount (USDC)', prefixText: '\$ '),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [AmountInputFormatter()],
                    validator: (v) => FormValidators.amount(v, min: 1),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(_targetDate == null ? 'Set target date (optional)' : 'Target: ${_targetDate!.day}/${_targetDate!.month}/${_targetDate!.year}'),
                    trailing: const Icon(Icons.calendar_today_rounded, size: 20),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 30)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 3650)),
                      );
                      if (date != null) setState(() => _targetDate = date);
                    },
                  ),
                  SizedBox(height: AppSpacing.xxl),
                  AppButton(
                    label: AppLocalizations.of(context)!.savingsPots_createPot,
                    onPressed: _isLoading ? null : _submit,
                    isLoading: _isLoading,
                    isFullWidth: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
