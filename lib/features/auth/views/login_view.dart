import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/countries.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../services/legal/legal_documents_service.dart';
import '../../../services/biometric/biometric_service.dart';
import '../../../services/api/api_client.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import 'legal_document_view.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView>
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _phoneFocusNode = FocusNode();
  CountryConfig _selectedCountry = SupportedCountries.defaultCountry;
  bool _isRegistering = false;
  bool _hasBiometricSession = false;
  bool _biometricInProgress = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();

    // Auto-prompt biometric login if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryBiometricLogin();
    });
  }

  Future<void> _tryBiometricLogin() async {
    final biometricService = ref.read(biometricServiceProvider);
    final storage = ref.read(secureStorageProvider);

    // Check if biometric is enabled and refresh token exists
    final isEnabled = await biometricService.isBiometricEnabled();
    final refreshToken = await storage.read(key: StorageKeys.refreshToken);

    if (isEnabled && refreshToken != null) {
      if (mounted) setState(() => _hasBiometricSession = true);
      await _doBiometricAuth(refreshToken);
    }
  }

  Future<void> _doBiometricAuth(String refreshToken) async {
    if (_biometricInProgress) return;
    setState(() => _biometricInProgress = true);

    try {
      final biometricService = ref.read(biometricServiceProvider);
      final authenticated = await biometricService.authenticate(
        reason: 'Authenticate to access Korido',
      );

      if (authenticated && mounted) {
        final success = await ref.read(authProvider.notifier).loginWithBiometric(refreshToken);
        if (success && mounted) {
          context.go('/home');
          return;
        }
      }
    } catch (_) {
      // Biometric failed — user can retry or use phone
    }

    if (mounted) setState(() => _biometricInProgress = false);
  }

  void _switchToPhoneLogin() {
    setState(() => _hasBiometricSession = false);
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
        context.go('/otp');  // Use go() to replace stack, not push()
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

    return Scaffold(
      backgroundColor: colors.canvas,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenPadding,
                      ),
                      child: _hasBiometricSession
                          ? _buildBiometricOnlyUI(colors)
                          : Column(
                              children: [
                                const SizedBox(height: AppSpacing.giant),
                                _buildHeader(),
                                const SizedBox(height: AppSpacing.giant),
                                _buildForm(authState),
                                const SizedBox(height: AppSpacing.xxxl),
                                _buildFooter(),
                                const SizedBox(height: AppSpacing.xl),
                              ],
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricOnlyUI(ThemeColors colors) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: AppSpacing.giant * 2),

        // Logo
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.goldGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: AppShadows.goldGlow,
          ),
          child: Center(
            child: Text(
              'K',
              style: TextStyle(
                color: colors.textInverse,
                fontSize: 44,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),

        AppText(
          l10n.appName,
          variant: AppTextVariant.headlineLarge,
          color: colors.textPrimary,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppText(
          l10n.auth_welcomeBack,
          variant: AppTextVariant.bodyLarge,
          color: colors.textSecondary,
        ),

        const SizedBox(height: AppSpacing.giant),

        // Biometric button
        if (_biometricInProgress)
          CircularProgressIndicator(color: colors.gold)
        else
          GestureDetector(
            onTap: () async {
              final storage = ref.read(secureStorageProvider);
              final refreshToken = await storage.read(key: StorageKeys.refreshToken);
              if (refreshToken != null) {
                _doBiometricAuth(refreshToken);
              }
            },
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.gold.withValues(alpha: 0.12),
                    border: Border.all(color: colors.gold.withValues(alpha: 0.3)),
                  ),
                  child: Icon(
                    Icons.fingerprint,
                    size: 40,
                    color: colors.gold,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AppText(
                  'Tap to unlock',
                  variant: AppTextVariant.bodyMedium,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),

        const SizedBox(height: AppSpacing.giant),

        // Switch to phone login
        TextButton(
          onPressed: _switchToPhoneLogin,
          child: AppText(
            'Use phone number instead',
            variant: AppTextVariant.labelMedium,
            color: colors.gold,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        // Logo
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.goldGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: AppShadows.goldGlow,
          ),
          child: Icon(
            Icons.account_balance_wallet_rounded,
            color: colors.textInverse,
            size: 36,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),

        // Title
        AppText(
          l10n.appName,
          variant: AppTextVariant.headlineLarge,
          color: colors.textPrimary,
        ),
        const SizedBox(height: AppSpacing.sm),

        // Subtitle with animation
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: AppText(
            _isRegistering
                ? l10n.auth_createWallet
                : l10n.auth_welcomeBack,
            key: ValueKey(_isRegistering),
            variant: AppTextVariant.bodyLarge,
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildForm(AuthState authState) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Country Selector
        _buildCountrySelector(),
        const SizedBox(height: AppSpacing.xl),

        // Phone Input
        _buildPhoneInput(),
        const SizedBox(height: AppSpacing.xxxl),

        // Submit Button
        AppButton(
          label: _isRegistering ? l10n.auth_createAccount : l10n.action_continue,
          onPressed: _isPhoneValid() ? _submit : null,
          variant: AppButtonVariant.primary,
          size: AppButtonSize.large,
          isFullWidth: true,
          isLoading: authState.isLoading,
        ),
        const SizedBox(height: AppSpacing.xl),

        // Toggle Mode
        Center(
          child: GestureDetector(
            onTap: () => setState(() => _isRegistering = !_isRegistering),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  AppText(
                    _isRegistering
                        ? l10n.auth_alreadyHaveAccount
                        : l10n.auth_dontHaveAccount,
                    variant: AppTextVariant.bodyMedium,
                    color: context.colors.textSecondary,
                  ),
                  AppText(
                    _isRegistering ? l10n.auth_signIn : l10n.auth_signUp,
                    variant: AppTextVariant.labelLarge,
                    color: context.colors.gold,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Biometric Login Button
        if (!_isRegistering)
          Consumer(
            builder: (context, ref, _) {
              final biometricAvailable = ref.watch(biometricAvailableProvider);
              final biometricEnabled = ref.watch(biometricEnabledProvider);

              return biometricAvailable.when(
                data: (available) => biometricEnabled.when(
                  data: (enabled) {
                    if (!available || !enabled) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.md),
                      child: GestureDetector(
                        onTap: _tryBiometricLogin,
                        child: Column(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: context.colors.elevated,
                                shape: BoxShape.circle,
                                border: Border.all(color: context.colors.borderSubtle),
                              ),
                              child: Icon(
                                Icons.fingerprint,
                                color: context.colors.gold,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            AppText(
                              'Use Face ID / Fingerprint',
                              variant: AppTextVariant.bodySmall,
                              color: context.colors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),
      ],
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
                // Flag with scale animation
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      scale: animation,
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: Container(
                    key: ValueKey(_selectedCountry.code),
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
                ),
                const SizedBox(width: AppSpacing.md),

                // Country info with slide animation
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.2, 0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOut,
                        )),
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child: Column(
                      key: ValueKey(_selectedCountry.code),
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
                ),

                // Arrow
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colors.elevated,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    Icons.unfold_more_rounded,
                    color: colors.textSecondary,
                    size: 20,
                  ),
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
    final showError = hasText && !isValid;

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
              color: showError
                  ? colors.error.withValues(alpha: 0.5)
                  : isValid && hasText
                      ? colors.success.withValues(alpha: 0.5)
                      : colors.borderSubtle,
            ),
          ),
          child: Row(
            children: [
              // Prefix
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

              // Input
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.elevated,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(AppRadius.lg),
                      bottomRight: Radius.circular(AppRadius.lg),
                    ),
                  ),
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
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
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
              ),

              // Status indicator
              if (hasText)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isValid
                          ? colors.success.withValues(alpha: 0.15)
                          : colors.error.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isValid ? Icons.check_rounded : Icons.close_rounded,
                      color: isValid ? colors.successText : colors.errorText,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Helper text
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: AppText(
                l10n.auth_enterDigits(_selectedCountry.phoneLength),
                variant: AppTextVariant.bodySmall,
                color: showError ? colors.errorText : colors.textTertiary,
              ),
            ),
            if (hasText)
              AppText(
                '${_phoneController.text.length}/${_selectedCountry.phoneLength}',
                variant: AppTextVariant.bodySmall,
                color: isValid ? colors.successText : colors.textTertiary,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooter() {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
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
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              GestureDetector(
                onTap: () => _openLegalDocument(LegalDocumentType.termsOfService),
                child: AppText(
                  l10n.auth_termsOfService,
                  variant: AppTextVariant.bodySmall,
                  color: colors.gold,
                ),
              ),
              AppText(
                l10n.auth_and,
                variant: AppTextVariant.bodySmall,
                color: colors.textTertiary,
              ),
              GestureDetector(
                onTap: () => _openLegalDocument(LegalDocumentType.privacyPolicy),
                child: AppText(
                  l10n.auth_privacyPolicy,
                  variant: AppTextVariant.bodySmall,
                  color: colors.gold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openLegalDocument(LegalDocumentType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LegalDocumentView(documentType: type),
      ),
    );
  }

  String _getFormattedHint() {
    final format = _selectedCountry.phoneFormat;
    if (format == null) return '0' * _selectedCountry.phoneLength;
    return format.replaceAll('X', '0');
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _CountryPickerSheet(
        selectedCountry: _selectedCountry,
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

/// Country Picker Bottom Sheet
class _CountryPickerSheet extends StatefulWidget {
  const _CountryPickerSheet({
    required this.selectedCountry,
    required this.onSelect,
  });

  final CountryConfig selectedCountry;
  final ValueChanged<CountryConfig> onSelect;

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  final _searchController = TextEditingController();
  List<CountryConfig> _filteredCountries = SupportedCountries.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCountries(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = SupportedCountries.all;
      } else {
        final lower = query.toLowerCase();
        _filteredCountries = SupportedCountries.all
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
          // Handle
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.md),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: colors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
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
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colors.elevated,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: colors.textSecondary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search
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

          // Divider
          Divider(color: colors.borderSubtle, height: 1),

          // Country list
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
                              color: colors.gold.withValues(alpha: 0.3))
                          : null,
                    ),
                    child: Row(
                      children: [
                        // Flag
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: colors.elevated,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            country.flag,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),

                        // Info
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
                              const SizedBox(height: 2),
                              AppText(
                                '${country.fullPrefix} • ${country.currencies.join(", ")}',
                                variant: AppTextVariant.bodySmall,
                                color: colors.textTertiary,
                              ),
                            ],
                          ),
                        ),

                        // Check
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
