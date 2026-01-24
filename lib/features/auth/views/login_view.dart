import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/countries.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../providers/auth_provider.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _phoneController = TextEditingController();
  CountryConfig _selectedCountry = SupportedCountries.defaultCountry;
  bool _isRegistering = false;

  @override
  void dispose() {
    _phoneController.dispose();
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
          ),
        );
        ref.read(authProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom -
                  (AppSpacing.screenPadding * 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xxxl),

                // Logo & Title
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
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
                          Icons.account_balance_wallet,
                          color: AppColors.textInverse,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      const AppText(
                        'JoonaPay',
                        variant: AppTextVariant.headlineLarge,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppText(
                        _isRegistering
                            ? 'Create your USDC wallet'
                            : 'Welcome back',
                        variant: AppTextVariant.bodyLarge,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xxxl * 1.5),

                // Country Selector
                const AppText(
                  'Country',
                  variant: AppTextVariant.labelMedium,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildCountrySelector(),

                const SizedBox(height: AppSpacing.xl),

                // Phone Input
                const AppText(
                  'Phone Number',
                  variant: AppTextVariant.labelMedium,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildPhoneInput(),

                const SizedBox(height: AppSpacing.md),

                // Phone format hint
                AppText(
                  'Format: ${_selectedCountry.phoneFormat ?? 'Enter your number'}',
                  variant: AppTextVariant.bodySmall,
                  color: AppColors.textTertiary,
                ),

                const SizedBox(height: AppSpacing.xxxl),

                // Continue Button
                AppButton(
                  label: _isRegistering ? 'Create Account' : 'Continue',
                  onPressed: _isPhoneValid() ? _submit : null,
                  variant: AppButtonVariant.primary,
                  isFullWidth: true,
                  isLoading: authState.isLoading,
                ),

                const SizedBox(height: AppSpacing.xl),

                // Toggle Register/Login
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _isRegistering = !_isRegistering;
                      });
                    },
                    child: RichText(
                      text: TextSpan(
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        children: [
                          TextSpan(
                            text: _isRegistering
                                ? 'Already have an account? '
                                : "Don't have an account? ",
                          ),
                          TextSpan(
                            text: _isRegistering ? 'Login' : 'Register',
                            style: const TextStyle(
                              color: AppColors.gold500,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xxxl),

                // Terms
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    child: AppText(
                      'By continuing, you agree to our Terms of Service and Privacy Policy',
                      variant: AppTextVariant.bodySmall,
                      color: AppColors.textTertiary,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountrySelector() {
    return GestureDetector(
      onTap: _showCountryPicker,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.slate,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          children: [
            Text(
              _selectedCountry.flag,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    _selectedCountry.name,
                    variant: AppTextVariant.bodyLarge,
                    color: AppColors.textPrimary,
                  ),
                  AppText(
                    _selectedCountry.fullPrefix,
                    variant: AppTextVariant.bodySmall,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.slate,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: _isPhoneValid() || _phoneController.text.isEmpty
              ? AppColors.borderSubtle
              : AppColors.errorBase.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Prefix
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
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
              keyboardType: TextInputType.phone,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textPrimary,
                letterSpacing: 1.5,
              ),
              decoration: InputDecoration(
                hintText: _selectedCountry.phoneFormat?.replaceAll('X', '0') ?? 'Phone number',
                hintStyle: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textTertiary,
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
          // Validation indicator
          if (_phoneController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: Icon(
                _isPhoneValid() ? Icons.check_circle : Icons.error_outline,
                color: _isPhoneValid() ? AppColors.successBase : AppColors.errorBase,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.slate,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: AppSpacing.md),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  const AppText(
                    'Select Country',
                    variant: AppTextVariant.titleMedium,
                    color: AppColors.textPrimary,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.borderSubtle, height: 1),
            // Country list
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: SupportedCountries.all.length,
                itemBuilder: (context, index) {
                  final country = SupportedCountries.all[index];
                  final isSelected = country.code == _selectedCountry.code;
                  return ListTile(
                    leading: Text(
                      country.flag,
                      style: const TextStyle(fontSize: 28),
                    ),
                    title: AppText(
                      country.name,
                      variant: AppTextVariant.bodyLarge,
                      color: isSelected ? AppColors.gold500 : AppColors.textPrimary,
                    ),
                    subtitle: AppText(
                      '${country.fullPrefix} • ${country.currencies.join(", ")}',
                      variant: AppTextVariant.bodySmall,
                      color: AppColors.textSecondary,
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: AppColors.gold500)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedCountry = country;
                        // Clear phone if length changed
                        if (_phoneController.text.length > country.phoneLength) {
                          _phoneController.clear();
                        }
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isPhoneValid() {
    final phone = _phoneController.text.replaceAll(RegExp(r'\s+'), '');
    return _selectedCountry.isValidLength(phone);
  }

  void _submit() {
    if (!_isPhoneValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a valid ${_selectedCountry.phoneLength}-digit phone number',
          ),
          backgroundColor: AppColors.errorBase,
        ),
      );
      return;
    }

    final phone = '${_selectedCountry.fullPrefix}${_phoneController.text}';

    if (_isRegistering) {
      ref.read(authProvider.notifier).register(phone, _selectedCountry.code);
    } else {
      ref.read(authProvider.notifier).login(phone);
    }
  }
}
