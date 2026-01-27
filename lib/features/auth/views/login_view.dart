import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/countries.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../services/legal/legal_documents_service.dart';
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
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.status == AuthStatus.otpSent) {
        context.push('/otp');
      } else if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.errorBase,
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
      backgroundColor: AppColors.obsidian,
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
                      child: Column(
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

  Widget _buildHeader() {
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
          child: const Icon(
            Icons.account_balance_wallet_rounded,
            color: AppColors.textInverse,
            size: 36,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),

        // Title
        AppText(
          l10n.appName,
          variant: AppTextVariant.headlineLarge,
          color: AppColors.textPrimary,
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
            color: AppColors.textSecondary,
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText(
                    _isRegistering
                        ? l10n.auth_alreadyHaveAccount
                        : l10n.auth_dontHaveAccount,
                    variant: AppTextVariant.bodyMedium,
                    color: AppColors.textSecondary,
                  ),
                  AppText(
                    _isRegistering ? l10n.auth_signIn : l10n.auth_signUp,
                    variant: AppTextVariant.labelLarge,
                    color: AppColors.gold500,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCountrySelector() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          l10n.auth_country,
          variant: AppTextVariant.labelMedium,
          color: AppColors.textSecondary,
        ),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: _showCountryPicker,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.slate,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                // Flag
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.elevated,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _selectedCountry.flag,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // Country info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        _selectedCountry.name,
                        variant: AppTextVariant.bodyLarge,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(height: 2),
                      AppText(
                        '${_selectedCountry.fullPrefix} • ${_selectedCountry.currencies.first}',
                        variant: AppTextVariant.bodySmall,
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ),
                ),

                // Arrow
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.elevated,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(
                    Icons.unfold_more_rounded,
                    color: AppColors.textSecondary,
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
          color: AppColors.textSecondary,
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: AppColors.slate,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: showError
                  ? AppColors.errorBase.withValues(alpha: 0.5)
                  : isValid && hasText
                      ? AppColors.successBase.withValues(alpha: 0.5)
                      : AppColors.borderSubtle,
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
                decoration: const BoxDecoration(
                  border: Border(
                    right: BorderSide(color: AppColors.borderSubtle),
                  ),
                ),
                child: AppText(
                  _selectedCountry.fullPrefix,
                  variant: AppTextVariant.bodyLarge,
                  color: AppColors.textSecondary,
                ),
              ),

              // Input
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  focusNode: _phoneFocusNode,
                  keyboardType: TextInputType.phone,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    letterSpacing: 1.2,
                  ),
                  cursorColor: AppColors.gold500,
                  decoration: InputDecoration(
                    hintText: _getFormattedHint(),
                    hintStyle: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textTertiary,
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
                          ? AppColors.successBase.withValues(alpha: 0.15)
                          : AppColors.errorBase.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isValid ? Icons.check_rounded : Icons.close_rounded,
                      color: isValid ? AppColors.successText : AppColors.errorText,
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
                color: showError ? AppColors.errorText : AppColors.textTertiary,
              ),
            ),
            if (hasText)
              AppText(
                '${_phoneController.text.length}/${_selectedCountry.phoneLength}',
                variant: AppTextVariant.bodySmall,
                color: isValid ? AppColors.successText : AppColors.textTertiary,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooter() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          AppText(
            l10n.auth_termsPrompt,
            variant: AppTextVariant.bodySmall,
            color: AppColors.textTertiary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => _openLegalDocument(LegalDocumentType.termsOfService),
                child: AppText(
                  l10n.auth_termsOfService,
                  variant: AppTextVariant.bodySmall,
                  color: AppColors.gold500,
                ),
              ),
              AppText(
                l10n.auth_and,
                variant: AppTextVariant.bodySmall,
                color: AppColors.textTertiary,
              ),
              GestureDetector(
                onTap: () => _openLegalDocument(LegalDocumentType.privacyPolicy),
                child: AppText(
                  l10n.auth_privacyPolicy,
                  variant: AppTextVariant.bodySmall,
                  color: AppColors.gold500,
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
    final l10n = AppLocalizations.of(context)!;
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.graphite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
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
              color: AppColors.borderDefault,
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
                  color: AppColors.textPrimary,
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.slate,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: AppColors.textSecondary,
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
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.slate,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: TextField(
                controller: _searchController,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
                cursorColor: AppColors.gold500,
                decoration: InputDecoration(
                  hintText: l10n.auth_searchCountry,
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                ),
                onChanged: _filterCountries,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Divider
          const Divider(color: AppColors.borderSubtle, height: 1),

          // Country list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              itemCount: _filteredCountries.length,
              itemBuilder: (context, index) {
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
                          ? AppColors.gold500.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: isSelected
                          ? Border.all(
                              color: AppColors.gold500.withValues(alpha: 0.3))
                          : null,
                    ),
                    child: Row(
                      children: [
                        // Flag
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.slate,
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
                                    ? AppColors.gold500
                                    : AppColors.textPrimary,
                              ),
                              const SizedBox(height: 2),
                              AppText(
                                '${country.fullPrefix} • ${country.currencies.join(", ")}',
                                variant: AppTextVariant.bodySmall,
                                color: AppColors.textTertiary,
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
                              color: AppColors.gold500,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: AppColors.textInverse,
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
