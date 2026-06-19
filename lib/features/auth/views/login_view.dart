import 'dart:async';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/config/countries.dart';
import 'package:usdc_wallet/config/environment_config.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/auth/models/login_state.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/features/auth/providers/countries_provider.dart';
import 'package:usdc_wallet/features/auth/providers/login_provider.dart';
import 'package:usdc_wallet/features/auth/widgets/auth_screen_chrome.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/biometric/biometric_service.dart';
import 'package:usdc_wallet/utils/input_formatters.dart';
import 'package:usdc_wallet/utils/phone_number_normalizer.dart';

/// Login screen with two modes:
/// 1. Returning user with biometric → full-screen biometric prompt
/// 2. New/phone login → country + phone number form
class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

enum _LoginMode { checking, biometric, phone }

class _LoginViewState extends ConsumerState<LoginView>
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _phoneFocusNode = FocusNode();
  CountryConfig _selectedCountry = SupportedCountries.defaultCountry;
  _LoginMode _mode = _LoginMode.checking;
  bool _biometricInProgress = false;
  String? _biometricError;
  String? _biometricUserId;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _selectedCountry = ref.read(selectedCountryProvider);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Pre-fetch countries from API
      ref.read(countriesProvider);
      unawaited(_determineLoginMode());
    });
  }

  Future<void> _determineLoginMode() async {
    final biometricService = ref.read(biometricServiceProvider);
    final storage = ref.read(secureStorageProvider);

    final storedUserId = await storage.read(key: StorageKeys.userId);
    final boundUserId = await biometricService.getBoundUserId();
    final isEnabled =
        storedUserId != null &&
        storedUserId.isNotEmpty &&
        boundUserId == storedUserId &&
        await biometricService.isBiometricEnabled(userId: storedUserId);
    final refreshToken = await storage.read(key: StorageKeys.refreshToken);

    if (isEnabled && refreshToken != null && mounted) {
      setState(() {
        _biometricUserId = storedUserId;
        _mode = _LoginMode.biometric;
      });
      unawaited(_animationController.forward());
      // Don't auto-prompt biometric on boot — let user tap the button
    } else {
      if (mounted) {
        setState(() {
          _biometricUserId = null;
          _mode = _LoginMode.phone;
        });
        unawaited(_animationController.forward());
      }
    }
  }

  Future<void> _doBiometricAuth({
    required String refreshToken,
    required String expectedUserId,
  }) async {
    if (_biometricInProgress) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _biometricInProgress = true;
      _biometricError = null;
    });

    try {
      final biometricService = ref.read(biometricServiceProvider);
      final authenticatedBio = await biometricService.authenticate(
        localizedReason: l10n.session_unlockReason,
      );

      if (authenticatedBio.success && mounted) {
        final success = await ref
            .read(authProvider.notifier)
            .loginWithBiometric(refreshToken, expectedUserId: expectedUserId);
        if (success && mounted) {
          context.fsmEnterAuthenticatedApp();
          return;
        }
        if (mounted) {
          setState(() => _biometricError = l10n.error_sessionExpired);
          // Clear invalid tokens and switch to phone
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) _switchToPhone();
        }
      }
    } catch (_) {
      // User cancelled or biometric failed
    }

    if (mounted) setState(() => _biometricInProgress = false);
  }

  void _switchToPhone() {
    setState(() {
      _mode = _LoginMode.phone;
      _biometricError = null;
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final loginState = ref.watch(loginProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _syncPhoneViewFromLoginState(ref.read(loginProvider));
      }
    });

    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: colors.error,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(AppSpacing.lg),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        );
        ref.read(authProvider.notifier).clearError();
      }
    });
    ref.listen<LoginState>(loginProvider, (prev, next) {
      if (next.phoneNumber != prev?.phoneNumber ||
          next.dialCode != prev?.dialCode) {
        _syncPhoneViewFromLoginState(next);
      }
      if (next.currentStep == LoginStep.otp &&
          prev?.currentStep != LoginStep.otp) {
        context.fsmGo('/login/otp');
      } else if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: colors.error,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(AppSpacing.lg),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        );
        ref.read(loginProvider.notifier).clearError();
      }
    });

    if (_mode == _LoginMode.checking) {
      return Scaffold(
        backgroundColor: colors.canvas,
        body: Center(
          child: CircularProgressIndicator(color: colors.gold, strokeWidth: 2),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colors.canvas,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: _mode == _LoginMode.biometric
              ? _buildBiometricScreen(colors)
              : _buildPhoneScreen(colors, loginState),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────
  // BIOMETRIC SCREEN (returning user)
  // ──────────────────────────────────────────

  Widget _buildBiometricScreen(ThemeColors colors) {
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: double.infinity,
          height: constraints.maxHeight,
          child: Column(
            children: [
              const Spacer(flex: 3),

              // Logo
              _buildLogo(colors, size: 80),
              const SizedBox(height: AppSpacing.xl),

              AppText(
                'Korido',
                variant: AppTextVariant.headlineLarge,
                color: colors.textPrimary,
              ),

              const Spacer(flex: 2),

              // Biometric area
              if (_biometricError != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl,
                  ),
                  child: AppText(
                    _biometricError!,
                    variant: AppTextVariant.bodyMedium,
                    color: colors.errorText,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],

              if (_biometricInProgress)
                SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    color: colors.gold,
                    strokeWidth: 2.5,
                  ),
                )
              else
                GestureDetector(
                  onTap: () async {
                    final storage = ref.read(secureStorageProvider);
                    final refreshToken = await storage.read(
                      key: StorageKeys.refreshToken,
                    );
                    final expectedUserId = _biometricUserId;
                    if (refreshToken != null && expectedUserId != null) {
                      unawaited(
                        _doBiometricAuth(
                          refreshToken: refreshToken,
                          expectedUserId: expectedUserId,
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.gold.withValues(alpha: 0.1),
                      border: Border.all(
                        color: colors.gold.withValues(alpha: 0.25),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.fingerprint,
                      size: 44,
                      color: colors.gold,
                    ),
                  ),
                ),

              const SizedBox(height: AppSpacing.lg),

              AppText(
                _biometricInProgress
                    ? l10n.auth_authenticating
                    : l10n.auth_tapToUnlock,
                variant: AppTextVariant.bodyMedium,
                color: colors.textSecondary,
              ),

              const Spacer(flex: 3),

              // Switch to phone
              TextButton(
                onPressed: _switchToPhone,
                child: AppText(
                  l10n.auth_usePhoneInstead,
                  variant: AppTextVariant.labelMedium,
                  color: colors.gold,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        );
      },
    );
  }

  // ──────────────────────────────────────────
  // PHONE LOGIN SCREEN
  // ──────────────────────────────────────────

  Widget _buildPhoneScreen(ThemeColors colors, LoginState loginState) {
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.giant),

                  // Header
                  _buildLogo(colors, size: 64),
                  const SizedBox(height: AppSpacing.xl),
                  AppText(
                    l10n.appName,
                    variant: AppTextVariant.headlineLarge,
                    color: colors.textPrimary,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  AppText(
                    l10n.auth_welcomeBack,
                    variant: AppTextVariant.bodyLarge,
                    color: colors.textSecondary,
                  ),

                  const SizedBox(height: AppSpacing.giant),

                  // Form
                  _buildCountrySelector(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildPhoneInput(),
                  const SizedBox(height: AppSpacing.xxxl),

                  // Submit
                  AppButton(
                    label: l10n.action_continue,
                    onPressed: _isPhoneValid() ? _submit : null,
                    variant: AppButtonVariant.primary,
                    size: AppButtonSize.large,
                    isFullWidth: true,
                    isLoading: loginState.isLoading,
                  ),
                  if (EnvironmentConfig.showDevOtpShortcut) ...[
                    const SizedBox(height: AppSpacing.sm),
                    AppButton(
                      label: 'Use dev phone',
                      onPressed: loginState.isLoading ? null : _useDevPhone,
                      variant: AppButtonVariant.ghost,
                      isFullWidth: true,
                    ),
                  ],

                  const SizedBox(height: AppSpacing.xl),

                  // Toggle register/login
                  GestureDetector(
                    onTap: () => context.fsmGo('/signup'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          AppText(
                            l10n.auth_dontHaveAccount,
                            variant: AppTextVariant.bodyMedium,
                            color: colors.textSecondary,
                          ),
                          AppText(
                            l10n.auth_signUp,
                            variant: AppTextVariant.labelLarge,
                            color: colors.gold,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ──────────────────────────────────────────
  // SHARED COMPONENTS
  // ──────────────────────────────────────────

  Widget _buildLogo(ThemeColors colors, {double size = 72}) {
    return KoridoMark(size: size);
  }

  Widget _buildCountrySelector() {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          l10n.auth_country,
          variant: AppTextVariant.labelMedium,
          color: colors.textSecondary,
        ),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: _showCountryPicker,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: colors.elevated,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: colors.borderSubtle),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.elevated,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _selectedCountry.flag,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        _selectedCountry.name,
                        variant: AppTextVariant.bodyLarge,
                        color: colors.textPrimary,
                      ),
                      const SizedBox(height: 2),
                      AppText(
                        '${_selectedCountry.fullPrefix} • ${_selectedCountry.currencies.first}',
                        variant: AppTextVariant.bodySmall,
                        color: colors.textTertiary,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.unfold_more_rounded,
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

  Widget _buildPhoneInput() {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final isValid = _isPhoneValid();
    final hasText = _phoneController.text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          l10n.auth_phoneNumber,
          variant: AppTextVariant.labelMedium,
          color: colors.textSecondary,
        ),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _phoneFocusNode.requestFocus(),
          child: Container(
            decoration: BoxDecoration(
              color: colors.elevated,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: hasText && !isValid
                    ? colors.error.withValues(alpha: 0.5)
                    : isValid && hasText
                    ? colors.success.withValues(alpha: 0.5)
                    : colors.borderSubtle,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.lg + 2,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: colors.borderSubtle),
                    ),
                  ),
                  child: AppText(
                    _selectedCountry.fullPrefix,
                    variant: AppTextVariant.bodyLarge,
                    color: colors.textSecondary,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    focusNode: _phoneFocusNode,
                    keyboardType: TextInputType.phone,
                    style: AppTypography.bodyLarge.copyWith(
                      color: colors.textPrimary,
                      letterSpacing: 1.2,
                    ),
                    cursorColor: colors.gold,
                    decoration: InputDecoration(
                      hintText: _getFormattedHint(),
                      hintStyle: AppTypography.bodyLarge.copyWith(
                        color: colors.textTertiary,
                        letterSpacing: 1.2,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.lg,
                      ),
                    ),
                    inputFormatters: [
                      LocalPhoneInputFormatter(
                        dialCode: _selectedCountry.fullPrefix,
                        maxLocalDigits: _selectedCountry.phoneLength,
                      ),
                    ],
                    onTapOutside: (_) => _phoneFocusNode.unfocus(),
                    onChanged: (_) {
                      _syncPhoneControllerToLocal();
                      setState(() {});
                    },
                  ),
                ),
                if (hasText)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.md),
                    child: Icon(
                      isValid ? Icons.check_circle : Icons.error_outline,
                      color: isValid ? colors.success : colors.error,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppText(
          l10n.auth_enterDigits(_selectedCountry.phoneLength),
          variant: AppTextVariant.bodySmall,
          color: colors.textTertiary,
        ),
      ],
    );
  }

  // ──────────────────────────────────────────
  // ACTIONS
  // ──────────────────────────────────────────

  String _getFormattedHint() {
    final format = _selectedCountry.phoneFormat;
    if (format == null) return '0' * _selectedCountry.phoneLength;
    return format.replaceAll('X', '0');
  }

  void _showCountryPicker() {
    final countriesAsync = ref.read(countriesProvider);
    final countries = countriesAsync.value ?? SupportedCountries.all;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _CountryPickerSheet(
        selectedCountry: _selectedCountry,
        countries: countries,
        onSelect: (country) {
          setState(() {
            _selectedCountry = country;
            _syncPhoneControllerToLocal();
          });
          ref.read(selectedCountryProvider.notifier).select(country);
        },
      ),
    );
  }

  bool _isPhoneValid() {
    final phone = _currentLocalPhone();
    return _selectedCountry.isValidLength(phone);
  }

  Future<void> _submit() async {
    if (!_isPhoneValid()) return;
    final phone = _currentLocalPhone();
    _setPhoneControllerText(phone);
    ref.read(selectedCountryProvider.notifier).select(_selectedCountry);
    ref
        .read(loginProvider.notifier)
        .updatePhoneNumber(phone, _selectedCountry.fullPrefix);
    await ref.read(loginProvider.notifier).submitPhoneNumber();
  }

  void _useDevPhone() {
    setState(() {
      _selectedCountry =
          SupportedCountries.findByCode('CI') ??
          SupportedCountries.defaultCountry;
      _setPhoneControllerText('0748805663');
    });
    unawaited(_submit());
  }

  String _currentLocalPhone() {
    return localPhoneInputDigits(
      dialCode: _selectedCountry.fullPrefix,
      phoneNumber: _phoneController.text,
      maxLocalDigits: _selectedCountry.phoneLength,
    );
  }

  void _syncPhoneControllerToLocal() {
    final localPhone = _currentLocalPhone();
    if (localPhone != _phoneController.text) {
      _setPhoneControllerText(localPhone);
    }
  }

  void _syncPhoneViewFromLoginState(LoginState loginState) {
    final phoneValue = loginState.phoneValue;
    if (phoneValue == null) {
      return;
    }

    final country =
        SupportedCountries.findByPrefix(phoneValue.dialCode) ??
        _selectedCountry;
    final currentFieldText = _phoneController.text;
    final shouldRespectFocusedInput =
        _phoneFocusNode.hasFocus &&
        !_looksLikeInternationalPhoneInput(currentFieldText, country);
    if (shouldRespectFocusedInput) {
      return;
    }

    final localPhone = phoneValue.localNumber.length > country.phoneLength
        ? phoneValue.localNumber.substring(0, country.phoneLength)
        : phoneValue.localNumber;
    final needsCountryUpdate = country.code != _selectedCountry.code;
    final needsPhoneUpdate = localPhone != currentFieldText;
    if (!needsCountryUpdate && !needsPhoneUpdate) {
      return;
    }

    setState(() {
      _selectedCountry = country;
      _setPhoneControllerText(localPhone);
    });
  }

  bool _looksLikeInternationalPhoneInput(String value, CountryConfig country) {
    if (value.contains('|') || value.trim().startsWith('+')) {
      return true;
    }
    final digits = digitsOnly(value);
    return digits.startsWith(country.prefix) &&
        digits.length > country.phoneLength;
  }

  void _setPhoneControllerText(String value) {
    _phoneController.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }
}

// ──────────────────────────────────────────
// COUNTRY PICKER
// ──────────────────────────────────────────

class _CountryPickerSheet extends StatefulWidget {
  const _CountryPickerSheet({
    required this.selectedCountry,
    required this.countries,
    required this.onSelect,
  });

  final CountryConfig selectedCountry;
  final List<CountryConfig> countries;
  final ValueChanged<CountryConfig> onSelect;

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  final _searchController = TextEditingController();
  late List<CountryConfig> _filteredCountries = widget.countries;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCountries(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = widget.countries;
      } else {
        final lower = query.toLowerCase();
        _filteredCountries = widget.countries
            .where(
              (c) =>
                  c.name.toLowerCase().contains(lower) ||
                  c.prefix.contains(lower) ||
                  c.code.toLowerCase().contains(lower),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.md),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: colors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                AppText(
                  l10n.auth_selectCountry,
                  variant: AppTextVariant.titleMedium,
                  color: colors.textPrimary,
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close_rounded,
                    color: colors.textSecondary,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: AppInput(
              controller: _searchController,
              variant: AppInputVariant.search,
              hint: l10n.auth_searchCountry,
              prefixIcon: Icons.search_rounded,
              onChanged: _filterCountries,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(color: colors.borderSubtle, height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              itemCount: _filteredCountries.length,
              itemBuilder: (context, index) {
                final colors = context.colors;
                final country = _filteredCountries[index];
                final isSelected = country.code == widget.selectedCountry.code;

                return GestureDetector(
                  onTap: () {
                    widget.onSelect(country);
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colors.gold.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: isSelected
                          ? Border.all(
                              color: colors.gold.withValues(alpha: 0.3),
                            )
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          child: Text(
                            country.flag,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                country.name,
                                variant: AppTextVariant.bodyLarge,
                                color: isSelected
                                    ? colors.gold
                                    : colors.textPrimary,
                              ),
                              AppText(
                                '${country.fullPrefix} • ${country.currencies.join(", ")}',
                                variant: AppTextVariant.bodySmall,
                                color: colors.textTertiary,
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: colors.gold,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_rounded,
                              color: colors.textInverse,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
