import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../state/index.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

/// Profile Edit Screen
/// Allows users to update their personal information
class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill with current user data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userState = ref.read(userStateMachineProvider);
      _firstNameController.text = userState.firstName ?? '';
      _lastNameController.text = userState.lastName ?? '';
      _emailController.text = userState.email ?? '';
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final userState = ref.watch(userStateMachineProvider);

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          'Edit Profile',
          variant: AppTextVariant.titleLarge,
          color: colors.textPrimary,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.gold),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              // Avatar section
              _buildAvatarSection(colors, userState),

              const SizedBox(height: AppSpacing.xxxl),

              // First Name
              AppText(
                'First Name',
                variant: AppTextVariant.labelMedium,
                color: colors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppInput(
                controller: _firstNameController,
                hint: 'Enter your first name',
                keyboardType: TextInputType.name,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'First name is required';
                  }
                  if (value.trim().length < 2) {
                    return 'First name must be at least 2 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              // Last Name
              AppText(
                'Last Name',
                variant: AppTextVariant.labelMedium,
                color: colors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppInput(
                controller: _lastNameController,
                hint: 'Enter your last name',
                keyboardType: TextInputType.name,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Last name is required';
                  }
                  if (value.trim().length < 2) {
                    return 'Last name must be at least 2 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              // Email (Optional)
              AppText(
                'Email (Optional)',
                variant: AppTextVariant.labelMedium,
                color: colors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppInput(
                controller: _emailController,
                hint: 'your@email.com',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final emailRegex = RegExp(
                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                    );
                    if (!emailRegex.hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              // Phone Number (Read-only)
              AppText(
                'Phone Number',
                variant: AppTextVariant.labelMedium,
                color: colors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.inputPadding),
                decoration: BoxDecoration(
                  color: colors.elevated.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: colors.borderSubtle,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      color: colors.textTertiary,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppText(
                        _formatPhone(userState.phone),
                        variant: AppTextVariant.bodyLarge,
                        color: colors.textSecondary,
                      ),
                    ),
                    Icon(
                      Icons.lock_outline,
                      color: colors.textTertiary,
                      size: 18,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppText(
                'Phone number cannot be changed',
                variant: AppTextVariant.bodySmall,
                color: colors.textTertiary,
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // Save Button
              AppButton(
                label: l10n.action_save,
                onPressed: _isLoading ? null : _handleSave,
                isLoading: _isLoading,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection(ThemeColors colors, UserState userState) {
    return Center(
      child: Stack(
        children: [
          // Avatar
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.goldGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.full),
              boxShadow: AppShadows.goldGlow,
            ),
            child: Center(
              child: AppText(
                _getInitials(userState),
                variant: AppTextVariant.displaySmall,
                color: AppColors.textInverse,
              ),
            ),
          ),
          // Edit button
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colors.gold,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color: colors.canvas,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.edit,
                size: 16,
                color: AppColors.textInverse,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(UserState userState) {
    final firstName = userState.firstName;
    final lastName = userState.lastName;

    if (firstName != null && firstName.isNotEmpty && lastName != null && lastName.isNotEmpty) {
      return '${firstName[0]}${lastName[0]}'.toUpperCase();
    } else if (firstName != null && firstName.isNotEmpty) {
      return firstName.substring(0, firstName.length >= 2 ? 2 : 1).toUpperCase();
    } else if (userState.phone != null && userState.phone!.length >= 2) {
      return userState.phone!.substring(userState.phone!.length - 2);
    }
    return 'U';
  }

  String _formatPhone(String? phone) {
    if (phone == null || phone.isEmpty) return '';
    if (phone.startsWith('+') && phone.length > 6) {
      final countryCode = phone.substring(0, 4);
      final number = phone.substring(4);
      final formatted = number.replaceAllMapped(
        RegExp(r'.{2}'),
        (match) => '${match.group(0)} ',
      );
      return '$countryCode $formatted'.trim();
    }
    return phone;
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Update user profile
      ref.read(userStateMachineProvider.notifier).updateProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AppText('Profile updated successfully'),
            backgroundColor: AppColors.successBase,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AppText('Failed to update profile: ${e.toString()}'),
            backgroundColor: AppColors.errorBase,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
