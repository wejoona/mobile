import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../providers/beneficiaries_provider.dart';
import '../models/beneficiary.dart';

/// Add/Edit Beneficiary Screen
class AddBeneficiaryScreen extends ConsumerStatefulWidget {
  const AddBeneficiaryScreen({
    super.key,
    this.beneficiaryId,
  });

  final String? beneficiaryId;

  @override
  ConsumerState<AddBeneficiaryScreen> createState() =>
      _AddBeneficiaryScreenState();
}

class _AddBeneficiaryScreenState extends ConsumerState<AddBeneficiaryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _walletAddressController = TextEditingController();
  final _bankCodeController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _mobileMoneyProviderController = TextEditingController();

  AccountType _selectedAccountType = AccountType.joonapayUser;
  bool _isLoading = false;
  Beneficiary? _existingBeneficiary;

  @override
  void initState() {
    super.initState();
    _loadBeneficiary();
  }

  void _loadBeneficiary() {
    if (widget.beneficiaryId != null) {
      final state = ref.read(beneficiariesProvider);
      _existingBeneficiary = state.beneficiaries.firstWhere(
        (b) => b.id == widget.beneficiaryId,
      );

      if (_existingBeneficiary != null) {
        _nameController.text = _existingBeneficiary!.name;
        _phoneController.text = _existingBeneficiary!.phoneE164 ?? '';
        _selectedAccountType = _existingBeneficiary!.accountType;

        switch (_selectedAccountType) {
          case AccountType.externalWallet:
            _walletAddressController.text =
                _existingBeneficiary!.beneficiaryWalletAddress ?? '';
            break;
          case AccountType.bankAccount:
            _bankCodeController.text = _existingBeneficiary!.bankCode ?? '';
            _bankAccountController.text =
                _existingBeneficiary!.bankAccountNumber ?? '';
            break;
          case AccountType.mobileMoney:
            _mobileMoneyProviderController.text =
                _existingBeneficiary!.mobileMoneyProvider ?? '';
            break;
          case AccountType.joonapayUser:
            break;
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _walletAddressController.dispose();
    _bankCodeController.dispose();
    _bankAccountController.dispose();
    _mobileMoneyProviderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEdit = widget.beneficiaryId != null;

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: AppText(
          isEdit
              ? l10n.beneficiaries_editTitle
              : l10n.beneficiaries_addTitle,
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
              // Name
              AppInput(
                label: l10n.beneficiaries_fieldName,
                controller: _nameController,
                validator: (v) =>
                    v?.isEmpty == true ? l10n.error_required : null,
              ),
              SizedBox(height: AppSpacing.md),

              // Phone
              AppInput(
                label: l10n.beneficiaries_fieldPhone,
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                hint: '+225 XX XX XX XX',
                enabled: !isEdit, // Can't change phone in edit mode
              ),
              SizedBox(height: AppSpacing.md),

              // Account Type
              AppSelect<AccountType>(
                label: l10n.beneficiaries_fieldAccountType,
                value: _selectedAccountType,
                items: AccountType.values.map((type) {
                  return AppSelectItem(
                    value: type,
                    label: _getAccountTypeLabel(l10n, type),
                  );
                }).toList(),
                enabled: !isEdit,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedAccountType = value);
                  }
                },
              ),
              SizedBox(height: AppSpacing.md),

              // Conditional fields based on account type
              ..._buildAccountTypeFields(l10n),

              SizedBox(height: AppSpacing.xl),

              // Submit button
              AppButton(
                label: isEdit ? l10n.common_save : l10n.beneficiaries_addButton,
                onPressed: _handleSubmit,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAccountTypeFields(AppLocalizations l10n) {
    switch (_selectedAccountType) {
      case AccountType.externalWallet:
        return [
          AppInput(
            label: l10n.beneficiaries_fieldWalletAddress,
            controller: _walletAddressController,
            hint: '0x...',
            validator: (v) => v?.isEmpty == true ? l10n.error_required : null,
            enabled: !(_existingBeneficiary != null),
          ),
          SizedBox(height: AppSpacing.md),
        ];

      case AccountType.bankAccount:
        return [
          AppInput(
            label: l10n.beneficiaries_fieldBankCode,
            controller: _bankCodeController,
            validator: (v) => v?.isEmpty == true ? l10n.error_required : null,
            enabled: !(_existingBeneficiary != null),
          ),
          SizedBox(height: AppSpacing.md),
          AppInput(
            label: l10n.beneficiaries_fieldBankAccount,
            controller: _bankAccountController,
            validator: (v) => v?.isEmpty == true ? l10n.error_required : null,
            enabled: !(_existingBeneficiary != null),
          ),
          SizedBox(height: AppSpacing.md),
        ];

      case AccountType.mobileMoney:
        return [
          AppInput(
            label: l10n.beneficiaries_fieldMobileMoneyProvider,
            controller: _mobileMoneyProviderController,
            hint: 'Orange Money, MTN MoMo, Wave',
            validator: (v) => v?.isEmpty == true ? l10n.error_required : null,
            enabled: !(_existingBeneficiary != null),
          ),
          SizedBox(height: AppSpacing.md),
        ];

      case AccountType.joonapayUser:
        return [];
    }
  }

  String _getAccountTypeLabel(AppLocalizations l10n, AccountType type) {
    switch (type) {
      case AccountType.joonapayUser:
        return l10n.beneficiaries_typeJoonapay;
      case AccountType.externalWallet:
        return l10n.beneficiaries_typeWallet;
      case AccountType.bankAccount:
        return l10n.beneficiaries_typeBank;
      case AccountType.mobileMoney:
        return l10n.beneficiaries_typeMobileMoney;
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);

    try {
      final isEdit = widget.beneficiaryId != null;

      if (isEdit) {
        // Update existing beneficiary
        final request = UpdateBeneficiaryRequest(
          name: _nameController.text.trim(),
          phoneE164: _phoneController.text.trim().isNotEmpty
              ? _phoneController.text.trim()
              : null,
        );

        final success = await ref
            .read(beneficiariesProvider.notifier)
            .updateBeneficiary(widget.beneficiaryId!, request);

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: AppText(l10n.beneficiaries_updateSuccess),
              backgroundColor: AppColors.successBase,
            ),
          );
          context.pop();
        }
      } else {
        // Create new beneficiary
        final request = CreateBeneficiaryRequest(
          name: _nameController.text.trim(),
          phoneE164: _phoneController.text.trim().isNotEmpty
              ? _phoneController.text.trim()
              : null,
          accountType: _selectedAccountType,
          beneficiaryWalletAddress:
              _selectedAccountType == AccountType.externalWallet
                  ? _walletAddressController.text.trim()
                  : null,
          bankCode: _selectedAccountType == AccountType.bankAccount
              ? _bankCodeController.text.trim()
              : null,
          bankAccountNumber: _selectedAccountType == AccountType.bankAccount
              ? _bankAccountController.text.trim()
              : null,
          mobileMoneyProvider: _selectedAccountType == AccountType.mobileMoney
              ? _mobileMoneyProviderController.text.trim()
              : null,
        );

        final beneficiary = await ref
            .read(beneficiariesProvider.notifier)
            .createBeneficiary(request);

        if (beneficiary != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: AppText(l10n.beneficiaries_createSuccess),
              backgroundColor: AppColors.successBase,
            ),
          );
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AppText(e.toString()),
            backgroundColor: AppColors.errorBase,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
