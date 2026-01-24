import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  String _countryCode = '+225';
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
      debugPrint('AuthState changed: ${prev?.status} -> ${next.status}');
      if (next.status == AuthStatus.otpSent) {
        debugPrint('Navigating to OTP screen...');
        context.push('/otp');
      } else if (next.error != null) {
        debugPrint('Auth error: ${next.error}');
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
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 1),

              // Logo & Title
              Center(
                child: Column(
                  children: [
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
                        Icons.account_balance_wallet,
                        color: AppColors.textInverse,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const AppText(
                      'JoonaPay',
                      variant: AppTextVariant.headlineLarge,
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const AppText(
                      'Your premium USDC wallet',
                      variant: AppTextVariant.bodyMedium,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 1),

              // Phone Input
              PhoneInput(
                controller: _phoneController,
                countryCode: _countryCode,
                label: 'Phone Number',
                onCountryCodeTap: () {
                  // TODO: Show country picker
                },
                onChanged: (value) {
                  setState(() {});
                },
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Continue Button
              AppButton(
                label: _isRegistering ? 'Create Account' : 'Continue',
                onPressed: _phoneController.text.length >= 8
                    ? () => _submit()
                    : null,
                variant: AppButtonVariant.primary,
                isFullWidth: true,
                isLoading: authState.isLoading,
              ),

              const SizedBox(height: AppSpacing.lg),

              // Toggle Register/Login
              Center(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _isRegistering = !_isRegistering;
                    });
                  },
                  child: AppText(
                    _isRegistering
                        ? 'Already have an account? Login'
                        : "Don't have an account? Register",
                    variant: AppTextVariant.bodyMedium,
                    color: AppColors.gold500,
                  ),
                ),
              ),

              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    final phone = '$_countryCode${_phoneController.text}';

    if (_isRegistering) {
      ref.read(authProvider.notifier).register(phone, 'CI');
    } else {
      ref.read(authProvider.notifier).login(phone);
    }
  }
}
