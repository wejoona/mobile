import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/theme_colors.dart';
import '../../../design/components/primitives/app_button.dart';
import '../../../design/components/primitives/app_text.dart';
import '../../../design/components/primitives/app_input.dart';
import '../providers/kyc_provider.dart';

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
  DateTime? _dateOfBirth;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
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
          variant: AppTextVariant.headlineSmall,
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
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        l10n.kyc_personalInfo_subtitle,
                        variant: AppTextVariant.bodyLarge,
                        color: colors.textSecondary,
                      ),
                      SizedBox(height: AppSpacing.xxl),
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
                      SizedBox(height: AppSpacing.lg),
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
                      SizedBox(height: AppSpacing.lg),
                      _buildDateOfBirthField(context, l10n),
                      SizedBox(height: AppSpacing.xxl),
                      _buildInfoCard(context, l10n),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
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
        SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
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
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.gold.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.gold.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: colors.gold,
            size: 24,
          ),
          SizedBox(width: AppSpacing.md),
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
    if (!_formKey.currentState!.validate()) return;

    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context)!.kyc_personalInfo_dateRequired),
        ),
      );
      return;
    }

    ref.read(kycProvider.notifier).setPersonalInfo(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          dateOfBirth: _dateOfBirth!,
        );

    context.push('/kyc/document-capture');
  }
}
