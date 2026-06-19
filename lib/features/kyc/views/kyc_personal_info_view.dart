import 'dart:async';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:usdc_wallet/design/components/primitives/app_button.dart';
import 'package:usdc_wallet/design/components/primitives/app_input.dart';
import 'package:usdc_wallet/design/components/primitives/app_select.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/design/tokens/spacing.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';
import 'package:usdc_wallet/features/kyc/providers/kyc_provider.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/state/index.dart';

class KycPersonalInfoView extends ConsumerStatefulWidget {
  const KycPersonalInfoView({super.key});

  @override
  ConsumerState<KycPersonalInfoView> createState() =>
      _KycPersonalInfoViewState();
}

class _KycPersonalInfoViewState extends ConsumerState<KycPersonalInfoView> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _documentNumberController = TextEditingController();
  DateTime? _dateOfBirth;
  String _country = 'CI';

  @override
  void initState() {
    super.initState();
    // Pre-fill from user profile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userState = ref.read(userStateMachineProvider);
      if (_firstNameController.text.isEmpty && userState.firstName != null) {
        _firstNameController.text = userState.firstName!;
      }
      if (_lastNameController.text.isEmpty && userState.lastName != null) {
        _lastNameController.text = userState.lastName!;
      }
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _documentNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        title: AppText(
          l10n.kyc_personalInfo_title,
          variant: AppTextVariant.titleLarge,
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.huge,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        l10n.kyc_personalInfo_subtitle,
                        color: colors.textSecondary,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppInput(
                        label: l10n.kyc_personalInfo_firstName,
                        controller: _firstNameController,
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.kyc_personalInfo_firstNameRequired;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppInput(
                        label: l10n.kyc_personalInfo_lastName,
                        controller: _lastNameController,
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.kyc_personalInfo_lastNameRequired;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _buildDateOfBirthField(context, l10n),
                      const SizedBox(height: AppSpacing.lg),
                      AppSelect<String>(
                        label: l10n.profile_country,
                        value: _country,
                        items: [
                          AppSelectItem(
                            value: 'CI',
                            label: l10n.profile_countryIvoryCoast,
                            subtitle: '+225',
                          ),
                          AppSelectItem(
                            value: 'SN',
                            label: l10n.profile_countrySenegal,
                            subtitle: '+221',
                          ),
                          const AppSelectItem(
                            value: 'ML',
                            label: 'Mali',
                            subtitle: '+223',
                          ),
                          const AppSelectItem(
                            value: 'US',
                            label: 'United States',
                            subtitle: '+1',
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _country = value);
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppInput(
                        label: 'Document number',
                        controller: _documentNumberController,
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Document number is required';
                          }
                          if (value.trim().length < 4) {
                            return 'Enter the number shown on your ID';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _buildInfoCard(context, l10n),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: AppButton(
                  label: l10n.common_continue,
                  onPressed: _handleContinue,
                  isFullWidth: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateOfBirthField(BuildContext context, AppLocalizations l10n) {
    final colors = context.colors;
    final dateFormat = DateFormat.yMMMd();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          l10n.kyc_personalInfo_dateOfBirth,
          variant: AppTextVariant.labelMedium,
          color: colors.textSecondary,
        ),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: AppText(
                    _dateOfBirth != null
                        ? dateFormat.format(_dateOfBirth!)
                        : l10n.kyc_personalInfo_selectDate,
                    variant: AppTextVariant.bodyLarge,
                    color: _dateOfBirth != null
                        ? colors.textPrimary
                        : colors.textTertiary,
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: colors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, AppLocalizations l10n) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.gold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.gold.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: colors.gold, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: AppText(
              l10n.kyc_personalInfo_matchIdHint,
              variant: AppTextVariant.bodySmall,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    const minAge = 18;
    final maxDate = DateTime(now.year - minAge, now.month, now.day);
    final minDate = DateTime(1900);

    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? maxDate,
      firstDate: minDate,
      lastDate: maxDate,
    );

    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  void _handleContinue() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.kyc_personalInfo_dateRequired,
          ),
        ),
      );
      return;
    }

    ref.read(kycProvider.notifier).setPersonalInfo({
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'dateOfBirth': _dateOfBirth!.toIso8601String(),
      'country': _country,
      'documentNumber': _documentNumberController.text.trim(),
    });

    unawaited(context.fsmPush('/kyc/document-capture'));
  }
}
