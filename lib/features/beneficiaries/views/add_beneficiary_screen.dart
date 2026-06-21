import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/beneficiaries/providers/beneficiaries_provider.dart';
import 'package:usdc_wallet/features/beneficiaries/models/beneficiary.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

/// Add/Edit Beneficiary Screen
class AddBeneficiaryScreen extends ConsumerStatefulWidget {
  const AddBeneficiaryScreen({super.key, this.beneficiaryId});

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

  AccountType _selectedAccountType = AccountType.joonapayUser;
  String? _selectedMobileMoneyProvider;
  bool _isLoading = false;
  Beneficiary? _existingBeneficiary;
  bool _requestedBeneficiariesLoad = false;

  @override
  void initState() {
    super.initState();
    _loadBeneficiary();
  }

  void _loadBeneficiary() {
    if (widget.beneficiaryId != null) {
      final state = ref.read(beneficiariesProvider);
      _existingBeneficiary = _findBeneficiary(
        state.beneficiaries,
        widget.beneficiaryId!,
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
            _selectedMobileMoneyProvider =
                _existingBeneficiary!.mobileMoneyProvider;
            break;
          case AccountType.joonapayUser:
            break;
        }
      }
    }
  }

  Beneficiary? _findBeneficiary(
    List<Beneficiary> beneficiaries,
    String beneficiaryId,
  ) {
    for (final beneficiary in beneficiaries) {
      if (beneficiary.id == beneficiaryId) {
        return beneficiary;
      }
    }
    return null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _walletAddressController.dispose();
    _bankCodeController.dispose();
    _bankAccountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final isEdit = widget.beneficiaryId != null;
    final state = ref.watch(beneficiariesProvider);

    if (isEdit && _existingBeneficiary == null) {
      if (!_requestedBeneficiariesLoad &&
          !state.isLoading &&
          state.error == null &&
          state.beneficiaries.isEmpty) {
        _requestedBeneficiariesLoad = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          unawaited(
            ref.read(beneficiariesProvider.notifier).loadBeneficiaries(),
          );
        });
      }

      final loadedBeneficiary = _findBeneficiary(
        state.beneficiaries,
        widget.beneficiaryId!,
      );
      if (loadedBeneficiary != null) {
        _existingBeneficiary = loadedBeneficiary;
        _nameController.text = loadedBeneficiary.name;
        _phoneController.text = loadedBeneficiary.phoneE164 ?? '';
        _selectedAccountType = loadedBeneficiary.accountType;
      } else if (state.isLoading) {
        return Scaffold(
          backgroundColor: colors.canvas,
          appBar: AppBar(
            title: AppText(
              l10n.beneficiaries_editTitle,
              variant: AppTextVariant.headlineSmall,
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: const Center(child: CircularProgressIndicator()),
        );
      } else {
        return Scaffold(
          backgroundColor: colors.canvas,
          appBar: AppBar(
            title: AppText(
              l10n.beneficiaries_editTitle,
              variant: AppTextVariant.headlineSmall,
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: AppText(
                l10n.error_beneficiaryNotFound,
                variant: AppTextVariant.bodyLarge,
                color: colors.textSecondary,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        title: AppText(
          isEdit ? l10n.beneficiaries_editTitle : l10n.beneficiaries_addTitle,
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
          AppSelect<String>(
            label: l10n.beneficiaries_fieldMobileMoneyProvider,
            value: _selectedMobileMoneyProvider,
            items: const [
              AppSelectItem(value: 'Orange Money', label: 'Orange Money'),
              AppSelectItem(value: 'MTN MoMo', label: 'MTN MoMo'),
              AppSelectItem(value: 'Wave', label: 'Wave'),
              AppSelectItem(value: 'Moov Money', label: 'Moov Money'),
            ],
            onChanged: (value) {
              setState(() => _selectedMobileMoneyProvider = value);
            },
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
        );

        final success = await ref
            .read(beneficiariesProvider.notifier)
            .updateBeneficiary(widget.beneficiaryId!, request);

        if (success && mounted) {
          final colors = context.colors;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: AppText(l10n.beneficiaries_updateSuccess),
              backgroundColor: colors.success,
            ),
          );
          context.fsmSafePop(fallbackRoute: '/beneficiaries');
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
              ? _selectedMobileMoneyProvider
              : null,
        );

        final beneficiary = await ref
            .read(beneficiariesProvider.notifier)
            .createBeneficiary(request);

        if (beneficiary != null && mounted) {
          final colors = context.colors;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: AppText(l10n.beneficiaries_createSuccess),
              backgroundColor: colors.success,
            ),
          );
          context.fsmSafePop(fallbackRoute: '/beneficiaries');
        }
      }
    } catch (e) {
      if (mounted) {
        final colors = context.colors;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AppText(
              AppLocalizations.of(context)!.beneficiaries_addError,
            ),
            backgroundColor: colors.error,
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
