import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../providers/login_provider.dart';
import '../models/login_state.dart';

/// Login phone input screen
class LoginPhoneView extends ConsumerStatefulWidget {
  const LoginPhoneView({super.key});

  @override
  ConsumerState<LoginPhoneView> createState() => _LoginPhoneViewState();
}

class _LoginPhoneViewState extends ConsumerState<LoginPhoneView> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  String _countryCode = '+225';

  @override
  void initState() {
    super.initState();
    // Pre-fill with remembered phone if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(loginProvider);
      if (state.phoneNumber != null) {
        _phoneController.text = state.phoneNumber!;
        _countryCode = state.countryCode ?? '+225';
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(loginProvider);

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(AppSpacing.xl),
            children: [
              SizedBox(height: AppSpacing.xxl),
              Text(
                l10n.login_welcomeBack,
                style: AppTypography.headlineLarge,
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                l10n.login_enterPhone,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: AppSpacing.xxxl),
              // Phone input
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Country code selector
                  Container(
                    width: 100,
                    decoration: BoxDecoration(
                      color: AppColors.elevated,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.borderDefault),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _countryCode,
                        dropdownColor: AppColors.elevated,
                        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        items: const [
                          DropdownMenuItem(value: '+225', child: Text('+225')),
                          DropdownMenuItem(value: '+221', child: Text('+221')),
                          DropdownMenuItem(value: '+223', child: Text('+223')),
                          DropdownMenuItem(value: '+226', child: Text('+226')),
                          DropdownMenuItem(value: '+234', child: Text('+234')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _countryCode = value);
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  // Phone number input
                  Expanded(
                    child: AppInput(
                      controller: _phoneController,
                      label: l10n.auth_phoneNumber,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.error_required;
                        }
                        if (value.length < 8) {
                          return l10n.auth_phoneInvalid;
                        }
                        return null;
                      },
                      onChanged: (value) {
                        ref.read(loginProvider.notifier).updatePhoneNumber(
                              value,
                              _countryCode,
                            );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.md),
              // Remember device checkbox
              Row(
                children: [
                  Checkbox(
                    value: state.rememberDevice,
                    onChanged: (value) {
                      ref.read(loginProvider.notifier).toggleRememberDevice();
                    },
                    fillColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return AppColors.gold500;
                      }
                      return AppColors.borderDefault;
                    }),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    l10n.login_rememberPhone,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              if (state.error != null) ...[
                SizedBox(height: AppSpacing.lg),
                Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.errorBase.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: AppColors.errorBase),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.errorText),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          state.error!,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.errorText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: AppSpacing.xxxl),
              AppButton(
                label: l10n.common_continue,
                onPressed: state.isLoading ? null : _handleContinue,
                isLoading: state.isLoading,
                isFullWidth: true,
              ),
              SizedBox(height: AppSpacing.lg),
              // Create account link
              Center(
                child: TextButton(
                  onPressed: () => context.go('/onboarding'),
                  child: Text.rich(
                    TextSpan(
                      text: l10n.login_noAccount,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      children: [
                        TextSpan(
                          text: ' ${l10n.login_createAccount}',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.gold500,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleContinue() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(loginProvider.notifier).submitPhoneNumber();

    if (mounted) {
      final state = ref.read(loginProvider);
      if (state.currentStep == LoginStep.otp) {
        context.go('/login/otp');
      }
    }
  }
}
