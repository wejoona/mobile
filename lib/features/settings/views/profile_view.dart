import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../domain/enums/index.dart';
import '../../../state/index.dart';
import '../../../services/api/api_client.dart';

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with empty values
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();

    // Populate controllers after first frame using post-frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final userState = ref.read(userStateMachineProvider);
        _firstNameController.text = userState.firstName ?? '';
        _lastNameController.text = userState.lastName ?? '';
        _emailController.text = userState.email ?? '';
      }
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
    final userState = ref.watch(userStateMachineProvider);

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const AppText(
          'Profile',
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gold500),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.gold500),
              onPressed: () => setState(() => _isEditing = true),
            )
          else
            TextButton(
              onPressed: () {
                setState(() => _isEditing = false);
                // Reset to original values
                _firstNameController.text = userState.firstName ?? '';
                _lastNameController.text = userState.lastName ?? '';
                _emailController.text = userState.email ?? '';
              },
              child: const AppText(
                'Cancel',
                variant: AppTextVariant.labelMedium,
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          children: [
            // Avatar
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppColors.goldGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: AppShadows.goldGlow,
                    ),
                    child: Center(
                      child: AppText(
                        _getInitials(userState),
                        variant: AppTextVariant.headlineLarge,
                        color: AppColors.textInverse,
                      ),
                    ),
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.slate,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.gold500, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: AppColors.gold500,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Phone (non-editable)
            _buildInfoCard(
              label: 'Phone Number',
              value: userState.phone ?? 'Not set',
              icon: Icons.phone,
              isVerified: true,
            ),

            const SizedBox(height: AppSpacing.md),

            // First Name
            _isEditing
                ? _buildEditableField(
                    label: 'First Name',
                    controller: _firstNameController,
                    icon: Icons.person,
                  )
                : _buildInfoCard(
                    label: 'First Name',
                    value: userState.firstName ?? 'Not set',
                    icon: Icons.person,
                  ),

            const SizedBox(height: AppSpacing.md),

            // Last Name
            _isEditing
                ? _buildEditableField(
                    label: 'Last Name',
                    controller: _lastNameController,
                    icon: Icons.person_outline,
                  )
                : _buildInfoCard(
                    label: 'Last Name',
                    value: userState.lastName ?? 'Not set',
                    icon: Icons.person_outline,
                  ),

            const SizedBox(height: AppSpacing.md),

            // Email
            _isEditing
                ? _buildEditableField(
                    label: 'Email',
                    controller: _emailController,
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  )
                : _buildInfoCard(
                    label: 'Email',
                    value: userState.email ?? 'Not set',
                    icon: Icons.email,
                  ),

            const SizedBox(height: AppSpacing.md),

            // KYC Status
            _buildInfoCard(
              label: 'KYC Status',
              value: _getKycStatusText(userState.kycStatus),
              icon: Icons.verified_user,
              valueColor: _getKycStatusColor(userState.kycStatus),
              trailing: userState.kycStatus != KycStatus.verified
                  ? TextButton(
                      onPressed: () => context.push('/settings/kyc'),
                      child: const AppText(
                        'Verify',
                        variant: AppTextVariant.labelMedium,
                        color: AppColors.gold500,
                      ),
                    )
                  : null,
            ),

            const SizedBox(height: AppSpacing.md),

            // Country
            _buildInfoCard(
              label: 'Country',
              value: _getCountryName(userState.countryCode),
              icon: Icons.public,
            ),

            if (_isEditing) ...[
              const SizedBox(height: AppSpacing.xxxl),

              // Save Button
              AppButton(
                label: 'Save Changes',
                onPressed: _canSave() ? _saveProfile : null,
                variant: AppButtonVariant.primary,
                isFullWidth: true,
                isLoading: _isSaving,
              ),
            ],

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String label,
    required String value,
    required IconData icon,
    Color? valueColor,
    bool isVerified = false,
    Widget? trailing,
  }) {
    return AppCard(
      variant: AppCardVariant.subtle,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.elevated,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: AppColors.textSecondary, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  label,
                  variant: AppTextVariant.bodySmall,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Row(
                  children: [
                    Expanded(
                      child: AppText(
                        value,
                        variant: AppTextVariant.bodyLarge,
                        color: valueColor ?? AppColors.textPrimary,
                      ),
                    ),
                    if (isVerified)
                      const Icon(
                        Icons.verified,
                        color: AppColors.successBase,
                        size: 18,
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return AppCard(
      variant: AppCardVariant.subtle,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.elevated,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: AppColors.gold500, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  label,
                  variant: AppTextVariant.bodySmall,
                  color: AppColors.textTertiary,
                ),
                TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: 'Enter value',
                    hintStyle: TextStyle(color: AppColors.textTertiary),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(UserState userState) {
    final firstName = userState.firstName;
    final lastName = userState.lastName;

    if (firstName != null && lastName != null) {
      return '${firstName[0]}${lastName[0]}'.toUpperCase();
    } else if (firstName != null) {
      return firstName.substring(0, firstName.length >= 2 ? 2 : 1).toUpperCase();
    } else if (userState.phone != null) {
      return userState.phone!.substring(userState.phone!.length - 2);
    }
    return 'U';
  }

  String _getKycStatusText(KycStatus status) {
    switch (status) {
      case KycStatus.none:
        return 'Not Verified';
      case KycStatus.pending:
        return 'Pending Review';
      case KycStatus.verified:
        return 'Verified';
      case KycStatus.rejected:
        return 'Rejected';
    }
  }

  Color _getKycStatusColor(KycStatus status) {
    switch (status) {
      case KycStatus.none:
        return AppColors.textSecondary;
      case KycStatus.pending:
        return AppColors.warningBase;
      case KycStatus.verified:
        return AppColors.successBase;
      case KycStatus.rejected:
        return AppColors.errorBase;
    }
  }

  String _getCountryName(String countryCode) {
    const countries = {
      'CI': 'Ivory Coast',
      'NG': 'Nigeria',
      'KE': 'Kenya',
      'GH': 'Ghana',
      'SN': 'Senegal',
    };
    return countries[countryCode] ?? countryCode;
  }

  bool _canSave() {
    return _firstNameController.text.isNotEmpty ||
        _lastNameController.text.isNotEmpty ||
        _emailController.text.isNotEmpty;
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    try {
      final dio = ref.read(dioProvider);
      await dio.put('/user/profile', data: {
        'firstName': _firstNameController.text.isEmpty
            ? null
            : _firstNameController.text,
        'lastName':
            _lastNameController.text.isEmpty ? null : _lastNameController.text,
        'email': _emailController.text.isEmpty ? null : _emailController.text,
      });

      // Update profile via state machine
      ref.read(userStateMachineProvider.notifier).updateProfile(
            firstName: _firstNameController.text.isEmpty
                ? null
                : _firstNameController.text,
            lastName: _lastNameController.text.isEmpty
                ? null
                : _lastNameController.text,
            email: _emailController.text.isEmpty ? null : _emailController.text,
          );

      if (mounted) {
        setState(() {
          _isSaving = false;
          _isEditing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppColors.successBase,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: AppColors.errorBase,
          ),
        );
      }
    }
  }
}
