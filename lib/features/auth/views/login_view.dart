import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/config/countries.dart';
import 'package:usdc_wallet/features/auth/providers/countries_provider.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/services/legal/legal_documents_service.dart';
import 'package:usdc_wallet/services/biometric/biometric_service.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/features/auth/views/legal_document_view.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';
import 'package:usdc_wallet/core/l10n/app_strings.dart';

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
  bool _isRegistering = false;
  _LoginMode _mode = _LoginMode.checking;
  bool _biometricInProgress = false;
  String? _biometricError;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
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
      _determineLoginMode();
    });
  }

  Future<void> _determineLoginMode() async {
    final biometricService = ref.read(biometricServiceProvider);
    final storage = ref.read(secureStorageProvider);

    final isEnabled = await biometricService.isBiometricEnabled();
    final refreshToken = await storage.read(key: StorageKeys.refreshToken);

    if (isEnabled && refreshToken != null && mounted) {
      setState(() => _mode = _LoginMode.biometric);
      _animationController.forward();
      // Don't auto-prompt biometric on boot — let user tap the button
    } else {
      if (mounted) {
        setState(() => _mode = _LoginMode.phone);
        _animationController.forward();
      }
    }
  }

  Future<void> _doBiometricAuth(String refreshToken) async {
    if (_biometricInProgress) return;
    setState(() {
      _biometricInProgress = true;
      _biometricError = null;
    });

    try {
      final biometricService = ref.read(biometricServiceProvider);
      final authenticatedBio = await biometricService.authenticate(
        localizedReason: AppStrings.unlockKorido,
      );

      if (authenticatedBio.success && mounted) {
        final success = await ref.read(authProvider.notifier).loginWithBiometric(refreshToken);
        if (success && mounted) {
          context.go('/home');
          return;
        }
        if (mounted) {
          setState(() => _biometricError = AppStrings.sessionExpiredRelogin);
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
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.status == AuthStatus.otpSent) {
        context.go('/otp');
      } else if (next.error != null) {
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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _mode == _LoginMode.biometric
                ? _buildBiometricScreen(colors)
                : _buildPhoneScreen(colors, authState),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────
  // BIOMETRIC SCREEN (returning user)
  // ──────────────────────────────────────────

  Widget _buildBiometricScreen(ThemeColors colors) {
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
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
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
                    final refreshToken = await storage.read(key: StorageKeys.refreshToken);
                    if (refreshToken != null) _doBiometricAuth(refreshToken);
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
                _biometricInProgress ? AppStrings.authenticating : AppStrings.tapToUnlock,
                variant: AppTextVariant.bodyMedium,
                color: colors.textSecondary,
              ),

              const Spacer(flex: 3),

              // Switch to phone
              TextButton(
                onPressed: _switchToPhone,
                child: AppText(
                  AppStrings.usePhoneInstead,
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

  Widget _buildPhoneScreen(ThemeColors colors, AuthState authState) {
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
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
                    _isRegistering ? l10n.auth_createWallet : l10n.auth_welcomeBack,
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
                    label: _isRegistering ? l10n.auth_createAccount : l10n.action_continue,
                    onPressed: _isPhoneValid() ? _submit : null,
                    variant: AppButtonVariant.primary,
                    size: AppButtonSize.large,
                    isFullWidth: true,
                    isLoading: authState.isLoading,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Toggle register/login
                  GestureDetector(
                    onTap: () => setState(() => _isRegistering = !_isRegistering),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          AppText(
                            _isRegistering ? l10n.auth_alreadyHaveAccount : l10n.auth_dontHaveAccount,
                            variant: AppTextVariant.bodyMedium,
                            color: colors.textSecondary,
                          ),
                          AppText(
                            _isRegistering ? l10n.auth_signIn : l10n.auth_signUp,
                            variant: AppTextVariant.labelLarge,
                            color: colors.gold,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxxl),

                  // Legal
                  _buildFooter(colors),
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
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: context.colors.goldGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: AppShadows.goldGlow,
      ),
      child: Center(
        child: Text(
          'K',
          style: TextStyle(
            color: colors.textInverse,
            fontSize: size * 0.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
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
                  child: Text(_selectedCountry.flag, style: const TextStyle(fontSize: 24)),
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
                Icon(Icons.unfold_more_rounded, color: colors.textSecondary, size: 20),
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
        Container(
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
                  border: Border(right: BorderSide(color: colors.borderSubtle)),
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
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(_selectedCountry.phoneLength),
                  ],
                  onChanged: (_) => setState(() {}),
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
        const SizedBox(height: AppSpacing.sm),
        AppText(
          l10n.auth_enterDigits(_selectedCountry.phoneLength),
          variant: AppTextVariant.bodySmall,
          color: colors.textTertiary,
        ),
      ],
    );
  }

  Widget _buildFooter(ThemeColors colors) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        AppText(
          l10n.auth_termsPrompt,
          variant: AppTextVariant.bodySmall,
          color: colors.textTertiary,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            GestureDetector(
              onTap: () => _openLegalDocument(LegalDocumentType.termsOfService),
              child: AppText(l10n.auth_termsOfService, variant: AppTextVariant.bodySmall, color: colors.gold),
            ),
            AppText(' ${l10n.auth_and} ', variant: AppTextVariant.bodySmall, color: colors.textTertiary),
            GestureDetector(
              onTap: () => _openLegalDocument(LegalDocumentType.privacyPolicy),
              child: AppText(l10n.auth_privacyPolicy, variant: AppTextVariant.bodySmall, color: colors.gold),
            ),
          ],
        ),
      ],
    );
  }

  // ──────────────────────────────────────────
  // ACTIONS
  // ──────────────────────────────────────────

  void _openLegalDocument(LegalDocumentType type) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LegalDocumentView(documentType: type)),
    );
  }

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
            if (_phoneController.text.length > country.phoneLength) {
              _phoneController.clear();
            }
          });
        },
      ),
    );
  }

  bool _isPhoneValid() {
    final phone = _phoneController.text.replaceAll(RegExp(r'\s+'), '');
    return _selectedCountry.isValidLength(phone);
  }

  void _submit() {
    if (!_isPhoneValid()) return;
    final phone = '${_selectedCountry.fullPrefix}${_phoneController.text}';
    if (_isRegistering) {
      ref.read(authProvider.notifier).register(phone, _selectedCountry.code);
    } else {
      ref.read(authProvider.notifier).login(phone);
    }
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
            .where((c) =>
                c.name.toLowerCase().contains(lower) ||
                c.prefix.contains(lower) ||
                c.code.toLowerCase().contains(lower))
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
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
                AppText(l10n.auth_selectCountry, variant: AppTextVariant.titleMedium, color: colors.textPrimary),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close_rounded, color: colors.textSecondary, size: 24),
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
                    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: isSelected ? colors.gold.withValues(alpha: 0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: isSelected ? Border.all(color: colors.gold.withValues(alpha: 0.3)) : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          child: Text(country.flag, style: const TextStyle(fontSize: 24)),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(country.name, variant: AppTextVariant.bodyLarge, color: isSelected ? colors.gold : colors.textPrimary),
                              AppText('${country.fullPrefix} • ${country.currencies.join(", ")}', variant: AppTextVariant.bodySmall, color: colors.textTertiary),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(color: colors.gold, shape: BoxShape.circle),
                            child: Icon(Icons.check_rounded, color: colors.textInverse, size: 16),
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
