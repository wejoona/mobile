import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/config/countries.dart' as app_config;
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/auth/providers/countries_provider.dart';
import 'package:usdc_wallet/features/auth/widgets/auth_screen_chrome.dart';
import 'package:usdc_wallet/features/onboarding/models/country_data.dart';
import 'package:usdc_wallet/features/onboarding/providers/onboarding_provider.dart';
import 'package:usdc_wallet/features/onboarding/widgets/country_picker_widget.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/utils/input_formatters.dart';
import 'package:usdc_wallet/utils/phone_number_normalizer.dart';

/// Phone input screen for explicit account signup.
class SignupPhoneView extends ConsumerStatefulWidget {
  const SignupPhoneView({super.key});

  @override
  ConsumerState<SignupPhoneView> createState() => _SignupPhoneViewState();
}

class _SignupPhoneViewState extends ConsumerState<SignupPhoneView> {
  final _phoneController = TextEditingController();
  CountryData _selectedCountry = SupportedCountries.coteDivoire;

  @override
  void initState() {
    super.initState();
    _selectedCountry = CountryData.fromConfig(
      ref.read(selectedCountryProvider),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(onboardingProvider);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.canvas,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            const SizedBox(height: AppSpacing.giant),
            AuthScreenHeader(
              appName: l10n.appName,
              title: l10n.onboarding_phoneInput_title,
              subtitle: l10n.onboarding_phoneInput_subtitle,
              markSize: 52,
            ),
            const SizedBox(height: AppSpacing.xxl),
            // Country picker
            GestureDetector(
              onTap: _showCountryPicker,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: colors.elevated,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: colors.borderSubtle),
                ),
                child: Row(
                  children: [
                    Text(
                      _selectedCountry.flag,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppText(
                        _selectedCountry.name,
                        variant: AppTextVariant.bodyLarge,
                        color: colors.textPrimary,
                      ),
                    ),
                    AppText(
                      _selectedCountry.dialCode,
                      variant: AppTextVariant.bodyLarge,
                      color: colors.gold,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Icon(Icons.arrow_drop_down, color: colors.iconSecondary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Phone input
            AppInput(
              label: l10n.onboarding_phoneInput_label,
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              hint: _selectedCountry.phoneFormat,
              inputFormatters: [
                LocalPhoneInputFormatter(
                  dialCode: _selectedCountry.dialCode,
                  maxLocalDigits: _selectedCountry.phoneLength,
                  displayFormat: _selectedCountry.phoneFormat,
                ),
              ],
              onChanged: (_) {
                _syncPhoneControllerToLocal();
                setState(() {});
              },
            ),
            if (state.error != null) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: colors.errorBg,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: colors.error),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: colors.errorText),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppText(
                        state.error!,
                        variant: AppTextVariant.bodySmall,
                        color: colors.errorText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.2),
            AppButton(
              label: l10n.action_continue,
              onPressed: _canSubmit ? _handleSubmit : null,
              isLoading: state.isLoading,
              isFullWidth: true,
            ),
            const SizedBox(height: AppSpacing.md),
            // Login link
            Center(
              child: TextButton(
                onPressed: () => context.go('/login'),
                child: AppText(
                  l10n.onboarding_phoneInput_loginLink,
                  style: AppTypography.bodyMedium.copyWith(color: colors.gold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _canSubmit {
    final digits = _currentLocalPhone();
    return digits.length == _selectedCountry.phoneLength;
  }

  Future<void> _showCountryPicker() async {
    final colors = context.colors;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) => CountryPickerWidget(
        selectedCountry: _selectedCountry,
        onCountrySelected: (country) {
          setState(() {
            _selectedCountry = country;
            _syncPhoneControllerToLocal();
          });
          final configCountry = app_config.SupportedCountries.findByCode(
            country.code,
          );
          if (configCountry != null) {
            ref.read(selectedCountryProvider.notifier).select(configCountry);
          }
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final localPhoneNumber = _currentLocalPhone();
    final configCountry = app_config.SupportedCountries.findByCode(
      _selectedCountry.code,
    );
    if (configCountry != null) {
      ref.read(selectedCountryProvider.notifier).select(configCountry);
    }
    ref
        .read(onboardingProvider.notifier)
        .updatePhoneNumber(
          localPhoneNumber,
          _selectedCountry.code,
          _selectedCountry.dialCode,
        );
    if (mounted) {
      context.go('/signup/legal-consent');
    }
  }

  String _currentLocalPhone() => localPhoneInputDigits(
    dialCode: _selectedCountry.dialCode,
    phoneNumber: _phoneController.text,
    maxLocalDigits: _selectedCountry.phoneLength,
  );

  void _syncPhoneControllerToLocal() {
    final formatted =
        LocalPhoneInputFormatter(
          dialCode: _selectedCountry.dialCode,
          maxLocalDigits: _selectedCountry.phoneLength,
          displayFormat: _selectedCountry.phoneFormat,
        ).formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(text: _phoneController.text),
        );

    if (formatted.text != _phoneController.text) {
      _phoneController.value = formatted;
    }
  }
}
